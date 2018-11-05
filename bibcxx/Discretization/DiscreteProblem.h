#ifndef DISCRETEPROBLEM_H_
#define DISCRETEPROBLEM_H_

/**
 * @file DiscreteProblem.h
 * @brief Fichier entete de la classe DiscreteProblem
 * @author Nicolas Sellenet
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

/* person_in_charge: nicolas.sellenet at edf.fr */

#include "astercxx.h"

#include <vector>

#include "Discretization/DOFNumbering.h"
#include "LinearAlgebra/ElementaryMatrix.h"
#include "LinearAlgebra/ElementaryVector.h"
#include "Studies/StudyDescription.h"

/**
 * @class DiscreteProblemInstance
 * @brief Cette classe permet de definir une étude au sens Aster
 * @author Nicolas Sellenet
 */
class DiscreteProblemInstance {
  private:
    /** @brief Etude definie par l'utilisateur */
    StudyDescriptionPtr _study;

    /**
     * @brief Production d'un CommandSyntax pour CALC_MATR_ELEM
     */
    SyntaxMapContainer computeMatrixSyntax( const std::string &optionName );

    /**
     * @brief Calcul des matrices elementaires pour une option quelconque
     */
    ElementaryMatrixDisplacementDoublePtr
    computeMechanicalMatrix( const std::string &optionName ) throw( std::runtime_error );

  public:
    /**
     * @typedef DiscreteProblemPtr
     * @brief Pointeur intelligent vers un DiscreteProblem
     */
    typedef boost::shared_ptr< DiscreteProblemInstance > DiscreteProblemPtr;

    /**
     * @brief Constructeur
     * @param StudyDescriptionPtr Etude utilisateur
     */
    DiscreteProblemInstance( const StudyDescriptionPtr &currentStudy ) : _study( currentStudy ){};

    /**
     * @brief Desctructeur
     */
    ~DiscreteProblemInstance(){};

    /**
     * @brief Calcul des matrices elementaires pour l'option CHAR_MECA
     */
    ElementaryVectorPtr buildElementaryMechanicalLoadsVector() throw( std::runtime_error );

    /**
     * @brief Fonction permettant de calculer les vecteurs élémentaires pour les
              chargements de Dirichlet
     * @param time Instant de calcul
     * @return Vecteur élémentaire
     */
    ElementaryVectorPtr buildElementaryDirichletVector( double time = 0. );

    /**
     * @brief Fonction permettant de calculer les vecteurs élémentaires pour les
              forces de Laplace
     * @return Vecteur élémentaire
     */
    ElementaryVectorPtr buildElementaryLaplaceVector();

    /**
     * @brief Fonction permettant de calculer les vecteurs élémentaires pour les
              chargements de Neumann
     * @param time Instants de calcul (vecteur de longueur 3 : instant courant, deltat, paramètre
     theta
     * @return Vecteur élémentaire
     */
    ElementaryVectorPtr
    buildElementaryNeumannVector( const VectorDouble time ) throw( std::runtime_error );

    /**
     * @brief Fonction permettant de calculer les matrices élémentaires de rigidité
     * @param time Instant de calcul
     * @return Vecteur élémentaire contenant la rigidité mécanique
     */
    ElementaryMatrixDisplacementDoublePtr buildElementaryStiffnessMatrix( double time = 0. );
    /**
     * @brief Fonction permettant de calculer les matrices élémentaires pour la matrice tangente
     * utilisée pour l'étape de prédiction de la méthode de Newton
     * @param time Instant de calcul
     * @return Matrice élémentaire contenant la rigidité mécanique
     */
    ElementaryMatrixDisplacementDoublePtr buildElementaryTangentMatrix( double time = 0. );

    ElementaryMatrixDisplacementDoublePtr buildElementaryJacobianMatrix( double time = 0. );

    /**
     * @brief Construction d'un vecteur de chargement cinématique
     * @return Booleen indiquant que tout s'est bien passe
     */
    FieldOnNodesDoublePtr buildKinematicsLoad( const BaseDOFNumberingPtr &curDOFNum,
                                               const double &time,
                                               const JeveuxMemory &memType = Permanent ) const
        throw( std::runtime_error );

    /**
     * @brief Détermination de la numérotation de ddl
     * @return Numérotation du problème discret
     */
    BaseDOFNumberingPtr
    computeDOFNumbering( BaseDOFNumberingPtr dofNum = BaseDOFNumberingPtr( nullptr ) );

    /**
     * @brief Calcul des matrices elementaires pour l'option AMOR_MECA
     */
    ElementaryMatrixDisplacementDoublePtr
    computeMechanicalDampingMatrix( const ElementaryMatrixDisplacementDoublePtr &rigidity,
                                    const ElementaryMatrixDisplacementDoublePtr &mass )
        throw( std::runtime_error );

    /**
     * @brief Calcul des matrices elementaires pour l'option RIGI_MECA
     */
    ElementaryMatrixDisplacementDoublePtr computeMechanicalStiffnessMatrix()
        throw( std::runtime_error );

    /**
     * @brief Calcul des matrices elementaires pour l'option MASS_MECA
     */
    ElementaryMatrixDisplacementDoublePtr computeMechanicalMassMatrix()
        throw( std::runtime_error );

    /**
     * @brief Récupération de l'étude
     * @return Numérotation du problème discret
     */
    StudyDescriptionPtr getStudyDescription() { return _study; };
};

/**
 * @typedef DiscreteProblemPtr
 * @brief Pointeur intelligent vers un DiscreteProblem
 */
typedef boost::shared_ptr< DiscreteProblemInstance > DiscreteProblemPtr;

#endif /* DISCRETEPROBLEM_H_ */
