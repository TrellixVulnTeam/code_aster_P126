# coding=utf-8
# --------------------------------------------------------------------
# Copyright (C) 1991 - 2017 - EDF R&D - www.code-aster.org
# This file is part of code_aster.
#
# code_aster is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# code_aster is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with code_aster.  If not, see <http://www.gnu.org/licenses/>.
# --------------------------------------------------------------------

# person_in_charge: josselin.delmas at edf.fr

cata_msg = {

    1 : _(u"""
 contraintes planes en grandes déformations non implantées
"""),

    2 : _(u"""
 caractéristique fluage incomplet
"""),

    20 : _(u"""
 La définition du repère d'orthotropie a été mal faite.
 Utilisez soit ANGL_REP  soit ANGL_AXE de la commande AFFE_CARA_ELEM mot clé facteur MASSIF
"""),

    22 : _(u"""
 type d'élément incompatible avec une loi élastique anisotrope
"""),

    24 : _(u"""
 Le chargement de type cisaillement (mot-clé CISA_2D) ne peut pas être suiveur (mot-clé TYPE_CHAR='SUIV').
"""),

    25 : _(u"""
 On ne sait pas traiter un chargement de type pression (mot-clé PRES_REP) suiveuse (mot-clé TYPE_CHAR_='SUIV') imposé sur l'axe du modèle axisymétrique.

 Conseils :
  - Vérifiez que le chargement doit bien être suiveur.
  - Vérifiez que la zone d'application du chargement est la bonne.
"""),

    28 : _(u"""
 prédiction par extrapolation impossible : pas de temps nul
"""),

    31 : _(u"""
La borne supérieure est incorrecte.
Ce message est un message d'erreur développeur.
Contactez le support technique.
"""),

    32 : _(u"""
 la viscosité N doit être différente de zéro
"""),

    33 : _(u"""
 la viscosité UN_SUR_K doit être différente de zéro
"""),

    65 : _(u"""
Arrêt suite à l'échec de l'intégration de la loi de comportement.
   Vérifiez vos paramètres, la cohérence des unités.
   Essayez d'augmenter ITER_INTE_MAXI.
"""),

    66 : _(u"""
  convergence atteinte sur approximation linéaire tangente de l'évolution plastique
  risque d'imprécision
"""),

    67 : _(u"""
  endommagement maximal atteint au cours des résolutions internes
"""),

    87 : _(u"""
 l'incrément de temps vaut zéro, vérifiez votre découpage
"""),

    88 : _(u"""
 fluence décroissante (flux<0)
"""),

    89 : _(u"""
 le paramètre A doit être >=0
"""),

    91 : _(u"""
 stop, RIGI_MECA_TANG non disponible
"""),

    92 : _(u"""
 la maille doit être de type SEG3, TRIA6, QUAD8 TETRA10, PENTA15 ou HEXA20.
 or la maille est de type :  %(k1)s .
"""),

    94 : _(u"""
 le champ issu du concept %(k1)s n'est pas calculé à l'instant %(i3)i
"""),

    96 : _(u"""
 le séchage ne peut pas être mélangé à un autre comportement
"""),

    97 : _(u"""
 EVOL_THER_SECH est un mot-clé obligatoire pour le séchage de type SECH_GRANGER et SECH_NAPPE
"""),

    98 : _(u"""
  le concept :  %(k1)s  n'est pas un champ de température
"""),

    99 : _(u"""
  le concept EVOL_THER :  %(k1)s  ne contient aucun champ de température
"""),

}
