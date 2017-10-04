/**
 * @file ResultsContainer.cxx
 * @brief Implementation de ResultsContainer
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

#include "aster_fort.h"

#include "Results/ResultsContainer.h"
#include "RunManager/LogicalUnitManagerCython.h"
#include "Supervis/CommandSyntax.h"
#include "Utilities/Tools.h"

bool ResultsContainerInstance::allocate( int nbRanks ) throw ( std::runtime_error )
{
    std::string base( JeveuxMemoryTypesNames[ getMemoryType() ] );
    long nbordr = nbRanks;
    CALL_RSCRSD( base.c_str(), getName().c_str(), getType().c_str(), &nbordr );
    _nbRanks = nbRanks;
    return true;
};

void ResultsContainerInstance::addModel( const ModelPtr& model,
                                         int rank ) throw ( std::runtime_error )
{
    long rang = rank;
    std::string type("MODELE");
    CALL_RSADPA_ZK8_WRAP( getName().c_str(), &rang, model->getName().c_str(),
                          type.c_str() );
};

void ResultsContainerInstance::addMaterialOnMesh( const MaterialOnMeshPtr& mater,
                                                  int rank ) throw ( std::runtime_error )
{
    long rang = rank;
    std::string type("CHAMPMAT");
    CALL_RSADPA_ZK8_WRAP( getName().c_str(), &rang, mater->getName().c_str(),
                          type.c_str() );
};

void ResultsContainerInstance::addTimeValue( double value,
                                             int rank ) throw ( std::runtime_error )
{
    long rang = rank;
    std::string type("INST");
    CALL_RSADPA_ZR_WRAP( getName().c_str(), &rang, &value, type.c_str() );
};

bool ResultsContainerInstance::buildFromExisting() throw ( std::runtime_error )
{
    _serialNumber->updateValuePointer();
    _namesOfFields->buildFromJeveux();
    const auto numberOfSerialNum = _serialNumber->size();
    _nbRanks = numberOfSerialNum;

    int cmpt = 1;
    for( const auto curIter : _namesOfFields->getVectorOfObjects() )
    {
        auto nomSymb = trim( _symbolicNamesOfFields->findStringOfElement( cmpt ) );
        if( numberOfSerialNum != curIter.size() )
            throw std::runtime_error( "Programming error" );

        for( int rank = 0; rank < curIter.size(); ++rank )
        {
            std::string name( trim( curIter[ rank ].toString() ) );
            if( name != "" )
            {
                const std::string questi( "TYPE_CHAMP" );
                const std::string typeco( "CHAMP" );
                long repi = 0, ier = 0;
                char* repk = MakeBlankFStr(32);
                const std::string arret( "C" );
                const std::string questi2( "TYPE_SCA" );

                CALL_DISMOI( questi2.c_str(), name.c_str(), typeco.c_str(),
                             &repi, repk, arret.c_str(), &ier );
                const std::string resu2( trim( repk ) );
                /*if( resu2 != "R" )
                    throw std::runtime_error( "Not yet implemented" );*/

                CALL_DISMOI( questi.c_str(), name.c_str(), typeco.c_str(),
                             &repi, repk, arret.c_str(), &ier );
                const std::string resu( trim( repk ) );

                if( resu == "NOEU" )
                {
                    FieldOnNodesDoublePtr result( new FieldOnNodesDoubleInstance( name ) );

                    auto curIter2 = _dictOfVectorOfFieldsNodes.find( nomSymb );
                    if( curIter2 == _dictOfVectorOfFieldsNodes.end() )
                        _dictOfVectorOfFieldsNodes[ nomSymb ] = VectorOfFieldsNodes( numberOfSerialNum );
                    _dictOfVectorOfFieldsNodes[ nomSymb ][ rank ] = result;
                }
                else if( resu == "ELEM" || resu == "ELNO" || resu == "ELGA" )
                {
                    FieldOnElementsDoublePtr result( new FieldOnElementsDoubleInstance( name ) );

                    auto curIter2 = _dictOfVectorOfFieldsElements.find( nomSymb );
                    if( curIter2 == _dictOfVectorOfFieldsElements.end() )
                        _dictOfVectorOfFieldsElements[ nomSymb ] = VectorOfFieldsElements( numberOfSerialNum );
                    _dictOfVectorOfFieldsElements[ nomSymb ][ rank ] = result;
                }
            }
        }
        ++cmpt;
    }

    return true;
};

