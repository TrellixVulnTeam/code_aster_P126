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

from ..Objects import Model
from .ExecuteCommand import ExecuteCommand


class ModelAssignment(ExecuteCommand):
    """Command that creates the :class:`~code_aster.Objects.Model` by assigning
    finite elements on a :class:`~code_aster.Objects.Mesh`."""
    command_name = "AFFE_MODELE"

    def create_result(self, keywords):
        """Create the result before calling the *exec* command function
        if needed.
        The result is stored in an internal attribute and will be returned by
        *exec*.

        Arguments:
            keywords (dict): Keywords arguments of user's keywords.
        """
        self._result = Model.create()

    def post_exec(self, keywords):
        """Execute the command.

        Arguments:
            keywords (dict): User's keywords.

        Returns:
            *Model*: Model object.
        """
        self._result.setSupportMesh(keywords["MAILLAGE"])


AFFE_MODELE = ModelAssignment()
