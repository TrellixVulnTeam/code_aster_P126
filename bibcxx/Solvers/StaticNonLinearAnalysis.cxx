/**
 * @file StaticNonLinearAnalysis.cxx
 * @brief Fichier source contenant le source du solveur de mecanique statique
 * @author Natacha Béreux
 * @section LICENCE
 *   Copyright (C) 1991 - 2020  EDF R&D                www.code-aster.org
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

/* person_in_charge: natacha.bereux at edf.fr */

#include <stdexcept>

#include "Algorithms/GenericAlgorithm.h"
#include "Solvers/StaticNonLinearAnalysis.h"
#include "Discretization/DiscreteProblem.h"
#include "Supervis/CommandSyntax.h"

StaticNonLinearAnalysisClass::StaticNonLinearAnalysisClass()
    : _model( ModelPtr() ), _materialOnMesh( MaterialOnMeshPtr() ),
      _loadStepManager( TimeStepManagerPtr() ),
      _nonLinearMethod( NonLinearMethodPtr( new NonLinearMethodClass() ) ),
      _control( NonLinearControlPtr( new NonLinearControlClass() ) ),
      _linearSolver( BaseLinearSolverPtr( new BaseLinearSolverClass() ) ),
      _lineSearch( LineSearchMethodPtr() ){};

/** @brief main routine to run a static, nonlinear analysis
 */
NonLinearEvolutionContainerPtr
StaticNonLinearAnalysisClass::execute() {
    // cmdSNL is the command Syntax object associated to Code_Aster STAT_NON_LINE command
    CommandSyntax cmdSNL( "STAT_NON_LINE" );
    // Init name of result
    NonLinearEvolutionContainerPtr resultSNL( new NonLinearEvolutionContainerClass() );
    cmdSNL.setResult( resultSNL->getName(), "STAT_NON_LINE" );
    // Build a dictionnary of keywords/values used to define the command syntax object
    SyntaxMapContainer dict;

    if ( !_model )
        throw std::runtime_error( "Model is undefined" );
    dict.container["MODELE"] = _model->getName();

    if ( !_materialOnMesh )
        throw std::runtime_error( "MaterialOnMesh is undefined" );
    dict.container["CHAM_MATER"] = _materialOnMesh->getName();

    if ( _listOfExcitations.size() == 0 )
        throw std::runtime_error( "Excitation is undefined" );

    CapyConvertibleFactorKeyword excitFKW( "EXCIT" );
    CapyConvertibleSyntax syntax;
    for ( ListExcitationCIter curIter = _listOfExcitations.begin();
          curIter != _listOfExcitations.end(); ++curIter ) {
        CapyConvertibleContainer toAdd = ( *curIter )->getCapyConvertibleContainer();
        excitFKW.addContainer( toAdd );
    }
    syntax.addFactorKeywordValues( excitFKW );
    SyntaxMapContainer test = syntax.toSyntaxMapContainer();
    // On ajoute le SyntaxMapContainer résultant du parcours de la liste des
    // excitations au SyntaxMapContainer qui servira à définir le CommandSyntax
    dict += test;

    ListSyntaxMapContainer listIncr;
    SyntaxMapContainer dictIncr;
    dictIncr.container["LIST_INST"] = _loadStepManager->getName();
    listIncr.push_back( dictIncr );
    dict.container["INCREMENT"] = listIncr;

    ListSyntaxMapContainer listMethod;
    const ListGenParam &listParamMethod = _nonLinearMethod->getListOfMethodParameters();
    SyntaxMapContainer dictMethod = buildSyntaxMapFromParamList( listParamMethod );
    dict += dictMethod;

    ListSyntaxMapContainer listNewton;
    const ListGenParam &listParamNewton = _nonLinearMethod->getListOfNewtonParameters();
    SyntaxMapContainer dictNewton = buildSyntaxMapFromParamList( listParamNewton );
    listNewton.push_back( dictNewton );
    dict.container["NEWTON"] = listNewton;

    CapyConvertibleFactorKeyword behaviourFKW( "COMPORTEMENT" );
    CapyConvertibleSyntax behaviourSyntax;
    if ( _listOfBehaviours.size() != 0 ) {
        for ( ListLocatedBehaviourCIter curIter = _listOfBehaviours.begin();
              curIter != _listOfBehaviours.end(); ++curIter ) {
            CapyConvertibleContainer toAdd = ( *curIter )->getCapyConvertibleContainer();
            behaviourFKW.addContainer( toAdd );
        }
    }

    behaviourSyntax.addFactorKeywordValues( behaviourFKW );
    SyntaxMapContainer behaviourTest = behaviourSyntax.toSyntaxMapContainer();
    // On ajoute le SyntaxMapContainer résultant du parcours de la liste des
    // comportements au SyntaxMapContainer qui servira à définir le CommandSyntax
    dict += behaviourTest;

    if ( _linearSolver != NULL )
        dict.container["SOLVEUR"] = _linearSolver->buildListSyntax();

    if ( _lineSearch != NULL ) {
        ListSyntaxMapContainer listLineSearch;
        const ListGenParam &listParamLineSearch = _lineSearch->getListOfParameters();
        SyntaxMapContainer dictLineSearch = buildSyntaxMapFromParamList( listParamLineSearch );
        listLineSearch.push_back( dictLineSearch );
        dict.container["RECH_LINEAIRE"] = listLineSearch;
    }
    if ( _initialState != NULL ) {
        ListSyntaxMapContainer listInitialState;
        const ListGenParam &listParamInitialState = _initialState->getListOfParameters();
        SyntaxMapContainer dictInitialState = buildSyntaxMapFromParamList( listParamInitialState );
        listInitialState.push_back( dictInitialState );
        dict.container["ETAT_INIT"] = listInitialState;
    }
    // Build Command Syntax object
    cmdSNL.define( dict );

    //  Now Command syntax is ready, call op00070
    try {
        ASTERINTEGER op = 70;
        CALL_EXECOP( &op );
    } catch ( ... ) {
        throw;
    }
    // Return result
    //    resultSNL->debugPrint(6);
    resultSNL->appendModelOnAllRanks( _model );
    resultSNL->update();
    return resultSNL;
};

