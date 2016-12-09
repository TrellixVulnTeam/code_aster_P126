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

from code_aster.DataStructure.DataStructure cimport DataStructure
from code_aster.DataFields.FieldOnNodes cimport FieldOnNodesDouble
from code_aster.Results.ResultsContainer cimport ResultsContainerPtr

#### EvolutiveThermalLoad

cdef class EvolutiveThermalLoad(ResultsContainer):
    """Python wrapper on the C++ EvolutiveThermalLoad Object"""

    def __cinit__(self, bint init = True):
        """Initialization: stores the pointer to the C++ object"""
        if init :
            self._cptr = <ResultsContainerPtr *>\
                new EvolutiveThermalLoadPtr(new EvolutiveThermalLoadInstance() )

    def getName(self):
        """Return the name of DataStructure"""
        return self.getInstance().getName()

    def getType(self):
        """Return the type of DataStructure"""
        return self.getInstance().getType()

    def getType(self):
        """Return the type of DataStructure"""
        return self.getInstance().getType()
