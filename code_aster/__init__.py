# coding: utf-8

# Copyright (C) 1991 - 2016  EDF R&D                www.code-aster.org
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

# person_in_charge: mathieu.courtois@edf.fr

# discourage import *
__all__ = []

from .Supervis import executionParameter
from .RunManager import Initializer

# commands must be registered by libCommandSyntax before calling DEBUT.
from .Cata import Commands
from code_aster.Supervis import libCommandSyntax
libCommandSyntax.commandsRegister(Commands.commandStore)

executionParameter.parse_args()

# automatic startup
if executionParameter.get( 'autostart' ):
    Initializer.init( executionParameter.get( 'buildelem' ) )

# import general purpose functions
from .RunManager.saving import saveObjects
from .Utilities import TestCase

import libaster
from libaster import *

# import datastructures, physical quantities and constants
# each package is responsible to export only the relevant objects
from .DataStructures import *
from .DataFields import *
from .Flow import *
from .Function import *
from .Geometry import *
from .LinearAlgebra import *
from .Materials import *
from .Meshes import *
from .Modal import *
from .Modeling import *
from .Results import *
from .Solvers import *
from .Loads import *
from .NonLinear import *
from .Algorithms import *
from .Studies import *
from .Discretization import *
from .Interactions import *