BaseDOFNumberingPtr ResultsContainerInstance::getEmptyDOFNumbering()
{
    std::string resuName( getName() );
    std::string name( "12345678.00000          " );
    long a = 10, b = 14;
    CALL_GNOMSD( resuName.c_str(), name.c_str(), &a, &b );
    DOFNumberingPtr retour( new DOFNumberingInstance( name.substr(0, 14) ) );
    _listOfDOFNum.push_back( retour );
    return retour;
};

#ifdef _USE_MPI
BaseDOFNumberingPtr ResultsContainerInstance::getEmptyParallelDOFNumbering()
{
    std::string resuName( getName() );
    std::string name( "12345678.00000          " );
    long a = 10, b = 14;
    CALL_GNOMSD( resuName.c_str(), name.c_str(), &a, &b );
    ParallelDOFNumberingPtr retour( new ParallelDOFNumberingInstance( name.substr(0, 14) ) );
    _listOfDOFNum.push_back( retour );
    return retour;
};
#endif /* _USE_MPI */

FieldOnNodesDoublePtr ResultsContainerInstance::getEmptyFieldOnNodesDouble( const std::string name,
                                                                            const int rank )
    throw ( std::runtime_error )
{
    if( rank > _nbRanks )
        throw std::runtime_error( "Order number out of range" );
    ASTERINTEGER retour;
    retour = 0;
    const ASTERINTEGER rankLong = rank;
    std::string returnName( 19, ' ' );
    CALL_RSEXCH( " ", getName().c_str(), name.c_str(), &rankLong, returnName.c_str(), &retour );
    CALL_RSNOCH( getName().c_str(), name.c_str(), &rankLong );
    std::string bis( returnName.c_str(), 19 );
    FieldOnNodesDoublePtr result( new FieldOnNodesDoubleInstance( bis ) );

    auto curIter = _dictOfVectorOfFieldsNodes.find( name );
    if( curIter == _dictOfVectorOfFieldsNodes.end() )
    {
        _dictOfVectorOfFieldsNodes[ name ] = VectorOfFieldsNodes( _nbRanks );
    }
    _dictOfVectorOfFieldsNodes[ name ][ rank ] = result;
    return result;
};

FieldOnElementsDoublePtr ResultsContainerInstance::getRealFieldOnElements( const std::string name,
                                                                           const int rank ) const
    throw ( std::runtime_error )
{
    if( rank > _nbRanks )
        throw std::runtime_error( "Order number out of range" );

    auto curIter = _dictOfVectorOfFieldsElements.find( trim( name ) );
    if( curIter == _dictOfVectorOfFieldsElements.end() )
        throw std::runtime_error( "Field " + name + " unknown in the results container" );

    FieldOnElementsDoublePtr toReturn = curIter->second[ rank ];
    return toReturn;
};

FieldOnNodesDoublePtr ResultsContainerInstance::getRealFieldOnNodes( const std::string name,
                                                                     const int rank ) const
    throw ( std::runtime_error )
{
    if( rank > _nbRanks )
        throw std::runtime_error( "Order number out of range" );

    auto curIter = _dictOfVectorOfFieldsNodes.find( trim( name ) );
    if( curIter == _dictOfVectorOfFieldsNodes.end() )
        throw std::runtime_error( "Field " + name + " unknown in the results container" );

    FieldOnNodesDoublePtr toReturn = curIter->second[ rank ];
    return toReturn;
};

bool ResultsContainerInstance::printMedFile( const std::string fileName ) const
    throw ( std::runtime_error )
{
    LogicalUnitFileCython a( fileName, Binary, New );
    int retour = a.getLogicalUnit();
    CommandSyntax cmdSt( "IMPR_RESU" );

    SyntaxMapContainer dict;
    dict.container[ "FORMAT" ] = "MED";
    dict.container[ "UNITE" ] = retour;

    ListSyntaxMapContainer listeResu;
    SyntaxMapContainer dict2;
    dict2.container[ "RESULTAT" ] = getName();
    dict2.container[ "TOUT_ORDRE" ] = "OUI";
    listeResu.push_back( dict2 );
    dict.container[ "RESU" ] = listeResu;

    cmdSt.define( dict );

    try
    {
        ASTERINTEGER op = 39;
        CALL_EXECOP( &op );
    }
    catch( ... )
    {
        throw;
    }

    return true;
};
