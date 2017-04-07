/**
 * @file TimeStepperInterface.cxx
 * @brief Interface python de TimeStepper
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

#include "PythonInterfaces/TimeStepperInterface.h"
#include "PythonInterfaces/DataStructureInterface.h"
#include "PythonInterfaces/VectorUtilities.h"
#include <boost/python.hpp>

void exportTimeStepperToPython()
{
    using namespace boost::python;

    exportVectorUtilities< double >();

    class_< TimeStepperInstance, TimeStepperInstance::TimeStepperPtr,
            bases< DataStructure > >( "TimeStepper", no_init )
        .def( "create", &TimeStepperInstance::create )
        .def( "setValues", &TimeStepperInstance::setValues )
    ;
};
