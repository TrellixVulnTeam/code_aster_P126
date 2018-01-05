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

# person_in_charge: 

from ..Objects import PCFieldOnMeshDouble, FieldOnNodesDouble, FieldOnElementsDouble
from .ExecuteCommand import ExecuteCommand


class FieldReader(ExecuteCommand):
    """Command that creates fields that may be
    :class:`~code_aster.Objects.FieldOnElementsDouble` or
    :class:`~code_aster.Objects.FieldOnNodesDouble` or
    :class:`~code_aster.Objects.PCFieldOnMeshDouble`."""
    command_name = "LIRE_CHAMP"

    def create_result(self, keywords):
        """Initialize the result.

        Arguments:
            keywords (dict): Keywords arguments of user's keywords.
        """
        location = keywords["TYPE_CHAM"][:5]
        typ = keywords["TYPE_CHAM"][10:]
        if (typ != "R" and typ != "F") or location not in ("CART_", "NOEU_", "ELGA_"):
            raise NotImplementedError("Type of field {0!r} not yet supported"
                                      .format(keywords["TYPE_CHAM"]))
        if location == "CART_":
            if keywords.has_key("MAILLAGE"):
                mesh = keywords["MAILLAGE"]
            else:
                mesh = keywords["MODELE"].getSupportMesh()
            self._result = PCFieldOnMeshDouble(mesh)
        elif location == "NOEU_":
            self._result = FieldOnNodesDouble()
        else:
            # ELGA_
            self._result = FieldOnElementsDouble()



LIRE_CHAMP = FieldReader.run
