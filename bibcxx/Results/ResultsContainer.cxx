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
    CALLO_RSCRSD( base, getName(), getType(), &nbordr );
    _nbRanks = nbRanks;
    return true;
};

void ResultsContainerInstance::addElementaryCharacteristics( const ElementaryCharacteristicsPtr& cara,
                                                             int rank )
    throw ( std::runtime_error )
{
    long rang = rank;
    std::string type("CARAELEM");
    CALLO_RSADPA_ZK8_WRAP( getName(), &rang, cara->getName(), type );
};

void ResultsContainerInstance::addListOfLoads( const ListOfLoadsPtr& load,
                                               int rank ) throw ( std::runtime_error )
{
    long rang = rank;
    std::string type("EXCIT");
    CALLO_RSADPA_ZK24_WRAP( getName(), &rang, load->getName(), type );
};

void ResultsContainerInstance::addMaterialOnMesh( const MaterialOnMeshPtr& mater,
                                                  int rank ) throw ( std::runtime_error )
{
    long rang = rank;
    std::string type("CHAMPMAT");
    CALLO_RSADPA_ZK8_WRAP( getName(), &rang, mater->getName(), type );
};

void ResultsContainerInstance::addModel( const ModelPtr& model,
                                         int rank ) throw ( std::runtime_error )
{
    long rang = rank;
    std::string type("MODELE");
    CALLO_RSADPA_ZK8_WRAP( getName(), &rang, model->getName(), type );
};

void ResultsContainerInstance::addTimeValue( double value,
                                             int rank ) throw ( std::runtime_error )
{
    long rang = rank;
    std::string type("INST");
    CALLO_RSADPA_ZR_WRAP( getName(), &rang, &value, type );
};

void ResultsContainerInstance::listFields() const
{   std::cout<<"Content of DataStructure : ";
    for ( auto curIter : _dictOfVectorOfFieldsNodes )
    {
        std::cout << curIter.first << " - " ;
    }
    for ( auto curIter : _dictOfVectorOfFieldsElements )
    {
        std::cout << curIter.first << " - "  ;
    }
    std::cout << std::endl;
};

bool ResultsContainerInstance::update() throw ( std::runtime_error )
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
                JeveuxChar32 repk(" ");
                const std::string arret( "C" );
                const std::string questi2( "TYPE_SCA" );

                CALLO_DISMOI( questi2, name, typeco, &repi, repk, arret, &ier );
                const std::string resu2( trim( repk.toString() ) );
                /*if( resu2 != "R" )
                    throw std::runtime_error( "Not yet implemented" );*/

                CALLO_DISMOI( questi, name, typeco, &repi, repk, arret, &ier );
                const std::string resu( trim( repk.toString() ) );

                if( resu == "NOEU" )
                {
                    const auto& curIter2 = _dictOfVectorOfFieldsNodes.find( nomSymb );
                    if( curIter2 == _dictOfVectorOfFieldsNodes.end() )
                        _dictOfVectorOfFieldsNodes[ nomSymb ] = VectorOfFieldsNodes( numberOfSerialNum,
                            FieldOnNodesDoublePtr( nullptr ) );

                    long test2 = _dictOfVectorOfFieldsNodes[ nomSymb ][ rank ].use_count();
                    if( test2 == 0 )
                    {
                        FieldOnNodesDoublePtr result( new FieldOnNodesDoubleInstance( name ) );
                        _dictOfVectorOfFieldsNodes[ nomSymb ][ rank ] = result;
                    }
                }
                else if( resu == "ELEM" || resu == "ELNO" || resu == "ELGA" )
                {
                    const auto& curIter2 = _dictOfVectorOfFieldsElements.find( nomSymb );
                    if( curIter2 == _dictOfVectorOfFieldsElements.end() )
                        _dictOfVectorOfFieldsElements[ nomSymb ] = VectorOfFieldsElements( numberOfSerialNum,
                            FieldOnElementsDoublePtr( nullptr ) );

                    long test2 = _dictOfVectorOfFieldsElements[ nomSymb ][ rank ].use_count();
                    if( test2 == 0 )
                    {
                        FieldOnElementsDoublePtr result( new FieldOnElementsDoubleInstance( name ) );
                        _dictOfVectorOfFieldsElements[ nomSymb ][ rank ] = result;
                    }
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
    CALLO_GNOMSD( resuName, name, &a, &b );
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
    CALLO_GNOMSD( resuName, name, &a, &b );
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
    std::string null( " " );
    std::string returnName( 19, ' ' );
    CALLO_RSEXCH( null, getName(), name, &rankLong, returnName, &retour );
    CALLO_RSNOCH( getName(), name, &rankLong );
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
