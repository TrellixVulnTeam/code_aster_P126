# coding: utf-8

# Copyright (C) 1991 - 2018  EDF R&D                www.code-aster.org
#
# This file is part of Code_Aster.
#
# Code_Aster is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# Code_Aster is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Code_Aster.  If not, see <http://www.gnu.org/licenses/>.

# person_in_charge: nicolas.sellenet@edf.fr

from ..Objects import MatchingMeshes, FieldOnElementsDouble
from .ExecuteCommand import ExecuteCommand


class FieldProjector(ExecuteCommand):
    """Command that allows to project fields."""
    command_name = "PROJ_CHAMP"

    def create_result(self, keywords):
        """Initialize the result.

        Arguments:
            keywords (dict): Keywords arguments of user's keywords.
        """
        if keywords.has_key("RESULTAT"):
            if keywords["RESULTAT"].getType() == "EVOL_ELAS":
                self._result = type(keywords["RESULTAT"])()
            else:
                self._result = type(keywords["RESULTAT"])()
        elif keywords.has_key("CHAM_GD"):
            self._result = FieldOnElementsDouble()
        else:
            self._result = MatchingMeshes()

    def post_exec(self, keywords):
        """Execute the command.

        Arguments:
            keywords (dict): User's keywords.
        """
        if keywords.has_key("RESULTAT"):
            self._result.update()
            if keywords.has_key("MODELE_2"):
                self._result.appendModelOnAllRanks(keywords["MODELE_2"])
        elif keywords.has_key("CHAM_GD"):
            pass
        else:
            if keywords.has_key("MAILLAGE_1"):
                self._result.setFirstMesh(keywords["MAILLAGE_1"])



PROJ_CHAMP = FieldProjector.run
