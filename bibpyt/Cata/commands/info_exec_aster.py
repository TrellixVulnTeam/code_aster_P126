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
# person_in_charge: j-pierre.lefebvre at edf.fr
INFO_EXEC_ASTER=OPER(nom="INFO_EXEC_ASTER",op=35,sd_prod=table_sdaster,
                    fr=tr("Récupère différentes informations propres à l'exécution en cours"),
                    reentrant='n',
                    UIinfo={"groupes":("Gestion du travail",)},

         regles=(),
         LISTE_INFO     =SIMP(statut='o',typ='TXM',validators=NoRepeat(),max=3,
                              into=("CPU_RESTANT","UNITE_LIBRE","ETAT_UNITE"),),
         b_etat_unite   =BLOC(condition = "au_moins_un(LISTE_INFO, 'ETAT_UNITE')",
            regles=(UN_PARMI('UNITE','FICHIER'),),
            UNITE          =SIMP(statut='f',typ='I',val_min=1,val_max=99,max=1,
                                 fr=tr("Unité logique dont on veut obtenir l'état"),),
            FICHIER        =SIMP(statut='f',typ=('Fichier','','Sauvegarde'),validators=LongStr(1,255),
                                 fr=tr("Nom du fichier dont on veut obtenir l'état"),),
         ),
         TITRE          =SIMP(statut='f',typ='TXM',max='**'),
         INFO           =SIMP(statut='f',typ='I',defaut=1,into=(1,2) ),
)  ;
