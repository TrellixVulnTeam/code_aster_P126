/**
 * @file InputVariableDefinitionInterface.cxx
 * @brief Interface python de GenericInputVariable
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

/* person_in_charge: nicolas.sellenet at edf.fr */

#include "PythonBindings/InputVariableDefinitionInterface.h"
#include <PythonBindings/factory.h>
#include <boost/python.hpp>

namespace py = boost::python;

void exportInputVariableDefinitionToPython() {

    void ( EvolutionParameterInstance::*c1 )( const FormulaPtr & ) =
        &EvolutionParameterInstance::setTimeFunction;
    void ( EvolutionParameterInstance::*c2 )( const FunctionPtr & ) =
        &EvolutionParameterInstance::setTimeFunction;

    py::class_< EvolutionParameterInstance, EvolutionParameterPtr >( "EvolutionParameter",
                                                                     py::no_init )
        .def( "__init__",
              py::make_constructor(&initFactoryPtr< EvolutionParameterInstance,
                                                    const TimeDependantResultsContainerPtr & >))
        .def( "setFieldName", &EvolutionParameterInstance::setFieldName )
        .def( "setTimeFunction", c1 )
        .def( "setTimeFunction", c2 )
        .def( "prohibitRightExtension", &EvolutionParameterInstance::prohibitRightExtension )
        .def( "setConstantRightExtension", &EvolutionParameterInstance::setConstantRightExtension )
        .def( "setLinearRightExtension", &EvolutionParameterInstance::setLinearRightExtension )
        .def( "prohibitLeftExtension", &EvolutionParameterInstance::prohibitLeftExtension )
        .def( "setConstantLeftExtension", &EvolutionParameterInstance::setConstantLeftExtension )
        .def( "setLinearLeftExtension", &EvolutionParameterInstance::setLinearLeftExtension );

    py::class_< GenericInputVariableInstance,
                GenericInputVariableInstance::GenericInputVariablePtr >( "GenericInputVariable",
                                                                         py::no_init )
        .def( "__init__", py::make_constructor(
                              &initFactoryPtr< GenericInputVariableInstance, const BaseMeshPtr & >))
        .def( "__init__",
              py::make_constructor(&initFactoryPtr< GenericInputVariableInstance,
                                                    const BaseMeshPtr &, const std::string & >))
        .def( "existsReferenceValue", &GenericInputVariableInstance::existsReferenceValue )
        .def( "getReferenceValue", &GenericInputVariableInstance::getReferenceValue )
        .def( "setEvolutionParameter", &GenericInputVariableInstance::setEvolutionParameter )
        .def( "setInputValuesField", &GenericInputVariableInstance::setInputValuesField )
        .def( "setReferenceValue", &GenericInputVariableInstance::setReferenceValue );

    py::class_< TemperatureInputVariableInstance, TemperatureInputVariablePtr,
                py::bases< GenericInputVariableInstance > >( "TemperatureInputVariable",
                                                             py::no_init )
        .def( "__init__",
              py::make_constructor(
                  &initFactoryPtr< TemperatureInputVariableInstance, const BaseMeshPtr & >))
        .def( "__init__",
              py::make_constructor(&initFactoryPtr< TemperatureInputVariableInstance,
                                                    const BaseMeshPtr &, const std::string & >));

    py::class_< GeometryInputVariableInstance, GeometryInputVariablePtr,
                py::bases< GenericInputVariableInstance > >( "GeometryInputVariable", py::no_init )
        .def( "__init__",
              py::make_constructor(
                  &initFactoryPtr< GeometryInputVariableInstance, const BaseMeshPtr & >))
        .def( "__init__",
              py::make_constructor(&initFactoryPtr< GeometryInputVariableInstance,
                                                    const BaseMeshPtr &, const std::string & >));

    py::class_< CorrosionInputVariableInstance, CorrosionInputVariablePtr,
                py::bases< GenericInputVariableInstance > >( "CorrosionInputVariable", py::no_init )
        .def( "__init__",
              py::make_constructor(
                  &initFactoryPtr< CorrosionInputVariableInstance, const BaseMeshPtr & >))
        .def( "__init__",
              py::make_constructor(&initFactoryPtr< CorrosionInputVariableInstance,
                                                    const BaseMeshPtr &, const std::string & >));

    py::class_< IrreversibleDeformationInputVariableInstance,
                IrreversibleDeformationInputVariablePtr,
                py::bases< GenericInputVariableInstance > >( "IrreversibleDeformationInputVariable",
                                                             py::no_init )
        .def( "__init__",
              py::make_constructor(&initFactoryPtr< IrreversibleDeformationInputVariableInstance,
                                                    const BaseMeshPtr & >))
        .def( "__init__",
              py::make_constructor(&initFactoryPtr< IrreversibleDeformationInputVariableInstance,
                                                    const BaseMeshPtr &, const std::string & >));

    py::class_< ConcreteHydratationInputVariableInstance, ConcreteHydratationInputVariablePtr,
                py::bases< GenericInputVariableInstance > >( "ConcreteHydratationInputVariable",
                                                             py::no_init )
        .def( "__init__",
              py::make_constructor(
                  &initFactoryPtr< ConcreteHydratationInputVariableInstance, const BaseMeshPtr & >))
        .def( "__init__",
              py::make_constructor(&initFactoryPtr< ConcreteHydratationInputVariableInstance,
                                                    const BaseMeshPtr &, const std::string & >));

    py::class_< IrradiationInputVariableInstance, IrradiationInputVariablePtr,
                py::bases< GenericInputVariableInstance > >( "IrradiationInputVariable",
                                                             py::no_init )
        .def( "__init__",
              py::make_constructor(
                  &initFactoryPtr< IrradiationInputVariableInstance, const BaseMeshPtr & >))
        .def( "__init__",
              py::make_constructor(&initFactoryPtr< IrradiationInputVariableInstance,
                                                    const BaseMeshPtr &, const std::string & >));

    py::class_< SteelPhasesInputVariableInstance, SteelPhasesInputVariablePtr,
                py::bases< GenericInputVariableInstance > >( "SteelPhasesInputVariable",
                                                             py::no_init )
        .def( "__init__",
              py::make_constructor(
                  &initFactoryPtr< SteelPhasesInputVariableInstance, const BaseMeshPtr & >))
        .def( "__init__",
              py::make_constructor(&initFactoryPtr< SteelPhasesInputVariableInstance,
                                                    const BaseMeshPtr &, const std::string & >));

    py::class_< ZircaloyPhasesInputVariableInstance, ZircaloyPhasesInputVariablePtr,
                py::bases< GenericInputVariableInstance > >( "ZircaloyPhasesInputVariable",
                                                             py::no_init )
        .def( "__init__",
              py::make_constructor(
                  &initFactoryPtr< ZircaloyPhasesInputVariableInstance, const BaseMeshPtr & >))
        .def( "__init__",
              py::make_constructor(&initFactoryPtr< ZircaloyPhasesInputVariableInstance,
                                                    const BaseMeshPtr &, const std::string & >));

    py::class_< Neutral1InputVariableInstance, Neutral1InputVariablePtr,
                py::bases< GenericInputVariableInstance > >( "Neutral1InputVariable", py::no_init )
        .def( "__init__",
              py::make_constructor(
                  &initFactoryPtr< Neutral1InputVariableInstance, const BaseMeshPtr & >))
        .def( "__init__",
              py::make_constructor(&initFactoryPtr< Neutral1InputVariableInstance,
                                                    const BaseMeshPtr &, const std::string & >));

    py::class_< Neutral2InputVariableInstance, Neutral2InputVariablePtr,
                py::bases< GenericInputVariableInstance > >( "Neutral2InputVariable", py::no_init )
        .def( "__init__",
              py::make_constructor(
                  &initFactoryPtr< Neutral2InputVariableInstance, const BaseMeshPtr & >))
        .def( "__init__",
              py::make_constructor(&initFactoryPtr< Neutral2InputVariableInstance,
                                                    const BaseMeshPtr &, const std::string & >));

    py::class_< Neutral3InputVariableInstance, Neutral3InputVariablePtr,
                py::bases< GenericInputVariableInstance > >( "Neutral3InputVariable", py::no_init )
        .def( "__init__",
              py::make_constructor(
                  &initFactoryPtr< Neutral3InputVariableInstance, const BaseMeshPtr & >))
        .def( "__init__",
              py::make_constructor(&initFactoryPtr< Neutral3InputVariableInstance,
                                                    const BaseMeshPtr &, const std::string & >));

    py::class_< ConcreteDryingInputVariableInstance, ConcreteDryingInputVariablePtr,
                py::bases< GenericInputVariableInstance > >( "ConcreteDryingInputVariable",
                                                             py::no_init )
        .def( "__init__",
              py::make_constructor(
                  &initFactoryPtr< ConcreteDryingInputVariableInstance, const BaseMeshPtr & >))
        .def( "__init__",
              py::make_constructor(&initFactoryPtr< ConcreteDryingInputVariableInstance,
                                                    const BaseMeshPtr &, const std::string & >));

    py::class_< TotalFluidPressureInputVariableInstance, TotalFluidPressureInputVariablePtr,
                py::bases< GenericInputVariableInstance > >( "TotalFluidPressureInputVariable",
                                                             py::no_init )
        .def( "__init__",
              py::make_constructor(
                  &initFactoryPtr< TotalFluidPressureInputVariableInstance, const BaseMeshPtr & >))
        .def( "__init__",
              py::make_constructor(&initFactoryPtr< TotalFluidPressureInputVariableInstance,
                                                    const BaseMeshPtr &, const std::string & >));

    py::class_< VolumetricDeformationInputVariableInstance, VolumetricDeformationInputVariablePtr,
                py::bases< GenericInputVariableInstance > >( "VolumetricDeformationInputVariable",
                                                             py::no_init )
        .def( "__init__",
              py::make_constructor(&initFactoryPtr< VolumetricDeformationInputVariableInstance,
                                                    const BaseMeshPtr & >))
        .def( "__init__",
              py::make_constructor(&initFactoryPtr< VolumetricDeformationInputVariableInstance,
                                                    const BaseMeshPtr &, const std::string & >));

    py::class_< InputVariableOnMeshInstance, InputVariableOnMeshPtr > c3( "InputVariableOnMesh",
                                                                          py::no_init );
    c3.def( "__init__",
            py::make_constructor(&initFactoryPtr< InputVariableOnMeshInstance, const MeshPtr & >));
    c3.def( "__init__", py::make_constructor(
                            &initFactoryPtr< InputVariableOnMeshInstance, const SkeletonPtr & >));
#ifdef _USE_MPI
    c3.def( "__init__",
            py::make_constructor(
                &initFactoryPtr< InputVariableOnMeshInstance, const ParallelMeshPtr & >));
#endif /* _USE_MPI */
    c3.def(
        "addInputVariableOnAllMesh",
        &InputVariableOnMeshInstance::addInputVariableOnAllMesh< TemperatureInputVariablePtr > );
    c3.def( "addInputVariableOnGroupOfElements",
            &InputVariableOnMeshInstance::addInputVariableOnGroupOfElements<
                TemperatureInputVariablePtr > );
    c3.def(
        "addInputVariableOnElement",
        &InputVariableOnMeshInstance::addInputVariableOnElement< TemperatureInputVariablePtr > );
    c3.def( "addInputVariableOnAllMesh",
            &InputVariableOnMeshInstance::addInputVariableOnAllMesh< GeometryInputVariablePtr > );
    c3.def( "addInputVariableOnGroupOfElements",
            &InputVariableOnMeshInstance::addInputVariableOnGroupOfElements<
                GeometryInputVariablePtr > );
    c3.def( "addInputVariableOnElement",
            &InputVariableOnMeshInstance::addInputVariableOnElement< GeometryInputVariablePtr > );
    c3.def( "addInputVariableOnAllMesh",
            &InputVariableOnMeshInstance::addInputVariableOnAllMesh< CorrosionInputVariablePtr > );
    c3.def( "addInputVariableOnGroupOfElements",
            &InputVariableOnMeshInstance::addInputVariableOnGroupOfElements<
                CorrosionInputVariablePtr > );
    c3.def( "addInputVariableOnElement",
            &InputVariableOnMeshInstance::addInputVariableOnElement< CorrosionInputVariablePtr > );
    c3.def( "addInputVariableOnAllMesh", &InputVariableOnMeshInstance::addInputVariableOnAllMesh<
                                             IrreversibleDeformationInputVariablePtr > );
    c3.def( "addInputVariableOnGroupOfElements",
            &InputVariableOnMeshInstance::addInputVariableOnGroupOfElements<
                IrreversibleDeformationInputVariablePtr > );
    c3.def( "addInputVariableOnElement", &InputVariableOnMeshInstance::addInputVariableOnElement<
                                             IrreversibleDeformationInputVariablePtr > );
    c3.def( "addInputVariableOnAllMesh", &InputVariableOnMeshInstance::addInputVariableOnAllMesh<
                                             ConcreteHydratationInputVariablePtr > );
    c3.def( "addInputVariableOnGroupOfElements",
            &InputVariableOnMeshInstance::addInputVariableOnGroupOfElements<
                ConcreteHydratationInputVariablePtr > );
    c3.def( "addInputVariableOnElement", &InputVariableOnMeshInstance::addInputVariableOnElement<
                                             ConcreteHydratationInputVariablePtr > );
    c3.def(
        "addInputVariableOnAllMesh",
        &InputVariableOnMeshInstance::addInputVariableOnAllMesh< IrradiationInputVariablePtr > );
    c3.def( "addInputVariableOnGroupOfElements",
            &InputVariableOnMeshInstance::addInputVariableOnGroupOfElements<
                IrradiationInputVariablePtr > );
    c3.def(
        "addInputVariableOnElement",
        &InputVariableOnMeshInstance::addInputVariableOnElement< IrradiationInputVariablePtr > );
    c3.def(
        "addInputVariableOnAllMesh",
        &InputVariableOnMeshInstance::addInputVariableOnAllMesh< SteelPhasesInputVariablePtr > );
    c3.def( "addInputVariableOnGroupOfElements",
            &InputVariableOnMeshInstance::addInputVariableOnGroupOfElements<
                SteelPhasesInputVariablePtr > );
    c3.def(
        "addInputVariableOnElement",
        &InputVariableOnMeshInstance::addInputVariableOnElement< SteelPhasesInputVariablePtr > );
    c3.def(
        "addInputVariableOnAllMesh",
        &InputVariableOnMeshInstance::addInputVariableOnAllMesh< ZircaloyPhasesInputVariablePtr > );
    c3.def( "addInputVariableOnGroupOfElements",
            &InputVariableOnMeshInstance::addInputVariableOnGroupOfElements<
                ZircaloyPhasesInputVariablePtr > );
    c3.def(
        "addInputVariableOnElement",
        &InputVariableOnMeshInstance::addInputVariableOnElement< ZircaloyPhasesInputVariablePtr > );
    c3.def( "addInputVariableOnAllMesh",
            &InputVariableOnMeshInstance::addInputVariableOnAllMesh< Neutral1InputVariablePtr > );
    c3.def( "addInputVariableOnGroupOfElements",
            &InputVariableOnMeshInstance::addInputVariableOnGroupOfElements<
                Neutral1InputVariablePtr > );
    c3.def( "addInputVariableOnElement",
            &InputVariableOnMeshInstance::addInputVariableOnElement< Neutral1InputVariablePtr > );
    c3.def( "addInputVariableOnAllMesh",
            &InputVariableOnMeshInstance::addInputVariableOnAllMesh< Neutral2InputVariablePtr > );
    c3.def( "addInputVariableOnGroupOfElements",
            &InputVariableOnMeshInstance::addInputVariableOnGroupOfElements<
                Neutral2InputVariablePtr > );
    c3.def( "addInputVariableOnElement",
            &InputVariableOnMeshInstance::addInputVariableOnElement< Neutral2InputVariablePtr > );
    c3.def( "addInputVariableOnAllMesh",
            &InputVariableOnMeshInstance::addInputVariableOnAllMesh< Neutral3InputVariablePtr > );
    c3.def( "addInputVariableOnGroupOfElements",
            &InputVariableOnMeshInstance::addInputVariableOnGroupOfElements<
                Neutral3InputVariablePtr > );
    c3.def( "addInputVariableOnElement",
            &InputVariableOnMeshInstance::addInputVariableOnElement< Neutral3InputVariablePtr > );
    c3.def(
        "addInputVariableOnAllMesh",
        &InputVariableOnMeshInstance::addInputVariableOnAllMesh< ConcreteDryingInputVariablePtr > );
    c3.def( "addInputVariableOnGroupOfElements",
            &InputVariableOnMeshInstance::addInputVariableOnGroupOfElements<
                ConcreteDryingInputVariablePtr > );
    c3.def(
        "addInputVariableOnElement",
        &InputVariableOnMeshInstance::addInputVariableOnElement< ConcreteDryingInputVariablePtr > );
    c3.def( "addInputVariableOnAllMesh", &InputVariableOnMeshInstance::addInputVariableOnAllMesh<
                                             TotalFluidPressureInputVariablePtr > );
    c3.def( "addInputVariableOnGroupOfElements",
            &InputVariableOnMeshInstance::addInputVariableOnGroupOfElements<
                TotalFluidPressureInputVariablePtr > );
    c3.def( "addInputVariableOnElement", &InputVariableOnMeshInstance::addInputVariableOnElement<
                                             TotalFluidPressureInputVariablePtr > );
    c3.def( "addInputVariableOnAllMesh", &InputVariableOnMeshInstance::addInputVariableOnAllMesh<
                                             VolumetricDeformationInputVariablePtr > );
    c3.def( "addInputVariableOnGroupOfElements",
            &InputVariableOnMeshInstance::addInputVariableOnGroupOfElements<
                VolumetricDeformationInputVariablePtr > );
    c3.def( "addInputVariableOnElement", &InputVariableOnMeshInstance::addInputVariableOnElement<
                                             VolumetricDeformationInputVariablePtr > );
};
