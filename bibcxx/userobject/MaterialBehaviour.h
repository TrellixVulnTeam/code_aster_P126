#ifndef MATERIALBEHAVIOUR_H_
#define MATERIALBEHAVIOUR_H_

#include <iomanip>
#include <map>
#include <sstream>
#include <string>

#include "baseobject/JeveuxVector.h"
//#include "aster_utils.h"
#include "aster.h"

extern "C"
{
    void CopyCStrToFStr( char *, char *, STRING_SIZE );
}

/**
* struct template AllowedMaterialPropertyType
*   structure permettant de limiter le type instanciable de ElementaryMaterialPropertyInstance
*   on autorise 2 types pour le moment : double et complex
* @author Nicolas Sellenet
*/
template<typename T>
struct AllowedMaterialPropertyType;

template<> struct AllowedMaterialPropertyType< double >
{};

template<> struct AllowedMaterialPropertyType< double complex >
{};

/**
* class template ElementaryMaterialPropertyInstance
*   Cette classe permet de definir un type elementaire de propriete materielle
*   ex : le module d'Young
* @author Nicolas Sellenet
*/
template< class ValueType >
class ElementaryMaterialPropertyInstance: private AllowedMaterialPropertyType< ValueType >
{
    private:
        // Nom Aster du type elementaire de propriete materielle,
        // ex : "NU" pour le coefficient de Poisson
        string    _name;
        // Description de parametre, ex : "Young's modulus"
        string    _description;
        // Valeur du parametre (double, complex, ...)
        ValueType _value;

    public:
        /**
        * Constructeur
        * @param name Nom Aster du parametre materiau (ex : "NU")
        * @param description Description libre
        */
        ElementaryMaterialPropertyInstance(string name, string description = ""): _name( name ),
                                                                                  _description( description )
        {};

        /**
        * Recuperation de la valeur du parametre
        */
        const string& getName() const
        {
            return _name;
        };

        /**
        * Recuperation de la valeur du parametre
        */
        const ValueType& getValue() const
        {
            return _value;
        };

        /**
        * Fonction servant a fixer la valeur du parametre
        * @param currentValue Valeur donnee par l'utilisateur
        */
        void setValue(ValueType& currentValue)
        {
            _value = currentValue;
        };
};

typedef ElementaryMaterialPropertyInstance< double > ElementaryMaterialPropertyDouble;
typedef ElementaryMaterialPropertyInstance< double complex > ElementaryMaterialPropertyComplex;

/**
* class GeneralMaterialBehaviourInstance
*   Cette classe permet de definir un ensemble de type elementaire de propriete materielle
*   ex : le module d'Young + le coefficient de Poisson, ...
* @author Nicolas Sellenet
*/
class GeneralMaterialBehaviourInstance
{
    protected:
        typedef map< string, ElementaryMaterialPropertyDouble > mapStrEMPD;
        typedef map< string, ElementaryMaterialPropertyDouble >::iterator mapStrEMPDIterator;
        typedef mapStrEMPD::value_type mapStrEMPDValue;

        typedef map< string, ElementaryMaterialPropertyComplex > mapStrEMPC;
        typedef map< string, ElementaryMaterialPropertyComplex >::iterator mapStrEMPCIterator;
        typedef mapStrEMPC::value_type mapStrEMPCValue;

        friend class MaterialInstance;
        // Chaine correspondant au nom Aster du MaterialBehaviourInstance
        // ex : ELAS ou ELAS_FO
        string              _asterName;
        // Vector Jeveux 'CPT.XXXXXX.VALC'
        JeveuxVectorComplex _complexValues;
        // Vector Jeveux 'CPT.XXXXXX.VALR'
        JeveuxVectorDouble  _doubleValues;
        // Vector Jeveux 'CPT.XXXXXX.VALK'
        JeveuxVectorChar16  _char16Values;
        // Map contenant les noms des proprietes double ainsi que les
        // ElementaryMaterialPropertyInstance correspondant
        mapStrEMPD          _mapOfDoubleMaterialProperties;
        // Map contenant les noms des proprietes complex ainsi que les
        // ElementaryMaterialPropertyInstance correspondant
        mapStrEMPC          _mapOfComplexMaterialProperties;
        // Liste contenant tous les noms des parametres materiau
        list< string >      _listOfNameOfMaterialProperties;

    public:
        /**
        * Constructeur
        */
        GeneralMaterialBehaviourInstance(): _asterName( string( " " ) ),
                                            _complexValues( JeveuxVectorComplex("") ),
                                            _doubleValues( JeveuxVectorDouble("") ),
                                            _char16Values( JeveuxVectorChar16("") )
        {};

