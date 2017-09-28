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

# person_in_charge: mathieu.courtois@edf.fr

import types

import aster

from code_aster.RunManager import LogicalUnitFile


class UniteAster:
    """Transitional class replaced by LogicalUnitFile."""

    def __init__(self):
        pass

    def Libre(self, nom=None, action='RESERVER'):
        """Réserve/associe et retourne une unité libre en y associant, s'il est
        fourni, le fichier 'nom'.
        """
        logical_unit = LogicalUnitFile.new_free(nom)
        return logical_unit.unit

    def Nom(self, ul):
        """Retourne le nom du fichier associé à l'unité 'ul'.
        """
        # ul peut etre un entier Aster
        try:
            unit = ul.valeur
        except AttributeError:
            unit = int(ul)
        logical_unit = LogicalUnitFile.from_number(unit)
        return logical_unit.filename if logical_unit else "fort.{}".format(unit)

    def Unite(self, nom):
        """Retourne l'unité logique associée au fichier `nom`.
        On retourne 0 si le nom n'a pas été trouvé."""
        logical_unit = LogicalUnitFile.from_name(nom)
        return logical_unit.unit if logical_unit else 0

    def Etat(self, ul, **kargs):
        """Transitional function: It is currently only used to free a logical
        unit, with etat='F'.

        Retourne l'état de l'unité si 'etat' n'est pas fourni
        et/ou change son état :
           kargs['etat']  : nouvel état,
           kargs['nom']   : nom du fichier,
           kargs['TYPE']  : type du fichier à ouvrir ASCII/BINARY/LIBRE,
           kargs['ACCES'] : type d'accès NEW/APPEND/OLD (APPEND uniquement en ASCII).
        """
        assert kargs.get('etat') == 'F', 'usage not supported!'
        # ul peut etre un entier Aster
        try:
            unit = ul.valeur
        except:
            unit = int(ul)
        LogicalUnitFile.release_from_number(unit)

    def EtatInit(self, ul=None):
        """Transitional function: Must free each unit previously used manually.

        Remet l'unité 'ul' dans son état initial.
        Si 'ul' est omis, toutes les unités sont remises dans leur état initial.
        """
        raise NotImplementedError("'EtatInit' is not supported anymore, use "
                                  "'LogicalUnit.ReservedUnitUsed' context "
                                  "manager instead.")
