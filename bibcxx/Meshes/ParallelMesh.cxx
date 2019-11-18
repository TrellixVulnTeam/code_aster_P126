/**
 * @file ParallelMesh.cxx
 * @brief Implementation de ParallelMeshInstance
 * @author Nicolas Sellenet
 * @section LICENCE
 *   Copyright (C) 1991 - 2019  EDF R&D                www.code-aster.org
 *
 *   This file is part of Code_Aster.
 *
 *   Code_Aster is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
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

#include "Meshes/ParallelMesh.h"
#include "ParallelUtilities/MPIInfos.h"
#include "ParallelUtilities/MPIContainerUtilities.h"
#include "Utilities/Tools.h"

#ifdef _USE_MPI

bool ParallelMeshInstance::readMedFile( const std::string &fileName ) {
    std::string completeFileName = fileName + "/" + std::to_string( getMPIRank() ) + ".med";
    BaseMeshInstance::readMedFile( completeFileName );

    CALLO_LRMJOI_WRAP( getName(), completeFileName );

    MPIContainerUtilities util;
    _groupsOfNodes->buildFromJeveux();
    auto gONNames = _groupsOfNodes->getObjectNames();
    auto allgONNames = util.gatheringVectorsOnAllProcs( gONNames );

    for ( auto &nameOfGrp : allgONNames )
        _setOfAllGON.insert( trim( nameOfGrp.toString() ) );
    _allGroupOfNodes->allocate( Permanent, _setOfAllGON.size() );
    int num = 0;
    for ( auto &nameOfGrp : _setOfAllGON ) {
        ( *_allGroupOfNodes )[num] = nameOfGrp;
        ++num;
    }

    _groupsOfElements->buildFromJeveux();
    auto gOENames = _groupsOfElements->getObjectNames();
    auto allgOENames = util.gatheringVectorsOnAllProcs( gOENames );

    for ( auto &nameOfGrp : allgOENames )
        _setOfAllGOE.insert( trim( nameOfGrp.toString() ) );
    _allGroupOfEements->allocate( Permanent, _setOfAllGOE.size() );
    num = 0;
    for ( auto &nameOfGrp : _setOfAllGOE ) {
        ( *_allGroupOfEements )[num] = nameOfGrp;
        ++num;
    }

    return true;
};

#endif /* _USE_MPI */
