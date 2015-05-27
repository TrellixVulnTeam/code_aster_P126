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
# person_in_charge: nicolas.greffet at edf.fr
#
DYNA_NON_LINE=OPER(nom="DYNA_NON_LINE",op= 70,sd_prod=evol_noli,reentrant='f',
            fr=tr("Calcul de l'évolution dynamique d'une structure dont le matériau ou la géométrie ont un comportement non linéaire"),
            UIinfo={"groupes":("Résolution","Dynamique",)},
         MODELE          =SIMP(statut='o',typ=modele_sdaster),
         CHAM_MATER      =SIMP(statut='o',typ=cham_mater),
         MODE_STAT       =SIMP(statut='f',typ=mode_meca),
         CARA_ELEM       =SIMP(statut='f',typ=cara_elem),
         MASS_DIAG       =SIMP(statut='f',typ='TXM',into=("OUI","NON",) ),
         EXCIT           =FACT(statut='f',max='**',
           regles=(PRESENT_ABSENT('FONC_MULT','ACCE'),
                   PRESENT_PRESENT('ACCE','VITE','DEPL'),
                   # PRESENT_ABSENT('MULT_APPUI','FONC_MULT'),
                   ),
           TYPE_CHARGE     =SIMP(statut='f',typ='TXM',defaut="FIXE_CSTE",
                                 into=("FIXE_CSTE","SUIV","DIDI")),
           CHARGE          =SIMP(statut='o',typ=(char_meca,char_cine_meca)),
           FONC_MULT       =SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule)),
           DEPL            =SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule)),
           ACCE            =SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule)),
           VITE            =SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule)),
           MULT_APPUI      =SIMP(statut='f',typ='TXM',defaut="NON",into=("OUI","NON") ),
           DIRECTION       =SIMP(statut='f',typ='R',max='**'),
           NOEUD           =SIMP(statut='f',typ=no  ,validators=NoRepeat(),max='**'),
           GROUP_NO        =SIMP(statut='f',typ=grno,validators=NoRepeat(),max='**'),
         ),
         EXCIT_GENE      =FACT(statut='f',max='**',
           FONC_MULT       =SIMP(statut='f',typ=fonction_sdaster,max='**' ),
           VECT_GENE       =SIMP(statut='f',typ=vect_asse_gene,max='**' ),
         ),
         CONTACT         =SIMP(statut='f',typ=char_contact),
         SOUS_STRUC      =FACT(statut='f',min=01,max='**',
                regles=(UN_PARMI('TOUT','SUPER_MAILLE'),),
                CAS_CHARGE  =SIMP(statut='o',typ='TXM' ),
                TOUT        =SIMP(statut='f',typ='TXM',into=("OUI",) ),
                SUPER_MAILLE=SIMP(statut='f',typ=ma,validators=NoRepeat(),max='**',),
                FONC_MULT   =SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule)),
              ),
         AMOR_RAYL_RIGI = SIMP(statut='f',typ='TXM',defaut="TANGENTE",into=("TANGENTE","ELASTIQUE"),),
         AMOR_MODAL      =FACT(statut='f',
           regles=(EXCLUS('AMOR_REDUIT','LIST_AMOR'),),
           MODE_MECA       =SIMP(statut='f',typ=mode_meca),
           AMOR_REDUIT     =SIMP(statut='f',typ='R',max='**' ),
           LIST_AMOR       =SIMP(statut='f',typ=listr8_sdaster ),
           NB_MODE         =SIMP(statut='f',typ='I',defaut= 9999 ),
           REAC_VITE       =SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON") ),
         ),
         PROJ_MODAL      =FACT(statut='f',max='**',
           MODE_MECA       =SIMP(statut='o',typ=mode_meca),
           NB_MODE         =SIMP(statut='f',typ='I',defaut= 9999 ),
           regles=(PRESENT_PRESENT('MASS_GENE','RIGI_GENE'),),
           MASS_GENE       =SIMP(statut='f',typ=matr_asse_gene_r),
           RIGI_GENE       =SIMP(statut='f',typ=matr_asse_gene_r),
           AMOR_GENE       =SIMP(statut='f',typ=matr_asse_gene_r),
           DEPL_INIT_GENE  =SIMP(statut='f',typ=vect_asse_gene),
           VITE_INIT_GENE  =SIMP(statut='f',typ=vect_asse_gene),
           ACCE_INIT_GENE  =SIMP(statut='f',typ=vect_asse_gene),
         ),
#-------------------------------------------------------------------
         COMPORTEMENT      =C_COMPORTEMENT('DYNA_NON_LINE'),
#-------------------------------------------------------------------
         b_reuse =BLOC(condition = "reuse",fr=tr("en mode concept reentrant : ETAT_INIT obligatoire"),
            ETAT_INIT         =C_ETAT_INIT('DYNA_NON_LINE','o'),),
         b_notreuse =BLOC(condition = "not reuse",fr=tr("en mode concept reentrant : ETAT_INIT facultatif"),
            ETAT_INIT         =C_ETAT_INIT('DYNA_NON_LINE','f'),),
