# coding=utf-8

from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *

# ======================================================================
# COPYRIGHT (C) 1991 - 2016  EDF R&D                  WWW.CODE-ASTER.ORG
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
DEFI_SOL_EQUI = MACRO(nom="DEFI_SOL_EQUI",
                      op=OPS('Macro.defi_sol_equi_ops.defi_sol_equi_ops'),
                      sd_prod=table_sdaster,
                      fr=tr("Définition des données de sol pour Miss"),
                      reentrant='n',
                      UIinfo={"groupes":("Modélisation","Outils-métier",)},
   FONC_SIGNAL   =SIMP(statut='o',typ=(fonction_sdaster), 
                       fr=tr("Signal impose d'accelero horizontal") ),
   SURF          =SIMP(statut='f',typ='TXM',into=("OUI","NON",),defaut="NON"),
   LIEU_SIGNAL   =SIMP(statut='f',typ='TXM',into=("AFFLEURANT","CHAMP_LIBRE",),
                       defaut="AFFLEURANT",fr=tr("lieu d'imposition du signal")
                       ),
   CORR_AMOR  =SIMP(statut='f',typ='TXM',into=("OUI","NON",),
                       defaut="NON",fr=tr("formulation d'amortissement")
                       ),
   LIST_FREQ     =SIMP(statut='f',typ=listr8_sdaster,
                       fr=tr("liste de frequences de spectre d oscillateur")),
   MAILLAGE      =SIMP(statut='o', typ=maillage_sdaster),     
   GROUP_MA_DROITE =SIMP(statut='o',typ=grma,),
   GROUP_MA_GAUCHE =SIMP(statut='o',typ=grma,),
   GROUP_MA_SUBSTR =SIMP(statut='o',typ=grma,),
   GROUP_MA_COL    =SIMP(statut='o',typ=grma,),
   COEF_VARI_MATE  =SIMP(statut='f',typ='R',defaut=1.0,
                         fr=tr("facteur de variation des modules") ),
   COEF_AMPL_ACCE  =SIMP(statut='f',typ='R',defaut=1.0,
                         fr=tr("facteur sur l'amplitude d'accelero") ),
   COEF_GAMMA      =SIMP(statut='f',typ='R',defaut=0.65,
                         fr=tr("facteur Gamma_max par couche") ),
   NMAX_ITER       =SIMP(statut='f',typ='I',defaut=10,
                         fr=tr("nombre d'iterations maximum") ),
   RESI_RELA       =SIMP(statut='f',typ='R',defaut=0.05,
                         fr=tr("tolerance d'arret des iterations") ),
   FREQ_COUP     =SIMP(statut='f',typ='R',
                       fr=tr("frequence de coupure de filtrage du signal")),
   # Si precise et SURF='NON' nombre de couches enfoncees
   NIVE_COUCH_ENFO   =SIMP(statut='f', typ='I',),
   # Si SURF='NON' nombre de recepteurs decoupant les couches enfoncees
   NB_RECEPTEUR  =SIMP(statut='f', typ='I',into=(2,4,),defaut=2),
   # Unites de sortie
   UNITE_TABLE_RESU =SIMP(statut='f', typ='I', inout='out',),
   UNITE_RESU_TRAN =SIMP(statut='f', typ='I', defaut=40, inout='out',),
   UNITE_RESU_SPEC =SIMP(statut='f', typ='I', defaut=55, inout='out',),
   regles=(ENSEMBLE('TABLE_MATER_ELAS','TABLE_GEQUI_GMAX','TABLE_AMOR_EQUI') ,),
   TABLE_MATER_ELAS =SIMP(statut='f', typ=table_sdaster,),
   TABLE_GEQUI_GMAX =SIMP(statut='f', typ=table_sdaster,),
   TABLE_AMOR_EQUI =SIMP(statut='f', typ=table_sdaster,),
   b_ntabl_mater = BLOC(condition="TABLE_MATER_ELAS is None",
    MATERIAU = FACT(statut='f', max='**',
            fr=tr("Définition des matériaux"),
      GAMMA = SIMP(statut='o',typ='R',max='**',fr=tr("Abscisses de distorsion")),
      G_GMAX= SIMP(statut='o',typ='R',max='**',
                   fr=tr("Valeurs de reduction de module G")),
      D     = SIMP(statut='o',typ='R',max='**',
                   fr=tr("Valeurs de coefficient d'amortissement")),
    ),
    COUCHE = FACT(statut='f', max='**',
                 fr=tr("Définition des couches"),
      EPAIS     = SIMP(statut='o', typ='R', fr=tr("Epaisseur de la couche")),
      GROUP_MA  = SIMP(statut='o',typ=grma,),
      E         = SIMP(statut='o', typ='R', fr=tr("Module d'Young")),
      NU        = SIMP(statut='o', typ='R', fr=tr("Coefficient de Poisson")),
      RHO       = SIMP(statut='o', typ='R', fr=tr("Masse volumique")),
      AMOR_HYST = SIMP(statut='o', typ='R', fr=tr("Coefficient d'amortissement")),
      NUME_MATE = SIMP(statut='o', typ='I', fr=tr("Numéro du matériau")),
    ),
   ),
   TITRE = SIMP(statut='f', typ='TXM', max='**',
                fr=tr("Titre de la table produite")),
   INFO  = SIMP(statut='f', typ='I', defaut=1, into=(1,2)),
)
