/**
 * @file Mesh.cxx
 * @brief Implementation de MeshInstance
 * @author Nicolas Sellenet
 * @section LICENCE
 *   Copyright (C) 1991 - 2014  EDF R&D                www.code-aster.org
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

#include "astercxx.h"

// emulate_LIRE_MAILLAGE_MED.h is auto-generated and requires Mesh.h and Python.h
#include "Python.h"
#include "Meshes/Mesh.h"
#include "Utilities/CapyConvertibleValue.h"
#include "RunManager/CommandSyntaxCython.h"
#include "RunManager/LogicalUnitManagerCython.h"

MeshInstance::MeshInstance(): DataStructure( getNewResultObjectName(), "MAILLAGE" ),
                        _jeveuxName( getName() ),
                        _dimensionInformations( JeveuxVectorLong( _jeveuxName + ".DIME      " ) ),
                        _nameOfNodes( JeveuxBidirectionalMap( _jeveuxName + ".NOMNOE    " ) ),
                        _coordinates( FieldOnNodesDoublePtr(
                            new FieldOnNodesDoubleInstance( _jeveuxName + ".COORDO    " ) ) ),
                        _groupsOfNodes( JeveuxCollectionLong( _jeveuxName + ".GROUPENO  " ) ),
                        _connectivity( JeveuxCollectionLong( _jeveuxName + ".CONNEX    " ) ),
                        _nameOfElements( JeveuxBidirectionalMap( _jeveuxName + ".NOMMAI    " ) ),
                        _elementsType( JeveuxVectorLong( _jeveuxName + ".TYPMAIL   " ) ),
                        _groupsOfElements( JeveuxCollectionLong( _jeveuxName + ".GROUPEMA  " ) ),
                        _isEmpty( true )
{
    assert(_jeveuxName.size() == 8);
};

bool MeshInstance::addGroupOfNodesFromNodes( const std::string& name, const VectorString& vec )
    throw( std::runtime_error )
{
    CommandSyntaxCython cmdSt( "DEFI_GROUP" );
    cmdSt.setResult( getResultObjectName(), "MAILLAGE" );

    CapyConvertibleContainer toCapyConverter;
    toCapyConverter.add( new CapyConvertibleValue< std::string >
                                ( false, "MAILLAGE", getName(), true ) );

    CapyConvertibleContainer toCapyConverter2( "CREA_GROUP_NO" );
    toCapyConverter2.add( new CapyConvertibleValue< VectorString >
                                ( false, "NOEUD", vec, true ) );
    toCapyConverter2.add( new CapyConvertibleValue< std::string >
                                ( false, "NOM", name, true ) );

    CapyConvertibleSyntax syntax;
    syntax.setSimpleKeywordValues( toCapyConverter );
    syntax.addCapyConvertibleContainer( toCapyConverter2 );

    cmdSt.define( syntax );
    try
    {
        ASTERINTEGER op = 104;
        CALL_EXECOP( &op );
    }
    catch( ... )
    {
        throw;
    }
    return true;
};

bool MeshInstance::build()
{
    // Attention, la connection des objets a leur image JEVEUX n'est pas necessaire
    _dimensionInformations->updateValuePointer();
    _coordinates->updateValuePointers();
    _groupsOfNodes->buildFromJeveux();
    _connectivity->buildFromJeveux();
    _elementsType->updateValuePointer();
    _groupsOfElements->buildFromJeveux();
    _isEmpty = false;

    return true;
};

bool MeshInstance::readMeshFile( const std::string& fileName, const std::string& format )
    throw ( std::runtime_error )
{
    LogicalUnitFileCython file1( fileName, Binary, Old );
    // Fichier temporaire
    LogicalUnitFileCython file2( fileName, Binary, Old );

    ASTERINTEGER op = 0;
    if( format == "GIBI" || format == "GMSH" )
    {
        throw;
        std::string preCmd = "PRE_" + format;
        ASTERINTEGER op = 47;
        if( format == "GIBI" ) op = 49;

        CommandSyntaxCython cmdSt2( preCmd );
        SyntaxMapContainer syntax2;
        syntax2.container[ "UNITE_" + format ] = file1.getLogicalUnit();
        syntax2.container[ "UNITE_MAILLAGE" ] = file2.getLogicalUnit();
        cmdSt2.define( syntax2 );

        try
        {
            CALL_EXECOP( &op );
        }
        catch( ... )
        {
            throw;
        }
    }

    CommandSyntaxCython cmdSt( "LIRE_MAILLAGE" );
    cmdSt.setResult( getResultObjectName(), "MAILLAGE" );

    SyntaxMapContainer syntax;
    syntax.container[ "FORMAT" ] = format;
    syntax.container[ "UNITE" ] = file2.getLogicalUnit();

    cmdSt.define( syntax );

    try
    {
        ASTERINTEGER op = 1;
        CALL_EXECOP( &op );
    }
    catch( ... )
    {
        throw;
    }

    build();

    return true;
};

bool MeshInstance::readAsterMeshFile( const std::string& fileName )
    throw ( std::runtime_error )
{
    readMeshFile( fileName, "ASTER" );

    return true;
};

bool MeshInstance::readMedFile( const std::string& fileName )
    throw ( std::runtime_error )
{
    readMeshFile( fileName, "MED" );

    return true;
};
