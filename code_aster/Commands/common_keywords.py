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

"""
:py:mod:`common_keywords` --- Helper functions for executors
************************************************************

Here are defined helper functions shared by several commands.
It reflects the common catalog definitions available from
:mod:`code_aster.Cata.Commons`.
"""

from ..Objects import (GcpcSolver, LdltSolver, MultFrontSolver, MumpsSolver,
                       PetscSolver, getGlossary)
from ..Utilities import unsupported


def create_solver(solver_keyword):
    """Create the solver object from the SOLVEUR factor keyword.

    Arguments:
        solver_keyword (dict): Content of the SOLVEUR factor keyword.

    Returns:
        :class:`~code_aster.Objects.BaseLinearSolver` (derivated of):
        Instance of a solver or *None* if none is selected.
    """
    if not solver_keyword:
        return None
    for key, value in solver_keyword.iteritems():
        if key not in ("METHODE", "RENUM", "PRE_COND", "RESI_RELA",
                       "STOP_SINGULIER", "ELIM_LAGR", "TYPE_RESOL",
                       "MATR_DISTRIBUEE", "GESTION_MEMOIRE",
                       "LOW_RANK_SEUIL", "NPREC", "PCENT_PIVOT",
                       "PRETRAITEMENTS", "ALGORITHME",
                       "FILTRAGE_MATRICE", "LOW_RANK_TAILLE"
                       "MIXER_PRECISION", "NIVE_REMPLISSAGE",
                       "NMAX_ITER", "REAC_PRECOND", "RESI_RELA_PC",
                       "POSTTRAITEMENTS", "ACCELERATION"):
            unsupported(solver_keyword, "", key, warning=True)

    method = solver_keyword["METHODE"]
    renum = solver_keyword["RENUM"]

    glossary = getGlossary()
    solverInt = glossary.getSolver(method)
    renumInt = glossary.getRenumbering(renum)

    selected_solver = {"MULT_FRONT": MultFrontSolver, "LDLT": LdltSolver,
                       "MUMPS": MumpsSolver, "PETSC": PetscSolver,
                       "GCPC": GcpcSolver
                       }.get(method)
    if selected_solver:
        solver = selected_solver(renumInt)
    else:
        solver = None

    if solver_keyword.has_key("PRE_COND"):
        precondInt = glossary.getPreconditioning(solver_keyword["PRE_COND"])
        solver.setPreconditioning(precondInt)

    if solver_keyword.has_key("RESI_RELA"):
        solver.setSolverResidual(solver_keyword["RESI_RELA"])

    if solver_keyword.has_key("STOP_SINGULIER"):
        value = True
        if solver_keyword["STOP_SINGULIER"] == "NON":
            value = False
        solver.setErrorOnMatrixSingularity(value)

    if solver_keyword.has_key("ELIM_LAGR"):
        value = glossary.getLagrangeTreatment(solver_keyword["ELIM_LAGR"])
        solver.setLagrangeElimination(value)

    if solver_keyword.has_key("TYPE_RESOL"):
        value = glossary.getMatrixType(solver_keyword["TYPE_RESOL"])
        solver.setMatrixType(value)

    if solver_keyword.has_key("MATR_DISTRIBUEE"):
        value = True
        if solver_keyword["MATR_DISTRIBUEE"] == "NON":
            value = False
        solver.setDistributedMatrix(value)

    if solver_keyword.has_key("GESTION_MEMOIRE"):
        value = glossary.getMemoryManagement(solver_keyword["GESTION_MEMOIRE"])
        solver.setMemoryManagement(value)

    if solver_keyword.has_key("LOW_RANK_TAILLE"):
        solver.setLowRankSize(solver_keyword["LOW_RANK_TAILLE"])

    if solver_keyword.has_key("LOW_RANK_SEUIL"):
        solver.setLowRankThreshold(solver_keyword["LOW_RANK_SEUIL"])

    if solver_keyword.has_key("NPREC"):
        solver.setSingularityDetectionThreshold(solver_keyword["NPREC"])

    if solver_keyword.has_key("PCENT_PIVOT"):
        solver.setPivotingMemory(solver_keyword["PCENT_PIVOT"])

    if solver_keyword.has_key("PRETRAITEMENTS"):
        if solver_keyword["PRETRAITEMENTS"] == "SANS":
            solver.disablePreprocessing()

    if solver_keyword.has_key("ALGORITHME"):
        value = glossary.getIterativeSolverAlgorithm(solver_keyword["ALGORITHME"])
        solver.setAlgorithm(value)

    if solver_keyword.has_key("FILTRAGE_MATRICE"):
        solver.setMatrixFilter(solver_keyword["FILTRAGE_MATRICE"])

    if solver_keyword.has_key("MIXER_PRECISION"):
        value = True
        if solver_keyword["MIXER_PRECISION"] == "NON":
            value = False
        solver.setPrecisionMix(value)

    if solver_keyword.has_key("REMPLISSAGE"):
        solver.setFilling(solver_keyword["REMPLISSAGE"])

    if solver_keyword.has_key("NIVE_REMPLISSAGE"):
        solver.setFillingLevel(solver_keyword["NIVE_REMPLISSAGE"])

    if solver_keyword.has_key("NMAX_ITER"):
        solver.setMaximumNumberOfIteration(solver_keyword["NMAX_ITER"])

    if solver_keyword.has_key("REAC_PRECOND"):
        solver.setUpdatePreconditioningParameter(solver_keyword["REAC_PRECOND"])

    if solver_keyword.has_key("RESI_RELA_PC"):
        solver.setPreconditioningResidual(solver_keyword["RESI_RELA_PC"])

    if solver_keyword.has_key("POSTTRAITEMENTS"):
        value = glossary.getMumpsPostTreatment(solver_keyword["POSTTRAITEMENTS"])
        solver.setPostTreatment(value)

    if solver_keyword.has_key("ACCELERATION"):
        value = glossary.getMumpsAcceleration(solver_keyword["ACCELERATION"])
        solver.setAcceleration(value)

    return solver
