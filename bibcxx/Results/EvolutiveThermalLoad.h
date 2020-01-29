#ifndef EVOLUTIVETHERMALLOAD_H_
#define EVOLUTIVETHERMALLOAD_H_

/**
 * @file EvolutiveThermalLoad.h
 * @brief Fichier entete de la classe EvolutiveThermalLoad
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

/* person_in_charge: natacha.bereux at edf.fr */

#include "astercxx.h"

#include "Results/TimeDependantResultsContainer.h"
#include "Supervis/ResultNaming.h"

/**
 * @class EvolutiveThermalLoadClass
 * @brief Cette classe correspond a un evol_ther
 * @author Nicolas Sellenet
 */
class EvolutiveThermalLoadClass : public TimeDependantResultsContainerClass {
  public:
    /**
     * @brief Constructeur
     */
    EvolutiveThermalLoadClass( const std::string name = ResultNaming::getNewResultName() )
        : TimeDependantResultsContainerClass( name, "EVOL_THER" ){};
};

/**
 * @typedef EvolutiveThermalLoadPtr
 * @brief Pointeur intelligent vers un EvolutiveThermalLoadClass
 */
typedef boost::shared_ptr< EvolutiveThermalLoadClass > EvolutiveThermalLoadPtr;

#endif /* EVOLUTIVETHERMALLOAD_H_ */
