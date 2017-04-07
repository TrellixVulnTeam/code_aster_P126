#ifndef PHYSICALQUANTITY_H_
#define PHYSICALQUANTITY_H_

/**
 * @file PhysicalQuantity.h
 * @brief Definition of the  Physical Quantities used in Code_Aster
 * @author Natacha Béreux
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

#include <list>
#include <map>
#include <set>
#include <stdexcept> 
#include <string>
#include "astercxx.h"

#include "Utilities/CapyConvertibleValue.h"

/**
 * @enum PhysicalQuantityEnum
 * @brief Inventory of all physical quantities available in Code_Aster
 * @todo attention confusion entre Pressure et Pres
 */
enum PhysicalQuantityEnum { Force, StructuralForce, LocalBeamForce, LocalShellForce, Displacement, Pressure, Temperature, Impedance, NormalSpeed, HeatFlux, HydraulicFlux };

const int nbPhysicalQuantities = 11;

/**
* @def PhysicalQuantityNames
* @brief Aster names of the physical quantities
*/
extern const char* PhysicalQuantityNames[nbPhysicalQuantities];

/**
 * @enum PhysicalQuantityComponent 
 * @brief Inventory of components of the physical quantities listed in PhysicalQuantityEnum 
 */
enum PhysicalQuantityComponent { Dx, Dy, Dz, Drx, Dry, Drz, Temp, MiddleTemp, Pres, Fx, Fy, Fz, Mx, My, Mz, N, Vy, Vz, Mt, Mfy, Mfz, F1, F2, F3, Mf1, Mf2, Impe, Vnor, Flun, FlunHydr1, FlunHydr2 };

const int nbComponent = 31; 
/**
* @def ComponentNames
* @brief Aster names of the components of the physical quantities
*/
extern const char* ComponentNames[nbComponent];

typedef std::vector< PhysicalQuantityComponent > VectorComponent;
extern const VectorComponent allComponents;
extern const VectorString allComponentsNames;

/**
* @class PhysicalQuantityTraits
* @brief Traits class for a Physical Quantity
*/
/* This is the most general case (defined but intentionally not implemented) */
/* It will be specialized for each physical quantity listed in the inventory */
/*
/*
/*************************************************************************/

template < PhysicalQuantityEnum PQ > struct PhysicalQuantityTraits; 

/****************************************/
/*            Force                     */
/****************************************/

/**
 * @def nbForceComponents
 * @brief Number of components specifying a force 
 */
const int nbForceComponents = 3;
/**
 * @def ForceComponents
 * @brief Declare Force Components 
 */
extern const PhysicalQuantityComponent ForceComponents[nbForceComponents];

/** @def PhysicalQuantityTraits <Force>
*  @brief Declare specialization for Force 
*  A Force is defined by its 3 components in the global basis.
*  It is applied to a 3D (or 2D) domain. 
*/

template <> struct PhysicalQuantityTraits< Force >
{
    static const std::set< PhysicalQuantityComponent > components;
    static const std::string name;
    static const PhysicalQuantityEnum type;
};

/****************************************/
/*     StructuralForce                 */
/****************************************/

/**
 * @def nbStructuralForceComponents
 * @brief Number of components specifying a StructuralForce 
 */
const int nbStructuralForceComponents = 6;
/**
 * @def StructuralForceComponents
 * @brief Declare StructuralForce Components 
 */
extern const PhysicalQuantityComponent StructuralForceComponents[nbStructuralForceComponents];

/** @def PhysicalQuantityTraits <StructuralForce>
*  @brief Declare specialization for StructuralForce
* A Structural Force is defined in the global basis. It is applied on structural elements
* (0d, 1d, 2d)
*/

template <> struct PhysicalQuantityTraits< StructuralForce >
{
    static const std::set< PhysicalQuantityComponent > components;
    static const std::string name;
    static const PhysicalQuantityEnum type;
};

/****************************************/
/*     LocalBeamForce                 */
/****************************************/

/**
 * @def nbLocalBeamForceComponents
 * @brief Number of components specifying a LocalBeamForce 
 */
const int nbLocalBeamForceComponents = 6;
/**
 * @def LocalBeamForceComponents
 * @brief Declare Force Components 
 */
extern const PhysicalQuantityComponent LocalBeamForceComponents[nbLocalBeamForceComponents];

/** @def PhysicalQuantityTraits <LocalBeamForce>
*  @brief Declare specialization for LocalBeamForce
* A LocalBeam Force is defined in the local basis of the beam. It is applied on beam elements.
*/

