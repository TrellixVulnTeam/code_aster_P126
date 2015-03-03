# coding=utf-8

from Cata.Descriptor import *
from Cata.Commons import *

# ======================================================================
# COPYRIGHT (C) 1991 - 2011  EDF R&D                  WWW.CODE-ASTER.ORG
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


DEFI_PARTITION=OPER(nom="DEFI_PARTITION",op=21,sd_prod=sd_partit,
                    fr=tr("Creation partitionnement en sous-domaines"),
                    docu="U4.23.05",reentrant='n',UIinfo={"groupes":("Modélisation",)},

         NB_PART         =SIMP(statut='o',typ='I',val_min=2),
         MODELE          =SIMP(statut='o',typ=modele_sdaster),

         # Methode de partitionnement
         METHODE         =SIMP(statut='f',typ='TXM',into=("PMETIS","SCOTCH","KMETIS",), defaut="KMETIS" ),


         # Prefixe pour le nom des group_ma definissant les sous-domaines
         NOM_GROUP_MA    =SIMP(statut='f',typ='TXM',defaut='SD' ),

         INFO            =SIMP(statut='f',typ='I',into=(1, 2), defaut=1),
);
