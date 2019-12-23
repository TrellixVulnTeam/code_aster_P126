# coding=utf-8
# --------------------------------------------------------------------
# Copyright (C) 1991 - 2019 - EDF R&D - www.code-aster.org
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

# person_in_charge: mathieu.courtois at edf.fr


import aster
from code_aster.Cata.Syntax import ASSD, AsException


class cham_gd_sdaster(ASSD):
    cata_sdj = "SD.sd_champ.sd_champ"

class carte_sdaster(cham_gd_sdaster):
    cata_sdj = "SD.sd_champ.sd_carte_class"

class cham_elem(cham_gd_sdaster):
   cata_sdj = "SD.sd_champ.sd_cham_elem_class"

   def EXTR_COMP(self,comp,lgma,topo=0) :
      """ retourne les valeurs de la composante comp du champ sur la liste
        de groupes de mailles lgma avec eventuellement l'info de la
        topologie si topo>0. Si lgma est une liste vide, c'est equivalent
        a un TOUT='OUI' dans les commandes aster
        Attributs retourne
          - self.valeurs : numpy.array contenant les valeurs
        Si on a demande la topo  :
          - self.maille  : numero de mailles
          - self.point   : numero du point dans la maille
          - self.sous_point : numero du sous point dans la maille """
      import numpy
      if not self.accessible() :
         raise AsException("Erreur dans cham_elem.EXTR_COMP en PAR_LOT='OUI'")

      ncham=self.getName()
      ncham=ncham+(8-len(ncham))*' '
      nchams=ncham[0:7]+'S'
      ncmp=comp+(8-len(comp))*' '

      aster.prepcompcham(ncham,nchams,ncmp,"EL      ",topo,lgma)

      valeurs=numpy.array(aster.getvectjev(nchams+(19-len(ncham))*' '+'.V'))

      if (topo>0) :
         maille=(aster.getvectjev(nchams+(19-len(ncham))*' '+'.M'))
         point=(aster.getvectjev(nchams+(19-len(ncham))*' '+'.P'))
         sous_point=(aster.getvectjev(nchams+(19-len(ncham))*' '+'.SP'))
      else :
         maille=None
         point=None
         sous_point=None

      aster.prepcompcham("__DETR__",nchams,ncmp,"EL      ",topo,lgma)

      return post_comp_cham_el(valeurs,maille,point,sous_point)

class cham_no_sdaster(cham_gd_sdaster):
   cata_sdj = "SD.sd_champ.sd_cham_no_class"

   def EXTR_COMP(self,comp=' ',lgno=[],topo=0) :
      """ retourne les valeurs de la composante comp du champ sur la liste
        de groupes de noeuds lgno avec eventuellement l'info de la
        topologie si topo>0. Si lgno est une liste vide, c'est equivalent
        a un TOUT='OUI' dans les commandes aster
        Attributs retourne
          - self.valeurs : numpy.array contenant les valeurs
        Si on a demande la topo (i.e. self.topo = 1) :
          - self.noeud  : numero de noeud
        Si on demande toutes les composantes (comp = ' ') :
          - self.comp : les composantes associees a chaque grandeur pour chaque noeud
      """
      import numpy
      if not self.accessible() :
         raise AsException("Erreur dans cham_no.EXTR_COMP en PAR_LOT='OUI'")

      ncham=self.getName()
      ncham=ncham+(8-len(ncham))*' '
      nchams=ncham[0:7]+'S'
      ncmp=comp+(8-len(comp))*' '

      aster.prepcompcham(ncham,nchams,ncmp,"NO      ",topo,lgno)

      valeurs=numpy.array(aster.getvectjev(nchams+(19-len(ncham))*' '+'.V'))

      if (topo>0) :
         noeud=(aster.getvectjev(nchams+(19-len(ncham))*' '+'.N'))
      else :
         noeud=None

      if comp[:1] == ' ':
         comp=(aster.getvectjev(nchams+(19-len(ncham))*' '+'.C'))
         aster.prepcompcham("__DETR__",nchams,ncmp,"NO      ",topo,lgno)
         return post_comp_cham_no(valeurs,noeud,comp)
      else:
         aster.prepcompcham("__DETR__",nchams,ncmp,"NO      ",topo,lgno)
         return post_comp_cham_no(valeurs,noeud)

   def __add__(self, other):
      from SD.sd_nume_equa import sd_nume_equa
      from code_aster.Cata.Syntax import _F
      from code_aster.Cata.Commands.crea_champ import CREA_CHAMP
      # on recupere le type
      __nume_ddl=sd_nume_equa(self.sdj.REFE.get()[1])
      __gd=__nume_ddl.REFN.get()[1].strip()
      __type='NOEU_'+__gd
      # on recupere le nom du maillage
      __nomMaillage=self.sdj.REFE.get()[0].strip()
      # on recupere l'objet du maillage
      __maillage=self.parent.get_concept(__nomMaillage)
      __CHAM = CREA_CHAMP(OPERATION='ASSE',
                          MAILLAGE=__maillage,
                          TYPE_CHAM=__type,
                          INFO=1,
                          ASSE=(_F(CHAM_GD=self,
                                   TOUT='OUI',
                                   CUMUL='OUI',
                                   COEF_R=1.),
                                _F(CHAM_GD=other,
                                   TOUT='OUI',
                                   CUMUL='OUI',
                                   COEF_R=1.),
                               ))
      return __CHAM

# post-traitement :
class post_comp_cham_no :
    def __init__(self, valeurs, noeud=None, comp=None) :
        self.valeurs = valeurs
        self.noeud = noeud
        self.comp = comp

class post_comp_cham_el :
    def __init__(self, valeurs, maille=None, point=None, sous_point=None) :
        self.valeurs = valeurs
        self.maille = maille
        self.point = point
        self.sous_point = sous_point
