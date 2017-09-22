#ifndef MESH_H_
#define MESH_H_

/**
 * @file Mesh.h
 * @brief Fichier entete de la classe Mesh
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
#include "definition.h"
#include "DataStructures/DataStructure.h"
#include "MemoryManager/JeveuxBidirectionalMap.h"
#include "DataFields/MeshCoordinatesField.h"
#include "Meshes/MeshEntities.h"
#include "Meshes/MeshExplorer.h"
#include "RunManager/LogicalUnitManagerCython.h"
#include <assert.h>

/**
 * @class BaseMeshInstance
 * @brief Cette classe decrit un maillage Aster
 * @author Nicolas Sellenet
 */
class BaseMeshInstance: public DataStructure
{
public:
    typedef MeshExplorer< ElementBuilderFromConnectivity,
                          const JeveuxCollectionLong&,
                          const JeveuxVectorLong& > ConnectivityMeshExplorer;
protected:
    typedef JeveuxCollection< long, JeveuxBidirectionalMapChar24 > JeveuxCollectionLongNamePtr;
    /** @brief Objet Jeveux '.DIME' */
    JeveuxVectorLong               _dimensionInformations;
    /** @brief Pointeur de nom Jeveux '.NOMNOE' */
    JeveuxBidirectionalMapChar8    _nameOfNodes;
    /** @brief Champ aux noeuds '.COORDO' */
    MeshCoordinatesFieldPtr        _coordinates;
    /** @brief Pointeur de nom Jeveux '.PTRNOMNOE' */
    JeveuxBidirectionalMapChar24   _nameOfGrpNodes;
    /** @brief Collection Jeveux '.GROUPENO' */
    JeveuxCollectionLongNamePtr    _groupsOfNodes;
    /** @brief Collection Jeveux '.CONNEX' */
    JeveuxCollectionLong           _connectivity;
    /** @brief Pointeur de nom Jeveux '.NOMMAIL' */
    JeveuxBidirectionalMapChar8    _nameOfElements;
    /** @brief Objet Jeveux '.TYPMAIL' */
    JeveuxVectorLong               _elementsType;
    /** @brief Pointeur de nom Jeveux '.PTRNOMMAI' */
    JeveuxBidirectionalMapChar24   _nameOfGrpElements;
    /** @brief Objet Jeveux '.GROUPEMA' */
    JeveuxCollectionLongNamePtr    _groupsOfElements;
    /** @brief Booleen indiquant si le maillage est vide */
    bool                           _isEmpty;
    /** @brief Object to allow loop over connectivity */
    const ConnectivityMeshExplorer _explorer;

    /**
     * @brief Read a Aster Mesh file
     * @return retourne true si tout est ok
     */
    bool readMeshFile( const std::string& fileName, const std::string& format )
        throw ( std::runtime_error );

    /**
     * @brief Constructeur
     * @param type jeveux de l'objet
     */
    BaseMeshInstance( const std::string& type );

public:
    /**
     * @typedef BaseMeshPtr
     * @brief Pointeur intelligent vers un BaseMeshInstance
     */
    typedef boost::shared_ptr< BaseMeshInstance > BaseMeshPtr;

    /**
     * @brief Destructeur
     */
    ~BaseMeshInstance() throw ( std::runtime_error )
    {
#ifdef __DEBUG_GC__
        std::cout << "Mesh.destr: " << this->getName() << std::endl;
#endif
    };

    /**
     * @brief Get the connectivity
     */
    const ConnectivityMeshExplorer& getConnectivityExplorer() const
    {
        return _explorer;
    };

    /**
     * @brief Recuperation des coordonnees du maillage
     * @return champ aux noeuds contenant les coordonnees des noeuds du maillage
     */
    MeshCoordinatesFieldPtr getCoordinates() const
    {
        _coordinates->updateValuePointers();
        return _coordinates;
    };

    /**
     * @brief Recuperation d'un groupe de noeuds
     * @return Objet de collection contenant la liste des noeuds
     */
    const JeveuxCollectionObject< long >& getGroupOfNodes( const std::string& name ) const
        throw( std::runtime_error )
    {
        if( _groupsOfNodes->size() == -1 )
            _groupsOfNodes->buildFromJeveux();
        return _groupsOfNodes->getObjectFromName( name );
    };

