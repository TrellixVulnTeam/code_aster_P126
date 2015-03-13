# coding=utf-8

from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *

# ======================================================================
# COPYRIGHT (C) 1991 - 2013  EDF R&D                  WWW.CODE-ASTER.ORG
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


def propa_fiss_prod(self,**args):
  if  args.has_key('MAIL_TOTAL')  :
      MAIL_TOTAL = args['MAIL_TOTAL']
      self.type_sdprod(MAIL_TOTAL,maillage_sdaster)
  if  args.has_key('MAIL_FISS')  :
      MAIL_FISS = args['MAIL_FISS']
      self.type_sdprod(MAIL_FISS,maillage_sdaster)
  if args.has_key('FISSURE') :
      FISSURE = args['FISSURE']
      for numfis in FISSURE :
        if (args['METHODE_PROPA']=='MAILLAGE') :
          self.type_sdprod(numfis['MAIL_PROPAGE'],maillage_sdaster)
        else :
          self.type_sdprod(numfis['FISS_PROPAGEE'],fiss_xfem)
  return None

PROPA_FISS=MACRO(nom="PROPA_FISS",
                 op=OPS('Macro.propa_fiss_ops.propa_fiss_ops'),
                 sd_prod=propa_fiss_prod,
                 fr=tr("Propagation de fissure avec X-FEM"),reentrant='n',
                 UIinfo={"groupes":("Post-traitements","Rupture",)},

        METHODE_PROPA = SIMP(statut='o',typ='TXM',
                               into=("SIMPLEXE","UPWIND","MAILLAGE","INITIALISATION","GEOMETRIQUE","UPW_FMM") ),

        OPERATION = SIMP(statut='f',typ='TXM', into=("RIEN","DETECT_COHESIF","PROPA_COHESIF"), defaut="RIEN" ),

        b_hamilton = BLOC(condition="(METHODE_PROPA=='SIMPLEXE') or (METHODE_PROPA=='UPWIND') or (METHODE_PROPA=='UPW_FMM') or (METHODE_PROPA=='GEOMETRIQUE' and OPERATION=='RIEN') ",
              MODELE        = SIMP(statut='o',typ=modele_sdaster),
              TEST_MAIL     = SIMP(statut='f',typ='TXM',into=("NON","OUI",),defaut="NON"),
              DA_MAX        = SIMP(statut='o',typ='R',max=1,val_min=0.0),
              RAYON         = SIMP(statut='o',typ='R',),
              ZONE_MAJ      = SIMP(statut='f',typ='TXM',into=("TOUT","TORE"),defaut="TORE"),
              b_tore        = BLOC(condition = "ZONE_MAJ == 'TORE' ",
                                   RAYON_TORE    = SIMP(statut='f',typ='R',max=1,val_min=0.0),
                                  ),
              b_propagation = BLOC(condition = "TEST_MAIL == 'NON' ",
                                   FISSURE   = FACT(statut='o',min=1,max='**',
                                                    FISS_ACTUELLE  = SIMP(statut='o',typ=fiss_xfem,max=1),
                                                    FISS_PROPAGEE  = SIMP(statut='o',typ=CO,max=1),
                                                    NB_POINT_FOND  = SIMP(statut='f',typ='I',max='**',val_min=2),
                                                    TABLE          = SIMP(statut='o',typ=table_sdaster,max=1),
                                                    ),
                                   LOI_PROPA = FACT(statut='o',max=1,
                                                    LOI     = SIMP(statut='o',typ='TXM',into=("PARIS",),defaut="PARIS"),
                                                    b_paris = BLOC(condition = "LOI=='PARIS'",
                                                                   C = SIMP(statut='o',typ='R',),
                                                                   M = SIMP(statut='o',typ='R',),
                                                                  ),
                                                    MATER = SIMP(statut='o',typ=mater_sdaster,),
                                                   ),
                                   COMP_LINE = FACT(statut='o',max=1,
                                                    COEF_MULT_MINI = SIMP(statut='o',typ='R',),
                                                    COEF_MULT_MAXI = SIMP(statut='o',typ='R',),
                                                   ),
                                   CRIT_ANGL_BIFURCATION = SIMP(statut='f',typ='TXM',max=1,defaut="SITT_MAX",
                                                              into=('SITT_MAX_DEVER','SITT_MAX','K1_MAX','K2_NUL','PLAN','ANGLE_IMPO','ANGLE_IMPO_GAMMA','ANGLE_IMPO_BETA_GAMMA'),),
                                  ),                                                 

              b_test_const  = BLOC(condition = "TEST_MAIL == 'OUI' ",
                                   FISSURE   = FACT(statut='o',min=1,max='**',
                                                    FISS_ACTUELLE  = SIMP(statut='o',typ=fiss_xfem,max=1),
                                                    FISS_PROPAGEE  = SIMP(statut='o',typ=CO,max=1),
                                                    ),
                                   ITERATIONS     = SIMP(statut='f',typ='I',max=1,val_min=3,defaut=5),
                                   TOLERANCE      = SIMP(statut='f',typ='R',max=1,val_min=0.0,val_max=100.0,defaut=5.0),
                                  ),

                         ),
        b_detection = BLOC(condition="(OPERATION == 'DETECT_COHESIF')",
              MODELE        = SIMP(statut='o',typ=modele_sdaster),
              TEST_MAIL     = SIMP(statut='f',typ='TXM',into=("NON","OUI",),defaut="NON"),
              RESULTAT      =  SIMP(statut='o',typ=(evol_elas,evol_noli),),
              ZONE_MAJ      = SIMP(statut='f',typ='TXM',into=("TOUT","TORE"),defaut="TORE"),
              b_tore        = BLOC(condition = "ZONE_MAJ == 'TORE' ",
                                   RAYON_TORE    = SIMP(statut='f',typ='R',max=1,val_min=0.0),
                                  ),
              b_propagation = BLOC(condition = "TEST_MAIL == 'NON' ",
                                   FISSURE   = FACT(statut='o',min=1,max='**',
                                                    FISS_ACTUELLE  = SIMP(statut='o',typ=fiss_xfem,max=1),
                                                    FISS_PROPAGEE  = SIMP(statut='o',typ=CO,max=1),
                                                    NB_POINT_FOND  = SIMP(statut='f',typ='I',max='**'),
                                                    TABLE   = SIMP(statut='o',typ=table_sdaster,max=1),
                                                    ),
                                   CRIT_ANGL_BIFURCATION = SIMP(statut='f',typ='TXM',max=1,defaut="SITT_MAX",
                                                              into=('SITT_MAX_DEVER','SITT_MAX','K1_MAX','K2_NUL','PLAN','ANGLE_IMPO','ANGLE_IMPO_GAMMA','ANGLE_IMPO_BETA_GAMMA'),),                 
                                  ),
                          ),
        b_cohesive = BLOC(condition="(OPERATION == 'PROPA_COHESIF')",
              MODELE        = SIMP(statut='o',typ=modele_sdaster),
              DA_MAX        = SIMP(statut='o',typ='R',max=1),
              TEST_MAIL     = SIMP(statut='f',typ='TXM',into=("NON","OUI",),defaut="NON"),
              ZONE_MAJ      = SIMP(statut='f',typ='TXM',into=("TOUT","TORE"),defaut="TORE"),
              b_tore        = BLOC(condition = "ZONE_MAJ == 'TORE' ",
                                   RAYON_TORE    = SIMP(statut='f',typ='R',max=1,val_min=0.0),
                                  ),
              b_propagation = BLOC(condition = "TEST_MAIL == 'NON' ",
                                   FISSURE   = FACT(statut='o',min=1,max='**',
                                                    FISS_ACTUELLE  = SIMP(statut='o',typ=fiss_xfem,max=1),
                                                    FISS_PROPAGEE  = SIMP(statut='o',typ=CO,max=1),
                                                    NB_POINT_FOND  = SIMP(statut='f',typ='I',max='**'),
                                                    TABLE   = SIMP(statut='o',typ=table_sdaster,max=1),
                                                    ),
                                   CRIT_ANGL_BIFURCATION = SIMP(statut='f',typ='TXM',max=1,defaut="SITT_MAX",
                                           into=('SITT_MAX','K1_MAX','K2_NUL','PLAN','ANGLE_IMPO'),),                                  
                                  ),
                          ),
        b_maillage    =BLOC(condition="(METHODE_PROPA=='MAILLAGE')",
               MAIL_STRUC       = SIMP(statut='o',typ=maillage_sdaster),
               ITERATION      = SIMP(statut='o',typ='I',max=1),
               DA_MAX        = SIMP(statut='o',typ='R',max=1),
               FISSURE   = FACT(statut='o',min=1,max='**',
                                MAIL_ACTUEL    = SIMP(statut='o',typ=maillage_sdaster,max=1),
                                GROUP_MA_FOND    = SIMP(statut='f',typ=grma,defaut="FOND"),
                                GROUP_MA_FISS    = SIMP(statut='f',typ=grma,defaut="FISS"),
                                FISS_ACTUELLE  = SIMP(statut='o',typ=fiss_xfem,max=1),
                                MAIL_PROPAGE  = SIMP(statut='f',typ=CO,max=1),
                                TABLE          = SIMP(statut='o',typ=table_sdaster,max=1),
                                                    ),
               MAIL_TOTAL        = SIMP(statut='o',typ=CO),
               LOI_PROPA = FACT(statut='o',max=1,
                                LOI     = SIMP(statut='o',typ='TXM',into=("PARIS",),defaut="PARIS"),
                                b_paris = BLOC(condition = "LOI=='PARIS'",
                                               C = SIMP(statut='o',typ='R',),
                                               M = SIMP(statut='o',typ='R',),
                                              ),
                                MATER = SIMP(statut='o',typ=mater_sdaster,),
                                                   ),
               COMP_LINE = FACT(statut='o',max=1,
                                COEF_MULT_MINI = SIMP(statut='o',typ='R',),
                                COEF_MULT_MAXI = SIMP(statut='o',typ='R',),
                                                   ),
               CRIT_ANGL_BIFURCATION = SIMP(statut='f',typ='TXM',max=1,defaut="SITT_MAX",
                                                into=('SITT_MAX','SITT_MAX_DEVER','K1_MAX','K2_NUL','PLAN','ANGLE_IMPO'),),
                                ),

        b_init    =BLOC(condition="(METHODE_PROPA=='INITIALISATION')",
               MAIL_STRUC    = SIMP(statut='o',typ=maillage_sdaster),
               FORM_FISS   = SIMP(statut='o',typ='TXM', into=("DEMI_DROITE","DEMI_PLAN","ELLIPSE"), ),
               GROUP_MA_FOND    = SIMP(statut='f',typ=grma,defaut="FOND"),
               GROUP_MA_FISS    = SIMP(statut='f',typ=grma,defaut="FISS"),
               MAIL_TOTAL     = SIMP(statut='o',typ=CO),
               MAIL_FISS       = SIMP(statut='f',typ=CO),

               b_droite = BLOC(condition = "FORM_FISS == 'DEMI_DROITE' ",
                  PFON        = SIMP(statut='o',typ='R',max=3),
                  DTAN        = SIMP(statut='o',typ='R',min=3,max=3),
               ),

               b_plan = BLOC(condition = "FORM_FISS == 'DEMI_PLAN' ",
                  DTAN        = SIMP(statut='o',typ='R',min=3,max=3),
                  POINT_ORIG        = SIMP(statut='o',typ='R',min=3,max=3),
                  POINT_EXTR        = SIMP(statut='o',typ='R',min=3,max=3),
                  NB_POINT_FOND     = SIMP(statut='o',typ='I',),
               ),

               b_ellipse = BLOC(condition = "FORM_FISS == 'ELLIPSE' ",
                  CENTRE         =SIMP(statut='o',typ='R',min=3,max=3),
                  DEMI_GRAND_AXE =SIMP(statut='o',typ='R',val_min=0.E+0),
                  DEMI_PETIT_AXE =SIMP(statut='o',typ='R',val_min=0.E+0),
                  VECT_X         =SIMP(statut='o',typ='R',min=3,max=3),
                  VECT_Y         =SIMP(statut='o',typ='R',min=3,max=3),
                  ANGLE_ORIG        = SIMP(statut='o',typ='R',),
                  ANGLE_EXTR        = SIMP(statut='o',typ='R',),
                  NB_POINT_FOND     = SIMP(statut='o',typ='I',)
               ),
             ),

        INFO = SIMP(statut='f',typ='I',defaut=1,into=(0,1,2)),
)
