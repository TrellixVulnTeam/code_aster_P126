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
:py:class:`Function` --- Function object
****************************************
"""

from libaster import Formula

from ..Utilities import deprecated, force_list, injector


class ExtendedFormula(injector(Formula), Formula):
    cata_sdj = "SD.sd_fonction.sd_formule"

    def __call__(self, *val):
        """Evaluate the formula with the given variables values.

        Arguments:
            val (list[float]): List of the values of the variables.

        Returns:
            float/complex: Value of the formula for these values.
        """
        result = self.evaluate(force_list(val))
        if self.getType() == "FORMULE_C":
            result = complex(*result)
        else:
            result = result[0]
        return result

    @property
    @deprecated(help="Use 'getVariables()' instead.")
    def nompar(self):
        """Return the variables names.

        *Deprecated:* Use `getVariables()` instead. """
        return self.getVariables()

    def Parametres(self):
        """
        Retourne un dictionnaire contenant les parametres de la fonction ;
        le type jeveux (FONCTION, FONCT_C, NAPPE) n'est pas retourne,
        le dictionnaire peut ainsi etre fourni a CALC_FONC_INTERP tel quel.
        """
        from Utilitai.Utmess import UTMESS
        prol = self.sdj.PROL.get()
        if prol == None:
            objev = '%-19s.PROL' % self.get_name()
            UTMESS('F', 'SDVERI_2', valk=[objev])
        dico = {
            'INTERPOL': ['LIN', 'LIN'],
            'NOM_PARA': [i.strip() for i in self.sdj.NOVA.get()],
            'NOM_RESU': prol[3][0:16].strip(),
            'PROL_DROITE': "EXCLU",
            'PROL_GAUCHE': "EXCLU",
        }
        return dico
