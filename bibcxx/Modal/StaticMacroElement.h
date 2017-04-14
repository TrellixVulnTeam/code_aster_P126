#ifndef STATICMACROELEMENT_H_
#define STATICMACROELEMENT_H_

/**
 * @file StaticMacroElement.h
 * @brief Fichier entete de la classe StaticMacroElement
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
#include "LinearAlgebra/AssemblyMatrix.h"


/**
 * @class ProjMesuInstance
 * @brief Cette classe correspond a un PROJ_MESU
 * @author Nicolas Sellenet
 */
class ProjMesuInstance: public DataStructure
{
private:
    /** @brief Objet Jeveux '.PJMNO' */
    JeveuxVectorLong        _pjmno;
    /** @brief Objet Jeveux '.PJMRG' */
    JeveuxVectorChar8       _pjmrg;
    /** @brief Objet Jeveux '.PJMBP' */
    JeveuxVectorDouble      _pjmbp;
    /** @brief Objet Jeveux '.PJMRF' */
    JeveuxVectorChar16      _pjmrf;
    /** @brief Objet Jeveux '.PJMOR' */
    JeveuxVectorDouble      _pjmor;
    /** @brief Objet Jeveux '.PJMMM' */
    JeveuxVectorDouble      _pjmmm;
    /** @brief Objet Jeveux '.PJMIG' */
    JeveuxVectorDouble      _pjmig;

public:
    /**
     * @brief Constructeur
     */
    ProjMesuInstance( const std::string& name ): 
        DataStructure( name, "PROJ_MESU", Permanent ),
        _pjmno( JeveuxVectorLong( getName() + ".PJMNO" ) ),
        _pjmrg( JeveuxVectorChar8( getName() + ".PJMRG" ) ),
        _pjmbp( JeveuxVectorDouble( getName() + ".PJMBP" ) ),
        _pjmrf( JeveuxVectorChar16( getName() + ".PJMRF" ) ),
        _pjmor( JeveuxVectorDouble( getName() + ".PJMOR" ) ),
        _pjmmm( JeveuxVectorDouble( getName() + ".PJMMM" ) ),
        _pjmig( JeveuxVectorDouble( getName() + ".PJMIG" ) )
    {};

};

/**
 * @typedef ProjMesuInstancePtr
 * @brief Pointeur intelligent vers un ProjMesuInstance
 */
typedef std::shared_ptr< ProjMesuInstance > ProjMesuPtr;

/**
 * @class StaticMacroElementInstance
 * @brief Cette classe correspond a un MACR_ELEM_STAT
 * @author Nicolas Sellenet
 */
class StaticMacroElementInstance: public DataStructure
{
private:
    /** @brief Objet Jeveux '.DESM' */
    JeveuxVectorLong        _desm;
    /** @brief Objet Jeveux '.LINO' */
    JeveuxVectorLong        _lino;
    /** @brief Objet Jeveux '.REFM' */
    JeveuxVectorChar8       _refm;
    /** @brief Objet Jeveux '.VARM' */
    JeveuxVectorDouble      _varm;
    /** @brief Objet Jeveux '.CONX' */
    JeveuxVectorLong        _conx;
    /** @brief Objet Jeveux '.RIGIMECA' */
    AssemblyMatrixDoublePtr _rigiMeca;
    /** @brief Objet Jeveux '.MAEL_RAID_VALE' */
    JeveuxVectorDouble      _maelRaidVale;
    /** @brief Objet Jeveux '.PHI_IE' */
    JeveuxCollectionDouble  _phiIe;
    /** @brief Objet Jeveux '.MASSMECA' */
    AssemblyMatrixDoublePtr _masseMeca;
    /** @brief Objet Jeveux '.MAEL_MASS_VALE' */
    JeveuxVectorDouble      _maelMassVale;
    /** @brief Objet Jeveux '.MAEL_AMOR_VALE' */
    JeveuxVectorDouble      _maelAmorVale;
    /** @brief Objet Jeveux '.LICA' */
    JeveuxCollectionDouble  _lica;
    /** @brief Objet Jeveux '.LICH' */
    JeveuxCollectionChar8   _lich;
    /** @brief Objet PROJ_MESU '        .PROJM    ' */
    ProjMesuPtr             _projM;

public:
    /**
     * @typedef StaticMacroElementPtr
     * @brief Pointeur intelligent vers un StaticMacroElementInstance
     */
    typedef std::shared_ptr< StaticMacroElementInstance > StaticMacroElementPtr;

    /**
     * @brief Constructeur
     */
    StaticMacroElementInstance(): 
        DataStructure( "MACR_ELEM_STAT", Permanent ),
        _desm( JeveuxVectorLong( getName() + ".DESM" ) ),
        _lino( JeveuxVectorLong( getName() + ".LINO" ) ),
        _refm( JeveuxVectorChar8( getName() + ".REFM" ) ),
        _varm( JeveuxVectorDouble( getName() + ".VARM" ) ),
        _conx( JeveuxVectorLong( getName() + ".CONX" ) ),
        _rigiMeca( new AssemblyMatrixDoubleInstance( getName() + ".RIGIMECA" ) ),
        _maelRaidVale( JeveuxVectorDouble( getName() + ".MAEL_RAID_VALE" ) ),
        _phiIe( JeveuxCollectionDouble( getName() + ".PHI_IE" ) ),
        _masseMeca( new AssemblyMatrixDoubleInstance( getName() + ".MASSMECA" ) ),
        _maelMassVale( JeveuxVectorDouble( getName() + ".MAEL_MASS_VALE" ) ),
        _maelAmorVale( JeveuxVectorDouble( getName() + ".MAEL_AMOR_VALE" ) ),
        _lica( JeveuxCollectionDouble( getName() + ".LICA" ) ),
        _lich( JeveuxCollectionChar8( getName() + ".LICH" ) ),
        _projM( new ProjMesuInstance( getName() + ".PROJM    " ) )
    {};

};

/**
 * @typedef StaticMacroElementPtr
 * @brief Pointeur intelligent vers un StaticMacroElementInstance
 */
typedef std::shared_ptr< StaticMacroElementInstance > StaticMacroElementPtr;

#endif /* STATICMACROELEMENT_H_ */
