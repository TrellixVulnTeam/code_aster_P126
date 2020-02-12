#ifndef MATERIALBEHAVIOUR_H_
#define MATERIALBEHAVIOUR_H_

/**
 * @file MaterialBehaviour.h
 * @brief Fichier entete de la classe MaterialBehaviour
 * @author Nicolas Sellenet
 * @section LICENCE
 *   Copyright (C) 1991 - 2020  EDF R&D                www.code-aster.org
 *
 *   This file is part of Code_Aster.
 *
 *   Code_Aster is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
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

#include <iomanip>
#include <map>
#include <sstream>
#include <string>

#include "DataFields/Table.h"
#include "Functions/Formula.h"
#include "Functions/Function.h"
#include "Functions/Surface.h"
#include "MemoryManager/JeveuxVector.h"
#include "aster_utils.h"
#include "astercxx.h"

extern "C" {
void CopyCStrToFStr( char *, char *, STRING_SIZE );
}

typedef std::vector< FunctionPtr > VectorFunction;

/**
 * @class ConvertibleValue
 * @brief Cette classe template permet de definir une variable convertible
 * @author Nicolas Sellenet
 */
template < class ValueType1, class ValueType2 > class ConvertibleValue {
  public:
    typedef ValueType2 ReturnValue;
    typedef ValueType1 BaseValue;

  private:
    typedef std::map< ValueType1, ValueType2 > mapVal1Val2;
    /** @brief map allowing conversion of ValueType1 into ValueType2 */
    mapVal1Val2 _matchMap;
    /** @brief value to convert */
    ValueType1 _valToConvert;
    /** @brief To know if value is set */
    bool _existsValue;

  public:
    ConvertibleValue() : _existsValue( false ){};

    ConvertibleValue( const mapVal1Val2 &matchMap )
        : _matchMap( matchMap ), _existsValue( false ){};

    ConvertibleValue( const mapVal1Val2 &matchMap, const ValueType1 &val )
        : _matchMap( matchMap ), _valToConvert( val ), _existsValue( true ){};

    void operator=( const ValueType1 &toSet ) {
        _existsValue = true;
        _valToConvert = toSet;
    };

    /**
     * @brief Recuperation de la valeur du parametre
     * @return la valeur du parametre
     */
    const ReturnValue &getValue() const {
        const auto &curIter = _matchMap.find( _valToConvert );
        if ( curIter == _matchMap.end() )
            throw std::runtime_error( "Impossible to convert " + _valToConvert );
        return curIter->second; //_matchMap[ _valToConvert ];
    };

    /**
     * @brief Is value already set ?
     */
    bool hasValue() const { return _existsValue; };

    /**
     * @brief Is value convertible (regarding the map of conversion) ?
     */
    bool isConvertible() const {
        if ( !_existsValue )
            return false;
        const auto &curIter = _matchMap.find( _valToConvert );
        if ( curIter == _matchMap.end() )
            return false;
        return true;
    };
};

typedef ConvertibleValue< std::string, double > StringToRealValue;

/**
 * @struct template AllowedMaterialPropertyType
 * @brief Structure permettant de limiter le type instanciable de MaterialPropertyClass
 * @author Nicolas Sellenet
 */
template < typename T > struct AllowedMaterialPropertyType;

template <> struct AllowedMaterialPropertyType< double > {};

template <> struct AllowedMaterialPropertyType< RealComplex > {};

template <> struct AllowedMaterialPropertyType< std::string > {};

template <> struct AllowedMaterialPropertyType< FunctionPtr > {};

template <> struct AllowedMaterialPropertyType< TablePtr > {};

template <> struct AllowedMaterialPropertyType< SurfacePtr > {};

template <> struct AllowedMaterialPropertyType< FormulaPtr > {};

template <> struct AllowedMaterialPropertyType< GenericFunctionPtr > {};

template <> struct AllowedMaterialPropertyType< VectorReal > {};

template <> struct AllowedMaterialPropertyType< VectorFunction > {};

template <> struct AllowedMaterialPropertyType< StringToRealValue > {};

class GeneralMaterialBehaviourClass;

template < typename T1 > struct is_convertible;

template < class T > struct is_convertible {
    typedef T value_type;
    typedef T init_value;
};

template <> struct is_convertible< StringToRealValue > {
    typedef typename StringToRealValue::ReturnValue value_type;
    typedef typename StringToRealValue::BaseValue init_value;
};

/**
 * @class MaterialPropertyClass
 * @brief Cette classe template permet de definir un type elementaire de propriete materielle
 * @author Nicolas Sellenet
 * @todo on pourrait detemplatiser cette classe pour qu'elle prenne soit des doubles soit des fct
 *       on pourrait alors fusionner elas et elasFo par exemple
 */
template < class ValueType >
class MaterialPropertyClass : private AllowedMaterialPropertyType< ValueType > {
  public:
    typedef typename is_convertible< ValueType >::value_type ReturnValue;
    typedef typename is_convertible< ValueType >::init_value BaseValue;

  protected:
    /** @brief Nom Aster du type elementaire de propriete materielle */
    // ex : "NU" pour le coefficient de Poisson
    std::string _name;
    /** @brief Booleen qui precise si la propriété est obligatoire */
    bool _isMandatory;
    /** @brief Description de parametre, ex : "Young's modulus" */
    std::string _description;
    /** @brief Valeur du parametre (double, FunctionPtr, ...) */
    ValueType _value;
    /** @brief Booleen qui precise si la propriété a été initialisée */
    bool _existsValue;

  public:
    /**
     * @brief Constructeur vide (utile pour ajouter une MaterialPropertyClass a une std::map
     */
    MaterialPropertyClass(){};

    /**
     * @brief Constructeur
     * @param name Nom Aster du parametre materiau (ex : "NU")
     * @param description Description libre
     */
    MaterialPropertyClass( const std::string name, const bool isMandatory )
        : _name( name ), _isMandatory( isMandatory ), _description( "" ), _existsValue( false ){};

    /**
     * @brief Constructeur
     * @param name Nom Aster du parametre materiau (ex : "NU")
     * @param ValueType Valeur par défaut
     * @param description Description libre
     */
    MaterialPropertyClass( const std::string name, const ValueType &currentValue,
                              const bool isMandatory )
        : _name( name ), _isMandatory( isMandatory ), _description( "" ), _value( currentValue ),
          _existsValue( true ){};

    /**
     * @brief Recuperation de la valeur du parametre
     * @return le nom Aster du parametre
     */
    const std::string &getName() const { return _name; };

    /**
     * @brief Recuperation de la valeur du parametre
     * @return la valeur du parametre
     */
    template < typename T = ValueType >
    typename std::enable_if< std::is_same< T, StringToRealValue >::value,
                             const ReturnValue & >::type
    getValue() const {
        return _value.getValue();
    };

    /**
     * @brief Recuperation de la valeur du parametre
     * @return la valeur du parametre
     */
    template < typename T = ValueType >
    typename std::enable_if< !std::is_same< T, StringToRealValue >::value,
                             const ReturnValue & >::type
    getValue() const {
        return _value;
    };

    /**
     * @brief Cette propriété est-elle obligatoire ?
     * @return true si la propriété est obligatoire
     */
    bool isMandatory() const { return _isMandatory; };

    /**
     * @brief Cette propriété a-t-elle une valeur fixée par l'utilisateur ?
     * @return true si la valeur a été précisée
     */
    template < typename T = ValueType >
    typename std::enable_if< std::is_same< T, StringToRealValue >::value, bool >::type
    hasValue() const {
        return _value.hasValue();
    };

    /**
     * @brief Cette propriété a-t-elle une valeur fixée par l'utilisateur ?
     * @return true si la valeur a été précisée
     */
    template < typename T = ValueType >
    typename std::enable_if< !std::is_same< T, StringToRealValue >::value, bool >::type
    hasValue() const {
        return _existsValue;
    };

    /**
     * @brief Fonction servant a fixer la valeur du parametre
     * @param currentValue valeur donnee par l'utilisateur
     */
    void setValue( BaseValue currentValue ) {
        _existsValue = true;
        _value = currentValue;
    };

