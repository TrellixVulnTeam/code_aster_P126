# coding=utf-8
# ======================================================================
# COPYRIGHT (C) 1991 - 2017  EDF R&D                  WWW.CODE-ASTER.ORG
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
# person_in_charge: harinaivo.andriambololona at edf.fr
from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


POST_USURE=OPER(nom="POST_USURE",op=153,sd_prod=table_sdaster,reentrant='f',
                fr=tr("Calcul des volumes d'usure et des profondeurs d'usure d'après la puissance d'usure"),
         regles=(UN_PARMI('TUBE_NEUF','RESU_GENE','PUIS_USURE'),
                 PRESENT_PRESENT('RESU_GENE','LOI_USURE'),
                 PRESENT_PRESENT('PUIS_USURE','LOI_USURE'),),
         reuse=SIMP(statut='c', typ=CO),
         TUBE_NEUF       =SIMP(statut='f',typ='TXM',into=("OUI",) ),
         ETAT_INIT       =FACT(statut='f',
           TABL_USURE      =SIMP(statut='f',typ=table_sdaster),
           INST_INIT       =SIMP(statut='f',typ='R'),
                         ),
         RESU_GENE       =SIMP(statut='f',typ=tran_gene),
         INST_INIT       =SIMP(statut='f',typ='R',defaut=-1.0E+0),
         INST_FIN        =SIMP(statut='f',typ='R'),
         NB_BLOC         =SIMP(statut='f',typ='I',defaut= 1 ),
         PUIS_USURE      =SIMP(statut='f',typ='R'),
         LOI_USURE       =SIMP(statut='f',typ='TXM',into=("ARCHARD","KWU_EPRI","EDF_MZ")),

         b_resu_gene  =BLOC(condition = """exists("RESU_GENE")""",
           regles=UN_PARMI('NOEUD','GROUP_NO'),
            NOEUD           =SIMP(statut='f',typ=no),
            GROUP_NO        =SIMP(statut='f',typ=grno),),
         b_archard       =BLOC(condition = """equal_to("LOI_USURE", 'ARCHARD')""",
           regles=(UN_PARMI('MOBILE','MATER_USURE','SECTEUR'),
                   EXCLUS('MATER_USURE','OBSTACLE'),
                   EXCLUS('MOBILE','USURE_OBST'),),
           MOBILE          =FACT(statut='f',
             COEF_USURE      =SIMP(statut='o',typ='R'),
           ),
           OBSTACLE        =FACT(statut='f',
             COEF_USURE      =SIMP(statut='o',typ='R'),
           ),
           SECTEUR         =FACT(statut='f',max='**',
             COEF_USUR_MOBILE=SIMP(statut='f',typ='R'),
             COEF_USUR_OBST  =SIMP(statut='f',typ='R'),
             ANGL_INIT       =SIMP(statut='f',typ='R'),
             ANGL_FIN        =SIMP(statut='f',typ='R'),
           ),
           MATER_USURE     =SIMP(statut='f',typ='TXM'),
           USURE_OBST      =SIMP(statut='f',typ='TXM',into=("OUI",)),
         ),
         b_kwu_epri        =BLOC(condition = """equal_to("LOI_USURE", 'KWU_EPRI')""",
           regles=(UN_PARMI('MOBILE','MATER_USURE'),
                   EXCLUS('MATER_USURE','OBSTACLE'),
                   EXCLUS('MOBILE','USURE_OBST'),),
           MOBILE          =FACT(statut='f',
             COEF_FNOR       =SIMP(statut='f',typ='R'),
             COEF_VTAN       =SIMP(statut='f',typ='R'),
             COEF_USURE      =SIMP(statut='f',typ='R'),
             COEF_K          =SIMP(statut='f',typ='R',defaut=5.0E+0),
             COEF_C          =SIMP(statut='f',typ='R',defaut=10.0E+0),
           ),
           OBSTACLE        =FACT(statut='f',
             COEF_FNOR       =SIMP(statut='f',typ='R' ),
             COEF_VTAN       =SIMP(statut='f',typ='R' ),
             COEF_USURE      =SIMP(statut='o',typ='R'),
             COEF_K          =SIMP(statut='f',typ='R',defaut=5.0E+0),
             COEF_C          =SIMP(statut='f',typ='R',defaut=10.0E+0),
           ),
           MATER_USURE     =SIMP(statut='f',typ='TXM'),
           USURE_OBST      =SIMP(statut='f',typ='TXM',into=("OUI",)),
           FNOR_MAXI       =SIMP(statut='f',typ='R' ),
           VTAN_MAXI       =SIMP(statut='f',typ='R' ),
         ),
         b_edf_mz          =BLOC(condition = """equal_to("LOI_USURE", 'EDF_MZ')""",
           regles=(UN_PARMI('MOBILE','MATER_USURE'),
                   EXCLUS('MATER_USURE','OBSTACLE'),
                   EXCLUS('MOBILE','USURE_OBST'),),
           MOBILE          =FACT(statut='f',
             COEF_USURE      =SIMP(statut='f',typ='R',defaut=1.0E-13),
             COEF_B          =SIMP(statut='f',typ='R',defaut=1.2E+0),
             COEF_N          =SIMP(statut='f',typ='R',defaut=2.44E-8),
             COEF_S          =SIMP(statut='f',typ='R',defaut=1.14E-16),
           ),
           OBSTACLE        =FACT(statut='f',
             COEF_USURE      =SIMP(statut='o',typ='R',defaut=1.0E-13),
             COEF_B          =SIMP(statut='f',typ='R',defaut=1.2E+0),
             COEF_N          =SIMP(statut='f',typ='R',defaut=2.44E-8),
             COEF_S          =SIMP(statut='f',typ='R',defaut=1.14E-16),
           ),
           MATER_USURE     =SIMP(statut='f',typ='TXM'),
           USURE_OBST      =SIMP(statut='f',typ='TXM',into=("OUI",)),
         ),
         b_tube_neuf       =BLOC(condition = """equal_to("TUBE_NEUF", 'OUI')""",
            TABL_USURE      =SIMP(statut='o',typ=table_sdaster),
         ),
         CONTACT         =SIMP(statut='f',typ='TXM',into=("TUBE_BAV","TUBE_ALESAGE","TUBE_4_ENCO",
                                                          "GRAPPE_ALESAGE","TUBE_3_ENCO","TUBE_TUBE",
                                                          "GRAPPE_1_ENCO","GRAPPE_2_ENCO")),
         RAYON_MOBILE    =SIMP(statut='f',typ='R'),
         RAYON_OBST      =SIMP(statut='f',typ='R'),
         LARGEUR_OBST    =SIMP(statut='f',typ='R'),
         ANGL_INCLI      =SIMP(statut='f',typ='R'),
         ANGL_ISTHME     =SIMP(statut='f',typ='R'),
         ANGL_IMPACT     =SIMP(statut='f',typ='R'),
         INST            =SIMP(statut='f',typ='R',validators=NoRepeat(),max='**'),
         LIST_INST       =SIMP(statut='f',typ=listr8_sdaster),
         COEF_INST       =SIMP(statut='f',typ='R',defaut=1.0E+0),
         INFO            =SIMP(statut='f',typ='I',defaut=1,into=(1,2)),
         TITRE           =SIMP(statut='f',typ='TXM' ),
)  ;
