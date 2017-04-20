# coding: utf-8

# Copyright (C) 1991 - 2016  EDF R&D                www.code-aster.org
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

from code_aster import LinearSolver, StaticMechanicalSolver, KinematicsLoad, GenericMechanicalLoad
from code_aster.Cata import Commands
from code_aster.Cata.SyntaxChecker import checkCommandSyntax
from code_aster import getGlossary


def _addLoad( mechaSolv, fkw ):
    load = fkw[ "CHARGE" ]
    if fkw.get( "FONC_MULT" ):
        raise NotImplementedError( "Unsupported keyword: {0}".format("FONC_MULT") )

    if isinstance( load, KinematicsLoad ):
        mechaSolv.addKinematicsLoad( load )
    elif isinstance( load, GenericMechanicalLoad ):
        mechaSolv.addMechanicalLoad( load )
    else:
        assert False


def MECA_STATIQUE( **kwargs ):
    """Opérateur de résolution de mécanique statique linéaire"""
    checkCommandSyntax( Commands.MECA_STATIQUE, kwargs )

    mechaSolv = StaticMechanicalSolver.create()

    model = kwargs[ "MODELE" ]
    matOnMesh = kwargs[ "CHAM_MATER" ]
    mechaSolv.setSupportModel( model )
    mechaSolv.setMaterialOnMesh( matOnMesh )

    if kwargs.get( "CARA_ELEM" ):
        raise NotImplementedError("Unsupported keyword: '{0}'".format("CARA_ELEM"))
    if kwargs.get( "LIST_INST" ) != None or kwargs.get( "INST_FIN" ) != None:
        raise NotImplementedError("Unsupported keywords: '{0}'".format(("LIST_INST", "INST_FIN")))

    fkw = kwargs[ "EXCIT" ]
    if type( fkw ) == dict:
        _addLoad( mechaSolv, fkw )
    elif type( fkw ) == tuple:
        for curDict in fkw:
            _addLoad( mechaSolv, curDict )
    else:
        assert False

    methode = None
    renum = None

    fkwSolv = kwargs["SOLVEUR"]
    for key, value in fkwSolv.iteritems():
        if key not in ( "METHODE", "RENUM" ):
            print(NotImplementedError("Not yet implemented: '{0}' is ignored".format(key)))
    methode = fkwSolv[ "METHODE" ]
    renum = fkwSolv[ "RENUM" ]

    glossary = getGlossary()
    solverInt = glossary.getSolver( methode )
    renumInt = glossary.getRenumbering( renum )
    currentSolver = LinearSolver.create( solverInt, renumInt )

    mechaSolv.setLinearSolver( currentSolver )

    return mechaSolv.execute()
