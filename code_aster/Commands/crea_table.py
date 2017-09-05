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
from code_aster import Commands, Table
from code_aster.Cata import checkSyntax
from code_aster.RunManager.AsterFortran import python_execop
from code_aster.Supervis.libCommandSyntax import CommandSyntax


def CREA_TABLE(**kwargs):
    """Create a Table object."""
    checkSyntax(Commands.CREA_TABLE, kwargs)

    returnTable = Table.create()
    name = returnTable.getName()
    syntax = CommandSyntax("CREA_TABLE")

    # self.getType()
    syntax.setResult(name, "TABLE")

    syntax.define(kwargs)
    numOp = 36
    python_execop(numOp)
    syntax.free()
    return returnTable
