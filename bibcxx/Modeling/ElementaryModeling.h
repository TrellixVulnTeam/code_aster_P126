#ifndef ELEMENTARYMODELISATION_H_
#define ELEMENTARYMODELISATION_H_

/**
 * @file ElementaryModeling.h
 * @brief Fichier entete de la classe ElementaryModeling
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

#include "astercxx.h"
#include "Modeling/AuthorizedModelings.h"
#include <string>

using namespace std;

/**
 * @class ElementaryModellisation
 * @brief Element de base d'un modele, c'est une paire PHYSIQUE, MODELISATION
 * @author Nicolas Sellenet
 */
class ElementaryModeling
{
    private:
        /** @brief Physique de la modelisation elementaire */
        Physics       _physic;
        /** @brief Modelisation de la modelisation elementaire */
        Modelings _modelisation;

    public:
        /**
         * @brief Constructeur
         * @param phys Physique
         * @param mod Modelisation
         */
        ElementaryModeling( const Physics phys, const Modelings mod ): _physic(phys),
                                                                       _modelisation(mod)
        {
            bool retour = PhysicsChecker::isAllowedModelingForPhysics( phys, mod );
            if ( ! retour )
                throw string( PhysicNames[_physic] ) + " with " + ModelingNames[_modelisation] + " not allowed";
        };

        /**
         * @brief Recuperation de la chaine modelisation
         * @return chaine de caracteres
         */
        const string getModeling() const
        {
            return ModelingNames[_modelisation];
        };

        /**
         * @brief Recuperation de la chaine physics
         * @return chaine de caracteres
         */
        const string getPhysic() const
        {
            return PhysicNames[_physic];
        };
};

#endif /* ELEMENTARYMODELISATION_H_ */
