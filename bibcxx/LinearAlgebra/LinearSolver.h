#ifndef LINEARSOLVER_H_
#define LINEARSOLVER_H_

/**
 * @file LinearSolver.h
 * @brief Fichier entete de la classe LinearSolver
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

#include <stdexcept>
#include <list>
#include <set>
#include <string>

#include "astercxx.h"
#include "DataFields/FieldOnNodes.h"
#include "LinearAlgebra/AllowedLinearSolver.h"
#include "LinearAlgebra/AssemblyMatrix.h"
#include "DataStructures/DataStructure.h"
#include "MemoryManager/JeveuxVector.h"
#include "Utilities/GenericParameter.h"
#include "Supervis/ResultNaming.h"

/* person_in_charge: nicolas.sellenet at edf.fr */

// Ces wrappers sont la pour autoriser que les set soient const
// Sinon, on aurait pas pu passer directement des const set<> en parametre template
/**
 * @struct WrapMultFront
 * @brief Structure destinee a contenir les renumeroteurs autorises pour MultFront
 */
struct WrapMultFront
{
    static const LinearSolverEnum solverType = MultFront;
    static const std::set< Renumbering > setOfAllowedRenumbering;
    static const bool isHPCCompliant = false;
    static const Renumbering defaultRenumbering = Metis;
};

/**
 * @struct WrapLdlt
 * @brief Structure destinee a contenir les renumeroteurs autorises pour Ldlt
 */
struct WrapLdlt
{
    static const LinearSolverEnum solverType = Ldlt;
    static const std::set< Renumbering > setOfAllowedRenumbering;
    static const bool isHPCCompliant = false;
    static const Renumbering defaultRenumbering = RCMK;
};

/**
 * @struct WrapMumps
 * @brief Structure destinee a contenir les renumeroteurs autorises pour Mumps
 */
struct WrapMumps
{
    static const LinearSolverEnum solverType = Mumps;
    static const std::set< Renumbering > setOfAllowedRenumbering;
    static const bool isHPCCompliant = true;
    static const Renumbering defaultRenumbering = Auto;
};

/**
 * @struct WrapPetsc
 * @brief Structure destinee a contenir les renumeroteurs autorises pour Petsc
 */
struct WrapPetsc
{
    static const LinearSolverEnum solverType = Petsc;
    static const std::set< Renumbering > setOfAllowedRenumbering;
    static const bool isHPCCompliant = true;
    static const Renumbering defaultRenumbering = Sans;
};

/**
 * @struct WrapGcpc
 * @brief Structure destinee a contenir les renumeroteurs autorises pour Gcpc
 */
struct WrapGcpc
{
    static const LinearSolverEnum solverType = Gcpc;
    static const std::set< Renumbering > setOfAllowedRenumbering;
    static const bool isHPCCompliant = false;
    static const Renumbering defaultRenumbering = Sans;
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

