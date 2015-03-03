# coding=utf-8

from Cata.Descriptor import *

# ======================================================================
# COPYRIGHT (C) 1991 - 2002  EDF R&D                  WWW.CODE-ASTER.ORG
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
# person_in_charge: irmela.zentner at edf.fr
def gene_matr_alea_prod(MATR_MOYEN,**args ):
  if (AsType(MATR_MOYEN) == matr_asse_gene_r )  : return matr_asse_gene_r
  if (AsType(MATR_MOYEN) == macr_elem_dyna) : return macr_elem_dyna
  raise AsException("type de concept resultat non prevu")

GENE_MATR_ALEA=OPER(nom="GENE_MATR_ALEA",op=  27,
#sd_prod=matr_asse_gene_r,
sd_prod=gene_matr_alea_prod,
               fr=tr("Générer une réalisation d'une matrice aléatoire réelle sym. déf. positive ou d'un macro élément dynamique"),
               reentrant='n',
            UIinfo={"groupes":("Matrices et vecteurs",)},
   MATR_MOYEN   = SIMP(statut='o', typ=(matr_asse_gene_r,macr_elem_dyna)),

#    cas matrice generalisee
   b_matr =BLOC( condition = "AsType(MATR_MOYEN) in (matr_asse_gene_r,)",
           COEF_VAR     = SIMP(statut='f', typ='R', defaut=0.1, val_min=0.E+0 ,
                                fr=tr("coefficient de variation de la matrice a generer") ),
           ),
#    cas macr_elem_dyna
   b_macr =BLOC( condition = "AsType(MATR_MOYEN) in (macr_elem_dyna,)",
           fr=tr("cas macr_elem_dyna (sous-structuratio)"),
           COEF_VAR_RIGI     = SIMP(statut='f', typ='R', defaut=0.1, val_min=0.E+0 ,
                                fr=tr("coefficient de variation de la matrice de raideur") ),
           COEF_VAR_MASS     = SIMP(statut='f', typ='R', defaut=0., val_min=0.E+0 ,
                                fr=tr("coefficient de variation de la matrice de masse") ),
           COEF_VAR_AMOR     = SIMP(statut='f', typ='R', defaut=0., val_min=0.E+0 ,
                                fr=tr("coefficient de variation de la matrice d'amortissement") ),),

   INIT_ALEA    =SIMP(statut='f',typ='I'),
) ;
