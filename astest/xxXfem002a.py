# coding: utf-8

import code_aster
from code_aster.Commands import *

code_aster.init()

test = code_aster.TestCase()


#----------------------------------------------
#            MAILLAGE
#----------------------------------------------

MA=LIRE_MAILLAGE(INFO=1,FORMAT='MED',);

# longueur du cote de la plaque
L = 1.

# GROUPES SUR LESQUELS ON VA IMPOSER LES DIRICHLETS
MA=DEFI_GROUP(reuse =MA,
              MAILLAGE=MA,
              CREA_GROUP_NO=(_F(NOM = 'LIGNSUP',GROUP_MA='LIGSUP',),
                             _F(NOM = 'LIGNINF',GROUP_MA='LIGINF',),),)

#----------------------------------------------
#            MODELE ET FISSURE
#----------------------------------------------

MODTHIN=AFFE_MODELE(MAILLAGE=MA,
                    AFFE=_F(GROUP_MA='SURF',
                            PHENOMENE='THERMIQUE',
                            MODELISATION='PLAN',),);

FISSTH=DEFI_FISS_XFEM(MAILLAGE=MA, TYPE_ENRI_FOND='TOPOLOGIQUE',
                      DEFI_FISS=_F(FORM_FISS='DEMI_DROITE',
                                   PFON=( 0.5*L, 0.5*L, 0.,),
                                   DTAN=(   -1.,    0., 0.,),),
                      INFO=1,);

MODTHX=MODI_MODELE_XFEM(MODELE_IN=MODTHIN,
                        FISSURE=FISSTH,
                        INFO=2,);

#----------------------------------------------
#            MATERIAU
#----------------------------------------------

MATE=DEFI_MATERIAU(THER=_F(LAMBDA=1.0,RHO_CP = 2.0))

CHMAT=AFFE_MATERIAU(MAILLAGE=MA,
                    MODELE=MODTHX,
                    AFFE=_F(TOUT='OUI',MATER=MATE,),)


#----------------------------------------------
#            CHARGEMENT THERMIQUE
#----------------------------------------------

CHTH=AFFE_CHAR_THER(MODELE=MODTHX,
                    TEMP_IMPO=(
                               _F(GROUP_NO = 'LIGNSUP',TEMP = 20.),
                               _F(GROUP_NO = 'LIGNINF',TEMP = 10.),
                               ))

CHTCONTR=AFFE_CHAR_THER(MODELE=MODTHX,
                        ECHANGE_PAROI=_F(FISSURE = FISSTH,
                                         TEMP_CONTINUE = 'OUI',),)

CHTCONTF=AFFE_CHAR_THER_F(MODELE=MODTHX,
                          ECHANGE_PAROI=_F(FISSURE = FISSTH,
                                           TEMP_CONTINUE = 'OUI',),)

#----------------------------------------------
#            CALCUL THERMIQUE LINEAIRE TRANSITOIRE
#----------------------------------------------

# CAS OU LE CHARGEMENT TEMP_CONTINUE EST CREE AVEC AFFE_CHAR_THER

TEMPEXR=THER_LINEAIRE(MODELE=MODTHX,
                      CHAM_MATER=CHMAT,
                      EXCIT=(_F(CHARGE=CHTH,),
                             _F(CHARGE=CHTCONTR,),),)

# CAS OU LE CHARGEMENT TEMP_CONTINUE EST CREE AVEC AFFE_CHAR_THER_F

TEMPEXF=THER_LINEAIRE(MODELE=MODTHX,
                      CHAM_MATER=CHMAT,
                      EXCIT=(_F(CHARGE=CHTH,),
                             _F(CHARGE=CHTCONTF,),),)

#----------------------------------------------
#            POST-TRAITEMENTS
#----------------------------------------------

MA_VISU=POST_MAIL_XFEM(MODELE=MODTHX)

