# coding=utf-8

from Cata.Descriptor import *

# ======================================================================
# COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
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

def macr_aspic_calc_prod(self,MODELE,CHAM_MATER,CARA_ELEM,FOND_FISS_1,FOND_FISS_2,RESU_THER,**args):
  if MODELE      != None:self.type_sdprod(MODELE,modele_sdaster)
  if CHAM_MATER  != None:self.type_sdprod(CHAM_MATER,cham_mater)
  if CARA_ELEM   != None:self.type_sdprod(CARA_ELEM,cara_elem)
  if FOND_FISS_1 != None:self.type_sdprod(FOND_FISS_1,fond_fiss)
  if FOND_FISS_2 != None:self.type_sdprod(FOND_FISS_2,fond_fiss)
  if RESU_THER   != None:self.type_sdprod(RESU_THER,evol_ther)
  return evol_noli

MACR_ASPIC_CALC=MACRO(nom="MACR_ASPIC_CALC",
                      op=OPS('Macro.macr_aspic_calc_ops.macr_aspic_calc_ops'),
                      sd_prod=macr_aspic_calc_prod,
                      fr=tr("Réalise un calcul prédéfini de piquages sains ou fissurés "
                           "ainsi que les post-traitements associés "),
                      UIinfo={"groupes":("Résolution","Outils-métier",)},
                      reentrant='n',

         TYPE_MAILLAGE   =SIMP(statut='o',typ='TXM',
                               into=("SAIN_FIN","SAIN_GROS","FISS_COUR_DEB","FISS_COUR_NONDEB","FISS_LONG_DEB",
                                     "FISS_LONG_NONDEB","FISS_AXIS_DEB","FISS_AXIS_NONDEB") ),

         TUBULURE        =FACT(statut='o',
           TYPE            =SIMP(statut='o',typ='TXM',into=("TYPE_1","TYPE_2") ),
         ),
         MAILLAGE        =SIMP(statut='o',typ=maillage_sdaster),
         MODELE          =SIMP(statut='f',typ=CO,),
         CHAM_MATER      =SIMP(statut='f',typ=CO,),
         CARA_ELEM       =SIMP(statut='f',typ=CO,),
         FOND_FISS_1     =SIMP(statut='f',typ=CO,),
         FOND_FISS_2     =SIMP(statut='f',typ=CO,),
         RESU_THER       =SIMP(statut='f',typ=CO,),

         AFFE_MATERIAU   =FACT(statut='o',max=3,
           regles=(UN_PARMI('TOUT','GROUP_MA'),),
           TOUT            =SIMP(statut='f',typ='TXM',into=("OUI",)),
           GROUP_MA        =SIMP(statut='f',typ=grma,into=("TUBU","CORP","SOUD","SOUDCORP","SOUDTUBU") ),
           MATER           =SIMP(statut='o',typ=mater_sdaster),
           TEMP_REF        =SIMP(statut='f',typ='R',defaut= 0.E+0 ),
           RCCM            =SIMP(statut='o',typ='TXM',into=("OUI","NON")),
         ),

         EQUILIBRE       =FACT(statut='o',
           NOEUD           =SIMP(statut='o',typ=no),
         ),

         PRES_REP        =FACT(statut='o',
           PRES            =SIMP(statut='o',typ='R'),
           NOEUD           =SIMP(statut='f',typ=no),
           EFFE_FOND       =SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON")),
           PRES_LEVRE      =SIMP(statut='f',typ='TXM',defaut="NON",into=("OUI","NON") ),
           FONC_MULT       =SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule)),
         ),

         ECHANGE         =FACT(statut='f',
           COEF_H_TUBU     =SIMP(statut='o',typ=(fonction_sdaster,nappe_sdaster,formule)),
           COEF_H_CORP     =SIMP(statut='o',typ=(fonction_sdaster,nappe_sdaster,formule)),
           TEMP_EXT        =SIMP(statut='o',typ=(fonction_sdaster,nappe_sdaster,formule)),
         ),

         TORS_CORP       =FACT(statut='f',max=6,
           regles=(AU_MOINS_UN('FX','FY','FZ','MX','MY','MZ'),),
           NOEUD           =SIMP(statut='o',typ=no),
           FX              =SIMP(statut='f',typ='R'),
           FY              =SIMP(statut='f',typ='R'),
           FZ              =SIMP(statut='f',typ='R'),
           MX              =SIMP(statut='f',typ='R'),
           MY              =SIMP(statut='f',typ='R'),
           MZ              =SIMP(statut='f',typ='R'),
           FONC_MULT       =SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule)),
         ),

         TORS_TUBU       =FACT(statut='f',max=6,
           regles=(AU_MOINS_UN('FX','FY','FZ','MX','MY','MZ'),),
           FX              =SIMP(statut='f',typ='R'),
           FY              =SIMP(statut='f',typ='R'),
           FZ              =SIMP(statut='f',typ='R'),
           MX              =SIMP(statut='f',typ='R'),
           MY              =SIMP(statut='f',typ='R'),
           MZ              =SIMP(statut='f',typ='R'),
           FONC_MULT       =SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule)),
         ),

         COMPORTEMENT    =C_COMPORTEMENT('MACR_ASPIC_CALC'),

         THETA_3D        =FACT(statut='f',max='**',
           R_INF           =SIMP(statut='o',typ='R'),
           R_SUP           =SIMP(statut='o',typ='R'),
         ),

         OPTION          =SIMP(statut='f',typ='TXM',into=("CALC_G_MAX","CALC_G_MAX_LOCAL") ),
         BORNES          =FACT(statut='f',max='**',
           NUME_ORDRE      =SIMP(statut='o',typ='I'),
           VALE_MIN        =SIMP(statut='o',typ='R'),
           VALE_MAX        =SIMP(statut='o',typ='R'),
         ),

