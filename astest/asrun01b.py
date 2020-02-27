# coding=utf-8
# --------------------------------------------------------------------
# Copyright (C) 1991 - 2020 - EDF R&D - www.code-aster.org
# This file is part of code_aster.
#
# code_aster is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# code_aster is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with code_aster.  If not, see <http://www.gnu.org/licenses/>.
# --------------------------------------------------------------------

# person_in_charge: mathieu.courtois at edf.fr

"""
Unittests of run_aster package.
"""

import os
import os.path as osp
import unittest
from glob import glob

import code_aster
from code_aster.Commands import *
from run_aster.export import (Export, File, Parameter, ParameterFloat,
                              ParameterInt, ParameterListStr, ParameterStr)

code_aster.init()
test = code_aster.TestCase()


class TestParameter(unittest.TestCase):
    """Check Parameter objects"""

    def test00_factory(self):
        para = Parameter.factory("debug")
        self.assertIsInstance(para, ParameterStr)
        para = Parameter.factory("mpi_nbcpu")
        self.assertIsInstance(para, ParameterInt)
        para = Parameter.factory("memory_limit")
        self.assertIsInstance(para, ParameterFloat)
        para = Parameter.factory("testlist")
        self.assertIsInstance(para, ParameterListStr)
        # unknown as list[str]
        para = Parameter.factory("xxxx")
        self.assertIsInstance(para, ParameterListStr)
        # deprecated as None: ignored
        para = Parameter.factory("service")
        self.assertIsNone(para)

    def test01_str(self):
        para = ParameterStr("debug")
        self.assertIsNone(para.value)
        para.set("nodebug")
        self.assertEqual(para.value, "nodebug")
        para.set(123)
        self.assertEqual(para.value, "123")
        para.set(["no", "debug"])
        self.assertEqual(para.value, "no debug")
        para.set([2, "debug"])
        self.assertEqual(para.value, "2 debug")

    def test02_int(self):
        para = ParameterInt("mpi_nbcpu")
        self.assertIsNone(para.value)
        para.set(2)
        self.assertEqual(para.value, 2)
        para.set(16.0)
        self.assertEqual(para.value, 16)
        para.set("8.1")
        self.assertEqual(para.value, 8)
        para.set([16.0])
        self.assertEqual(para.value, 16)
        with self.assertRaises(ValueError):
            para.set([16.0, 32.0])

    def test03_float(self):
        para = ParameterFloat("memory_limit")
        self.assertIsNone(para.value)
        para.set(2048)
        self.assertEqual(para.value, 2048.0)
        para.set(1024.1)
        self.assertEqual(para.value, 1024.1)
        para.set("512")
        self.assertEqual(para.value, 512.0)
        para.set([16.5])
        self.assertEqual(para.value, 16.5)
        with self.assertRaises(ValueError):
            para.set([16.0, 32.0])

    def test01_liststr(self):
        para = ParameterListStr("testlist")
        self.assertIsNone(para.value)
        para.set([])
        self.assertSequenceEqual(para.value, [])
        para.set("ci")
        self.assertSequenceEqual(para.value, ["ci"])
        para.set(123.456)
        self.assertSequenceEqual(para.value, ["123.456"])
        para.set(["ci", "verification"])
        self.assertSequenceEqual(para.value, ["ci", "verification"])
        para.set([2, "debug"])
        self.assertSequenceEqual(para.value, ["2", "debug"])


class TestFile(unittest.TestCase):
    """Check File object"""

    def test_file(self):
        fobj = File("/a/filename", resu=True)
        self.assertEqual(fobj.path, "/a/filename")
        self.assertEqual(fobj.filetype, "libr")
        self.assertEqual(fobj.unit, 0)
        self.assertFalse(fobj.isdir)
        self.assertFalse(fobj.data)
        self.assertTrue(fobj.resu)
        self.assertFalse(fobj.compr)
        self.assertEqual(repr(fobj), "F libr /a/filename R 0")

    def test_directory(self):
        tmpdir = os.getcwd()
        wrk = File(tmpdir)
        self.assertEqual(wrk.path, os.getcwd())
        self.assertEqual(wrk.filetype, "libr")
        self.assertEqual(wrk.unit, 0)
        self.assertTrue(wrk.isdir)
        self.assertTrue(wrk.data)
        self.assertFalse(wrk.resu)
        self.assertFalse(wrk.compr)
        self.assertEqual(repr(wrk), f"R libr {tmpdir} D 0")


class TestExport(unittest.TestCase):
    """Check Export object"""

    def test(self):
        fexp = glob("*.export")[0]
        with self.assertRaises(FileNotFoundError):
            export = Export(fexp + "XX")

        export = Export(fexp)
        self.assertIn("/asrun01b.py", repr(export))
        self.assertTrue(export.has_param("time_limit"))
        self.assertFalse(export.has_param("consbtc"))
        self.assertIsInstance(export.get_param("time_limit"), ParameterFloat)
        self.assertIsNone(export.get_param("consbtc"))
        self.assertEqual(export.get("time_limit"), 60.0)
        self.assertIsNone(export.get("consbtc"))
        self.assertEqual(len(export.datafiles), 1)
        self.assertEqual(len(export.resultfiles), 0)
        comm = [i for i in export.datafiles if i.filetype == "comm"][0]
        self.assertEqual(osp.basename(comm.path), "asrun01b.py")
        self.assertEqual(comm.unit, 1)
        self.assertTrue(comm.data)

    def test_args(self):
        text = "\n".join([
            "A args --continue --memjeveux=512",
            "A max_base 1000",
            "A abort",
        ])
        export = Export(from_string=text)
        export.check()
        self.assertSequenceEqual(export.args,
            ["--continue", "--memjeveux", "512",
             "--max_base", "1000", "--abort",
             "--memory", "4096.0"])
        self.assertEqual(export.get_argument_value("memjeveux", float), 512.0)
        self.assertEqual(export.get_argument_value("memory", float), 4096.0)
        self.assertEqual(export.get_argument_value("max_base", float), 1000.0)
        self.assertEqual(export.get_argument_value("continue", bool), True)
        self.assertEqual(export.get_argument_value("abort", bool), True)
        self.assertEqual(export.get_argument_value("tpmax", float), None)
        self.assertEqual(export.get_argument_value("dbgjeveux", bool), False)


result = unittest.main(argv=["asrun01b"], exit=False).result

test.assertTrue( result.wasSuccessful() )
test.printSummary()

FIN()
