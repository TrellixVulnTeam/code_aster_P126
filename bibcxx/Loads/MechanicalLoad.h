#ifndef MECHANICALLOAD_H_
#define MECHANICALLOAD_H_

/**
 * @file MechanicalLoad.h
 * @brief Fichier entete de la classe MechanicalLoad
 * @author Natacha Bereux
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

#include "Modeling/Model.h"
#include "Loads/UnitaryLoad.h"
#include "DataFields/PCFieldOnMesh.h"

/**
 * @class MechanicalLoadInstance
 * @brief This class defines a mechanical load (resulting from AFFE_CHAR_MECA command)
 * @author Natacha Bereux
 * @todo Mutualiser avec KinematicsLoad. Typedef et méthodes sont parfois des copies serviles
 */
class MechanicalLoadInstance : public DataStructure
{
    private:
        /** @typedef Pointeur intelligent sur un VirtualMeshEntity */
        typedef boost::shared_ptr< VirtualMeshEntity > MeshEntityPtr;
        /** @typedef std::list de DoubleLoadDisplacement */
        typedef list< DoubleLoadDisplacement > ListDoubleDisp;
        /** @typedef ListDoubleDisp iterator*/
        typedef ListDoubleDisp::iterator ListDoubleDispIter;

        /** @typedef std::list of DoubleLoadPressure */
        typedef list< DoubleLoadPressure > ListDoublePres;
        /** @typedef ListDoubleTemp iterator*/
        typedef ListDoublePres::iterator ListDoublePresIter;

        /** @brief User description of imposed loads */
        ListDoubleDisp      _listOfDoubleImposedDisplacement;
        ListDoublePres      _listOfDoubleImposedPressure;
        ListDoublePres      _listOfDoubleImposedDistributedPressure;
        ListDoublePres      _listOfDoubleImposedPipePressure;

        /** @brief Structure de données Aster */
        const string           _jeveuxName;
        PCFieldOnMeshDouble    _kinematicLoad;
        PCFieldOnMeshDouble    _pressure;
        /** @brief Modele support */
        ModelPtr       _supportModel;

    public:
        /**
        * @brief Constructeur
        */
        MechanicalLoadInstance();

        /**
         * @brief Set displacement on a group of elements
         * @param nameOfGroup name of the group of elements
         * @param value imposed value
         * @return bool
         */

        bool setDisplacementOnElements(AsterCoordinates coordinate,
                                    string nameOfGroup, double value)
        {
// Check that neither the pointer to the support model nor the model itself are empty
            if ( ( ! _supportModel ) || _supportModel->isEmpty() )
                throw string("Model is empty");
// Check that nameOfGroup defines a group of nodes of the support mesh
            MeshPtr & currentMesh= _supportModel->getSupportMesh();
            if ( !currentMesh->hasGroupOfElements( nameOfGroup ))
            {
                throw  nameOfGroup +" is not a group of elements of the mesh you provided";
            }
            MeshEntityPtr meshEnt( new GroupOfElementsInstance( nameOfGroup ) );
            DoubleLoadDisplacement resu( meshEnt, coordinate, value );
            _listOfDoubleImposedDisplacement.push_back( resu );
            return true;
        };
/**
         * @brief Set displacement on a group of nodes
         * @param nameOfGroup name of the group of nodes
         * @param value imposed value
         * @return bool
         */

        bool setDisplacementOnNodes(AsterCoordinates coordinate,
                                    string nameOfGroup, double value)
        {
// Check that neither the pointer to the support model nor the model itself are empty
            if ( ( ! _supportModel ) || _supportModel->isEmpty() )
                throw string("Model is empty");
// Check that nameOfGroup defines a group of nodes of the support mesh
            MeshPtr & currentMesh= _supportModel->getSupportMesh();
            if ( !currentMesh->hasGroupOfNodes( nameOfGroup ))
            {
                throw nameOfGroup +" is not a group of nodes of the mesh you provided";
            }
            MeshEntityPtr meshEnt( new GroupOfNodesInstance( nameOfGroup ) );
            DoubleLoadDisplacement resu( meshEnt, coordinate, value );
            _listOfDoubleImposedDisplacement.push_back( resu );
            return true;
        };

