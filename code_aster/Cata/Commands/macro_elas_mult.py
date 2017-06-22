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

# person_in_charge: natacha.bereux at edf.fr


from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


def macro_elas_mult_prod(self,NUME_DDL,CAS_CHARGE,**args ):
  if NUME_DDL is not None and NUME_DDL.is_typco():
    self.type_sdprod(NUME_DDL,nume_ddl_sdaster)
  if CAS_CHARGE[0]['NOM_CAS']      != None : return mult_elas
  if CAS_CHARGE[0]['MODE_FOURIER'] != None : return fourier_elas
  raise AsException("type de concept resultat non prevu")

MACRO_ELAS_MULT=MACRO(nom="MACRO_ELAS_MULT",
                      op=OPS('Macro.macro_elas_mult_ops.macro_elas_mult_ops'),
                      sd_prod=macro_elas_mult_prod,
                      reentrant='f',
                      fr=tr("Calculer les réponses statiques linéaires pour différents cas "
                           "de charges ou modes de Fourier"),
         regles=(UN_PARMI('CHAR_MECA_GLOBAL','LIAISON_DISCRET', ),),
         reuse=SIMP(statut='c', typ=CO),
         MODELE          =SIMP(statut='o',typ=modele_sdaster),
         CHAM_MATER      =SIMP(statut='f',typ=cham_mater),
         CARA_ELEM       =SIMP(statut='f',typ=cara_elem),
         NUME_DDL        =SIMP(statut='f',typ=(nume_ddl_sdaster,CO)),
         CHAR_MECA_GLOBAL=SIMP(statut='f',typ=(char_meca),validators=NoRepeat(),max='**'),
         LIAISON_DISCRET =SIMP(statut='f',typ='TXM',into=("OUI",)),
         CAS_CHARGE      =FACT(statut='o',max='**',
           regles=(UN_PARMI('NOM_CAS','MODE_FOURIER'),
                   UN_PARMI('CHAR_MECA','VECT_ASSE'),),
           NOM_CAS         =SIMP(statut='f',typ='TXM' ),
           MODE_FOURIER    =SIMP(statut='f',typ='I' ),
           TYPE_MODE       =SIMP(statut='f',typ='TXM',defaut="SYME",into=("SYME","ANTI","TOUS") ),
           CHAR_MECA       =SIMP(statut='f',typ=(char_meca),validators=NoRepeat(),max='**'),
           OPTION          =SIMP(statut='f',typ='TXM',into=("SIEF_ELGA","SANS"),defaut="SIEF_ELGA",max=1,
                                 fr=tr("Contraintes aux points de Gauss."),),
           SOUS_TITRE      =SIMP(statut='f',typ='TXM'),
           VECT_ASSE       =SIMP(statut='f',typ=cham_no_sdaster),
         ),
         SOLVEUR         =FACT(statut='d',
           METHODE         =SIMP(statut='f',typ='TXM',defaut="MULT_FRONT",into=("MULT_FRONT","LDLT") ),
           b_mult_front    = BLOC ( condition = """equal_to("METHODE", 'MULT_FRONT') """,
                                    fr=tr("Paramètres de la méthode multi frontale"),
             RENUM           =SIMP(statut='f',typ='TXM',defaut="METIS",into=("MD","MDA","METIS") ),
           ),
           b_ldlt          =BLOC(condition = """equal_to("METHODE", 'LDLT') """,fr=tr("Paramètres de la méthode LDLT"),
             RENUM           =SIMP(statut='f',typ='TXM',defaut="RCMK",into=("RCMK",) ),
            ),
           b_ldlt_mult     =BLOC(condition = """equal_to("METHODE", 'LDLT') or equal_to("METHODE", 'MULT_FRONT') """,
                                   fr=tr("Paramètres relatifs à la non inversibilité de la matrice à factorise"),
             NPREC           =SIMP(statut='f',typ='I',defaut= 8 ),
             STOP_SINGULIER  =SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON") ),
           ),
         ),
         INFO            =SIMP(statut='f',typ='I',defaut= 1,into=(1,2)),
         TITRE           =SIMP(statut='f',typ='TXM'),
)  ;