    friend class GeneralMaterialBehaviourClass;
};

/** @typedef Definition d'une propriete materiau de type double */
typedef MaterialPropertyClass< double > ElementaryMaterialPropertyReal;
/** @typedef Definition d'une propriete materiau de type double */
typedef MaterialPropertyClass< RealComplex > ElementaryMaterialPropertyComplex;
/** @typedef Definition d'une propriete materiau de type string */
typedef MaterialPropertyClass< std::string > ElementaryMaterialPropertyString;
/** @typedef Definition d'une propriete materiau de type Function */
typedef MaterialPropertyClass< FunctionPtr > ElementaryMaterialPropertyFunction;
/** @typedef Definition d'une propriete materiau de type Table */
typedef MaterialPropertyClass< TablePtr > ElementaryMaterialPropertyTable;
/** @typedef Definition d'une propriete materiau de type Surface */
typedef MaterialPropertyClass< SurfacePtr > ElementaryMaterialPropertySurface;
/** @typedef Definition d'une propriete materiau de type Formula */
typedef MaterialPropertyClass< FormulaPtr > ElementaryMaterialPropertyFormula;
/** @typedef Definition d'une propriete materiau de type DataStructure */
typedef MaterialPropertyClass< GenericFunctionPtr > ElementaryMaterialPropertyDataStructure;
/** @typedef Definition d'une propriete materiau de type vector double */
typedef MaterialPropertyClass< VectorReal > ElementaryMaterialPropertyVectorReal;
/** @typedef Definition d'une propriete materiau de type vector Function */
typedef MaterialPropertyClass< std::vector< FunctionPtr > >
    ElementaryMaterialPropertyVectorFunction;
/** @typedef Definition d'une propriete materiau de type Convertible string double */
typedef MaterialPropertyClass< StringToRealValue > ElementaryMaterialPropertyConvertible;

/**
 * @class GeneralMaterialBehaviourClass
 * @brief Cette classe permet de definir un ensemble de type elementaire de propriete materielle
 * @author Nicolas Sellenet
 */
class GeneralMaterialBehaviourClass {
  protected:
    /** @typedef std::map d'une chaine et d'un ElementaryMaterialPropertyReal */
    typedef std::map< std::string, ElementaryMaterialPropertyReal > mapStrEMPD;
    /** @typedef Iterateur sur mapStrEMPD */
    typedef mapStrEMPD::iterator mapStrEMPDIterator;
    typedef mapStrEMPD::const_iterator mapStrEMPDConstIterator;
    /** @typedef Valeur contenue dans un mapStrEMPD */
    typedef mapStrEMPD::value_type mapStrEMPDValue;

    /** @typedef std::map d'une chaine et d'un ElementaryMaterialPropertyComplex */
    typedef std::map< std::string, ElementaryMaterialPropertyComplex > mapStrEMPC;
    /** @typedef Iterateur sur mapStrEMPC */
    typedef mapStrEMPC::iterator mapStrEMPCIterator;
    typedef mapStrEMPC::const_iterator mapStrEMPCConstIterator;
    /** @typedef Valeur contenue dans un mapStrEMPC */
    typedef mapStrEMPC::value_type mapStrEMPCValue;

    /** @typedef std::map d'une chaine et d'un ElementaryMaterialPropertyString */
    typedef std::map< std::string, ElementaryMaterialPropertyString > mapStrEMPS;
    /** @typedef Iterateur sur mapStrEMPS */
    typedef mapStrEMPS::iterator mapStrEMPSIterator;
    typedef mapStrEMPS::const_iterator mapStrEMPSConstIterator;
    /** @typedef Valeur contenue dans un mapStrEMPS */
    typedef mapStrEMPS::value_type mapStrEMPSValue;

    /** @typedef std::map d'une chaine et d'un ElementaryMaterialPropertyDataStructure */
    typedef std::map< std::string, ElementaryMaterialPropertyDataStructure > mapStrEMPF;
    /** @typedef Iterateur sur mapStrEMPF */
    typedef mapStrEMPF::iterator mapStrEMPFIterator;
    typedef mapStrEMPF::const_iterator mapStrEMPFConstIterator;
    /** @typedef Valeur contenue dans un mapStrEMPF */
    typedef mapStrEMPF::value_type mapStrEMPFValue;

    /** @typedef std::map d'une chaine et d'un ElementaryMaterialPropertyTable */
    typedef std::map< std::string, ElementaryMaterialPropertyTable > mapStrEMPT;
    /** @typedef Iterateur sur mapStrEMPT */
    typedef mapStrEMPT::iterator mapStrEMPTIterator;
    typedef mapStrEMPT::const_iterator mapStrEMPTConstIterator;
    /** @typedef Valeur contenue dans un mapStrEMPT */
    typedef mapStrEMPT::value_type mapStrEMPTValue;

    /** @typedef std::map d'une chaine et d'un ElementaryMaterialPropertyVectorReal */
    typedef std::map< std::string, ElementaryMaterialPropertyVectorReal > mapStrEMPVD;
    /** @typedef Iterateur sur mapStrEMPVD */
    typedef mapStrEMPVD::iterator mapStrEMPVDIterator;
    typedef mapStrEMPVD::const_iterator mapStrEMPVDConstIterator;
    /** @typedef Valeur contenue dans un mapStrEMPVD */
    typedef mapStrEMPVD::value_type mapStrEMPVDValue;

    /** @typedef std::map d'une chaine et d'un ElementaryMaterialPropertyVectorFunction */
    typedef std::map< std::string, ElementaryMaterialPropertyVectorFunction > mapStrEMPVF;
    /** @typedef Iterateur sur mapStrEMPVF */
    typedef mapStrEMPVF::iterator mapStrEMPVFIterator;
    typedef mapStrEMPVF::const_iterator mapStrEMPVFConstIterator;
    /** @typedef Valeur contenue dans un mapStrEMPVF */
    typedef mapStrEMPVF::value_type mapStrEMPVFValue;

    /** @typedef std::map d'une chaine et d'un ElementaryMaterialPropertyConvertible */
    typedef std::map< std::string, ElementaryMaterialPropertyConvertible > mapStrEMPCSD;
    /** @typedef Iterateur sur mapStrEMPCSD */
    typedef mapStrEMPCSD::iterator mapStrEMPCSDIterator;
    typedef mapStrEMPCSD::const_iterator mapStrEMPCSDConstIterator;
    /** @typedef Valeur contenue dans un mapStrEMPCSD */
    typedef mapStrEMPCSD::value_type mapStrEMPCSDValue;

    /** @typedef std::list< std::string > */
    typedef std::list< std::string > ListString;
    typedef ListString::iterator ListStringIter;
    typedef ListString::const_iterator ListStringConstIter;

    /** @brief Chaine correspondant au nom Aster du MaterialBehaviourClass */
    // ex : ELAS ou ELASFo
    std::string _asterName;
    std::string _asterNewName;
    /** @brief Map contenant les noms des proprietes double ainsi que les
               MaterialPropertyClass correspondant */
    mapStrEMPD _mapOfRealMaterialProperties;
    /** @brief Map contenant les noms des proprietes complex ainsi que les
               MaterialPropertyClass correspondant */
    mapStrEMPC _mapOfComplexMaterialProperties;
    /** @brief Map contenant les noms des proprietes chaine ainsi que les
               MaterialPropertyClass correspondant */
    mapStrEMPS _mapOfStringMaterialProperties;
    /** @brief Map contenant les noms des proprietes function ainsi que les
               MaterialPropertyClass correspondant */
    mapStrEMPF _mapOfFunctionMaterialProperties;
    /** @brief Map contenant les noms des proprietes table ainsi que les
               MaterialPropertyClass correspondant */
    mapStrEMPT _mapOfTableMaterialProperties;
    /** @brief Map contenant les noms des proprietes vector double ainsi que les
               MaterialPropertyClass correspondant */
    mapStrEMPVD _mapOfVectorRealMaterialProperties;
    /** @brief Map contenant les noms des proprietes vector Function ainsi que les
               MaterialPropertyClass correspondant */
    mapStrEMPVF _mapOfVectorFunctionMaterialProperties;
    /** @brief Map contenant les noms des proprietes double ainsi que les
               MaterialPropertyClass correspondant */
    mapStrEMPCSD _mapOfConvertibleMaterialProperties;
    /** @brief Liste contenant les infos du .ORDR */
    VectorString _vectOrdr;
    /** @brief Vector of ordered keywords */
    VectorString _vectKW;