template <> struct PhysicalQuantityTraits< LocalBeamForce >
{
    static const std::set< PhysicalQuantityComponent > components;
    static const std::string name;
    static const PhysicalQuantityEnum type;
};

/****************************************/
/*     LocalShellForce                 */
/****************************************/

/**
 * @def nbLocalShellForceComponents
 * @brief Number of components specifying a LocalShellForce 
 */
const int nbLocalShellForceComponents = 5;
/**
 * @def LocalShellForceComponents
 * @brief Declare Force Components 
 */
extern const PhysicalQuantityComponent LocalShellForceComponents[nbLocalShellForceComponents];

/** @def PhysicalQuantityTraits <LocalShellForce>
*  @brief Declare specialization for LocalShellForce
* A LocalShell Force is defined in the local basis of the plate/shell. It is applied on plate/shell elements.
*/

template <> struct PhysicalQuantityTraits< LocalShellForce >
{
    static const std::set< PhysicalQuantityComponent > components;
    static const std::string name;
    static const PhysicalQuantityEnum type;
};



/****************************************/
/*        Displacement                  */
/****************************************/

/**
 * @def nbDisplComponents
 * @brief Number of components specifying a displacement 
 */
const int nbDisplacementComponents = 6;

/**
 * @def DisplComponents
 * @brief Declare Displacement Components 
 */
extern const PhysicalQuantityComponent DisplacementComponents[nbDisplacementComponents];

template <> struct PhysicalQuantityTraits< Displacement >
{
    static const std::set< PhysicalQuantityComponent > components;
    static const std::string name;
    static const PhysicalQuantityEnum type;
};

/****************************************/
/*        Pressure                      */
/****************************************/

/**
 * @def nbPressureComponents
 * @brief Number of components specifying a pressure
 */
const int nbPressureComponents = 1;

/**
 * @def PressureComponents
 * @brief Declare Pressure Components 
 */
extern const PhysicalQuantityComponent PressureComponents[nbPressureComponents];

template <> struct PhysicalQuantityTraits< Pressure >
{
    static const std::set< PhysicalQuantityComponent > components;
    static const std::string name;
    static const PhysicalQuantityEnum type;
};

/****************************************/
/*        Temperature                   */
/****************************************/

/**
 * @def nbTemperatureComponents
 * @brief Number of components specifying a Temperature
 */
const int nbTemperatureComponents = 2;

/**
 * @def TemperatureComponents
 * @brief Declare Temperature Components 
 */
extern const PhysicalQuantityComponent TemperatureComponents[nbTemperatureComponents];

template <> struct PhysicalQuantityTraits< Temperature >
{
    static const std::set< PhysicalQuantityComponent > components;
    static const std::string name;
    static const PhysicalQuantityEnum type;
};

/****************************************/
/*        Impédance (acoustique)        */
/****************************************/

/**
 * @def nbImpedanceComponents
 * @brief Number of components specifying a Impedance
 */
const int nbImpedanceComponents = 1;

/**
 * @def ImpedanceComponents
 * @brief Declare Impedance Components 
 */
extern const PhysicalQuantityComponent ImpedanceComponents[nbImpedanceComponents];

template <> struct PhysicalQuantityTraits< Impedance >
{
    static const std::set< PhysicalQuantityComponent > components;
    static const std::string name;
    static const PhysicalQuantityEnum type;
};

/****************************************/
/*        Vitesse Normale (acoustique)  */
/****************************************/

/**
 * @def nbNormalSpeedComponents
 * @brief Number of components specifying a NormalSpeed
 */
const int nbNormalSpeedComponents = 1;

/**
 * @def NormalSpeedComponents
 * @brief Declare NormalSpeed Components 
 */
extern const PhysicalQuantityComponent NormalSpeedComponents[nbNormalSpeedComponents];

template <> struct PhysicalQuantityTraits< NormalSpeed >
{
    static const std::set< PhysicalQuantityComponent > components;
    static const std::string name;
    static const PhysicalQuantityEnum type;
};

/****************************************/
/*        Flux de Chaleur (THM)         */
/****************************************/

/**
 * @def nbHeatFluxComponents
 * @brief Number of components specifying a HeatFlux
 */
const int nbHeatFluxComponents = 1;

/**
 * @def HeatFluxComponents
 * @brief Declare HeatFlux Components 
 */
extern const PhysicalQuantityComponent HeatFluxComponents[nbHeatFluxComponents];

template <> struct PhysicalQuantityTraits< HeatFlux >
{
    static const std::set< PhysicalQuantityComponent > components;
    static const std::string name;
    static const PhysicalQuantityEnum type;
};

