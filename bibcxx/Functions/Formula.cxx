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
#include <cstdio>

#include "astercxx.h"
#include "Functions/Formula.h"
#include "Supervis/ResultNaming.h"
#include "Utilities/Tools.h"


FormulaInstance::FormulaInstance( const std::string jeveuxName ):
    DataStructure( jeveuxName, 19, "FORMULE" ),
    _jeveuxName( getName() ),
    _property( JeveuxVectorChar24( getName() + ".PROL" ) ),
    _variables( JeveuxVectorChar8( getName() + ".NOVA" ) ),
    _pointers( JeveuxVectorLong( getName() + ".ADDR" ) ),
    _expression( "" ),
    _code( NULL ),
    _context( NULL )
{
    propertyAllocate();
    _pointers->allocate( Permanent, 2 );
}

FormulaInstance::FormulaInstance() :
    FormulaInstance::FormulaInstance( ResultNaming::getNewResultName() )
{
}

FormulaInstance::~FormulaInstance()
{
    Py_XDECREF(_code);
    Py_XDECREF(_context);
}

void FormulaInstance::setVariables( const std::vector< std::string > &names )
    throw ( std::runtime_error )
{
    const int nbvar = names.size();
    _variables->allocate( Permanent, nbvar );

    std::vector< std::string >::const_iterator varIt = names.begin();
    int idx = 0;
    for ( ; varIt != names.end(); ++varIt )
    {
        (*_variables)[idx] = *varIt;
        ++idx;
    }
}
std::vector< std::string > FormulaInstance::getVariables() const
{
    _variables->updateValuePointer();
    long nbvars = _variables->size();
    std::vector< std::string > vars;
    for ( int i = 0; i < nbvars; ++i )
    {
        vars.push_back( (*_variables)[i].rstrip() );
    }
    return vars;
}

void FormulaInstance::setExpression( const std::string expression )
    throw(std::runtime_error)
{
    const std::string name = "formula";
    _expression = expression;
    Py_XDECREF(_code);
    PyCompilerFlags flags;
    flags.cf_flags = CO_FUTURE_DIVISION;
    _code = Py_CompileStringFlags(_expression.c_str(), name.c_str(),
                                  Py_eval_input, &flags);
    (*_pointers)[0] = (long)_code;
    if ( _code == NULL ) {
        PyErr_Print();
        throw std::runtime_error("Invalid syntax in expression.");
    }
}

VectorDouble FormulaInstance::evaluate( const VectorDouble &values ) const
    throw ( std::runtime_error )
{
    int iret = 0;
    std::vector< std::string > vars = getVariables();
    VectorDouble result = evaluate_formula(_code, _context, vars, values, &iret);
    if ( iret == 1 ) {
        const long nbvars = vars.size();
        const long nbvalues = values.size();
        throw std::runtime_error("Expecting exactly " + std::to_string(nbvars)
                                + " values, not " + std::to_string(nbvalues));
    } else if ( iret == 4 ) {
        throw std::runtime_error("Formula: Error during evaluation.");
    }
    return result;
}


/* functions shared with evaluation from Fortran */
VectorDouble evaluate_formula( const PyObject* code, PyObject* globals,
    const std::vector< std::string > &variables,
    const VectorDouble &values, int* retcode )
{
    const long nbvars = variables.size();
    const long nbvalues = values.size();
    if ( nbvalues != nbvars ) {
        *retcode = 1;
        return VectorDouble(0., 0);
    }

    PyObject* locals = PyDict_New();
    for ( int i = 0 ; i < nbvars; ++i ) {
        PyDict_SetItemString(locals, trim(variables[i]).c_str(),
                                     PyFloat_FromDouble(values[i]));
    }

    PyObject* res = PyEval_EvalCode((PyCodeObject*)code, globals, locals);
    Py_DECREF(locals);
    if ( res == NULL ) {
        PyErr_Print();
        std::cout << "Parameters values:";
        PyObject_Print(locals, stdout, 0);
        std::cout << std::endl;
        *retcode = 4;
        return VectorDouble(0., 0);
    }

    VectorDouble result;
    if ( PyTuple_Check(res) ) {
        const long nbres = PyTuple_Size(res);
        for ( long i = 0; i < nbres; ++ i ) {
            result.push_back(PyFloat_AsDouble(PyTuple_GetItem(res, i)));
        }
    } else if ( PyComplex_Check(res) ) {
        result.push_back(PyComplex_RealAsDouble(res));
        result.push_back(PyComplex_ImagAsDouble(res));
    } else {
        result.push_back(PyFloat_AsDouble(res));
    }
    Py_DECREF(res);

    return result;
}

/* Interface for Fortran calls */
void DEFPPSPPPPP(EVAL_FORMULA, eval_formula,
    ASTERINTEGER* pcode, ASTERINTEGER* pglobals,
    char* array_vars, STRING_SIZE lenvars, ASTERDOUBLE* array_values,
    ASTERINTEGER* nbvar, _OUT ASTERINTEGER* iret,
    _IN ASTERINTEGER* nbres, _OUT ASTERDOUBLE* result )
{
    PyObject* code = (PyObject*)(*pcode);
    PyObject* globals = (PyObject*)(*pglobals);

    std::vector< std::string > vars;
    VectorDouble values;
    for ( int i = 0; i < *nbvar; ++i ) {
        vars.push_back(std::string( array_vars + i * lenvars, lenvars ));
        values.push_back( array_values[i] );
    }

    int ret = 0;
    VectorDouble retvalues = evaluate_formula(code, globals, vars, values, &ret);
    *iret = (ASTERINTEGER)ret;
    if ( ret == 0 ) {
        for ( long i = 0; i < retvalues.size() && i < (*nbres); ++i) {
            result[i] = (ASTERDOUBLE)retvalues[i];
        }
    }
    return;
}
