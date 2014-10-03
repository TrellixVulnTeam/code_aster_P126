#ifndef RESULTSCONTAINER_H_
#define RESULTSCONTAINER_H_

/* person_in_charge: nicolas.sellenet at edf.fr */

#include "baseobject/JeveuxVector.h"
#include "baseobject/JeveuxCollection.h"
#include "baseobject/JeveuxBidirectionalMap.h"

/**
* class ResultsContainerInstance
*   Cette classe correspond a la sd_resultat de Code_Aster
*   Elle permet de stocker les champs issus d'une resolution numerique
* @author Nicolas Sellenet
*/
class ResultsContainerInstance
{
    private:
        string                 _jeveuxName;
        JeveuxBidirectionalMap _symbolicNamesOfFields;
        JeveuxCollectionChar24 _namesOfFields;
        JeveuxBidirectionalMap _accessVariables;
        JeveuxCollectionChar8  _calculationParameter;
        JeveuxVectorLong       _serialNumber;

    public:
        /**
        * Constructeur
        */
        ResultsContainerInstance():
                            _jeveuxName( initAster->getNewResultObjectName() ),
                            _symbolicNamesOfFields( JeveuxBidirectionalMap( _jeveuxName + "           .DESC" ) ),
                            _namesOfFields( JeveuxCollectionChar24( _jeveuxName + "           .TACH" ) ),
                            _accessVariables( JeveuxBidirectionalMap( _jeveuxName + "           .NOVA" ) ),
                            _calculationParameter( JeveuxCollectionChar8( _jeveuxName + "           .TAVA" ) ),
                            _serialNumber( JeveuxVectorLong( _jeveuxName + "           .ORDR" ) )
        {};
};

/**
* class ResultsContainer
*   Enveloppe d'un pointeur intelligent vers un ResultsContainerInstance
* @author Nicolas Sellenet
*/
class ResultsContainer
{
    public:
        typedef boost::shared_ptr< ResultsContainerInstance > ResultsContainerPtr;

    private:
        ResultsContainerPtr _meshPtr;

    public:
        ResultsContainer(bool initilisation = true): _meshPtr()
        {
            if ( initilisation == true )
                _meshPtr = ResultsContainerPtr( new ResultsContainerInstance() );
        };

        ~ResultsContainer()
        {};

        ResultsContainer& operator=(const ResultsContainer& tmp)
        {
            _meshPtr = tmp._meshPtr;
            return *this;
        };

        const ResultsContainerPtr& operator->() const
        {
            return _meshPtr;
        };

        bool isEmpty() const
        {
            if ( _meshPtr.use_count() == 0 ) return true;
            return false;
        };
};

#endif /* RESULTSCONTAINER_H_ */
