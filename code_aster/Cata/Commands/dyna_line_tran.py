# coding=utf-8

from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *

# ======================================================================
# COPYRIGHT (C) 1991 - 2015  EDF R&D                  WWW.CODE-ASTER.ORG
# THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
# IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
# THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
# (AT YOUR OPTION) ANY LATER VERSION.
#
# THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
# WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
# MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
# GENERAL PUBLIC LICENSE FOR MORE DETAILS.
#
# YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
# ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
#    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
# ======================================================================
# person_in_charge: emmanuel.boyere at edf.fr
DYNA_LINE_TRAN=OPER(nom="DYNA_LINE_TRAN",op=  48,sd_prod=dyna_trans,
                    fr=tr("Calcul de la réponse dynamique transitoire à une excitation temporelle quelconque"),
                    reentrant='f',
            UIinfo={"groupes":("Résolution","Dynamique",)},
         MODELE          =SIMP(statut='f',typ=modele_sdaster ),
         CHAM_MATER      =SIMP(statut='f',typ=cham_mater ),
         CARA_ELEM       =SIMP(statut='f',typ=cara_elem ),
         MATR_MASS       =SIMP(statut='o',typ=matr_asse_depl_r ),
         MATR_RIGI       =SIMP(statut='o',typ=matr_asse_depl_r ),
         MATR_AMOR       =SIMP(statut='f',typ=matr_asse_depl_r ),

         SCHEMA_TEMPS  =FACT(statut='d',
                SCHEMA =SIMP(statut='f',typ='TXM',defaut="NEWMARK",
                      into=("NEWMARK","WILSON","DIFF_CENTRE","ADAPT_ORDRE2")),
                b_newmark       =BLOC(condition="SCHEMA=='NEWMARK'",
                        BETA           =SIMP(statut='f',typ='R',defaut= 0.25 ),
                        GAMMA           =SIMP(statut='f',typ='R',defaut= 0.5 ),
                        ),
                b_wilson        =BLOC(condition="SCHEMA=='WILSON'",
                        THETA           =SIMP(statut='f',typ='R',defaut= 1.4 ),
                        ),
         ),

         ETAT_INIT       =FACT(statut='f',
           regles=(AU_MOINS_UN('RESULTAT', 'DEPL', 'VITE', 'ACCE'),
                   PRESENT_ABSENT('RESULTAT', 'DEPL', 'VITE', 'ACCE'),),
           RESULTAT     =SIMP(statut='f',typ=dyna_trans ),
           b_dyna_trans    =BLOC(condition = "RESULTAT != None",
             regles=(EXCLUS('NUME_ORDRE','INST_INIT' ),),
             NUME_ORDRE       =SIMP(statut='f',typ='I' ),
             INST_INIT       =SIMP(statut='f',typ='R' ),
             b_inst_init     =BLOC(condition = "INST_INIT != None",
               CRITERE         =SIMP(statut='f',typ='TXM',defaut="RELATIF",into=("RELATIF","ABSOLU") ),
               b_prec_rela=BLOC(condition="(CRITERE=='RELATIF')",
                   PRECISION       =SIMP(statut='f',typ='R',defaut= 1.E-6,),),
               b_prec_abso=BLOC(condition="(CRITERE=='ABSOLU')",
                   PRECISION       =SIMP(statut='o',typ='R',),),
             ),
           ),
           DEPL         =SIMP(statut='f',typ=cham_no_sdaster),
           VITE         =SIMP(statut='f',typ=cham_no_sdaster),
           ACCE         =SIMP(statut='f',typ=cham_no_sdaster),
         ),
         EXCIT           =FACT(statut='f',max='**',
           regles=(UN_PARMI('CHARGE','VECT_ASSE'),
                   EXCLUS('CHARGE','COEF_MULT'),
                   EXCLUS('FONC_MULT','COEF_MULT'),
                   EXCLUS('ACCE','COEF_MULT'),
                   PRESENT_ABSENT('ACCE','FONC_MULT'),
                   PRESENT_PRESENT('ACCE','VITE','DEPL'),
                   # PRESENT_ABSENT('MULT_APPUI','FONC_MULT'),
                   ),
           VECT_ASSE       =SIMP(statut='f',typ=cham_no_sdaster),
           CHARGE          =SIMP(statut='f',typ=char_meca ),
           FONC_MULT       =SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule) ),
           COEF_MULT       =SIMP(statut='f',typ='R' ),
           ACCE            =SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule) ),
           VITE            =SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule) ),
           DEPL            =SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule) ),
           MULT_APPUI      =SIMP(statut='f',typ='TXM',defaut="NON",into=("OUI","NON") ),
           b_mult_appui     =BLOC(condition = "MULT_APPUI == 'OUI'",
           regles=(EXCLUS('NOEUD','GROUP_NO'),),
           DIRECTION       =SIMP(statut='f',typ='R',max='**'),
           NOEUD           =SIMP(statut='f',typ=no  ,validators=NoRepeat(),max='**'),
           GROUP_NO        =SIMP(statut='f',typ=grno,validators=NoRepeat(),max='**'),
         ),),
