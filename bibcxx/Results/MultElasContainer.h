#ifndef MULTELASCONTAINER_H_
#define MULTELASCONTAINER_H_

/**
 * @file MultElasContainer.h
 * @brief Fichier entete de la classe MultElasContainer
 * @author Natacha Béreux
 * @section LICENCE
 *   Copyright (C) 1991 - 2018  EDF R&D                www.code-aster.org
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

#include "astercxx.h"

#include "Results/ResultsContainer.h"
#include "Supervis/ResultNaming.h"

/**
 * @class MultElasContainerInstance
 * @brief Cette classe correspond a un mode_meca
 * @author Nicolas Sellenet
 */
class MultElasContainerInstance : public ResultsContainerInstance {
  private:
  public:
    /**
     * @brief Constructeur
     */
    MultElasContainerInstance( const std::string name = ResultNaming::getNewResultName() )
        : ResultsContainerInstance( name, "MULT_ELAS" ){};
};

/**
 * @typedef MultElasContainerPtr
 * @brief Pointeur intelligent vers un MultElasContainerInstance
 */
typedef boost::shared_ptr< MultElasContainerInstance > MultElasContainerPtr;

#endif /* MULTELASCONTAINER_H_ */