/** @brief Implementation of the member functions to add an excitation (source term)
 */
void StaticNonLinearAnalysisClass::addMechanicalExcitation(
    const GenericMechanicalLoadPtr &currentLoad, ExcitationEnum typeOfExcit,
    const FunctionPtr &scalF ) {
    ExcitationPtr curExcit( new ExcitationClass( typeOfExcit ) );
    curExcit->setMechanicalLoad( currentLoad );
    if ( scalF )
        curExcit->setMultiplicativeFunction( scalF );
    _listOfExcitations.push_back( curExcit );
};

void StaticNonLinearAnalysisClass::addKinematicExcitation( const KinematicsLoadPtr &currentLoad,
                                                              ExcitationEnum typeOfExcit,
                                                              const FunctionPtr &scalF ) {
    ExcitationClass *curExcit( new ExcitationClass( typeOfExcit ) );
    curExcit->setKinematicLoad( currentLoad );
    if ( scalF )
        curExcit->setMultiplicativeFunction( scalF );
    _listOfExcitations.push_back( ExcitationPtr( curExcit ) );
};

void StaticNonLinearAnalysisClass::addStandardExcitation(
    const GenericMechanicalLoadPtr &currentLoad ) {
    addMechanicalExcitation( currentLoad, StandardExcitation, nullptr );
};
void StaticNonLinearAnalysisClass::addStandardScaledExcitation(
    const GenericMechanicalLoadPtr &currentLoad, const FunctionPtr &scalF ) {
    addMechanicalExcitation( currentLoad, StandardExcitation, scalF );
};
void
StaticNonLinearAnalysisClass::addStandardExcitation( const KinematicsLoadPtr &currentLoad ) {
    addKinematicExcitation( currentLoad, StandardExcitation, nullptr );
};
void
StaticNonLinearAnalysisClass::addStandardScaledExcitation( const KinematicsLoadPtr &currentLoad,
                                                              const FunctionPtr &scalF ) {
    addKinematicExcitation( currentLoad, StandardExcitation, scalF );
};
void StaticNonLinearAnalysisClass::addDrivenExcitation(
    const GenericMechanicalLoadPtr &currentLoad ) {
    addMechanicalExcitation( currentLoad, DrivenExcitation, nullptr );
};
void StaticNonLinearAnalysisClass::addExcitationOnUpdatedGeometry(
    const GenericMechanicalLoadPtr &currentLoad ) {
    addMechanicalExcitation( currentLoad, OnUpdatedGeometryExcitation, nullptr );
};
void StaticNonLinearAnalysisClass::addScaledExcitationOnUpdatedGeometry(
    const GenericMechanicalLoadPtr &currentLoad, const FunctionPtr &scalF ) {
    addMechanicalExcitation( currentLoad, OnUpdatedGeometryExcitation, scalF );
};
void StaticNonLinearAnalysisClass::addIncrementalDirichletExcitation(
    const GenericMechanicalLoadPtr &currentLoad ) {
    addMechanicalExcitation( currentLoad, IncrementalDirichletExcitation, nullptr );
};
void StaticNonLinearAnalysisClass::addIncrementalDirichletScaledExcitation(
    const GenericMechanicalLoadPtr &currentLoad, const FunctionPtr &scalF ) {
    addMechanicalExcitation( currentLoad, IncrementalDirichletExcitation, scalF );
};
