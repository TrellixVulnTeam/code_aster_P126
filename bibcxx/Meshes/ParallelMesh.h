
#include "astercxx.h"

#ifdef _USE_MPI

#ifndef PARALLELMESH_H_
#define PARALLELMESH_H_

/**
 * @file ParallelMesh.h
 * @brief Fichier entete de la classe ParallelMesh
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
#include "Meshes/Mesh.h"

/**
 * @class ParallelMeshInstance
 * @brief Cette classe decrit un maillage Aster parallèle
 * @author Nicolas Sellenet
 */
class ParallelMeshInstance: public MeshInstance
{
private:

public:
    /**
     * @typedef ParallelMeshPtr
     * @brief Pointeur intelligent vers un ParallelMeshInstance
     */
    typedef boost::shared_ptr< ParallelMeshInstance > ParallelMeshPtr;

    /**
     * @brief Constructeur
     */
    static ParallelMeshPtr create()
    {
        return ParallelMeshPtr( new ParallelMeshInstance );
    };

    /**
     * @brief Constructeur
     */
    ParallelMeshInstance();

    /**
     * @brief Destructeur
     */
    ~ParallelMeshInstance() throw ( std::runtime_error )
    {
#ifdef __DEBUG_GC__
        std::cout << "ParallelMesh.destr: " << this->getName() << std::endl;
#endif
    };

    /**
     * @brief Read a MED ParallelMesh file
     * @return retourne true si tout est ok
     */
    bool readMedFile( const std::string& fileName ) throw ( std::runtime_error );
};

/**
 * @typedef ParallelMeshPtr
 * @brief Pointeur intelligent vers un ParallelMeshInstance
 */
typedef boost::shared_ptr< ParallelMeshInstance > ParallelMeshPtr;

#endif /* PARALLELMESH_H_ */

#endif /* _USE_MPI */
