/**
 * @file AssemblyMatrixInterface.cxx
 * @brief Interface python de AssemblyMatrix
 * @author Nicolas Sellenet
 * @section LICENCE
 *   Copyright (C) 1991 - 2017  EDF R&D                www.code-aster.org
 *
 *   This file is part of Code_Aster.
 *
 *   Code_Aster is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 2 of the License, or
 *   (at your option) any later version.
 *
 *   Code_Aster is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with Code_Aster.  If not, see <http://www.gnu.org/licenses/>.
 */

/* person_in_charge: nicolas.sellenet at edf.fr */

#include <boost/python.hpp>
#include <PythonBindings/factory.h>
#include "PythonBindings/AssemblyMatrixInterface.h"


void exportAssemblyMatrixToPython()
{
    using namespace boost::python;
    class_< AssemblyMatrixDoubleInstance, AssemblyMatrixDoublePtr,
            bases< DataStructure > >
        ( "AssemblyMatrixDouble", no_init )
        .def( "__init__", make_constructor(
            &initFactoryPtr< AssemblyMatrixDoubleInstance >) )
        .def( "__init__", make_constructor(
            &initFactoryPtr< AssemblyMatrixDoubleInstance,
                             std::string >) )
        .def( "addKinematicsLoad", &AssemblyMatrixDoubleInstance::addKinematicsLoad )
        .def( "build", &AssemblyMatrixDoubleInstance::build )
        .def( "factorization", &AssemblyMatrixDoubleInstance::factorization )
        .def( "getDOFNumbering", &AssemblyMatrixDoubleInstance::getDOFNumbering )
        .def( "setDOFNumbering", &AssemblyMatrixDoubleInstance::setDOFNumbering )
        .def( "appendElementaryMatrix", &AssemblyMatrixDoubleInstance::appendElementaryMatrix )
    ;

    class_< AssemblyMatrixComplexInstance, AssemblyMatrixComplexPtr,
            bases< DataStructure > >
        ( "AssemblyMatrixComplex", no_init )
        .def( "__init__", make_constructor(
            &initFactoryPtr< AssemblyMatrixComplexInstance >) )
        .def( "__init__", make_constructor(
            &initFactoryPtr< AssemblyMatrixComplexInstance ,
                             std::string >) )
        .def( "addKinematicsLoad", &AssemblyMatrixComplexInstance::addKinematicsLoad )
        .def( "build", &AssemblyMatrixComplexInstance::build )
        .def( "factorization", &AssemblyMatrixComplexInstance::factorization )
        .def( "getDOFNumbering", &AssemblyMatrixComplexInstance::getDOFNumbering )
        .def( "setDOFNumbering", &AssemblyMatrixComplexInstance::setDOFNumbering )
        .def( "appendElementaryMatrix", &AssemblyMatrixComplexInstance::appendElementaryMatrix )
    ;
};
