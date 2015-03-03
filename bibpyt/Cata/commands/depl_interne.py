# coding=utf-8

from Cata.Descriptor import *

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
def depl_interne_prod(DEPL_GLOBAL,**args ):
    if AsType(DEPL_GLOBAL)     == cham_no_sdaster: return cham_no_sdaster
    if AsType(DEPL_GLOBAL)     == evol_elas      : return evol_elas
    if AsType(DEPL_GLOBAL)     == dyna_trans     : return dyna_trans
    if AsType(DEPL_GLOBAL)     == dyna_harmo     : return dyna_harmo
    if AsType(DEPL_GLOBAL)     == mode_meca      : return mode_meca
    if AsType(DEPL_GLOBAL)     == mode_meca_c    : return mode_meca_c
    raise AsException("type de concept resultat non prevu")

DEPL_INTERNE=OPER(nom="DEPL_INTERNE",op=89,sd_prod=depl_interne_prod,reentrant='n',
            UIinfo={"groupes":("Matrices et vecteurs",)},
                  fr=tr("Calculer le champ de déplacement à l'intérieur d'une sous-structure statique"),
         DEPL_GLOBAL     =SIMP(statut='o',typ=(cham_no_sdaster,mode_meca,mode_meca_c,evol_elas,dyna_trans,dyna_harmo),),
         SUPER_MAILLE    =SIMP(statut='o',typ=ma,),
         NOM_CAS         =SIMP(statut='f',typ='TXM',defaut=" "),
)  ;
