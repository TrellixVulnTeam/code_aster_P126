/**
 * @file KinematicsLoad.cxx
 * @brief Implementation de KinematicsLoad
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

#include <stdexcept>
#include <typeinfo>
#include "astercxx.h"

#include "Loads/KinematicsLoad.h"
#include "Utilities/SyntaxDictionary.h"

__PYX_EXTERN_C DL_IMPORT(void) newCommandSyntax(const char *);
__PYX_EXTERN_C DL_IMPORT(void) deleteCommandSyntax(void);
__PYX_EXTERN_C DL_IMPORT(void) setResultCommandSyntax(const char *, const char *);
__PYX_EXTERN_C DL_IMPORT(void) defineCommandSyntax(PyObject *);

KinematicsLoadInstance::KinematicsLoadInstance():
                    DataStructure( getNewResultObjectName(), "CHAR_CINE" ),
                    _supportModel( ModelPtr() ),
                    _isEmpty( true )
{};

bool KinematicsLoadInstance::build() throw ( std::runtime_error )
{
    std::string typSd;
    if ( _listOfDoubleImposedDisplacement.size() != 0 )
        typSd = getType() + "_MECA";
    if ( _listOfDoubleImposedTemperature.size() != 0 )
        typSd = getType() + "_THER";
    if ( _listOfDoubleImposedDisplacement.size() == 0 && _listOfDoubleImposedTemperature.size() == 0 )
        throw std::runtime_error( "KinematicsLoad empty" );
    newCommandSyntax( "AFFE_CHAR_CINE" );
    setResultCommandSyntax( getResultObjectName().c_str(), typSd.c_str() );

    SyntaxMapContainer dict;
    if ( ! _supportModel )
        throw std::runtime_error( "Support model is undefined" );
    dict.container["MODELE"] = _supportModel->getName();

    // Definition de mot cle facteur MECA_IMPO
    if ( _listOfDoubleImposedDisplacement.size() != 0 )
    {
        ListSyntaxMapContainer listeMecaImpo;
        for ( ListDoubleDispIter curIter = _listOfDoubleImposedDisplacement.begin();
              curIter != _listOfDoubleImposedDisplacement.end();
              ++curIter )
        {
            SyntaxMapContainer dict2;
            const MeshEntityPtr& tmp = curIter->getMeshEntityPtr();
            if ( tmp->getType() == AllMeshEntitiesType )
            {
                dict2.container["TOUI"] = "OUI";
            }
            else
            {
                if ( tmp->getType() == GroupOfNodesType )
                    dict2.container["GROUP_NO"] = tmp->getEntityName();
                else if ( tmp->getType() == GroupOfElementsType )
                    dict2.container["GROUP_MA"] = tmp->getEntityName();
            }

            const std::string nomComp = curIter->getAsterCoordinateName();
            dict2.container[ nomComp ] = curIter->getValue();

            listeMecaImpo.push_back( dict2 );
        }

        dict.container["MECA_IMPO"] = listeMecaImpo;
    }
    defineCommandSyntax( dict.convertToPythonDictionnary() );
    debugPrintCommandSyntax();
    try
    {
        INTEGER op = 101;
        CALL_EXECOP( &op );
    }
    catch( ... )
    {
        throw;
    }
    _isEmpty = false;
    deleteCommandSyntax();

    return true;
};