#-------------------------------------------------------------------
#        Catalogue commun SOLVEUR
         SOLVEUR         =C_SOLVEUR('MACR_ASPIC_CALC'),
#-------------------------------------------------------------------

         CONVERGENCE     =C_CONVERGENCE(),

         NEWTON          =C_NEWTON(),

         RECH_LINEAIRE   =C_RECH_LINEAIRE(),

         INCREMENT       =C_INCREMENT('MECANIQUE'),

         PAS_AZIMUT      =SIMP(statut='f',typ='I',defaut=1),

         ENERGIE         =FACT(statut='f',max=1,
           CALCUL          =SIMP(statut='f',typ='TXM',into=("OUI",),defaut="OUI",),
         ),

         IMPRESSION      =FACT(statut='f',
           FORMAT          =SIMP(statut='f',typ='TXM',defaut="RESULTAT",
                                 into=("RESULTAT","ASTER","CASTEM","IDEAS")),

           b_format_ideas  =BLOC(condition="FORMAT=='IDEAS'",fr=tr("version Ideas"),
             VERSION         =SIMP(statut='f',typ='I',defaut=5,into=(4,5)),
           ),

           b_format_castem =BLOC(condition="FORMAT=='CASTEM'",fr=tr("version Castem"),
             NIVE_GIBI       =SIMP(statut='f',typ='I',defaut=10,into=(3,10)),
           ),

           b_extrac        =BLOC(condition="((FORMAT=='IDEAS')or(FORMAT=='CASTEM'))",
                                 fr=tr("extraction d un champ de grandeur"),
             regles=(EXCLUS('TOUT_ORDRE','NUME_ORDRE','INST'),),
             NOM_CHAM        =SIMP(statut='f',typ='TXM',validators=NoRepeat(),max=3,into=("DEPL","SIEQ_ELNO","TEMP")),

             TOUT_ORDRE      =SIMP(statut='f',typ='TXM',into=("OUI",) ),
             NUME_ORDRE      =SIMP(statut='f',typ='I',validators=NoRepeat(),max='**'),
             INST            =SIMP(statut='f',typ='R',validators=NoRepeat(),max='**'),
           ),
         ),

         INFO            =SIMP(statut='f',typ='I',defaut=1,into=(1,2)),

         TITRE           =SIMP(statut='f',typ='TXM'),
)
