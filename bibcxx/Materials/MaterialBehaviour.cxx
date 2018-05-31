/**
 * @file MaterialBehaviour.cxx
 * @brief Implementation de GeneralMaterialBehaviourInstance
 * @author Nicolas Sellenet
 * @todo autoriser le type Function pour les paramètres matériau 
 * @section LICENCE
 *   Copyright (C) 1991 - 2018  EDF R&D                www.code-aster.org
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

#include <stdexcept>
#include "Materials/MaterialBehaviour.h"

bool GeneralMaterialBehaviourInstance::buildJeveuxVectors( JeveuxVectorComplex& complexValues,
                                                           JeveuxVectorDouble& doubleValues,
                                                           JeveuxVectorChar16& char16Values,
                                                           JeveuxVectorChar16& ordr,
                                                           JeveuxVectorDouble& userDoubles,
                                                           JeveuxVectorChar8& userFunctions ) const
    throw( std::runtime_error )
{
    if( _vectOrdr.size() != 0 )
    {
        ordr->allocate( Permanent, _vectOrdr.size() );
        for( int i = 0; i < _vectOrdr.size(); ++i )
            (*ordr)[i] = _vectOrdr[i];
    }
    const int nbOfMaterialProperties = getNumberOfPropertiesWithValue();
    complexValues->allocate( Permanent, nbOfMaterialProperties );
    doubleValues->allocate( Permanent, nbOfMaterialProperties );
    char16Values->allocate( Permanent, 2*nbOfMaterialProperties );

    int position = 0, position2 = nbOfMaterialProperties, pos3 = 0;
    for( auto curIter : _mapOfDoubleMaterialProperties ){
        std::string nameOfProperty = curIter.second.getName();
        if( curIter.second.hasValue() )
        {
            nameOfProperty.resize( 16, ' ' );
            (*char16Values)[position] = nameOfProperty.c_str();
            (*doubleValues)[position] = curIter.second.getValue();
            ++position;
        }

        if( curIter.second.isMandatory() && ! curIter.second.hasValue() )
            throw std::runtime_error( "Mandatory material property " + nameOfProperty + " is missing" );

    }
    for( auto curIter : _mapOfConvertibleMaterialProperties ){
        std::string nameOfProperty = curIter.second.getName();
        if( curIter.second.hasValue() )
        {
            nameOfProperty.resize( 16, ' ' );
            (*char16Values)[position] = nameOfProperty.c_str();
            (*doubleValues)[position] = curIter.second.getValue();
            ++position;
        }

        if( curIter.second.isMandatory() && ! curIter.second.hasValue() )
            throw std::runtime_error( "Mandatory material property " + nameOfProperty + " is missing" );

    }
    doubleValues->setUsedSize(position);

    for( auto curIter : _mapOfComplexMaterialProperties ){
        std::string nameOfProperty = curIter.second.getName();
        if( curIter.second.hasValue() )
        {
            nameOfProperty.resize( 16, ' ' );
            (*char16Values)[position] = nameOfProperty.c_str();
            (*complexValues)[position] = curIter.second.getValue();
            ++position;
            ++pos3;
        }

        if( curIter.second.isMandatory() && ! curIter.second.hasValue() )
            throw std::runtime_error( "Mandatory material property " + nameOfProperty + " is missing" );

    }
    if( pos3 != 0 )
        complexValues->setUsedSize(position);
    else
        complexValues->setUsedSize(pos3);

    for( auto curIter : _mapOfTableMaterialProperties ){
        std::string nameOfProperty = curIter.second.getName();
        if( curIter.second.hasValue() )
        {
            nameOfProperty.resize( 16, ' ' );
            (*char16Values)[position] = nameOfProperty.c_str();
            (*char16Values)[position2] = curIter.second.getValue()->getName();
            ++position;
            ++position2;
        }

        if( curIter.second.isMandatory() && ! curIter.second.hasValue() )
            throw std::runtime_error( "Mandatory material property " + nameOfProperty + " is missing" );
    }

    for( auto curIter : _mapOfFunctionMaterialProperties ){
        std::string nameOfProperty = curIter.second.getName();
        if( curIter.second.hasValue() )
        {
            nameOfProperty.resize( 16, ' ' );
            (*char16Values)[position] = nameOfProperty.c_str();
            (*char16Values)[position2] = curIter.second.getValue()->getName();
            ++position;
            ++position2;
        }

        if( curIter.second.isMandatory() && ! curIter.second.hasValue() )
            throw std::runtime_error( "Mandatory material property " + nameOfProperty + " is missing" );
    }

    if( _mapOfVectorDoubleMaterialProperties.size() > 1 )
        throw std::runtime_error( "Unconsistent size" );
    for( auto curIter : _mapOfVectorDoubleMaterialProperties ){
        std::string nameOfProperty = curIter.second.getName();
        if( curIter.second.hasValue() )
        {
            nameOfProperty.resize( 16, ' ' );
            (*char16Values)[position] = nameOfProperty.c_str();
            (*char16Values)[position2] = userDoubles->getName();

            auto values = curIter.second.getValue();
            userDoubles->allocate( Permanent, values.size() );
            (*userDoubles) = values;
            ++position;
            ++position2;
        }

        if( curIter.second.isMandatory() && ! curIter.second.hasValue() )
            throw std::runtime_error( "Mandatory material property " + nameOfProperty + " is missing" );
    }

    if( _mapOfVectorFunctionMaterialProperties.size() > 1 )
        throw std::runtime_error( "Unconsistent size" );
    for( auto curIter : _mapOfVectorFunctionMaterialProperties ){
        std::string nameOfProperty = curIter.second.getName();
        if( curIter.second.hasValue() )
        {
            nameOfProperty.resize( 16, ' ' );
            (*char16Values)[position] = nameOfProperty.c_str();
            (*char16Values)[position2] = userFunctions->getName();

            auto values = curIter.second.getValue();
            userFunctions->allocate( Permanent, values.size() );
            for( int i = 0; i < values.size(); ++i )
                (*userFunctions)[i] = values[i]->getName();
            ++position;
            ++position2;
        }

        if( curIter.second.isMandatory() && ! curIter.second.hasValue() )
            throw std::runtime_error( "Mandatory material property " + nameOfProperty + " is missing" );
    }
    char16Values->setUsedSize( position2 );

    return true;
};

bool GeneralMaterialBehaviourInstance::buildTractionFunction
    ( FunctionPtr& doubleValues ) const
    throw( std::runtime_error )
{
    return true;
};

bool TractionMaterialBehaviourInstance::buildTractionFunction
    ( FunctionPtr& doubleValues ) const
    throw( std::runtime_error )
{
    long maxSize = 0, maxSize2 = 0;
    std::string resName;
    for( auto curIter : _mapOfFunctionMaterialProperties )
    {
        std::string nameOfProperty = curIter.second.getName();
        if( curIter.second.hasValue() )
        {
            const auto func = curIter.second.getValue();
            CALLO_RCSTOC_VERIF( func->getName(), nameOfProperty,
                                _asterName, &maxSize2 );
            const auto size = func->maximumSize();
            if( size > maxSize )
                maxSize = size;
            resName = curIter.second.getValue()->getResultName();
        }
    }
    doubleValues->allocate( Permanent, maxSize );
    doubleValues->setParameterName( "EPSI" );
    doubleValues->setResultName( resName );
    return true;
};

bool MetaTractionMaterialBehaviourInstance::buildTractionFunction
    ( FunctionPtr& doubleValues ) const
    throw( std::runtime_error )
{
    long maxSize = 0, maxSize2 = 0;
    std::string resName;
    for( auto curIter : _mapOfFunctionMaterialProperties )
    {
        std::string nameOfProperty = curIter.second.getName();
        if( curIter.second.hasValue() )
        {
            const auto func = curIter.second.getValue();
            CALLO_RCSTOC_VERIF( func->getName(), nameOfProperty,
                                _asterName, &maxSize2 );
            const auto size = func->maximumSize();
            if( size > maxSize )
                maxSize = size;
            resName = curIter.second.getValue()->getResultName();
        }
    }
    doubleValues->allocate( Permanent, maxSize );
    doubleValues->setParameterName( "EPSI" );
    doubleValues->setResultName( resName );
    return true;
};

int GeneralMaterialBehaviourInstance::getNumberOfPropertiesWithValue() const
{
    int toReturn = 0;
    for( auto curIter : _mapOfDoubleMaterialProperties )
        if( curIter.second.hasValue() )
            ++toReturn;

    for( auto curIter : _mapOfComplexMaterialProperties )
        if( curIter.second.hasValue() )
            ++toReturn;

    for( auto curIter : _mapOfStringMaterialProperties )
        if( curIter.second.hasValue() )
            ++toReturn;

    for( auto curIter : _mapOfTableMaterialProperties )
        if( curIter.second.hasValue() )
            ++toReturn;

    for( auto curIter : _mapOfFunctionMaterialProperties )
        if( curIter.second.hasValue() )
            ++toReturn;

    for( auto curIter : _mapOfVectorDoubleMaterialProperties )
        if( curIter.second.hasValue() )
            ++toReturn;

    for( auto curIter : _mapOfVectorFunctionMaterialProperties )
        if( curIter.second.hasValue() )
            ++toReturn;

    for( auto curIter : _mapOfConvertibleMaterialProperties )
        if( curIter.second.hasValue() )
            ++toReturn;

    return toReturn;
};
