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
# person_in_charge: jacques.pellet at edf.fr

def post_champ_prod(RESULTAT,**args):
   if AsType(RESULTAT) != None : return AsType(RESULTAT)
   raise AsException("type de concept resultat non prevu")


# liste des options possibles pour les 4 mots clés EXTR_COQUE, EXTR_TUYAU, EXTR_PMF et MIN_MAX_SP :
liste_option_extr=("EPEQ_ELGA","EPEQ_ELNO","EPSI_ELGA","EPSI_ELNO",
                   "SIEF_ELGA","SIEF_ELNO",
                   "SIEQ_ELGA","SIEQ_ELNO","SIGM_ELGA","SIGM_ELNO",
                   "VARI_ELGA","VARI_ELNO","EPVC_ELGA","EPVC_ELNO",
                   "EPME_ELGA","EPME_ELNO","EPSP_ELGA","EPSP_ELNO" )


POST_CHAMP=OPER(nom="POST_CHAMP",op=155,sd_prod=post_champ_prod, reentrant='n',
            UIinfo={"groupes":("Post-traitements","Eléments de structure",)},
                 fr=tr("extraction de champs sur un sous-point. "),

         regles=(UN_PARMI('EXTR_COQUE','EXTR_TUYAU','EXTR_PMF','MIN_MAX_SP','COQU_EXCENT'),
                 EXCLUS('TOUT_ORDRE','NUME_ORDRE','INST','FREQ','NUME_MODE','NOEUD_CMP',
                        'LIST_INST','LIST_FREQ','LIST_ORDRE','NOM_CAS',),
                 ),

         RESULTAT        =SIMP(statut='o',typ=resultat_sdaster,
                               fr=tr("Resultat d'une commande globale")),


#====
# Sélection des numéros d'ordre pour lesquels on fait le calcul :
#====
         TOUT_ORDRE      =SIMP(statut='f',typ='TXM',into=("OUI",) ),
         NUME_ORDRE      =SIMP(statut='f',typ='I',validators=NoRepeat(),max='**' ),
         NUME_MODE       =SIMP(statut='f',typ='I',validators=NoRepeat(),max='**'),
         LIST_ORDRE      =SIMP(statut='f',typ=listis_sdaster),
         NOEUD_CMP       =SIMP(statut='f',typ='TXM',validators=NoRepeat(),max='**'),
         NOM_CAS         =SIMP(statut='f',typ='TXM',validators=NoRepeat(),max='**'),
         INST            =SIMP(statut='f',typ='R',validators=NoRepeat(),max='**' ),
         LIST_INST       =SIMP(statut='f',typ=listr8_sdaster),
         FREQ            =SIMP(statut='f',typ='R',validators=NoRepeat(),max='**' ),
         LIST_FREQ       =SIMP(statut='f',typ=listr8_sdaster),

         b_acce_reel     =BLOC(condition="(FREQ != None)or(LIST_FREQ != None)or(INST != None)or(LIST_INST != None)",
            CRITERE         =SIMP(statut='f',typ='TXM',defaut="RELATIF",into=("RELATIF","ABSOLU",),),
            b_prec_rela=BLOC(condition="(CRITERE=='RELATIF')",
                 PRECISION       =SIMP(statut='f',typ='R',defaut= 1.E-6,),),
            b_prec_abso=BLOC(condition="(CRITERE=='ABSOLU')",
                 PRECISION       =SIMP(statut='o',typ='R',),),
         ),


#====
# Sélection de la zone géométrique:
#====
         TOUT       =SIMP(statut='f',typ='TXM',into=("OUI",) ),
         GROUP_MA   =SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
         MAILLE     =SIMP(statut='f',typ=ma,validators=NoRepeat(),max='**'),



#====
# Extraction sur un sous-point d'une coque :
#====
         EXTR_COQUE  =FACT(statut='f', max=1, fr=tr("extraction sur un sous-point d'une coque"),
           NOM_CHAM     =SIMP(statut='o',typ='TXM',validators=NoRepeat(),max='**',
                              into=liste_option_extr,),
           NUME_COUCHE  =SIMP(statut='o',typ='I',val_min=1,
                             fr=tr("numero de couche dans l'épaisseur de la coque") ),
           NIVE_COUCHE  =SIMP(statut='o',typ='TXM',into=("SUP","INF","MOY"),
                             fr=tr("position dans l'épaisseur de la couche") ),
           ),


#====
# Extraction sur un sous-point d'un tuyau :
#====
         EXTR_TUYAU  =FACT(statut='f', max=1, fr=tr("extraction sur un sous-point d'un tuyau"),
           NOM_CHAM     =SIMP(statut='o',typ='TXM',validators=NoRepeat(),max='**',
                              into=liste_option_extr ,),
           NUME_COUCHE  =SIMP(statut='o',typ='I',val_min=1,
                             fr=tr("numero de couche dans l'épaisseur du tuyau") ),
           NIVE_COUCHE  =SIMP(statut='o',typ='TXM',into=("SUP","INF","MOY"),
                             fr=tr("position dans l'épaisseur de la couche") ),
           ANGLE        =SIMP(statut='o',typ='I',val_min=0,val_max=360,
                             fr=tr("angle de dépouillement pour les tuyaux, en degrés à partir de la génératrice") ),
           ),


#====
# Extraction sur un sous-point d'une poutre multifibre :
#====
         EXTR_PMF  =FACT(statut='f', max=1, fr=tr("extraction sur un sous-point d'une poutre multifibre"),
           NOM_CHAM     =SIMP(statut='o',typ='TXM',validators=NoRepeat(),max='**',
                              into=liste_option_extr,),
           NUME_FIBRE  =SIMP(statut='o',typ='I',val_min=1,
                             fr=tr("numéro de la fibre dans la poutre multifibre") ),
           ),


#====
# Extraction des min / max sur les sous-points :
#====
         MIN_MAX_SP  =FACT(statut='f', max='**', fr=tr("extraction du min/max d'une composante pour un champ"),
           NOM_CHAM     =SIMP(statut='o',typ='TXM',
                              into=liste_option_extr,),
           NOM_CMP        =SIMP(statut='o',typ='TXM',fr=tr("nom de la composante"),  ),
           TYPE_MAXI      =SIMP(statut='o',typ='TXM',into=("MAXI","MINI","MAXI_ABS","MINI_ABS",) ),
           NUME_CHAM_RESU = SIMP(statut='o', typ='I', val_min=1, val_max=20,
                          fr=tr("Numéro du champ produit. Exemple: 6 produit le champ UT06"),),
           ),


#====
# Calcul des efforts des coques "excentrées" sur le feuillet moyen de la coque :
#====
         COQU_EXCENT  =FACT(statut='f', max=2, fr=tr("Calcul des efforts d'une coque 'excentrée' sur le feuillet moyen de la coque"),
           NOM_CHAM     =SIMP(statut='o',typ='TXM',into=("EFGE_ELNO","EFGE_ELGA",),),
           MODI_PLAN    =SIMP(statut='o',typ='TXM',into=("OUI",),),
           ),
      )
