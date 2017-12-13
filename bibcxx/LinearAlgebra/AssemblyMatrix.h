#ifndef ASSEMBLYMATRIX_H_
#define ASSEMBLYMATRIX_H_

/**
 * @file AssemblyMatrix.h
 * @brief Fichier entete de la classe AssemblyMatrix
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

#include <stdexcept>
#include <list>

#include "astercxx.h"
#include "aster_fort.h"

#include "DataStructures/DataStructure.h"
#include "MemoryManager/JeveuxVector.h"
#include "MemoryManager/JeveuxCollection.h"
#include "LinearAlgebra/ElementaryMatrix.h"
#include "Loads/ListOfLoads.h"
#include "Supervis/CommandSyntax.h"
#include "Utilities/Tools.h"
#ifdef _HAVE_PETSC4PY
#if _HAVE_PETSC4PY == 1
#include <petscmat.h>
#endif
#endif

#include "Discretization/DOFNumbering.h"
#include "Discretization/ParallelDOFNumbering.h"
#include "Loads/PhysicalQuantity.h"

class BaseLinearSolverInstance;

/**
 * @class AssemblyMatrixInstance
 * @brief Classe template definissant une sd_matr_asse.
 *        Cette classe est volontairement succinte car on n'en connait pas encore l'usage
 * @author Nicolas Sellenet
 * @todo revoir le template pour prendre la grandeur en plus
 */
template< class ValueType, PhysicalQuantityEnum PhysicalQuantity >
class AssemblyMatrixInstance: public DataStructure
{
    private:
        /** @typedef std::list de KinematicsLoad */
        typedef std::list< KinematicsLoadPtr > ListKinematicsLoad;
        /** @typedef Iterateur sur une std::list de KinematicsLoad */
        typedef ListKinematicsLoad::iterator ListKinematicsLoadIter;

        /** @brief Objet Jeveux '.REFA' */
        JeveuxVectorChar24            _description;
        /** @brief Collection '.VALM' */
        JeveuxCollection< ValueType > _matrixValues;
        /** @brief Objet '.CONL' */
        JeveuxVectorDouble            _scaleFactorLagrangian;
        /** @brief ElementaryMatrix sur lesquelles sera construit la matrice */
        std::vector< ElementaryMatrixPtr > _elemMatrix;
        /** @brief Objet nume_ddl */
        BaseDOFNumberingPtr           _dofNum;
        /** @brief La matrice est elle vide ? */
        bool                          _isEmpty;
        /** @brief La matrice est elle vide ? */
        bool                          _isFactorized;
        /** @brief Liste de charges cinematiques */
        ListOfLoadsPtr                _listOfLoads;

        friend class BaseLinearSolverInstance;

    public:
        /**
         * @typedef AssemblyMatrixPtr
         * @brief Pointeur intelligent vers un AssemblyMatrix
         */
        typedef boost::shared_ptr< AssemblyMatrixInstance<ValueType, PhysicalQuantity> > AssemblyMatrixPtr;

        /**
         * @brief Constructeur
         */
        AssemblyMatrixInstance( const JeveuxMemory memType = Permanent );
        /**
         * @brief Constructeur
         */
        AssemblyMatrixInstance( const std::string& name );

        /**
         * @brief Destructeur
         */
        ~AssemblyMatrixInstance()
        {
#ifdef __DEBUG_GC__
            std::cout << "AssemblyMatrixInstance.destr: " << this->getName() << std::endl;
#endif
        };

        /**
         * @brief Function d'ajout d'un chargement
         * @param Args... Liste d'arguments template
         */
        template< typename... Args >
        void addLoad( const Args&... a )
        {
            _listOfLoads->addLoad( a... );
        };

        /**
         * @brief Assemblage de la matrice
         */
        bool build() throw ( std::runtime_error );

        /**
         * @brief Factorisation de la matrice
         * @return true
        */
        bool factorization() throw ( std::runtime_error );

        /**
         * @brief Get the internal DOFNumbering
         * @return Internal DOFNumbering
         */
        BaseDOFNumberingPtr getDOFNumbering() const
        {
            return _dofNum;
        };

#ifdef _HAVE_PETSC4PY
#if _HAVE_PETSC4PY == 1
        /**
         * @brief Conversion to petsc4py
         * @return converted matrix
        */
        Mat toPetsc4py() throw ( std::runtime_error );
#endif
#endif

