#!/usr/bin/env python3
"""Tests for scripts/check_irx_symbols.py: python3 -m unittest scripts/test_check_irx_symbols.py"""
import contextlib
import io
import json
import os
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import check_irx_symbols as chk  # noqa: E402


def fake_file370(csects, members):
    """A stand-in for file370: csects[file name] and members[file name]."""
    def run(args):
        path = Path(args[-1])
        if args[0] == "--json":
            return json.dumps({"csects": [{"name": n} for n in csects.get(path.name, [])]})
        return "".join(f"    member {m} 0\n" for m in members.get(path.name, []))
    return run


class Build:
    def __init__(self, files, csects=None, members=None):
        self.tmp = tempfile.TemporaryDirectory()
        for f in files:
            Path(self.tmp.name, f).write_text("")
        self.run = fake_file370(csects or {}, members or {})

    def check(self, *others):
        old = chk.run
        chk.run = self.run
        try:
            with contextlib.redirect_stdout(io.StringIO()) as out:
                rc = chk.main([self.tmp.name, *others])
        finally:
            chk.run = old
        return rc, out.getvalue()


class Cleaning(unittest.TestCase):
    def build(self, *a, **kw):
        b = Build(*a, **kw)
        self.addCleanup(b.tmp.cleanup)
        return b


class AnyIrxName(Cleaning):
    FILES = ["BREXX", "BREXX.iebcopy", "BRXVTOC", "BRXVTOC.iebcopy", "hostenv.o"]

    def test_clean_build_passes(self):
        b = self.build(self.FILES, {"BREXX": ["BREXX", "BRXSTAM"], "hostenv.o": ["BRXSTAM"]},
                  {"BRXVTOC.iebcopy": ["BRXVTOC"]})
        rc, out = b.check()
        self.assertEqual(rc, 0, out)

    def test_symbol_in_the_cesd(self):
        rc, out = self.build(self.FILES, {"BREXX": ["BREXX", "IRXSTAM"]}).check()
        self.assertEqual(rc, 1)
        self.assertIn("CESD of BREXX", out)

    def test_module_name_and_alias(self):
        rc, out = self.build(self.FILES, members={"BRXVTOC.iebcopy": ["BRXVTOC", "IRXVTOC"]}).check()
        self.assertEqual(rc, 1)
        self.assertIn("member of BRXVTOC.iebcopy", out)

    def test_object_deck(self):
        rc, out = self.build(self.FILES, {"hostenv.o": ["irxstam"]}).check()
        self.assertEqual(rc, 1)
        self.assertIn("ESD of hostenv.o", out)

    def test_test_objects_are_not_shipped(self):
        b = self.build(self.FILES + ["tstxcom.o"], {"tstxcom.o": ["IRXEXTE"]})
        rc, out = b.check()
        self.assertEqual(rc, 0, out)

    def test_no_load_module_is_an_error(self):
        with self.assertRaises(SystemExit):
            self.build(["hostenv.o"]).check()


class TwoBuilds(Cleaning):
    def test_name_only_the_base_has_is_no_error(self):
        base = self.build(["BREXX", "BREXX.iebcopy"], {"BREXX": ["IRXSTAM"]})
        new = self.build(["BREXX", "BREXX.iebcopy"], {"BREXX": ["BRXSTAM"]})
        old = chk.run
        chk.run = lambda a: (base.run if Path(a[-1]).parent == Path(base.tmp.name) else new.run)(a)
        try:
            with contextlib.redirect_stdout(io.StringIO()):
                rc = chk.main([base.tmp.name, new.tmp.name])
        finally:
            chk.run = old
        self.assertEqual(rc, 0)


if __name__ == "__main__":
    unittest.main()