#-------------------------------------------------------------------
         INCREMENT         =C_INCREMENT('MECANIQUE'),
#-------------------------------------------------------------------
         SCHEMA_TEMPS     =FACT(statut='o',
            SCHEMA          =SIMP(statut='o',min=1,max=1,typ='TXM',
            into=("DIFF_CENT","TCHAMWA","NEWMARK","HHT","THETA_METHODE","KRENK"),),
            COEF_MASS_SHIFT =SIMP(statut='f',typ='R',defaut= 0.0E+0 ),
            b_tchamwa = BLOC(condition="SCHEMA=='TCHAMWA'",
               PHI          =SIMP(statut='f',typ='R',defaut= 1.05),),

            b_newmark = BLOC(condition="SCHEMA=='NEWMARK'",
               BETA         =SIMP(statut='f',typ='R',defaut= 0.25),
               GAMMA        =SIMP(statut='f',typ='R',defaut= 0.5),),

            b_hht     = BLOC(condition="SCHEMA=='HHT'",
               ALPHA        =SIMP(statut='f',typ='R',defaut= -0.3 ),
               MODI_EQUI    =SIMP(statut='f',typ='TXM',defaut="NON",into=("OUI","NON"),),),

            b_theta   = BLOC(condition="SCHEMA=='THETA_METHODE'",
               THETA         =SIMP(statut='f',typ='R',defaut= 1.,val_min=0.5,val_max=100. ),),

            b_krenk   = BLOC(condition="SCHEMA=='KRENK'",
               KAPPA         =SIMP(statut='f',typ='R',defaut= 1.0,val_min=1.0,val_max=100. ),),

            b_explicit= BLOC(condition="SCHEMA=='TCHAMWA'or SCHEMA=='DIFF_CENT'",
               STOP_CFL     =SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON"),),
               FORMULATION  =SIMP(statut='o',typ='TXM',into=("ACCELERATION",),),),

            b_implicit= BLOC(condition="SCHEMA!='TCHAMWA'and SCHEMA!='DIFF_CENT'",
               FORMULATION  =SIMP(statut='o',max=1,typ='TXM',into=("DEPLACEMENT","VITESSE","ACCELERATION"),),),
         ),
#-------------------------------------------------------------------
         METHODE        =SIMP(statut='d',typ='TXM',defaut="NEWTON",into=("NEWTON","NEWTON_KRYLOV")),
         NEWTON          =C_NEWTON(),
#-------------------------------------------------------------------
         RECH_LINEAIRE   =C_RECH_LINEAIRE(),
#-------------------------------------------------------------------
         CONVERGENCE     =C_CONVERGENCE(),
#-------------------------------------------------------------------
         SOLVEUR         =C_SOLVEUR('DYNA_NON_LINE'),
#-------------------------------------------------------------------
         OBSERVATION     =C_OBSERVATION('MECANIQUE'),
#-------------------------------------------------------------------
         ENERGIE         =FACT(statut='f',max=1,
           CALCUL          =SIMP(statut='f',typ='TXM',into=("OUI",),defaut="OUI",),
         ),
#-------------------------------------------------------------------
         SUIVI_DDL       =C_SUIVI_DDL(),
#-------------------------------------------------------------------
         AFFICHAGE       =C_AFFICHAGE(),
#-------------------------------------------------------------------
         ARCHIVAGE       =C_ARCHIVAGE(),
