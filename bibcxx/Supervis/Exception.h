#ifndef EXCEPTION_H_
#define EXCEPTION_H_

/**
 * @file Exception.h
 * @brief Definition of code_aster exceptions
 * @author Mathieu Courtois
 * @section LICENCE
 *   Copyright (C) 1991 - 2018  EDF R&D                www.code-aster.org
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

/* person_in_charge: mathieu.courtois@edf.fr */

#include <exception>
#include <string>

#include "astercxx.h"

class AsterErrorCpp : public std::exception {
  private:
    std::string _idmess;
    VectorString _valk;
    VectorLong _vali;
    VectorDouble _valr;

  public:
    AsterErrorCpp( std::string idmess, VectorString valk = {}, VectorLong vali = {},
                    VectorDouble valr = {} )
        : _idmess( idmess ), _valk( valk ), _vali( vali ), _valr( valr ) {}

    const char *what() const throw() { return _idmess.c_str(); }

    ~AsterErrorCpp() throw() {}

    /* Build arguments for the Python exception */
    PyObject *py_attrs() const;
};

PyObject *createExceptionClass( const char *name, PyObject *baseTypeObj = PyExc_Exception );

void raiseAsterError( const std::string idmess = "DVP_1" ) throw( AsterErrorCpp );

extern "C" void DEF0(UEXCEP, uexcep);

#endif
