/**
 * @file ListOfLoads.cxx
 * @brief Implementation de ListOfLoads
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

#include "Loads/ListOfLoads.h"
#include "Supervis/CommandSyntax.h"

ListOfLoadsInstance::ListOfLoadsInstance( const JeveuxMemory memType ):
    DataStructure( "L_CHARGES", memType, 19 ),
    _loadInformations( JeveuxVectorLong( getName() + ".INFC" ) ),
    _list( JeveuxVectorChar24( getName() + ".LCHA" ) ),
    _listOfFunctions( JeveuxVectorChar24( getName() + ".FCHA" ) ),
    _isEmpty( true )
{};

bool ListOfLoadsInstance::build() throw ( std::runtime_error )
{
    if ( ! _isEmpty )
        return true;
    CommandSyntax cmdSt( "MECA_STATIQUE" );

    SyntaxMapContainer dict;
    ListSyntaxMapContainer listeExcit;
    int pos = 0;
    for ( const auto& curIter : _listOfMechanicalLoads )
    {
        SyntaxMapContainer dict2;
        dict2.container[ "CHARGE" ] = curIter->getName();
        if( _listOfMechaFun[pos].getName() != emptyDoubleFunction->getName() )
            dict2.container[ "FONC_MULT" ] = _listOfMechaFun[pos].getName();
        ++pos;
        listeExcit.push_back( dict2 );
    }
#ifdef _USE_MPI
    pos = 0;
    for ( const auto& curIter : _listOfParallelMechanicalLoads )
    {
        SyntaxMapContainer dict2;
        dict2.container[ "CHARGE" ] = curIter->getName();
        if( _listOfParaMechaFun[pos].getName() != emptyDoubleFunction->getName() )
            dict2.container[ "FONC_MULT" ] = _listOfParaMechaFun[pos].getName();
        ++pos;
        listeExcit.push_back( dict2 );
    }
#endif /* _USE_MPI */
    pos = 0;
    for ( const auto& curIter : _listOfKinematicsLoads )
    {
        SyntaxMapContainer dict2;
        dict2.container[ "CHARGE" ] = curIter->getName();
        if( _listOfKineFun[pos].getName() != emptyDoubleFunction->getName() )
            dict2.container[ "FONC_MULT" ] = _listOfKineFun[pos].getName();
        ++pos;
        listeExcit.push_back( dict2 );
    }
    dict.container[ "EXCIT" ] = listeExcit;
    cmdSt.define( dict );
    long iexcit = 1;
    std::string name( getName().c_str() );
    name.resize( 19, ' ' );
    std::string blank( " " );
    blank.resize( 19, ' ' );
    std::string base( JeveuxMemoryTypesNames[ (int)getMemoryType() ] );
    CALLO_NMDOCH_WRAP( name, &iexcit, blank, base );
    _isEmpty = false;
    return true;
};

/* buildListExcit : construit la liste des charges utilisées pour valoriser le mot-clé facteur EXCIT
dans STAT_NON_LINE. C'est une méthode temporaire qui disparaîtra avec la réécriture d'op0070 */
ListSyntaxMapContainer ListOfLoadsInstance::buildListExcit() throw ( std::runtime_error )
{
    ListSyntaxMapContainer listeExcit;
    int pos = 0;
    for ( ListMecaLoadCIter curIter = _listOfMechanicalLoads.begin();
          curIter != _listOfMechanicalLoads.end();
          ++curIter )
    {
        SyntaxMapContainer dict2;
        dict2.container[ "CHARGE" ] = (*curIter)->getName();
        if( _listOfMechaFun[pos].getName() != emptyDoubleFunction->getName() )
            dict2.container[ "FONC_MULT" ] = _listOfMechaFun[pos].getName();
        ++pos;
        listeExcit.push_back( dict2 );
    }
#ifdef _USE_MPI
    pos = 0;
    for ( const auto& curIter : _listOfParallelMechanicalLoads )
    {
        SyntaxMapContainer dict2;
        dict2.container[ "CHARGE" ] = curIter->getName();
        if( _listOfParaMechaFun[pos].getName() != emptyDoubleFunction->getName() )
            dict2.container[ "FONC_MULT" ] = _listOfParaMechaFun[pos].getName();
        ++pos;
        listeExcit.push_back( dict2 );
    }
#endif /* _USE_MPI */
    pos = 0;
    for ( ListKineLoadCIter curIter = _listOfKinematicsLoads.begin();
          curIter != _listOfKinematicsLoads.end();
          ++curIter )
    {
        SyntaxMapContainer dict2;
        dict2.container[ "CHARGE" ] = (*curIter)->getName();
        if( _listOfKineFun[pos].getName() != emptyDoubleFunction->getName() )
            dict2.container[ "FONC_MULT" ] = _listOfKineFun[pos].getName();
        ++pos;
        listeExcit.push_back( dict2 );
    }
    return listeExcit;
};
