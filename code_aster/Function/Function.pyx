# coding: utf-8

# Copyright (C) 1991 - 2015  EDF R&D                www.code-aster.org
#
# This file is part of Code_Aster.
#
# Code_Aster is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# Code_Aster is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Code_Aster.  If not, see <http://www.gnu.org/licenses/>.

import cython
from libcpp.string cimport string

from code_aster.Supervis.libBaseUtils import resizeStr
from code_aster.DataStructure.DataStructure cimport DataStructure


# numpy implementation in cython currently generates a warning at compilation
import numpy as np
cimport numpy as np
np.import_array()


cdef class Function(DataStructure):
    """Python wrapper on the C++ Function object"""

    def __cinit__(self, bint init=True, string jeveuxName=" "):
        """Initialization: stores the pointer to the C++ object"""
        if init:
            self._cptr = new FunctionPtr(new FunctionInstance())
        else:
            self.attach(jeveuxName)

    def __getnewargs__(self):
        """Define arguments to create an instance at unpickling and to attach it
        to its Jeveux object."""
        return (False, self.getInstance().getName())

    def __dealloc__(self):
        """Destructor"""
        if self._cptr is not NULL:
            del self._cptr

    cdef set(self, FunctionPtr other):
        """Point to an existing object"""
        self._cptr = new FunctionPtr(other)

    cpdef attach(self, string jeveuxName):
        """Attach this function to an existing Jeveux object"""
        jname = resizeStr(jeveuxName, 8)
        if not jname:
            return
        self._cptr = new FunctionPtr(new FunctionInstance(jname))
        ret = self.getInstance().build()
        assert ret, "can't attach Function to the Jeveux object >{0}<".format(jname)

    cdef FunctionPtr* getPtr(self):
        """Return the pointer on the c++ shared-pointer object"""
        return self._cptr

    cdef FunctionInstance* getInstance(self):
        """Return the pointer on the c++ instance object"""
        return self._cptr.get()

    def getName(self):
        """Return the name of DataStructure"""
        return self.getInstance().getName()

    def getType(self):
        """Return the type of DataStructure"""
        return self.getInstance().getType()

    def setParameterName(self, string name):
        """Set the name of the parameter"""
        self.getInstance().setParameterName(name)

    def setResultName(self, string name):
        """Set the name of the parameter"""
        self.getInstance().setResultName(name)

    def setInterpolation(self, typ):
        """Set the type of interpolation"""
        typ = typ.strip()
        try:
            assert len(typ) == 7
            spl = typ.split()
            assert len(spl) == 2
            assert spl[0] in ('LIN', 'LOG', 'NON')
            assert spl[1] in ('LIN', 'LOG', 'NON')
            typ = " ".join(spl)
        except AssertionError:
            raise ValueError("Invalid interpolation type: '{}'".format(typ))
        self.getInstance().setInterpolation(typ)

    def setExtrapolation(self, typ):
        """Set the type of extrapolation"""
        typ = typ.strip()
        try:
            assert len(typ) == 2
            assert typ[0] in ('E', 'C', 'L', 'I')
            assert typ[1] in ('E', 'C', 'L', 'I')
        except AssertionError:
            raise ValueError("Invalid extrapolation type: '{}'".format(typ))
        self.getInstance().setExtrapolation(typ)

    def setValues(self, abscissas, ordinates):
        """Define the values of the function"""
        self.getInstance().setValues(abscissas, ordinates)

    def size(self):
        """Return the number of points of the function"""
        return self.getInstance().size()

    def getProperties(self):
        """Return the properties of the function"""
        return self.getInstance().getProperties()

    @cython.boundscheck(False)
    def getValuesAsArray(self, copy=True, writeable=False):
        """Return an array object of the values with (default) or without
        copying the data. Without copying you should delete the 'view' when
        the Function is removed."""
        cdef const double* data = self.getInstance().getDataPtr()
        cdef long size = self.getInstance().size()
        cdef np.npy_intp shape[2]
        cdef long i
        cdef np.ndarray[np.float64_t, ndim=2] res
        if copy:
            res = np.empty([size, 2], dtype=float)
            with nogil:
                for i in range(size):
                    res[i, 0] = data[2 * i]
                    res[i, 1] = data[2 * i + 1]
        else:
            shape[0] = <np.npy_intp> size
            shape[1] = 2
            res = np.PyArray_SimpleNewFromData(2, shape, np.NPY_DOUBLE, <void*> data)
            res.flags.writeable = writeable
        return res

    def debugPrint(self, logicalUnit=6):
        """Print debug information of the content"""
        self.getInstance().debugPrint(logicalUnit)

    def copyProperties(self, other):
        """Shortcut to copy the properties of another function"""
        prop = other.getProperties()
        self = Function()
        self.setParameterName(prop[2])
        self.setResultName(prop[3])
        self.setInterpolation(prop[1])
        self.setExtrapolation(prop[4])

    # operations on Functions
    def abs(self):
        """Return the absolute value"""
        new = Function()
        new.copyProperties(self)
        values = self.getValuesAsArray()
        new.setValues(values[:, 0], np.abs(values[:, 1]))
        return new
