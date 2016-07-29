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

from code_aster.DataStructure.DataStructure cimport DataStructure
from code_aster.Loads.KinematicsLoad cimport KinematicsLoadPtr
from code_aster.Discretization.DOFNumbering cimport ForwardDOFNumberingPtr
from code_aster.LinearAlgebra.ElementaryMatrix cimport ElementaryMatrixPtr


cdef extern from "LinearAlgebra/AssemblyMatrix.h":

    cdef cppclass AssemblyMatrixDoubleInstance:

        AssemblyMatrixDoubleInstance()
        void addKinematicsLoad( KinematicsLoadPtr& currentLoad )
        bint build()
        bint factorization()
        void setDOFNumbering( ForwardDOFNumberingPtr& curDOFNumber )
        void setElementaryMatrix(  ElementaryMatrixPtr& currentElemMatrix )
        const string getType()
        void debugPrint( int logicalUnit )

    cdef cppclass AssemblyMatrixDoublePtr:

        AssemblyMatrixDoublePtr( AssemblyMatrixDoublePtr& )
        AssemblyMatrixDoublePtr( AssemblyMatrixDoubleInstance * )
        AssemblyMatrixDoubleInstance* get()

    cdef cppclass AssemblyMatrixComplexInstance:

        AssemblyMatrixComplexInstance()
        void addKinematicsLoad( KinematicsLoadPtr& currentLoad )
        bint build()
        bint factorization()
        void setDOFNumbering( ForwardDOFNumberingPtr& curDOFNumber )
        void setElementaryMatrix(  ElementaryMatrixPtr& currentElemMatrix )
        const string getType()
        void debugPrint( int logicalUnit )

    cdef cppclass AssemblyMatrixComplexPtr:

        AssemblyMatrixComplexPtr( AssemblyMatrixComplexPtr& )
        AssemblyMatrixComplexPtr( AssemblyMatrixComplexInstance * )
        AssemblyMatrixComplexInstance* get()

#### AssemblyMatrixDouble

cdef class AssemblyMatrixDouble( DataStructure ):
    cdef AssemblyMatrixDoublePtr* _cptr
    cdef set( self, AssemblyMatrixDoublePtr other )
    cdef AssemblyMatrixDoublePtr* getPtr( self )
    cdef AssemblyMatrixDoubleInstance* getInstance( self )

#### AssemblyMatrixComplex

cdef class AssemblyMatrixComplex( DataStructure ):
    cdef AssemblyMatrixComplexPtr* _cptr
    cdef set( self, AssemblyMatrixComplexPtr other )
    cdef AssemblyMatrixComplexPtr* getPtr( self )
    cdef AssemblyMatrixComplexInstance* getInstance( self )
