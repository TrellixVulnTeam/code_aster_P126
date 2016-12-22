#ifndef GENERALIZEDASSEMBLYMATRIX_H_
#define GENERALIZEDASSEMBLYMATRIX_H_

/**
 * @file GeneralizedAssemblyMatrix.h
 * @brief Fichier entete de la classe GeneralizedAssemblyMatrix
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

/* person_in_charge: nicolas.sellenet at edf.fr */

#include "astercxx.h"

#include "DataStructure/DataStructure.h"
#include "MemoryManager/JeveuxVector.h"
#include "MemoryManager/JeveuxCollection.h"


/**
 * @class GenericGeneralizedAssemblyMatrixInstance
 * @brief Cette classe correspond a un matr_asse_gene
 * @author Nicolas Sellenet
 */
class GenericGeneralizedAssemblyMatrixInstance: public DataStructure
{
private:
    /** @brief Objet Jeveux '.DESC' */
    JeveuxVectorDouble _desc;
    /** @brief Objet Jeveux '.REFE' */
    JeveuxVectorChar24 _refe;

public:
    /**
     * @brief Constructeur
     */
    GenericGeneralizedAssemblyMatrixInstance(): 
        DataStructure( "MATR_ASSE_GENE", Permanent, 19 ),
        _desc( JeveuxVectorDouble( getName() + ".DISC" ) ),
        _refe( JeveuxVectorChar24( getName() + ".REFE" ) )
    {};
};

/**
 * @class GeneralizedAssemblyMatrixInstance
 * @brief Cette classe correspond a un matr_asse_gene
 * @author Nicolas Sellenet
 */
template< class ValueType >
class GeneralizedAssemblyMatrixInstance: public GenericGeneralizedAssemblyMatrixInstance
{
private:
    /** @brief Objet Jeveux '.VALM' */
    JeveuxVector< ValueType > _valm;

    /**
     * @brief definir le type
     */
    template< class type = ValueType >
    typename std::enable_if< std::is_same< type, double >::value, void>::type
    setMatrixType()
    {
        setType( "MATR_ASSE_GENE_R" );
    };

    /**
     * @brief definir le type
     */
    template< class type = ValueType >
    typename std::enable_if< std::is_same< type, DoubleComplex >::value, void>::type
    setMatrixType()
    {
        setType( "MATR_ASSE_GENE_C" );
    };

public:
    /**
     * @brief Constructeur
     */
    GeneralizedAssemblyMatrixInstance():
        _valm( JeveuxVector< ValueType >( getName() + ".VALM" ) )
    {
        GeneralizedAssemblyMatrixInstance< ValueType >::setMatrixType();
    };
};

/** @typedef Definition d'une matrice assemblee généralisée de double */
typedef GeneralizedAssemblyMatrixInstance< double > GeneralizedAssemblyMatrixDoubleInstance;
/** @typedef Definition d'une matrice assemblee généralisée de complexe */
typedef GeneralizedAssemblyMatrixInstance< DoubleComplex > GeneralizedAssemblyMatrixComplexInstance;

/**
 * @typedef GenericGeneralizedAssemblyMatrixPtr
 * @brief Pointeur intelligent vers un GenericGeneralizedAssemblyMatrixInstance
 */
typedef boost::shared_ptr< GenericGeneralizedAssemblyMatrixInstance > GenericGeneralizedAssemblyMatrixPtr;

/**
 * @typedef GeneralizedAssemblyMatrixDoublePtr
 * @brief Pointeur intelligent vers un GeneralizedAssemblyMatrixDoubleInstance
 */
typedef boost::shared_ptr< GeneralizedAssemblyMatrixDoubleInstance > GeneralizedAssemblyMatrixDoublePtr;

/**
 * @typedef GeneralizedAssemblyMatrixComplexPtr
 * @brief Pointeur intelligent vers un GeneralizedAssemblyMatrixComplexInstance
 */
typedef boost::shared_ptr< GeneralizedAssemblyMatrixComplexInstance > GeneralizedAssemblyMatrixComplexPtr;

#endif /* GENERALIZEDASSEMBLYMATRIX_H_ */
