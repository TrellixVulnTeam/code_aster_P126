# coding=utf-8
# --------------------------------------------------------------------
# Copyright (C) 1991 - 2019 - EDF R&D - www.code-aster.org
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
:py:class:`TransientGeneralizedResultsContainer` --- Assignment of mesh
************************************************************************
"""

import aster
from libaster import TransientGeneralizedResultsContainer

from ..Utilities import injector


class ExtendedTransientGeneralizedResultsContainer(injector(TransientGeneralizedResultsContainer),
                                                   TransientGeneralizedResultsContainer):
    cata_sdj = "SD.sd_dyna_gene.sd_dyna_gene"

    def FORCE_RELATION (self, inoli=-1):
        """ Returns a 1D numpy array giving the evolution of the forces defined
            as displacement or velocity relationships"""

        if not self.accessible():
            raise AsException("Erreur dans tran_gene.FORCE_RELATION() en PAR_LOT='OUI'")

        inoli = self.__check_input_inoli(inoli)

        nltypes = self.__type_nonl()
        if not(nltypes[inoli-1] in ('RELA_EFFO_DEPL', 'RELA_EFFO_VITE')) :
            dummy = self.INFO_NONL()
            raise AsException("The chosen nonlinearity index (%d) does not"+
                              " correspond to a RELA_EFFO_DEPL or RELA_EFFO_VITE'"+
                              " nonlinearity\nThese are the only nonlinearities that"+
                              " calculate and save a relationship defined force."%(inoli))


        vint = self.VARI_INTERNE(inoli, describe=False)

        #The relationship defined forces are saved in position 2  for 
        #RELA_EFFO_DEPL and RELA_EFFO_VITE nonlinearities
        return vint[:,1]
