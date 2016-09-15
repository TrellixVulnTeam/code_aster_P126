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
# person_in_charge: samuel.geniaut at edf.fr

DEFI_FISS_XFEM=OPER(nom="DEFI_FISS_XFEM",op=  41,sd_prod=fiss_xfem,reentrant='n',
            UIinfo={"groupes":("Modélisation",)},
               fr=tr("Définition des caratéristiques d'une fissure ou d'une interface avec X-FEM"),
            regles = EXCLUS('MAILLAGE_GRILLE','FISS_GRILLE'),
# ------------------------------------------------------------------------------------------------------------------------
#                       fissure/interface/cohesif
# ------------------------------------------------------------------------------------------------------------------------

    TYPE_DISCONTINUITE  =SIMP(statut='f',typ='TXM',into=("FISSURE","INTERFACE","COHESIF",) ,defaut="FISSURE",position='global'),
# ------------------------------------------------------------------------------------------------------------------------
#                       maillage sous-jacent
# ------------------------------------------------------------------------------------------------------------------------

    MAILLAGE              =SIMP(statut='o',typ=maillage_sdaster),

# ------------------------------------------------------------------------------------------------------------------------
#                       grille auxiliaire : pas ouvert avec le cohesif
# ------------------------------------------------------------------------------------------------------------------------

    MAILLAGE_GRILLE       =SIMP(statut='f',typ=maillage_sdaster,max=1,position='global'),
    FISS_GRILLE           =SIMP(statut='f',typ=fiss_xfem,max=1),

# ------------------------------------------------------------------------------------------------------------------------
#                       caracteristiques de la fissure/interface
# ------------------------------------------------------------------------------------------------------------------------

    DEFI_FISS             =FACT(statut='o',max=1,

#      regles              =UN_PARMI('GROUP_MA_FISS','FONC_LN','FORM_FISS','CHAM_NO_LSN'),

      FONC_LT             =SIMP(statut='f',typ=(fonction_sdaster,formule) ),
      FONC_LN             =SIMP(statut='f',typ=(fonction_sdaster,formule) ),
#     Front initial ptopagation cohesive
      b_cohesif           =BLOC(condition = "TYPE_DISCONTINUITE == 'COHESIF'",
         GROUP_MA_BORD     =SIMP(statut='o',typ=grma,max=1),
      ),
#
      b_sans_cohesif      = BLOC(condition = "TYPE_DISCONTINUITE != 'COHESIF'",fr="Options pas ouvertes avec le cohesif",
         CHAM_NO_LSN         =SIMP(statut='f',typ=cham_no_sdaster,min=1,max=1),
         CHAM_NO_LST         =SIMP(statut='f',typ=cham_no_sdaster,min=1,max=1),
         GROUP_MA_FISS       =SIMP(statut='f',typ=grma,min=1,max=1),
         GROUP_MA_FOND       =SIMP(statut='f',typ=grma,min=1,max=1),
      ),
      FORM_FISS   =SIMP(statut='f',typ='TXM',into=("ELLIPSE","RECTANGLE","CYLINDRE","DEMI_PLAN",
                                                   "SEGMENT","DEMI_DROITE","DROITE","ENTAILLE") ),
      b_ellipse           =BLOC(condition = "FORM_FISS == 'ELLIPSE' ",fr=tr("Paramètres de la fissure/interface elliptique"),
           DEMI_GRAND_AXE =SIMP(statut='o',typ='R',val_min=0.),
           DEMI_PETIT_AXE =SIMP(statut='o',typ='R',val_min=0.),
           CENTRE         =SIMP(statut='o',typ='R',min=3,max=3),
           VECT_X         =SIMP(statut='o',typ='R',min=3,max=3),
           VECT_Y         =SIMP(statut='o',typ='R',min=3,max=3),
           COTE_FISS      =SIMP(statut='f',typ='TXM',defaut="IN",into=("IN","OUT",) ),    ),
      b_rectangle         =BLOC(condition = "FORM_FISS == 'RECTANGLE' ",fr=tr("Paramètres de la fissure/interface rectangulaire"),
           DEMI_GRAND_AXE =SIMP(statut='o',typ='R',val_min=0.),
           DEMI_PETIT_AXE =SIMP(statut='o',typ='R',val_min=0.),
           RAYON_CONGE    =SIMP(statut='f',typ='R',val_min=0.,defaut=0.),
           CENTRE         =SIMP(statut='o',typ='R',min=3,max=3),
           VECT_X         =SIMP(statut='o',typ='R',min=3,max=3),
           VECT_Y         =SIMP(statut='o',typ='R',min=3,max=3),
           COTE_FISS      =SIMP(statut='f',typ='TXM',defaut="IN",into=("IN","OUT",) ),    ),
      b_entaille          =BLOC(condition = "FORM_FISS == 'ENTAILLE' ",fr=tr("Paramètres de l'interface entaille"),
           DEMI_LONGUEUR  =SIMP(statut='o',typ='R',val_min=0.),
           RAYON_CONGE    =SIMP(statut='o',typ='R',val_min=0.),
           CENTRE         =SIMP(statut='o',typ='R',min=3,max=3),
           VECT_X         =SIMP(statut='o',typ='R',min=3,max=3),  
           VECT_Y         =SIMP(statut='o',typ='R',min=3,max=3),  ),
      b_cylindre          =BLOC(condition = "FORM_FISS == 'CYLINDRE' ",fr=tr("Paramètres de la fissure cylindrique"),
           DEMI_GRAND_AXE =SIMP(statut='o',typ='R',val_min=0.),
           DEMI_PETIT_AXE =SIMP(statut='o',typ='R',val_min=0.),
           CENTRE         =SIMP(statut='o',typ='R',min=3,max=3),
           VECT_X         =SIMP(statut='o',typ='R',min=3,max=3),
           VECT_Y         =SIMP(statut='o',typ='R',min=3,max=3),),
      b_demiplan          =BLOC(condition = "FORM_FISS == 'DEMI_PLAN' ",fr=tr("Paramètres de la fissure plane à front droit"),
           PFON           =SIMP(statut='o',typ='R',min=3,max=3),
           NORMALE        =SIMP(statut='o',typ='R',min=3,max=3),
           DTAN           =SIMP(statut='o',typ='R',min=3,max=3),),
      b_segment           =BLOC(condition = "FORM_FISS == 'SEGMENT' ",fr=tr("Paramètres de la fissure 2D segment"),
           PFON_ORIG      =SIMP(statut='o',typ='R',min=3,max=3),
           PFON_EXTR      =SIMP(statut='o',typ='R',min=3,max=3),),
      b_demidroite         =BLOC(condition = "FORM_FISS == 'DEMI_DROITE' ",fr=tr("Paramètres de la fissure 2D demi-droite"),
           PFON           =SIMP(statut='o',typ='R',min=3,max=3),
           DTAN           =SIMP(statut='o',typ='R',min=3,max=3),),
      b_droite            =BLOC(condition = "FORM_FISS == 'DROITE' ",fr=tr("Paramètres de l'interface 2D (fissure traversante)"),
           POINT          =SIMP(statut='o',typ='R',min=3,max=3),
           DTAN           =SIMP(statut='o',typ='R',min=3,max=3),),
                            ),

# ------------------------------------------------------------------------------------------------------------------------
#                       partie du maillage potentiellement enrichie
# ------------------------------------------------------------------------------------------------------------------------

    GROUP_MA_ENRI         =SIMP(statut='f',typ=grma,max=01),

# ------------------------------------------------------------------------------------------------------------------------
#                       types d'enrichissement 
# ------------------------------------------------------------------------------------------------------------------------

    b_enri_inte           =BLOC(condition = "TYPE_DISCONTINUITE == 'INTERFACE' ",

      CHAM_DISCONTINUITE  =SIMP(statut='f',typ='TXM',into=("DEPL","SIGM"),defaut="DEPL" ),

                          ),


    b_enri_fiss           =BLOC(condition = "TYPE_DISCONTINUITE == 'FISSURE' ",

      CHAM_DISCONTINUITE  =SIMP(statut='f',typ='TXM',into=("DEPL",),defaut="DEPL" ),
      TYPE_ENRI_FOND      =SIMP(statut='f',typ='TXM',into=("TOPOLOGIQUE","GEOMETRIQUE"),defaut="GEOMETRIQUE" ),

        b_enri_geom       =BLOC(condition = "TYPE_ENRI_FOND == 'GEOMETRIQUE' ",fr=tr("Paramètres de l enrichissement geometrique"),
           RAYON_ENRI     =SIMP(statut='f',typ='R',val_min=0.E+0),

          b_enri_couches  =BLOC(condition = "(RAYON_ENRI == None) ",fr=tr("Paramètres de l enrichissement à n couches"),
           NB_COUCHES     =SIMP(statut='f',typ='I',defaut=2,val_min=1),

                               ),
                             ),                        
                          ),

# ------------------------------------------------------------------------------------------------------------------------
#                       branchement
# ------------------------------------------------------------------------------------------------------------------------

    b_jonction            =BLOC(condition = "(MAILLAGE_GRILLE == None) and (FISS_GRILLE == None)",
        JONCTION              =FACT(statut='f',max=1,
          FISSURE             =SIMP(statut='o',typ=fiss_xfem,min=1,max='**',),
          POINT               =SIMP(statut='o',typ='R',max=3,),
                                   ),
                               ),
# ------------------------------------------------------------------------------------------------------------------------
#                       info
# ------------------------------------------------------------------------------------------------------------------------

    INFO                  =SIMP(statut='f',typ='I',defaut= 1,into=(1,2,3,) ),

)  ;
