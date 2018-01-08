# coding: utf-8

# Copyright (C) 1991 - 2017  EDF R&D                www.code-aster.org
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

from ..Objects import (EvolutiveLoad, EvolutiveThermalLoad,
                       NonLinearEvolutionContainer,
                       LinearDisplacementEvolutionContainer,
                       FourierElasContainer, MultElasContainer,
                       MechanicalModeContainer)
from .ExecuteCommand import ExecuteCommand


class ResultCreator(ExecuteCommand):
    """Command that creates evolutive results."""
    command_name = "CREA_RESU"

    def create_result(self, keywords):
        """Initialize the result.

        Arguments:
            keywords (dict): Keywords arguments of user's keywords.
        """
        typ = keywords["TYPE_RESU"]
        if typ == "EVOL_CHAR":
            self._result = EvolutiveLoad()
        elif typ == "EVOL_THER":
            self._result = EvolutiveThermalLoad()
        elif typ == "EVOL_NOLI":
            self._result = NonLinearEvolutionContainer()
        elif typ == "EVOL_ELAS":
            self._result = LinearDisplacementEvolutionContainer()
        elif typ == "FOURIER_ELAS":
            self._result = FourierElasContainer()
        elif typ == "MULT_ELAS":
            self._result = MultElasContainer()
        elif typ == "MODE_MECA":
            self._result = MechanicalModeContainer()
        else:
            raise NotImplementedError("Type of result {0!r} not yet "
                                      "implemented".format(typ))

    def post_exec(self, keywords):
        """Execute the command.

        Arguments:
            keywords (dict): User's keywords.
        """
        self._result.update()


CREA_RESU = ResultCreator.run
