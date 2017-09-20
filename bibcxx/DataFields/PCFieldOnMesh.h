#ifndef PCFIELDONMESH_H_
#define PCFIELDONMESH_H_

/**
 * @file PCFieldOnMesh.h
 * @brief Fichier entete de la classe PCFieldOnMesh
 * @author Natacha Bereux
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

/* person_in_charge: natacha.bereux at edf.fr */

#include <stdexcept>
#include <string>
#include <assert.h>

#include "astercxx.h"
#include "MemoryManager/JeveuxCollection.h"
#include "MemoryManager/JeveuxVector.h"
#include "Meshes/Mesh.h"
#include "Modeling/FiniteElementDescriptor.h"
#include "aster_fort.h"

/**
 * @class PCFieldZone Piecewise Constant (PC) Field Zone
 * @author Natacha Bereux
 */
class PCFieldZone
{
public:
    enum LocalizationType { AllMesh, AllDelayedElements, GroupOfElements,
                            ListOfElements, ListOfDelayedElements };

private:
    BaseMeshPtr                _mesh;
    FiniteElementDescriptorPtr _ligrel;
    LocalizationType           _localisation;
    GroupOfElementsPtr         _grp;
    VectorLong                 _indexes;

public:
    PCFieldZone( BaseMeshPtr mesh ): _mesh( mesh ),
                                     _localisation( AllMesh )
    {};

    PCFieldZone( FiniteElementDescriptorPtr ligrel ): _ligrel( ligrel ),
                                                      _localisation( AllDelayedElements )
    {};

    PCFieldZone( BaseMeshPtr mesh, GroupOfElementsPtr grp ): _mesh( mesh ),
                                                             _localisation( GroupOfElements ),
                                                             _grp( grp )
    {};

    PCFieldZone( BaseMeshPtr mesh, const VectorLong& indexes ): _mesh( mesh ),
                                                               _localisation( ListOfElements ),
                                                               _indexes( indexes )
    {};

    PCFieldZone( FiniteElementDescriptorPtr ligrel, const VectorLong& indexes ):
        _ligrel( ligrel ),
        _localisation( ListOfDelayedElements ),
        _indexes( indexes )
    {};

    BaseMeshPtr getMesh() const throw( std::runtime_error )
    {
        if( _localisation != AllMesh and _localisation != GroupOfElements
            and _localisation != ListOfElements )
            throw std::runtime_error( "Zone not on a mesh" );
        return _mesh;
    };

    FiniteElementDescriptorPtr getFiniteElementDescriptor() const
        throw( std::runtime_error )
    {
        if( _localisation != AllDelayedElements and _localisation != ListOfDelayedElements )
            throw std::runtime_error( "Zone not on a FiniteElementDescriptor" );
        return _ligrel;
    };

    LocalizationType getLocalizationType() const
    {
        return _localisation;
    };

    GroupOfElementsPtr getSupportGroup() const
        throw( std::runtime_error )
    {
        if( _localisation != GroupOfElements )
            throw std::runtime_error( "Zone not on a group of elements" );
        return _grp;
    };

    const VectorLong& getListOfElements() const
        throw( std::runtime_error )
    {
        if( _localisation != ListOfElements and _localisation != ListOfDelayedElements )
            throw std::runtime_error( "Zone not on a group of elements" );
        return _indexes;
    };
};

/**
 * @class PCFieldOnMeshInstance Piecewise Constant (PC) Field on Mesh template
 * @brief Cette classe permet de definir une carte (champ défini sur les mailles)
 * @author Natacha Bereux
 * @todo Le template doit aussi prendre en argument la grandeur : CART_TEMP_R
 */
template< class ValueType >
class PCFieldOnMeshInstance: public DataStructure
{
    private:
        /** @brief Vecteur Jeveux '.NOMA' */
        JeveuxVectorChar8          _meshName;
        /** @brief Vecteur Jeveux '.DESC' */
        JeveuxVectorLong           _descriptor;
        /** @brief Vecteur Jeveux '.NOLI' */
        JeveuxVectorChar24         _nameOfLigrels;
        /** @brief Collection  '.LIMA' */
        JeveuxCollectionLong       _listOfMeshElements;
        /** @brief Vecteur Jeveux '.VALE' */
        JeveuxVector< ValueType >  _valuesList;
        /** @brief Maillage sous-jacent */
        BaseMeshPtr                _supportMesh;
        /** @brief Ligrel */
        FiniteElementDescriptorPtr _FEDesc;
        /** @brief La carte est-elle allouée ? */
        bool                       _isAllocated;
        /** @brief Objet temporaire '.NCMP' */
        JeveuxVectorChar8          _componentNames;
        /** @brief Objet temporaire '.VALV' */
        JeveuxVector< ValueType >  _valuesListTmp;

