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
# person_in_charge: francois.voldoire at edf.fr


MACR_SPECTRE=MACRO(nom="MACR_SPECTRE",
                   op=OPS('Macro.macr_spectre_ops.macr_spectre_ops'),
                   sd_prod=table_sdaster,
                   reentrant='n',
                   UIinfo={"groupes":("Post-traitements","Outils-métier",)},
                   fr=tr("Calcul de spectre, post-traitement de séisme"),
         MAILLAGE      =SIMP(statut='f',typ=maillage_sdaster,position='global',),
         PLANCHER      =FACT(statut='o',max='**',
            NOM           =SIMP(statut='o',typ='TXM',),
            b_maillage=BLOC( condition = "MAILLAGE != None",
                regles=(AU_MOINS_UN('GROUP_NO','NOEUD'),),
                GROUP_NO      =SIMP(statut='f',typ=grno,validators=NoRepeat(),max='**'),
                NOEUD         =SIMP(statut='f',typ=no  ,validators=NoRepeat(),max='**'),
            ),
            b_no_maillage=BLOC( condition = "MAILLAGE == None",
                NOEUD         =SIMP(statut='o',typ=no  ,validators=NoRepeat(),max='**'),
            ),
         ),
         NOM_CHAM      =SIMP(statut='o',typ='TXM' ,into=('ACCE','DEPL')),
         CALCUL        =SIMP(statut='o',typ='TXM' ,into=('ABSOLU','RELATIF'),position='global'),
         b_acce  =BLOC( condition = "NOM_CHAM=='ACCE'",
           regles=(UN_PARMI('LIST_FREQ','FREQ'),),
           AMOR_SPEC     =SIMP(statut='o',typ='R',max='**'),
           LIST_INST     =SIMP(statut='f',typ=listr8_sdaster ),
           LIST_FREQ     =SIMP(statut='f',typ=listr8_sdaster ),
           FREQ          =SIMP(statut='f',typ='R',max='**'),
           NORME         =SIMP(statut='o',typ='R'),
           RESU          =FACT(statut='o',max='**',
                regles=(UN_PARMI('RESU_GENE','RESULTAT','TABLE'),),
                TABLE         =SIMP(statut='f',typ=table_sdaster),
                RESU_GENE     =SIMP(statut='f',typ=tran_gene),
                RESULTAT      =SIMP(statut='f',typ=(dyna_trans,evol_noli)),
                b_calc  =BLOC( condition = "CALCUL=='RELATIF'",
                   ACCE_X        =SIMP(statut='o',typ=fonction_sdaster),
                   ACCE_Y        =SIMP(statut='o',typ=fonction_sdaster),
                   ACCE_Z        =SIMP(statut='o',typ=fonction_sdaster),), ),
                b_calc  =BLOC( condition = "CALCUL=='ABSOLU'" ,
                   MULT_APPUI        =SIMP(statut='f',typ='TXM', into=("OUI",),),),
           IMPRESSION    =FACT(statut='f',
                TRI           =SIMP(statut='f',typ='TXM',defaut='AMOR_SPEC',into=("AMOR_SPEC","DIRECTION",),),
                FORMAT        =SIMP(statut='f',typ='TXM',defaut='TABLEAU',into=("TABLEAU","XMGRACE",),),
                UNITE         =SIMP(statut='f',typ='I',val_min=10,val_max=90,defaut=29,
                                    fr=tr("Unité logique définissant le fichier (fort.N) dans lequel on écrit")),
                b_pilote = BLOC(condition = "FORMAT == 'XMGRACE'",
                   PILOTE        =SIMP(statut='f',typ='TXM',defaut='',
                                 into=('','POSTSCRIPT','EPS','MIF','SVG','PNM','PNG','JPEG','PDF','INTERACTIF'),),),
                TOUT          =SIMP(statut='f',typ='TXM',defaut='NON',into=("OUI","NON",),),
                              ),
         ),
         b_depl  =BLOC( condition = "NOM_CHAM=='DEPL'",
           LIST_INST     =SIMP(statut='f',typ=listr8_sdaster),
           RESU          =FACT(statut='o',max=3,
                regles=(UN_PARMI('RESU_GENE','RESULTAT','TABLE'),),
                TABLE         =SIMP(statut='f',typ=table_sdaster),
                RESU_GENE     =SIMP(statut='f',typ=tran_gene),
                RESULTAT      =SIMP(statut='f',typ=(dyna_trans,evol_noli)),
                b_calc  =BLOC( condition = "CALCUL=='ABSOLU'",
                   DEPL_X        =SIMP(statut='o',typ=fonction_sdaster),
                   DEPL_Y        =SIMP(statut='o',typ=fonction_sdaster),
                   DEPL_Z        =SIMP(statut='o',typ=fonction_sdaster),),),
         ),
)
