# coding: utf-8
  
import code_aster
from code_aster.Commands import *
import numpy as np

DEBUT()

# maillage, modele, caraelem

maillage = code_aster.Mesh()
maillage.readMedFile("sdll156a.mmed")

modele = AFFE_MODELE(MAILLAGE = maillage,
                    AFFE = (_F(MODELISATION = "POU_D_T",
                              PHENOMENE = "MECANIQUE",
                              GROUP_MA = "RUN",),
                            _F(MODELISATION = "POU_D_T",
                              PHENOMENE = "MECANIQUE",
                              GROUP_MA = "BRANCH",)
                              
                              
                              
                              ))

acier=DEFI_MATERIAU(ELAS=_F(E = 2.E11,
                            RHO = 7800,
                            ALPHA = 1.2E-5,
                            NU = 0.3),
                    RAMBERG_OSGOOD=_F(FACTEUR=0.01,
                                     EXPOSANT=2)
                    )


t_ini=CREA_CHAMP(
    TYPE_CHAM='NOEU_TEMP_R', OPERATION='AFFE', MODELE=modele,
    AFFE=_F(TOUT='OUI', NOM_CMP='TEMP', VALE=20,),)

t_final=CREA_CHAMP(
                            TYPE_CHAM='NOEU_TEMP_R', OPERATION='AFFE', MODELE=modele,
                            AFFE=_F(TOUT='OUI', NOM_CMP='TEMP', VALE=120.0,),)

resu_temp = CREA_RESU(TYPE_RESU = 'EVOL_THER',
                        NOM_CHAM='TEMP',
                        OPERATION='AFFE',
                        AFFE=(
                            _F(CHAM_GD=t_ini, INST=0.0),
                            _F(CHAM_GD=t_final, INST=1.0),))


ch_mater=AFFE_MATERIAU(MAILLAGE=maillage,
                       AFFE_VARC=_F(TOUT='OUI',NOM_VARC = 'TEMP',EVOL=resu_temp,VALE_REF=20.0,),
                       AFFE=_F(TOUT="OUI", MATER = acier))

cara_elem=AFFE_CARA_ELEM(MODELE=modele, INFO=2,
                         POUTRE=_F(GROUP_MA="TUYAU", SECTION = 'CERCLE',
                                   CARA = ('R', 'EP'),
                                   VALE = (0.01, 0.005)))

# conditions aux limites

blocage_a = AFFE_CHAR_MECA(MODELE=modele,
                           DDL_IMPO=(_F(GROUP_NO='A',
                                        DX=0,DY=0,DZ=0,DRX=0, DRY=0, DRZ=0)))

blocage_b = AFFE_CHAR_MECA(MODELE=modele,
                           DDL_IMPO=(_F(GROUP_NO='B',
                                        DX=0)))

blocage_c = AFFE_CHAR_MECA(MODELE=modele,
                           DDL_IMPO=(_F(GROUP_NO='C',
                                        DZ=0)))

deplacement_b = AFFE_CHAR_MECA(MODELE=modele,
                               DDL_IMPO=(_F(GROUP_NO='B',
                                               DRX=0.02,)))

poids = AFFE_CHAR_MECA(MODELE=modele,
                       PESANTEUR=_F(GRAVITE=9.81,DIRECTION=( 0., 0., -1.),)
                       )

acce_xy=DEFI_FONCTION(NOM_PARA='FREQ',    INTERPOL='LOG',
                      VALE=(1.0, 1.962, 10.0, 19.62,
                            30.0,  19.62,   100.0,    1.962,
                            10000.0,   1.962,          )       )
spect_xy=DEFI_NAPPE(NOM_PARA='AMOR',
                    INTERPOL=('LIN', 'LOG'),
                    PARA=(0.015, 0.02, 0.025,),
                    FONCTION=(acce_xy, acce_xy, acce_xy))

# modes