  public:
    /**
     * @brief Constructeur
     */
    GeneralMaterialBehaviourClass() : _asterNewName( "" ){};

    /**
     * @brief Constructeur
     */
    GeneralMaterialBehaviourClass( const std::string asterName,
                                      const std::string asterNewName = "" )
        : _asterName( asterName ), _asterNewName( asterNewName ){};

    /**
     * @brief Recuperation du nom Aster du GeneralMaterialBehaviourClass
     *        ex : 'ELAS', 'ELASFo', ...
     * @return Chaine contenant le nom Aster
     */
    const std::string getAsterName() const { return _asterName; };

    const std::string getAsterNewName() const { return _asterNewName; };

    /**
     * @brief Get number of properties containing a list of doubles
     */
    int getNumberOfListOfRealProperties() const {
        return _mapOfVectorRealMaterialProperties.size();
    };

    /**
     * @brief Get number of properties containing a list of functions
     */
    int getNumberOfListOfFunctionProperties() const {
        return _mapOfVectorFunctionMaterialProperties.size();
    };

    double getRealValue( std::string nameOfProperty )
    {
        auto curIter = _mapOfRealMaterialProperties.find( nameOfProperty );
        if ( curIter != _mapOfRealMaterialProperties.end() )
            return ( *curIter ).second.getValue();
        throw std::runtime_error( nameOfProperty + " is not a double value" );
    };

    RealComplex getComplexValue( std::string nameOfProperty )
    {
        auto curIter = _mapOfComplexMaterialProperties.find( nameOfProperty );
        if ( curIter != _mapOfComplexMaterialProperties.end() )
            return ( *curIter ).second.getValue();
        throw std::runtime_error( nameOfProperty + " is not a complex value" );
    };

    std::string getStringValue( std::string nameOfProperty )
    {
        auto curIter = _mapOfStringMaterialProperties.find( nameOfProperty );
        if ( curIter != _mapOfStringMaterialProperties.end() )
            return ( *curIter ).second.getValue();
        throw std::runtime_error( nameOfProperty + " is not a string value" );
    };

    GenericFunctionPtr getGenericFunctionValue( std::string nameOfProperty )
    {
        auto curIter = _mapOfFunctionMaterialProperties.find( nameOfProperty );
        if ( curIter != _mapOfFunctionMaterialProperties.end() )
            return ( *curIter ).second.getValue();
        throw std::runtime_error( nameOfProperty + " is not a function value" );
    };

    TablePtr getTableValue( std::string nameOfProperty )
    {
        auto curIter = _mapOfTableMaterialProperties.find( nameOfProperty );
        if ( curIter != _mapOfTableMaterialProperties.end() )
            return ( *curIter ).second.getValue();
        throw std::runtime_error( nameOfProperty + " is not a table value" );
    };

    double hasRealValue( std::string nameOfProperty )
    {
        auto curIter = _mapOfRealMaterialProperties.find( nameOfProperty );
        if ( curIter == _mapOfRealMaterialProperties.end() )
            return false;
        return true;
    };

    bool hasComplexValue( std::string nameOfProperty )
    {
        auto curIter = _mapOfComplexMaterialProperties.find( nameOfProperty );
        if ( curIter == _mapOfComplexMaterialProperties.end() )
            return false;
        return true;
    };

    bool hasStringValue( std::string nameOfProperty )
    {
        auto curIter = _mapOfStringMaterialProperties.find( nameOfProperty );
        if ( curIter == _mapOfStringMaterialProperties.end() )
            return false;
        return true;
    };

    bool hasGenericFunctionValue( std::string nameOfProperty )
    {
        auto curIter = _mapOfFunctionMaterialProperties.find( nameOfProperty );
        if ( curIter == _mapOfFunctionMaterialProperties.end() )
            return false;
        return true;
    };

    bool hasTableValue( std::string nameOfProperty )
    {
        auto curIter = _mapOfTableMaterialProperties.find( nameOfProperty );
        if ( curIter == _mapOfTableMaterialProperties.end() )
            return false;
        return true;
    };

    /**
     * @brief Get number of properties with a value
     */
    int getNumberOfPropertiesWithValue() const;

    /**
     * @brief Fonction servant a fixer un parametre materiau au GeneralMaterialBehaviourClass
     * @param nameOfProperty Nom de la propriete
     * @param value Real correspondant a la valeur donnee par l'utilisateur
     * @return Booleen valant true si la tache s'est bien deroulee
     */
    bool setRealValue( std::string nameOfProperty, double value ) {
        // Recherche de la propriete materielle
        mapStrEMPDIterator curIter = _mapOfRealMaterialProperties.find( nameOfProperty );
        if ( curIter == _mapOfRealMaterialProperties.end() )
            return false;
        // Ajout de la valeur
        ( *curIter ).second.setValue( value );
        return true;
    };

    /**
     * @brief Fonction servant a fixer un parametre materiau au GeneralMaterialBehaviourClass
     * @param nameOfProperty Nom de la propriete
     * @param value Real correspondant a la valeur donnee par l'utilisateur
     * @return Booleen valant true si la tache s'est bien deroulee
     */
    bool setComplexValue( std::string nameOfProperty, RealComplex value ) {
        // Recherche de la propriete materielle
        mapStrEMPCIterator curIter = _mapOfComplexMaterialProperties.find( nameOfProperty );
        if ( curIter == _mapOfComplexMaterialProperties.end() )
            return false;
        // Ajout de la valeur
        ( *curIter ).second.setValue( value );
        return true;
    };

    /**
     * @brief Fonction servant a fixer un parametre materiau au GeneralMaterialBehaviourClass
     * @param nameOfProperty Nom de la propriete
     * @param value string correspondant a la valeur donnee par l'utilisateur
     * @return Booleen valant true si la tache s'est bien deroulee
     */
    bool setStringValue( std::string nameOfProperty, std::string value ) {
        // Recherche de la propriete materielle dans les Convertible
        const auto &curIter = _mapOfConvertibleMaterialProperties.find( nameOfProperty );
        if ( curIter != _mapOfConvertibleMaterialProperties.end() ) {
            ( *curIter ).second.setValue( value );
            return true;
        }

        // Recherche de la propriete materielle
        mapStrEMPSIterator curIter2 = _mapOfStringMaterialProperties.find( nameOfProperty );
        if ( curIter2 == _mapOfStringMaterialProperties.end() )
            return false;
        // Ajout de la valeur
        ( *curIter2 ).second.setValue( value );
        return true;
    };

    /**
     * @brief Fonction servant a fixer un parametre materiau au GeneralMaterialBehaviourClass
     * @param nameOfProperty Nom de la propriete
     * @param value Function correspondant a la valeur donnee par l'utilisateur
     * @return Booleen valant true si la tache s'est bien deroulee
     */
    bool setFunctionValue( std::string nameOfProperty, FunctionPtr value ) {
        // Recherche de la propriete materielle
        mapStrEMPFIterator curIter = _mapOfFunctionMaterialProperties.find( nameOfProperty );
        if ( curIter == _mapOfFunctionMaterialProperties.end() )
            return false;
        // Ajout de la valeur
        _mapOfFunctionMaterialProperties[nameOfProperty].setValue( value );
        return true;
    };

