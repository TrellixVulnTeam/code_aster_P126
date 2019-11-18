#ifndef FIELDONNODESSHAPE_H_
#define FIELDONNODESSHAPE_H_

/**
 * @file FieldOnNodesShape.h
 * @brief Fichier entete de la classe FieldOnNodesShape
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

#include <stdexcept>
#include "astercxx.h"
#include <string>

#include "DataStructures/DataStructure.h"
#include "MemoryManager/JeveuxVector.h"

/**
 * @class FieldOnNodesShapeInstance
 * @brief Class definissant un prof_chno
 * @author Nicolas Sellenet
 */
class FieldOnNodesShapeInstance : public DataStructure {
  private:
  public:
    /**
     * @brief Constructeur
     */
    FieldOnNodesShapeInstance() : DataStructure( "", Permanent, 8 ){};

    /**
     * @typedef FieldOnNodesShapePtr
     * @brief Pointeur intelligent vers un FieldOnNodesShape
     */
    typedef boost::shared_ptr< FieldOnNodesShapeInstance > FieldOnNodesShapePtr;
};

/**
 * @typedef FieldOnNodesShapePtr
 * @brief Enveloppe d'un pointeur intelligent vers un FieldOnNodesShapeInstance
 * @author Nicolas Sellenet
 */
typedef boost::shared_ptr< FieldOnNodesShapeInstance > FieldOnNodesShapePtr;

#endif /* FIELDONNODESSHAPE_H_ */
