#ifndef FLUIDSTRUCTUREINTERACTION_H_
#define FLUIDSTRUCTUREINTERACTION_H_

/**
 * @file FluidStructureInteraction.h
 * @brief Fichier entete de la classe FluidStructureInteraction
 * @author Nicolas Sellenet
 * @section LICENCE
 *   Copyright (C) 1991 - 2017  EDF R&D                www.code-aster.org
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


/**
 * @class FluidStructureInteractionInstance
 * @brief Cette classe correspond a une sd spectre
 * @author Nicolas Sellenet
 */
class FluidStructureInteractionInstance: public DataStructure
{
private:
    /** @brief Objet Jeveux '.FSIC' */
    JeveuxVectorLong   _fsic;
    /** @brief Objet Jeveux '.FSVI' */
    JeveuxVectorLong   _fsvi;
    /** @brief Objet Jeveux '.FSVK' */
    JeveuxVectorChar8  _fsvk;
    /** @brief Objet Jeveux '.FSVR' */
    JeveuxVectorDouble _fsvr;
    /** @brief Objet Jeveux '.FSGM' */
    JeveuxVectorChar24 _fsgm;
    /** @brief Objet Jeveux '.FSGR' */
    JeveuxVectorDouble _fsgr;
    /** @brief Objet Jeveux '.FSCR' */
    JeveuxVectorDouble _fscr;
    /** @brief Objet Jeveux '.UNIT_FAISCEAU' */
    JeveuxVectorLong   _unitFaisceau;
    /** @brief Objet Jeveux '.UNIT_GRAPPES' */
    JeveuxVectorLong   _unitGrappes;

public:
    /**
     * @typedef FluidStructureInteractionPtr
     * @brief Pointeur intelligent vers un FluidStructureInteraction
     */
    typedef boost::shared_ptr< FluidStructureInteractionInstance > FluidStructureInteractionPtr;

    /**
     * @brief Constructeur
     */
    static FluidStructureInteractionPtr create()
    {
        return FluidStructureInteractionPtr( new FluidStructureInteractionInstance );
    };

    /**
     * @brief Constructeur
     */
    FluidStructureInteractionInstance(): 
        DataStructure( "TYPE_FLUI_STRU", Permanent, 8 ),
        _fsic( JeveuxVectorLong( getName() + "           .FSIC" ) ),
        _fsvi( JeveuxVectorLong( getName() + "           .FSVI" ) ),
        _fsvk( JeveuxVectorChar8( getName() + "           .FSVK" ) ),
        _fsvr( JeveuxVectorDouble( getName() + "           .FSVR" ) ),
        _fsgm( JeveuxVectorChar24( getName() + "           .FSGM" ) ),
        _fsgr( JeveuxVectorDouble( getName() + "           .FSGR" ) ),
        _fscr( JeveuxVectorDouble( getName() + "           .FSCR" ) ),
        _unitFaisceau( JeveuxVectorLong( getName() + ".UNIT_FAISCEAU" ) ),
        _unitGrappes( JeveuxVectorLong( getName() + ".UNIT_GRAPPES" ) )
    {};
};

/**
 * @typedef FluidStructureInteractionPtr
 * @brief Pointeur intelligent vers un FluidStructureInteractionInstance
 */
typedef boost::shared_ptr< FluidStructureInteractionInstance > FluidStructureInteractionPtr;

#endif /* FLUIDSTRUCTUREINTERACTION_H_ */
