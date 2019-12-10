# coding: utf-8

import code_aster
from code_aster.Commands import *

code_aster.init()

test = code_aster.TestCase()

# lecture du maillage
MAIL=code_aster.Mesh()
MAIL.readMedFile("zzzz104a.mmed")

MOD=AFFE_MODELE(MAILLAGE=MAIL,
                  AFFE=_F(GROUP_MA='POUTRE',
                          PHENOMENE='MECANIQUE',
                          MODELISATION='D_PLAN',),)


BETON=DEFI_MATERIAU(ELAS=_F(E=200000000000.0,
                            NU=0.3,
                            ALPHA = 0.02),
                   )

TEMP1=CREA_CHAMP(OPERATION='AFFE',
                 TYPE_CHAM='NOEU_TEMP_R',
                 MAILLAGE=MAIL,
                 AFFE=_F( GROUP_MA='POUTRE',
                          NOM_CMP = ('TEMP',),
                          VALE =50.,
                        )
                )


CHMAT=AFFE_MATERIAU(MAILLAGE=MAIL,
                       AFFE=_F(TOUT='OUI',
                               MATER=BETON,),
                    AFFE_VARC=_F(GROUP_MA = 'POUTRE',
                                 NOM_VARC = 'TEMP',
                                 CHAM_GD=TEMP1,
                                 VALE_REF=0.),
                   )

BLOQ=AFFE_CHAR_MECA(MODELE=MOD,
                     DDL_IMPO=(_F(GROUP_MA=('ENCNEG',),
                                  DX=0.0,
                                  DY=0.0,
                                  ),
                               _F(GROUP_MA=('ENCPOS',),
                                  DY=0.0,
                                  ),
                                ),
                               );


rigiel    = CALC_MATR_ELEM(MODELE=MOD, CHAM_MATER=CHMAT, OPTION='RIGI_MECA', CHARGE=BLOQ)
vecel     = CALC_VECT_ELEM(CHARGE=BLOQ, INST=1.0, CHAM_MATER=CHMAT, OPTION='CHAR_MECA')
numeddl   = NUME_DDL(MATR_RIGI = rigiel)
matass    = ASSE_MATRICE(MATR_ELEM=rigiel , NUME_DDL=numeddl)

matass    = FACTORISER(reuse=matass, MATR_ASSE=matass)

# prise en compte des variables de commande

LIST1=DEFI_LIST_REEL(DEBUT=0.0,
                    INTERVALLE=_F(JUSQU_A=1.0,
                                  NOMBRE=1,),);

CONT1=CALCUL(OPTION=('FORC_VARC_ELEM_P'),
            MODELE=MOD,
            CHAM_MATER=CHMAT,
            INCREMENT=_F(LIST_INST=LIST1,
                         NUME_ORDRE=1),
            EXCIT=_F(CHARGE=BLOQ),
            COMPORTEMENT=_F(RELATION='ELAS',),
            );

VVACRP=EXTR_TABLE(TYPE_RESU='VECT_ELEM_DEPL_R',
                 TABLE=CONT1,
                 NOM_PARA='NOM_SD',
                 FILTRE=_F(NOM_PARA='NOM_OBJET',
                           VALE_K='FORC_VARC_ELEM_P'),)



vecas     = ASSE_VECTEUR(VECT_ELEM=(vecel,VVACRP,), NUME_DDL=numeddl)
RESUREF   = RESOUDRE( MATR = matass, CHAM_NO= vecas )


TEST_RESU(CHAM_NO=(_F(
                   CHAM_GD=RESUREF,
                   VALE_CALC=118.696076203,
                   NOEUD = 'N22',
                   NOM_CMP = 'DX',
                   ),
                ),
          )

MODMACR=AFFE_MODELE(MAILLAGE=MAIL,
                  AFFE=_F(GROUP_MA=('MACREL',
                                    ),
                          PHENOMENE='MECANIQUE',
                          MODELISATION='D_PLAN',),)

BLOQMACR=AFFE_CHAR_MECA(MODELE=MODMACR,
                     DDL_IMPO=(_F(
                                  GROUP_MA=('ENCNEG',),
                                  DX=0.0,
                                  DY=0.0,
                                  ),),
                               );

MACSS=MACR_ELEM_STAT(DEFINITION=_F(MODELE=MODMACR,
                                   CHAM_MATER=CHMAT,
                                   CHAR_MACR_ELEM=BLOQMACR,),
                     EXTERIEUR=_F(GROUP_NO=('EXTERNE')),
                     RIGI_MECA=_F(),
                     CAS_CHARGE=_F(NOM_CAS='K1',
                                   SUIV='OUI',
                                   CHARGE=BLOQMACR,),);

