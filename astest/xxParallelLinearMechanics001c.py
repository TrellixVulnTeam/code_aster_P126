#!/usr/bin/python
# coding: utf-8

import code_aster
from code_aster.Commands import *

code_aster.init()

test = code_aster.TestCase()

rank = code_aster.getMPIRank()
pMesh = code_aster.ParallelMesh()
pMesh.readMedFile("xxParallelMesh001a")

monModel = code_aster.Model()
monModel.setSupportMesh(pMesh)
monModel.addModelingOnAllMesh(code_aster.Physics.Mechanics,
                              code_aster.Modelings.Tridimensional)
monModel.build()

testMesh = monModel.getSupportMesh()
test.assertEqual(testMesh.getType(), "MAILLAGE_P")

elas = code_aster.ElasMaterialBehaviour()
elas.setDoubleValue("E", 2.e11)
elas.setDoubleValue("Nu", 0.3)

acier = code_aster.Material()
acier.addMaterialBehaviour(elas)
acier.build()

affectMat = code_aster.MaterialOnMesh(pMesh)
affectMat.addMaterialOnAllMesh( acier )
affectMat.build()

testMesh2 = affectMat.getSupportMesh()
test.assertEqual(testMesh2.getType(), "MAILLAGE_P")

charCine = code_aster.KinematicsLoad()
charCine.setSupportModel(monModel)
charCine.addImposedMechanicalDOFOnNodes(code_aster.PhysicalQuantityComponent.Dx, 0., "COTE_B")
charCine.addImposedMechanicalDOFOnNodes(code_aster.PhysicalQuantityComponent.Dy, 0., "COTE_B")
charCine.addImposedMechanicalDOFOnNodes(code_aster.PhysicalQuantityComponent.Dz, 0., "COTE_B")
charCine.build()

a = code_aster.PartialMesh(pMesh, ["COTE_H"])
if( rank == 0 ): a.debugPrint(8)

model1 = AFFE_MODELE(MAILLAGE=a,
                     AFFE=_F(TOUT='OUI',
                             PHENOMENE='MECANIQUE',
                             MODELISATION='DIS_T',),
                     DISTRIBUTION=_F(METHODE='CENTRALISE',),)

charMeca1 = AFFE_CHAR_MECA(MODELE=model1,
                           DDL_IMPO=_F(GROUP_NO=("COTE_H"),
                                       DZ=1.0,),)

charMeca = code_aster.ParallelMechanicalLoad(charMeca1, monModel)

monSolver = code_aster.MumpsSolver(code_aster.Renumbering.Metis)

mecaStatique = code_aster.StaticMechanicalSolver(monModel, affectMat)
mecaStatique.addKinematicsLoad(charCine)
mecaStatique.addParallelMechanicalLoad(charMeca)
mecaStatique.setLinearSolver(monSolver)

resu = mecaStatique.execute()

resu.printMedFile("fort."+str(rank+40)+".med")

MyFieldOnNodes = resu.getRealFieldOnNodes("DEPL", 0)
sfon = MyFieldOnNodes.exportToSimpleFieldOnNodes()
sfon.updateValuePointers()

val = [0.134202362865, 0.134202362865, 0.154144849556, 0.154144849556]
test.assertAlmostEqual(sfon.getValue(4, 1), val[rank])

test.printSummary()