    /**
     * @brief Fonction servant a fixer un parametre materiau au GeneralMaterialBehaviourClass
     * @param nameOfProperty Nom de la propriete
     * @param value Table correspondant a la valeur donnee par l'utilisateur
     * @return Booleen valant true si la tache s'est bien deroulee
     */
    bool setTableValue( std::string nameOfProperty, TablePtr value ) {
        // Recherche de la propriete materielle
        mapStrEMPTIterator curIter = _mapOfTableMaterialProperties.find( nameOfProperty );
        if ( curIter == _mapOfTableMaterialProperties.end() )
            return false;
        // Ajout de la valeur
        ( *curIter ).second.setValue( value );
        return true;
    };

    /**
     * @brief Fonction servant a fixer un parametre materiau au GeneralMaterialBehaviourClass
     * @param nameOfProperty Nom de la propriete
     * @param value Surface correspondant a la valeur donnee par l'utilisateur
     * @return Booleen valant true si la tache s'est bien deroulee
     */
    bool setSurfaceValue( std::string nameOfProperty, SurfacePtr value ) {
        // Recherche de la propriete materielle
        mapStrEMPFIterator curIter = _mapOfFunctionMaterialProperties.find( nameOfProperty );
        if ( curIter == _mapOfFunctionMaterialProperties.end() )
            return false;
        // Ajout de la valeur
        _mapOfFunctionMaterialProperties[nameOfProperty].setValue( value );
        return true;
    };

    /**
     * @brief Fonction servant a fixer un parametre materiau au GeneralMaterialBehaviourClass
     * @param nameOfProperty Nom de la propriete
     * @param value Formula correspondant a la valeur donnee par l'utilisateur
     * @return Booleen valant true si la tache s'est bien deroulee
     */
    bool setFormulaValue( std::string nameOfProperty, FormulaPtr value ) {
        // Recherche de la propriete materielle
        mapStrEMPFIterator curIter = _mapOfFunctionMaterialProperties.find( nameOfProperty );
        if ( curIter == _mapOfFunctionMaterialProperties.end() )
            return false;
        // Ajout de la valeur
        _mapOfFunctionMaterialProperties[nameOfProperty].setValue( value );
        return true;
    };

    /**
     * @brief Fonction servant a fixer un parametre materiau au GeneralMaterialBehaviourClass
     * @param nameOfProperty Nom de la propriete
     * @param value VectorReal correspondant a la valeur donnee par l'utilisateur
     * @return Booleen valant true si la tache s'est bien deroulee
     */
    bool setVectorOfRealValue( std::string nameOfProperty, const VectorReal &value ) {
        // Recherche de la propriete materielle
        auto curIter = _mapOfVectorRealMaterialProperties.find( nameOfProperty );
        if ( curIter == _mapOfVectorRealMaterialProperties.end() )
            return false;
        // Ajout de la valeur
        ( *curIter ).second._value = value;
        ( *curIter ).second._existsValue = true;
        return true;
    };

    /**
     * @brief Fonction servant a fixer un parametre materiau au GeneralMaterialBehaviourClass
     * @param nameOfProperty Nom de la propriete
     * @param value VectorFunction correspondant a la valeur donnee par l'utilisateur
     * @return Booleen valant true si la tache s'est bien deroulee
     */
    bool setVectorOfFunctionValue( std::string nameOfProperty, VectorFunction value ) {
        // Recherche de la propriete materielle
        auto curIter = _mapOfVectorFunctionMaterialProperties.find( nameOfProperty );
        if ( curIter == _mapOfVectorFunctionMaterialProperties.end() )
            return false;
        // Ajout de la valeur
        ( *curIter ).second._value = value;
        ( *curIter ).second._existsValue = true;
        return true;
    };

    /**
     * @brief Fonction permettant de définir le .ORDR
     * @param values Vecteur correspondant au mot clé ORDRE_PARAM
     * @return Booleen valant true si la tache s'est bien deroulee
     */
    bool setSortedListParameters( VectorString values ) {
        _vectOrdr = values;
        return true;
    };

    /**
     * @brief Construction du GeneralMaterialBehaviourClass
     * @return Booleen valant true si la tache s'est bien deroulee
     * @todo vérifier les valeurs réelles par défaut du .VALR
     */
    virtual bool buildJeveuxVectors( JeveuxVectorComplex &complexValues,
                                     JeveuxVectorReal &doubleValues,
                                     JeveuxVectorChar16 &char16Values, JeveuxVectorChar16 &ordr,
                                     JeveuxVectorLong &kOrdr, std::vector< JeveuxVectorReal > &,
                                     std::vector< JeveuxVectorChar8 > & );

    /**
     * @brief Build ".RDEP" if necessary
     * @return true
     */
    virtual bool buildTractionFunction( FunctionPtr &doubleValues ) const;

    /**
     * @brief Function to know if ".RDEP" is necessary
     * @return true if ".RDEP" is necessary
     */
    virtual bool hasTractionFunction() const { return false; };

    /**
     * @brief Function to know if material own a function for enthalpy
     */
    virtual bool hasEnthalpyFunction() const { return false; };

    /**
     * @brief Function to know if behaviour own a list of double parameter
     */
    bool hasVectorOfRealParameters() const {
        if ( _mapOfVectorRealMaterialProperties.size() != 0 )
            return true;
        return false;
    };

    /**
     * @brief Function to know if behaviour own a list of double parameter
     */
    bool hasVectorOfFunctionParameters() const {
        if ( _mapOfVectorFunctionMaterialProperties.size() != 0 )
            return true;
        return false;
    };

  protected:
    bool addRealProperty( std::string key, ElementaryMaterialPropertyReal value ) {
        _mapOfRealMaterialProperties[key] = value;
        _vectKW.push_back( key );
        _vectKW.push_back( value.getName() );
        return true;
    };

    bool addComplexProperty( std::string key, ElementaryMaterialPropertyComplex value ) {
        _mapOfComplexMaterialProperties[key] = value;
        _vectKW.push_back( key );
        _vectKW.push_back( value.getName() );
        return true;
    };

    bool addStringProperty( std::string key, ElementaryMaterialPropertyString value ) {
        _mapOfStringMaterialProperties[key] = value;
        _vectKW.push_back( key );
        _vectKW.push_back( value.getName() );
        return true;
    };

    bool addFunctionProperty( std::string key, ElementaryMaterialPropertyDataStructure value ) {
        _mapOfFunctionMaterialProperties[key] = value;
        _vectKW.push_back( key );
        _vectKW.push_back( value.getName() );
        return true;
    };

    bool addTableProperty( std::string key, ElementaryMaterialPropertyTable value ) {
        _mapOfTableMaterialProperties[key] = value;
        _vectKW.push_back( key );
        _vectKW.push_back( value.getName() );
        return true;
    };

    bool addVectorOfRealProperty( std::string key,
                                    ElementaryMaterialPropertyVectorReal value ) {
        _mapOfVectorRealMaterialProperties[key] = value;
        _vectKW.push_back( key );
        _vectKW.push_back( value.getName() );
        return true;
    };

    bool addVectorOfFunctionProperty( std::string key,
                                      ElementaryMaterialPropertyVectorFunction value ) {
        _mapOfVectorFunctionMaterialProperties[key] = value;
        _vectKW.push_back( key );
        _vectKW.push_back( value.getName() );
        return true;
    };

    bool addConvertibleProperty( std::string key, ElementaryMaterialPropertyConvertible value ) {
        _mapOfConvertibleMaterialProperties[key] = value;
        _vectKW.push_back( key );
        _vectKW.push_back( value.getName() );
        return true;
    };
};

/**
 * @class MaterialBehaviourClass
 * @brief Classe fille de GeneralMaterialBehaviourClass
 * @author Jean-Pierre Lefebvre
 */
class MaterialBehaviourClass : public GeneralMaterialBehaviourClass {
    std::string capitalizeName( const std::string &nameInit ) {
        std::string name( nameInit );
        if ( !name.empty() ) {
            name[0] = std::toupper( name[0] );

            for ( std::size_t i = 1; i < name.length(); ++i )
                name[i] = std::tolower( name[i] );
        }
        return name;
    };

  public:
    /**
     * @brief Constructeur
     */
    MaterialBehaviourClass( const std::string asterName, const std::string asterNewName = "" )
        : GeneralMaterialBehaviourClass( asterName, asterNewName ){};

