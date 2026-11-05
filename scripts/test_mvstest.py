#!/usr/bin/env python3
"""Tests for the abend check of scripts/mvstest.py: python3 -m unittest scripts/test_mvstest.py"""
import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import mvstest as mt  # noqa: E402

# What BREXX's ESTAE writes (src/brexx.c), as it reads back from the spool
CAUGHT = """--- SYSTSPRT ---
File abndtso.rexx
 
BRX0003E - ABEND CAUGHT IN BREXX/370
 
USER IBMUSER   BREXX     ABEND S0C4
EPA 002475B0  PSW 078D0000 001B58A2  ILC 02  INTC 0004
GR 0-3   00000000  0026D7C0  002BD110  00000001
"""
QUIET = "--- SYSTSPRT ---\nFile abs.rexx\nABS - test 1 .. PASS\n"


class ExpectedAbends(unittest.TestCase):
    def test_none(self):
        self.assertEqual(mt._expected_abends("/* MVSTEST TSO */"), set())

    def test_one_and_several(self):
        self.assertEqual(mt._expected_abends("/* MVSTEST ABEND=S0C4 */"), {"S0C4"})
        self.assertEqual(
            mt._expected_abends("/* MVSTEST ABEND=s0c4,S0C1 */\n/* MVSTEST ABEND=U0100 */"),
            {"S0C4", "S0C1", "U0100"})

    def test_other_directives_are_not_abends(self):
        self.assertEqual(mt._expected_abends("/* MVSTEST RC=8 */"), set())


class CaughtAbends(unittest.TestCase):
    def test_by_step(self):
        files = [("JES2", "JESYSMSG", "--- JESYSMSG ---\n" + CAUGHT),
                 ("ABS", "STDOUT", QUIET),
                 ("ABNDTSO", "SYSTSPRT", CAUGHT)]
        caught, loose, unreadable = mt._caught_abends(files)
        self.assertEqual(caught, {"ABNDTSO": ["S0C4"]})
        self.assertEqual((loose, unreadable), ([], set()))

    def test_no_step_name(self):
        caught, loose, _ = mt._caught_abends([("", "SYSTSPRT", CAUGHT)])
        self.assertEqual((caught, loose), ({}, ["S0C4"]))

    def test_unreadable_dd(self):
        files = [("ABS", "STDOUT", "--- STDOUT --- [FAILED TO RETRIEVE: HTTP 500]")]
        self.assertEqual(mt._caught_abends(files)[2], {"ABS"})

    def test_unreadable_dd_without_step_name_fails_the_job(self):
        files = [("", "STDOUT", "--- STDOUT --- [FAILED TO RETRIEVE: x]")]
        _, loose, unreadable = mt._caught_abends(files)
        self.assertEqual(mt._job_failures(loose, unreadable),
                         ["SPOOL DD WITHOUT STEP NAME UNREADABLE"])

    def test_loose_abend_and_unreadable_dd_both_reported(self):
        files = [("", "SYSTSPRT", CAUGHT),
                 ("", "STDOUT", "--- STDOUT --- [FAILED TO RETRIEVE: x]")]
        _, loose, unreadable = mt._caught_abends(files)
        self.assertEqual(len(mt._job_failures(loose, unreadable)), 2)

    def test_clean_job_has_no_job_failure(self):
        files = [("ABS", "STDOUT", QUIET)]
        _, loose, unreadable = mt._caught_abends(files)
        self.assertEqual(mt._job_failures(loose, unreadable), [])

    def test_unreadable_input_dd_does_not_count(self):
        files = [("VTOC", "SYSTSIN", "--- SYSTSIN --- [FAILED TO RETRIEVE: x]")]
        self.assertEqual(mt._caught_abends(files)[2], set())

    def test_unreadable_jes_log_does_not_count(self):
        files = [("JES2", "JESYSMSG", "--- JESYSMSG --- [FAILED TO RETRIEVE: x]")]
        self.assertEqual(mt._caught_abends(files)[2], set())

    def test_a_test_that_prints_the_text_is_not_an_abend(self):
        said = "--- STDOUT ---\nBRX0003E - ABEND CAUGHT IN BREXX/370 is what we look for\n"
        self.assertEqual(mt._caught_abends([("X", "STDOUT", said)])[0], {})


class Verdict(unittest.TestCase):
    def test_quiet_step_passes(self):
        self.assertEqual(mt._verdict("RC 0", 0, [], set(), False), (True, "RC 0"))

    def test_caught_abend_with_rc_0_fails(self):
        # the defect of #607: TMP step RC 0, abend only in the output
        ok, text = mt._verdict("RC 0", 0, ["S0C4"], set(), False)
        self.assertFalse(ok)
        self.assertIn("ABEND CAUGHT S0C4", text)

    def test_declared_abend_passes(self):
        self.assertTrue(mt._verdict("RC 0", 0, ["S0C4"], {"S0C4"}, False)[0])

    def test_declared_abend_with_declared_rc_passes(self):
        self.assertTrue(mt._verdict("RC 8", 8, ["S0C4"], {"S0C4"}, False)[0])

    def test_declared_rc_alone_does_not_cover_an_abend(self):
        # batch: RC 8 is what the caught abend gives, MVSTEST RC=8 hid it
        self.assertFalse(mt._verdict("RC 8", 8, ["S0C4"], set(), False)[0])

    def test_other_abend_than_declared_fails(self):
        ok, text = mt._verdict("RC 0", 0, ["S0C1"], {"S0C4"}, False)
        self.assertFalse(ok)
        self.assertIn("declared S0C4", text)

    def test_declared_abend_that_did_not_happen_fails(self):
        ok, text = mt._verdict("RC 0", 0, [], {"S0C4"}, False)
        self.assertFalse(ok)
        self.assertIn("NOT CAUGHT", text)

    def test_wrong_rc_still_fails(self):
        self.assertFalse(mt._verdict("RC 4", 0, [], set(), False)[0])

    def test_unreadable_output_fails(self):
        self.assertFalse(mt._verdict("RC 0", 0, [], set(), True)[0])


if __name__ == "__main__":
    unittest.main()
