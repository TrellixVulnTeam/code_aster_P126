#ifndef LINEARSOLVER_H_
#define LINEARSOLVER_H_

/**
 * @file LinearSolver.h
 * @brief Fichier entete de la classe LinearSolver
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

#include <list>
#include <set>
#include <string>

#include "DataFields/FieldOnNodes.h"
#include "LinearAlgebra/AllowedLinearSolver.h"

using namespace std;

/* person_in_charge: nicolas.sellenet at edf.fr */

// Ces wrappers sont la pour autoriser que les set soitent const
// Sinon, on aurait pas pu passer directement des const set<> en parametre template
/**
 * @struct WrapMultFront
 * @brief Structure destinee a contenir les renumeroteurs autorises pour MultFront
 */
struct WrapMultFront
{
    static const set< Renumbering > setOfAllowedRenumbering;
};

/**
 * @struct WrapLdlt
 * @brief Structure destinee a contenir les renumeroteurs autorises pour Ldlt
 */
struct WrapLdlt
{
    static const set< Renumbering > setOfAllowedRenumbering;
};

/**
 * @struct WrapMumps
 * @brief Structure destinee a contenir les renumeroteurs autorises pour Mumps
 */
struct WrapMumps
{
    static const set< Renumbering > setOfAllowedRenumbering;
};

/**
 * @struct WrapPetsc
 * @brief Structure destinee a contenir les renumeroteurs autorises pour Petsc
 */
struct WrapPetsc
{
    static const set< Renumbering > setOfAllowedRenumbering;
};

/**
 * @struct WrapGcpc
 * @brief Structure destinee a contenir les renumeroteurs autorises pour Gcpc
 */
struct WrapGcpc
{
    static const set< Renumbering > setOfAllowedRenumbering;
};

/**
 * @struct RenumberingChecker
 * @brief Struct statiquepermetant de verifier si un renumeroteur est autorise
         pour un solveur donne
 * @author Nicolas Sellenet
 */
template< class Wrapping >
struct RenumberingChecker
{
    static bool isAllowedRenumbering( Renumbering test )
    {
        if ( Wrapping::setOfAllowedRenumbering.find( test ) == Wrapping::setOfAllowedRenumbering.end() )
            return false;
        return true;
    }
};

/** @typedef Definition du verificateur de renumeroteur pour MultFront */
typedef RenumberingChecker< WrapMultFront > MultFrontRenumberingChecker;
/** @typedef Definition du verificateur de renumeroteur pour Ldlt */
typedef RenumberingChecker< WrapLdlt > LdltRenumberingChecker;
/** @typedef Definition du verificateur de renumeroteur pour Mumps */
typedef RenumberingChecker< WrapMumps > MumpsRenumberingChecker;
/** @typedef Definition du verificateur de renumeroteur pour Petsc */
typedef RenumberingChecker< WrapPetsc > PetscRenumberingChecker;
/** @typedef Definition du verificateur de renumeroteur pour Gcpc */
typedef RenumberingChecker< WrapGcpc > GcpcRenumberingChecker;

/**
 * @struct SolverChecker
 * @brief permet de verifier si un couple solveur, renumeroteur est autorise
 * @author Nicolas Sellenet
 */
struct SolverChecker
{
    /**
     * @brief Fonction statique qui verifie un couple solveur, renumeroteur
     * @param solver Type de solveur
     * @param renumber Type de renumeroteur
     * @return vrai si le couple est valide
     */
    static bool isAllowedRenumberingForSolver( LinearSolverEnum solver, Renumbering renumber )
    {
        switch ( solver )
        {
            case MultFront:
                return MultFrontRenumberingChecker::isAllowedRenumbering( renumber );
            case Ldlt:
                return LdltRenumberingChecker::isAllowedRenumbering( renumber );
            case Mumps:
                return MumpsRenumberingChecker::isAllowedRenumbering( renumber );
            case Petsc:
                return PetscRenumberingChecker::isAllowedRenumbering( renumber );
            case Gcpc:
                return GcpcRenumberingChecker::isAllowedRenumbering( renumber );
            default:
                throw "Not a valid linear solver";
        }
    };
};

template< class tmp > class AssemblyMatrix;
typedef AssemblyMatrix< double > AssemblyMatrixDouble;

/**
 * @class LinearSolverInstance
 * @brief Cette classe permet de definir un solveur lineraire
 * @author Nicolas Sellenet
 */
class LinearSolverInstance
{
    private:
        /** @brief Type du solveur lineaire */
        LinearSolverEnum _linearSolver;
        /** @brief Type du renumeroteur */
        Renumbering      _renumber;

    public:
        /**
         * @brief Constructeur
         * @param currentLinearSolver Type de solveur
         * @param currentRenumber Type de renumeroteur
         * @todo recuperer le code retour de isAllowedRenumberingForSolver
         */
        LinearSolverInstance( const LinearSolverEnum currentLinearSolver,
                              const Renumbering currentRenumber ):
                    _linearSolver( currentLinearSolver ),
                    _renumber( currentRenumber )
        {
            SolverChecker::isAllowedRenumberingForSolver( currentLinearSolver, currentRenumber );
        };

        /**
         * @brief Recuperer le nom du solveur
         * @return chaine contenant le nom Aster du solveur
         */
        const string getSolverName() const
        {
            return LinearSolverNames[ (int)_linearSolver ];
        };

        /**
         * @brief Recuperer le nom du renumeroteur
         * @return chaine contenant le nom Aster du renumeroteur
         */
        const string getRenumburingName() const
        {
            return RenumberingNames[ (int)_renumber ];
        };

        /**
         * @brief Inversion du systeme lineaire
         * @param currentMatrix Matrice assemblee
         * @param currentRHS Second membre
         * @return champ aux noeuds resultat
         */
        FieldOnNodesPtrDouble solveDoubleLinearSystem( const AssemblyMatrixDouble& currentMatrix,
                                                    const FieldOnNodesPtrDouble& currentRHS ) const;
};

/**
 * @class LinearSolver
 * @brief Enveloppe d'un pointeur intelligent vers un LinearSolverInstance
 * @author Nicolas Sellenet
 */
class LinearSolver
{
    public:
        typedef boost::shared_ptr< LinearSolverInstance > LinearSolverPtr;

    private:
        LinearSolverPtr _linearSolverPtr;

    public:
        LinearSolver(): _linearSolverPtr()
        {};

        LinearSolver( const LinearSolverEnum currentLinearSolver,
                      const Renumbering currentRenumber ): _linearSolverPtr()
        {
            _linearSolverPtr = LinearSolverPtr( new LinearSolverInstance( currentLinearSolver,
                                                                          currentRenumber ) );
        };

        ~LinearSolver()
        {};

        LinearSolver& operator=(const LinearSolver& tmp)
        {
            _linearSolverPtr = tmp._linearSolverPtr;
            return *this;
        };

        const LinearSolverPtr& operator->() const
        {
            return _linearSolverPtr;
        };

        LinearSolverInstance& operator*(void) const
        {
            return *_linearSolverPtr;
        };

        bool isEmpty() const
        {
            if ( _linearSolverPtr.use_count() == 0 ) return true;
            return false;
        };
};

#endif /* LINEARSOLVER_H_ */