    static bool isHPCCompliant()
    {
        return Wrapping::isHPCCompliant;
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
 * @class BaseLinearSolverInstance
 * @brief Cette classe permet de definir un solveur lineaire
 * @author Nicolas Sellenet
 * @todo verifier que tous les mots-clés sont modifiables par des set
 */
class BaseLinearSolverInstance: public DataStructure
{
    protected:
        /** @brief Type du solveur lineaire */
        LinearSolverEnum    _linearSolver;
        /** @brief Type du renumeroteur */
        Renumbering         _renumber;
        /** @brief Le solveur est-il vide ? */
        bool                _isEmpty;
        Preconditioning     _preconditioning;

        JeveuxVectorChar24  _charValues;
        JeveuxVectorDouble  _doubleValues;
        JeveuxVectorLong    _integerValues;

        GenParam     _algo;
        GenParam     _lagr;
        GenParam     _matrFilter;
        GenParam     _memory;
        GenParam     _lowRankThreshold;
        GenParam     _lowRankSize;
        GenParam     _distMatrix;
        GenParam     _method;
        GenParam     _precision;
        GenParam     _fillingLevel;
        GenParam     _iterNumber;
        GenParam     _nPrec;
        GenParam     _pivotPourcent;
        GenParam     _postPro;
        GenParam     _precond;
        GenParam     _prePro;
        GenParam     _reac;
        GenParam     _filling;
        GenParam     _renum;
        GenParam     _residual;
        GenParam     _precondResidual;
        GenParam     _stopSingular;
        GenParam     _resolutionType;
        GenParam     _acceleration;
        ListGenParam _listOfParameters;
        AssemblyMatrixDisplacementDoublePtr _matrixPrec;

    public:
        /**
         * @typedef BaseLinearSolverPtr
         * @brief Pointeur intelligent vers un BaseLinearSolverInstance
         */
        typedef boost::shared_ptr< BaseLinearSolverInstance > BaseLinearSolverPtr;

        /**
         * @brief Constructeur
         * @param currentBaseLinearSolver Type de solveur
         * @param currentRenumber Type de renumeroteur
         * @todo recuperer le code retour de isAllowedRenumberingForSolver
         */
        BaseLinearSolverInstance( const LinearSolverEnum currentBaseLinearSolver = MultFront,
                                  const Renumbering currentRenumber = Metis ):
            BaseLinearSolverInstance( ResultNaming::getNewResultName(),
                                      currentBaseLinearSolver,
                                      currentRenumber )
        {};

        /**
         * @brief Constructeur
         * @param name Name of the DataStructure
         * @param currentBaseLinearSolver Type de solveur
         * @param currentRenumber Type de renumeroteur
         * @todo recuperer le code retour de isAllowedRenumberingForSolver
         */
        BaseLinearSolverInstance( const std::string name,
                                  const LinearSolverEnum currentBaseLinearSolver = MultFront,
                                  const Renumbering currentRenumber = Metis ):
            DataStructure( name, 19, "SOLVEUR" ),
            _linearSolver( currentBaseLinearSolver ),
            _renumber( currentRenumber ),
            _isEmpty( true ),
            _preconditioning( Without ),
            _charValues( JeveuxVectorChar24( getName() + ".SLVK" ) ),
            _doubleValues( JeveuxVectorDouble( getName() + ".SLVR" ) ),
            _integerValues( JeveuxVectorLong( getName() + ".SLVI" ) ),
            _algo( "ALGORITHME", false ),
            _lagr( "ELIM_LAGR", false ),
            _matrFilter( "FILTRAGE_MATRICE", false ),
            _memory( "GESTION_MEMOIRE", false ),
            _lowRankThreshold( "LOW_RANK_SEUIL", false ),
            _lowRankSize( "LOW_RANK_TAILLE", false ),
            _distMatrix( "MATR_DISTRIBUEE", false ),
            _method( "METHODE", false ),
            _precision( "MIXER_PRECISION", false ),
            _fillingLevel( "NIVE_REMPLISSAGE", false ),
            _iterNumber( "NMAX_ITER", false ),
            _nPrec( "NPREC", false ),
            _pivotPourcent( "PCENT_PIVOT", false ),
            _postPro( "POSTTRAITEMENTS", false ),
            _precond( "PRE_COND", false ),
            _prePro( "PRETRAITEMENTS", false ),
            _reac( "REAC_PRECOND", false ),
            _filling( "REMPLISSAGE", false ),
            _renum( "RENUM", false ),
            _residual( "RESI_RELA", false ),
            _precondResidual( "RESI_RELA_PC", false ),
            _stopSingular( "STOP_SINGULIER", false ),
            _resolutionType( "TYPE_RESOL", false ),
            _acceleration( "ACCELERATION", false ),
            _matrixPrec( new AssemblyMatrixDisplacementDoubleInstance
                            ( ResultNaming::getNewResultName() + ".PREC" ) )
        {
            _renum = RenumberingNames[ (int)_renumber ];

            _method = std::string( LinearSolverNames[ (int)_linearSolver ] );
            _lagr = "NON";
            if ( currentBaseLinearSolver == Petsc )
            {
                _algo = "FGMRES";
                _distMatrix = "NON";
                _iterNumber = (ASTERINTEGER)0;
                _preconditioning = SimplePrecisionLdlt;
                _precond = PreconditioningNames[ (int)_preconditioning ];
                _residual = 1.e-6;
                _precondResidual = -1.0;
                _reac = (ASTERINTEGER)30;
                _pivotPourcent = (ASTERINTEGER)20;
                _memory = "AUTO";
            }
            if ( currentBaseLinearSolver == Mumps )
            {
                _lagr = "LAGR2";
                _memory = "AUTO";
                _lowRankThreshold = 0.;
                _lowRankSize = -1.0;
                _distMatrix = "NON";
                _precision = "NON";
                _nPrec = (ASTERINTEGER)8;
                _pivotPourcent = (ASTERINTEGER)20;
                _postPro = "AUTO";
                _prePro = "AUTO";
                _residual = -1.0;
                _stopSingular = "OUI";
                _resolutionType = "AUTO";
                _acceleration = "AUTO";
            }
            if ( currentBaseLinearSolver == MultFront )
            {
                _nPrec = (ASTERINTEGER)8;
                _stopSingular = "OUI";
            }
            if ( currentBaseLinearSolver == Ldlt )
            {
                _nPrec = (ASTERINTEGER)8;
                _stopSingular = "OUI";
            }
            if ( currentBaseLinearSolver == Gcpc )
            {
                _iterNumber = (ASTERINTEGER)0;
                _preconditioning = IncompleteLdlt;
                _precond = PreconditioningNames[ (int)_preconditioning ];
                _residual = 1.e-6;
            }
            _listOfParameters.push_back( &_algo );
            _listOfParameters.push_back( &_lagr );
            _listOfParameters.push_back( &_matrFilter );
            _listOfParameters.push_back( &_memory );
            _listOfParameters.push_back( &_lowRankThreshold );
            _listOfParameters.push_back( &_lowRankSize );
            _listOfParameters.push_back( &_distMatrix );
            _listOfParameters.push_back( &_method );
            _listOfParameters.push_back( &_precision );
            _listOfParameters.push_back( &_fillingLevel );
            _listOfParameters.push_back( &_iterNumber );
            _listOfParameters.push_back( &_nPrec );
            _listOfParameters.push_back( &_pivotPourcent );
            _listOfParameters.push_back( &_postPro );
            _listOfParameters.push_back( &_precond );
            _listOfParameters.push_back( &_prePro );
            _listOfParameters.push_back( &_reac );
            _listOfParameters.push_back( &_filling );
            _listOfParameters.push_back( &_renum );
            _listOfParameters.push_back( &_residual );
            _listOfParameters.push_back( &_precondResidual );
            _listOfParameters.push_back( &_stopSingular );
            _listOfParameters.push_back( &_resolutionType );
            _listOfParameters.push_back( &_acceleration );
        };

        /**
         * @brief Destructor
         */
        ~BaseLinearSolverInstance()
        {};

        /** @brief Returns a ListSyntaxMapContainer object "listsyntax",
            ready to be inserted  in a CommandSyntax object with the key SOLVEUR
        */
        ListSyntaxMapContainer buildListSyntax();

        /**
         * @brief Construction de la sd_solveur
         * @return vrai si tout s'est bien passé
         */
        bool build();

        /**
         * @brief Récupération de la liste des paramètres du solveur
         * @return Liste constante des paramètres déclarés
         */
        const ListGenParam& getListOfParameters() const
        {
            return _listOfParameters;
        };

        /**
         * @brief Recuperer le précond
         * @return le type de preconditionneur
         */
        Preconditioning getPreconditioning() const
        {
            return _preconditioning;
        };

        /**
         * @brief Recuperer le nom du solveur
         * @return chaine contenant le nom Aster du solveur
         */
        const std::string getSolverName() const
        {
            return LinearSolverNames[ (int)_linearSolver ];
        };

        /**
         * @brief Recuperer le nom du renumeroteur
         * @return chaine contenant le nom Aster du renumeroteur
         */
        const std::string getRenumberingName() const
        {
            return RenumberingNames[ (int)_renumber ];
        };

        /**
         * @brief Methode permettant de savoir si la matrice est vide
         * @return true si vide
         */
        bool isEmpty()
        {
            return _isEmpty;
        };

        /**
         * @brief Methode permettant de savoir si le HPC est autorise
         * @return true si le découpage de domain est autorisé
         */
        virtual bool isHPCCompliant()
        {
            return false;
        };

        /**
         * @brief Factorisation d'une matrice
         * @param currentMatrix Matrice assemblee
         */
        bool matrixFactorization( AssemblyMatrixDisplacementDoublePtr currentMatrix )
            throw( std::runtime_error );

        /**
         * @brief Inversion du systeme lineaire
         * @param currentMatrix Matrice assemblee
         * @param kinematicsField Charge cinématique
         * @param currentRHS Second membre
         * @param result champ aux noeuds résultat (optionnel)
         * @return champ aux noeuds resultat
         */
        FieldOnNodesDoublePtr solveDoubleLinearSystem(
            const AssemblyMatrixDisplacementDoublePtr& currentMatrix,
            const FieldOnNodesDoublePtr& currentRHS,
            FieldOnNodesDoublePtr result = FieldOnNodesDoublePtr(
                new FieldOnNodesDoubleInstance( Permanent ) )
        ) const;

        /**
         * @brief Inversion du systeme lineaire
         * @param currentMatrix Matrice assemblee
         * @param kinematicsField Charge cinématique
         * @param currentRHS Second membre
         * @param result champ aux noeuds résultat (optionnel)
         * @return champ aux noeuds resultat
         */
        FieldOnNodesDoublePtr solveDoubleLinearSystemWithKinematicsLoad
            ( const AssemblyMatrixDisplacementDoublePtr& currentMatrix,
              const FieldOnNodesDoublePtr& kinematicsField,
              const FieldOnNodesDoublePtr& currentRHS,
              FieldOnNodesDoublePtr result = FieldOnNodesDoublePtr( new FieldOnNodesDoubleInstance( Permanent ) ) ) const;

        void disablePreprocessing() throw ( std::runtime_error )
        {
            if ( _linearSolver != Mumps )
                throw std::runtime_error( "Algorithm only allowed with Mumps" );
            _prePro = "SANS";
        };

        void setAcceleration( MumpsAcceleration post )
        {
            if ( _linearSolver != Mumps )
                throw std::runtime_error( "Only allowed with Mumps" );
            _acceleration = MumpsAccelerationNames[ (int)post ];
        };

        void setAlgorithm( IterativeSolverAlgorithm algo ) throw ( std::runtime_error )
        {
            if ( _linearSolver != Petsc )
                throw std::runtime_error( "Algorithm only allowed with Petsc" );
            _algo = std::string( IterativeSolverAlgorithmNames[ (int)algo ] );
        };

        void setDistributedMatrix( bool matDist ) throw ( std::runtime_error )
        {
            if ( _linearSolver != Petsc && _linearSolver != Mumps )
                throw std::runtime_error( "Distributed matrix only allowed with Mumps or Petsc" );
            if ( matDist )
                _distMatrix = "OUI";
            else
                _distMatrix = "NON";
        };

        void setErrorOnMatrixSingularity( bool error )
        {
            if ( error )
                _stopSingular = "OUI";
            else
                _stopSingular = "NON";
        };

        void setFilling( double filLevel ) throw ( std::runtime_error )
        {
            if ( _linearSolver != Petsc && _linearSolver != Gcpc )
                throw std::runtime_error( "Filling level only allowed with Gcpc or Petsc" );
            if ( _preconditioning != IncompleteLdlt )
                throw std::runtime_error( "Filling level only allowed with IncompleteLdlt" );
            _filling = filLevel;
        };

        void setFillingLevel( ASTERINTEGER filLevel ) throw ( std::runtime_error )
        {
            if ( _linearSolver != Petsc && _linearSolver != Gcpc )
                throw std::runtime_error( "Filling level only allowed with Gcpc or Petsc" );
            if ( _preconditioning != IncompleteLdlt )
                throw std::runtime_error( "Filling level only allowed with IncompleteLdlt" );
            _fillingLevel = filLevel;
        };

        void setLagrangeElimination( LagrangeTreatment lagrTreat )
        {
            _lagr = std::string( LagrangeTreatmentNames[ (int)lagrTreat ] );
        };

        void setLowRankSize( double size )
        {
            _lowRankSize = size;
        };

        void setLowRankThreshold( double threshold )
        {
            _lowRankThreshold = threshold;
        };

        void setMatrixFilter( double filter )
        {
            _matrFilter = filter;
        };

        void setMatrixType( MatrixType matType )
        {
            _resolutionType = MatrixTypeNames[ (int)matType ];
        };

        void setMaximumNumberOfIteration( ASTERINTEGER number ) throw ( std::runtime_error )
        {
            if ( _linearSolver != Petsc && _linearSolver != Gcpc )
                throw std::runtime_error( "Only allowed with Gcpc or Petsc" );
            _iterNumber = number;
        };

        void setMemoryManagement( MemoryManagement memManagt )
        {
            _memory = MemoryManagementNames[ (int)memManagt ];
        };

        void setPivotingMemory( ASTERINTEGER mem )
        {
            _pivotPourcent = mem;
        };

        void setPostTreatment( MumpsPostTreatment post )
        {
            if ( _linearSolver != Mumps )
                throw std::runtime_error( "Only allowed with Mumps" );
            _postPro = MumpsPostTreatmentNames[ (int)post ];
        };

        void setPrecisionMix( bool precMix ) throw ( std::runtime_error )
        {
            if ( _linearSolver != Petsc && _linearSolver != Mumps )
                throw std::runtime_error( "Precision mixing only allowed with Mumps or Petsc" );
            if ( precMix )
                _precision = "OUI";
            else
                _precision = "NON";
        };

        void setPreconditioning( Preconditioning precond ) throw ( std::runtime_error )
        {
            if ( _linearSolver != Petsc && _linearSolver != Gcpc )
                throw std::runtime_error( "Preconditionong only allowed with Gcpc or Petsc" );
            _preconditioning = precond;
            _precond = PreconditioningNames[ (int)_preconditioning ];
            if ( _preconditioning == IncompleteLdlt )
            {
                _fillingLevel = (ASTERINTEGER)0;
                if ( _linearSolver == Petsc )
                    _filling = 1.0;
            }
            if ( _preconditioning == SimplePrecisionLdlt )
            {
                _pivotPourcent = (ASTERINTEGER)20;
                _reac = (ASTERINTEGER)30;
                _renumber = Sans;
                _renum = std::string( RenumberingNames[ (int)Sans ] );
            }
        };

        void setPreconditioningResidual( double residual )
        {
            _precondResidual = residual;
        };

        void setRenumbering( Renumbering reum )
        {
            _renumber = reum;
        };

        void setSingularityDetectionThreshold( ASTERINTEGER nprec )
        {
            _nPrec = nprec;
        };

        void setSolverResidual( double residual )
        {
            _residual = residual;
        };

        void setUpdatePreconditioningParameter( ASTERINTEGER value ) throw ( std::runtime_error )
        {
            if ( _linearSolver != Petsc && _linearSolver != Gcpc )
                throw std::runtime_error( "Preconditionong only allowed with Gcpc or Petsc" );
            if ( _preconditioning != SimplePrecisionLdlt )
                throw std::runtime_error( "Update preconditioning parameter only allowed with IncompleteLdlt" );
            _reac = value;
        };
};

/**
 * @typedef BaseLinearSolverPtr
 * @brief Pointeur intelligent vers un BaseLinearSolverInstance
 */
typedef boost::shared_ptr< BaseLinearSolverInstance > BaseLinearSolverPtr;

/**
 * @class LinearSolverInstance
 * @brief Cette classe permet de definir un solveur lineaire
 * @author Nicolas Sellenet
 * @todo verifier que tous les mots-clés sont modifiables par des set
 */
template< typename linSolvWrap >
class LinearSolverInstance: public BaseLinearSolverInstance
{
public:
    /**
     * @typedef LinearSolverPtr
     * @brief Pointeur intelligent vers un LinearSolver
     */
    typedef boost::shared_ptr< LinearSolverInstance< linSolvWrap > > LinearSolverPtr;

    /**
     * @brief Constructeur
     */
    LinearSolverInstance( const Renumbering currentRenumber = Metis ):
        LinearSolverInstance( ResultNaming::getNewResultName() )
    {};

    LinearSolverInstance( const std::string name,
                          const Renumbering currentRenumber = Metis ):
        BaseLinearSolverInstance( name, linSolvWrap::solverType, currentRenumber )
    {
        RenumberingChecker< linSolvWrap >::isAllowedRenumbering( currentRenumber );
    };

    bool isHPCCompliant()
    {
        return RenumberingChecker< linSolvWrap >::isHPCCompliant();
    };
};

typedef LinearSolverInstance< WrapMultFront > MultFrontSolverInstance;
typedef LinearSolverInstance< WrapLdlt > LdltSolverInstance;
typedef LinearSolverInstance< WrapMumps > MumpsSolverInstance;
typedef LinearSolverInstance< WrapPetsc > PetscSolverInstance;
typedef LinearSolverInstance< WrapGcpc > GcpcSolverInstance;


/** @brief Enveloppe d'un pointeur intelligent vers un BaseLinearSolverInstance< MultFront > */
typedef boost::shared_ptr< MultFrontSolverInstance > MultFrontSolverPtr;

/** @brief Enveloppe d'un pointeur intelligent vers un BaseLinearSolverInstance< Ldlt > */
typedef boost::shared_ptr< LdltSolverInstance > LdltSolverPtr;

/** @brief Enveloppe d'un pointeur intelligent vers un BaseLinearSolverInstance< Mumps > */
typedef boost::shared_ptr< MumpsSolverInstance > MumpsSolverPtr;

/** @brief Enveloppe d'un pointeur intelligent vers un BaseLinearSolverInstance< Petsc > */
typedef boost::shared_ptr< PetscSolverInstance > PetscSolverPtr;

/** @brief Enveloppe d'un pointeur intelligent vers un BaseLinearSolverInstance< Gcpc > */
typedef boost::shared_ptr< GcpcSolverInstance > GcpcSolverPtr;

#endif /* LINEARSOLVER_H_ */