    /**
     * @brief Get all the names of group of elements
     * @return JeveuxBidirectionalMapChar24 _nameOfGrpElements
     */
    const JeveuxBidirectionalMapChar24& getGroupOfNodesNames() const
    {
        return _nameOfGrpElements;
    };

    /**
     * @brief Recuperation du nombre de noeuds
     */
    int getNumberOfNodes() const
    {
        if( _isEmpty )
            return 0;
        if( ! _dimensionInformations->updateValuePointer() )
            return 0;
        return (*_dimensionInformations)[0];
    };

    /**
     * @brief Teste l'existence d'un groupe de mailles dans le maillage
     * @return true si le groupe existe
     */
    virtual bool hasGroupOfElements( const std::string& name ) const
    {
        throw std::runtime_error( "Not allowed" );
        return _groupsOfElements->existsObject(name);
    };

    /**
     * @brief Teste l'existence d'un groupe de noeuds dans le maillage
     * @return true si le groupe existe
     */
    virtual bool hasGroupOfNodes( const std::string& name ) const
    {
        throw std::runtime_error( "Not allowed" );
        return _groupsOfNodes->existsObject(name);
    };

    /**
     * @brief Fonction permettant de savoir si un maillage est vide (non relu par exemple)
     * @return retourne true si le maillage est vide
     */
    bool isEmpty() const
    {
        return _isEmpty;
    };

    /**
     * @brief Fonction permettant de savoir si un maillage est parallel
     * @return retourne true si le maillage est parallel
     */
    virtual bool isParallel() const
    {
        return false;
    };

    /**
     * @brief Read a MED Mesh file
     * @return retourne true si tout est ok
     */
    virtual bool readMedFile( const std::string& fileName ) throw ( std::runtime_error );
};

/**
 * @class MeshInstance
 * @brief Cette classe decrit un maillage Aster
 * @author Nicolas Sellenet
 */
class MeshInstance: public BaseMeshInstance
{
public:
    /**
     * @typedef MeshPtr
     * @brief Pointeur intelligent vers un MeshInstance
     */
    typedef boost::shared_ptr< MeshInstance > MeshPtr;

    /**
     * @brief Constructeur
     */
    MeshInstance(): BaseMeshInstance( "MAILLAGE" )
    {};

    /**
     * @brief Constructeur
     */
    static MeshPtr create()
    {
        return MeshPtr( new MeshInstance );
    };

    /**
     * @brief Ajout d'un groupe de noeuds au maillage en partant d'une liste noeuds
     * @param name nom du groupe à créer
     * @param vec liste des noeuds
     * @return Retourne true si tout s'est bien déroulé
     */
    bool addGroupOfNodesFromNodes( const std::string& name,
                                   const VectorString& vec ) throw( std::runtime_error );

    /**
     * @brief Teste l'existence d'un groupe de mailles dans le maillage
     * @return true si le groupe existe
     */
    bool hasGroupOfElements( const std::string& name ) const
    {
        return _groupsOfElements->existsObject(name);
    };

    /**
     * @brief Teste l'existence d'un groupe de noeuds dans le maillage
     * @return true si le groupe existe
     */
    bool hasGroupOfNodes( const std::string& name ) const
    {
        return _groupsOfNodes->existsObject(name);
    };

    /**
     * @brief Read a Aster Mesh file
     * @return retourne true si tout est ok
     */
    bool readAsterMeshFile( const std::string& fileName ) throw ( std::runtime_error );

    /**
     * @brief Read a Aster Mesh file
     * @return retourne true si tout est ok
     */
    bool readGibiFile( const std::string& fileName ) throw ( std::runtime_error );

    /**
     * @brief Read a Aster Mesh file
     * @return retourne true si tout est ok
     */
    bool readGmshFile( const std::string& fileName ) throw ( std::runtime_error );
};

/**
 * @typedef BaseMeshPtr
 * @brief Pointeur intelligent vers un BaseMeshInstance
 */
typedef boost::shared_ptr< BaseMeshInstance > BaseMeshPtr;

/**
 * @typedef MeshPtr
 * @brief Pointeur intelligent vers un MeshInstance
 */
typedef boost::shared_ptr< MeshInstance > MeshPtr;

#endif /* MESH_H_ */
