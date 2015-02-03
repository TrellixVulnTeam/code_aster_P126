#ifndef JEVEUXCOLLECTION_H_
#define JEVEUXCOLLECTION_H_

/**
 * @file JeveuxCollection.h
 * @brief Fichier entete de la classe JeveuxCollection
 * @author Nicolas Sellenet
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

/* person_in_charge: nicolas.sellenet at edf.fr */

#include "astercxx.h"
#include "aster_fort.h"

// @todo prefer use JeveuxString
#include "aster_utils.h"

#include "MemoryManager/JeveuxAllowedTypes.h"
#include "MemoryManager/JeveuxString.h"

#include <string>
#include <list>
#include <map>

using namespace std;

/**
 * @class JeveuxCollectionObject
 * @brief Cette classe template permet de definir un objet de collection Jeveux
 * @author Nicolas Sellenet
 */
template< class ValueType >
class JeveuxCollectionObject: private AllowedJeveuxType< ValueType >
{
    private:
        /** @brief Nom Jeveux de la collection */
        string     _collectionName;
        /** @brief Position dans la collection */
        int        _numberInCollection;
        /** @brief Nom de l'objet de collection */
        string     _nameOfObject;
        /** @brief Pointeur vers le vecteur Jeveux */
        ValueType* _valuePtr;

    public:
        /**
         * @brief Constructeur
         * @param collectionName Nom de collection
         * @param number Numero de l'objet dans la collection
         * @param ptr Pointeur vers le vecteur Jeveux
         */
        JeveuxCollectionObject(string collectionName, int number,
                               ValueType* ptr = NULL): _collectionName(collectionName),
                                                       _numberInCollection(number),
                                                       _nameOfObject(""),
                                                       _valuePtr(ptr)
        {};

        /**
         * @brief Constructeur
         * @param collectionName Nom de collection
         * @param number Numero de l'objet dans la collection
         * @param objectName Nom de l'objet de collection
         * @param ptr Pointeur vers le vecteur Jeveux
         */
        JeveuxCollectionObject(string collectionName, int number, string objectName,
                               ValueType* ptr = NULL): _collectionName(collectionName),
                                                       _numberInCollection(number),
                                                       _nameOfObject(objectName),
                                                       _valuePtr(ptr)
        {};
};

/**
 * @class JeveuxCollectionInstance
 * @brief Cette classe template permet de definir une collection Jeveux
 * @author Nicolas Sellenet
 */
template< class ValueType >
class JeveuxCollectionInstance
{
    private:
        /** @brief Definition d'un objet de collection du type ValueType */
        typedef JeveuxCollectionObject< ValueType > JeveuxCollObjValType;
        /** @brief std::map associant une chaine a un JeveuxCollObjValType */
        typedef map< string, JeveuxCollObjValType > mapStrCollectionObject;

        /** @brief Nom de la collection */
        string                                    _name;
        /** @brief Listes de objets de collection */
        list< JeveuxCollectionObject<ValueType> > _listObjects;

    public:
        /**
         * @brief Constructeur
         * @param name Chaine representant le nom de la collection
         */
        JeveuxCollectionInstance(string name): _name(name)
        {};

        /**
         * @brief Methode permettant de construire une collection a partir d'une collection
         *   existante en memoire Jeveux
         * @return Renvoit true si la construction s'est bien deroulee
         */
        bool buildFromJeveux();

        /**
         * @brief Methode verifiant l'existance d'un objet de collection dans la collection
         * @param name Chaine contenant le nom de l'objet
         * @return Renvoit true si l'objet existe dans la collection
         */
        bool existsObject(string name);
};

