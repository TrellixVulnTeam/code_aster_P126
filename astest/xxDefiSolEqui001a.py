#!/usr/bin/python
# coding: utf-8

import code_aster
from code_aster.Commands import *

code_aster.init()

test = code_aster.TestCase()

# Lecture du maillage
mailcol=code_aster.Mesh()
mailcol.readMedFile("sdnx100i.mmed")

# ----------------- ACCELERO ----------------------- #

FCOUP = 25.
TSM = 10.

SRO_NGA = DEFI_FONCTION(  PROL_DROITE='CONSTANT',PROL_GAUCHE='EXCLU',
                          NOM_PARA='FREQ',
                          ABSCISSE=(0.1, 0.1333, 0.2, 0.25, 0.3333, 0.5, 0.6667, 1.0, 1.3333, 
                                    2.0, 2.5, 3.3333, 4.0, 5.0, 6.6667, 10.0,13.3333, 20.0, 33.3333, 50.0, 100.0),
                          INTERPOL=('LIN', ),
                          ORDONNEE=(0.0037, 0.0065, 0.0144, 0.0180, 0.0291,  0.0605, 0.0984, 0.1659,  0.2298, 0.3682,
                                    0.4480, 0.5366, 0.6022, 0.6846, 0.674,  0.5645,  0.4661,  0.3525,  0.2909,   0.2716, 0.2665),
                          INFO=1, NOM_RESU='TOUTRESU',)


FDSP = CALC_FONCTION ( DSP =_F( FONCTION = SRO_NGA, AMOR_REDUIT = 0.05,
                               FREQ_PAS    = 0.05, FREQ_COUP   = FCOUP, 
                               DUREE = TSM, NORME = 9.81,  NB_ITER=2   ),);

DSPX= DEFI_INTE_SPEC( DIMENSION = 1,
                         PAR_FONCTION = _F(NUME_ORDRE_I = 1, NUME_ORDRE_J = 1, FONCTION =FDSP , )); 

#---------- LECTURE TABLE GGmax - D - DONNEE SOL --------#


