/**
 * @file KinematicsLoadInterface.cxx
 * @brief Interface python de KinematicsLoad
 * @author Nicolas Sellenet
 * @section LICENCE
 *   Copyright (C) 1991 - 2019  EDF R&D                www.code-aster.org
 *
 *   This file is part of Code_Aster.
 *
 *   Code_Aster is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
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

#include "PythonBindings/KinematicsLoadInterface.h"
#include "PythonBindings/factory.h"
#include <boost/python.hpp>

namespace py = boost::python;

void exportKinematicsLoadToPython() {

    bool ( KinematicsMechanicalLoadInstance::*c1 )( const PhysicalQuantityComponent &,
                                                    const double &, const std::string & ) =
        &KinematicsMechanicalLoadInstance::addImposedMechanicalDOFOnElements;
    bool ( KinematicsMechanicalLoadInstance::*c2 )(
        const PhysicalQuantityComponent &, const double &, const std::vector< std::string > & ) =
        &KinematicsMechanicalLoadInstance::addImposedMechanicalDOFOnElements;

    bool ( KinematicsMechanicalLoadInstance::*c3 )( const PhysicalQuantityComponent &,
                                                    const double &, const std::string & ) =
        &KinematicsMechanicalLoadInstance::addImposedMechanicalDOFOnNodes;
    bool ( KinematicsMechanicalLoadInstance::*c4 )(
        const PhysicalQuantityComponent &, const double &, const std::vector< std::string > & ) =
        &KinematicsMechanicalLoadInstance::addImposedMechanicalDOFOnNodes;

    bool ( KinematicsThermalLoadInstance::*c5 )( const PhysicalQuantityComponent &, const double &,
                                                 const std::string & ) =
        &KinematicsThermalLoadInstance::addImposedThermalDOFOnElements;
    bool ( KinematicsThermalLoadInstance::*c6 )( const PhysicalQuantityComponent &, const double &,
                                                 const std::vector< std::string > & ) =
        &KinematicsThermalLoadInstance::addImposedThermalDOFOnElements;

    bool ( KinematicsThermalLoadInstance::*c7 )( const PhysicalQuantityComponent &, const double &,
                                                 const std::string & ) =
        &KinematicsThermalLoadInstance::addImposedThermalDOFOnNodes;
    bool ( KinematicsThermalLoadInstance::*c8 )( const PhysicalQuantityComponent &, const double &,
                                                 const std::vector< std::string > & ) =
        &KinematicsThermalLoadInstance::addImposedThermalDOFOnNodes;
    bool ( KinematicsThermalLoadInstance::*c9 )( const PhysicalQuantityComponent &,
                                                 const FunctionPtr &,
                                                 const std::vector< std::string > & ) =
        &KinematicsThermalLoadInstance::addImposedThermalDOFOnNodes;

    py::class_< KinematicsLoadInstance, KinematicsLoadInstance::KinematicsLoadPtr,
                py::bases< DataStructure > >( "KinematicsLoad", py::no_init )
        // fake initFactoryPtr: created by subclasses
        // fake initFactoryPtr: created by subclasses
        .def( "build", &KinematicsLoadInstance::build )
        .def( "setModel", &KinematicsLoadInstance::setModel );

    py::class_< KinematicsMechanicalLoadInstance,
                KinematicsMechanicalLoadInstance::KinematicsMechanicalLoadPtr,
                py::bases< KinematicsLoadInstance > >( "KinematicsMechanicalLoad", py::no_init )
        .def( "__init__", py::make_constructor(&initFactoryPtr< KinematicsMechanicalLoadInstance >))
        .def( "__init__", py::make_constructor(
                              &initFactoryPtr< KinematicsMechanicalLoadInstance, std::string >))
        .def( "addImposedMechanicalDOFOnElements", c1 )
        .def( "addImposedMechanicalDOFOnElements", c2 )
        .def( "addImposedMechanicalDOFOnNodes", c3 )
        .def( "addImposedMechanicalDOFOnNodes", c4 );

    py::class_< KinematicsThermalLoadInstance,
                KinematicsThermalLoadInstance::KinematicsThermalLoadPtr,
                py::bases< KinematicsLoadInstance > >( "KinematicsThermalLoad", py::no_init )
        .def( "__init__", py::make_constructor(&initFactoryPtr< KinematicsThermalLoadInstance >))
        .def( "__init__",
              py::make_constructor(&initFactoryPtr< KinematicsThermalLoadInstance, std::string >))
        .def( "addImposedThermalDOFOnElements", c5 )
        .def( "addImposedThermalDOFOnElements", c6 )
        .def( "addImposedThermalDOFOnNodes", c7 )
        .def( "addImposedThermalDOFOnNodes", c8 )
        .def( "addImposedThermalDOFOnNodes", c9 );

    py::class_< KinematicsAcousticLoadInstance,
                KinematicsAcousticLoadInstance::KinematicsAcousticLoadPtr,
                py::bases< KinematicsLoadInstance > >( "KinematicsAcousticLoad", py::no_init )
        .def( "__init__", py::make_constructor(&initFactoryPtr< KinematicsAcousticLoadInstance >))
        .def( "__init__",
              py::make_constructor(&initFactoryPtr< KinematicsAcousticLoadInstance, std::string >));
};
