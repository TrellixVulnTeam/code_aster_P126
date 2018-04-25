#!/usr/bin/python
# coding: utf-8

import code_aster
from code_aster.Commands import *

code_aster.init()

test = code_aster.TestCase()

rank = code_aster.getMPIRank()
print "Nb procs", code_aster.getMPINumberOfProcs()
print "Rank", code_aster.getMPIRank()

pMesh2 = code_aster.ParallelMesh()
pMesh2.readMedFile("xxParallelMesh001a")
del pMesh2

pMesh = code_aster.ParallelMesh()
pMesh.readMedFile("xxParallelMesh001a")
pMesh.debugPrint(rank+30)

model = code_aster.Model()
test.assertEqual(model.getType(), "MODELE_SDASTER")
model.setSupportMesh(pMesh)
model.addModelingOnAllMesh(code_aster.Physics.Mechanics,
                           code_aster.Modelings.Tridimensional)
model.build()

testMesh = model.getSupportMesh()
test.assertEqual(testMesh.getType(), "MAILLAGE_P")

model.debugPrint(rank+30)

acier = code_aster.Material()

elas = code_aster.ElasMaterialBehaviour()
elas.setDoubleValue("E", 2.e11)
elas.setDoubleValue("Nu", 0.3)

acier.addMaterialBehaviour(elas)
acier.build()
acier.debugPrint(8)

affectMat = code_aster.MaterialOnMesh(pMesh)

testMesh2 = affectMat.getSupportMesh()
test.assertEqual(testMesh2.getType(), "MAILLAGE_P")

affectMat.addMaterialOnAllMesh(acier)
affectMat.buildWithoutInputVariables()

charCine = code_aster.KinematicsMechanicalLoad()
charCine.setSupportModel(model)
charCine.addImposedMechanicalDOFOnNodes(code_aster.PhysicalQuantityComponent.Dx, 0., "COTE_B")
charCine.build()

study = code_aster.StudyDescription(model, affectMat)
dProblem = code_aster.DiscreteProblem(study)
matr_elem = dProblem.computeMechanicalRigidityMatrix()

monSolver = code_aster.MumpsSolver(code_aster.Renumbering.Metis)

numeDDL = code_aster.ParallelDOFNumbering()
numeDDL.setElementaryMatrix(matr_elem)
numeDDL.computeNumerotation()
numeDDL.debugPrint(rank+30)

matrAsse = code_aster.AssemblyMatrixDouble()
matrAsse.appendElementaryMatrix(matr_elem)
matrAsse.setDOFNumbering(numeDDL)
matrAsse.addKinematicsLoad(charCine)
matrAsse.build()
matrAsse.debugPrint(rank+30)

retour = matrAsse.getDOFNumbering()
test.assertEqual(retour.isParallel(), True)

test.printSummary()
