# -*- coding: iso-8859-1 -*-
# person_in_charge: mathieu.courtois at edf.fr
#            CONFIGURATION MANAGEMENT OF EDF VERSION
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
#
#
# ======================================================================


""" Ce module contient la classe de definition SIMP
    qui permet de sp�cifier les caract�ristiques des mots cl�s simples
"""

import types

import N_ENTITE
import N_MCSIMP
from strfunc import ufmt

class SIMP(N_ENTITE.ENTITE):
   """
    Classe pour definir un mot cle simple

    Cette classe a deux attributs de classe

    - class_instance qui indique la classe qui devra etre utilis�e
            pour cr�er l'objet qui servira � controler la conformit� d'un
            mot-cl� simple avec sa d�finition

    - label qui indique la nature de l'objet de d�finition (ici, SIMP)

   """
   class_instance = N_MCSIMP.MCSIMP
   label = 'SIMP'

   def __init__(self,typ,fr="",ang="",statut='f',into=None,defaut=None,
                     min=1,max=1,homo=1,position ='local',
                     val_min = '**',val_max='**',docu="",validators=None):

      """
          Un mot-cl� simple est caract�ris� par les attributs suivants :

          - type : cet attribut est obligatoire et indique le type de valeur attendue

          - fr   :

          - ang :

          - statut :

          - into   :

          - defaut :

          - min

          - max

          - homo

          - position

          - val_min

          - val_max

          - docu
      """
      N_ENTITE.ENTITE.__init__(self,validators)
      # Initialisation des attributs
      if type(typ) == types.TupleType :
          self.type=typ
      else :
          self.type=(typ,)
      self.fr=fr
      self.ang=ang
      self.statut=statut
      self.into=into
      self.defaut=defaut
      self.min=min
      self.max=max
      self.homo=homo
      self.position = position
      self.val_min=val_min
      self.val_max=val_max
      self.docu = docu

   def verif_cata(self):
      """
          Cette methode sert � valider les attributs de l'objet de d�finition
          de la classe SIMP
      """
      self.check_min_max()
      self.check_fr()
      self.check_statut()
      self.check_homo()
      self.check_into()
      self.check_position()
      self.check_validators()

   def __call__(self,val,nom,parent=None):
      """
          Construit un objet mot cle simple (MCSIMP) a partir de sa definition (self)
          de sa valeur (val), de son nom (nom) et de son parent dans l arboresence (parent)
      """
      return self.class_instance(nom=nom,definition=self,val=val,parent=parent)
