/**
 * @file GenericInputVariableInterface.cxx
 * @brief Interface python de GenericInputVariable
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
#include "PythonBindings/InputVariableDefinitionInterface.h"


void exportInputVariableDefinitionToPython()
{
    using namespace boost::python;

    class_< GenericInputVariableInstance, GenericInputVariableInstance::GenericInputVariablePtr >
        ( "GenericInputVariable", no_init )
        .def( "__init__", make_constructor(
            &initFactoryPtr< GenericInputVariableInstance, const BaseMeshPtr& > ) )
        .def( "__init__", make_constructor(
            &initFactoryPtr< GenericInputVariableInstance, const BaseMeshPtr&,
                             const std::string& > ) )
        .def( "existsReferenceValue", &GenericInputVariableInstance::existsReferenceValue )
        .def( "getReferenceValue", &GenericInputVariableInstance::getReferenceValue )
        .def( "setInputValuesField", &GenericInputVariableInstance::setInputValuesField )
        .def( "setReferenceValue", &GenericInputVariableInstance::setReferenceValue )
    ;

    class_< TemperatureInputVariableInstance, TemperatureInputVariablePtr,
            bases< GenericInputVariableInstance > >
        ( "TemperatureInputVariable", no_init )
        .def( "__init__", make_constructor(
            &initFactoryPtr< TemperatureInputVariableInstance, const BaseMeshPtr& > ) )
        .def( "__init__", make_constructor(
            &initFactoryPtr< TemperatureInputVariableInstance, const BaseMeshPtr&,
                             const std::string& > ) )
    ;

    class_< GeometryInputVariableInstance, GeometryInputVariablePtr,
            bases< GenericInputVariableInstance > >
        ( "GeometryInputVariable", no_init )
        .def( "__init__", make_constructor(
            &initFactoryPtr< GeometryInputVariableInstance, const BaseMeshPtr& > ) )
        .def( "__init__", make_constructor(
            &initFactoryPtr< GeometryInputVariableInstance, const BaseMeshPtr&,
                             const std::string& > ) )
    ;

    class_< CorrosionInputVariableInstance, CorrosionInputVariablePtr,
            bases< GenericInputVariableInstance > >
        ( "CorrosionInputVariable", no_init )
        .def( "__init__", make_constructor(
            &initFactoryPtr< CorrosionInputVariableInstance, const BaseMeshPtr& > ) )
        .def( "__init__", make_constructor(
            &initFactoryPtr< CorrosionInputVariableInstance, const BaseMeshPtr&,
                             const std::string& > ) )
    ;

    class_< IrreversibleDeformationInputVariableInstance, IrreversibleDeformationInputVariablePtr,
            bases< GenericInputVariableInstance > >
        ( "IrreversibleDeformationInputVariable", no_init )
        .def( "__init__", make_constructor(
            &initFactoryPtr< IrreversibleDeformationInputVariableInstance, const BaseMeshPtr& > ) )
        .def( "__init__", make_constructor(
            &initFactoryPtr< IrreversibleDeformationInputVariableInstance, const BaseMeshPtr&,
                             const std::string& > ) )
    ;

    class_< ConcreteHydratationInputVariableInstance, ConcreteHydratationInputVariablePtr,
            bases< GenericInputVariableInstance > >
        ( "ConcreteHydratationInputVariable", no_init )
        .def( "__init__", make_constructor(
            &initFactoryPtr< ConcreteHydratationInputVariableInstance, const BaseMeshPtr& > ) )
        .def( "__init__", make_constructor(
            &initFactoryPtr< ConcreteHydratationInputVariableInstance, const BaseMeshPtr&,
                             const std::string& > ) )
    ;

    class_< IrradiationInputVariableInstance, IrradiationInputVariablePtr,
            bases< GenericInputVariableInstance > >
        ( "IrradiationInputVariable", no_init )
        .def( "__init__", make_constructor(
            &initFactoryPtr< IrradiationInputVariableInstance, const BaseMeshPtr& > ) )
        .def( "__init__", make_constructor(
            &initFactoryPtr< IrradiationInputVariableInstance, const BaseMeshPtr&,
                             const std::string& > ) )
    ;

    class_< SteelPhasesInputVariableInstance, SteelPhasesInputVariablePtr,
            bases< GenericInputVariableInstance > >
        ( "SteelPhasesInputVariable", no_init )
        .def( "__init__", make_constructor(
            &initFactoryPtr< SteelPhasesInputVariableInstance, const BaseMeshPtr& > ) )
        .def( "__init__", make_constructor(
            &initFactoryPtr< SteelPhasesInputVariableInstance, const BaseMeshPtr&,
                             const std::string& > ) )
    ;

    class_< ZircaloyPhasesInputVariableInstance, ZircaloyPhasesInputVariablePtr,
            bases< GenericInputVariableInstance > >
        ( "ZircaloyPhasesInputVariable", no_init )
        .def( "__init__", make_constructor(
            &initFactoryPtr< ZircaloyPhasesInputVariableInstance, const BaseMeshPtr& > ) )
        .def( "__init__", make_constructor(
            &initFactoryPtr< ZircaloyPhasesInputVariableInstance, const BaseMeshPtr&,
                             const std::string& > ) )
    ;

    class_< Neutral1InputVariableInstance, Neutral1InputVariablePtr,
            bases< GenericInputVariableInstance > >
        ( "Neutral1InputVariable", no_init )
        .def( "__init__", make_constructor(
            &initFactoryPtr< Neutral1InputVariableInstance, const BaseMeshPtr& > ) )
        .def( "__init__", make_constructor(
            &initFactoryPtr< Neutral1InputVariableInstance, const BaseMeshPtr&,
                             const std::string& > ) )
    ;

    class_< Neutral2InputVariableInstance, Neutral2InputVariablePtr,
            bases< GenericInputVariableInstance > >
        ( "Neutral2InputVariable", no_init )
        .def( "__init__", make_constructor(
            &initFactoryPtr< Neutral2InputVariableInstance, const BaseMeshPtr& > ) )
        .def( "__init__", make_constructor(
            &initFactoryPtr< Neutral2InputVariableInstance, const BaseMeshPtr&,
                             const std::string& > ) )
    ;

    class_< ConcreteDryingInputVariableInstance, ConcreteDryingInputVariablePtr,
            bases< GenericInputVariableInstance > >
        ( "ConcreteDryingInputVariable", no_init )
        .def( "__init__", make_constructor(
            &initFactoryPtr< ConcreteDryingInputVariableInstance, const BaseMeshPtr& > ) )
        .def( "__init__", make_constructor(
            &initFactoryPtr< ConcreteDryingInputVariableInstance, const BaseMeshPtr&,
                             const std::string& > ) )
    ;

    class_< TotalFluidPressureInputVariableInstance, TotalFluidPressureInputVariablePtr,
            bases< GenericInputVariableInstance > >
        ( "TotalFluidPressureInputVariable", no_init )
        .def( "__init__", make_constructor(
            &initFactoryPtr< TotalFluidPressureInputVariableInstance, const BaseMeshPtr& > ) )
        .def( "__init__", make_constructor(
            &initFactoryPtr< TotalFluidPressureInputVariableInstance, const BaseMeshPtr&,
                             const std::string& > ) )
    ;

    class_< VolumetricDeformationInputVariableInstance, VolumetricDeformationInputVariablePtr,
            bases< GenericInputVariableInstance > >
        ( "VolumetricDeformationInputVariable", no_init )
        .def( "__init__", make_constructor(
            &initFactoryPtr< VolumetricDeformationInputVariableInstance, const BaseMeshPtr& > ) )
        .def( "__init__", make_constructor(
            &initFactoryPtr< VolumetricDeformationInputVariableInstance, const BaseMeshPtr&,
                             const std::string& > ) )
    ;
};
