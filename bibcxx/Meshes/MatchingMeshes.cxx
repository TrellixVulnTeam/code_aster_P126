/**
 * @file MatchingMeshes.cxx
 * @brief Implementation de MatchingMeshesInstance
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

#include "Meshes/MatchingMeshes.h"

MatchingMeshesInstance::MatchingMeshesInstance():
    DataStructure( "CORRESP_2_MAILLA", Permanent, 16 ),
    _pjxxK1( JeveuxVectorChar24( getName() + ".PJXX_K1" ) ),
    _pjefNb( JeveuxVectorLong( getName() + ".PJEF_NB" ) ),
    _pjefNu( JeveuxVectorLong( getName() + ".PJEF_NU" ) ),
    _pjefM1( JeveuxVectorLong( getName() + ".PJEF_M1" ) ),
    _pjefCf( JeveuxVectorDouble( getName() + ".PJEF_CF" ) ),
    _pjefTr( JeveuxVectorLong( getName() + ".PJEF_TR" ) ),
    _pjefCo( JeveuxVectorDouble( getName() + ".PJEF_CO" ) ),
    _pjefEl( JeveuxVectorLong( getName() + ".PJEF_EL" ) ),
    _pjefMp( JeveuxVectorChar8( getName() + ".PJEF_MP" ) ),
    _pjngI1( JeveuxVectorLong( getName() + ".PJNG_I1" ) ),
    _pjngI2( JeveuxVectorLong( getName() + ".PJNG_I2" ) )
{};
