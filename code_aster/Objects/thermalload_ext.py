# coding=utf-8
# --------------------------------------------------------------------
# Copyright (C) 1991 - 2018 - EDF R&D - www.code-aster.org
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
"""
:py:class:`ThermalLoad` --- ThermalLoading definition
*****************************************
"""

import aster
from libaster import ThermalLoad

from ..Utilities import injector


class ExtendedThermalLoad(injector(ThermalLoad), ThermalLoad):
    cata_sdj = "SD.sd_char_ther.sd_char_ther"

    def __getinitargs__(self):
        """Returns the argument required to reinitialize a ThermalLoad
        object during unpickling.
        """
        return (self.getName(), self.getModel())
