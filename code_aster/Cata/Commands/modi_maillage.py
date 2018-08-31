# coding=utf-8
# --------------------------------------------------------------------
# Copyright (C) 1991 - 2018 - EDF R&D - www.code-aster.org
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

# person_in_charge: jacques.pellet at edf.fr
from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


MODI_MAILLAGE=OPER(nom="MODI_MAILLAGE",op= 154,sd_prod=maillage_sdaster,
                   fr=tr("Effectuer des modifications sur un maillage existant: réorienter des mailles servant,"
                      " à l'application d'une pression, à la modélisation du contact,..."),
                   reentrant='o:MAILLAGE',
      regles=(AU_MOINS_UN('ORIE_FISSURE','DEFORME','ORIE_PEAU_2D',
                       'ORIE_PEAU_3D','ORIE_NORM_COQUE','MODI_MAILLE',
                       'TRANSLATION','ROTATION','MODI_BASE','ECHELLE',
                       'ORIE_SHB','SYMETRIE','ORIE_LIGNE','ABSC_CURV'),
              PRESENT_ABSENT('ORIE_FISSURE','DEFORME','ORIE_PEAU_2D',
                       'ORIE_PEAU_3D','ORIE_NORM_COQUE','MODI_MAILLE',
                       'ORIE_LIGNE'),
              PRESENT_ABSENT('DEFORME','ORIE_FISSURE','ORIE_PEAU_2D',
                       'ORIE_PEAU_3D','ORIE_NORM_COQUE','MODI_MAILLE',
                       'ORIE_LIGNE'),
              PRESENT_ABSENT('ORIE_FISSURE','DEFORME','ORIE_PEAU_2D',
                       'ORIE_PEAU_3D','ORIE_NORM_COQUE','MODI_MAILLE',
                       'ORIE_LIGNE'),
              PRESENT_ABSENT('ORIE_PEAU_2D','ORIE_FISSURE','DEFORME',
                       'ORIE_PEAU_3D','ORIE_NORM_COQUE','MODI_MAILLE',
                       'ORIE_LIGNE'),
              PRESENT_ABSENT('ORIE_PEAU_3D','ORIE_FISSURE','DEFORME',
                       'ORIE_PEAU_2D','MODI_MAILLE',),
              PRESENT_ABSENT('ORIE_NORM_COQUE','ORIE_FISSURE','DEFORME',
                       'ORIE_PEAU_2D','MODI_MAILLE','ORIE_LIGNE'),
              PRESENT_ABSENT('ORIE_FISSURE','DEFORME','ORIE_PEAU_2D',
                       'ORIE_PEAU_3D','ORIE_NORM_COQUE','MODI_MAILLE','ORIE_LIGNE'),
              PRESENT_ABSENT('MODI_MAILLE','ORIE_FISSURE','DEFORME','ORIE_PEAU_2D',
                       'ORIE_PEAU_3D','ORIE_NORM_COQUE','ORIE_LIGNE'),
              EXCLUS('ROTATION','MODI_BASE'),
              EXCLUS('SYMETRIE','ROTATION'),
              EXCLUS('SYMETRIE','TRANSLATION'),
              EXCLUS('SYMETRIE','MODI_BASE'),
              EXCLUS('SYMETRIE','ECHELLE'),
              ),
         reuse=SIMP(statut='c', typ=CO),
         MAILLAGE        =SIMP(statut='o',typ=maillage_sdaster ),
         ORIE_FISSURE    =FACT(statut='f',
           GROUP_MA        =SIMP(statut='o',typ=grma,validators=NoRepeat(),max='**'),
         ),
         DEFORME         =FACT(statut='f',
           OPTION          =SIMP(statut='o',typ='TXM',into=("TRAN",) ),
           regles=UN_PARMI('DEPL','ALEA'),
           DEPL            =SIMP(statut='f',typ=cham_no_sdaster ),
           ALEA            =SIMP(statut='f',typ='R' ),
         ),
         ORIE_PEAU_2D    =FACT(statut='f',max='**',
           GROUP_MA        =SIMP(statut='o',typ=grma,validators=NoRepeat(),max='**'),
           GROUP_MA_SURF   =SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
         ),
         ORIE_PEAU_3D    =FACT(statut='f',max='**',
           GROUP_MA        =SIMP(statut='o',typ=grma,validators=NoRepeat(),max='**'),
           GROUP_MA_VOLU   =SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
         ),
         ORIE_SHB       =FACT(statut='f',max=1,
           GROUP_MA        =SIMP(statut='o',typ=grma,validators=NoRepeat(),max='**'),
         ),
         ORIE_NORM_COQUE =FACT(statut='f',max='**',
           GROUP_MA        =SIMP(statut='o',typ=grma,validators=NoRepeat(),max='**'),
           VECT_NORM       =SIMP(statut='f',typ='R',max=3),
           b_vect_norm     =BLOC(condition = """exists("VECT_NORM")""",
             regles=UN_PARMI('NOEUD','GROUP_NO'),
             NOEUD           =SIMP(statut='c',typ=no),
             GROUP_NO        =SIMP(statut='f',typ=grno),
           ),
         ),
         ORIE_LIGNE =FACT(statut='f',max='**',
           GROUP_MA        =SIMP(statut='o',typ=grma,validators=NoRepeat(),max='**'),
           VECT_TANG       =SIMP(statut='f',typ='R',max=3),
           b_vect_tang     =BLOC(condition = """exists("VECT_TANG")""",
             regles=UN_PARMI('NOEUD','GROUP_NO'),
             NOEUD           =SIMP(statut='c',typ=no),
             GROUP_NO        =SIMP(statut='f',typ=grno),
           ),
         ),
         MODI_MAILLE     =FACT(statut='f',max=1,
           regles=(AU_MOINS_UN('GROUP_MA_FOND','MAILLE_FOND','GROUP_NO_FOND','NOEUD_FOND'),),
           OPTION          =SIMP(statut='o',typ='TXM',into=("NOEUD_QUART",) ),
           GROUP_MA_FOND   =SIMP(statut='f',typ=grma,max=1),
           MAILLE_FOND     =SIMP(statut='c',typ=ma  ,max=1),
           GROUP_NO_FOND   =SIMP(statut='f',typ=grno,max=1),
           NOEUD_FOND      =SIMP(statut='c',typ=no  ,max=1),
         ),
         MODI_BASE       =FACT(statut='f',
           VECT_X          =SIMP(statut='o',typ='R',min=2,max=3),
           VECT_Y          =SIMP(statut='f',typ='R',min=2,max=3),
         ),
         ECHELLE         =SIMP(statut='f',typ='R',),
         TRANSLATION     =SIMP(statut='f',typ='R',min=2,max=3),
         ROTATION        =FACT(statut='f',max='**',
           POIN_1           =SIMP(statut='o',typ='R',min=2,max=3),
           ANGLE            =SIMP(statut='f',typ='R',defaut= 0.E+0 ),
           regles=(EXCLUS('DIR','POIN_2'),),
           POIN_2           =SIMP(statut='f',typ='R',min=2,max=3),
           DIR              =SIMP(statut='f',typ='R',min=2,max=3),
         ),
         SYMETRIE        =FACT(statut='f',max=1,
                          fr = tr("Symétrie du maillage par rapport à un plan en 3D ou à une droite en 2D."),
           POINT           =SIMP(statut='o',typ='R',min=2,max=3,
                            fr=tr("Point appartenant à la droite ou au plan.")),
           AXE_1           =SIMP(statut='o',typ='R',min=2,max=3,
                            fr=tr("Vecteur directeur de la droite ou 1er vecteur appartenant au plan.")),
           AXE_2           =SIMP(statut='f',typ='R',min=3,max=3,
                            fr=tr("2nd vecteur appartenant du plan.")),
         ),
         ABSC_CURV       =FACT(statut='f',max=1,
           regles=(AU_MOINS_UN('TOUT','GROUP_MA','MAILLE',),
                   UN_PARMI('GROUP_NO_ORIG','NOEUD_ORIG',),
                   EXCLUS('TOUT','GROUP_MA'),
                   EXCLUS('TOUT','MAILLE'),),
           TOUT            =SIMP(statut='f',typ='TXM',into=("OUI",) ),
           GROUP_MA        =SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
           MAILLE          =SIMP(statut='c',typ=ma,validators=NoRepeat(),max='**'),
           GROUP_NO_ORIG   =SIMP(statut='f',typ=grno,max=1),
           NOEUD_ORIG      =SIMP(statut='c',typ=no,max=1),
         ),
         INFO            =SIMP(statut='f',typ='I',defaut= 1,into=( 1 , 2) ),
         translation={
            "MODI_MAILLAGE": "Modify a mesh",
         }

)  ;
