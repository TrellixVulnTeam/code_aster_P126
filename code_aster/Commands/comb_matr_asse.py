# coding: utf-8

# Copyright (C) 1991 - 2018  EDF R&D                www.code-aster.org
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

from ..Objects import AssemblyMatrixDouble, AssemblyMatrixComplex, \
    GeneralizedAssemblyMatrixDouble, GeneralizedAssemblyMatrixComplex
from .ExecuteCommand import ExecuteCommand


class MatrixCombination(ExecuteCommand):
    """Command that creates the
    :class:`~code_aster.Objects.AssemblyMatrixDouble`
    :class:`~code_aster.Objects.AssemblyMatrixComplex`
    :class:`~code_aster.Objects.GeneralizedAssemblyMatrixDouble`
    :class:`~code_aster.Objects.GeneralizedAssemblyMatrixComplex`
    """
    command_name = "COMB_MATR_ASSE"

    def create_result(self, keywords):
        """Initialize the result.

        Arguments:
            keywords (dict): Keywords arguments of user's keywords.
        """
        self._result = None
        if("COMB_C" in keywords):
            if(len(keywords["COMB_C"]) > 0):
                if("MATR_ASSE" in keywords["COMB_C"][0]):
                    matrix = keywords["COMB_C"][0]["MATR_ASSE"]
                    if(type(matrix) in (AssemblyMatrixDouble,
                                        AssemblyMatrixComplex)):
                        self._result = AssemblyMatrixComplex()
                    elif(type(matrix) in (GeneralizedAssemblyMatrixDouble,
                                          GeneralizedAssemblyMatrixComplex)):
                        self._result = GeneralizedAssemblyMatrixComplex()
        elif("COMB_R" in keywords):
            if(len(keywords["COMB_R"]) > 0):
                if("MATR_ASSE" in keywords["COMB_R"][0]):
                    matrix = keywords["COMB_R"][0]["MATR_ASSE"]
                    if(type(matrix) in (AssemblyMatrixDouble,
                                        AssemblyMatrixComplex)):
                        self._result = AssemblyMatrixDouble()
                    elif(type(matrix) in (GeneralizedAssemblyMatrixDouble,
                                          GeneralizedAssemblyMatrixComplex)):
                        self._result = GeneralizedAssemblyMatrixDouble()
        elif("CALC_AMOR_GENE" in keywords):
            self._result = GeneralizedAssemblyMatrixDouble()
        if(self._result is None):
            raise NotImplementedError()


COMB_MATR_ASSE = MatrixCombination.run