ASSEMBLAGE(MODELE=modele,
           CHAM_MATER=ch_mater,
           CARA_ELEM=cara_elem,
           CHARGE=blocage_a,
           NUME_DDL=CO('nddl'),
           MATR_ASSE=(_F(MATRICE=CO('matrice_rigi'),
                         OPTION='RIGI_MECA',),
                      _F(MATRICE=CO('matrice_mass'),
                         OPTION='MASS_MECA',),),);

modes_dyn=CALC_MODES(MATR_RIGI=matrice_rigi,
                     MATR_MASS=matrice_mass,
                     CALC_FREQ=_F(NMAX_FREQ=4),
                     )
modes_dyn=CALC_CHAMP(reuse=modes_dyn,
                     RESULTAT=modes_dyn,
                     CONTRAINTE='EFGE_ELNO')

modes_sta=MODE_STATIQUE(MATR_RIGI=matrice_rigi,
                        MATR_MASS=matrice_mass,
                        PSEUDO_MODE=_F(  AXE = ( 'X',  'Y',  'Z', )))
modes_sta=CALC_CHAMP(reuse=modes_sta,
                     RESULTAT=modes_sta,
                     CONTRAINTE='EFGE_ELNO')

# resultats

poids_propre = MECA_STATIQUE(MODELE=modele,
                             CHAM_MATER=ch_mater,
                             CARA_ELEM=cara_elem,
                             EXCIT=(_F(CHARGE=blocage_a),
                                    _F(CHARGE=poids)),
                             INST = 0.0)
poids_propre = CALC_CHAMP(reuse=poids_propre,
                            RESULTAT=poids_propre,
                            CONTRAINTE='EFGE_ELNO')

deplacement_impose = MECA_STATIQUE(MODELE=modele,
                                   CHAM_MATER=ch_mater,
                                   CARA_ELEM=cara_elem,
                                   EXCIT=(_F(CHARGE=blocage_a),
                                           _F(CHARGE=deplacement_b)),
                                   INST = 0.0)
deplacement_impose = CALC_CHAMP(reuse=deplacement_impose,
                                RESULTAT=deplacement_impose,
                                CONTRAINTE='EFGE_ELNO')

dilatation_thermique = MECA_STATIQUE(MODELE=modele,
                                     CHAM_MATER=ch_mater,
                                     CARA_ELEM=cara_elem,
                                     EXCIT=(_F(CHARGE=blocage_a,),
                                            _F(CHARGE=blocage_c,)),
                                     INST = 1.0)
dilatation_thermique = CALC_CHAMP(reuse=dilatation_thermique,
                                  RESULTAT=dilatation_thermique,
                                  CONTRAINTE='EFGE_ELNO')

sismique = COMB_SISM_MODAL(MODE_MECA=modes_dyn,
                           AMOR_REDUIT=0.02,
                           CORR_FREQ='NON',
                           MODE_CORR=modes_sta,
                           MONO_APPUI = 'OUI',
                           EXCIT=_F( TRI_SPEC = 'OUI',
                                     SPEC_OSCI = ( spect_xy,  spect_xy, spect_xy, ),
                           ECHELLE = ( 1.,  1.,  0.5, )),
                           COMB_MODE=_F(  TYPE = 'SRSS'),
                           COMB_DIRECTION=_F(  TYPE = 'QUAD'),
                           OPTION=('EFGE_ELNO')
                          )

# calcul des references pour POST_ROCHE, on extrait uniquement les valeurs de MT, MFY et MFZ non nulles

table = CREA_TABLE(RESU=_F(RESULTAT=poids_propre,
                            NOM_CHAM="EFGE_ELNO",
                            TOUT="OUI",
                            NOM_CMP=("MT", "MFY", "MFZ")))
poids_propre_values = table.EXTR_TABLE().values()
mfy_poids_propre = np.array(poids_propre_values["MFY"])

table = CREA_TABLE(RESU=_F(RESULTAT=deplacement_impose,
                            NOM_CHAM="EFGE_ELNO",
                            TOUT="OUI",
                            NOM_CMP=("MT", "MFY", "MFZ")))
deplacement_impose_values = table.EXTR_TABLE().values()
mt_deplacement_impose = np.array(deplacement_impose_values["MT"])