# GROUPES SUR LESQUELS ON VA TESTER LES VALEURS DE T
hsain = L/101.
hfiss = 0.5*hsain
MA_VISU=DEFI_GROUP(reuse =MA_VISU,
                   MAILLAGE=MA_VISU,
                   CREA_GROUP_MA=(
                                  _F(NOM='MASUPTMP',OPTION='SPHERE',
                                     POINT=(L,0.5*L+hfiss),RAYON=1.e-6*hfiss),
                                  _F(NOM='MAINFTMP',OPTION='SPHERE',
                                     POINT=(L,0.5*L-hfiss),RAYON=1.e-6*hfiss),
                                  ),
                   CREA_GROUP_NO=(
                                  _F(GROUP_MA='MASUPTMP',),
                                  _F(GROUP_MA='MAINFTMP',),
                                  _F(NOM='GNFOND',OPTION='ENV_SPHERE',
                                     POINT=(0.5*L,0.5*L,),RAYON=1.e-6*hfiss,
                                     PRECISION=1.e-6*hfiss),
                                  _F(NOM='GNOTMP',OPTION='ENV_SPHERE',
                                     POINT=(L,0.5*L,),RAYON=1.e-6*hfiss,
                                     PRECISION=1.e-6*hfiss),
                                  _F(NOM='NTESTSUP',INTERSEC=('GNOTMP','MASUPTMP')),
                                  _F(NOM='NTESTINF',INTERSEC=('GNOTMP','MAINFTMP')),
                                  ),)

MOD_VISU=AFFE_MODELE(MAILLAGE=MA_VISU,
                     AFFE=_F(TOUT='OUI',
                             PHENOMENE='THERMIQUE',
                             MODELISATION='PLAN',),)

RES_VISR=POST_CHAM_XFEM(MODELE_VISU = MOD_VISU,
                        RESULTAT    = TEMPEXR)

RES_VISF=POST_CHAM_XFEM(MODELE_VISU = MOD_VISU,
                        RESULTAT    = TEMPEXF)

test.assertEqual(RES_VISR.getType(), "EVOL_THER")
#----------------------------------------------
#            RELEVES
#----------------------------------------------

TEMPSUPR=POST_RELEVE_T(ACTION=_F(INTITULE='TEMPE',
                                GROUP_NO='NTESTSUP',
                                RESULTAT=RES_VISR,
                                NOM_CHAM='TEMP',
                                TOUT_CMP='OUI',
                                NUME_ORDRE = 0,
                                OPERATION='EXTRACTION',),)

TEMPINFR=POST_RELEVE_T(ACTION=_F(INTITULE='TEMPE',
                                GROUP_NO='NTESTINF',
                                RESULTAT=RES_VISR,
                                NOM_CHAM='TEMP',
                                TOUT_CMP='OUI',
                                NUME_ORDRE = 0,
                                OPERATION='EXTRACTION',),)

TEMPFONR=POST_RELEVE_T(ACTION=_F(INTITULE='TEMPE',
                                GROUP_NO='GNFOND',
                                RESULTAT=RES_VISR,
                                NOM_CHAM='TEMP',
                                TOUT_CMP='OUI',
                                NUME_ORDRE = 0,
                                OPERATION='EXTRACTION',),)

TEMPSUPF=POST_RELEVE_T(ACTION=_F(INTITULE='TEMPE',
                                GROUP_NO='NTESTSUP',
                                RESULTAT=RES_VISF,
                                NOM_CHAM='TEMP',
                                TOUT_CMP='OUI',
                                NUME_ORDRE = 0,
                                OPERATION='EXTRACTION',),)

TEMPINFF=POST_RELEVE_T(ACTION=_F(INTITULE='TEMPE',
                                GROUP_NO='NTESTINF',
                                RESULTAT=RES_VISF,
                                NOM_CHAM='TEMP',
                                TOUT_CMP='OUI',
                                NUME_ORDRE = 0,
                                OPERATION='EXTRACTION',),)

TEMPFONF=POST_RELEVE_T(ACTION=_F(INTITULE='TEMPE',
                                GROUP_NO='GNFOND',
                                RESULTAT=RES_VISF,
                                NOM_CHAM='TEMP',
                                TOUT_CMP='OUI',
                                NUME_ORDRE = 0,
                                OPERATION='EXTRACTION',),)

#----------------------------------------------
#            TESTS
#----------------------------------------------

# CAS OU LE CHARGEMENT TEMP_CONTINUE EST CREE AVEC AFFE_CHAR_THER

