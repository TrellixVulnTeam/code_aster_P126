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
"""
:py:class:`DataStructure` --- Base of all objects
*************************************************
"""


from libaster import DataStructure
from ..Utilities import deprecated, import_object, injector


class ExtendedDataStructure(injector(DataStructure), DataStructure):
    """This class defines the base class of the DataStructures.
    """
    cata_sdj = None
    ptr_class_sdj = None
    ptr_sdj = None

    @property
    def sdj(self):
        """Return the DataStructure catalog."""
        if self.ptr_sdj is None:
            cata_sdj = getattr(self, 'cata_sdj', None)
            assert cata_sdj, ("The attribute 'cata_sdj' must be defined in "
                              "the class {}".format(self.__class__.__name__))
            if self.ptr_class_sdj is None:
                self.ptr_class_sdj = import_object(cata_sdj)
            self.ptr_sdj = self.ptr_class_sdj(nomj=self.getName())
        return self.ptr_sdj

    # transitional functions - to remove later
    @staticmethod
    @deprecated(False)
    def accessible():
        return True

    @deprecated(help="Use 'getName()' instead.")
    def get_name(self):
        return self.getName()

    @property
    @deprecated(help="Use 'getName()' instead.")
    def nom(self):
        return self.getName()