    private:
        void fortranAddValues( const long& code, const std::string& grp, const std::string& mode,
                               const long& nma, const JeveuxVectorLong& limanu,
                               const std::string& ligrel, const JeveuxVectorChar8& component,
                               JeveuxVector< ValueType >& values )
            throw ( std::runtime_error )
        {
            bool test = _componentNames->updateValuePointer();
            test = test && _valuesListTmp->updateValuePointer();
            if ( ! test )
                throw std::runtime_error( "PCFieldOnMeshInstance not allocate" );
            const long taille = _componentNames->size();

            const long tVerif1 = component->size();
            const long tVerif2 = values->size();
            if ( tVerif1 > taille || tVerif2 > taille || tVerif1 != tVerif2 )
                throw std::runtime_error( "Unconsistent size" );

            for ( int position = 0; position < tVerif1; ++position )
            {
                (*_componentNames)[position] = (*component)[position];
                (*_valuesListTmp)[position] = (*values)[position];
            }

            const std::string limano( " " );
            try
            {
                CALL_NOCARTC( getName().c_str(), &code, &tVerif1, grp.c_str(), mode.c_str(),
                              &nma, limano.c_str(), &( *limanu )[0], ligrel.c_str() );
            }
            catch( ... )
            {
                throw;
            }
        };

        void fortranAllocate( const std::string base, const std::string quantity )
            throw ( std::runtime_error )
        {
            try
            {
                CALL_ALCART( base.c_str(), getName().c_str(), _supportMesh->getName().c_str(),
                             quantity.c_str() );
            }
            catch( ... )
            {
                throw;
            }
        };

    public:
        /**
         * @typedef PCFieldOnBaseMeshPtr
         * @brief Pointeur intelligent vers un PCFieldOnMesh
         */
        typedef boost::shared_ptr< PCFieldOnMeshInstance > PCFieldOnBaseMeshPtr;

        /**
         * @brief Constructeur
         */
        static PCFieldOnBaseMeshPtr create( const BaseMeshPtr& mesh )
        {
            return PCFieldOnBaseMeshPtr( new PCFieldOnMeshInstance( getNewResultObjectName(),
                                                                    mesh ) );
        };

        /**
         * @brief Constructeur
         * @param name Nom Jeveux de la carte
         * @param mesh Maillage support
         */
        PCFieldOnMeshInstance( const std::string& name, const BaseMeshPtr& mesh ):
            DataStructure( name, "CART_" ),
            _meshName( JeveuxVectorChar8( name + ".NOMA" ) ),
            _descriptor( JeveuxVectorLong( name + ".DESC" ) ),
            _nameOfLigrels( JeveuxVectorChar24( name + ".NOLI" ) ),
            _listOfMeshElements( JeveuxCollectionLong( name + ".LIMA" ) ),
            _valuesList( JeveuxVector<ValueType>( name + ".VALE" ) ),
            _supportMesh( mesh ),
            _FEDesc( FiniteElementDescriptorPtr() ),
            _isAllocated( false ),
            _componentNames( name + ".NCMP" ),
            _valuesListTmp( name + ".VALV" )
        {
            assert( name.size() == 19 );
        };

        /**
         * @brief Constructeur
         * @param name Nom Jeveux de la carte
         * @param ligrel Ligrel support
         */
        PCFieldOnMeshInstance( std::string name,
                               const FiniteElementDescriptorPtr& ligrel ):
            DataStructure( name, "CART_" ),
            _meshName( JeveuxVectorChar8( name + ".NOMA" ) ),
            _descriptor( JeveuxVectorLong( name + ".DESC" ) ),
            _nameOfLigrels( JeveuxVectorChar24( name + ".NOLI" ) ),
            _listOfMeshElements( JeveuxCollectionLong( name + ".LIMA" ) ),
            _valuesList( JeveuxVector<ValueType>( name + ".VALE" ) ),
            _supportMesh( BaseMeshPtr() ),
            _FEDesc( ligrel ),
            _isAllocated( false ),
            _componentNames( name + ".NCMP" ),
            _valuesListTmp( name + ".VALV" )
        {
            assert( name.size() == 19 );
        };

        /**
         * @brief Constructeur
         * @param mesh Maillage support
         * @param name Nom Jeveux de la carte
         */
        PCFieldOnMeshInstance( const BaseMeshPtr& mesh, 
                               const JeveuxMemory memType = Permanent ):
            DataStructure( "CART_", memType, 19 ),
            _meshName( JeveuxVectorChar8( getName() + ".NOMA" ) ),
            _descriptor( JeveuxVectorLong( getName() + ".DESC" ) ),
            _nameOfLigrels( JeveuxVectorChar24( getName() + ".NOLI" ) ),
            _listOfMeshElements( JeveuxCollectionLong( getName() + ".LIMA" ) ),
            _valuesList( JeveuxVector<ValueType>( getName() + ".VALE" ) ),
            _supportMesh( mesh ),
            _FEDesc( FiniteElementDescriptorPtr() ),
            _isAllocated( false ),
            _componentNames( getName() + ".NCMP" ),
            _valuesListTmp( getName() + ".VALV" )
        {
            assert( getName().size() == 19 );
        };

