#!/usr/bin/env python3
"""Find commas at the end of a line that join two REXX arguments (#513).

  mbt run libcheck                   # with the 80-column check
  python3 scripts/rexxcont.py [-v] [FILE ...]

In REXX a comma at the end of a line is a continuation, and the comma is
replaced by a blank. It is not an argument separator:

  call fssfieldL j+#lstOFF,loff+#lal2,
        #prot+#hi+colorlist2,'_LIST.'j      /* ... loff+#lal2 #prot+... */

passes one argument where two were meant, and every later argument shifts by
one (#487, the long-line split of commit 8a1b82a). The same holds for a
function call f(a,<newline>b) and for the argument separator of a template,
parse arg a,<newline>b.

The scanner reads each member as REXX (strings, nested comments, clauses
after THEN/ELSE/OTHERWISE) and looks at every line whose last token is a
comma. A comma after an operator (x = a ||,) is a continuation by
construction and passes. A comma after an operand is reported:

  call     in a CALL clause
  paren    inside parentheses (a function call or a grouped expression)
  template in an ARG / PARSE ARG clause

The next line may start with a comma (a separator after the continuation),
and a line may end in two commas (separator, then continuation); both pass.
A comma after an operand in SAY, an assignment or ADDRESS is a continuation
whose blank is part of the text, and a comma before the closing parenthesis
joins nothing (FMTCOLUM counts its arguments, so an empty last one would be
wrong); both are counted, and listed with -v.

An intended continuation after an operand is entered in
scripts/rexxcont.toml with the member, the text of the line and the reason;
the text, not the line number, so that an edit elsewhere in the member does
not detach it. An entry that matches nothing fails too.

Exit code 0 only when every finding is allowed.
"""
import os
import re
import sys
import tomllib

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LIBS = ("rxlib", "samples")
OPERATOR = set("+-*/%|&=\\<>\u00ac^")
CLAUSE_WORDS = {"then", "else", "otherwise"}


def read_text(path):
    with open(path, "rb") as f:
        raw = f.read()
    try:
        return raw.decode("utf-8")
    except UnicodeDecodeError:
        return raw.decode("latin-1")


class Clause:
    """What the scanner knows about the clause it is in."""

    def __init__(self):
        self.words = []
        self.depth = 0

    @property
    def first(self):
        return self.words[0].lower() if self.words else ""

    def kind(self):
        f = self.first
        w = [x.lower() for x in self.words]
        if f == "call":
            return "call"
        if f == "arg" or (f == "parse" and "arg" in w[:3]):
            return "template"
        return "other"


def scan(text):
    """Return ([(line, prev_char, clause_kind, depth)], lines, first_sig) for
    the lines that end in a comma outside strings and comments."""
    found = []
    first_sig = {}       # line number -> first significant char
    clause = Clause()
    comment = 0          # nesting depth of /* */
    carried = False      # the previous line ended in a comma
    lines = text.split("\n")
    for n, line in enumerate(lines, 1):
        if not carried and comment == 0:
            clause = Clause()
        carried = False
        i = 0
        last = None      # last significant char of this line
        prev = None      # the significant char before it
        word = ""

        def flush():
            nonlocal word
            if word:
                clause.words.append(word)
                if word.lower() in CLAUSE_WORDS and clause.depth == 0:
                    clause.words = []
                word = ""

        def sig(c):
            nonlocal last, prev
            prev, last = last, c
            first_sig.setdefault(n, c)

        while i < len(line):
            c = line[i]
            two = line[i:i + 2]
            if comment:
                if two == "/*":
                    comment += 1
                    i += 2
                elif two == "*/":
                    comment -= 1
                    i += 2
                else:
                    i += 1
                continue
            if two == "/*":
                flush()
                comment = 1
                i += 2
                continue
            if c in "'\"":
                flush()
                j = i + 1
                while j < len(line):
                    if line[j] == c:
                        if line[j:j + 2] == c + c:
                            j += 2
                            continue
                        break
                    j += 1
                clause.words.append("'")
                sig("'")
                i = j + 1
                continue
            if c == ";":
                flush()
                clause = Clause()
                last = prev = None
                i += 1
                continue
            if c.isspace():
                flush()
                i += 1
                continue
            if c == "(":
                flush()
                clause.depth += 1
                sig(c)
            elif c == ")":
                flush()
                clause.depth = max(0, clause.depth - 1)
                sig(c)
            elif c == ",":
                flush()
                sig(c)
            elif c == ":" and clause.depth == 0:
                flush()
                clause = Clause()
                last = prev = None
            elif c in OPERATOR:
                flush()
                sig(c)
            else:
                word += c
                sig("a")
            i += 1
        flush()
        if last == ",":
            carried = True
            found.append((n, prev, clause.kind(), clause.depth))
    return found, lines, first_sig


