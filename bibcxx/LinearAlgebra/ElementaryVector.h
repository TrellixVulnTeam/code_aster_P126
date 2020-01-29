#ifndef ELEMENTARYVECTOR_H_
#define ELEMENTARYVECTOR_H_

/**
 * @file ElementaryVector.h
 * @brief Fichier entete de la classe ElementaryVector
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

/* person_in_charge: nicolas.sellenet at edf.fr */

#include "astercxx.h"
#include "DataStructures/DataStructure.h"
#include "MemoryManager/JeveuxVector.h"
#include "Loads/MechanicalLoad.h"
#include "Loads/ListOfLoads.h"
#include "DataFields/FieldOnNodes.h"
#include "Discretization/DOFNumbering.h"
#include "Discretization/ParallelDOFNumbering.h"
#include "DataFields/ElementaryResult.h"
#include "Loads/PhysicalQuantity.h"

/**
 * @class ElementaryVectorClass
 * @brief Class definissant une sd_vect_elem
 * @author Nicolas Sellenet
 */
class ElementaryVectorClass : public DataStructure {
  private:
    /** @typedef std::list de MechanicalLoad */
    typedef std::list< GenericMechanicalLoadPtr > ListMechanicalLoad;
    /** @typedef Iterateur sur une std::list de MechanicalLoad */
    typedef ListMechanicalLoad::iterator ListMechanicalLoadIter;

    /** @brief Objet Jeveux '.RERR' */
    JeveuxVectorChar24 _description;
    /** @brief Objet Jeveux '.RELR' */
    JeveuxVectorChar24 _listOfElementaryResults;
    /** @brief Booleen indiquant si la sd est vide */
    bool _isEmpty;
    /** @brief Vectors of RESUELEM */
    std::vector< ElementaryResultDoublePtr > _realVector;

    /** @brief Liste de charges */
    ListOfLoadsPtr _listOfLoads;

    JeveuxBidirectionalMapChar24 _corichRept;

  public:
    /**
     * @typedef ElementaryVectorPtr
     * @brief Pointeur intelligent vers un ElementaryVector
     */
    typedef boost::shared_ptr< ElementaryVectorClass > ElementaryVectorPtr;

    /**
     * @brief Constructeur
     */
    ElementaryVectorClass( const std::string name,
                              const JeveuxMemory memType = Permanent,
                              const std::string type = "VECT_ELEM" )
        : DataStructure( name, 19, type, memType ),
          _description( JeveuxVectorChar24( getName() + ".RERR" ) ),
          _listOfElementaryResults( JeveuxVectorChar24( getName() + ".RELR" ) ), _isEmpty( true ),
          _listOfLoads( new ListOfLoadsClass( memType ) ),
          _corichRept( JeveuxBidirectionalMapChar24( "&&CORICH." + getName8() + ".REPT" ) ){};

    /**
     * @brief Constructeur
     */
    ElementaryVectorClass( const JeveuxMemory memType = Permanent )
        : ElementaryVectorClass( ResultNaming::getNewResultName(), memType ){};

    /* FIXME: temporay for _corich .REPT initialiezation! */
    const std::string getName8() const {
        std::string name8 = getName();
        name8.resize( 8, ' ' );
        return name8;
    };

    /**
     * @brief Function d'ajout d'un chargement
     * @param Args... Liste d'arguments template
     */
    template < typename... Args > void addLoad( const Args &... a ) {
        _listOfLoads->addLoad( a... );
    };

    /**
     * @brief Reset new type (double, complex, ...)
     * @param newType
     */
    void setType( const std::string newType ) { DataStructure::setType( newType ); };

    /**
     * @brief Assembler les vecteurs elementaires en se fondant sur currentNumerotation
     * @param currentNumerotation objet DOFNumbering
     * @todo prendre en compte les fonctions multiplicatrices
     */
    FieldOnNodesDoublePtr
    assembleVector( const DOFNumberingPtr &currentNumerotation ) {
        return assembleVector( currentNumerotation, 0., Permanent );
    };

/**
 * @brief Assembler les vecteurs elementaires en se fondant sur currentNumerotation
 * @param currentNumerotation objet DOFNumbering
 * @todo prendre en compte les fonctions multiplicatrices
 */
#ifdef _USE_MPI
    FieldOnNodesDoublePtr assembleVector(
        const ParallelDOFNumberingPtr &currentNumerotation ) {
        return assembleVector( currentNumerotation, 0., Permanent );
    };
#endif /* _USE_MPI */

