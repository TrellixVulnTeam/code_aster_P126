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
# person_in_charge: andre.adobes at edf.fr
DEFI_FLUI_STRU=OPER(nom="DEFI_FLUI_STRU",op= 143,sd_prod=type_flui_stru,
                    reentrant='n',fr=tr("Définit les caractéristiques nécessaires à l'étude dynamique d'une structure sous écoulement"),
            UIinfo={"groupes":("Modélisation",)},
         regles=(  UN_PARMI('FAISCEAU_TRANS','GRAPPE','FAISCEAU_AXIAL','COQUE_COAX',),),
         FAISCEAU_TRANS  =FACT(statut='f',max='**',
           regles=(  ENSEMBLE('CSTE_CONNORS','NB_CONNORS','RHO_TUBE'),),
           COUPLAGE        =SIMP(statut='f',typ='TXM',into=("OUI","NON") ),
           CARA_ELEM       =SIMP(statut='f',typ=cara_elem ),
           PROF_VITE_FLUI  =SIMP(statut='o',typ=(fonction_sdaster,nappe_sdaster,formule) ),
           PROF_RHO_F_INT  =SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule) ),
           PROF_RHO_F_EXT  =SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule) ),
           NOM_CMP         =SIMP(statut='f',typ='TXM',into=("DX","DY","DZ") ),
           COEF_MASS_AJOU  =SIMP(statut='f',typ='R' ),
           TYPE_PAS        =SIMP(statut='f',typ='TXM',into=("CARRE_LIGN","TRIA_LIGN") ),
           TYPE_RESEAU     =SIMP(statut='f',typ='I' ),
           UNITE_CD        =SIMP(statut='f',typ='I',defaut=70),
           UNITE_CK        =SIMP(statut='f',typ='I',defaut=71),
           PAS             =SIMP(statut='f',typ='R' ),
           CSTE_CONNORS    =SIMP(statut='f',typ='R',min=2,max=2,val_min=0.E+00),
           NB_CONNORS      =SIMP(statut='f',typ='I',val_min=2,),
           RHO_TUBE        =SIMP(statut='f',typ='R' ),
         ),
         GRAPPE          =FACT(statut='f',
           regles=(ENSEMBLE('GRAPPE_2','CARA_ELEM','MODELE','RHO_FLUI',),
                   EXCLUS('NOEUD','GROUP_NO',),
                   PRESENT_PRESENT('COEF_MASS_AJOU','GRAPPE_2', ),),
#  peut on créer un bloc a partir de la valeur de couplage
           COUPLAGE        =SIMP(statut='o',typ='TXM',into=("OUI","NON") ),
           GRAPPE_2        =SIMP(statut='f',typ='TXM',
                                 into=("ASC_CEN","ASC_EXC","DES_CEN","DES_EXC") ),
           NOEUD           =SIMP(statut='f',typ=no),
           GROUP_NO        =SIMP(statut='f',typ=grno),
           CARA_ELEM       =SIMP(statut='f',typ=cara_elem ),
           MODELE          =SIMP(statut='f',typ=modele_sdaster ),
           COEF_MASS_AJOU  =SIMP(statut='f',typ='R' ),
           RHO_FLUI        =SIMP(statut='f',typ='R' ),
           UNITE_CA        =SIMP(statut='f',typ='I',defaut=70),
           UNITE_KA        =SIMP(statut='f',typ='I',defaut=71),
         ),
         FAISCEAU_AXIAL  =FACT(statut='f',max='**',
           regles=(UN_PARMI('GROUP_MA','TRI_GROUP_MA'),
                   UN_PARMI('CARA_ELEM','RAYON_TUBE'),
                   ENSEMBLE('RAYON_TUBE','COOR_TUBE'),
                   PRESENT_ABSENT('RAYON_TUBE','TRI_GROUP_MA'),
                   ENSEMBLE('CARA_PAROI','VALE_PAROI'),
                   ENSEMBLE('LONG_TYPG','LARG_TYPG','EPAI_TYPG','RUGO_TYPG','COEF_TRAI_TYPG','COEF_DPOR_TYPG',
                            'COOR_GRILLE','TYPE_GRILLE', ),),
#  on doit pouvoir mettre des blocs conditionnels mais pas assez d infos pour le faire
           GROUP_MA        =SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
           TRI_GROUP_MA    =SIMP(statut='f',typ='TXM' ),
           VECT_X          =SIMP(statut='f',typ='R',max=3),
           PROF_RHO_FLUI   =SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule) ),
           PROF_VISC_CINE  =SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule) ),
           CARA_ELEM       =SIMP(statut='f',typ=cara_elem ),
           RAYON_TUBE      =SIMP(statut='f',typ='R' ),
           COOR_TUBE       =SIMP(statut='f',typ='R',max='**'),
           PESANTEUR       =SIMP(statut='f',typ='R',min=4,max=4),
           RUGO_TUBE       =SIMP(statut='f',typ='R' ),
           CARA_PAROI      =SIMP(statut='f',typ='TXM',validators=NoRepeat(),max=5,
                                 into=("YC","ZC","R","HY","HZ") ),
           VALE_PAROI      =SIMP(statut='f',typ='R',max=5),
           ANGL_VRIL       =SIMP(statut='f',typ='R' ),
           LONG_TYPG       =SIMP(statut='f',typ='R',max='**',val_min=0.E+0),
           LARG_TYPG       =SIMP(statut='f',typ='R',max='**',val_min=0.E+0),
           EPAI_TYPG       =SIMP(statut='f',typ='R',max='**',val_min=0.E+0),
           RUGO_TYPG       =SIMP(statut='f',typ='R',max='**',val_min=0.E+0),
           COEF_TRAI_TYPG  =SIMP(statut='f',typ='R',max='**',val_min=0.E+0),
           COEF_DPOR_TYPG  =SIMP(statut='f',typ='R',max='**'),
           COOR_GRILLE     =SIMP(statut='f',typ='R',max='**'),
           TYPE_GRILLE     =SIMP(statut='f',typ='I',max='**'),
         ),
         COQUE_COAX      =FACT(statut='f',
           MASS_AJOU       =SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON") ),
           GROUP_MA_INT    =SIMP(statut='o',typ=grma),
           GROUP_MA_EXT    =SIMP(statut='o',typ=grma),
           VECT_X          =SIMP(statut='o',typ='R',max='**'),
           CARA_ELEM       =SIMP(statut='o',typ=cara_elem ),
           MATER_INT       =SIMP(statut='o',typ=mater_sdaster ),
           MATER_EXT       =SIMP(statut='o',typ=mater_sdaster ),
           RHO_FLUI        =SIMP(statut='o',typ='R' ),
           VISC_CINE       =SIMP(statut='o',typ='R' ),
           RUGOSITE        =SIMP(statut='o',typ='R' ),
           PDC_MOY_1       =SIMP(statut='o',typ='R' ),
           PDC_DYN_1       =SIMP(statut='o',typ='R' ),
           PDC_MOY_2       =SIMP(statut='o',typ='R' ),
           PDC_DYN_2       =SIMP(statut='o',typ='R' ),
         ),
         INFO            =SIMP(statut='f',typ='I',defaut= 1,into=( 1 , 2) ),
)  ;
