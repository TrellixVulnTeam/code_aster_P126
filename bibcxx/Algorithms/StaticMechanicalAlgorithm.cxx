/**
 * @file StaticMechanicalAlgorithm.cxx
 * @brief Implementation de StaticMechanicalAlgorithm
 * @author Nicolas Sellenet
 * @section LICENCE
 *   Copyright (C) 1991 - 2015  EDF R&D                www.code-aster.org
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

#include "MemoryManager/JeveuxVector.h"
#include "Algorithms/StaticMechanicalAlgorithm.h"
#include "DataFields/FieldOnNodes.h"
#include "LinearAlgebra/ElementaryMatrix.h"
#include "LinearAlgebra/ElementaryVector.h"
#include "LinearAlgebra/AssemblyMatrix.h"
#include "LinearAlgebra/LinearSolver.h"
#include "Discretization/DOFNumbering.h"
#include "Loads/ListOfLoads.h"
#include "RunManager/CommandSyntaxCython.h"

/* person_in_charge: nicolas.sellenet at edf.fr */