/****************************************/
/*        Flux Hydraulique (THM)         */
/****************************************/

/**
 * @def nbHydraulicFluxComponents
 * @brief Number of components specifying a HydraulicFlux
 */
const int nbHydraulicFluxComponents = 2;

/**
 * @def HydraulicFluxComponents
 * @brief Declare HydraulicFlux Components 
 */
extern const PhysicalQuantityComponent HydraulicFluxComponents[nbHydraulicFluxComponents];

template <> struct PhysicalQuantityTraits< HydraulicFlux >
{
    static const std::set< PhysicalQuantityComponent > components;
    static const std::string name;
    static const PhysicalQuantityEnum type;
};


/******************************************/
/* @class PhysicalQuantityInstance
/* @brief Defines a physical quantity 
/******************************************/

template< class ValueType, PhysicalQuantityEnum PhysicalQuantity >
class PhysicalQuantityInstance
{
    /** @brief Conteneur des mots-clés avec traduction */
    CapyConvertibleContainer _toCapyConverter;

    public:
    /** @typedef Define the Traits type */
    typedef PhysicalQuantityTraits<PhysicalQuantity> Traits;
    /** @typedef Value type of the physical quantity (double, function ...) */
    typedef ValueType QuantityType;
    /** @typedef Components and Values of the PhysicalQuantityInstance */
    typedef typename std::map< PhysicalQuantityComponent, QuantityType > MapOfCompAndVal;
    typedef typename MapOfCompAndVal::iterator MapIt;
    typedef typename std::pair<PhysicalQuantityComponent, QuantityType> CompAndVal;

    /* @def  _compAndVal Components and Values  */
    MapOfCompAndVal          _compAndVal;
    std::vector< ValueType > _values;

    /** 
    * @brief Constructor
    */
    PhysicalQuantityInstance(){};

    /**
    * @brief Destructor
    */
     ~PhysicalQuantityInstance(){};

    /**
    * @function hasComponent
    * @brief test if a component is authorized for the physical quantity
    */
    
    static bool hasComponent( PhysicalQuantityComponent comp )
    {
        if ( Traits::components.find( comp ) == Traits::components.end() ) return false;
        return true;
    }

    void setValue( PhysicalQuantityComponent comp, QuantityType val )
        throw( std::runtime_error )
    {
        if ( ! hasComponent( comp ) ) 
        {
            throw std::runtime_error( "This component is not allowed for the current Physical Quantity" );
        }
        // On teste le retour de map.insert pour savoir si le terme existe déjà */ 
        std::pair< MapIt , bool> ret = _compAndVal.insert( CompAndVal( comp, val ) );
        if (! ret.second )
        {
            // S'il existe déjà, on le retire et on le remplace par un nouveau */
            _compAndVal.erase( comp );
            _compAndVal.insert( CompAndVal( comp, val ) ); 
        }
        _values.push_back( val );
        _toCapyConverter.add( new CapyConvertibleValue< QuantityType >
                                                      ( false, ComponentNames[ (int)comp ],
                                                        _values[ _values.size()-1 ], true ) );
    }

    /**
     * @brief debugPrint 
     */
    void debugPrint() const
    {
        std::cout << "Nom de la grandeur physique : " << Traits::name << std::endl; 
        std::cout << "Nb de composantes   : " << Traits::components.size() << std::endl;
        std::cout << "Nom des composantes : " ;
        for (std::set<PhysicalQuantityComponent>::iterator it(Traits::components.begin());
             it!=Traits::components.end(); it++)
        {
            std::cout << ComponentNames[*it] << " , " ;
        }
        std::cout << std::endl; 
        for ( typename MapOfCompAndVal::const_iterator it(_compAndVal.begin());
              it!= _compAndVal.end(); it++)
        {
            std::cout << ComponentNames[it->first] << " : " << it->second << std::endl; 
        }
    };

    /**
     * @brief getMap
     * @return Map storing components and values of the physical quantity 
     */
    const MapOfCompAndVal& getMap() const
    {
        return _compAndVal;
    };

    const CapyConvertibleContainer& getCapyConvertibleContainer() const
    {
        return _toCapyConverter;
    };

    /**
    * @brief get the name of the PhysicalQuantity
    */
    std::string getName() const
    {
        return Traits::name; 
    };
};


/**********************************************************/
/*  Explicit instantiation of template classes
/**********************************************************/

