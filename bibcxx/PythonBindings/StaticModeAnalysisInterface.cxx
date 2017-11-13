/**
 * @file StaticModeAnalysisInterface.cxx
 * @brief Interface python de StaticModeAnalysis
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

#include "PythonBindings/StaticModeAnalysisInterface.h"
#include "PythonBindings/factory.h"
#include <boost/python.hpp>

void exportStaticModeAnalysisToPython()
{
    using namespace boost::python;

    class_< StaticModeDeplInstance, StaticModeDeplPtr >
        ( "StaticModeDepl", no_init )
        .def( "__init__", make_constructor(
            &initFactoryPtr< StaticModeDeplInstance > ) )
        .def( "setMassMatrix", &StaticModeDeplInstance::setMassMatrix )
        .def( "setStiffMatrix", &StaticModeDeplInstance::setStiffMatrix )
        .def( "setLinearSolver", &StaticModeDeplInstance::setLinearSolver )
        .def( "enableOnAllMesh", &StaticModeDeplInstance::enableOnAllMesh )
        .def( "setAllComponents", &StaticModeDeplInstance::setAllComponents )
        .def( "WantedGroupOfNodes", &StaticModeDeplInstance::WantedGroupOfNodes )
        .def( "UnwantedComponent", &StaticModeDeplInstance::UnwantedComponent )
        .def( "WantedComponent", &StaticModeDeplInstance::WantedComponent )
        .def( "execute", &StaticModeDeplInstance::execute )
    ;

    class_< StaticModeForcInstance, StaticModeForcPtr >
        ( "StaticModeForc", no_init )
        .def( "__init__", make_constructor(
            &initFactoryPtr< StaticModeForcInstance > ) )
        .def( "setMassMatrix", &StaticModeForcInstance::setMassMatrix )
        .def( "setStiffMatrix", &StaticModeForcInstance::setStiffMatrix )
        .def( "setLinearSolver", &StaticModeForcInstance::setLinearSolver )
        .def( "enableOnAllMesh", &StaticModeForcInstance::enableOnAllMesh )
        .def( "setAllComponents", &StaticModeForcInstance::setAllComponents )
        .def( "WantedGroupOfNodes", &StaticModeForcInstance::WantedGroupOfNodes )
        .def( "UnwantedComponent", &StaticModeForcInstance::UnwantedComponent )
        .def( "WantedComponent", &StaticModeForcInstance::WantedComponent )
        .def( "execute", &StaticModeForcInstance::execute )
    ;

    class_< StaticModePseudoInstance, StaticModePseudoPtr >
        ( "StaticModePseudo", no_init )
        .def( "__init__", make_constructor(
            &initFactoryPtr< StaticModePseudoInstance > ) )
        .def( "setMassMatrix", &StaticModePseudoInstance::setMassMatrix )
        .def( "setStiffMatrix", &StaticModePseudoInstance::setStiffMatrix )
        .def( "setLinearSolver", &StaticModePseudoInstance::setLinearSolver )
        .def( "enableOnAllMesh", &StaticModePseudoInstance::enableOnAllMesh )
        .def( "setAllComponents", &StaticModePseudoInstance::setAllComponents )
        .def( "WantedGroupOfNodes", &StaticModePseudoInstance::WantedGroupOfNodes )
        .def( "WantedDirection", &StaticModePseudoInstance::WantedDirection )
        .def( "setNameForDirection", &StaticModePseudoInstance::setNameForDirection )
        .def( "WantedAxe", &StaticModePseudoInstance::WantedAxe )
        .def( "UnwantedComponent", &StaticModePseudoInstance::UnwantedComponent )
        .def( "WantedComponent", &StaticModePseudoInstance::WantedComponent )
        .def( "execute", &StaticModePseudoInstance::execute )
    ;

    class_< StaticModeInterfInstance, StaticModeInterfPtr >
        ( "StaticModeInterf", no_init )
        .def( "__init__", make_constructor(
            &initFactoryPtr< StaticModeInterfInstance > ) )
        .def( "setMassMatrix", &StaticModeInterfInstance::setMassMatrix )
        .def( "setStiffMatrix", &StaticModeInterfInstance::setStiffMatrix )
        .def( "setLinearSolver", &StaticModeInterfInstance::setLinearSolver )
        .def( "enableOnAllMesh", &StaticModeInterfInstance::enableOnAllMesh )
        .def( "setAllComponents", &StaticModeInterfInstance::setAllComponents )
        .def( "WantedGroupOfNodes", &StaticModeInterfInstance::WantedGroupOfNodes )
        .def( "UnwantedComponent", &StaticModeInterfInstance::UnwantedComponent )
        .def( "WantedComponent", &StaticModeInterfInstance::WantedComponent )
        .def( "setNumberOfModes", &StaticModeInterfInstance::setNumberOfModes )
        .def( "setShift", &StaticModeInterfInstance::setShift )
        .def( "execute", &StaticModeInterfInstance::execute )
    ;
};