        /**
         * @brief Methode permettant de savoir si la matrice est vide
         * @return true si vide
         */
        bool isEmpty() const
        {
            return (!_description->exists());
        };

        /**
         * @brief Methode permettant de savoir si la matrice est vide
         * @return true si vide
         */
        bool isFactorized() const
        {
            return _isFactorized;
        };

        /**
         * @brief Methode permettant de definir la numerotation
         * @param currentNum objet DOFNumbering
         */
        void setDOFNumbering( const BaseDOFNumberingPtr& currentNum )
        {
            _dofNum = currentNum;
        };

        /**
         * @brief Methode permettant de definir la numerotation
         * @param currentNum objet ParallelDOFNumbering
         */
#ifdef _USE_MPI
//         void setDOFNumbering( const ParallelDOFNumberingPtr& currentNum )
//         {
//             _dofNum = currentNum;
//         };
#endif /* _USE_MPI */

        /**
         * @brief Methode permettant de definir les matrices elementaires
         * @param currentElemMatrix objet ElementaryMatrix
         */
        void appendElementaryMatrix( const ElementaryMatrixPtr& currentElemMatrix )
        {
            _elemMatrix.push_back( currentElemMatrix );
        };

        /**
         * @brief Clear all ElementaryMatrixPtr
         */
        void clearElementaryMatrix()
        {
            _elemMatrix.clear();
        };

        /**
         * @brief Methode permettant de definir la liste de chargement
         * @param lLoads objet de type ListOfLoadsPtr
         */
        void setListOfLoads( const ListOfLoadsPtr& lLoads )
        {
            _listOfLoads = lLoads;
        };
};

/** @typedef Definition d'une matrice assemblee de double */
template class AssemblyMatrixInstance< double, Displacement >;
typedef AssemblyMatrixInstance< double, Displacement > AssemblyMatrixDoubleInstance;
/** @typedef Definition d'une matrice assemblee de complexe */
typedef AssemblyMatrixInstance< DoubleComplex, Displacement > AssemblyMatrixComplexInstance;

/** @typedef Definition d'une matrice assemblee de double temperature */
template class AssemblyMatrixInstance< double, Temperature >;
typedef AssemblyMatrixInstance< double, Temperature > AssemblyMatrixTemperatureDoubleInstance;

typedef boost::shared_ptr< AssemblyMatrixDoubleInstance > AssemblyMatrixDoublePtr;
typedef boost::shared_ptr< AssemblyMatrixComplexInstance > AssemblyMatrixComplexPtr;
typedef boost::shared_ptr< AssemblyMatrixTemperatureDoubleInstance > AssemblyMatrixTemperatureDoublePtr;

template< class ValueType, PhysicalQuantityEnum PhysicalQuantity >
AssemblyMatrixInstance< ValueType, PhysicalQuantity >::AssemblyMatrixInstance( const JeveuxMemory memType ):
    DataStructure( "MATR_ASSE_" + std::string(PhysicalQuantityNames[PhysicalQuantity]) + "_R", memType, 19 ),
    _description( JeveuxVectorChar24( getName() + ".REFA" ) ),
    _matrixValues( JeveuxCollection< ValueType >( getName() + ".VALM" ) ),
    _scaleFactorLagrangian( JeveuxVectorDouble( getName() + ".CONL" ) ),
    _isEmpty( true ),
    _isFactorized( false ),
    _listOfLoads( ListOfLoadsPtr( new ListOfLoadsInstance( memType ) ) )
{};

template< class ValueType, PhysicalQuantityEnum PhysicalQuantity >
AssemblyMatrixInstance< ValueType, PhysicalQuantity >::AssemblyMatrixInstance( const std::string& name ):
    DataStructure( name, 19, "MATR_ASSE_" + std::string(PhysicalQuantityNames[PhysicalQuantity]) + "_R" ),
    _description( JeveuxVectorChar24( getName() + ".REFA" ) ),
    _matrixValues( JeveuxCollection< ValueType >( getName() + ".VALM" ) ),
    _scaleFactorLagrangian( JeveuxVectorDouble( getName() + ".CONL" ) ),
    _isEmpty( true ),
    _isFactorized( false ),
    _listOfLoads( ListOfLoadsPtr( new ListOfLoadsInstance() ) )
{};