tabsol= DEFI_SOL_EQUI(#MAILLAGE=mailcol,
                       GROUP_MA_DROITE='DR8',GROUP_MA_GAUCHE='GA8',
                       GROUP_MA_COL='SURF',GROUP_MA_SUBSTR='BAS',

             MATERIAU=(
                       _F(GAMMA=(0.000001, 0.000003, 0.00001, 0.00003,
                                 0.0001, 0.0003, 0.001, 0.003, 0.01),
                          G_GMAX=(1, 1, 0.99, 0.96,
                                  0.84, 0.66, 0.37, 0.19, 0.08),
                          D=(0.025, 0.025, 0.025, 0.025, 0.025, 0.03,
                             0.04, 0.05, 0.07),
                          ),
                       _F(GAMMA=(0.000001, 0.000003, 0.00001, 0.00003,
                                 0.0001, 0.0003, 0.001, 0.003, 0.01),
                          G_GMAX=(1, 0.99, 0.96, 0.89,
                                  0.75, 0.54, 0.3, 0.15, 0.07),
                          D=(0.025, 0.025, 0.025, 0.025, 0.03,
                             0.04, 0.05, 0.07, 0.1),
                          ),
                       _F(GAMMA=(0.000001, 0.000003, 0.00001, 0.00003,
                                 0.0001, 0.0003, 0.001, 0.003, 0.01),
                          G_GMAX=(1, 0.98, 0.93, 0.83,
                                  0.64, 0.43, 0.22, 0.11, 0.05),
                          D=(0.025, 0.025, 0.025, 0.03,
                             0.04, 0.05, 0.07, 0.1, 0.135 ),
                          ),
                       _F(GAMMA=(0.000001, 0.000003, 0.00001, 0.00003,
                                 0.0001, 0.0003, 0.001, 0.003, 0.01),
                          G_GMAX=(1, 1, 1, 1,
                                  1, 1, 1, 1, 1),
                          D=(0.01, 0.01, 0.01, 0.01,
                             0.01, 0.01, 0.01, 0.01, 0.01, ),
                          ),
                               ),
                     COUCHE=(
                       _F(GROUP_MA='COUCH1A',EPAIS=1.9, E=2.67E8, NU=0.49,
                          RHO=2650., AMOR_HYST=0.05, NUME_MATE=1,),
                       _F(GROUP_MA='COUCH1B',EPAIS=1.9, E=2.67E8, NU=0.49,
                          RHO=2650., AMOR_HYST=0.05, NUME_MATE=1,),
                       _F(GROUP_MA='COUCH1C',EPAIS=1.9, E=2.67E8, NU=0.49,
                          RHO=2650., AMOR_HYST=0.05, NUME_MATE=1,),
                       _F(GROUP_MA='COUCH1D',EPAIS=1.9, E=2.67E8, NU=0.49,
                          RHO=2650., AMOR_HYST=0.05, NUME_MATE=1,),
                       _F(GROUP_MA='COUCH2A',EPAIS=1.9, E=3.35E8, NU=0.49,
                          RHO=2650., AMOR_HYST=0.05, NUME_MATE=1,),
                       _F(GROUP_MA='COUCH2B',EPAIS=1.9, E=3.35E8, NU=0.49,
                          RHO=2650., AMOR_HYST=0.05, NUME_MATE=1,),
                       _F(GROUP_MA='COUCH2C',EPAIS=1.9, E=3.35E8, NU=0.49,
                          RHO=2650., AMOR_HYST=0.05, NUME_MATE=1,),
                       _F(GROUP_MA='COUCH2D',EPAIS=1.9, E=3.35E8, NU=0.49,
                          RHO=2650., AMOR_HYST=0.05, NUME_MATE=1,),
                       _F(GROUP_MA='COUCH3A',EPAIS=4.125, E=9.21E8, NU=0.47,
                          RHO=2710., AMOR_HYST=0.05, NUME_MATE=2,),
                       _F(GROUP_MA='COUCH3B',EPAIS=4.125, E=9.21E8, NU=0.47,
                          RHO=2710., AMOR_HYST=0.05, NUME_MATE=2,),
                       _F(GROUP_MA='COUCH3C',EPAIS=4.125, E=9.21E8, NU=0.47,
                          RHO=2710., AMOR_HYST=0.05, NUME_MATE=2,),
                       _F(GROUP_MA='COUCH3D',EPAIS=4.125, E=9.21E8, NU=0.47,
                          RHO=2710., AMOR_HYST=0.05, NUME_MATE=2,),
                       _F(GROUP_MA='COUCH3E',EPAIS=4.125, E=9.21E8, NU=0.47,
                          RHO=2710., AMOR_HYST=0.05, NUME_MATE=2,),
                       _F(GROUP_MA='COUCH3F',EPAIS=4.125, E=9.21E8, NU=0.47,
                          RHO=2710., AMOR_HYST=0.05, NUME_MATE=2,),
                       _F(GROUP_MA='COUCH3G',EPAIS=4.125, E=9.21E8, NU=0.47,
                          RHO=2710., AMOR_HYST=0.05, NUME_MATE=2,),
                       _F(GROUP_MA='COUCH3H',EPAIS=4.125, E=9.21E8, NU=0.47,
                          RHO=2710., AMOR_HYST=0.05, NUME_MATE=2,),
                       _F(GROUP_MA='COUCH4A',EPAIS=4.25, E=1.39E9, NU=0.47,
                          RHO=2710., AMOR_HYST=0.05, NUME_MATE=2,),
                       _F(GROUP_MA='COUCH4B',EPAIS=4.25, E=1.39E9, NU=0.47,
                          RHO=2710., AMOR_HYST=0.05, NUME_MATE=2,),
                       _F(GROUP_MA='COUCH4C',EPAIS=4.25, E=1.39E9, NU=0.47,
                          RHO=2710., AMOR_HYST=0.05, NUME_MATE=2,),
                       _F(GROUP_MA='COUCH4D',EPAIS=4.25, E=1.39E9, NU=0.47,
                          RHO=2710., AMOR_HYST=0.05, NUME_MATE=2,),
                       _F(GROUP_MA='COUCH4E',EPAIS=4.25, E=1.39E9, NU=0.47,
                          RHO=2710., AMOR_HYST=0.05, NUME_MATE=2,),
                       _F(GROUP_MA='COUCH4F',EPAIS=4.25, E=1.39E9, NU=0.47,
                          RHO=2710., AMOR_HYST=0.05, NUME_MATE=2,),
                       _F(GROUP_MA='COUCH4G',EPAIS=4.25, E=1.39E9, NU=0.47,
                          RHO=2710., AMOR_HYST=0.05, NUME_MATE=2,),
                       _F(GROUP_MA='COUCH4H',EPAIS=4.25, E=1.39E9, NU=0.47,
                          RHO=2710., AMOR_HYST=0.05, NUME_MATE=2,),
                       _F(GROUP_MA='COUCH5A',EPAIS=4.25, E=1.96E9, NU=0.47,
                          RHO=2710., AMOR_HYST=0.05, NUME_MATE=2,),
                       _F(GROUP_MA='COUCH5B',EPAIS=4.25, E=1.96E9, NU=0.47,
                          RHO=2710., AMOR_HYST=0.05, NUME_MATE=2,),
                       _F(GROUP_MA='COUCH5C',EPAIS=4.25, E=1.96E9, NU=0.47,
                          RHO=2710., AMOR_HYST=0.05, NUME_MATE=2,),
                       _F(GROUP_MA='COUCH5D',EPAIS=4.25, E=1.96E9, NU=0.47,
                          RHO=2710., AMOR_HYST=0.05, NUME_MATE=2,),
                       _F(GROUP_MA='COUCH5E',EPAIS=4.25, E=1.96E9, NU=0.47,
                          RHO=2710., AMOR_HYST=0.05, NUME_MATE=2,),
                       _F(GROUP_MA='COUCH5F',EPAIS=4.25, E=1.96E9, NU=0.47,
                          RHO=2710., AMOR_HYST=0.05, NUME_MATE=2,),
                       _F(GROUP_MA='COUCH5G',EPAIS=4.25, E=1.96E9, NU=0.47,
                          RHO=2710., AMOR_HYST=0.05, NUME_MATE=2,),
                       _F(GROUP_MA='COUCH5H',EPAIS=4.25, E=1.96E9, NU=0.47,
                          RHO=2710., AMOR_HYST=0.05, NUME_MATE=2,),
                       _F(GROUP_MA='COUCH6',EPAIS=5.5, E=3.02E9, NU=0.45,
                          RHO=2710., AMOR_HYST=0.05, NUME_MATE=3,),
                       _F(GROUP_MA='COUCH7',EPAIS=5.5, E=5.95E9, NU=0.45,
                          RHO=2710., AMOR_HYST=0.05, NUME_MATE=3,),
                       _F(GROUP_MA='COUCH8',EPAIS=10., E=4.23E10, NU=0.25,
                          RHO=2710., AMOR_HYST=0.02, NUME_MATE=4,),
                            ),
                       LIEU_SIGNAL='CHAMP_LIBRE',
                      DSP = FDSP,
                      DUREE = TSM,
                      UNITE_TABLE_RESU =39,
                      UNITE_RESU_TRAN =40,
                      UNITE_RESU_SPEC =41,
                      UNITE_RESU_DSP = 54,
                       RESI_RELA=0.05,
                       SURF='OUI',
                       FREQ_COUP=FCOUP,
                       COEF_AMPL_ACCE=1.);

