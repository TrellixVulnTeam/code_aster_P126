# coding: utf-8

# Copyright (C) 1991 - 2016  EDF R&D                www.code-aster.org
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

from libcpp.string cimport string
from cython.operator cimport dereference as deref


cdef class Behaviour:
    """Python wrapper on the C++ Behaviour Object"""

    def __cinit__( self, ConstitutiveLawEnum curLaw , DeformationEnum curDeformation ):
        """Initialization: stores the pointer to the C++ object"""
        self._cptr = new BehaviourPtr( new BehaviourInstance( curLaw, curDeformation ) )

    def __dealloc__( self ):
        """Destructor"""
        if self._cptr is not NULL:
            del self._cptr

    cdef set( self, BehaviourPtr other ):
        """Point to an existing object"""
        self._cptr = new BehaviourPtr( other )

    cdef BehaviourPtr* getPtr( self ):
        """Return the pointer on the c++ shared-pointer object"""
        return self._cptr

    cdef BehaviourInstance* getInstance( self ):
        """Return the pointer on the c++ instance object"""
        return self._cptr.get()
