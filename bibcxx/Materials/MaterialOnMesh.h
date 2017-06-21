#ifndef MATERIALONMESH_H_
#define MATERIALONMESH_H_

/**
 * @file MaterialOnMesh.h
 * @brief Fichier entete de la classe MaterialOnMesh
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

#include <stdexcept>
#include "astercxx.h"
#include "DataStructures/DataStructure.h"
#include "Modeling/Model.h"
#include "Materials/Material.h"
#include "DataFields/PCFieldOnMesh.h"
#include "Meshes/ParallelMesh.h"

/**
 * @class MaterialOnMeshInstance
 * @brief produit une sd identique a celle produite par AFFE_MATERIAU
 * @author Nicolas Sellenet
 */
class MaterialOnMeshInstance: public DataStructure
{
    private:
        // On redefinit le type MeshEntityPtr afin de pouvoir stocker les MeshEntity
        // dans la list
        /** @typedef Definition d'un pointeur intelligent sur un VirtualMeshEntity */
        typedef boost::shared_ptr< VirtualMeshEntity > MeshEntityPtr;
        /** @typedef std::list d'une std::pair de MeshEntityPtr */
        typedef std::list< std::pair< MaterialPtr, MeshEntityPtr > > listOfMatsAndGrps;
        /** @typedef Definition de la valeur contenue dans un listOfMatsAndGrps */
        typedef listOfMatsAndGrps::value_type listOfMatsAndGrpsValue;
        /** @typedef Definition d'un iterateur sur listOfMatsAndGrps */
        typedef listOfMatsAndGrps::iterator listOfMatsAndGrpsIter;

        /** @brief Carte '.CHAMP_MAT' */
        PCFieldOnMeshPtrChar8  _listOfMaterials;
        /** @brief Carte '.TEMPE_REF' */
        PCFieldOnMeshPtrDouble _listOfTemperatures;
        /** @brief Liste contenant les materiaux ajoutes par l'utilisateur */
        listOfMatsAndGrps      _materialsOnMeshEntity;
        /** @brief Maillage sur lequel repose la sd_cham_mater */
        BaseMeshPtr            _supportMesh;

        /**
         * @brief Return a SyntaxMapContainer to emulate the command keywords
         * @return SyntaxMapContainer
         */
        SyntaxMapContainer getCppCommandKeywords() throw ( std::runtime_error );

    public:
        /**
         * @typedef MaterialOnMeshPtr
         * @brief Pointeur intelligent vers un MaterialOnMeshInstance
         */
        typedef boost::shared_ptr< MaterialOnMeshInstance > MaterialOnMeshPtr;

        /**
         * @brief Constructeur
         */
        MaterialOnMeshInstance();

        /**
         * @brief Ajout d'un materiau sur tout le maillage
         * @param curMater Materiau a ajouter
         */
        void addMaterialOnAllMesh( MaterialPtr& curMater )
        {
            _materialsOnMeshEntity.push_back( listOfMatsAndGrpsValue( curMater,
                                                MeshEntityPtr( new AllMeshEntities() ) ) );
        };

        /**
         * @brief Ajout d'un materiau sur une entite du maillage
         * @param curMater Materiau a ajouter
         * @param nameOfGroup Nom du groupe de mailles
         */
        void addMaterialOnGroupOfElements( MaterialPtr& curMater,
                                           std::string nameOfGroup ) throw ( std::runtime_error )
        {
            if ( ! _supportMesh ) throw std::runtime_error( "Support mesh is not defined" );
            if ( ! _supportMesh->hasGroupOfElements( nameOfGroup ) )
                throw std::runtime_error( nameOfGroup + "not in support mesh" );

            _materialsOnMeshEntity.push_back( listOfMatsAndGrpsValue( curMater,
                                                MeshEntityPtr( new GroupOfElements(nameOfGroup) ) ) );
        };

        /**
         * @brief Return a Python dict to emulate the command keywords
         * @return PyDict
         */
        PyObject* getCommandKeywords() throw ( std::runtime_error );

        /**
         * @brief Construction (au sens Jeveux fortran) de la sd_cham_mater
         * @return booleen indiquant que la construction s'est bien deroulee
         */
        bool build() throw ( std::runtime_error );

        /**
         * @brief Construction (au sens Jeveux fortran) de la sd_cham_mater
         * @return booleen indiquant que la construction s'est bien deroulee
         */
        bool build_deprecated() throw ( std::runtime_error );

        /**
         * @brief Definition du maillage support
         * @param currentMesh objet MeshPtr sur lequel le materiau reposera
         */
        bool setSupportMesh( MeshPtr& currentMesh ) throw ( std::runtime_error )
        {
            if ( currentMesh->isEmpty() )
                throw std::runtime_error( "Mesh is empty" );
            _supportMesh = currentMesh;
            return true;
        };

        /**
         * @brief Definition du maillage support
         * @param currentMesh objet ParallelMeshPtr sur lequel le materiau reposera
         */
        bool setSupportMesh( ParallelMeshPtr& currentMesh ) throw ( std::runtime_error )
        {
            if ( currentMesh->isEmpty() )
                throw std::runtime_error( "Mesh is empty" );
            _supportMesh = currentMesh;
            return true;
        };

        /**
         * @brief Obtenir le maillage support
         * @return Maillage support du champ de materiau
         */
        BaseMeshPtr getSupportMesh() throw ( std::runtime_error )
        {
            if ( _supportMesh->isEmpty() )
                throw std::runtime_error( "support mesh of current model is empty" );
            return _supportMesh;
        };
};

/**
 * @typedef MaterialOnMeshPtr
 * @brief Pointeur intelligent vers un MaterialOnMeshInstance
 */
typedef boost::shared_ptr< MaterialOnMeshInstance > MaterialOnMeshPtr;

#endif /* MATERIALONMESH_H_ */