        /**
         * @brief Constructeur
         * @param ligrel Ligrel support
         * @param name Nom Jeveux de la carte
         */
        PCFieldOnMeshInstance( const FiniteElementDescriptorPtr& ligrel,
                               const JeveuxMemory memType = Permanent ):
            DataStructure( "CART_", memType, 19 ),
            _meshName( JeveuxVectorChar8( getName() + ".NOMA" ) ),
            _descriptor( JeveuxVectorLong( getName() + ".DESC" ) ),
            _nameOfLigrels( JeveuxVectorChar24( getName() + ".NOLI" ) ),
            _listOfMeshElements( JeveuxCollectionLong( getName() + ".LIMA" ) ),
            _valuesList( JeveuxVector<ValueType>( getName() + ".VALE" ) ),
            _supportMesh( BaseMeshPtr() ),
            _FEDesc( ligrel ),
            _isAllocated( false ),
            _componentNames( getName() + ".NCMP" ),
            _valuesListTmp( getName() + ".VALV" )
        {
            assert( getName().size() == 19 );
        };

        /**
         * @brief Destructeur
         */
        ~PCFieldOnMeshInstance()
        {};

        /**
         * @brief Allocation de la carte
         * @return true si l'allocation s'est bien deroulee, false sinon
         */
        void allocate( const JeveuxMemory jeveuxBase, const std::string componant )
            throw ( std::runtime_error )
        {
            if ( _supportMesh.use_count() == 0 || _supportMesh->isEmpty() )
                throw std::runtime_error( "Mesh is empty" );

            std::string strJeveuxBase( "V" );
            if ( jeveuxBase == Permanent ) strJeveuxBase = "G";
            fortranAllocate( strJeveuxBase, componant );
            _isAllocated = true;
        };

        /**
         * @brief Get number of zone in PCFieldOnMesh
         */
        int getSize() const
        {
            _descriptor->updateValuePointer();
            return (*_descriptor)[2];
        };

        /**
         * @brief Get zone description
         */
        PCFieldZone getZoneDescription( const int& position ) const
            throw( std::runtime_error )
        {
            _descriptor->updateValuePointer();
            if( position >= (*_descriptor)[2] )
                throw std::runtime_error( "Out of PCFieldOnMesh bound" );

            long code = (*_descriptor)[ 3 + 2*position ];
            if( code == 1 )
                return PCFieldZone( _supportMesh );
            else if( code == -1 )
                return PCFieldZone( _FEDesc );
            else if( code == 2 )
            {
                const auto numGrp = (*_descriptor)[ 4 + 2*position ];
                const auto& map = _supportMesh->getGroupOfNodesNames();
                const auto name = map->findStringOfElement( numGrp );
                return PCFieldZone( _supportMesh, 
                                    GroupOfElementsPtr( new GroupOfElements( name ) ) );
            }
//             else if( code == 3 )
            else if( code == -3 )
            {
                const auto numGrp = (*_descriptor)[ 4 + 2*position ];
                _listOfMeshElements->buildFromJeveux();
                const auto& object = _listOfMeshElements->getObject( numGrp );
                return PCFieldZone( _FEDesc, object.toVector() );
            }
            else
                throw std::runtime_error( "Error in PCFieldOnMesh" );
        };

        /**
         * @brief Définition du maillage sous-jacent
         * @param currentMesh objet Mesh sur lequel le modele reposera
         * @return renvoit true si la définition s'est bien deroulee, false sinon
         */
        bool setSupportMesh( BaseMeshPtr& currentMesh ) throw ( std::runtime_error )
        {
            if ( currentMesh->isEmpty() )
                throw std::runtime_error( "Mesh is empty" );
            _supportMesh = currentMesh;
            return true;
        };

        /**
         * @brief Fixer une valeur sur tout le maillage
         * @param component JeveuxVectorChar8 contenant le nom des composantes à fixer
         * @param values JeveuxVector< ValueType > contenant les valeurs
         * @param ligrel TEMPORAIRE
         * @return renvoit true si l'ajout s'est bien deroulee, false sinon
         * @todo Ajouter la possibilite de donner un ligrel (n'existe pas encore)
         */
        bool setValueOnAllMesh( const JeveuxVectorChar8& component,
                                const JeveuxVector< ValueType >& values,
                                std::string ligrel = " " )
            throw ( std::runtime_error )
        {
            if ( _supportMesh.use_count() == 0 || _supportMesh->isEmpty() )
                throw std::runtime_error( "Mesh is empty" );
            if ( ligrel != " " )
                throw std::runtime_error( "Build a PCFieldOnMeshInstance with a ligrel not yet available" );

            const long code = 1;
            const std::string grp( " " );
            const std::string mode( " " );
            const long nbMa = 0;
            JeveuxVectorLong limanu( "empty" );
            limanu->allocate( Temporary, 1 );
            fortranAddValues( code, grp, mode, nbMa, limanu, ligrel, component, values );
            return true;
        };

