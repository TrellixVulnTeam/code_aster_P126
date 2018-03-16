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
:py:class:`GeneralizedAssemblyMatrixDouble` --- Generalized Assembly matrix
****************************************************
"""

from libaster import GeneralizedAssemblyMatrixDouble

from ..Utilities import injector

_orig_getType = GeneralizedAssemblyMatrixDouble.getType


class ExtendedGeneralizedAssemblyMatrixDouble(injector(GeneralizedAssemblyMatrixDouble),
                                   GeneralizedAssemblyMatrixDouble):
    cata_sdj = "SD.sd_matr_asse_gene.sd_matr_asse_gene"

    def EXTR_MATR(self, sparse=False):
        """Retourne les valeurs de la matrice dans un format numpy
        Si sparse=True, la valeur de retour est un triplet de numpy.array.
        Attributs retourne si sparse=False:
        - valeurs : numpy.array contenant les valeurs
        ou si sparse=True:
        - valeurs : numpy.array contenant les valeurs
        - lignes : numpy.array numpy.array contenant les indices des lignes
        - colonnes : numpy.array contenant les indices des colonnes
        - dim : int qui donne la dimension de la matrice
        """
        import numpy as NP
        if not self.accessible():
            raise Accas.AsException(
                "Erreur dans matr_asse_gene.EXTR_MATR en PAR_LOT='OUI'")
        refa = NP.array(self.sdj.REFA.get())
        ma = refa[0]
        nu = refa[1]
        stock = "diag" if self.sdj.DESC.get()[2]==1 else "full"
        valm = self.sdj.VALM.get()
        sym = len(valm) == 1
        if not sym:
            raise Accas.AsException(
                "Not implemented for non symetric matrix")
        dim = len(valm[1]) if stock=="diag" else int((-1+NP.sqrt(1+8*len(valm[1])))/2)
        if stock=="diag":
            return NP.diag(valm[1])
        else:
            def make_sym_matrix(n,vals,ntype):
                m = NP.zeros([n,n], dtype=ntype)
                xs,ys = NP.triu_indices(n)
                m[xs,ys] = vals
                m[ys,xs] = vals
                return m
            triang_sup = NP.array(valm[1])
            if type(valm[1][0]) == complex:
                ntype = complex
            else:
                ntype = float
            return make_sym_matrix(dim,triang_sup,ntype)