template< class ValueType, PhysicalQuantityEnum PhysicalQuantity >
bool AssemblyMatrixInstance< ValueType, PhysicalQuantity >::build() throw ( std::runtime_error )
{
    if ( _dofNum->isEmpty() )
        throw std::runtime_error( "Numbering is empty" );

    if ( _elemMatrix.size() == 0 )
        throw std::runtime_error( "Elementary matrix is empty" );

    long typscal = 1;
    VectorString names;
    std::vector< ElementaryMatrixPtr >::const_iterator elemIt = _elemMatrix.begin();
    for ( ; elemIt != _elemMatrix.end(); ++elemIt ) {
        names.push_back( (*elemIt)->getName() );
        if ( (*elemIt)->getType() != "MATR_ELEM_DEPL_R" ) {
            typscal = -1;
        }
    }
    if ( typscal < 0 ) {
        throw std::runtime_error( "Only MATR_ASSE_DEPL_R is currently supported." );
    }
    char *tabNames = vectorStringAsFStrArray( names, 8 );

    std::string base( "G" );
    std::string blanc( " " );
    std::string cumul( "ZERO" );
    if( _listOfLoads->isEmpty() && _listOfLoads->size() != 0 )
        _listOfLoads->build();
    long nbMatrElem = 1;
    CALL_ASMATR( &nbMatrElem, tabNames, blanc.c_str(),
                 _dofNum->getName().c_str(), _listOfLoads->getName().c_str(),
                 cumul.c_str(), base.c_str(), &typscal, getName().c_str() );
    _isEmpty = false;
    FreeStr( tabNames );

    return true;
};

#ifdef _HAVE_PETSC4PY
#if _HAVE_PETSC4PY == 1

template< class ValueType, PhysicalQuantityEnum PhysicalQuantity >
Mat AssemblyMatrixInstance< ValueType, PhysicalQuantity >::toPetsc4py() throw ( std::runtime_error )
{
    Mat myMat;
    PetscErrorCode ierr;

    if ( _isEmpty )
        throw std::runtime_error( "Assembly matrix is empty" );
    if ( getType() != "MATR_ASSE_DEPL_R" ) throw std::runtime_error( "Not yet implemented" );

    CALLO_MATASS2PETSC( getName(), &myMat, &ierr );

    return myMat;
};
#endif
#endif

template< class ValueType, PhysicalQuantityEnum PhysicalQuantity >
bool AssemblyMatrixInstance< ValueType, PhysicalQuantity >::factorization() throw ( std::runtime_error )
{
    if ( _isEmpty )
        throw std::runtime_error( "Assembly matrix is empty" );

    CommandSyntax cmdSt( "FACTORISER" );
    cmdSt.setResult( getName(), getType() );

    SyntaxMapContainer dict;
    // !!! Rajouter un if MUMPS !!!
    dict.container[ "MATR_ASSE" ] = getName();
    dict.container[ "ELIM_LAGR" ] = "LAGR2";
    dict.container[ "TYPE_RESOL" ] = "AUTO";
    dict.container[ "PRETRAITEMENTS" ] = "AUTO";
    dict.container[ "PCENT_PIVOT" ] = 20;
    dict.container[ "GESTION_MEMOIRE" ] = "IN_CORE";
    dict.container[ "REMPLISSAGE" ] = 1.0;
    dict.container[ "NIVE_REMPLISSAGE" ] = 0;
    dict.container[ "STOP_SINGULIER" ] = "OUI";
    dict.container[ "PRE_COND" ] = "LDLT_INC";
    dict.container[ "NPREC" ] = 8;
    cmdSt.define( dict );

    try
    {
        ASTERINTEGER op = 14;
        CALL_EXECOP( &op );
    }
    catch( ... )
    {
        throw;
    }
    _isEmpty = false;
    _isFactorized = true;

    return true;
};

#endif /* ASSEMBLYMATRIX_H_ */