table = CREA_TABLE(RESU=_F(RESULTAT=dilatation_thermique,
                            NOM_CHAM="EFGE_ELNO",
                            TOUT="OUI",
                            NOM_CMP=("MT", "MFY", "MFZ")))
dilatation_thermique_values = table.EXTR_TABLE().values()
mfy_dilatation_thermique = np.array(dilatation_thermique_values["MFY"])

table = CREA_TABLE(RESU=_F(RESULTAT=sismique,
                            NUME_ORDRE=14,
                            NOM_CHAM="EFGE_ELNO",
                            TOUT="OUI",
                            NOM_CMP=("MT", "MFY", "MFZ")))
sismique_dyn_values = table.EXTR_TABLE().values()
mt_sismique_dyn = np.array(sismique_dyn_values["MT"])
mfy_sismique_dyn = np.array(sismique_dyn_values["MFY"])
mfz_sismique_dyn = np.array(sismique_dyn_values["MFZ"])

table = CREA_TABLE(RESU=_F(RESULTAT=sismique,
                            NUME_ORDRE=24,
                            NOM_CHAM="EFGE_ELNO",
                            TOUT="OUI",
                            NOM_CMP=("MT", "MFY", "MFZ")))
sismique_qs_values = table.EXTR_TABLE().values()
mt_sismique_qs = np.array(sismique_qs_values["MT"])
mfy_sismique_qs = np.array(sismique_qs_values["MFY"])
mfz_sismique_qs = np.array(sismique_qs_values["MFZ"])

from sdll156a_fonctions import PostRocheAnalytic
post_roche_analytic = PostRocheAnalytic(mfy_poids_propre, mt_deplacement_impose, mfy_sismique_dyn, mfz_sismique_dyn, mfy_sismique_qs, mfz_sismique_qs,\
                         mfy_dilatation_thermique, mt_sismique_dyn, mt_sismique_qs)
post_roche_analytic.calcul_ressort()
post_roche_analytic.calcul_abattement()
post_roche_analytic.calcul_sigma_eq()

# appel à POST_ROCHE

chPostRocheTout = POST_ROCHE(ZONE_ANALYSEE=(_F(GROUP_MA='RUN',
                                               GROUP_NO_ORIG = 'A',
                                              ),
                                            _F(GROUP_MA='BRANCH',
                                               GROUP_NO_ORIG = 'C',
                                              ),
                                  ),
                    RESU_MECA=(
                               _F(TYPE_CHAR='POIDS',
                                 RESULTAT=poids_propre,
                                 NUME_ORDRE=1,
                                 ),
                               _F(TYPE_CHAR='DILAT_THERM',
                                 RESULTAT=dilatation_thermique,
                                 NUME_ORDRE=1,
                                 ),
                               _F(TYPE_CHAR='DEPLACEMENT',
                                 RESULTAT=deplacement_impose,
                                 NUME_ORDRE=1,
                                 ),
                                _F(TYPE_CHAR='SISM_INER_SPEC',
                                 RESULTAT=sismique,
                                 DIRECTION='COMBI',
                                 ),
                                ),
                     PRESSION=(_F(
                                     TOUT='OUI',
                                     VALE = 1E6,
                                    ),
                                  ),
                    )

# TEST_RESU