    bool addNewRealProperty( std::string name, const bool mandatory ) {
        return addRealProperty( capitalizeName( name ),
                                  ElementaryMaterialPropertyReal( name, mandatory ) );
    };

    bool addNewRealProperty( std::string name, const double &value, const bool mandatory ) {
        return addRealProperty( capitalizeName( name ),
                                  ElementaryMaterialPropertyReal( name, value, mandatory ) );
    };

    bool addNewComplexProperty( std::string name, const bool mandatory ) {
        return addComplexProperty( capitalizeName( name ),
                                   ElementaryMaterialPropertyComplex( name, mandatory ) );
    };

    bool addNewStringProperty( std::string name, const bool mandatory ) {
        return addStringProperty( capitalizeName( name ),
                                  ElementaryMaterialPropertyString( name, mandatory ) );
    };

    bool addNewStringProperty( std::string name, const std::string &value, const bool mandatory ) {
        return addStringProperty( capitalizeName( name ),
                                  ElementaryMaterialPropertyString( name, value, mandatory ) );
    };

    bool addNewFunctionProperty( std::string name, const bool mandatory ) {
        return addFunctionProperty( capitalizeName( name ),
                                    ElementaryMaterialPropertyDataStructure( name, mandatory ) );
    };

    bool addNewTableProperty( std::string name, const bool mandatory ) {
        return addTableProperty( capitalizeName( name ),
                                 ElementaryMaterialPropertyTable( name, mandatory ) );
    };

    bool addNewVectorOfRealProperty( std::string name, const bool mandatory ) {
        return addVectorOfRealProperty(
            capitalizeName( name ), ElementaryMaterialPropertyVectorReal( name, mandatory ) );
    };

    bool addNewVectorOfFunctionProperty( std::string name, const bool mandatory ) {
        return addVectorOfFunctionProperty(
            capitalizeName( name ), ElementaryMaterialPropertyVectorFunction( name, mandatory ) );
    };

    /**
     * @brief Get name link to the class
     * @return name
     */
    std::string getName() { return _asterName; };
};

/** @typedef Pointeur intelligent vers un comportement materiau */
typedef boost::shared_ptr< MaterialBehaviourClass > MaterialBehaviourPtr;

/**
 * @class BetonRealDpMaterialBehaviourClass
 * @brief Classe fille de GeneralMaterialBehaviourClass definissant un materiau BetonRealDp
 * @author Jean-Pierre Lefebvre
 */
class BetonRealDpMaterialBehaviourClass : public GeneralMaterialBehaviourClass {
  public:
    /**
     * @brief Constructeur
     */
    BetonRealDpMaterialBehaviourClass() {
        // Mot cle "BETON_DOUBLE_DP" dans Aster
        _asterName = "BETON_DOUBLE_DP";

        // Parametres matériau
        this->addFunctionProperty( "F_c", ElementaryMaterialPropertyDataStructure( "F_C", true ) );
        this->addFunctionProperty( "F_t", ElementaryMaterialPropertyDataStructure( "F_T", true ) );
        this->addFunctionProperty( "Coef_biax",
                                   ElementaryMaterialPropertyDataStructure( "COEF_BIAX", true ) );
        this->addFunctionProperty(
            "Ener_comp_rupt", ElementaryMaterialPropertyDataStructure( "ENER_COMP_RUPT", true ) );
        this->addFunctionProperty(
            "Ener_trac_rupt", ElementaryMaterialPropertyDataStructure( "ENER_TRAC_RUPT", true ) );
        this->addRealProperty( "Coef_elas_comp",
                                 ElementaryMaterialPropertyReal( "COEF_ELAS_COMP", true ) );
        this->addRealProperty( "Long_cara",
                                 ElementaryMaterialPropertyReal( "LONG_CARA", false ) );
        this->addConvertibleProperty(
            "Ecro_comp_p_pic",
            ElementaryMaterialPropertyConvertible(
                "ECRO_COMP_P_PIC",
                StringToRealValue( {{"LINEAIRE", 0.}, {"PARABOLE", 1.}}, "LINEAIRE" ), false ) );
        this->addConvertibleProperty(
            "Ecro_trac_p_pic",
            ElementaryMaterialPropertyConvertible(
                "ECRO_TRAC_P_PIC",
                StringToRealValue( {{"LINEAIRE", 0.}, {"EXPONENT", 1.}}, "LINEAIRE" ), false ) );
    };

    /**
     * @brief Get name link to the class
     * @return name
     */
    static std::string getName() { return "BETON_DOUBLE_DP"; };

    /**
     * @brief To know if a MaterialBehaviour has ConvertibleValues
     */
    static bool hasConvertibleValues() { return true; };
};

/** @typedef Pointeur intelligent vers un comportement materiau BetonRealDp */
typedef boost::shared_ptr< BetonRealDpMaterialBehaviourClass >
    BetonRealDpMaterialBehaviourPtr;

/**
 * @class BetonRagMaterialBehaviourClass
 * @brief Classe fille de GeneralMaterialBehaviourClass definissant un materiau BetonRag
 * @author Jean-Pierre Lefebvre
 */
class BetonRagMaterialBehaviourClass : public GeneralMaterialBehaviourClass {
  public:
    /**
     * @brief Constructeur
     */
    BetonRagMaterialBehaviourClass() {
        // Mot cle "BETON_RAG" dans Aster
        _asterName = "BETON_RAG";

        // Parametres matériau
        this->addConvertibleProperty(
            "Comp_beton",
            ElementaryMaterialPropertyConvertible(
                "TYPE_LOI",
                StringToRealValue( {{"ENDO", 1.}, {"ENDO_FLUA", 2.}, {"ENDO_FLUA_RAG", 3.}} ),
                true ) );
        this->addRealProperty( "Endo_mc", ElementaryMaterialPropertyReal( "ENDO_MC", false ) );
        this->addRealProperty( "Endo_mt", ElementaryMaterialPropertyReal( "ENDO_MT", false ) );
        this->addRealProperty( "Endo_siguc",
                                 ElementaryMaterialPropertyReal( "ENDO_SIGUC", false ) );
        this->addRealProperty( "Endo_sigut",
                                 ElementaryMaterialPropertyReal( "ENDO_SIGUT", false ) );
        this->addRealProperty( "Endo_drupra",
                                 ElementaryMaterialPropertyReal( "ENDO_DRUPRA", false ) );
        this->addRealProperty( "Flua_sph_kr",
                                 ElementaryMaterialPropertyReal( "FLUA_SPH_KR", false ) );
        this->addRealProperty( "Flua_sph_ki",
                                 ElementaryMaterialPropertyReal( "FLUA_SPH_KI", false ) );
        this->addRealProperty( "Flua_sph_nr",
                                 ElementaryMaterialPropertyReal( "FLUA_SPH_NR", false ) );
        this->addRealProperty( "Flua_sph_ni",
                                 ElementaryMaterialPropertyReal( "FLUA_SPH_NI", false ) );
        this->addRealProperty( "Flua_dev_kr",
                                 ElementaryMaterialPropertyReal( "FLUA_DEV_KR", false ) );
        this->addRealProperty( "Flua_dev_ki",
                                 ElementaryMaterialPropertyReal( "FLUA_DEV_KI", false ) );
        this->addRealProperty( "Flua_dev_nr",
                                 ElementaryMaterialPropertyReal( "FLUA_DEV_NR", false ) );
        this->addRealProperty( "Flua_dev_ni",
                                 ElementaryMaterialPropertyReal( "FLUA_DEV_NI", false ) );
        this->addRealProperty( "Gel_alpha0",
                                 ElementaryMaterialPropertyReal( "GEL_ALPHA0", false ) );
        this->addRealProperty( "Gel_tref",
                                 ElementaryMaterialPropertyReal( "GEL_TREF", false ) );
        this->addRealProperty( "Gel_ear", ElementaryMaterialPropertyReal( "GEL_EAR", false ) );
        this->addRealProperty( "Gel_sr0", ElementaryMaterialPropertyReal( "GEL_SR0", false ) );
        this->addRealProperty( "Gel_vg", ElementaryMaterialPropertyReal( "GEL_VG", false ) );
        this->addRealProperty( "Gel_mg", ElementaryMaterialPropertyReal( "GEL_MG", false ) );
        this->addRealProperty( "Gel_bg", ElementaryMaterialPropertyReal( "GEL_BG", false ) );
        this->addRealProperty( "Gel_a0", ElementaryMaterialPropertyReal( "GEL_A0", false ) );
        this->addRealProperty( "Rag_epsi0",
                                 ElementaryMaterialPropertyReal( "RAG_EPSI0", false ) );
        this->addRealProperty( "Pw_a", ElementaryMaterialPropertyReal( "PW_A", false ) );
        this->addRealProperty( "Pw_b", ElementaryMaterialPropertyReal( "PW_B", false ) );
    };