#-------------------------------------------------------------------
         CRIT_STAB      =FACT(statut='f',min=1,max=1,
           NB_FREQ         =SIMP(statut='f',typ='I',max=1,val_min=1,defaut=3),
           COEF_DIM_ESPACE =SIMP(statut='f',typ='I',max=1,val_min=2,defaut=5),
           RIGI_GEOM     =SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON")),
           MODI_RIGI     =SIMP(statut='f',typ='TXM',defaut="NON",into=("OUI","NON")),
           bloc_char_crit=BLOC(condition="(RIGI_GEOM=='OUI')",
              CHAR_CRIT       =SIMP(statut='f',typ='R',min=2,max=2,
                               fr=tr("Valeur des deux charges critiques délimitant la bande de recherche en HPP")),),
           TYPE          =SIMP(statut='f',typ='TXM',defaut="FLAMBEMENT",into=("FLAMBEMENT","STABILITE")),
           PREC_INSTAB   =SIMP(statut='f',typ='R',defaut=1.E-6,max=1,),
           SIGNE         =SIMP(statut='f',typ='TXM',defaut=("POSITIF_NEGATIF"),into=("NEGATIF","POSITIF","POSITIF_NEGATIF"),max=1,),
           bloc_rigi_geom=BLOC(condition="(RIGI_GEOM=='NON'or MODI_RIGI=='OUI')",
              DDL_EXCLUS      =SIMP(statut='f',typ='TXM',validators=NoRepeat(),max=40,
                                    into=('DX','DY','DZ','DRX','DRY','DRZ','GRX','PRES','PHI',
                                          'TEMP','PRE1','PRE2','UI2','UI3','VI2','VI3','WI2','WI3','UO2',
                                          'UO3','VO2','VO3','WO2','WO3','UI4','UI5','VI4','VI5','WI4',
                                          'WI5','UO4','UO5','VO4','VO5','WO4','WO5','UI6','UO6','VI6',
                                          'VO6','WI6','WO6','WO','WI1','WO1','GONF','LIAISON','DCX',
                                          'DCY','DCZ','H1X','H1Y','H1Z','E1X','E1Y','E1Z','E2X','E2Y','E2Z',
                                          'E3X','E3Y','E3Z','E4X','E4Y','E4Z','LAGS_C','V11','V12','V13','V21','V22',
                                          'V23','V31','V32','V33','PRES11','PRES12','PRES13','PRES21','PRES22','PRES23',
                                          'PRES31','PRES32','PRES33','VARI','LAG_GV','DAMG','DH')),
           bloc_type_stab =BLOC(condition= "TYPE == 'STABILITE' and RIGI_GEOM == 'NON'",
              DDL_STAB        =SIMP(statut='o',typ='TXM',validators=NoRepeat(),min=1,max=40,
                                       into=('DX','DY','DZ','DRX','DRY','DRZ','GRX','PRES','PHI',
                                             'TEMP','PRE1','PRE2','UI2','UI3','VI2','VI3','WI2','WI3','UO2',
                                             'UO3','VO2','VO3','WO2','WO3','UI4','UI5','VI4','VI5','WI4',
                                             'WI5','UO4','UO5','VO4','VO5','WO4','WO5','UI6','UO6','VI6',
                                             'VO6','WI6','WO6','WO','WI1','WO1','GONF','LIAISON','DCX',
                                             'DCY','DCZ','H1X','H1Y','H1Z','E1X','E1Y','E1Z','E2X','E2Y','E2Z',
                                             'E3X','E3Y','E3Z','E4X','E4Y','E4Z','LAGS_C','V11','V12','V13','V21','V22',
                                             'V23','V31','V32','V33','PRES11','PRES12','PRES13','PRES21','PRES22','PRES23',
                                             'PRES31','PRES32','PRES33','VARI','LAG_GV','DAMG','DH')),),
                            ),
           regles         = (EXCLUS('PAS_CALC','LIST_INST','INST'),),
           LIST_INST      = SIMP(statut='f',typ=(listr8_sdaster) ),
           INST           = SIMP(statut='f',typ='R',validators=NoRepeat(),max='**' ),
           PAS_CALC       = SIMP(statut='f',typ='I' ),
           CRITERE        = SIMP(statut='f',typ='TXM',defaut="RELATIF",into=("RELATIF","ABSOLU") ),
              b_prec_rela=BLOC(condition="(CRITERE=='RELATIF')",
                 PRECISION       =SIMP(statut='f',typ='R',defaut= 1.E-6,),),
              b_prec_abso=BLOC(condition="(CRITERE=='ABSOLU')",
                 PRECISION       =SIMP(statut='o',typ='R',),),
         ),
         MODE_VIBR     =FACT(statut='f',min=1,max=1,
           MATR_RIGI        =SIMP(statut='f',typ='TXM',defaut="ELASTIQUE",into=("ELASTIQUE","TANGENTE","SECANTE",) ),
           NB_FREQ          =SIMP(statut='f',typ='I',max=1,val_min=1,defaut=3,
                            fr=tr("Nombre de fréquences propres à calculer")),
           COEF_DIM_ESPACE  =SIMP(statut='f',typ='I',max=1,val_min=2,defaut=5),
           BANDE            =SIMP(statut='f',typ='R',min=2,max=2,
                            fr=tr("Valeur des deux fréquences délimitant la bande de recherche"),),
           regles         = (EXCLUS('PAS_CALC','LIST_INST','INST'),),
           LIST_INST      = SIMP(statut='f',typ=(listr8_sdaster) ),
           INST           = SIMP(statut='f',typ='R',validators=NoRepeat(),max='**' ),
           PAS_CALC       = SIMP(statut='f',typ='I' ),
           CRITERE        = SIMP(statut='f',typ='TXM',defaut="RELATIF",into=("RELATIF","ABSOLU") ),
              b_prec_rela=BLOC(condition="(CRITERE=='RELATIF')",
                 PRECISION       =SIMP(statut='f',typ='R',defaut= 1.E-6,),),
              b_prec_abso=BLOC(condition="(CRITERE=='ABSOLU')",
                 PRECISION       =SIMP(statut='o',typ='R',),),
         ),
#-------------------------------------------------------------------
         INFO            =SIMP(statut='f',typ='I',defaut=1,into=(1,2) ),
         b_info=BLOC(condition="(INFO==2)",
               fr=tr("filtre les messages émis dans le .mess selon le type de message demandé"),
               INFO_DBG = SIMP(statut='f',typ='TXM',max='**',validators=NoRepeat(),
                               into=("CONTACT",
                                     "MECA_NON_LINE",
                                     "PILOTAGE",
                                     "FACTORISATION",
                                     "APPARIEMENT"),
                             ),
                    ),
         TITRE           =SIMP(statut='f',typ='TXM',max='**'),
)