TEST_RESU(CHAM_ELEM=(# X1 = contrainte de référence
                     _F(MAILLE='M1',
                        POINT=1,
                        REFERENCE="ANALYTIQUE",
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X1',
                        VALE_CALC=14541953.839530045,
                        VALE_REFE=post_roche_analytic._sigma_deplacement_ref[0]),
                     _F(MAILLE='M1',
                        POINT=2,
                        REFERENCE="ANALYTIQUE",
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X1',
                        VALE_CALC=13384615.38461542,
                        VALE_REFE=post_roche_analytic._sigma_deplacement_ref[1]),
                     _F(MAILLE='M2',
                        POINT=1,
                        REFERENCE="ANALYTIQUE",
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X1',
                        VALE_CALC=13384615.384615349,
                        VALE_REFE=post_roche_analytic._sigma_deplacement_ref[2]),
                     _F(MAILLE='M2',
                        POINT=2,
                        REFERENCE="ANALYTIQUE",
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X1',
                        VALE_CALC=13384615.384615349,
                        VALE_REFE=post_roche_analytic._sigma_deplacement_ref[3]),
                     # X2 = contrainte de référence S2
                     _F(MAILLE='M1',
                        POINT=1,
                        REFERENCE="ANALYTIQUE",
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X2',
                        VALE_CALC=43474610.549473695,
                        VALE_REFE=post_roche_analytic._sigma_sismique_ref[0]),
                     _F(MAILLE='M1',
                        POINT=2,
                        REFERENCE="ANALYTIQUE",
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X2',
                        VALE_CALC=17938116.906759135,
                        VALE_REFE=post_roche_analytic._sigma_sismique_ref[1]),
                     _F(MAILLE='M2',
                        POINT=1,
                        REFERENCE="ANALYTIQUE",
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X2',
                        VALE_CALC=10477220.030450225,
                        VALE_REFE=post_roche_analytic._sigma_sismique_ref[2]),
                     _F(MAILLE='M2',
                        POINT=2,
                        REFERENCE="ANALYTIQUE",
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X2',
                        ORDRE_GRANDEUR=1.e6,
                        CRITERE="ABSOLU",
                        VALE_CALC=0.,
                        VALE_REFE=post_roche_analytic._sigma_sismique_ref[3]),
                     # X3 = réversibilité locale t
                     _F(MAILLE='M1',
                        POINT=1,
                        REFERENCE="ANALYTIQUE",
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X3',
                        VALE_CALC=0.8527002357080138,
                        VALE_REFE=post_roche_analytic._t[0]),
                     _F(MAILLE='M1',
                        POINT=2,
                        REFERENCE="ANALYTIQUE",
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X3',
                        VALE_CALC=0.8180652597627959,
                        VALE_REFE=post_roche_analytic._t[1]),
                     _F(MAILLE='M2',
                        POINT=1,
                        REFERENCE="ANALYTIQUE",
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X3',
                        VALE_CALC=0.8180652597627939,
                        VALE_REFE=post_roche_analytic._t[2]),
                     _F(MAILLE='M2',
                        POINT=2,
                        REFERENCE="ANALYTIQUE",
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X3',
                        VALE_CALC=0.8180652597627939,
                        VALE_REFE=post_roche_analytic._t[3]),
                     # X4 = réversibilité locale ts
                     _F(MAILLE='M1',
                        POINT=1,
                        REFERENCE="ANALYTIQUE",
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X4',
                        VALE_CALC=1.4743576660612867,
                        VALE_REFE=post_roche_analytic._t_s[0]),
                     _F(MAILLE='M1',
                        POINT=2,
                        REFERENCE="ANALYTIQUE",
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X4',
                        VALE_CALC=0.9470511313218294,
                        VALE_REFE=post_roche_analytic._t_s[1]),
                     _F(MAILLE='M2',
                        POINT=1,
                        REFERENCE="ANALYTIQUE",
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X4',
                        VALE_CALC=0.7237824269229747,
                        VALE_REFE=post_roche_analytic._t_s[2]),
                     _F(MAILLE='M2',
                        POINT=2,
                        REFERENCE="ANALYTIQUE",
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X4',
                        ORDRE_GRANDEUR=1.,
                        VALE_CALC=0.,
                        VALE_REFE=post_roche_analytic._t_s[3]),
                     # X5 = réversibilité totale T
                     _F(MAILLE='M1',
                        POINT=1,
                        REFERENCE="ANALYTIQUE",
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X5',
                        VALE_CALC=0.8275566726302965,
                        VALE_REFE=post_roche_analytic._T[0]),
                     _F(MAILLE='M1',
                        POINT=2,
                        REFERENCE="ANALYTIQUE",
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X5',
                        VALE_CALC=0.8275566726302965,
                        VALE_REFE=post_roche_analytic._T[1]),
                     _F(MAILLE='M2',
                        POINT=1,
                        REFERENCE="ANALYTIQUE",
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X5',
                        VALE_CALC=0.8275566726302965,
                        VALE_REFE=post_roche_analytic._T[2]),
                     _F(MAILLE='M2',
                        POINT=2,
                        REFERENCE="ANALYTIQUE",
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X5',
                        VALE_CALC=0.8275566726302965,
                        VALE_REFE=post_roche_analytic._T[3]),
                     # X6 = réversibilité totale Ts
                     _F(MAILLE='M1',
                        POINT=1,
                        REFERENCE="ANALYTIQUE",
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X6',
                        VALE_CALC=1.3091377252304939,
                        VALE_REFE=post_roche_analytic._T_s[0]),
                     _F(MAILLE='M1',
                        POINT=2,
                        REFERENCE="ANALYTIQUE",
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X6',
                        VALE_CALC=1.3091377252304939,
                        VALE_REFE=post_roche_analytic._T_s[1]),
                     _F(MAILLE='M2',
                        POINT=1,
                        REFERENCE="ANALYTIQUE",
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X6',
                        VALE_CALC=1.3091377252304939,
                        VALE_REFE=post_roche_analytic._T_s[2]),
                     _F(MAILLE='M2',
                        POINT=2,
                        REFERENCE="ANALYTIQUE",
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X6',
                        VALE_CALC=1.3091377252304939,
                        VALE_REFE=post_roche_analytic._T_s[3]),
                     # X7 = facteur d'effet de ressort r_M
                     _F(MAILLE='M1',
                        POINT=1,
                        REFERENCE="ANALYTIQUE",
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X7',
                        VALE_CALC=0.0,
                        ORDRE_GRANDEUR=1.,
                        VALE_REFE=post_roche_analytic._r_m[0]),
                     _F(MAILLE='M1',
                        POINT=2,
                        REFERENCE="ANALYTIQUE",
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X7',
                        VALE_CALC=0.011602268589492093,
                        VALE_REFE=post_roche_analytic._r_m[1]),
                     _F(MAILLE='M2',
                        POINT=1,
                        REFERENCE="ANALYTIQUE",
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X7',
                        VALE_CALC=0.011602268589494757,
                        VALE_REFE=post_roche_analytic._r_m[2]),
                     _F(MAILLE='M2',
                        POINT=2,
                        REFERENCE="ANALYTIQUE",
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X7',
                        VALE_CALC=0.011602268589494757,
                        VALE_REFE=post_roche_analytic._r_m[3]),
                     # X8 = facteur d'effet de ressort r_S
                     _F(MAILLE='M1',
                        POINT=1,
                        REFERENCE="ANALYTIQUE",
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X8',
                        VALE_CALC=0.0,
                        ORDRE_GRANDEUR=1.,
                        VALE_REFE=post_roche_analytic._r_s[0]),
                     _F(MAILLE='M1',
                        POINT=2,
                        REFERENCE="ANALYTIQUE",
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X8',
                        VALE_CALC=0.3823305647745636,
                        VALE_REFE=post_roche_analytic._r_s[1]),
                     _F(MAILLE='M2',
                        POINT=1,
                        REFERENCE="ANALYTIQUE",
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X8',
                        VALE_CALC=0.808744833438479,
                        VALE_REFE=post_roche_analytic._r_s[2]),
                     _F(MAILLE='M2',
                        POINT=2,
                        REFERENCE="ANALYTIQUE",
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X8',
                        ORDRE_GRANDEUR=1.,
                        VALE_CALC=0.,
                        VALE_REFE=post_roche_analytic._r_s[3]),
                     # X9 = facteur d'effet de ressort maximal r_M_Max
                     _F(MAILLE='M1',
                        POINT=1,
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X9',
                        VALE_CALC=0.011602268589494757),
                     _F(MAILLE='M1',
                        POINT=2,
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X9',
                        VALE_CALC=0.011602268589494757),
                     _F(MAILLE='M2',
                        POINT=1,
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X9',
                        VALE_CALC=0.011602268589494757),
                     _F(MAILLE='M2',
                        POINT=2,
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X9',
                        VALE_CALC=0.011602268589494757),
                     # X10 = facteur d'effet de ressort maximal r_S_Max
                     _F(MAILLE='M1',
                        POINT=1,
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X10',
                        VALE_CALC=0.808744833438479),
                     _F(MAILLE='M1',
                        POINT=2,
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X10',
                        VALE_CALC=0.808744833438479),
                     _F(MAILLE='M2',
                        POINT=1,
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X10',
                        VALE_CALC=0.808744833438479),
                     _F(MAILLE='M2',
                        POINT=2,
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X10',
                        VALE_CALC=0.808744833438479),
                     # X11 = coefficient d'abattement g
                     _F(MAILLE='M1',
                        POINT=1,
                        REFERENCE="ANALYTIQUE",
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X11',
                        VALE_CALC=0.3730700795069738,
                        VALE_REFE=post_roche_analytic._g[0]),
                     _F(MAILLE='M1',
                        POINT=2,
                        REFERENCE="ANALYTIQUE",
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X11',
                        VALE_CALC=0.38254709774180523,
                        VALE_REFE=post_roche_analytic._g[1]),
                     _F(MAILLE='M2',
                        POINT=1,
                        REFERENCE="ANALYTIQUE",
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X11',
                        VALE_CALC=0.3825470977418063,
                        VALE_REFE=post_roche_analytic._g[2]),
                     _F(MAILLE='M2',
                        POINT=2,
                        REFERENCE="ANALYTIQUE",
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X11',
                        VALE_CALC=0.3825470977418063,
                        VALE_REFE=post_roche_analytic._g[3]),
                     # X12 = coefficient d'abattement gs
                     _F(MAILLE='M1',
                        POINT=1,
                        REFERENCE="ANALYTIQUE",
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X12',
                        VALE_CALC=0.28780001566475794,
                        VALE_REFE=post_roche_analytic._g_s[0]),
                     _F(MAILLE='M1',
                        POINT=2,
                        REFERENCE="ANALYTIQUE",
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X12',
                        VALE_CALC=0.47069664043955783,
                        VALE_REFE=post_roche_analytic._g_s[1]),
                     _F(MAILLE='M2',
                        POINT=1,
                        REFERENCE="ANALYTIQUE",
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X12',
                        VALE_CALC=0.5721145598182666,
                        VALE_REFE=post_roche_analytic._g_s[2]),
                     _F(MAILLE='M2',
                        POINT=2,
                        REFERENCE="ANALYTIQUE",
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X12',
                        VALE_CALC=1.0,
                        VALE_REFE=post_roche_analytic._g_s[3]),
                     # X13 = coefficient d'abattement optimisé gOpt
                     _F(MAILLE='M1',
                        POINT=1,
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X13',
                        VALE_CALC=0.37686125439238416),
                     _F(MAILLE='M1',
                        POINT=2,
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X13',
                        VALE_CALC=0.38254709774180606),
                     _F(MAILLE='M2',
                        POINT=1,
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X13',
                        VALE_CALC=0.3825470977418063),
                     _F(MAILLE='M2',
                        POINT=2,
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X13',
                        VALE_CALC=0.3825470977418063),
                     # X14 = coefficient d'abattement optimisé gsOpt
                     _F(MAILLE='M1',
                        POINT=1,
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X14',
                        VALE_CALC=0.5345223284320106),
                     _F(MAILLE='M1',
                        POINT=2,
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X14',
                        VALE_CALC=0.5600426892046365),
                     _F(MAILLE='M2',
                        POINT=1,
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X14',
                        VALE_CALC=0.5721145598182666),
                     _F(MAILLE='M2',
                        POINT=2,
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X14',
                        VALE_CALC=1.0),
                     # X15 = contrainte équivalente
                     _F(MAILLE='M1',
                        POINT=1,
                        REFERENCE="ANALYTIQUE",
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X15',
                        VALE_CALC=48171790.86535862,
                        VALE_REFE=post_roche_analytic._sigma_eq[0]),
                     _F(MAILLE='M1',
                        POINT=2,
                        REFERENCE="ANALYTIQUE",
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X15',
                        VALE_CALC=17281614.270636257,
                        VALE_REFE=post_roche_analytic._sigma_eq[1]),
                     _F(MAILLE='M2',
                        POINT=1,
                        REFERENCE="ANALYTIQUE",
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X15',
                        VALE_CALC=15980132.92618753,
                        VALE_REFE=post_roche_analytic._sigma_eq[2]),
                     _F(MAILLE='M2',
                        POINT=2,
                        REFERENCE="ANALYTIQUE",
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X15',
                        VALE_CALC=4850732.26109282,
                        VALE_REFE=post_roche_analytic._sigma_eq[3]),
                     # X16 = contrainte équivalente optimisée
                     _F(MAILLE='M1',
                        POINT=1,
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X16',
                        VALE_CALC=53493492.95672578),
                     _F(MAILLE='M1',
                        POINT=2,
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X16',
                        VALE_CALC=18403586.313146226),
                     _F(MAILLE='M2',
                        POINT=1,
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X16',
                        VALE_CALC=15980132.92618753),
                     _F(MAILLE='M2',
                        POINT=2,
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X16',
                        VALE_CALC=4850732.26109282),
                     # X17 = indicateur sigmaV <sigmaP 
                     _F(MAILLE='M1',
                        POINT=1,
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X17',
                        ORDRE_GRANDEUR=1.,
                        VALE_CALC=0.),
                     _F(MAILLE='M1',
                        POINT=2,
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X17',
                        ORDRE_GRANDEUR=1.,
                        VALE_CALC=0.),
                     _F(MAILLE='M2',
                        POINT=1,
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X17',
                        ORDRE_GRANDEUR=1.,
                        VALE_CALC=0.),
                     _F(MAILLE='M2',
                        POINT=2,
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X17',
                        ORDRE_GRANDEUR=1.,
                        VALE_CALC=0.),
                     # X18 = indicateur sigmaV_s <sigmaP 
                     _F(MAILLE='M1',
                        POINT=1,
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X18',
                        ORDRE_GRANDEUR=1.,
                        VALE_CALC=0.),
                     _F(MAILLE='M1',
                        POINT=2,
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X18',
                        ORDRE_GRANDEUR=1.,
                        VALE_CALC=0.),
                     _F(MAILLE='M2',
                        POINT=1,
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X18',
                        ORDRE_GRANDEUR=1.,
                        VALE_CALC=0.),
                     _F(MAILLE='M2',
                        POINT=2,
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X18',
                        ORDRE_GRANDEUR=1.,
                        VALE_CALC=0.),
                     # X19 = indicateur sigmaV_opt <sigmaP 
                     _F(MAILLE='M1',
                        POINT=1,
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X19',
                        ORDRE_GRANDEUR=1.,
                        VALE_CALC=0.),
                     _F(MAILLE='M1',
                        POINT=2,
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X19',
                        ORDRE_GRANDEUR=1.,
                        VALE_CALC=0.),
                     _F(MAILLE='M2',
                        POINT=1,
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X19',
                        ORDRE_GRANDEUR=1.,
                        VALE_CALC=0.),
                     _F(MAILLE='M2',
                        POINT=2,
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X19',
                        ORDRE_GRANDEUR=1.,
                        VALE_CALC=0.),
                     # X20 = indicateur sigmaV_s_opt <sigmaP 
                     _F(MAILLE='M1',
                        POINT=1,
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X20',
                        ORDRE_GRANDEUR=1.,
                        VALE_CALC=0.),
                     _F(MAILLE='M1',
                        POINT=2,
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X20',
                        ORDRE_GRANDEUR=1.,
                        VALE_CALC=0.),
                     _F(MAILLE='M2',
                        POINT=1,
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X20',
                        ORDRE_GRANDEUR=1.,
                        VALE_CALC=0.),
                     _F(MAILLE='M2',
                        POINT=2,
                        CHAM_GD=chPostRocheTout,
                        NOM_CMP='X20',
                        ORDRE_GRANDEUR=1.,
                        VALE_CALC=0.),
                    )
        )

FIN()
