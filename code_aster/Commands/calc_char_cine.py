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

from ..Objects import FieldOnNodesDouble
from .ExecuteCommand import ExecuteCommand


class KinematicsLoadComputation(ExecuteCommand):
    """Command that computes :class:`~code_aster.Objects.KinematicsLoad`."""
    command_name = "CALC_CHAR_CINE"

    def create_result(self, keywords):
        """Initialize the result.

        Arguments:
            keywords (dict): Keywords arguments of user's keywords.
        """
        if keywords['CHAR_CINE'][0].getType() == 'CHAR_CINE_MECA':
            self._result = FieldOnNodesDouble()
        elif keywords['CHAR_CINE'][0].getType() == 'CHAR_CINE_THER':
            self._result = FieldOnNodesDouble()
        else:
            raise NotImplementedError("Not implemented yet")


CALC_CHAR_CINE = KinematicsLoadComputation.run
