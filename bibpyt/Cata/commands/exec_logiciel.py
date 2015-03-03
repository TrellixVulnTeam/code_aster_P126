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
# person_in_charge: j-pierre.lefebvre at edf.fr

def exec_logiciel_prod(self, MAILLAGE, **args):
   if MAILLAGE != None:
      mcf = MAILLAGE[0]
      self.type_sdprod(mcf['MAILLAGE'], maillage_sdaster)
   return None

EXEC_LOGICIEL = MACRO(nom="EXEC_LOGICIEL",
                      op=OPS('Macro.exec_logiciel_ops.exec_logiciel_ops'),
                      sd_prod=exec_logiciel_prod,
                      fr=tr("Exécute un logiciel ou une commande système depuis Aster"),
                      UIinfo={"groupes":("Gestion du travail","Outils-métier",)},

      regles = ( AU_MOINS_UN('LOGICIEL', 'MAILLAGE', 'SALOME'),
                 EXCLUS('MACHINE_DISTANTE','MAILLAGE'),
                 EXCLUS('MAILLAGE','SALOME'),
                 ),

      LOGICIEL = SIMP(statut='f', typ=('Fichier','','Sauvegarde')),
      ARGUMENT = SIMP(statut='f', max='**', typ='TXM'),


      MACHINE_DISTANTE = FACT(statut='f',
        SSH_ADRESSE  = SIMP(statut='o', typ='TXM', val_min=1, val_max=255,
                           fr=tr("Adresse IP ou nom de la machine sur laquelle le logiciel/script sera exécuté via SSH")),
        SSH_LOGIN    = SIMP(statut='f', typ='TXM', val_min=1, val_max=255,
                           fr=tr("Nom d'utilisateur sur la machine distante")),
        SSH_PORT     = SIMP(statut='f', typ='I', val_min=1, val_max=65535, defaut=22,
                           fr=tr("Port SSH de la machien distante")),
      ),


      MAILLAGE = FACT(statut='f',
         FORMAT     = SIMP(statut='o', typ='TXM', into=("GMSH", "GIBI", "SALOME")),
         UNITE_GEOM = SIMP(statut='f', typ='I', val_min=10, val_max=90, defaut=16,
                           fr=tr("Unité logique définissant le fichier (fort.N) contenant les données géométriques (datg)")),
         UNITE      = SIMP(statut='f', typ='I', val_min=10, val_max=90, defaut=19,
                           fr=tr("Unité logique définissant le fichier (fort.N) produit par le mailleur")),
         MAILLAGE   = SIMP(statut='o', typ=CO),
      ),


      SALOME = FACT(statut='f',
           regles=(UN_PARMI('CHEMIN_SCRIPT', 'UNITE_SCRIPT'),
                   PRESENT_PRESENT('NOM_PARA','VALE'),),
         CHEMIN_SCRIPT     = SIMP(statut='f', typ=('Fichier','','Sauvegarde'),
                               fr=tr("Chemin du script Salome")),
         UNITE_SCRIPT      = SIMP(statut='f', typ='I', val_min=80, val_max=99,
                               fr=tr("Unité logique du script Salome")),
         SALOME_HOST       = SIMP(statut='f', typ='TXM', defaut='localhost',
                               fr=tr("Machine sur laquelle tourne Salome")),
         SALOME_PORT       = SIMP(statut='f', typ='I', val_min=2800, val_max=2900, defaut=2810,
                               fr=tr("Port de l'instance Salome (2810 ou supérieur)")),
         SALOME_RUNAPPLI   = SIMP(statut='f', typ='TXM',
                               fr=tr("Chemin vers le script de lancement runAppli de Salome")),
         FICHIERS_ENTREE   = SIMP(statut='f', typ='TXM', validators=NoRepeat(),max='**',
                               fr=tr("Liste des fichiers d'entrée du script Salome")),
         FICHIERS_SORTIE   = SIMP(statut='f', typ='TXM', validators=NoRepeat(),max='**',
                               fr=tr("Liste des fichiers générés par le script Salome")),
         NOM_PARA          = SIMP(statut='f',typ='TXM',max='**',validators=NoRepeat(),
                               fr=tr("Liste des noms des paramètres à modifier dans le script Salome")),
         VALE              = SIMP(statut='f',typ='TXM',max='**',
                               fr=tr("Valeur des paramètres à) modifier dans le script Salome")),
      ),

      CODE_RETOUR_MAXI = SIMP(statut='f', typ='I', defaut=0, val_min=-1,
                              fr=tr("Valeur maximale du code retour toléré (-1 pour l'ignorer)")),

      INFO     = SIMP(statut='f', typ='I', defaut=2, into=(1,2),),
)