TEST_TABLE(REFERENCE='ANALYTIQUE',
           VALE_CALC=15.0,
           VALE_REFE=15.0,
           NOM_PARA='TEMP',
           TABLE=TEMPSUPR,)

TEST_TABLE(REFERENCE='ANALYTIQUE',
           VALE_CALC=15.0,
           VALE_REFE=15.0,
           NOM_PARA='TEMP',
           TABLE=TEMPINFR,)

TEST_TABLE(REFERENCE='ANALYTIQUE',
           VALE_CALC=15.0,
           VALE_REFE=15.0,
           NOM_PARA='TEMP',
           TYPE_TEST='MIN',
           TABLE=TEMPFONR,)

TEST_TABLE(REFERENCE='ANALYTIQUE',
           VALE_CALC=15.0,
           VALE_REFE=15.0,
           NOM_PARA='TEMP',
           TYPE_TEST='MAX',
           TABLE=TEMPFONR,)

# CAS OU LE CHARGEMENT TEMP_CONTINUE EST CREE AVEC AFFE_CHAR_THER_F

TEST_TABLE(REFERENCE='ANALYTIQUE',
           VALE_CALC=15.0,
           VALE_REFE=15.0,
           NOM_PARA='TEMP',
           TABLE=TEMPSUPF,)

TEST_TABLE(REFERENCE='ANALYTIQUE',
           VALE_CALC=15.0,
           VALE_REFE=15.0,
           NOM_PARA='TEMP',
           TABLE=TEMPINFF,)

TEST_TABLE(REFERENCE='ANALYTIQUE',
           VALE_CALC=15.0,
           VALE_REFE=15.0,
           NOM_PARA='TEMP',
           TYPE_TEST='MIN',
           TABLE=TEMPFONF,)

TEST_TABLE(REFERENCE='ANALYTIQUE',
           VALE_CALC=15.0,
           VALE_REFE=15.0,
           NOM_PARA='TEMP',
           TYPE_TEST='MAX',
           TABLE=TEMPFONF,)

# TEST SUR LE GRADIENT DE TEMPERATURE SELON X
# CAS OU LE CHARGEMENT TEMP_CONTINUE EST CREE AVEC AFFE_CHAR_THER

TEST_RESU(RESU=(_F(RESULTAT=TEMPEXR,
                   NOM_CHAM='TEMP_ELGA',
                   NOM_CMP='DTX',
                   NUME_ORDRE = 0,
                   MAILLE='M4999',
                   POINT=13,
                   REFERENCE = 'ANALYTIQUE' ,
                   VALE_REFE=0.,
                   PRECISION= 1.0E-9,
                   VALE_CALC=-5.96855898038E-13    ,
                   CRITERE='ABSOLU',),),);
TEST_RESU(RESU=(_F(RESULTAT=TEMPEXR,
                   NOM_CHAM='TEMP_ELGA',
                   NOM_CMP='DTX',
                   NUME_ORDRE = 0,
                   MAILLE='M5001',
                   POINT=1,
                   REFERENCE = 'ANALYTIQUE' ,
                   VALE_REFE=0.,
                   PRECISION= 1.0E-9,
                   VALE_CALC=-9.37906191503E-13 ,
                   CRITERE='ABSOLU',),),);
TEST_RESU(RESU=(_F(RESULTAT=TEMPEXR,
                   NOM_CHAM='TEMP_ELGA',
                   NOM_CMP='DTX',
                   NUME_ORDRE = 0,
                   MAILLE='M5150',
                   POINT=1,
                   REFERENCE = 'ANALYTIQUE' ,
                   VALE_REFE=0.,
                   PRECISION= 1.0E-9,
                   VALE_CALC=0.0  ,
                   CRITERE='ABSOLU',),),);

# CAS OU LE CHARGEMENT TEMP_CONTINUE EST CREE AVEC AFFE_CHAR_THER_F

TEST_RESU(RESU=(_F(RESULTAT=TEMPEXF,
                   NOM_CHAM='TEMP_ELGA',
                   NOM_CMP='DTX',
                   NUME_ORDRE = 0,
                   MAILLE='M4999',
                   POINT=13,
                   REFERENCE = 'ANALYTIQUE' ,
                   VALE_REFE=0.,
                   PRECISION= 1.0E-9,
                   VALE_CALC=-5.96855898038E-13  ,
                   CRITERE='ABSOLU',),),);