    /**
     * @brief Get name link to the class
     * @return name
     */
    static std::string getName() { return "BETON_RAG"; };

    /**
     * @brief To know if a MaterialBehaviour has ConvertibleValues
     */
    static bool hasConvertibleValues() { return true; };
};

/** @typedef Pointeur intelligent vers un comportement materiau BetonRag */
typedef boost::shared_ptr< BetonRagMaterialBehaviourClass > BetonRagMaterialBehaviourPtr;

/**
 * @class DisEcroTracMaterialBehaviourClass
 * @brief Classe fille de GeneralMaterialBehaviourClass definissant un materiau DisEcroTrac
 * @author Jean-Pierre Lefebvre
 */
class DisEcroTracMaterialBehaviourClass : public GeneralMaterialBehaviourClass {
  public:
    /**
     * @brief Constructeur
     */
    DisEcroTracMaterialBehaviourClass() {
        // Mot cle "DIS_ECRO_TRAC" dans Aster
        _asterName = "DIS_ECRO_TRAC";

        // Parametres matériau
        this->addFunctionProperty( "Fx", ElementaryMaterialPropertyDataStructure( "FX", false ) );
        this->addFunctionProperty( "Ftan",
                                   ElementaryMaterialPropertyDataStructure( "FTAN", false ) );
        this->addConvertibleProperty(
            "Ecrouissage",
            ElementaryMaterialPropertyConvertible(
                "ECRO", StringToRealValue( {{"ISOTROPE", 1.}, {"CINEMATIQUE", 2.}} ), false ) );
    };

    /**
     * @brief Get name link to the class
     * @return name
     */
    static std::string getName() { return "DIS_ECRO_TRAC"; };

    /**
     * @brief To know if a MaterialBehaviour has ConvertibleValues
     */
    static bool hasConvertibleValues() { return true; };
};

/** @typedef Pointeur intelligent vers un comportement materiau DisEcroTrac */
typedef boost::shared_ptr< DisEcroTracMaterialBehaviourClass > DisEcroTracMaterialBehaviourPtr;

/**
 * @class CableGaineFrotMaterialBehaviourClass
 * @brief Classe fille de GeneralMaterialBehaviourClass definissant un materiau CableGaineFrot
 */
class CableGaineFrotMaterialBehaviourClass : public GeneralMaterialBehaviourClass {
  public:
    /**
     * @brief Constructeur
     */
    CableGaineFrotMaterialBehaviourClass() {
        // Mot cle "CABLE_GAINE_FROT" dans Aster
        _asterName = "CABLE_GAINE_FROT";

        // Parametres matériau
        this->addConvertibleProperty(
            "Type",
            ElementaryMaterialPropertyConvertible(
                "TYPE",
                StringToRealValue( {{"FROTTANT", 1.}, {"GLISSANT", 2.}, {"ADHERENT", 3.}} ),
                true ) );
        this->addRealProperty( "Frot_line",
                                 ElementaryMaterialPropertyReal( "FROT_LINE", 0., false ) );
        this->addRealProperty( "Frot_courb",
                                 ElementaryMaterialPropertyReal( "FROT_COURB", 0., false ) );
        this->addRealProperty( "Pena_lagr",
                                 ElementaryMaterialPropertyReal( "PENA_LAGR", true ) );
    };

    /**
     * @brief Get name link to the class
     * @return name
     */
    static std::string getName() { return "CABLE_GAINE_FROT"; };

    /**
     * @brief To know if a MaterialBehaviour has ConvertibleValues
     */
    static bool hasConvertibleValues() { return true; };
};

/** @typedef Pointeur intelligent vers un comportement materiau CableGaineFrot */
typedef boost::shared_ptr< CableGaineFrotMaterialBehaviourClass >
    CableGaineFrotMaterialBehaviourPtr;

/**
 * @class ElasMetaMaterialBehaviourClass
 * @brief Classe fille de GeneralMaterialBehaviourClass definissant un materiau ElasMeta
 * @author Jean-Pierre Lefebvre
 */
class ElasMetaMaterialBehaviourClass : public GeneralMaterialBehaviourClass {
  public:
    /**
     * @brief Constructeur
     */
    ElasMetaMaterialBehaviourClass() {
        // Mot cle "ELAS_META" dans Aster
        _asterName = "ELAS_META";

        // Parametres matériau
        this->addRealProperty( "E", ElementaryMaterialPropertyReal( "E", true ) );
        this->addRealProperty( "Nu", ElementaryMaterialPropertyReal( "NU", true ) );
        this->addRealProperty( "F_alpha", ElementaryMaterialPropertyReal( "F_ALPHA", true ) );
        this->addRealProperty( "C_alpha", ElementaryMaterialPropertyReal( "C_ALPHA", true ) );
        this->addConvertibleProperty(
            "Phase_refe",
            ElementaryMaterialPropertyConvertible(
                "PHASE_REFE", StringToRealValue( {{"CHAUD", 1.}, {"FROID", 0.}} ), true ) );
        this->addRealProperty( "Epsf_epsc_tref",
                                 ElementaryMaterialPropertyReal( "EPSF_EPSC_TREF", true ) );
        this->addRealProperty( "Precision",
                                 ElementaryMaterialPropertyReal( "PRECISION", 1.0E+0, false ) );
        this->addRealProperty( "F1_sy", ElementaryMaterialPropertyReal( "F1_SY", false ) );
        this->addRealProperty( "F2_sy", ElementaryMaterialPropertyReal( "F2_SY", false ) );
        this->addRealProperty( "F3_sy", ElementaryMaterialPropertyReal( "F3_SY", false ) );
        this->addRealProperty( "F4_sy", ElementaryMaterialPropertyReal( "F4_SY", false ) );
        this->addRealProperty( "C_sy", ElementaryMaterialPropertyReal( "C_SY", false ) );
        this->addFunctionProperty( "Sy_melange",
                                   ElementaryMaterialPropertyDataStructure( "SY_MELANGE", false ) );
        this->addRealProperty( "F1_s_vp", ElementaryMaterialPropertyReal( "F1_S_VP", false ) );
        this->addRealProperty( "F2_s_vp", ElementaryMaterialPropertyReal( "F2_S_VP", false ) );
        this->addRealProperty( "F3_s_vp", ElementaryMaterialPropertyReal( "F3_S_VP", false ) );
        this->addRealProperty( "F4_s_vp", ElementaryMaterialPropertyReal( "F4_S_VP", false ) );
        this->addRealProperty( "C_s_vp", ElementaryMaterialPropertyReal( "C_S_VP", false ) );
        this->addFunctionProperty(
            "S_vp_melange", ElementaryMaterialPropertyDataStructure( "S_VP_MELANGE", false ) );
    };

    /**
     * @brief Get name link to the class
     * @return name
     */
    static std::string getName() { return "ELAS_META"; };

    /**
     * @brief To know if a MaterialBehaviour has ConvertibleValues
     */
    static bool hasConvertibleValues() { return true; };
};

/** @typedef Pointeur intelligent vers un comportement materiau ElasMeta */
typedef boost::shared_ptr< ElasMetaMaterialBehaviourClass > ElasMetaMaterialBehaviourPtr;