        /**
        * Recuperation du nom Aster du GeneralMaterialBehaviourInstance
        *   ex : 'ELAS', 'ELAS_FO', ...
        * @return Chaine contenant le nom Aster
        */
        const string getAsterName() const
        {
            return _asterName;
        };

        /**
        * Fonction servant a fixer un parametre materiau au GeneralMaterialBehaviourInstance
        * @param nameOfProperty Nom de la propriete
        * @param value Double correspondant a la valeur donnee par l'utilisateur
        * @return Booleen valant true si la tache s'est bien deroulee
        */
        bool setDoubleValue(string nameOfProperty, double value)
        {
            // Recherche de la propriete materielle
            mapStrEMPDIterator curIter = _mapOfDoubleMaterialProperties.find(nameOfProperty);
            if ( curIter ==  _mapOfDoubleMaterialProperties.end() ) return false;
            // Ajout de la valeur
            (*curIter).second.setValue(value);
            return true;
        };

        /**
        * Fonction servant a fixer un parametre materiau au GeneralMaterialBehaviourInstance
        * @param nameOfProperty Nom de la propriete
        * @param value Complex correspondant a la valeur donnee par l'utilisateur
        * @return Booleen valant true si la tache s'est bien deroulee
        */
        bool setComplexValue(string nameOfProperty, double complex value)
        {
            // Recherche de la propriete materielle
            mapStrEMPCIterator curIter = _mapOfComplexMaterialProperties.find(nameOfProperty);
            if ( curIter ==  _mapOfComplexMaterialProperties.end() ) return false;
            // Ajout de la valeur
            (*curIter).second.setValue(value);
            return true;
        };

        /**
        * Construction du GeneralMaterialBehaviourInstance
        * @return Booleen valant true si la tache s'est bien deroulee
        */
        bool build();

    private:
        /**
        * Modification a posteriori des objets Jeveux ".VALC", ...
        */
        void setJeveuxObjectNames(string name)
        {
            _complexValues = JeveuxVectorComplex( name + ".VALC" );
            _doubleValues = JeveuxVectorDouble( name + ".VALR" );
            _char16Values = JeveuxVectorChar16( name + ".VALK" );
        };
};

/**
* class ElasticMaterialBehaviourInstance
*   Classe fille de GeneralMaterialBehaviourInstance definissant un materiau elastique
* @author Nicolas Sellenet
*/
class ElasticMaterialBehaviourInstance: public GeneralMaterialBehaviourInstance
{
    public:
        /**
        * Constructeur
        */
        ElasticMaterialBehaviourInstance()
        {
            bool a = true;
            while ( a )
            {
                int b = 5;
            }
            // Mot cle "ELAS" dans Aster
            _asterName = "ELAS";

            // Deux parametres E et Nu
            ElementaryMaterialPropertyDouble firstElt("E", "Young Modulus");
            _mapOfDoubleMaterialProperties.insert( mapStrEMPDValue ( string("E"), firstElt ) );
            _listOfNameOfMaterialProperties.push_back("E");

            ElementaryMaterialPropertyDouble secondElt("NU", "Poisson's ratio");
            _mapOfDoubleMaterialProperties.insert( mapStrEMPDValue ( string("Nu"), secondElt ) );
            _listOfNameOfMaterialProperties.push_back("Nu");
        };
};

/**
* class template MaterialBehaviourInstance
*   Enveloppe d'un pointeur intelligent vers un MaterialBehaviourInstance
* @author Nicolas Sellenet
*/
template< class MaterialBehaviourInstance >
class MaterialBehaviour
{
    public:
        typedef boost::shared_ptr< MaterialBehaviourInstance > MaterialBehaviourPtr;

    private:
        MaterialBehaviourPtr _materialBehaviourPtr;

    public:
        MaterialBehaviour(bool initilisation = true): _materialBehaviourPtr()
        {
            if ( initilisation == true )
                _materialBehaviourPtr = MaterialBehaviourPtr( new MaterialBehaviourInstance() );
        };

        ~MaterialBehaviour()
        {};

        MaterialBehaviour& operator=(const MaterialBehaviour& tmp)
        {
            _materialBehaviourPtr = tmp._materialBehaviourPtr;
            return *this;
        };

        const MaterialBehaviourPtr& operator->() const
        {
            return _materialBehaviourPtr;
        };

        bool isEmpty() const
        {
            if ( _materialBehaviourPtr.use_count() == 0 ) return true;
            return false;
        };
};

typedef class MaterialBehaviour< ElasticMaterialBehaviourInstance > ElasticMaterialBehaviour;
typedef class MaterialBehaviour< GeneralMaterialBehaviourInstance > GeneralMaterialBehaviour;

#endif /* MATERIALBEHAVIOUR_H_ */
