# coding: utf-8

import code_aster
from code_aster.Commands import *

code_aster.init()

test = code_aster.TestCase()

rank = code_aster.getMPIRank()
pMesh = code_aster.ParallelMesh()
pMesh.readMedFile("xxParallelMesh001a")

monModel = code_aster.Model()
monModel.setMesh(pMesh)
monModel.addModelingOnAllMesh(code_aster.Physics.Mechanics,
                              code_aster.Modelings.Tridimensional)
monModel.build()

testMesh = monModel.getMesh()
test.assertEqual(testMesh.getType(), "MAILLAGE_P")

acier = DEFI_MATERIAU(ELAS = _F(E = 2.e11,
                                NU = 0.3,),)

affectMat = code_aster.MaterialOnMesh(pMesh)
affectMat.addMaterialOnAllMesh( acier )
affectMat.buildWithoutInputVariables()

testMesh2 = affectMat.getMesh()
test.assertEqual(testMesh2.getType(), "MAILLAGE_P")

charCine = code_aster.KinematicsMechanicalLoad()
charCine.setModel(monModel)
charCine.addImposedMechanicalDOFOnNodes(code_aster.PhysicalQuantityComponent.Dx, 0., "COTE_B")
charCine.addImposedMechanicalDOFOnNodes(code_aster.PhysicalQuantityComponent.Dy, 0., "COTE_B")
charCine.addImposedMechanicalDOFOnNodes(code_aster.PhysicalQuantityComponent.Dz, 0., "COTE_B")
charCine.build()

charCine2 = code_aster.KinematicsMechanicalLoad()
charCine2.setModel(monModel)
charCine2.addImposedMechanicalDOFOnNodes(code_aster.PhysicalQuantityComponent.Dz, 1., "COTE_H")
charCine2.build()

monSolver = code_aster.PetscSolver(code_aster.Renumbering.Sans)
monSolver.setPreconditioning(code_aster.Preconditioning.Sor)

mecaStatique = code_aster.StaticMechanicalSolver(monModel, affectMat)
mecaStatique.addKinematicsLoad(charCine)
mecaStatique.addKinematicsLoad(charCine2)
mecaStatique.setLinearSolver(monSolver)

resu = mecaStatique.execute()

resu.printMedFile("fort."+str(rank+40)+".med")

MyFieldOnNodes = resu.getRealFieldOnNodes("DEPL", 1)
sfon = MyFieldOnNodes.exportToSimpleFieldOnNodes()
sfon.updateValuePointers()

val = [0.134228076192 , 0.134176297047, 0.154099687654, 0.154189676715]
test.assertAlmostEqual(sfon.getValue(4, 1), val[rank])

test.printSummary()

FIN()