        /**
         * @brief Set the pressure on a group of elements
         * @param nameOfGroup Nom du groupe sur lequel imposer la valeur
         * @param value imposed value
         * @return bool
         */
        bool setPressureOnElements(double value, string nameOfGroup)
        {
// Check that neither the pointer to the support model nor the model itself are empty
            if ( ( ! _supportModel ) || _supportModel->isEmpty() )
                throw string("Model is empty");
// Check that nameOfGroup is the name of a group belonging to the support mesh
            MeshPtr & currentMesh= _supportModel->getSupportMesh();
            if ( !currentMesh->hasGroupOfElements( nameOfGroup ))
            {
                throw nameOfGroup +" is not a group of nodes of the mesh you provided" ;
            }
            MeshEntityPtr meshEnt( new GroupOfElementsInstance( nameOfGroup ) );
            AsterCoordinates coordinate = Pressure;
            DoubleLoadPressure resu( meshEnt, coordinate, value );
            _listOfDoubleImposedPressure.push_back( resu );
            return true;
        };
        /**
         * @brief Set the pressure on a group of nodes
         * @param nameOfGroup Nom du groupe sur lequel imposer la valeur
         * @param value imposed value
         * @return bool
         */
        bool setPressureOnNodes(double value, string nameOfGroup)
        {
// Check that neither the pointer to the support model nor the model itself are empty
            if ( ( ! _supportModel ) || _supportModel->isEmpty() )
                throw string("Model is empty");
// Check that nameOfGroup is the name of a group belonging to the support mesh
            MeshPtr & currentMesh= _supportModel->getSupportMesh();
            if ( !currentMesh->hasGroupOfNodes( nameOfGroup ))
            {
                throw nameOfGroup +" is not a group of nodes of the mesh you provided" ;
            }
            MeshEntityPtr meshEnt( new GroupOfNodesInstance( nameOfGroup ) );
            AsterCoordinates coordinate = Pressure;
            DoubleLoadPressure resu( meshEnt, coordinate, value );
            _listOfDoubleImposedPressure.push_back( resu );
            return true;
        };
        /**
         * @brief Set a distributed pressure on a group of elements
         * @param nameOfGroup Nom du groupe sur lequel imposer la valeur
         * @param value imposed value
         * @return bool
         */
        bool setDistributedPressureOnElements(double value, string nameOfGroup)
        {
// Check that neither the pointer to the support model nor the model itself are empty
            if ( ( ! _supportModel ) || _supportModel->isEmpty() )
                throw string("Model is empty");
// Check that nameOfGroup is the name of a group belonging to the support mesh
            MeshPtr & currentMesh= _supportModel->getSupportMesh();
            if ( !currentMesh->hasGroupOfElements( nameOfGroup ))
            {
                throw nameOfGroup +" is not a group of elements of the mesh you provided" ;
            }
            MeshEntityPtr meshEnt( new GroupOfElementsInstance( nameOfGroup ) );
            AsterCoordinates coordinate = Pressure;
            DoubleLoadPressure resu( meshEnt, coordinate, value );
            _listOfDoubleImposedDistributedPressure.push_back( resu );
            return true;
        };
        /**
        * @brief Set a pressure on a group of elements describing a pipe
        * @param nameOfGroup Nom du groupe sur lequel imposer la valeur
        * @param value imposed value
        * @return bool
        */
        bool setPipePressureOnElements( double value, string nameOfGroup )
        {
// Check that neither the pointer to the support model nor the model itself are empty
            if ( ( ! _supportModel ) || _supportModel->isEmpty() )
                throw string("Model is empty");
// Check that nameOfGroup is the name of a group belonging to the support mesh
            MeshPtr & currentMesh= _supportModel->getSupportMesh();
            if ( !currentMesh->hasGroupOfElements( nameOfGroup ))
            {
                throw nameOfGroup +" is not a group of elements of the mesh you provided" ;
            }
            MeshEntityPtr meshEnt( new GroupOfElementsInstance( nameOfGroup ) );
            AsterCoordinates coordinate = Pressure;
            DoubleLoadPressure resu( meshEnt, coordinate, value );
            _listOfDoubleImposedPipePressure.push_back( resu );
            return true;
        };
        /**
         * @brief Construction de la charge (appel a OP007)
         * @return Booleen indiquant que tout s'est bien passe
         */
        bool build();

       /**
         * @brief Definition du modele support
         * @param currentMesh objet Model sur lequel la charge reposera
         */
        bool setSupportModel(ModelPtr& currentModel)
        {
            if ( ! currentModel )
                throw string("Model is empty");
            _supportModel = currentModel;
            return true;
        };
};

class MechanicalLoad
{
    public:
        typedef boost::shared_ptr< MechanicalLoadInstance > MechanicalLoadPtr;

    private:
        MechanicalLoadPtr _MechanicalLoadPtr;

    public:
        MechanicalLoad(bool initialisation = true): _MechanicalLoadPtr()
        {
            if ( initialisation == true )
                _MechanicalLoadPtr = MechanicalLoadPtr( new MechanicalLoadInstance() );
        };

        ~MechanicalLoad()
        {};

        MechanicalLoad& operator=(const MechanicalLoad& tmp)
        {
            _MechanicalLoadPtr = tmp._MechanicalLoadPtr;
            return(*this);
        };

        const MechanicalLoadPtr& operator->() const
        {
            return _MechanicalLoadPtr;
        };

        MechanicalLoadInstance& operator*(void) const
        {
            return *_MechanicalLoadPtr;
        };

        bool isEmpty() const
        {
            if ( _MechanicalLoadPtr.use_count() == 0 ) return true;
            return false;
        };
};

#endif /* MECHANICALLOAD_H_ */
