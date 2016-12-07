#ifndef FOURIERCOMBINATION_H_
#define FOURIERCOMBINATION_H_

/**
 * @file FourierCombination.h
 * @brief Fichier entete de la classe FourierCombination
 * @author Nicolas Sellenet
 * @section LICENCE
 *   Copyright (C) 1991 - 2016  EDF R&D                www.code-aster.org
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

#include "astercxx.h"

#include "Results/ResultsContainer.h"


/**
 * @class FourierCombinationInstance
 * @brief Cette classe correspond a un comb_fourier
 * @author Nicolas Sellenet
 */
class FourierCombinationInstance: public ResultsContainerInstance
{
    public:
        /**
         * @brief Constructeur
         */
        FourierCombinationInstance( const std::string resuTyp = "COMB_FOURIER" ): 
            ResultsContainerInstance( resuTyp )
        {};

};

/**
 * @typedef FourierCombinationPtr
 * @brief Pointeur intelligent vers un FourierCombinationInstance
 */
typedef boost::shared_ptr< FourierCombinationInstance > FourierCombinationPtr;

#endif /* FOURIERCOMBINATION_H_ */
