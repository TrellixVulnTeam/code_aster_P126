#ifndef DOFNUMBERING_H_
#define DOFNUMBERING_H_

/**
 * @file BaseDOFNumbering.h
 * @brief Fichier entete de la classe BaseDOFNumbering
 * @author Nicolas Sellenet
 * @section LICENCE
 *   Copyright (C) 1991 - 2017 - EDF R&D - www.code-aster.org
 *   This file is part of code_aster.
 *
 *   code_aster is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   code_aster is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 */

/* person_in_charge: nicolas.sellenet at edf.fr */

#include <stdexcept>
#include "astercxx.h"
#include <string>

#include "DataStructures/DataStructure.h"
#include "MemoryManager/JeveuxVector.h"
#include "Modeling/Model.h"
#include "LinearAlgebra/ElementaryMatrix.h"
#include "Loads/MechanicalLoad.h"
#include "Loads/KinematicsLoad.h"
#include "Loads/ListOfLoads.h"
#include "LinearAlgebra/MatrixStorage.h"

/**
 * @class FieldOnNodesDescriptionInstance
 * @brief This class describes the structure of dof stored in a field on nodes
 * @author Nicolas Sellenet
 */
class FieldOnNodesDescriptionInstance: public DataStructure
{
    /** @brief Objet Jeveux '.PRNO' */
    JeveuxCollectionLong         _componentsOnNodes;
    /** @brief Objet Jeveux '.LILI' */
    JeveuxBidirectionalMapChar24 _namesOfGroupOfElements;
    /** @brief Objet Jeveux '.NUEQ' */
    JeveuxVectorLong             _indexationVector;
    /** @brief Objet Jeveux '.DEEQ' */
    JeveuxVectorLong             _nodeAndComponentsNumberFromDOF;

public:
    /**
     * @brief Constructeur
     */
    FieldOnNodesDescriptionInstance(  const JeveuxMemory memType = Permanent );

    /**
     * @brief Constructeur
     * @param name nom souhaité de la sd (utile pour le FieldOnNodesDescriptionInstance d'une sd_resu)
     */
    FieldOnNodesDescriptionInstance( const std::string name,
                                     const JeveuxMemory memType = Permanent );
};
typedef boost::shared_ptr< FieldOnNodesDescriptionInstance > FieldOnNodesDescriptionPtr;

/**
 * @class BaseDOFNumberingInstance
 * @brief Class definissant un nume_ddl
 *        Cette classe est volontairement succinte car on n'en connait pas encore l'usage
 * @author Nicolas Sellenet
 */
class BaseDOFNumberingInstance: public DataStructure
{
private:
    class MultFrontGarbageInstance
    {
        /** @brief Objet Jeveux '.ADNT' */
        JeveuxVectorShort             _adnt;
        /** @brief Objet Jeveux '.GLOB' */
        JeveuxVectorShort             _glob;
        /** @brief Objet Jeveux '.LOCL' */
        JeveuxVectorShort             _locl;
        /** @brief Objet Jeveux '.PNTI' */
        JeveuxVectorShort             _pnti;
        /** @brief Objet Jeveux '.RENU' */
        JeveuxVectorChar8             _renu;
        /** @brief Objet Jeveux '.ADPI' */
        JeveuxVectorLong              _adpi;
        /** @brief Objet Jeveux '.ADRE' */
        JeveuxVectorLong              _adre;
        /** @brief Objet Jeveux '.ANCI' */
        JeveuxVectorLong              _anci;
        /** @brief Objet Jeveux '.LFRN' */
        JeveuxVectorLong              _debf;
        /** @brief Objet Jeveux '.DECA' */
        JeveuxVectorLong              _deca;
        /** @brief Objet Jeveux '.DEFS' */
        JeveuxVectorLong              _defs;
        /** @brief Objet Jeveux '.DESC' */
        JeveuxVectorLong              _desc;
        /** @brief Objet Jeveux '.DIAG' */
        JeveuxVectorLong              _diag;
        /** @brief Objet Jeveux '.FILS' */
        JeveuxVectorLong              _fils;
        /** @brief Objet Jeveux '.FRER' */
        JeveuxVectorLong              _frer;
        /** @brief Objet Jeveux '.LGBL' */
        JeveuxVectorLong              _lgbl;
        /** @brief Objet Jeveux '.LGSN' */
        JeveuxVectorLong              _lgsn;
        /** @brief Objet Jeveux '.NBAS' */
        JeveuxVectorLong              _nbas;
        /** @brief Objet Jeveux '.NBLI' */
        JeveuxVectorLong              _nbli;
        /** @brief Objet Jeveux '.NCBL' */
        JeveuxVectorLong              _nbcl;
        /** @brief Objet Jeveux '.NOUV' */
        JeveuxVectorLong              _nouv;
        /** @brief Objet Jeveux '.PARE' */
        JeveuxVectorLong              _pare;
        /** @brief Objet Jeveux '.SEQU' */
        JeveuxVectorLong              _sequ;
        /** @brief Objet Jeveux '.SUPN' */
        JeveuxVectorLong              _supn;

