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

from ..Objects import Formula
from ..Utilities import force_list
from .ExecuteCommand import ExecuteCommand


class FormulaDefinition(ExecuteCommand):
    """Execute legacy operator FORMULE."""
    command_name = "FORMULE"
    command_op = 5

    def __init__(self, command_name=None, command_op=None):
        """Initialization"""
        super(FormulaDefinition, self).__init__(command_name, command_op)
        self._ctxt = self.initial_context()

    @staticmethod
    def initial_context():
        """Returns `initial` Python context (independent of Stage and Command)

        Returns:
            dict: pairs of name per corresponding Python instance.
        """
        import __builtin__
        import math
        context = {}
        context.update(__builtin__.__dict__)
        for func in dir(math):
            if not func.startswith('_'):
                context[func] = getattr(math, func)
        return context

    def adapt_syntax(self, keywords):
        """Adapt syntax to store the evaluation context.

        Arguments:
            keywords (dict): Keywords arguments of user's keywords, changed
                in place.
        """
        # add in _ctxt all keywords but VALE, VALE_C, NOM_PARA.
        for key in keywords.iterkeys():
            if key not in ('VALE', 'VALE_C', 'NOM_PARA'):
                self._ctxt[key] = keywords.pop(key)

    def create_result(self, keywords):
        """Initialize the result.

        Arguments:
            keywords (dict): Keywords arguments of user's keywords.
        """
        self._result = Formula.create()
        if keywords.get('VALE_C'):
            self._result.setComplex()

    def exec_(self, keywords):
        """Execute the command.

        Arguments:
            keywords (dict): User's keywords.
        """
        self._result.setVariables(force_list(keywords['NOM_PARA']))
        expr = keywords.get('VALE') or keywords.get('VALE_C')
        self._result.setExpression("".join(expr.splitlines()))
        self._result.setContext(self._ctxt)
        # the context is hold by the Formula
        self._ctxt = None


FORMULE = FormulaDefinition.run