/**
 * @class ElasMetaFoMaterialBehaviourClass
 * @brief Classe fille de GeneralMaterialBehaviourClass definissant un materiau ElasMetaFo
 * @author Jean-Pierre Lefebvre
 */
class ElasMetaFoMaterialBehaviourClass : public GeneralMaterialBehaviourClass {
  public:
    /**
     * @brief Constructeur
     */
    ElasMetaFoMaterialBehaviourClass() {
        // Mot cle "ELAS_META_FO" dans Aster
        _asterName = "ELAS_META_FO";
        _asterNewName = "ELAS_META";

        // Parametres matériau
        this->addFunctionProperty( "E", ElementaryMaterialPropertyDataStructure( "E", true ) );
        this->addFunctionProperty( "Nu", ElementaryMaterialPropertyDataStructure( "NU", true ) );
        this->addFunctionProperty( "F_alpha",
                                   ElementaryMaterialPropertyDataStructure( "F_ALPHA", true ) );
        this->addFunctionProperty( "C_alpha",
                                   ElementaryMaterialPropertyDataStructure( "C_ALPHA", true ) );
        this->addConvertibleProperty(
            "Phase_refe",
            ElementaryMaterialPropertyConvertible(
                "PHASE_REFE", StringToRealValue( {{"CHAUD", 1.}, {"FROID", 0.}} ), true ) );
        this->addRealProperty( "Epsf_epsc_tref",
                                 ElementaryMaterialPropertyReal( "EPSF_EPSC_TREF", true ) );
        this->addRealProperty( "Temp_def_alpha",
                                 ElementaryMaterialPropertyReal( "TEMP_DEF_ALPHA", false ) );
        this->addRealProperty( "Precision",
                                 ElementaryMaterialPropertyReal( "PRECISION", 1.0E+0, false ) );
        this->addFunctionProperty( "F1_sy",
                                   ElementaryMaterialPropertyDataStructure( "F1_SY", false ) );
        this->addFunctionProperty( "F2_sy",
                                   ElementaryMaterialPropertyDataStructure( "F2_SY", false ) );
        this->addFunctionProperty( "F3_sy",
                                   ElementaryMaterialPropertyDataStructure( "F3_SY", false ) );
        this->addFunctionProperty( "F4_sy",
                                   ElementaryMaterialPropertyDataStructure( "F4_SY", false ) );
        this->addFunctionProperty( "C_sy",
                                   ElementaryMaterialPropertyDataStructure( "C_SY", false ) );
        this->addFunctionProperty( "Sy_melange",
                                   ElementaryMaterialPropertyDataStructure( "SY_MELANGE", false ) );
        this->addFunctionProperty( "F1_s_vp",
                                   ElementaryMaterialPropertyDataStructure( "F1_S_VP", false ) );
        this->addFunctionProperty( "F2_s_vp",
                                   ElementaryMaterialPropertyDataStructure( "F2_S_VP", false ) );
        this->addFunctionProperty( "F3_s_vp",
                                   ElementaryMaterialPropertyDataStructure( "F3_S_VP", false ) );
        this->addFunctionProperty( "F4_s_vp",
                                   ElementaryMaterialPropertyDataStructure( "F4_S_VP", false ) );
        this->addFunctionProperty( "C_s_vp",
                                   ElementaryMaterialPropertyDataStructure( "C_S_VP", false ) );
        this->addFunctionProperty(
            "S_vp_melange", ElementaryMaterialPropertyDataStructure( "S_VP_MELANGE", false ) );
    };

    /**
     * @brief Get name link to the class
     * @return name
     */
    static std::string getName() { return "ELAS_META_FO"; };

    /**
     * @brief To know if a MaterialBehaviour has ConvertibleValues
     */
    static bool hasConvertibleValues() { return true; };
};

/** @typedef Pointeur intelligent vers un comportement materiau ElasMetaFo */
typedef boost::shared_ptr< ElasMetaFoMaterialBehaviourClass > ElasMetaFoMaterialBehaviourPtr;

/**
 * @class MetaTractionMaterialBehaviourClass
 * @brief Classe fille de GeneralMaterialBehaviourClass definissant un materiau MetaTraction
 * @author Jean-Pierre Lefebvre
 */
class MetaTractionMaterialBehaviourClass : public GeneralMaterialBehaviourClass {
  public:
    /**
     * @brief Constructeur
     */
    MetaTractionMaterialBehaviourClass() {
        // Mot cle "META_TRACTION" dans Aster
        _asterName = "META_TRACTION";

        // Parametres matériau
        this->addFunctionProperty( "Sigm_f1",
                                   ElementaryMaterialPropertyDataStructure( "SIGM_F1", false ) );
        this->addFunctionProperty( "Sigm_f2",
                                   ElementaryMaterialPropertyDataStructure( "SIGM_F2", false ) );
        this->addFunctionProperty( "Sigm_f3",
                                   ElementaryMaterialPropertyDataStructure( "SIGM_F3", false ) );
        this->addFunctionProperty( "Sigm_f4",
                                   ElementaryMaterialPropertyDataStructure( "SIGM_F4", false ) );
        this->addFunctionProperty( "Sigm_c",
                                   ElementaryMaterialPropertyDataStructure( "SIGM_C", false ) );
    };

    /**
     * @brief Build ".RDEP"
     * @return true
     */
    bool buildTractionFunction( FunctionPtr &doubleValues ) const;

    /**
     * @brief Get name link to the class
     * @return name
     */
    static std::string getName() { return "META_TRACTION"; };

    /**
     * @brief To know if a MaterialBehaviour has ConvertibleValues
     */
    static bool hasConvertibleValues() { return false; };

    /**
     * @brief Function to know if ".RDEP" is necessary
     * @return true if ".RDEP" is necessary
     */
    bool hasTractionFunction() const { return true; };
};

/** @typedef Pointeur intelligent vers un comportement materiau MetaTraction */
typedef boost::shared_ptr< MetaTractionMaterialBehaviourClass > MetaTractionMaterialBehaviourPtr;

/**
 * @class RuptFragMaterialBehaviourClass
 * @brief Classe fille de GeneralMaterialBehaviourClass definissant un materiau RuptFrag
 * @author Jean-Pierre Lefebvre
 */
class RuptFragMaterialBehaviourClass : public GeneralMaterialBehaviourClass {
  public:
    /**
     * @brief Constructeur
     */
    RuptFragMaterialBehaviourClass() {
        // Mot cle "RUPT_FRAG" dans Aster
        _asterName = "RUPT_FRAG";

        // Parametres matériau
        this->addRealProperty( "Gc", ElementaryMaterialPropertyReal( "GC", true ) );
        this->addRealProperty( "Sigm_c", ElementaryMaterialPropertyReal( "SIGM_C", false ) );
        this->addRealProperty( "Pena_adherence",
                                 ElementaryMaterialPropertyReal( "PENA_ADHERENCE", false ) );
        this->addRealProperty( "Pena_contact",
                                 ElementaryMaterialPropertyReal( "PENA_CONTACT", 1., false ) );
        this->addRealProperty( "Pena_lagr",
                                 ElementaryMaterialPropertyReal( "PENA_LAGR", 1.0E2, false ) );
        this->addRealProperty( "Rigi_glis",
                                 ElementaryMaterialPropertyReal( "RIGI_GLIS", 1.0E1, false ) );
        this->addConvertibleProperty(
            "Cinematique",
            ElementaryMaterialPropertyConvertible(
                "CINEMATIQUE",
                StringToRealValue( {{"UNILATER", 0.}, {"GLIS_1D", 1.}, {"GLIS_2D", 2.}},
                                     "UNILATER" ),
                false ) );
    };

    /**
     * @brief Get name link to the class
     * @return name
     */
    static std::string getName() { return "RUPT_FRAG"; };

    /**
     * @brief To know if a MaterialBehaviour has ConvertibleValues
     */
    static bool hasConvertibleValues() { return true; };
};

/** @typedef Pointeur intelligent vers un comportement materiau RuptFrag */
typedef boost::shared_ptr< RuptFragMaterialBehaviourClass > RuptFragMaterialBehaviourPtr;

