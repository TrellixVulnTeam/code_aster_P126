# coding: utf-8

# Copyright (C) 1991 - 2020  EDF R&D                www.code-aster.org
#
# This file is part of Code_Aster.
#
# Code_Aster is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
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

from ..Objects import EvolutiveThermalLoad
from ..Supervis.ExecuteCommand import ExecuteCommand


class TherNonLineMo(ExecuteCommand):
    """Command that creates the :class:`~code_aster.Objects.EvolutiveThermalLoad` by assigning
    finite elements on a :class:`~code_aster.Objects.EvolutiveThermalLoad`."""
    command_name = "THER_NON_LINE_MO"

    def create_result(self, keywords):
        """Initialize the result.

        Arguments:
            keywords (dict): Keywords arguments of user's keywords.
        """
        self._result = EvolutiveThermalLoad()

    def post_exec(self, keywords):
        """Execute the command.

        Arguments:
            keywords (dict): User's keywords.
        """
        if("reuse" in keywords):
            self._result.update()
        else:
            self._result.appendModelOnAllRanks(keywords["MODELE"])
            self._result.update()


THER_NON_LINE_MO = TherNonLineMo.run