/** @typedef ForceDouble FORC_R */
template class PhysicalQuantityInstance< double, Force >; 
typedef PhysicalQuantityInstance< double, Force > ForceDoubleInstance;
typedef std::shared_ptr< ForceDoubleInstance > ForceDoublePtr; 

/** @typedef StructuralForceDouble  */
template class PhysicalQuantityInstance< double, StructuralForce >; 
typedef PhysicalQuantityInstance< double, StructuralForce > StructuralForceDoubleInstance;
typedef std::shared_ptr< StructuralForceDoubleInstance > StructuralForceDoublePtr; 

/** @typedef LocalBeamForceDouble  */
template class PhysicalQuantityInstance< double, LocalBeamForce >; 
typedef PhysicalQuantityInstance< double, LocalBeamForce > LocalBeamForceDoubleInstance;
typedef std::shared_ptr< LocalBeamForceDoubleInstance > LocalBeamForceDoublePtr; 

/** @typedef LocalShellForceDouble  */
template class PhysicalQuantityInstance< double, LocalShellForce >; 
typedef PhysicalQuantityInstance< double, LocalShellForce > LocalShellForceDoubleInstance;
typedef std::shared_ptr< LocalShellForceDoubleInstance > LocalShellForceDoublePtr; 

/** @typedef DisplacementDouble DEPL_R */
template class PhysicalQuantityInstance< double, Displacement >; 
typedef PhysicalQuantityInstance< double, Displacement > DisplacementDoubleInstance;
typedef std::shared_ptr< DisplacementDoubleInstance > DisplacementDoublePtr; 

/** @typedef PressureDouble Pression */
template class PhysicalQuantityInstance< double, Pressure >; 
typedef PhysicalQuantityInstance< double, Pressure > PressureDoubleInstance;
typedef std::shared_ptr< PressureDoubleInstance > PressureDoublePtr; 

/** @typedef PressureComplex Pression */
template class PhysicalQuantityInstance< DoubleComplex, Pressure >; 
typedef PhysicalQuantityInstance< DoubleComplex, Pressure > PressureComplexInstance;
typedef std::shared_ptr< PressureComplexInstance > PressureComplexPtr; 

/** @typedef TemperatureDouble Temperature */
template class PhysicalQuantityInstance< double, Temperature >; 
typedef PhysicalQuantityInstance< double, Temperature > TemperatureDoubleInstance;
typedef std::shared_ptr< TemperatureDoubleInstance > TemperatureDoublePtr;

/** @typedef ImpedanceDouble Impedance */
template class PhysicalQuantityInstance< double, Impedance >; 
typedef PhysicalQuantityInstance< double, Impedance > ImpedanceDoubleInstance;
typedef std::shared_ptr< ImpedanceDoubleInstance > ImpedanceDoublePtr;

/** @typedef ImpedanceComplex Impedance */
template class PhysicalQuantityInstance< DoubleComplex, Impedance >; 
typedef PhysicalQuantityInstance< DoubleComplex, Impedance > ImpedanceComplexInstance;
typedef std::shared_ptr< ImpedanceComplexInstance > ImpedanceComplexPtr; 

/** @typedef NormalSpeedDouble Normal Speed  */
template class PhysicalQuantityInstance< double, NormalSpeed >; 
typedef PhysicalQuantityInstance< double, NormalSpeed > NormalSpeedDoubleInstance;
typedef std::shared_ptr< NormalSpeedDoubleInstance > NormalSpeedDoublePtr; 

/** @typedef NormalSpeedComplex Normal Speed  */
template class PhysicalQuantityInstance< DoubleComplex, NormalSpeed >; 
typedef PhysicalQuantityInstance< DoubleComplex, NormalSpeed > NormalSpeedComplexInstance;
typedef std::shared_ptr< NormalSpeedComplexInstance > NormalSpeedComplexPtr; 

/** @typedef HeatFluxDouble Normal Speed  */
template class PhysicalQuantityInstance< double, HeatFlux >; 
typedef PhysicalQuantityInstance< double, HeatFlux > HeatFluxDoubleInstance;
typedef std::shared_ptr< HeatFluxDoubleInstance > HeatFluxDoublePtr; 

/** @typedef HydraulicFluxDouble Normal Speed  */
template class PhysicalQuantityInstance< double, HydraulicFlux >; 
typedef PhysicalQuantityInstance< double, HydraulicFlux > HydraulicFluxDoubleInstance;
typedef std::shared_ptr< HydraulicFluxDoubleInstance > HydraulicFluxDoublePtr; 
#endif /* PHYSICALQUANTITY_H_ */
