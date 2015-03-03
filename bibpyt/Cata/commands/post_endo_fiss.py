# coding=utf-8

from Cata.Descriptor import *
from Cata.Commons import *

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
# person_in_charge: marina.bottoni at edf.fr

# ---------------------------------------------------------------------------
#                  POST_ENDO_FISS
# RECHERCHE DU TRAJET DE FISSURATION SUR UN
#  CHAMP SCALAIRE 2D


def post_endo_fiss_prod(self,TABLE,**args) :
    self.type_sdprod(TABLE,table_sdaster)
    return maillage_sdaster

POST_ENDO_FISS=MACRO(nom="POST_ENDO_FISS",
                     op=OPS('Macro.post_endo_fiss_ops.post_endo_fiss_ops'),
                     sd_prod=post_endo_fiss_prod,
                     reentrant='n',
                     UIinfo={"groupes":("Post-traitements","Outils-métier",)},
                     fr=tr("Individuation du trace d'une fissure a partir d'un champ scalaire pertinant"),

            TABLE  = SIMP(statut = 'o', typ = CO,),

            regles = (UN_PARMI("RESULTAT","CHAM_GD"),
                      ),
            OUVERTURE  = SIMP(statut = 'f', typ = 'TXM', into=('OUI','NON',), defaut = 'NON' ),
            b_resultat = BLOC(condition  = "RESULTAT != None",
                              regles     = (UN_PARMI('NUME_ORDRE','INST'),),
                              NUME_ORDRE = SIMP(statut = 'f', typ = 'I', validators = NoRepeat(), ),
                              INST       = SIMP(statut = 'f', typ = 'R', validators = NoRepeat(), ),
                              ),

            #b_champ    = BLOC(condition = "CHAM_GD != None",),

            CHAM_GD         = SIMP(statut = 'f',typ = (cham_gd_sdaster)),
            RESULTAT        = SIMP(statut = 'f',typ = (evol_noli)),
            NOM_CMP         = SIMP(statut = 'o',typ='TXM',),
            NOM_CHAM        = SIMP(statut = 'o', typ = 'TXM',
                                   fr = tr("nom du champ a post-traiter"),),

            RECHERCHE = FACT(statut = 'o',min=1,max='**',
                             regles = (
                                       PRESENT_ABSENT('TOUT','GROUP_MA',),
                                    ),
                              LONG_ORTH  = SIMP(statut='o', typ='R'),
                              NB_POINT   = SIMP(statut='f', typ='I', defaut = 500),
                              PAS        = SIMP(statut='o', typ='R', ),
                              LONG_REG   = SIMP(statut='o', typ='R'),
                              BORNE_MIN  = SIMP(statut='f', typ='R', defaut=0.5),
                              ANGL_MAX   = SIMP(statut='f', typ='R', defaut=120.),
                              TOUT       = SIMP(statut='f', typ='TXM', into=('OUI',) ),
                              GROUP_MA   = SIMP(statut='f', typ=grma,  validators=NoRepeat(), ),
                              BORNE_MAX  = SIMP(statut='f', typ='R'),
                              ),
                   )
