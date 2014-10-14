
/* person_in_charge: nicolas.sellenet at edf.fr */

#include "definition.h"
#include "Debug/DebugPrint.h"
#include "RunManager/CommandSyntax.h"

void jeveuxDebugPrint(string nomJeveux, int logicalUnit)
{
    // Definition du bout de fichier de commande correspondant a AFFE_MODELE
    CommandSyntax syntaxeImprCo( "IMPR_CO", false, "" );
    // Ligne indispensable pour que les commandes GET* fonctionnent
    commandeCourante = &syntaxeImprCo;

    FactorKeyword motCleCONCEPT = FactorKeyword( "CONCEPT", false );

    SimpleKeyWordStr mCSNom( "NOM" );
    mCSNom.addValues( nomJeveux.c_str() );

    FactorKeywordOccurence occurCONCEPT = FactorKeywordOccurence();
    occurCONCEPT.addSimpleKeywordStr( mCSNom );
    motCleCONCEPT.addOccurence( occurCONCEPT );

    syntaxeImprCo.addFactorKeyword( motCleCONCEPT );

    SimpleKeyWordInt mCSUnite( "UNITE" );
    mCSUnite.addValues( logicalUnit );
    syntaxeImprCo.addSimpleKeywordInteger( mCSUnite );

    SimpleKeyWordStr mCSBase( "BASE" );
    mCSBase.addValues( "G" );
    syntaxeImprCo.addSimpleKeywordStr( mCSBase );

    SimpleKeyWordInt mCSNiveau( "NIVEAU" );
    mCSNiveau.addValues( 2 );
    syntaxeImprCo.addSimpleKeywordInteger( mCSNiveau );

    SimpleKeyWordStr mCSContenu( "CONTENU" );
    mCSContenu.addValues( "OUI" );
    syntaxeImprCo.addSimpleKeywordStr( mCSContenu );

    SimpleKeyWordStr mCSAttr( "ATTRIBUT" );
    mCSAttr.addValues( "NON" );
    syntaxeImprCo.addSimpleKeywordStr( mCSAttr );

    CALL_EXECOP(17);
    commandeCourante = NULL;
};
