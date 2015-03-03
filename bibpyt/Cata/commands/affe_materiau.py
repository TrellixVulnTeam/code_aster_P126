# coding=utf-8

from Cata.Descriptor import *

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
# person_in_charge: jacques.pellet at edf.fr
AFFE_MATERIAU=OPER(nom="AFFE_MATERIAU",op=6,sd_prod=cham_mater,
                   fr=tr("Affecter des matériaux à des zones géométriques d'un maillage"),
                         reentrant='n',
            UIinfo={"groupes":("Modélisation",)},
         regles=(AU_MOINS_UN('MAILLAGE','MODELE',),),
         MAILLAGE        =SIMP(statut='f',typ=maillage_sdaster),
         MODELE          =SIMP(statut='f',typ=modele_sdaster),

         #  affectation du nom du matériau (par mailles):
         #  ----------------------------------------------
         AFFE            =FACT(statut='o',max='**',
           regles=(UN_PARMI('TOUT','GROUP_MA','MAILLE'),),
           TOUT            =SIMP(statut='f',typ='TXM',into=("OUI",) ),
           GROUP_MA        =SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
           MAILLE          =SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
           MATER           =SIMP(statut='o',typ=mater_sdaster,max=30),
         ),

         #  affectation de comportement (multifibres pour l'instant):
         #  ----------------------------------------------
         AFFE_COMPOR        =FACT(statut='f',max='**',
           regles=(UN_PARMI('TOUT','GROUP_MA','MAILLE'),),
           TOUT            =SIMP(statut='f',typ='TXM',into=("OUI",) ),
           GROUP_MA        =SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
           MAILLE          =SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
           COMPOR          =SIMP(statut='o',typ=compor_sdaster,max=1),
         ),

         #  affectation des variables de commande :
         #  --------------------------------------------------
         # un mot clé caché qui ne sert qu'à boucler sur les VARC possibles :
         LIST_NOM_VARC =SIMP(statut='c',typ='TXM', max='**', defaut=("TEMP","GEOM","CORR","IRRA","HYDR","SECH","EPSA",
                                                           "M_ACIER","M_ZIRC","NEUT1","NEUT2","PTOT","DIVU",)),

         AFFE_VARC    =FACT(statut='f',max='**',
          regles=(PRESENT_ABSENT('TOUT','GROUP_MA','MAILLE'),
                  PRESENT_ABSENT('GROUP_MA','TOUT'),
                  PRESENT_ABSENT('MAILLE','TOUT'),
                # La règle suivante permet de donner VALE_REF sans donner EVOL ni CHAM_GD
                # Elle est nécessaire pour la THM (voir doc U4.43.03)
                # Mais on ne peut plus l'écrire depuis de VALE_REF est dans un bloc
                # AU_MOINS_UN('EVOL','CHAM_GD','VALE_REF'),
                  EXCLUS('EVOL','CHAM_GD'),
                  ),

          TOUT            =SIMP(statut='f',typ='TXM',into=("OUI",) ), # [défaut]
          GROUP_MA        =SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
          MAILLE          =SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),

          NOM_VARC        =SIMP(statut='o',typ='TXM', into=("TEMP","GEOM","CORR","IRRA","HYDR","SECH","EPSA",
                               "M_ACIER","M_ZIRC","NEUT1","NEUT2","PTOT","DIVU",)),
          CHAM_GD        =SIMP(statut='f',typ=cham_gd_sdaster,),
          EVOL            =SIMP(statut='f',typ=evol_sdaster,),

          B_EVOL          =BLOC(condition="EVOL!=None",
              NOM_CHAM      =SIMP(statut='f',typ='TXM',into=("TEMP","CORR","IRRA","NEUT","GEOM",
                                                             "HYDR_ELNO","HYDR_NOEU",
                                                             "META_ELNO","META_NOEU",
                                                             "EPSA_ELNO","EPSA_NOEU","PTOT","DIVU",)),
              PROL_DROITE   =SIMP(statut='f',typ='TXM',defaut="EXCLU",into=("CONSTANT","LINEAIRE","EXCLU") ),
              PROL_GAUCHE   =SIMP(statut='f',typ='TXM',defaut="EXCLU",into=("CONSTANT","LINEAIRE","EXCLU") ),
              FONC_INST     =SIMP(statut='f',typ=(fonction_sdaster,formule)),
          ),

          # VALE_REF est nécessaire pour certaines VARC :
          B_VALE_REF          =BLOC(condition="NOM_VARC in ('TEMP','SECH')",
               VALE_REF          =SIMP(statut='o',typ='R'),
          ),

         ),

         #  mots clés cachés pour les variables de commande NEUT1/NEUT2 :
         #  --------------------------------------------------------------
         VARC_NEUT1   =FACT(statut='d',
           NOM_VARC        =SIMP(statut='c',typ='TXM',defaut="NEUT1"),
           GRANDEUR        =SIMP(statut='c',typ='TXM',defaut="NEUT_R"),
           CMP_GD          =SIMP(statut='c',typ='TXM',max=1,min=1,defaut=("X1")),
           CMP_VARC        =SIMP(statut='c',typ='TXM',max=1,min=1,defaut=("NEUT1")),
         ),
         VARC_NEUT2   =FACT(statut='d',
           NOM_VARC        =SIMP(statut='c',typ='TXM',defaut="NEUT2"),
           GRANDEUR        =SIMP(statut='c',typ='TXM',defaut="NEUT_R"),
           CMP_GD          =SIMP(statut='c',typ='TXM',max=1,min=1,defaut=("X1")),
           CMP_VARC        =SIMP(statut='c',typ='TXM',max=1,min=1,defaut=("NEUT2")),
         ),

         #  mots clés cachés pour variable de commande TEMP :
         #  --------------------------------------------------
         VARC_TEMP    =FACT(statut='d',
           NOM_VARC        =SIMP(statut='c',typ='TXM',defaut="TEMP"),
           GRANDEUR        =SIMP(statut='c',typ='TXM',defaut="TEMP_R"),
           CMP_GD          =SIMP(statut='c',typ='TXM',max=4,min=4,defaut=("TEMP","TEMP_MIL","TEMP_INF","TEMP_SUP",)),
           CMP_VARC        =SIMP(statut='c',typ='TXM',max=4,min=4,defaut=("TEMP","TEMP_MIL","TEMP_INF","TEMP_SUP",)),
         ),

         #  mots clés cachés pour variable de commande GEOM :
         #  --------------------------------------------------
         VARC_GEOM    =FACT(statut='d',
           NOM_VARC        =SIMP(statut='c',typ='TXM',defaut="GEOM"),
           GRANDEUR        =SIMP(statut='c',typ='TXM',defaut="GEOM_R"),
           CMP_GD          =SIMP(statut='c',typ='TXM',max=3,min=3,defaut=("X","Y","Z",)),
           CMP_VARC        =SIMP(statut='c',typ='TXM',max=3,min=3,defaut=("X","Y","Z",)),
         ),

         #  mots clés cachés pour variable de commande PTOT :
         #  -------------------------------------------------
         VARC_PTOT    =FACT(statut='d',
           NOM_VARC         =SIMP(statut='c',typ='TXM',defaut="PTOT"),
           GRANDEUR         =SIMP(statut='c',typ='TXM',defaut="DEPL_R"),
           CMP_GD           =SIMP(statut='c',typ='TXM',max=1,min=1,defaut=("PTOT",)),
           CMP_VARC         =SIMP(statut='c',typ='TXM',max=1,min=1,defaut=("PTOT",)),
         ),

         #  mots clés cachés pour variable de commande SECH :
         #  --------------------------------------------------
         VARC_SECH    =FACT(statut='d',
           NOM_VARC        =SIMP(statut='c',typ='TXM',defaut="SECH"),
           GRANDEUR        =SIMP(statut='c',typ='TXM',defaut="TEMP_R"),
           CMP_GD          =SIMP(statut='c',typ='TXM',max=1,min=1,defaut=("TEMP",)),
           CMP_VARC        =SIMP(statut='c',typ='TXM',max=1,min=1,defaut=("SECH",)),
         ),

         #  mots clés cachés pour variable de commande HYDR :
         #  --------------------------------------------------
         VARC_HYDR    =FACT(statut='d',
           NOM_VARC        =SIMP(statut='c',typ='TXM',defaut="HYDR"),
           GRANDEUR        =SIMP(statut='c',typ='TXM',defaut="HYDR_R"),
           CMP_GD          =SIMP(statut='c',typ='TXM',max=1,min=1,defaut=("HYDR",)),
           CMP_VARC        =SIMP(statut='c',typ='TXM',max=1,min=1,defaut=("HYDR",)),
         ),

         #  mots clés cachés pour variable de commande CORR :
         #  --------------------------------------------------
         VARC_CORR    =FACT(statut='d',
           NOM_VARC        =SIMP(statut='c',typ='TXM',defaut="CORR"),
           GRANDEUR        =SIMP(statut='c',typ='TXM',defaut="CORR_R"),
           CMP_GD          =SIMP(statut='c',typ='TXM',max=1,min=1,defaut=("CORR",)),
           CMP_VARC        =SIMP(statut='c',typ='TXM',max=1,min=1,defaut=("CORR",)),
         ),

         #  mots clés cachés pour variable de commande IRRA :
         #  --------------------------------------------------
         VARC_IRRA    =FACT(statut='d',
           NOM_VARC        =SIMP(statut='c',typ='TXM',defaut="IRRA"),
           GRANDEUR        =SIMP(statut='c',typ='TXM',defaut="IRRA_R"),
           CMP_GD          =SIMP(statut='c',typ='TXM',max=1,min=1,defaut=("IRRA",)),
           CMP_VARC        =SIMP(statut='c',typ='TXM',max=1,min=1,defaut=("IRRA",)),
         ),

         #  mots clés cachés pour variable de commande DIVU :
         #  --------------------------------------------------
         VARC_DIVU    =FACT(statut='d',
           NOM_VARC        =SIMP(statut='c',typ='TXM',defaut="DIVU"),
           GRANDEUR        =SIMP(statut='c',typ='TXM',defaut="EPSI_R"),
           CMP_GD          =SIMP(statut='c',typ='TXM',max=1,min=1,defaut=("DIVU",)),
           CMP_VARC        =SIMP(statut='c',typ='TXM',max=1,min=1,defaut=("DIVU",)),
         ),

         #  mots clés cachés pour variable de commande EPSA :
         #  --------------------------------------------------
         VARC_EPSA    =FACT(statut='d',
           NOM_VARC        =SIMP(statut='c',typ='TXM',defaut="EPSA"),
           GRANDEUR        =SIMP(statut='c',typ='TXM',defaut="EPSI_R"),
           CMP_GD          =SIMP(statut='c',typ='TXM',max=6,min=6,defaut=("EPXX","EPYY","EPZZ","EPXY","EPXZ","EPYZ",)),
           CMP_VARC        =SIMP(statut='c',typ='TXM',max=6,min=6,defaut=("EPSAXX","EPSAYY","EPSAZZ","EPSAXY","EPSAXZ","EPSAYZ",)),
         ),
         #  mots clés cachés pour variable de commande metallurgique ACIER :
         #  -----------------------------------------------------------------
         VARC_M_ACIER  =FACT(statut='d',
           NOM_VARC        =SIMP(statut='c',typ='TXM',defaut="M_ACIER"),
           GRANDEUR        =SIMP(statut='c',typ='TXM',defaut="VARI_R"),
           CMP_GD          =SIMP(statut='c',typ='TXM',max=7,min=7,defaut=("V1","V2","V3","V4","V5","V6","V7")),
           CMP_VARC        =SIMP(statut='c',typ='TXM',max=7,min=7,defaut=("PFERRITE","PPERLITE","PBAINITE",
                                                                          "PMARTENS","TAUSTE","TRANSF","TACIER",)),
         ),
         #  mots clés cachés pour variable de commande metallurgique ZIRCALOY :
         #  --------------------------------------------------------------------
         VARC_M_ZIRC  =FACT(statut='d',
           NOM_VARC        =SIMP(statut='c',typ='TXM',defaut="M_ZIRC"),
           GRANDEUR        =SIMP(statut='c',typ='TXM',defaut="VARI_R"),
           CMP_GD          =SIMP(statut='c',typ='TXM',max=4,min=4,defaut=("V1","V2","V3","V4")),
           CMP_VARC        =SIMP(statut='c',typ='TXM',max=4,min=4,defaut=("ALPHPUR","ALPHBETA","TZIRC","TEMPS")),
         ),

         INFO            =SIMP(statut='f',typ='I',defaut=1,into=(1,2) ),
)  ;