TEST_RESU(RESU=(_F(RESULTAT=TEMPEXF,
                   NOM_CHAM='TEMP_ELGA',
                   NOM_CMP='DTX',
                   NUME_ORDRE = 0,
                   MAILLE='M5150',
                   POINT=13,
                   REFERENCE = 'ANALYTIQUE' ,
                   VALE_REFE=0.,
                   PRECISION= 1.0E-9,
                   VALE_CALC=9.40558337779E-15 ,
                   CRITERE='ABSOLU',),),);
TEST_RESU(RESU=(_F(RESULTAT=TEMPEXF,
                   NOM_CHAM='TEMP_ELGA',
                   NOM_CMP='DTX',
                   NUME_ORDRE = 0,
                   MAILLE='M5001',
                   POINT=1,
                   REFERENCE = 'ANALYTIQUE' ,
                   VALE_REFE=0.,
                   PRECISION= 1.0E-9,
                   VALE_CALC=-9.37906191503E-13  ,
                   CRITERE='ABSOLU',),),);

# TEST SUR LE GRADIENT DE TEMPERATURE SELON Y
# CAS OU LE CHARGEMENT TEMP_CONTINUE EST CREE AVEC AFFE_CHAR_THER

TEST_RESU(RESU=(_F(RESULTAT=TEMPEXR,
                   NOM_CHAM='TEMP_ELGA',
                   NOM_CMP='DTY',
                   NUME_ORDRE = 0,
                   MAILLE='M4999',
                   POINT=1,
                   REFERENCE = 'ANALYTIQUE' ,
                   VALE_REFE=10.,
                   VALE_CALC=10.0,
                   CRITERE='RELATIF',),),);
TEST_RESU(RESU=(_F(RESULTAT=TEMPEXR,
                   NOM_CHAM='TEMP_ELGA',
                   NOM_CMP='DTY',
                   NUME_ORDRE = 0,
                   MAILLE='M5001',
                   POINT=1,
                   REFERENCE = 'ANALYTIQUE' ,
                   VALE_REFE=10.,
                   VALE_CALC=10.0,
                   CRITERE='RELATIF',),),);
TEST_RESU(RESU=(_F(RESULTAT=TEMPEXR,
                   NOM_CHAM='TEMP_ELGA',
                   NOM_CMP='DTY',
                   NUME_ORDRE = 0,
                   MAILLE='M5150',
                   POINT=1,
                   REFERENCE = 'ANALYTIQUE' ,
                   VALE_REFE=10.,
                   VALE_CALC=10.0 ,
                   CRITERE='RELATIF',),),);

# CAS OU LE CHARGEMENT TEMP_CONTINUE EST CREE AVEC AFFE_CHAR_THER_F

TEST_RESU(RESU=(_F(RESULTAT=TEMPEXF,
                   NOM_CHAM='TEMP_ELGA',
                   NOM_CMP='DTY',
                   NUME_ORDRE = 0,
                   MAILLE='M4999',
                   POINT=1,
                   REFERENCE = 'ANALYTIQUE' ,
                   VALE_REFE=10.,
                   VALE_CALC=10.0  ,
                   CRITERE='RELATIF',),),);
TEST_RESU(RESU=(_F(RESULTAT=TEMPEXF,
                   NOM_CHAM='TEMP_ELGA',
                   NOM_CMP='DTY',
                   NUME_ORDRE = 0,
                   MAILLE='M5150',
                   POINT=1,
                   REFERENCE = 'ANALYTIQUE' ,
                   VALE_REFE=10.,
                   VALE_CALC=10.0  ,
                   CRITERE='RELATIF',), ),);
TEST_RESU(RESU=(_F(RESULTAT=TEMPEXF,
                   NOM_CHAM='TEMP_ELGA',
                   NOM_CMP='DTY',
                   NUME_ORDRE = 0,
                   MAILLE='M5001',
                   POINT=1,
                   REFERENCE = 'ANALYTIQUE' ,
                   VALE_REFE=10.,
                   VALE_CALC=10.0  ,
                   CRITERE='RELATIF',),),);


test.printSummary()

FIN()
