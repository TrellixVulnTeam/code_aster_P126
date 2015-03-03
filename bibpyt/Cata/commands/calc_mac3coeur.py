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
# person_in_charge: romeo.fernandes at edf.fr


CALC_MAC3COEUR = MACRO(nom="CALC_MAC3COEUR",
                       op=OPS("Mac3coeur.mac3coeur_calcul.calc_mac3coeur_ops"),
                       sd_prod=evol_noli,

         TYPE_COEUR   = SIMP(statut='o',typ='TXM',into=("MONO","TEST","900","1300","N4","EPR"),position='global' ),
         # TYPE DE COEUR A CONSIDERER
         TABLE_N      = SIMP(statut='o',typ=table_sdaster),         # TABLE INITIALE DES DAMAC A L INSTANT N
         MAILLAGE_N   = SIMP(statut='f',typ=maillage_sdaster),      # MAILLAGE EN ATTENDANT MIEUX ???

         LAME = FACT(statut='f',max=1,
                     fr=tr("Estimation des lames d'eau entre AC"),
               TABLE_NP1    = SIMP(statut='o',typ=table_sdaster),         # TABLE INITIALE DES DAMAC A L INSTANT N+1
               MAILLAGE_NP1 = SIMP(statut='o',typ=maillage_sdaster),      # MAILLAGE EN ATTENDANT MIEUX ???
               UNITE_THYC   = SIMP(statut='f',typ='I', max=1),            # Unite Logique du fichier THYC
                     ),

         DEFORMATION  = FACT(statut='f',max=1,
                      fr=tr("Estimation des deformations des AC"),
               RESU_INIT    = SIMP(statut='f',typ=resultat_sdaster),
               NIVE_FLUENCE = SIMP(statut='o',typ='R',validators=NoRepeat(),max=1), # FLUENCE MAXIMALE DANS LE COEUR
               UNITE_THYC      = SIMP(statut='o',typ='I', max=1),                   # Unite Logique du fichier THYC

               # choix du maintien dans le cas mono-assemblage
               b_maintien_mono = BLOC(condition = "TYPE_COEUR == 'MONO'",

                    TYPE_MAINTIEN = SIMP(statut='o',typ='TXM',into=("FORCE","DEPL_PSC"), ),

                    b_maintien_mono_force = BLOC(condition = "TYPE_MAINTIEN == 'FORCE'",
                                 fr=tr("valeur de l'effort de maintien imposée"),
                                 FORCE_MAINTIEN           =SIMP(statut='o',typ='R', max=1),),

                                       ),

               # choix du maintien dans le cas d'un coeur à plusieurs assemblages
               b_maintien_coeur = BLOC(condition = "TYPE_COEUR != 'MONO'",

                    TYPE_MAINTIEN = SIMP(statut='f',typ='TXM',into=("DEPL_PSC",),defaut="DEPL_PSC" ),

                                       ),

               # choix de la poussée d'Archimède dans le cas mono-assemblage
               b_archimede_mono = BLOC(condition = "TYPE_COEUR == 'MONO'",

                    ARCHIMEDE = SIMP(statut='o',typ='TXM',into=("OUI","NON"), ),

                                       ),

               # choix de la poussée d'Archimède dans le cas d'un coeur à plusieurs assemblages
               b_archimede_coeur = BLOC(condition = "TYPE_COEUR != 'MONO'",

                    ARCHIMEDE = SIMP(statut='f',typ='TXM',into=("OUI"),defaut="OUI" ),

                                       ),

                       ),

);