MAYSS=DEFI_MAILLAGE(DEFI_SUPER_MAILLE=_F(MACR_ELEM=MACSS,
                                        SUPER_MAILLE='MAILLE1',),
                    DEFI_NOEUD=_F(TOUT='OUI',
                    INDEX=(1,0,1,8,),),
                                  );

MAG=ASSE_MAILLAGE(MAILLAGE_1=MAIL,
                  MAILLAGE_2=MAYSS,
                  OPERATION='SOUS_STR',);


TEMPMACR=CREA_CHAMP(OPERATION='AFFE',
                    TYPE_CHAM='NOEU_TEMP_R',
                    MAILLAGE=MAG,
                    AFFE=_F( TOUT='OUI',
                             NOM_CMP = ('TEMP',),
                             VALE =50.,
                        )
                )

CHMAT2=AFFE_MATERIAU(MAILLAGE=MAG,
                    AFFE=(_F(TOUT='OUI',
                            MATER=BETON,),
                          ),
                    AFFE_VARC=_F(
                                 GROUP_MA = 'POUPOS',
                                 NOM_VARC = 'TEMP',
                                 CHAM_GD=TEMPMACR,
                                 VALE_REF=0.),
                    )

MOMACR=AFFE_MODELE(MAILLAGE=MAG,
               AFFE_SOUS_STRUC=_F(SUPER_MAILLE='MAILLE1',
                                  PHENOMENE='MECANIQUE',),
               AFFE=_F(GROUP_MA=('POUPOS',),
                       PHENOMENE='MECANIQUE',
                       MODELISATION='D_PLAN',),
                       );


ENCAST2=AFFE_CHAR_MECA(MODELE=MOMACR,
                      DDL_IMPO=_F(GROUP_MA='ENCPOS',
                                  DY=0.0,
                                  ),);

rigiel2    = CALC_MATR_ELEM(MODELE=MOMACR,
                            CHAM_MATER=CHMAT2,
                            OPTION='RIGI_MECA',
                            CHARGE=ENCAST2)
vecel2     = CALC_VECT_ELEM(INST=1.0,
                            CHAM_MATER=CHMAT2,
                            CHARGE=ENCAST2,
                            OPTION='CHAR_MECA',
                            MODELE=MOMACR,
                            SOUS_STRUC=_F(CAS_CHARGE='K1',
                                          SUPER_MAILLE = 'MAILLE1'
                                         )
                            )

# prise en compte des variables de commande

CONT1M=CALCUL(OPTION=('FORC_VARC_ELEM_P'),
            MODELE=MOMACR,
            CHAM_MATER=CHMAT2,
            INCREMENT=_F(LIST_INST=LIST1,
                         NUME_ORDRE=1),
            EXCIT=_F(CHARGE=ENCAST2),
            COMPORTEMENT=_F(RELATION='ELAS',),
            );




VVACRPM=EXTR_TABLE(TYPE_RESU='VECT_ELEM_DEPL_R',
                 TABLE=CONT1M,
                 NOM_PARA='NOM_SD',
                 FILTRE=_F(NOM_PARA='NOM_OBJET',
                           VALE_K='FORC_VARC_ELEM_P'),)

numeddl2   = NUME_DDL(MATR_RIGI = rigiel2)
matass2    = ASSE_MATRICE(MATR_ELEM=rigiel2 , NUME_DDL=numeddl2)
vecas2     = ASSE_VECTEUR(VECT_ELEM=(vecel2, VVACRPM), NUME_DDL=numeddl2)
matass2    = FACTORISER(reuse=matass2, MATR_ASSE=matass2);




RESUMACR   = RESOUDRE( MATR = matass2, CHAM_NO= vecas2 )



TEST_RESU(CHAM_NO=(_F(
                   CHAM_GD=RESUMACR,
                   REFERENCE = 'AUTRE_ASTER',
                   VALE_REFE = 118.696076203,
                   VALE_CALC=118.696076203,
                   NOEUD='N22',
                   NOM_CMP = 'DX',
                   ),
                ),
          )

test.assertEqual(CONT1.getType(), "TABLE_CONTAINER")
test.assertEqual(CONT1M.getType(), "TABLE_CONTAINER")


test.printSummary()

FIN()
