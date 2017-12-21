#ifndef DATASTRUCTURE_H_
#define DATASTRUCTURE_H_

/**
 * @file DataStructure.h
 * @brief Fichier entete de la classe DataStructure
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

#ifdef __cplusplus

#include <stdexcept>
#include <string>
#include <map>

#include "astercxx.h"
#include "aster_fort.h"

#include "MemoryManager/JeveuxVector.h"
#include "MemoryManager/JeveuxAllowedTypes.h"
#include "DataStructures/DataStructureNaming.h"


/**
 * @class DataStructure
 * @brief Classe mere des classes representant des sd_aster
 * @author Nicolas Sellenet
 * @todo rendre cette classe virtuelle pure ?
 */
class DataStructure
{
    private:
        /** @brief Nom de la sd */
        /** @todo remettre le const */
        std::string  _name;
        /** @brief Type of memory allocation */
        JeveuxMemory _memoryType;
        /** @brief Object that stores the DataStructure type for jeveux requests */
        JeveuxVectorChar24 _tco;

    public:
        /** @typedef shared_ptr d'une DataStructure */
        typedef boost::shared_ptr< DataStructure > DataStructurePtr;

        /**
         * @brief Constructeur
         * @param name Name of the jeveux datastructure
         * @param nameLength Length of the jeveux basename
         * @param type code_aster type of the datastructure
         * @param memType Jeveux memory type
         */
        DataStructure( const std::string name, const int nameLength,
                       const std::string type = "",
                       const JeveuxMemory memType = Permanent );

        /**
         * @brief Constructeur
         * @param type code_aster type of the datastructure
         * @param memType Jeveux memory type
         * @param nameLength Length of the jeveux basename
         */
        DataStructure( const std::string type, const JeveuxMemory memType,
                       int nameLength );

        /**
         * @brief Destructeur
         */
        ~DataStructure();

        /**
         * @brief Function membre getMemoryType
         * @return le type de mémoire (globale ou volatile)
         */
        const JeveuxMemory& getMemoryType() const
        {
            return _memoryType;
        };

        /**
         * @brief Function membre getName
         * @return une chaine contenant le nom de la sd
         */
        const std::string& getName() const
        {
            return _name;
        };

        /**
         * @brief Function membre getType
         * @return le type de la sd
         */
        const std::string getType() const
        {
            _tco->updateValuePointer();
            return (*_tco)[0].rstrip();
        };

        /**
         * @brief Function membre debugPrint
         * @param logicalUnit Unite logique d'impression
         */
        void debugPrint( const int logicalUnit = 6 ) const;

        /**
         * @brief Function membre debugPrint
         */
        void debugPrint() const
        {
            debugPrint(6);
        };

    protected:
        /**
         * @brief Methode servant a fixer a posteriori le type d'une sd
         * @param newType chaine contenant le nouveau type
         */
        void setType( const std::string newType );
};

#endif

#endif /* DATASTRUCTURE_H_ */