template< class ValueType >
bool JeveuxCollectionInstance< ValueType >::buildFromJeveux()
{
    _listObjects.clear();
    long nbColObj, valTmp;
    const char* charName = _name.c_str();
    JeveuxChar8 param( "NMAXOC" );
    char* charval = MakeBlankFStr(32);
    // Attention rajouter des verifications d'existence
    CALL_JELIRA( charName, param.c_str(), &nbColObj, charval );

    param = "ACCES ";
    CALL_JELIRA( charName, param.c_str(), &valTmp, charval );
    string resu = string( charval, 2 );
    FreeStr( charval );

    bool named = false;
    if ( resu == "NO" ) named = true;

    const char* tmp = "L";
    charval = MakeBlankFStr(32);
    char* collectionObjectName = MakeBlankFStr(32);
    for ( long i = 1; i <= nbColObj; ++i )
    {
        ValueType* valuePtr;
        CALL_JEXNUM( charval, charName, &i );
        if ( named )
            CALL_JENUNO( charval, collectionObjectName );
        CALL_JEVEUOC( charval, tmp, (void*)(&valuePtr) );
        if ( named )
            _listObjects.push_back( JeveuxCollObjValType( charName, i,
                                                          collectionObjectName, valuePtr ) );
        else
            _listObjects.push_back( JeveuxCollObjValType( charName, i, valuePtr ) );
    }
    FreeStr( charval );
    FreeStr( collectionObjectName );
    return true;
};

template< class ValueType >
bool JeveuxCollectionInstance< ValueType >::existsObject( string name )
{
    const char* collName = _name.c_str();
    char* charJeveuxName = MakeBlankFStr(32);
    long returnBool;
    CALL_JEXNOM( charJeveuxName,collName, name.c_str() );
    CALL_JEEXIN( charJeveuxName, &returnBool );
    if ( returnBool == 0 ) return false;
    return true;
};

/**
 * @class JeveuxCollection
 * @brief Enveloppe d'un pointeur intelligent vers un JeveuxCollectionInstance
 * @author Nicolas Sellenet
 */
template< class ValueType >
class JeveuxCollection
{
    public:
        typedef boost::shared_ptr< JeveuxCollectionInstance< ValueType > > JeveuxCollectionTypePtr;

    private:
        JeveuxCollectionTypePtr _jeveuxCollectionPtr;

    public:
        JeveuxCollection( string nom ):
                _jeveuxCollectionPtr( new JeveuxCollectionInstance< ValueType > (nom) )
        {};

        ~JeveuxCollection()
        {};

        JeveuxCollection& operator=( const JeveuxCollection< ValueType >& tmp )
        {
            _jeveuxCollectionPtr = tmp._jeveuxCollectionPtr;
        };

        const JeveuxCollectionTypePtr& operator->() const
        {
            return _jeveuxCollectionPtr;
        };

        bool isEmpty() const
        {
            if ( _jeveuxCollectionPtr.use_count() == 0 ) return true;
            return false;
        };
};

/** @typedef Definition d'une collection de type long */
typedef JeveuxCollection< long > JeveuxCollectionLong;
/** @typedef Definition d'une collection de type short int */
typedef JeveuxCollection< short int > JeveuxCollectionShort;
/** @typedef Definition d'une collection de type double */
typedef JeveuxCollection< double > JeveuxCollectionDouble;
/** @typedef Definition d'une collection de type double complex */
typedef JeveuxCollection< double complex > JeveuxCollectionComplex;
/** @typedef Definition d'une collection de JeveuxChar8 */
typedef JeveuxCollection< JeveuxChar8 > JeveuxCollectionChar8;
/** @typedef Definition d'une collection de JeveuxChar16 */
typedef JeveuxCollection< JeveuxChar16 > JeveuxCollectionChar16;
/** @typedef Definition d'une collection de JeveuxChar24 */
typedef JeveuxCollection< JeveuxChar24 > JeveuxCollectionChar24;
/** @typedef Definition d'une collection de JeveuxChar32 */
typedef JeveuxCollection< JeveuxChar32 > JeveuxCollectionChar32;
/** @typedef Definition d'une collection de JeveuxChar80 */
typedef JeveuxCollection< JeveuxChar80 > JeveuxCollectionChar80;

#endif /* JEVEUXCOLLECTION_H_ */
