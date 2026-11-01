#!/usr/bin/env python3
"""Tests for scripts/rexxcont.py: python3 -m unittest scripts/test_rexxcont.py"""
import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import rexxcont  # noqa: E402


def whys(text):
    return [w for _n, w, _l in rexxcont.classified(text) if w != "note" and w]


def notes(text):
    return [w for _n, w, _l in rexxcont.classified(text) if w == "note"]


class Joins(unittest.TestCase):
    def test_call_argument_joined(self):
        self.assertEqual(whys("call f a,b,\n   c\n"), ["call"])

    def test_call_after_then_and_else(self):
        self.assertEqual(whys("if x then call f a,\n b\n"), ["call"])
        self.assertEqual(whys("if x then nop; else call f a,\n b\n"), ["call"])

    def test_function_call_argument_joined(self):
        self.assertEqual(whys("x = f(a,b,\n  c)\n"), ["paren"])

    def test_call_with_paren_arguments(self):
        self.assertEqual(whys("call f(a,b,\n  c)\n"), ["call"])

    def test_template_separator_joined(self):
        self.assertEqual(whys("parse arg a,\n b\n"), ["template"])
        self.assertEqual(whys("parse upper arg a,\n b\n"), ["template"])

    def test_label_then_call(self):
        self.assertEqual(whys("lbl: call f a,\n b\n"), ["call"])

    def test_second_clause_of_the_line(self):
        self.assertEqual(whys("say 1; call f a,\n b\n"), ["call"])

    def test_comment_after_the_comma(self):
        self.assertEqual(whys("call f a, /* more */\n b\n"), ["call"])


class Passes(unittest.TestCase):
    def test_leading_comma_on_the_next_line(self):
        self.assertEqual(whys("call f a,\n  ,b\n"), [])
        self.assertEqual(whys("x = f(a,\n ,b)\n"), [])

    def test_double_comma(self):
        self.assertEqual(whys("call f a,,\n b\n"), [])

    def test_comma_after_an_operator(self):
        self.assertEqual(whys("x = a ||,\n b\n"), [])
        self.assertEqual(whys("if a = b &,\n c then nop\n"), [])
        self.assertEqual(whys("call f 'a' ||,\n 'b'\n"), [])

    def test_comma_before_closing_parenthesis(self):
        self.assertEqual(whys("x = f(a,\n )\n"), [])
        self.assertEqual(notes("x = f(a,\n )\n"), ["note"])

    def test_continuation_outside_an_argument_list(self):
        self.assertEqual(whys("say 'a',\n 'b'\n"), [])
        self.assertEqual(whys("if x then ,\n say 1\n"), [])
        self.assertEqual(whys("x = 'a',\n 'b'\n"), [])

    def test_comma_in_string_or_comment(self):
        self.assertEqual(whys("call f 'a,'\n"), [])
        self.assertEqual(whys("call f a /* b, */\n"), [])
        self.assertEqual(whys("/* call f a,\n b, */\ncall g\n"), [])

    def test_next_clause_starts_afresh(self):
        self.assertEqual(whys("call f a,b\nx = a,\n b\n"), [])


class Members(unittest.TestCase):
    def test_every_member_is_clean(self):
        self.assertEqual(rexxcont.main([]), 0)


if __name__ == "__main__":
    unittest.main()