/**
 * @class RuptFragFoMaterialBehaviourClass
 * @brief Classe fille de GeneralMaterialBehaviourClass definissant un materiau RuptFragFo
 * @author Jean-Pierre Lefebvre
 */
class RuptFragFoMaterialBehaviourClass : public GeneralMaterialBehaviourClass {
  public:
    /**
     * @brief Constructeur
     */
    RuptFragFoMaterialBehaviourClass() {
        // Mot cle "RUPT_FRAG_FO" dans Aster
        _asterName = "RUPT_FRAG_FO";
        _asterNewName = "RUPT_FRAG";

        // Parametres matériau
        this->addFunctionProperty( "Gc", ElementaryMaterialPropertyDataStructure( "GC", true ) );
        this->addFunctionProperty( "Sigm_c",
                                   ElementaryMaterialPropertyDataStructure( "SIGM_C", false ) );
        this->addFunctionProperty(
            "Pena_adherence", ElementaryMaterialPropertyDataStructure( "PENA_ADHERENCE", false ) );
        this->addRealProperty( "Pena_contact",
                                 ElementaryMaterialPropertyReal( "PENA_CONTACT", 1., false ) );
        this->addRealProperty( "Pena_lagr",
                                 ElementaryMaterialPropertyReal( "PENA_LAGR", 1.0E2, false ) );
        this->addRealProperty( "Rigi_glis",
                                 ElementaryMaterialPropertyReal( "RIGI_GLIS", 1.0E1, false ) );
        this->addConvertibleProperty(
            "Cinematique",
            ElementaryMaterialPropertyConvertible(
                "CINEMATIQUE",
                StringToRealValue( {{"UNILATER", 0.}, {"GLIS_1D", 1.}, {"GLIS_2D", 2.}},
                                     "UNILATER" ),
                false ) );
    };

    /**
     * @brief Get name link to the class
     * @return name
     */
    static std::string getName() { return "RUPT_FRAG_FO"; };

    /**
     * @brief To know if a MaterialBehaviour has ConvertibleValues
     */
    static bool hasConvertibleValues() { return true; };
};

/** @typedef Pointeur intelligent vers un comportement materiau RuptFragFo */
typedef boost::shared_ptr< RuptFragFoMaterialBehaviourClass > RuptFragFoMaterialBehaviourPtr;

/**
 * @class CzmLabMixMaterialBehaviourClass
 * @brief Classe fille de GeneralMaterialBehaviourClass definissant un materiau CzmLabMix
 * @author Nicolas Pignet
 */
class CzmLabMixMaterialBehaviourClass : public GeneralMaterialBehaviourClass {
  public:
    /**
     * @brief Constructeur
     */
    CzmLabMixMaterialBehaviourClass() {
        // Mot cle "CZM_LAB_MIX" dans Aster
        _asterName = "CZM_LAB_MIX";

        // Parametres matériau
        this->addRealProperty( "Sigm_c", ElementaryMaterialPropertyReal( "SIGM_C", false ) );
        this->addRealProperty( "Glis_c",
                                 ElementaryMaterialPropertyReal( "GLIS_C", false ) );
        this->addRealProperty( "Alpha",
                                 ElementaryMaterialPropertyReal( "ALPHA", 0.5, false ) );
        this->addRealProperty( "Beta",
                                 ElementaryMaterialPropertyReal( "BETA", 1.0, false ) );
        this->addRealProperty( "Pena_lagr",
                                 ElementaryMaterialPropertyReal( "PENA_LAGR", 100., false ) );
        this->addConvertibleProperty(
            "Cinematique",
            ElementaryMaterialPropertyConvertible(
                "CINEMATIQUE",
                StringToRealValue( {{"UNILATER", 0.}, {"GLIS_1D", 1.}, {"GLIS_2D", 2.}},
                                     "GLIS_1D" ),
                false ) );
    };

    /**
     * @brief Get name link to the class
     * @return name
     */
    static std::string getName() { return "CZM_LAB_MIX"; };

    /**
     * @brief To know if a MaterialBehaviour has ConvertibleValues
     */
    static bool hasConvertibleValues() { return true; };
};

/** @typedef Pointeur intelligent vers un comportement materiau CzmLabMix */
typedef boost::shared_ptr< CzmLabMixMaterialBehaviourClass > CzmLabMixMaterialBehaviourPtr;

/**
 * @class TractionMaterialBehaviourClass
 * @brief Classe fille de GeneralMaterialBehaviourClass definissant un materiau Traction
 * @author Jean-Pierre Lefebvre
 */
class TractionMaterialBehaviourClass : public GeneralMaterialBehaviourClass {
  public:
    /**
     * @brief Constructeur
     */
    TractionMaterialBehaviourClass() {
        // Mot cle "TRACTION" dans Aster
        _asterName = "TRACTION";

        // Parametres matériau
        this->addFunctionProperty( "Sigm",
                                   ElementaryMaterialPropertyDataStructure( "SIGM", true ) );
    };

    /**
     * @brief Build ".RDEP"
     * @return true
     */
    bool buildTractionFunction( FunctionPtr &doubleValues ) const;

    /**
     * @brief Get name link to the class
     * @return name
     */
    static std::string getName() { return "TRACTION"; };

    /**
     * @brief To know if a MaterialBehaviour has ConvertibleValues
     */
    static bool hasConvertibleValues() { return false; };

    /**
     * @brief Function to know if ".RDEP" is necessary
     * @return true if ".RDEP" is necessary
     */
    bool hasTractionFunction() const { return true; };
};

/** @typedef Pointeur intelligent vers un comportement materiau Traction */
typedef boost::shared_ptr< TractionMaterialBehaviourClass > TractionMaterialBehaviourPtr;

/**
 * @class ThermalNlMaterialBehaviourClass
 * @brief Classe fille de GeneralMaterialBehaviourClass definissant un materiau TherNl
 * @author Jean-Pierre Lefebvre
 */
class ThermalNlMaterialBehaviourClass : public GeneralMaterialBehaviourClass {
  private:
    FunctionPtr _enthalpyFunction;

  public:
    /**
     * @brief Constructeur
     */
    ThermalNlMaterialBehaviourClass() : _enthalpyFunction( new FunctionClass() ) {
        // Mot cle "THER_NL" dans Aster
        _asterName = "THER_NL";

        // Parametres matériau
        this->addFunctionProperty( "Lambda",
                                   ElementaryMaterialPropertyDataStructure( "LAMBDA", true ) );
        this->addFunctionProperty( "Beta",
                                   ElementaryMaterialPropertyDataStructure( "BETA", false ) );
        this->addFunctionProperty( "Rho_cp",
                                   ElementaryMaterialPropertyDataStructure( "RHO_CP", false ) );
    };

    /**
     * @brief Get name link to the class
     * @return name
     */
    static std::string getName() { return "THER_NL"; };

    /**
     * @brief To know if a MaterialBehaviour has ConvertibleValues
     */
    static bool hasConvertibleValues() { return false; };

    /**
     * @brief Function to know if material own a function for enthalpy
     */
    bool hasEnthalpyFunction() { return true; };

    /**
     * @brief Construction du GeneralMaterialBehaviourClass
     * @return Booleen valant true si la tache s'est bien deroulee
     * @todo vérifier les valeurs réelles par défaut du .VALR
     */
    bool buildJeveuxVectors( JeveuxVectorComplex &complexValues, JeveuxVectorReal &doubleValues,
                             JeveuxVectorChar16 &char16Values, JeveuxVectorChar16 &ordr,
                             JeveuxVectorLong &kOrdr, std::vector< JeveuxVectorReal > &,
                             std::vector< JeveuxVectorChar8 > & );
};

/** @typedef Pointeur intelligent vers un comportement materiau TherNl */
typedef boost::shared_ptr< ThermalNlMaterialBehaviourClass > ThermalNlMaterialBehaviourPtr;

/** @typedef Pointeur intellignet vers un comportement materiau quelconque */
typedef boost::shared_ptr< GeneralMaterialBehaviourClass > GeneralMaterialBehaviourPtr;

#endif
