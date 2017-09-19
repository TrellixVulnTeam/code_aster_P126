/**
 * @file FiniteElementDescriptor.cxx
 * @brief Implementation de FiniteElementDescriptor
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

#include "Modeling/FiniteElementDescriptor.h"

FiniteElementDescriptorInstance::FiniteElementDescriptorInstance( const std::string& name,
                                                                  const JeveuxMemory memType ):
                    DataStructure( name, "LIGREL", memType ),
                    _numberOfDelayedNumberedConstraintNodes( getName() + ".NBNO" ),
                    _parameters( getName() + ".LGRF" ),
                    _dofDescriptor( getName() + ".PRNM" ),
                    _listOfGroupOfElements( getName() + ".LIEL" ),
                    _groupOfElementsNumberByElement( getName() + ".REPE" ),
                    _delayedNumberedConstraintElementsDescriptor( getName() + ".NEMA" ),
                    _dofOfDelayedNumberedConstraintNodes( getName() + ".PRNS" ),
                    _delayedNodesNumbering( getName() + ".LGNS" ),
                    _superElementsDescriptor( getName() + ".SSSA" ),
                    _nameOfNeighborhoodStructure( getName() + ".NVGE" )
{
    if( getName().size() != 19 )
        throw std::runtime_error( "Naming problem" );
};