def classify(prev, kind, depth, next_first):
    """None where the comma is a continuation by construction, "note" for a
    continuation outside an argument list (SAY, an assignment: the blank is
    part of the text), else the kind of finding."""
    if prev is not None and prev in OPERATOR:
        return None
    if prev == "," or next_first == ",":
        return None     # ",," or ",<newline>,": separator, then continuation
    if next_first == ")":
        return "note"   # a comma before the closing parenthesis joins nothing
    if kind == "call":
        return "call"
    if depth > 0:
        return "paren"
    if kind == "template":
        return "template"
    return "note"


def classified(text):
    """[(line, why, source_lines)] for every line-end comma; why is None, "note"
    or the kind of a finding."""
    found, lines, first_sig = scan(text)
    out = []
    for n, prev, kind, depth in found:
        m = n + 1
        while m <= len(lines) and m not in first_sig:
            m += 1
        out.append((n, classify(prev, kind, depth, first_sig.get(m)), lines))
    return out


def members():
    for lib in LIBS:
        d = os.path.join(ROOT, lib)
        for f in sorted(os.listdir(d)):
            p = os.path.join(d, f)
            if os.path.isfile(p) and not f.lower().endswith(".md"):
                yield lib + "/" + f, p


def load_allow():
    path = os.path.join(ROOT, "scripts", "rexxcont.toml")
    if not os.path.isfile(path):
        return []
    with open(path, "rb") as f:
        return tomllib.load(f).get("allow", [])


def norm(s):
    return re.sub(r"\s+", " ", s).strip()


def main(argv):
    verbose = "-v" in argv
    files = [a for a in argv if not a.startswith("-")]
    if files:
        todo = [(os.path.relpath(os.path.abspath(f), ROOT), f) for f in files]
    else:
        todo = list(members())
    allow = load_allow()
    used = [False] * len(allow)
    findings = []
    nmembers = ncommas = nnotes = 0
    for name, path in todo:
        nmembers += 1
        for n, why, lines in classified(read_text(path)):
            ncommas += 1
            if why is None:
                continue
            if why == "note":
                nnotes += 1
                if verbose:
                    print("%s:%d: note: continuation outside an argument "
                          "list\n    %s" % (name, n, lines[n - 1].rstrip()))
                continue
            text = norm(lines[n - 1])
            hit = False
            for k, a in enumerate(allow):
                if a["member"] == name and norm(a["line"]) == text:
                    used[k] = hit = True
            if not hit:
                findings.append((name, n, why, lines[n - 1].rstrip()))
    errors = ["%s:%d: %s: comma at the end of the line after an operand"
              "\n    %s" % f for f in findings]
    if not files:
        for k, a in enumerate(allow):
            if not used[k]:
                errors.append("scripts/rexxcont.toml: %s: %r matches no finding"
                              % (a["member"], a["line"]))
    if errors:
        print("\n".join(errors), file=sys.stderr)
        print("rexxcont: %d problem(s) in %d members; a continuation comma is "
              "not an argument separator (see scripts/rexxcont.py)"
              % (len(errors), nmembers), file=sys.stderr)
        return 1
    print("rexxcont: %d members, %d line-end commas, %d outside argument "
          "lists, %d allowed, none joins arguments"
          % (nmembers, ncommas, nnotes, sum(used)))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