        MultFrontGarbageInstance( const std::string& DOFNumName ):
            _adnt( DOFNumName + ".ADNT" ),
            _glob( DOFNumName + ".GLOB" ),
            _locl( DOFNumName + ".LOCL" ),
            _pnti( DOFNumName + ".PNTI" ),
            _renu( DOFNumName + ".RENU" ),
            _adpi( DOFNumName + ".ADPI" ),
            _adre( DOFNumName + ".ADRE" ),
            _anci( DOFNumName + ".ANCI" ),
            _debf( DOFNumName + ".LFRN" ),
            _deca( DOFNumName + ".DECA" ),
            _defs( DOFNumName + ".DEFS" ),
            _desc( DOFNumName + ".DESC" ),
            _diag( DOFNumName + ".DIAG" ),
            _fils( DOFNumName + ".FILS" ),
            _frer( DOFNumName + ".FRER" ),
            _lgbl( DOFNumName + ".LGBL" ),
            _lgsn( DOFNumName + ".LGSN" ),
            _nbas( DOFNumName + ".NBAS" ),
            _nbli( DOFNumName + ".NBLI" ),
            _nbcl( DOFNumName + ".NCBL" ),
            _nouv( DOFNumName + ".NOUV" ),
            _pare( DOFNumName + ".PARE" ),
            _sequ( DOFNumName + ".SEQU" ),
            _supn( DOFNumName + ".SUPN" )
        {};
        friend class BaseDOFNumberingInstance;
    };
    typedef boost::shared_ptr< MultFrontGarbageInstance > MultFrontGarbagePtr;

    class GlobalEquationNumberingInstance
    {
        /** @brief Objet Jeveux '.NEQU' */
        JeveuxVectorLong             _numberOfEquations;
        /** @brief Objet Jeveux '.REFN' */
        JeveuxVectorLong             _informations;
        /** @brief Objet Jeveux '.DELG' */
        JeveuxVectorLong             _lagrangianInformations;

        GlobalEquationNumberingInstance( const std::string& DOFNumName ):
            _numberOfEquations( DOFNumName + ".NEQU" ),
            _informations( DOFNumName + ".REFN" ),
            _lagrangianInformations( DOFNumName + ".DELG" )
        {};
        friend class BaseDOFNumberingInstance;
    };
    typedef boost::shared_ptr< GlobalEquationNumberingInstance > GlobalEquationNumberingPtr;

    class LocalEquationNumberingInstance
    {
        /** @brief Objet Jeveux '.NEQU' */
        JeveuxVectorLong     _numberOfEquations;
        /** @brief Objet Jeveux '.DELG' */
        JeveuxVectorLong     _lagrangianInformations;
        /** @brief Objet Jeveux '.PRNO' */
        JeveuxCollectionLong _componentsOnNodes;
        /** @brief Objet Jeveux '.NUEQ' */
        JeveuxVectorLong     _indexationVector;
        /** @brief Objet Jeveux '.NEQU' */
        JeveuxVectorLong     _globalToLocal;
        /** @brief Objet Jeveux '.DELG' */
        JeveuxVectorLong     _LocalToGlobal;

        LocalEquationNumberingInstance( const std::string& DOFNumName ):
            _numberOfEquations( DOFNumName + ".NEQU" ),
            _lagrangianInformations( DOFNumName + ".DELG" ),
            _componentsOnNodes( DOFNumName + ".PRNO" ),
            _indexationVector( DOFNumName + ".NUEQ" ),
            _globalToLocal( DOFNumName + ".NULG" ),
            _LocalToGlobal( DOFNumName + ".NUGL" )
        {};
        friend class BaseDOFNumberingInstance;
    };
    typedef boost::shared_ptr< LocalEquationNumberingInstance > LocalEquationNumberingPtr;

    // !!! Classe succinte car on ne sait pas comment elle sera utiliser !!!
    /** @brief Objet Jeveux '.NSLV' */
    JeveuxVectorChar24         _nameOfSolverDataStructure;
    /** @brief Objet '.NUME' */
    GlobalEquationNumberingPtr _globalNumbering;
    /** @brief Objet prof_chno */
    FieldOnNodesDescriptionPtr _dofDescription;
    /** @brief Objet '.NUML' */
    LocalEquationNumberingPtr  _localNumbering;
    /** @brief Modele support */
    ModelPtr                   _supportModel;
    /** @brief Matrices elementaires */
    ElementaryMatrixPtr        _supportMatrix;
    /** @brief Chargements */
    ListOfLoadsPtr             _listOfLoads;
    /** @brief Objet Jeveux '.SMOS' */
    MorseStoragePtr            _smos;
    /** @brief Objet Jeveux '.SLCS' */
    LigneDeCielPtr             _slcs;
    /** @brief Objet Jeveux '.MLTF' */
    MultFrontGarbagePtr        _mltf;
    /** @brief Booleen permettant de preciser sur la sd est vide */
    bool                       _isEmpty;

protected:
    /**
     * @brief Constructeur
     */
    BaseDOFNumberingInstance( const std::string& type,
                              const JeveuxMemory memType = Permanent );

