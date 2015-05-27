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
# person_in_charge: samuel.geniaut at edf.fr

CALC_THETA=OPER(nom="CALC_THETA",op=54,sd_prod=theta_geom,reentrant='n',
            UIinfo={"groupes":("Post-traitements","Rupture",)},
                fr=tr("Définir un champ theta pour le calcul du taux de restitution d'énergie"
                     " ou des facteurs d'intensité de contraintes"),
         regles=(UN_PARMI('THETA_2D','THETA_3D'),
                 PRESENT_ABSENT('THETA_2D','DIRE_THETA'),
                 EXCLUS('DIRECTION','DIRE_THETA'),),
         MODELE          =SIMP(statut='o',typ=(modele_sdaster) ),
         THETA_3D        =FACT(statut='f',max='**',
           regles=(UN_PARMI('TOUT','GROUP_NO','NOEUD'),
                   UN_PARMI('MODULE','MODULE_FO'),
                   ENSEMBLE('MODULE_FO','R_INF_FO','R_SUP_FO'),),
           TOUT            =SIMP(statut='f',typ='TXM',into=("OUI",) ),
           GROUP_NO        =SIMP(statut='f',typ=grno,validators=NoRepeat(),max='**'),
           NOEUD           =SIMP(statut='f',typ=no  ,validators=NoRepeat(),max='**'),
           MODULE          =SIMP(statut='f',typ='R'),
           R_INF           =SIMP(statut='f',typ='R'),
           R_SUP           =SIMP(statut='f',typ='R'),
           MODULE_FO       =SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule)),
           R_INF_FO        =SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule)),
           R_SUP_FO        =SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule)),
                         ),
         b_theta_3d     =BLOC(condition="THETA_3D != None",
           FOND_FISS       =SIMP(statut='o',typ=fond_fiss),),
         DIRE_THETA      =SIMP(statut='f',typ=cham_no_sdaster ),
         DIRECTION       =SIMP(statut='f',typ='R',max='**'),
         THETA_2D        =FACT(statut='f',max='**',
           regles=(UN_PARMI('GROUP_NO','NOEUD'),),
           GROUP_NO        =SIMP(statut='f',typ=grno,validators=NoRepeat(),max='**'),
           NOEUD           =SIMP(statut='f',typ=no  ,validators=NoRepeat(),max='**'),
           MODULE          =SIMP(statut='o',typ='R'),
           R_INF           =SIMP(statut='o',typ='R'),
           R_SUP           =SIMP(statut='o',typ='R'),
         ),
         IMPRESSION      =FACT(statut='f',
           UNITE           =SIMP(statut='f',typ='I',defaut=8),
           FORMAT          =SIMP(statut='f',typ='TXM',defaut="EXCEL",into=("EXCEL","AGRAF") ),
         ),
)  ;
