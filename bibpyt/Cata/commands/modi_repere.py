# coding=utf-8

from Cata.Descriptor import *
from Cata.Commons import *

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
# person_in_charge: xavier.desroches at edf.fr
def modi_repere_prod(RESULTAT,CHAM_GD,**args):
  if AsType(RESULTAT) != None : return AsType(RESULTAT)
  if AsType(CHAM_GD)  != None : return AsType(CHAM_GD)

MODI_REPERE=OPER(nom="MODI_REPERE",op=191,sd_prod=modi_repere_prod,reentrant='f',
                 UIinfo={"groupes":("Post-traitements","Résultats et champs",)},
                 fr="Calcule les champs dans un nouveau repère.",
#
    regles=(UN_PARMI('CHAM_GD','RESULTAT',),),
    CHAM_GD     =SIMP(statut='f',typ=cham_gd_sdaster),
    RESULTAT    =SIMP(statut='f',typ=resultat_sdaster),
#
#   Traitement de RESULTAT
    b_resultat=BLOC(condition="RESULTAT != None",
                    fr="Changement de repère d'un champ extrait d'un résultat",
        regles=(EXCLUS('TOUT_ORDRE','NUME_ORDRE','INST','FREQ','NUME_MODE',
                       'NOEUD_CMP','LIST_INST','LIST_FREQ','NOM_CAS'),),
        TOUT_ORDRE  =SIMP(statut='f',typ='TXM',into=("OUI",) ),
        NUME_ORDRE  =SIMP(statut='f',typ='I',validators=NoRepeat(),max='**'),
        NUME_MODE   =SIMP(statut='f',typ='I',validators=NoRepeat(),max='**'),
        NOEUD_CMP   =SIMP(statut='f',typ='TXM',validators=NoRepeat(),max='**'),
        NOM_CAS     =SIMP(statut='f',typ='TXM' ),

        INST        =SIMP(statut='f',typ='R',validators=NoRepeat(),max='**'),
        FREQ        =SIMP(statut='f',typ='R',validators=NoRepeat(),max='**'),
        LIST_INST   =SIMP(statut='f',typ=listr8_sdaster),
        LIST_FREQ   =SIMP(statut='f',typ=listr8_sdaster),

        CRITERE     =SIMP(statut='f',typ='TXM',defaut="RELATIF",into=("RELATIF","ABSOLU",),),
        b_prec_rela=BLOC(condition="(CRITERE=='RELATIF')",
            PRECISION   =SIMP(statut='f',typ='R',defaut= 1.E-6,),
        ),
        b_prec_abso=BLOC(condition="(CRITERE=='ABSOLU')",
            PRECISION   =SIMP(statut='o',typ='R',),
        ),
        MODI_CHAM   =FACT(statut='o',max='**',
            TYPE_CHAM       =SIMP(statut='o',typ='TXM',
                                  into=("VECT_2D","VECT_3D","TENS_2D","TENS_3D","COQUE_GENE"),),
            NOM_CHAM        =SIMP(statut='o',typ='TXM',validators=NoRepeat(),into=C_NOM_CHAM_INTO(),),
            b_vect_2d   =BLOC(condition = "TYPE_CHAM=='VECT_2D'",
                NOM_CMP     =SIMP(statut='o',typ='TXM',min=2,max=2,), ),
            b_vect_3d   =BLOC(condition = "TYPE_CHAM=='VECT_3D'",
                NOM_CMP     =SIMP(statut='o',typ='TXM',min=3,max=3,), ),
            b_tens_2d   =BLOC(condition = "TYPE_CHAM=='TENS_2D'",
                NOM_CMP     =SIMP(statut='o',typ='TXM',min=4,max=4,), ),
            b_tens_3d   =BLOC(condition = "TYPE_CHAM=='TENS_3D'",
                NOM_CMP     =SIMP(statut='o',typ='TXM',min=6,max=6,), ),
            b_coque_gene=BLOC(condition = "TYPE_CHAM=='COQUE_GENE'",
                NOM_CMP     =SIMP(statut='o',typ='TXM',min=8,max=8,), ),
        ),
    ),
    b_resu_reuse=BLOC(condition = "RESULTAT != None and reuse",
                fr="Résultat réentrant : COQUE_INTR_UTIL ou COQUE_UTIL_INTR autorise",
        REPERE          =SIMP(statut='o',typ='TXM',position='global',
                                into=("COQUE_INTR_UTIL","COQUE_UTIL_INTR","COQUE_UTIL_CYL"),),
        AFFE     =FACT(statut='o',max='**',
            GROUP_MA    =SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**',),
            MAILLE      =SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**',),
        ),
    ),
    b__resu_not_reuse=BLOC(condition = "RESULTAT != None and not reuse",fr="Résultat non réentrant ",
        REPERE  =SIMP(statut='f',typ='TXM',defaut="UTILISATEUR",position='global',
                        into=("UTILISATEUR","CYLINDRIQUE","COQUE",
                            "COQUE_INTR_UTIL","COQUE_UTIL_INTR","COQUE_UTIL_CYL"),),
        AFFE     =FACT(statut='o',max='**',
            b_cyl       =BLOC(condition = "REPERE in ('CYLINDRIQUE', 'COQUE_UTIL_CYL')",
                ORIGINE         =SIMP(statut='f',typ='R',min=2,max=3,),
                AXE_Z           =SIMP(statut='f',typ='R',min=3,max=3,),
            ),
            b_uti       =BLOC(condition = "REPERE == 'UTILISATEUR'",
                            regles=(UN_PARMI('ANGL_NAUT','VECT_X'),
                                    ENSEMBLE('VECT_X','VECT_Y')),
                ANGL_NAUT       =SIMP(statut='f',typ='R',max=3,),
                VECT_X          =SIMP(statut='f',typ='R',min=3,max=3,),
                VECT_Y          =SIMP(statut='f',typ='R',min=3,max=3,),
            ),
            b_coq      =BLOC(condition = "REPERE == 'COQUE'",
                            regles=(UN_PARMI('ANGL_REP','VECTEUR'),),
                ANGL_REP        =SIMP(statut='f',typ='R',min=2,max=2,),
                VECTEUR         =SIMP(statut='f',typ='R',min=3,max=3,),
            ),
        GROUP_MA    =SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**',),
        GROUP_NO    =SIMP(statut='f',typ=grno,validators=NoRepeat(),max='**',),
        MAILLE      =SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**',),
        NOEUD       =SIMP(statut='f',typ=no  ,validators=NoRepeat(),max='**',),
        ),
    ),
#
#   Traitement de CHAM_GD
    b_cham_gd=BLOC(condition="CHAM_GD != None and not reuse",
            fr="Changement de repère du champ",
        REPERE      =SIMP(statut='o',typ='TXM',defaut="GLOBAL_UTIL",position='global',
                          into=("GLOBAL_UTIL",),),
        CARA_ELEM   =SIMP(statut='o',typ=cara_elem,),
    ),
    TITRE   =SIMP(statut='f',typ='TXM',max='**',),
    INFO    =SIMP(statut='f',typ='I',defaut=1,into=(1,2),),
);
