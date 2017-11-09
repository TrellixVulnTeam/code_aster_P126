#ifndef FUNCTION_H_
#define FUNCTION_H_

/**
 * @file Function.h
 * @brief Implementation of functions.
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
#include <string>
#include <vector>
#include <boost/shared_ptr.hpp>

#include "DataStructures/DataStructure.h"
#include "MemoryManager/JeveuxVector.h"


/**
 * class BaseFunctionInstance
 *   Create a datastructure for a function with real values
 * @author Mathieu Courtois
 */
class BaseFunctionInstance: public DataStructure
{
    private:
        // Nom Jeveux de la SD
        /** @todo remettre le const */
        std::string  _jeveuxName;
        // Vecteur Jeveux '.PROL'
        JeveuxVectorChar24 _property;

        void propertyAllocate()
        {
            // Create Jeveux vector ".PROL"
            _property->allocate( Permanent, 6 );
            (*_property)[0] = _funct_type;
            (*_property)[1] = "LIN LIN";
            (*_property)[2] = "";
            (*_property)[3] = "TOUTRESU";
            (*_property)[4] = "EE";
            (*_property)[5] = _jeveuxName;
        };

    protected:
        // Vecteur Jeveux '.VALE'
        JeveuxVectorDouble _value;
        // Type of Function
        std::string _funct_type;

    public:
        /**
         * @typedef BaseFunctionPtr
         * @brief Pointeur intelligent vers un BaseFunction
         */
        typedef boost::shared_ptr< BaseFunctionInstance > BaseFunctionPtr;

        /**
         * Constructeur
         */
        BaseFunctionInstance( const std::string type );

        BaseFunctionInstance( const std::string jeveuxName, const std::string type );

        /**
         * @brief Definition of the name of the parameter (abscissa)
         * @param name name of the parameter
         * @type  name string
         */
        void setParameterName( const std::string name )
        {
            if( !_property->isAllocated() )
                propertyAllocate();
            (*_property)[2] = name.c_str();
        }

        /**
         * @brief Definition of the name of the result (ordinate)
         * @param name name of the result
         * @type  name string
         */
        void setResultName( const std::string name )
        {
            if( !_property->isAllocated() )
                propertyAllocate();
            (*_property)[3] = name.c_str();
        }

        /**
         * @brief Definition of the type of interpolation
         * @param interpolation type of interpolation
         * @type  interpolation string
         * @todo checking
         */
        void setInterpolation( const std::string type ) throw ( std::runtime_error );

        /**
         * @brief Definition of the type of extrapolation
         * @param extrapolation type of extrapolation
         * @type  extrapolation string
         * @todo checking
         */
        void setExtrapolation( const std::string type ) throw ( std::runtime_error );

        /**
         * @brief Assign the values of the function
         * @param absc values of the abscissa
         * @type  absc vector of double
         * @param ord values of the ordinates
         * @type  ord vector of double
         */
        virtual void setValues( const VectorDouble &absc, const VectorDouble &ord )
            throw ( std::runtime_error );

        /**
         * @brief Return the values of the function as an unidimensional vector
         */
        std::vector<double> getValues() const
        {
            _value->updateValuePointer();
            const double* ptr = getDataPtr();
            std::vector<double> vect( ptr, ptr + _value->size() );
            return vect;
        }

        /**
         * @brief Return a pointer to the vector of data
         */
        const double* getDataPtr() const
        {
            return _value->getDataPtr();
        }

        /**
         * @brief Return the number of points of the function
         */
        virtual long size() const
        {
            return _value->size() / 2;
        }

        /**
         * @brief Return the properties of the function
         * @return vector of strings
         */
        std::vector< std::string > getProperties() const
        {
            _property->updateValuePointer();
            std::vector< std::string > prop;
            for ( int i = 0; i < 6; ++i )
            {
                prop.push_back( (*_property)[i].rstrip() );
            }
            return prop;
        }

        /**
         * @brief Update the pointers to the Jeveux objects
         * @return Return true if ok
         */
        bool build( )
        {
            return _property->updateValuePointer() && _value->updateValuePointer();
        }

};

/**
 * class FunctionInstance
 *   Create a datastructure for a function with real values
 * @author Mathieu Courtois
 */
class FunctionInstance: public BaseFunctionInstance
{

public:
    /**
     * @typedef FunctionPtr
     * @brief Pointeur intelligent vers un Function
     */
    typedef boost::shared_ptr< FunctionInstance > FunctionPtr;

    /**
    * Constructeur
    */
    FunctionInstance():
        BaseFunctionInstance( "FONCTION" )
    {
    };

    FunctionInstance( const std::string jeveuxName ):
        BaseFunctionInstance( jeveuxName, "FONCTION" )
    {
    };

};


/**
 * class FunctionComplexInstance
 *   Create a datastructure for a function with complex values
 * @author Mathieu Courtois
 */
class FunctionComplexInstance: public BaseFunctionInstance
{

public:
    /**
     * @typedef FunctionPtr
     * @brief Pointeur intelligent vers un FunctionComplex
     */
    typedef boost::shared_ptr< FunctionComplexInstance > FunctionComplexPtr;

    /**
    * Constructeur
    */
    FunctionComplexInstance( const std::string jeveuxName ):
        BaseFunctionInstance( jeveuxName, "FONCTION_C" )
    {
        _funct_type = "FONCT_C";
    };

    FunctionComplexInstance():
        BaseFunctionInstance( "FONCTION_C" )
    {
        _funct_type = "FONCT_C";
    };

    /**
     * @brief Return the number of points of the function
     */
    long size() const
    {
        return _value->size() / 3;
    }

    /**
     * @brief Assign the values of the function
     * @param absc values of the abscissa
     * @type  absc vector of double
     * @param ord values of the ordinates (real1, imag1, real2, imag2...)
     * @type  ord vector of double
     */
    void setValues( const VectorDouble &absc, const VectorDouble &ord )
        throw ( std::runtime_error );

    /**
     * @brief Assign the values of the function
     * @param absc values of the abscissa
     * @type  absc vector of double
     * @param ord values of the ordinates
     * @type  ord vector of complex
     */
    void setValues( const VectorDouble &absc, const VectorComplex &ord )
        throw ( std::runtime_error );

};


/**
 * @typedef BaseFunctionPtr
 * @brief  Pointer to a BaseFunctionInstance
 */
typedef boost::shared_ptr< BaseFunctionInstance > BaseFunctionPtr;

/**
 * @typedef FunctionPtr
 * @brief  Pointer to a FunctionInstance
 */
typedef boost::shared_ptr< FunctionInstance > FunctionPtr;

/**
 * @typedef FunctionComplexPtr
 * @brief  Pointer to a FunctionComplexInstance
 */
typedef boost::shared_ptr< FunctionComplexInstance > FunctionComplexPtr;

#endif /* FUNCTION_H_ */
