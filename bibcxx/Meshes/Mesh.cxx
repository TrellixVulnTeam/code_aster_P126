/**
 * @file Mesh.cxx
 * @brief Implementation de BaseMeshInstance
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

#include "astercxx.h"

// emulate_LIRE_MAILLAGE_MED.h is auto-generated and requires Mesh.h and Python.h
#include "Python.h"
#include "Meshes/Mesh.h"
#include "Utilities/CapyConvertibleValue.h"
#include "Supervis/CommandSyntax.h"
#include "Supervis/ResultNaming.h"
#include "RunManager/LogicalUnitManagerCython.h"

bool MeshInstance::addGroupOfNodesFromNodes( const std::string& name, const VectorString& vec )
    throw( std::runtime_error )
{
    CommandSyntax cmdSt( "DEFI_GROUP" );
    cmdSt.setResult( ResultNaming::getCurrentName(), "MAILLAGE" );

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

bool BaseMeshInstance::readMeshFile( const std::string& fileName, const std::string& format )
    throw ( std::runtime_error )
{
    FileTypeCython type = Ascii;
    if( format == "MED" ) type = Binary;
    LogicalUnitFileCython file1( fileName, type, Old );

    SyntaxMapContainer syntax;

    if( format == "GIBI" || format == "GMSH" )
    {
        // Fichier temporaire
        LogicalUnitFileCython file2( "", Ascii, Append );
        std::string preCmd = "PRE_" + format;
        ASTERINTEGER op2 = 47;
        if( format == "GIBI" ) op2 = 49;

        CommandSyntax* cmdSt2 = new CommandSyntax( preCmd );
        SyntaxMapContainer syntax2;
        syntax2.container[ "UNITE_" + format ] = (ASTERINTEGER)file1.getLogicalUnit();
        syntax2.container[ "UNITE_MAILLAGE" ] = (ASTERINTEGER)file2.getLogicalUnit();
        cmdSt2->define( syntax2 );

        try
        {
            CALL_EXECOP( &op2 );
        }
        catch( ... )
        {
            throw;
        }
        delete cmdSt2;
        syntax.container[ "FORMAT" ] = "ASTER";
        syntax.container[ "UNITE" ] = (ASTERINTEGER)file2.getLogicalUnit();

        CommandSyntax cmdSt( "LIRE_MAILLAGE" );
        cmdSt.setResult( ResultNaming::getCurrentName(), "MAILLAGE" );

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
    }
    else
    {
        syntax.container[ "FORMAT" ] = format;
        syntax.container[ "UNITE" ] = (ASTERINTEGER)file1.getLogicalUnit();

        CommandSyntax cmdSt( "LIRE_MAILLAGE" );
        cmdSt.setResult( ResultNaming::getCurrentName(), "MAILLAGE" );

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
    }

    return true;
};

bool MeshInstance::readAsterMeshFile( const std::string& fileName )
    throw ( std::runtime_error )
{
    readMeshFile( fileName, "ASTER" );

    return true;
};

bool MeshInstance::readGibiFile( const std::string& fileName )
    throw ( std::runtime_error )
{
    readMeshFile( fileName, "GIBI" );

    return true;
};

bool MeshInstance::readGmshFile( const std::string& fileName )
    throw ( std::runtime_error )
{
    readMeshFile( fileName, "GMSH" );

    return true;
};

bool BaseMeshInstance::readMedFile( const std::string& fileName )
    throw ( std::runtime_error )
{
    readMeshFile( fileName, "MED" );

    return true;
};
