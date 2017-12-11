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

from ..Objects import DOFNumbering
from ..Supervis import logger
from .ExecuteCommand import ExecuteCommand


class NumberingCreation(ExecuteCommand):
    """Command that creates a :class:`~code_aster.Objects.DOFNumbering`."""
    command_name = "NUME_DDL"

    def create_result(self, keywords):
        """Initialize the result.

        Arguments:
            keywords (dict): Keywords arguments of user's keywords.
        """
        self._result = DOFNumbering()
        
    def post_exec(self, keywords):
        """Store references to ElementaryMatrix objects.

        Arguments:
            keywords (dict): Keywords arguments of user's keywords, changed
                in place.
        """
        if keywords.has_key('MODELE'):
            self._result.setSupportModel(keywords['MODELE'])
        else:
            self._result.setSupportModel(keywords['MATR_RIGI'][0].getSupportModel())


NUME_DDL = NumberingCreation.run
