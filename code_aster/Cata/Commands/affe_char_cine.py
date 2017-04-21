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
# person_in_charge: jacques.pellet at edf.fr
from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


def affe_char_cine_prod(MECA_IMPO,THER_IMPO,ACOU_IMPO,EVOL_IMPO,**args):
  if MECA_IMPO != None  : return char_cine_meca
  if THER_IMPO != None  : return char_cine_ther
  if ACOU_IMPO != None  : return char_cine_acou
  if EVOL_IMPO != None  :
      if AsType(EVOL_IMPO) in (evol_elas,evol_noli) :
          return char_cine_meca
      elif AsType(EVOL_IMPO) in (evol_ther,) :
          return char_cine_ther
      else :
          raise AsException("Extension à faire ...")

  raise AsException("type de concept resultat non prevu")


AFFE_CHAR_CINE=OPER(nom="AFFE_CHAR_CINE",op= 101,sd_prod=affe_char_cine_prod
                    ,fr=tr("Affectation de conditions aux limites cinématiques (U=U0) pour un traitement sans dualisation"),
                     reentrant='n',
         regles=(UN_PARMI('MECA_IMPO','THER_IMPO','ACOU_IMPO','EVOL_IMPO'),
                 ),
         MODELE          =SIMP(statut='o',typ=modele_sdaster ),

         MECA_IMPO       =FACT(statut='f',max='**',
           regles=(UN_PARMI('TOUT','GROUP_MA','MAILLE','GROUP_NO','NOEUD'),
                   AU_MOINS_UN('DX','DY','DZ','DRX','DRY','DRZ','GRX','PRES','PHI',
                               'TEMP','PRE1','PRE2','UI2','UI3','VI2','VI3','WI2','WI3','UO2',
                               'UO3','VO2','VO3','WO2','WO3','UI4','UI5','VI4','VI5','WI4',
                               'WI5','UO4','UO5','VO4','VO5','WO4','WO5','UI6','UO6','VI6',
                               'VO6','WI6','WO6','WO','WI1','WO1','GONF',
                               'H1X','H1Y','H1Z','H1PRE1','K1','K2','K3','V11','V12','V13','V21','V22',
                               'V23','V31','V32','V33','PRES11','PRES12','PRES13','PRES21',
                               'PRES22','PRES23','PRES31','PRES32','PRES33','LH1','GLIS'),),
             TOUT            =SIMP(statut='f',typ='TXM',into=("OUI",) ),
             GROUP_MA        =SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
             MAILLE          =SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
             GROUP_NO        =SIMP(statut='f',typ=grno,validators=NoRepeat(),max='**'),
             NOEUD           =SIMP(statut='f',typ=no  ,validators=NoRepeat(),max='**'),
             DX              =SIMP(statut='f',typ='R' ),
             DY              =SIMP(statut='f',typ='R' ),
             DZ              =SIMP(statut='f',typ='R' ),
             DRX             =SIMP(statut='f',typ='R' ),
             DRY             =SIMP(statut='f',typ='R' ),
             DRZ             =SIMP(statut='f',typ='R' ),
             GRX             =SIMP(statut='f',typ='R' ),
             PRES            =SIMP(statut='f',typ='R' ),
             PHI             =SIMP(statut='f',typ='R' ),
             TEMP            =SIMP(statut='f',typ='R' ),
             PRE1            =SIMP(statut='f',typ='R' ),
             PRE2            =SIMP(statut='f',typ='R' ),
             UI2             =SIMP(statut='f',typ='R' ),
             UI3             =SIMP(statut='f',typ='R' ),
             UI4             =SIMP(statut='f',typ='R' ),
             UI5             =SIMP(statut='f',typ='R' ),
             UI6             =SIMP(statut='f',typ='R' ),
             UO2             =SIMP(statut='f',typ='R' ),
             UO3             =SIMP(statut='f',typ='R' ),
             UO4             =SIMP(statut='f',typ='R' ),
             UO5             =SIMP(statut='f',typ='R' ),
             UO6             =SIMP(statut='f',typ='R' ),
             VI2             =SIMP(statut='f',typ='R' ),
             VI3             =SIMP(statut='f',typ='R' ),
             VI4             =SIMP(statut='f',typ='R' ),
             VI5             =SIMP(statut='f',typ='R' ),
             VI6             =SIMP(statut='f',typ='R' ),
             VO2             =SIMP(statut='f',typ='R' ),
             VO3             =SIMP(statut='f',typ='R' ),
             VO4             =SIMP(statut='f',typ='R' ),
             VO5             =SIMP(statut='f',typ='R' ),
             VO6             =SIMP(statut='f',typ='R' ),
             WI2             =SIMP(statut='f',typ='R' ),
             WI3             =SIMP(statut='f',typ='R' ),
             WI4             =SIMP(statut='f',typ='R' ),
             WI5             =SIMP(statut='f',typ='R' ),
             WI6             =SIMP(statut='f',typ='R' ),
             WO2             =SIMP(statut='f',typ='R' ),
             WO3             =SIMP(statut='f',typ='R' ),
             WO4             =SIMP(statut='f',typ='R' ),
             WO5             =SIMP(statut='f',typ='R' ),
             WO6             =SIMP(statut='f',typ='R' ),
             WO              =SIMP(statut='f',typ='R' ),
             WI1             =SIMP(statut='f',typ='R' ),
             WO1             =SIMP(statut='f',typ='R' ),
             GONF            =SIMP(statut='f',typ='R' ),
             H1X             =SIMP(statut='f',typ='R' ),
             H1Y             =SIMP(statut='f',typ='R' ),
             H1Z             =SIMP(statut='f',typ='R' ),
             H1PRE1          =SIMP(statut='f',typ='R' ),
             K1              =SIMP(statut='f',typ='R' ),
             K2              =SIMP(statut='f',typ='R' ),
             K3              =SIMP(statut='f',typ='R' ),
             V11             =SIMP(statut='f',typ='R' ),
             V12             =SIMP(statut='f',typ='R' ),
             V13             =SIMP(statut='f',typ='R' ),
             V21             =SIMP(statut='f',typ='R' ),
             V22             =SIMP(statut='f',typ='R' ),
             V23             =SIMP(statut='f',typ='R' ),
             V31             =SIMP(statut='f',typ='R' ),
             V32             =SIMP(statut='f',typ='R' ),
             V33             =SIMP(statut='f',typ='R' ),
             PRES11          =SIMP(statut='f',typ='R' ),
             PRES12          =SIMP(statut='f',typ='R' ),
             PRES13          =SIMP(statut='f',typ='R' ),
             PRES21          =SIMP(statut='f',typ='R' ),
             PRES22          =SIMP(statut='f',typ='R' ),
             PRES23          =SIMP(statut='f',typ='R' ),
             PRES31          =SIMP(statut='f',typ='R' ),
             PRES32          =SIMP(statut='f',typ='R' ),
             PRES33          =SIMP(statut='f',typ='R' ),
             LH1             =SIMP(statut='f',typ='R' ),
             GLIS            =SIMP(statut='f',typ='R' ),
         ),

         THER_IMPO       =FACT(statut='f',max='**',
           regles=(UN_PARMI('TOUT','GROUP_MA','MAILLE','GROUP_NO','NOEUD'),
                   AU_MOINS_UN('TEMP','TEMP_MIL','TEMP_INF','TEMP_SUP'),),
           TOUT            =SIMP(statut='f',typ='TXM',into=("OUI",) ),
           GROUP_MA        =SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
           MAILLE          =SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
           GROUP_NO        =SIMP(statut='f',typ=grno,validators=NoRepeat(),max='**'),
           NOEUD           =SIMP(statut='f',typ=no  ,validators=NoRepeat(),max='**'),
           TEMP            =SIMP(statut='f',typ='R' ),
           TEMP_MIL        =SIMP(statut='f',typ='R' ),
           TEMP_SUP        =SIMP(statut='f',typ='R' ),
           TEMP_INF        =SIMP(statut='f',typ='R' ),
         ),

         ACOU_IMPO       =FACT(statut='f',max='**',
           regles=(UN_PARMI('TOUT','GROUP_MA','MAILLE','GROUP_NO','NOEUD'),),
           TOUT            =SIMP(statut='f',typ='TXM',into=("OUI",) ),
           GROUP_MA        =SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
           MAILLE          =SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
           GROUP_NO        =SIMP(statut='f',typ=grno,validators=NoRepeat(),max='**'),
           NOEUD           =SIMP(statut='f',typ=no  ,validators=NoRepeat(),max='**'),
           PRES            =SIMP(statut='o',typ='C' ),
         ),

         EVOL_IMPO  =SIMP(statut='f',typ=(evol_noli,evol_elas,evol_ther),fr=tr("Pour imposer les ddls d'un evol_xxx")),
         b_evol_impo = BLOC ( condition = """exists("EVOL_IMPO")""",
           NOM_CMP         =SIMP(statut='f',typ='TXM',max='**',), # pour n'imposer que certaines CMPS (par défaut : toutes)
         ),

         INFO            =SIMP(statut='f',typ='I',defaut= 1,into=( 1 , 2) ),
)  ;