###
         MODE_STAT       =SIMP(statut='f',typ=mode_meca),
###
         EXCIT_RESU      =FACT(statut='f',max='**',
           RESULTAT        =SIMP(statut='o',typ=dyna_trans ),
           COEF_MULT       =SIMP(statut='o',typ='R' ),
         ),
         AMOR_MODAL      =FACT(statut='f',
           MODE_MECA       =SIMP(statut='o',typ=mode_meca ),
           AMOR_REDUIT     =SIMP(statut='o',typ='R',max='**'),
           NB_MODE         =SIMP(statut='f',typ='I',defaut= 9999 ),
         ),

#-------------------------------------------------------------------
#        Catalogue commun SOLVEUR
         SOLVEUR         =C_SOLVEUR('DYNA_LINE_TRAN'),
#-------------------------------------------------------------------
         INCREMENT       =FACT(statut='o',max='**',
           regles=(UN_PARMI('LIST_INST','PAS'),),
           LIST_INST       =SIMP(statut='f',typ=listr8_sdaster ),
           PAS             =SIMP(statut='f',typ='R' ),
           b_pas           =BLOC(condition = "PAS != None",
               INST_INIT       =SIMP(statut='f',typ='R' ),
               INST_FIN        =SIMP(statut='o',typ='R' ),
           ),
           b_list_fonc     =BLOC(condition = "LIST_INST != None",
               regles=(EXCLUS('INST_FIN','NUME_FIN'),),
               NUME_FIN        =SIMP(statut='f',typ='I' ),
               INST_FIN        =SIMP(statut='f',typ='R' ),
           ),
           VITE_MIN        =SIMP(statut='f',typ='TXM',defaut="NORM",into=("MAXI","NORM") ),
           COEF_MULT_PAS   =SIMP(statut='f',typ='R',defaut= 1.1 ),
           COEF_DIVI_PAS   =SIMP(statut='f',typ='R',defaut= 1.33334 ),
           PAS_LIMI_RELA   =SIMP(statut='f',typ='R',defaut= 1.E-6 ),
           NB_POIN_PERIODE =SIMP(statut='f',typ='I',defaut= 50 ),
           NMAX_ITER_PAS   =SIMP(statut='f',typ='I',defaut= 16 ),
           PAS_MINI         =SIMP(statut='f',typ='R' ),
         ),
         ENERGIE         =FACT(statut='f',max=1,
           CALCUL          =SIMP(statut='f',typ='TXM',into=("OUI",),defaut="OUI",),
         ),
         ARCHIVAGE       =FACT(statut='f',max=1,
           regles         = (EXCLUS('PAS_ARCH','LIST_INST','INST'),),
           LIST_INST      = SIMP(statut='f',typ=(listr8_sdaster) ),
           INST           = SIMP(statut='f',typ='R',validators=NoRepeat(),max='**' ),
           PAS_ARCH       = SIMP(statut='f',typ='I' ),
           CRITERE        = SIMP(statut='f',typ='TXM',defaut="RELATIF",into=("RELATIF","ABSOLU") ),
               b_prec_rela=BLOC(condition="(CRITERE=='RELATIF')",
                    PRECISION       =SIMP(statut='f',typ='R',defaut= 1.E-6,),),
               b_prec_abso=BLOC(condition="(CRITERE=='ABSOLU')",
                    PRECISION       =SIMP(statut='o',typ='R',),),
           CHAM_EXCLU      =SIMP(statut='f',typ='TXM',validators=NoRepeat(),max='**',into=("DEPL","VITE","ACCE") ),
         ),
         TITRE           =SIMP(statut='f',typ='TXM',max='**'),
         INFO            =SIMP(statut='f',typ='I',into=(1,2) ),
)  ;