        /**
         * @brief Fixer une valeur sur un groupe de mailles
         * @param component JeveuxVectorChar8 contenant le nom des composantes à fixer
         * @param values JeveuxVector< ValueType > contenant les valeurs
         * @param grp Groupe de mailles
         * @param ligrel TEMPORAIRE
         * @return renvoit true si l'ajout s'est bien deroulee, false sinon
         * @todo Ajouter la possibilite de donner un ligrel (n'existe pas encore)
         */
        bool setValueOnGroupOfElements( const JeveuxVectorChar8& component,
                                        const JeveuxVector< ValueType >& values,
                                        const GroupOfElements& grp, std::string ligrel = " " )
            throw ( std::runtime_error )
        {
            if ( _supportMesh.use_count() == 0 || _supportMesh->isEmpty() )
                throw std::runtime_error( "Mesh is empty" );
            if ( ligrel != " " )
                throw std::runtime_error( "Build a PCFieldOnMeshInstance with a ligrel not yet available" );
            if ( ! _supportMesh->hasGroupOfElements( grp.getName() ) )
                throw std::runtime_error( "Group " + grp.getName() + " not in mesh" );

            const long code = 2;
            const std::string mode( " " );
            const long nbMa = 0;
            JeveuxVectorLong limanu( "empty" );
            limanu->allocate( Temporary, 1 );
            fortranAddValues( code, grp.getName(), mode, nbMa, limanu, ligrel, component, values );
            return true;
        };

        /**
         * @brief Mise a jour des pointeurs Jeveux
         * @return true si la mise a jour s'est bien deroulee, false sinon
         */
        bool updateValuePointers()
        {
            bool retour = _meshName->updateValuePointer();
            retour = ( retour && _descriptor->updateValuePointer() );
            retour = ( retour && _valuesList->updateValuePointer() );
            // Les deux elements suivants sont facultatifs
            _listOfMeshElements->buildFromJeveux();
            _nameOfLigrels->updateValuePointer();
            return retour;
        };
};

/** @typedef PCFieldOnMeshDoubleInstance Instance d'une carte de double */
typedef PCFieldOnMeshInstance< double > PCFieldOnMeshDoubleInstance;
/** @typedef PCFieldOnMeshLongInstance Instance d'une carte de long */
typedef PCFieldOnMeshInstance< long > PCFieldOnMeshLongInstance;
/** @typedef PCFieldOnMeshComplexInstance Instance d'une carte de complexe */
typedef PCFieldOnMeshInstance< DoubleComplex > PCFieldOnMeshComplexInstance;
/** @typedef PCFieldOnMeshChar8Instance Instance d'une carte de char*8 */
typedef PCFieldOnMeshInstance< JeveuxChar8 > PCFieldOnMeshChar8Instance;
/** @typedef PCFieldOnMeshChar16Instance Instance d'une carte de char*16 */
typedef PCFieldOnMeshInstance< JeveuxChar8 > PCFieldOnMeshChar16Instance;

/**
 * @typedef PCFieldOnBaseMeshPtrDouble
 * @brief   Definition d'une carte de double
 */
typedef boost::shared_ptr< PCFieldOnMeshDoubleInstance > PCFieldOnMeshDoublePtr;

/**
 * @typedef PCFieldOnMeshLongPtr
 * @brief   Definition d'une carte de double
 */
typedef boost::shared_ptr< PCFieldOnMeshLongInstance > PCFieldOnMeshLongPtr;

/**
 * @typedef PCFieldOnBaseMeshPtrComplex
 * @brief   Definition d'une carte de complexe
 */
typedef boost::shared_ptr< PCFieldOnMeshComplexInstance > PCFieldOnMeshComplexPtr;

/**
 * @typedef PCFieldOnBaseMeshPtrChar8 Definition d'une carte de char[8]
 * @brief Pointeur intelligent vers un PCFieldOnMeshInstance
 */
typedef boost::shared_ptr< PCFieldOnMeshChar8Instance > PCFieldOnMeshChar8Ptr;

/**
 * @typedef PCFieldOnBaseMeshPtrChar16 Definition d'une carte de char[16]
 * @brief Pointeur intelligent vers un PCFieldOnMeshInstance
 */
typedef boost::shared_ptr< PCFieldOnMeshChar16Instance > PCFieldOnMeshChar16Ptr;
#endif /* PCFIELDONMESH_H_ */