    /**
     * @brief Constructeur
     * @param name nom souhaité de la sd (utile pour le BaseDOFNumberingInstance d'une sd_resu)
     */
    BaseDOFNumberingInstance( const std::string name,
                              const std::string& type,
                              const JeveuxMemory memType = Permanent );

public:
    /**
     * @brief Destructeur
     */
    ~BaseDOFNumberingInstance()
    {
#ifdef __DEBUG_GC__
        std::cout << "BaseDOFNumberingInstance.destr: " << this->getName() << std::endl;
#endif
    };

    /**
     * @typedef BaseDOFNumberingPtr
     * @brief Pointeur intelligent vers un BaseDOFNumbering
     */
    typedef boost::shared_ptr< BaseDOFNumberingInstance > BaseDOFNumberingPtr;

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
     * @brief Determination de la numerotation
     */
    bool computeNumerotation() throw ( std::runtime_error );

    /**
     * @brief Methode permettant de savoir si la numerotation est vide
     * @return true si la numerotation est vide
     */
    bool isEmpty()
    {
        return _isEmpty;
    };

    /**
     * @brief Methode permettant de savoir si l'objet est parallel
     * @return false
     */
    virtual bool isParallel()
    {
        return false;
    };

    /**
     * @brief Methode permettant de definir les matrices elementaires
     * @param currentMatrix objet ElementaryMatrix
     */
    virtual void setElementaryMatrix( const ElementaryMatrixPtr& currentMatrix )
        throw ( std::runtime_error )
    {
        if ( _supportModel )
            throw std::runtime_error( "It is not allowed to defined Model and ElementaryMatrix together" );
        _supportMatrix = currentMatrix;
    };

    /**
     * @brief Methode permettant de definir la liste de charge
     * @param currentList Liste charge
     */
    void setListOfLoads( const ListOfLoadsPtr& currentList  )
    {
        _listOfLoads = currentList;
    };

    /**
     * @brief Methode permettant de definir le modele support
     * @param currentModel Model support de la numerotation
     */
    virtual void setSupportModel( const ModelPtr& currentModel )
        throw ( std::runtime_error )
    {
        if ( ! _supportMatrix.use_count() == 0 )
            throw std::runtime_error( "It is not allowed to defined Model and ElementaryMatrix together" );
        _supportModel = currentModel;
    };
    /**
     * @brief Get model
     */
    ModelPtr getSupportModel() throw ( std::runtime_error ){
        return _supportModel;
    };
};

/**
 * @class DOFNumberingInstance
 * @brief Class definissant un nume_ddl
 * @author Nicolas Sellenet
 */
class DOFNumberingInstance: public BaseDOFNumberingInstance
{
public:
    /**
     * @typedef DOFNumberingPtr
     * @brief Pointeur intelligent vers un DOFNumbering
     */
    typedef boost::shared_ptr< DOFNumberingInstance > DOFNumberingPtr;

    /**
     * @brief Constructeur
     */
    DOFNumberingInstance( const JeveuxMemory memType = Permanent ):
        BaseDOFNumberingInstance( "NUME_DDL", memType )
    {};

    /**
     * @brief Constructeur
     * @param name nom souhaité de la sd (utile pour le BaseDOFNumberingInstance d'une sd_resu)
     */
    DOFNumberingInstance( const std::string name, const JeveuxMemory memType = Permanent ):
        BaseDOFNumberingInstance( name, "NUME_DDL", memType )
    {};

    /**
     * @brief Methode permettant de definir les matrices elementaires
     * @param currentMatrix objet ElementaryMatrix
     */
    void setElementaryMatrix( const ElementaryMatrixPtr& currentMatrix )
        throw ( std::runtime_error )
    {
        if( currentMatrix->getSupportModel()->getSupportMesh()->isParallel() )
            throw std::runtime_error( "Support mesh must not be parallel" );
        BaseDOFNumberingInstance::setElementaryMatrix( currentMatrix );
    };

    /**
     * @brief Methode permettant de definir le modele support
     * @param currentModel Model support de la numerotation
     */
    void setSupportModel( const ModelPtr& currentModel )
        throw ( std::runtime_error )
    {
        if( currentModel->getSupportMesh()->isParallel() )
            throw std::runtime_error( "Support mesh must not be parallel" );
        BaseDOFNumberingInstance::setSupportModel( currentModel );
    };
};

/**
 * @typedef BaseDOFNumberingPtr
 * @brief Enveloppe d'un pointeur intelligent vers un BaseDOFNumberingInstance
 * @author Nicolas Sellenet
 */
typedef boost::shared_ptr< BaseDOFNumberingInstance > BaseDOFNumberingPtr;


/**
 * @typedef DOFNumberingPtr
 * @brief Enveloppe d'un pointeur intelligent vers un DOFNumberingInstance
 * @author Nicolas Sellenet
 */
typedef boost::shared_ptr< DOFNumberingInstance > DOFNumberingPtr;

#endif /* DOFNUMBERING_H_ */
