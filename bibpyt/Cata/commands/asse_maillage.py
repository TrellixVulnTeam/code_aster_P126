# coding=utf-8

from Cata.Syntax import *
from Cata.DataStructure import *
from Cata.Commons import *

# ======================================================================
# COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
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
ASSE_MAILLAGE=OPER(nom="ASSE_MAILLAGE",op= 105,sd_prod=maillage_sdaster,
                   fr=tr("Assembler deux maillages pour en former un nouveau"),
                   reentrant='n',
                   UIinfo={"groupes":("Maillage",)},
         MAILLAGE_1 =  SIMP(statut='o',typ=maillage_sdaster,),
         MAILLAGE_2 =  SIMP(statut='o',typ=maillage_sdaster,),
         OPERATION  =  SIMP(statut='o',typ='TXM',into=("SOUS_STR","SUPERPOSE","COLLAGE"),),
         b_collage  =  BLOC(condition = "OPERATION == 'COLLAGE'",
           COLLAGE  =  FACT(statut='o',
              GROUP_MA_1     =SIMP(statut='o',typ=grma),
              GROUP_MA_2     =SIMP(statut='o',typ=grma),
                             ),
                           ),
)  ;
