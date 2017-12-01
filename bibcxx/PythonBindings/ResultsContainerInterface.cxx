/**
 * @file ResultsContainerInterface.cxx
 * @brief Interface python de ResultsContainer
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

#include "PythonBindings/ResultsContainerInterface.h"
#include "PythonBindings/factory.h"
#include <boost/python.hpp>

void exportResultsContainerToPython()
{
    using namespace boost::python;

    class_< ResultsContainerInstance, ResultsContainerInstance::ResultsContainerPtr,
            bases< DataStructure > > ( "ResultsContainer", no_init )
        .def( "__init__", make_constructor(
            &initFactoryPtr< ResultsContainerInstance,
                             std::string > ) )
        .def( "__init__", make_constructor(
            &initFactoryPtr< ResultsContainerInstance,
                             std::string, std::string > ) )
        .def( "getRealFieldOnNodes", &ResultsContainerInstance::getRealFieldOnNodes )
        .def( "getRealFieldOnElements", &ResultsContainerInstance::getRealFieldOnElements )
        .def( "printMedFile", &ResultsContainerInstance::printMedFile )
        .def( "listFields", &ResultsContainerInstance::listFields )
        .def( "update", &ResultsContainerInstance::update )
        .def( "setModel", &ResultsContainerInstance::setModel )
        .def( "getModel", &ResultsContainerInstance::getModel )
    ;
};
