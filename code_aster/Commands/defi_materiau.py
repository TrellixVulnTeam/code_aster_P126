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

from ..Objects import Material, GeneralMaterialBehaviour, Table, Function
from ..Objects import Surface, Formula, MaterialBehaviour
from code_aster.Cata.Language.SyntaxObjects import _F
from .ExecuteCommand import ExecuteCommand
import numpy


class MaterialDefinition(ExecuteCommand):
    """Definition of the material properties.
    Returns a :class:`~code_aster.Objects.Material` object.
    """
    command_name = "DEFI_MATERIAU"

    def create_result(self, _):
        """Initialize the :class:`~code_aster.Objects.Material`.

        Arguments:
            keywords (dict): Keywords arguments of user's keywords.
        """
        self._result = Material()

    def exec_(self, keywords):
        """Execute the command.

        Arguments:
            keywords (dict): User's keywords.
        """
        materByName = self._buildInstance(keywords)
        classByName = MaterialDefinition._byKeyword()
        for fkwName, fkw in keywords.iteritems():
            # only see factor keyword
            if not isinstance(fkw, dict):
                continue
            if materByName.has_key(fkwName):
                matBehav = materByName[fkwName]
                klassName = matBehav.getName()
            else:
                klass = classByName.get(fkwName)
                if not klass:
                    raise NotImplementedError("Unsupported behaviour: '{0}'"
                                            .format(fkwName))
                matBehav = klass()
                klassName = klass.__name__
            for skwName, skw in fkw.iteritems():
                if skwName == "ORDRE_PARAM":
                    matBehav.setSortedListParameters(list(skw))
                    continue
                iName = skwName.capitalize()
                if fkwName in ("MFRONT", "UMAT"):
                    matBehav.setVectorOfDoubleValue(iName, list(skw))
                    continue
                if fkwName in ("MFRONT_FO", "UMAT_FO"):
                    matBehav.setVectorOfFunctionValue(iName, list(skw))
                    continue
                if type(skw) in (float, int, numpy.float64):
                    cRet = matBehav.setDoubleValue(iName, float(skw))
                    if not cRet:
                        print ValueError("Can not assign keyword '{1}'/'{0}' "
                                         "(as '{3}'/'{2}') "
                                         .format(skwName, fkwName, iName,
                                                 klassName))
                elif type(skw) is complex:
                    cRet = matBehav.setComplexValue(iName, skw)
                    if not cRet:
                        print ValueError("Can not assign keyword '{1}'/'{0}' "
                                         "(as '{3}'/'{2}') "
                                         .format(skwName, fkwName, iName,
                                                 klassName))
                elif type(skw) is str:
                    cRet = matBehav.setStringValue(iName, skw)
                elif type(skw) is Table:
                    cRet = matBehav.setTableValue(iName, skw)
                elif type(skw) is Function:
                    cRet = matBehav.setFunctionValue(iName, skw)
                elif type(skw) is Surface:
                    cRet = matBehav.setSurfaceValue(iName, skw)
                elif type(skw) is Formula:
                    cRet = matBehav.setFormulaValue(iName, skw)
                elif type(skw) is tuple and type(skw[0]) is str:
                    if skw[0] == "RI":
                        comp = complex(skw[1], skw[2])
                        cRet = matBehav.setComplexValue(iName, comp)
                    else:
                        raise NotImplementedError("Unsupported type for keyword: "
                                                "{0} <{1}>"
                                                .format(skwName, type(skw)))
                else:
                    raise NotImplementedError("Unsupported type for keyword: "
                                              "{0} <{1}>"
                                              .format(skwName, type(skw)))
                if not cRet:
                    raise NotImplementedError("Unsupported keyword: "
                                              "{0}"
                                              .format(iName))
            self._result.addMaterialBehaviour(matBehav)

        self._result.build()

    def _buildInstance(self, keywords):
        """Build a dict with MaterialBehaviour

        Returns:
            dict: Behaviour instances from keywords of command.
        """

        objects = {}
        for materName, skws in keywords.iteritems():
            keyword = self._cata.getKeyword(materName, keywords)
            asterNewName = ""
            if materName[-2:] == "FO": asterNewName = materName[:-3]
            mater = MaterialBehaviour(materName, asterNewName)
            if isinstance(skws, _F):
                for kwName, kwValue in skws.iteritems():
                    curType = type(kwValue)
                    mandatory = False
                    if curType in (float, int):
                        mater.addNewDoubleProperty(kwName, mandatory)
                    elif curType is complex:
                        mater.addNewComplexProperty(kwName, mandatory)
                    elif curType is str:
                        mater.addNewStringProperty(kwName, mandatory)
                    elif isinstance(kwValue, Function) or\
                            isinstance(kwValue, Surface) or\
                            isinstance(kwValue, Formula):
                        mater.addNewFunctionProperty(kwName, mandatory)
                    elif isinstance(kwValue, Table):
                        mater.addNewTableProperty(kwName, mandatory)
                    else:
                        raise NotImplementedError("Type not implemented for"
                                                    " material property: '{0}'"
                                                    .format(kwName))
            objects[materName] = mater
        return objects

    @staticmethod
    def _byKeyword():
        """Build a dict of all behaviours subclasses, indexed by keyword.

        Returns:
            dict: Behaviour classes by keyword in DEFI_MATERIAU.
        """
        import code_aster.Objects as all_types
        objects = {}
        for name, obj in all_types.__dict__.items():
            if not isinstance(obj, type):
                continue
            if not issubclass(obj, GeneralMaterialBehaviour):
                continue
            if issubclass(obj, MaterialBehaviour):
                continue
            key = ""
            try:
                key = obj.getName()
            except:
                key = obj().getAsterName()
            objects[key] = obj
        return objects


DEFI_MATERIAU = MaterialDefinition.run
