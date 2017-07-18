/**
 * @file StructureInterfaceInterface.cxx
 * @brief Interface python de StructureInterface
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

#include "PythonBindings/StructureInterfaceInterface.h"
#include <boost/python.hpp>
BOOST_PYTHON_MEMBER_FUNCTION_OVERLOADS(StructureInterfaceInstance_overloads, addInterface, 3, 4)

void exportStructureInterfaceToPython()
{
    using namespace boost::python;

    enum_< InterfaceTypeEnum >( "InterfaceType" )
        .value( "MacNeal", MacNeal )
        .value( "CraigBampton", CraigBampton )
        .value( "HarmonicCraigBampton", HarmonicCraigBampton )
        .value( "None", NoInterfaceType )
        ;

    StructureInterfaceInstance::StructureInterfacePtr
        (*c1)(const DOFNumberingPtr& curDof) =
            &StructureInterfaceInstance::create;
    StructureInterfaceInstance::StructureInterfacePtr
        (*c2)() = &StructureInterfaceInstance::create;

   

    class_< StructureInterfaceInstance, StructureInterfaceInstance::StructureInterfacePtr,
            bases< DataStructure > > ( "StructureInterface", no_init )
        .def( "create", c1 )
        .def( "create", c2 )
        .staticmethod( "create" )
	.def( "addInterface", &StructureInterfaceInstance::addInterface, StructureInterfaceInstance_overloads() )
    ;
};
