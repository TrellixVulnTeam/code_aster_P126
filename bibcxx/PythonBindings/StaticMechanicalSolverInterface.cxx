/**
 * @file StaticMechanicalSolverInterface.cxx
 * @brief Interface python de StaticMechanicalSolver
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

#include "PythonBindings/StaticMechanicalSolverInterface.h"
#include "PythonBindings/LoadInterface.h"
#include "PythonBindings/factory.h"
#include <boost/python.hpp>

void exportStaticMechanicalSolverToPython()
{
    using namespace boost::python;

    class_< StaticMechanicalSolverInstance, StaticMechanicalSolverPtr >
        c1( "StaticMechanicalSolver", no_init );
    c1.def( "__init__", make_constructor(
            &initFactoryPtr< StaticMechanicalSolverInstance,
                             ModelPtr, MaterialOnMeshPtr > ) );
    addKinematicsLoadToInterface( c1 );
    addMechanicalLoadToInterface( c1 );
#ifdef _USE_MPI
    c1.def( "addParallelMechanicalLoad", &StaticMechanicalSolverInstance::addParallelMechanicalLoad );
#endif /* _USE_MPI */
    c1.def( "execute", &StaticMechanicalSolverInstance::execute );
    c1.def( "setLinearSolver", &StaticMechanicalSolverInstance::setLinearSolver );
};
