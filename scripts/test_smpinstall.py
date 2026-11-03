#!/usr/bin/env python3
"""Tests for scripts/smpinstall.py: python3 -m unittest scripts/test_smpinstall.py"""
import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import smpinstall  # noqa: E402

# The statements of the allocation job as mbt packages it: 3.0.0 calls the
# procedure bare, 3.0.1 adds a check step in front and a COND to the call.
JOB_300 = """\
//SMPALLOC PROC TGTVOL=MVSRES,DLBVOL=SMP000
//ALLOC   EXEC PGM=IEFBR14
//        PEND
//ALLOC   EXEC SMPALLOC
"""

JOB_301 = """\
//SMPALLOC PROC TGTVOL=MVSRES,DLBVOL=SMP000
//ALLOC   EXEC PGM=IEFBR14
//        PEND
//CHECK   EXEC PGM=IDCAMS
//ALLOC   EXEC SMPALLOC,COND=(0,NE,CHECK)
//
"""


class GiveVolumes(unittest.TestCase):
    def test_job_of_3_0_0(self):
        out = smpinstall.give_volumes(JOB_300, "TK5RES", "TK5DLB")
        self.assertIn("//ALLOC   EXEC SMPALLOC,TGTVOL=TK5RES,DLBVOL=TK5DLB\n", out)

    def test_job_of_3_0_1_with_cond(self):
        out = smpinstall.give_volumes(JOB_301, "TK5RES", "TK5DLB")
        self.assertIn(
            "//ALLOC   EXEC SMPALLOC,TGTVOL=TK5RES,DLBVOL=TK5DLB,COND=(0,NE,CHECK)\n", out)

    def test_single_blanks(self):
        out = smpinstall.give_volumes("//ALLOC EXEC SMPALLOC,COND=(0,NE,CHECK)\n", "V1", "")
        self.assertEqual(out, "//ALLOC EXEC SMPALLOC,TGTVOL=V1,COND=(0,NE,CHECK)\n")

    def test_only_the_call_changes(self):
        out = smpinstall.give_volumes(JOB_301, "TK5RES", "")
        self.assertIn("//SMPALLOC PROC TGTVOL=MVSRES,DLBVOL=SMP000\n", out)
        self.assertIn("//ALLOC   EXEC PGM=IEFBR14\n", out)

    def test_no_call_is_refused(self):
        with self.assertRaises(SystemExit):
            smpinstall.give_volumes("//CHECK   EXEC PGM=IDCAMS\n", "V1", "V2")


if __name__ == "__main__":
    unittest.main()
