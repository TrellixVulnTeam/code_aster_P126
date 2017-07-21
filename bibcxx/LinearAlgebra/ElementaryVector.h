#ifndef ELEMENTARYVECTOR_H_
#define ELEMENTARYVECTOR_H_

/**
 * @file ElementaryVector.h
 * @brief Fichier entete de la classe ElementaryVector
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
#include "DataStructures/DataStructure.h"
#include "MemoryManager/JeveuxVector.h"
#include "Loads/MechanicalLoad.h"
#include "Loads/ListOfLoads.h"
#include "DataFields/FieldOnNodes.h"
#include "Discretization/DOFNumbering.h"
#include "Discretization/ParallelDOFNumbering.h"

/**
 * @class ElementaryVectorInstance
 * @brief Class definissant une sd_vect_elem
 * @author Nicolas Sellenet
 */
class ElementaryVectorInstance: public DataStructure
{
private:
    /** @typedef std::list de MechanicalLoad */
    typedef std::list< GenericMechanicalLoadPtr > ListMechanicalLoad;
    /** @typedef Iterateur sur une std::list de MechanicalLoad */
    typedef ListMechanicalLoad::iterator ListMechanicalLoadIter;

    /** @brief Objet Jeveux '.RERR' */
    JeveuxVectorChar24           _description;
    /** @brief Objet Jeveux '.RELR' */
    JeveuxVectorChar24           _listOfElementaryResults;
    /** @brief Booleen indiquant si la sd est vide */
    bool                         _isEmpty;

    /** @brief Liste de charges */
    ListOfLoadsPtr               _listOfLoads;

    JeveuxBidirectionalMapChar24 _corichRept;

public:
    /**
     * @typedef ElementaryVectorPtr
     * @brief Pointeur intelligent vers un ElementaryVector
     */
    typedef boost::shared_ptr< ElementaryVectorInstance > ElementaryVectorPtr;

    /**
     * @brief Constructeur
     */
    static ElementaryVectorPtr create()
    {
        return ElementaryVectorPtr( new ElementaryVectorInstance );
    };

    /**
     * @brief Constructeur
     */
    ElementaryVectorInstance( const JeveuxMemory memType = Permanent );

    /**
     * @brief Destructeur
     */
    ~ElementaryVectorInstance()
    {
#ifdef __DEBUG_GC__
        std::cout << "ElementaryVectorInstance.destr: " << this->getName() << std::endl;
#endif
    };

    /**
     * @brief Ajouter une charge mecanique
     * @param currentLoad objet MechanicalLoad
     */
    void addMechanicalLoad( const GenericMechanicalLoadPtr& currentLoad )
    {
        _listOfLoads->addMechanicalLoad( currentLoad );
    };

    /**
     * @brief Assembler les vecteurs elementaires en se fondant sur currentNumerotation
     * @param currentNumerotation objet DOFNumbering
     * @todo prendre en compte les fonctions multiplicatrices
     */
    FieldOnNodesDoublePtr assembleVector( const DOFNumberingPtr& currentNumerotation )
        throw ( std::runtime_error )
    {
        return assembleVector( currentNumerotation, 0., Permanent );
    };

    /**
     * @brief Assembler les vecteurs elementaires en se fondant sur currentNumerotation
     * @param currentNumerotation objet DOFNumbering
     * @todo prendre en compte les fonctions multiplicatrices
     */
#ifdef _USE_MPI
    FieldOnNodesDoublePtr assembleVector( const ParallelDOFNumberingPtr& currentNumerotation )
        throw ( std::runtime_error )
    {
        return assembleVector( currentNumerotation, 0., Permanent );
    };
#endif /* _USE_MPI */

    /**
     * @brief Assembler les vecteurs elementaires en se fondant sur currentNumerotation
     * @param currentNumerotation objet DOFNumbering
     * @todo prendre en compte les fonctions multiplicatrices
     */
    FieldOnNodesDoublePtr assembleVector( const BaseDOFNumberingPtr& currentNumerotation,
                                          const double& time = 0.,
                                          const JeveuxMemory memType = Permanent )
        throw ( std::runtime_error );

    /**
     * @brief Methode permettant de savoir si les matrices elementaires sont vides
     * @return true si les matrices elementaires sont vides
     */
    bool isEmpty()
    {
        return _isEmpty;
    };

    /**
     * @brief Methode permettant de changer l'état de remplissage
     * @param bEmpty booleen permettant de dire que l'objet est vide ou pas
     */
    void setEmpty( bool bEmpty )
    {
        _isEmpty = bEmpty;
    };

    /**
     * @brief Methode permettant de definir la liste de charge
     * @param currentList Liste charge
     */
    void setListOfLoads( const ListOfLoadsPtr& currentList  )
    {
        _listOfLoads = currentList;
    };

    friend class DiscreteProblemInstance;
};

/**
 * @typedef ElementaryVectorPtr
 * @brief Pointeur intelligent vers un ElementaryVectorInstance
 */
typedef boost::shared_ptr< ElementaryVectorInstance > ElementaryVectorPtr;

#endif /* ELEMENTARYVECTOR_H_ */
