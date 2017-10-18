/**
 * @file ResultNaming.cxx
 * @brief Implementation of automatic naming of jeveux objects.
 * @section LICENCE
 * Copyright (C) 1991 - 2017 - EDF R&D - www.code-aster.org
 * This file is part of code_aster.
 *
 * code_aster is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * code_aster is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with code_aster.  If not, see <http://www.gnu.org/licenses/>.

 * person_in_charge: mathieu.courtois@edf.fr
 */

#include <stdexcept>
#include <string>
#include <vector>

#include "astercxx.h"
#include "Functions/Function.h"
#include "Supervis/ResultNaming.h"


FunctionInstance::FunctionInstance( const std::string jeveuxName ):
    DataStructure( jeveuxName + "           ", "FONCTION" ),
    _jeveuxName( getName() ),
    _property( JeveuxVectorChar24( getName() + ".PROL" ) ),
    _value( JeveuxVectorDouble( getName() + ".VALE" ) )
{
}

FunctionInstance::FunctionInstance() :
    FunctionInstance::FunctionInstance( ResultNaming::getNewResultName() )
{
}

void FunctionInstance::setValues( const VectorDouble &absc, const VectorDouble &ordo ) throw ( std::runtime_error )
{
    if ( absc.size() != ordo.size() )
        throw std::runtime_error( "Function: length of abscissa and ordinates must be equal" );

    // Create Jeveux vector ".VALE"
    const int nbpts = absc.size();
    _value->allocate( Permanent, 2 * nbpts );

    // Loop on the points
    VectorDouble::const_iterator abscIt = absc.begin();
    VectorDouble::const_iterator ordoIt = ordo.begin();
    int idx = 0;
    for ( ; abscIt != absc.end(); ++abscIt, ++ordoIt )
    {
        (*_value)[idx] = *abscIt;
        (*_value)[nbpts + idx] = *ordoIt;
        ++idx;
    }
}

void FunctionInstance::setInterpolation( const std::string type ) throw ( std::runtime_error )
{
    std::string interp;
    if( !_property->isAllocated() )
        propertyAllocate();

    if ( type.length() != 7 )
        throw std::runtime_error("Function: interpolation must be 7 characters long.");

    interp = type.substr(0, 3);
    if ( interp != "LIN" && interp != "LOG" && interp != "NON" )
        throw std::runtime_error("Function: invalid interpolation for abscissa.");

    interp = type.substr(4, 3);
    if ( interp != "LIN" && interp != "LOG" && interp != "NON" )
        throw std::runtime_error("Function: invalid interpolation for ordinates.");

    (*_property)[1] = type.c_str();
}

void FunctionInstance::setExtrapolation( const std::string type ) throw ( std::runtime_error )
{
    if( !_property->isAllocated() )
        propertyAllocate();

    if ( type.length() != 2 )
        throw std::runtime_error("Function: interpolation must be 2 characters long.");

    std::string auth("CELI");
    if ( auth.find(type[0]) == std::string::npos )
        throw std::runtime_error("Function: invalid extrapolation for abscissa.");

    if ( auth.find(type[1]) == std::string::npos )
        throw std::runtime_error("Function: invalid extrapolation for ordinates.");

    (*_property)[4] = type.c_str();
}