IMPR_TABLE(TABLE=tabsol);

                       
#----------- TEST CAS-TEST---------------#



T_resu=LIRE_TABLE(UNITE=39,
               FORMAT='TABLEAU',
               NUME_TABLE=1,
               TITRE='',);

TEST_TABLE(  TABLE=T_resu,
             NOM_PARA='G/Gmax',
             FILTRE=_F(NOM_PARA='M',
                       VALE_K='COUCH2A',
                       CRITERE='RELATIF',
                       ),
             VALE_CALC=( 0.6852491  , ),
             VALE_ABS='NON',)

            
TEST_TABLE(  TABLE=T_resu,
             NOM_PARA='G/Gmax',
             FILTRE=_F(NOM_PARA='M',
                       VALE_K='COUCH4A',
                       CRITERE='RELATIF',
                       ),
             VALE_CALC=(      0.72368654  , ),
             VALE_ABS='NON',)      

TEST_TABLE(  TABLE=T_resu,
             NOM_PARA='AHfin',
             FILTRE=_F(NOM_PARA='M',
                       VALE_K='COUCH4A',
                       CRITERE='RELATIF',
                       ),
             VALE_CALC=(  0.062506044  ),
             VALE_ABS='NON',)
             
TEST_TABLE(  TABLE=T_resu,
             NOM_PARA='AHfin',
             FILTRE=_F(NOM_PARA='M',
                       VALE_K='COUCH2A',
                       CRITERE='RELATIF',
                       ),
             VALE_CALC=(  0.058597272   , ),
             VALE_ABS='NON',)  

TEST_TABLE(  TABLE=T_resu,
             NOM_PARA='gamma_ma',
             FILTRE=_F(NOM_PARA='M',
                       VALE_K='COUCH4A',
                       CRITERE='RELATIF',
                       ),
             VALE_CALC=(  0.00017851907   , ),
             CRITERE='RELATIF',
             VALE_ABS='NON',)
             
TEST_TABLE(  TABLE=T_resu,
             NOM_PARA='gamma_ma',
             FILTRE=_F(NOM_PARA='M',
                       VALE_K='COUCH2A',
                       CRITERE='RELATIF',
                       ),
             VALE_CALC=(  0.00041247863   , ),
             CRITERE='RELATIF',
             VALE_ABS='NON',)


T_SPEC=LIRE_TABLE(UNITE=41,
               FORMAT='TABLEAU',
               NUME_TABLE=1,
               TITRE='SPEC',);

TEST_TABLE(  TABLE=T_SPEC,
             NOM_PARA='ACCE_0',
             FILTRE=_F(NOM_PARA='FREQ',
                       VALE=8.50000E+00,
                       CRITERE='RELATIF',
                       ),
             VALE_CALC=( 0.611206  , ),
             CRITERE='RELATIF',
             VALE_ABS='NON',)

TEST_TABLE(  TABLE=T_SPEC,
             NOM_PARA='ACCE_0',
             FILTRE=_F(NOM_PARA='FREQ',
                       VALE=2.50000E+00,
                       CRITERE='RELATIF',
                       ),
             VALE_CALC=( 0.443876, ),
             CRITERE='RELATIF',
             VALE_ABS='NON',)


test.printSummary()