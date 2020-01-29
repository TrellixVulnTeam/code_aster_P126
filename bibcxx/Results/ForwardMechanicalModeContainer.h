#ifndef FORWARDMECHANICALMODECONTAINER_H_
#define FORWARDMECHANICALMODECONTAINER_H_

/**
 * @file ForwardMechanicalModeContainer.h
 * @brief Fichier entete de la classe ForwardMechanicalModeContainer
 * @author Nicolas Sellenet
 * @section LICENCE
 *   Copyright (C) 1991 - 2020  EDF R&D                www.code-aster.org
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

#include "astercxx.h"

class MechanicalModeContainerClass;
typedef boost::shared_ptr< MechanicalModeContainerClass > MechanicalModeContainerPtr;

/**
 * @class ForwardMechanicalModeContainerPtr
 * @brief Forward definition of MechanicalModeContainerPtr
 * @author Nicolas Sellenet
 */
class ForwardMechanicalModeContainerPtr {
  private:
    /** @brief Pointer to MechanicalModeContainerClass */
    MechanicalModeContainerPtr _ptr;
    bool _isSet;

  public:
    /**
     * @brief Constructor
     */
    ForwardMechanicalModeContainerPtr();

    /**
     * @brief Constructor
     */
    ForwardMechanicalModeContainerPtr( const MechanicalModeContainerPtr &ptr );

    void operator=( const MechanicalModeContainerPtr &ptr );

    MechanicalModeContainerPtr getPointer();

    bool isSet() const;

    void setPointer( const MechanicalModeContainerPtr &ptr );
};

#endif /* FORWARDMECHANICALMODECONTAINER_H_ */