    /**
     * @brief Assembler les vecteurs elementaires en se fondant sur currentNumerotation
     * @param currentNumerotation objet DOFNumbering
     * @todo prendre en compte les fonctions multiplicatrices
     */
    FieldOnNodesDoublePtr
    assembleVector( const BaseDOFNumberingPtr &currentNumerotation, const double &time = 0.,
                    const JeveuxMemory memType = Permanent ) ;

    /**
     * @brief Methode permettant de savoir si les matrices elementaires sont vides
     * @return true si les matrices elementaires sont vides
     */
    bool isEmpty() { return _isEmpty; };

    /**
     * @brief Methode permettant de changer l'état de remplissage
     * @param bEmpty booleen permettant de dire que l'objet est vide ou pas
     */
    void setEmpty( bool bEmpty ) { _isEmpty = bEmpty; };

    /**
     * @brief Methode permettant de definir la liste de charge
     * @param currentList Liste charge
     */
    void setListOfLoads( const ListOfLoadsPtr &currentList ) { _listOfLoads = currentList; };

    /**
     * @brief function to update ElementaryResultClass
     */
    bool update()
    {
        _listOfElementaryResults->updateValuePointer();
        _realVector.clear();
        for ( int pos = 0; pos < _listOfElementaryResults->size(); ++pos )
        {
            const std::string name = ( *_listOfElementaryResults )[pos].toString();
            if ( trim( name ) != "" )
            {
                ElementaryResultDoublePtr toPush( new ElementaryResultClass< double >( name ) );
                _realVector.push_back( toPush );
            }
        }
        return true;
    };

    friend class DiscreteProblemClass;
};

/**
 * @typedef ElementaryVectorPtr
 * @brief Pointeur intelligent vers un ElementaryVectorClass
 */
typedef boost::shared_ptr< ElementaryVectorClass > ElementaryVectorPtr;

/**
 * @class TemplateElementaryVectorClass
 * @brief Classe definissant une sd_vect_elem template
 * @author Nicolas Sellenet
 */
template < class ValueType, PhysicalQuantityEnum PhysicalQuantity >
class TemplateElementaryVectorClass: public ElementaryVectorClass
{
  private:

  public:
    /**
     * @typedef TemplateElementaryVectorPtr
     * @brief Pointeur intelligent vers un TemplateElementaryVector
     */
    typedef boost::shared_ptr< TemplateElementaryVectorClass< ValueType, PhysicalQuantity > >
        TemplateElementaryVectorPtr;

    /**
     * @brief Constructor with a name
     */
    TemplateElementaryVectorClass( const std::string name,
                                      const JeveuxMemory memType = Permanent ):
        ElementaryVectorClass( name, memType,
            "VECT_ELEM_" + std::string( PhysicalQuantityNames[PhysicalQuantity] ) +
            ( typeid( ValueType ) == typeid(double)? "_R" : "_C" ) )
    {};

    /**
     * @brief Constructor
     */
    TemplateElementaryVectorClass( const JeveuxMemory memType = Permanent ):
        TemplateElementaryVectorClass( ResultNaming::getNewResultName(), memType )
    {};
};

/** @typedef Definition d'une matrice élémentaire de double */
template class TemplateElementaryVectorClass< double, Displacement >;
typedef TemplateElementaryVectorClass< double,
                                          Displacement > ElementaryVectorDisplacementDoubleClass;

/** @typedef Definition d'une matrice élémentaire de double temperature */
template class TemplateElementaryVectorClass< double, Temperature >;
typedef TemplateElementaryVectorClass< double,
                                          Temperature > ElementaryVectorTemperatureDoubleClass;

/** @typedef Definition d'une matrice élémentaire de DoubleComplex pression */
template class TemplateElementaryVectorClass< DoubleComplex, Pressure >;
typedef TemplateElementaryVectorClass< DoubleComplex,
                                          Pressure > ElementaryVectorPressureComplexClass;

typedef boost::shared_ptr< ElementaryVectorDisplacementDoubleClass >
    ElementaryVectorDisplacementDoublePtr;
typedef boost::shared_ptr< ElementaryVectorTemperatureDoubleClass >
    ElementaryVectorTemperatureDoublePtr;
typedef boost::shared_ptr< ElementaryVectorPressureComplexClass >
    ElementaryVectorPressureComplexPtr;

#endif /* ELEMENTARYVECTOR_H_ */
