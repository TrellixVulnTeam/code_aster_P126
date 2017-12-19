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

from ..Objects import (GenericMechanicalLoad, KinematicsLoad,
                       StaticMechanicalSolver)
from ..Objects import ParallelMechanicalLoad
from ..Utilities import unsupported
from .ExecuteCommand import ExecuteCommand
from .common_keywords import create_solver
from .calc_champ import CALC_CHAMP


class MechanicalSolver(ExecuteCommand):
    """Solver for static linear mechanical problems."""
    command_name = "MECA_STATIQUE"

    def create_result(self, keywords):
        """Does nothing, creating by *exec*."""

    @staticmethod
    def _addLoad(mechaSolv, fkw):
        load = fkw["CHARGE"]
        func = fkw.get("FONC_MULT")

        if func !=  None:
            if isinstance(load, KinematicsLoad):
                mechaSolv.addKinematicsLoad(load, func)
            elif isinstance(load, GenericMechanicalLoad):
                mechaSolv.addMechanicalLoad(load, func)
            elif isinstance(load, ParallelMechanicalLoad):
                mechaSolv.addParallelMechanicalLoad(load, func)
            else:
                assert False
        else:
            if isinstance(load, KinematicsLoad):
                mechaSolv.addKinematicsLoad(load)
            elif isinstance(load, GenericMechanicalLoad):
                mechaSolv.addMechanicalLoad(load)
            elif isinstance(load, ParallelMechanicalLoad):
                mechaSolv.addParallelMechanicalLoad(load)
            else:
                assert False

    def exec_(self, keywords):
        """Execute the command.

        Arguments:
            keywords (dict): User's keywords.
        """
        model = keywords["MODELE"]
        matOnMesh = keywords["CHAM_MATER"]

        mechaSolv = StaticMechanicalSolver(model, matOnMesh)

        inst = keywords.get("INST")
        if inst != None:
            mechaSolv.setTimeStepManager(list(inst))
        listInst = keywords.get("LIST_INST")
        if listInst != None:
            mechaSolv.setTimeStepManager(listInst.getValues())

        caraElem = keywords.get("CARA_ELEM")
        if caraElem != None:
            mechaSolv.setElementaryCharacteristics(caraElem)

        fkw = keywords["EXCIT"]
        if isinstance(fkw, dict):
            self._addLoad(mechaSolv, fkw)
        elif isinstance(fkw, (list, tuple)):
            for curDict in fkw:
                self._addLoad(mechaSolv, curDict)
        else:
            assert False

        solver = create_solver(keywords.get("SOLVEUR"))
        mechaSolv.setLinearSolver(solver)
        self._result = mechaSolv.execute()

    def post_exec(self, keywords):
        """Execute the command.

        Arguments:
            keywords (dict): User's keywords.
        """
        contrainte = ()
        if keywords["MODELE"].existsFiberBeam():
            contrainte = contrainte+("STRX_ELGA",)
        if keywords.get("OPTION") == "SIEF_ELGA":
            contrainte = contrainte+("SIEF_ELGA",)

        if len(contrainte) > 0:
            CALC_CHAMP(reuse=self._result,
                       RESULTAT=self._result,
                       CONTRAINTE=contrainte,)

        self._result.setModel(keywords["MODELE"])

MECA_STATIQUE = MechanicalSolver.run
