#!/usr/bin/python
# coding: utf-8

import code_aster


test = code_aster.TestCase()

monMaillage = code_aster.Mesh.create()
monMaillage.readMedFile( "test001f.mmed" )

monModel = code_aster.Model.create()
monModel.setSupportMesh( monMaillage )
monModel.addModelingOnAllMesh( code_aster.Physics.Mechanics, code_aster.Modelings.Tridimensional )
monModel.build()
test.assertEqual( monModel.getType(), "MODELE" )

YOUNG = 200000.0;
POISSON = 0.3;

materElas = code_aster.ElasMaterialBehaviour.create()
materElas.setDoubleValue( "E", YOUNG )
materElas.setDoubleValue( "Nu", POISSON )

Kinv= 3.2841e-4
Kv=1./Kinv
SY = 437.0;
Rinf = 758.0;
Qzer   = 758.0-437.;
Qinf   = Qzer + 100.;
b = 2.3;
C1inf = 63767.0/2.0
C2inf = 63767.0/2.0
Gam1 = 341.0
Gam2 = 341.0
C_Pa = 1.e+6

materViscochab = code_aster.ViscochabMaterialBehaviour.create()
materViscochab.setDoubleValue( "K",  SY*C_Pa )
materViscochab.setDoubleValue( "B",  b )
materViscochab.setDoubleValue( "Mu", 10 )
materViscochab.setDoubleValue( "Q_m", Qinf * C_Pa )
materViscochab.setDoubleValue( "Q_0", Qzer * C_Pa )
materViscochab.setDoubleValue( "C1", C1inf * C_Pa )
materViscochab.setDoubleValue( "C2", C2inf * C_Pa )
materViscochab.setDoubleValue( "G1_0", Gam1 )
materViscochab.setDoubleValue( "G2_0", Gam2 )
materViscochab.setDoubleValue( "K_0", Kv * C_Pa)
materViscochab.setDoubleValue( "N", 11)
materViscochab.setDoubleValue( "A_k", 1.)

acier = code_aster.Material.create()
acier.addMaterialBehaviour( materElas )
acier.addMaterialBehaviour( materViscochab )
acier.build()
acier.debugPrint(6)
test.assertEqual( acier.getType(), "MATER" )

affectMat = code_aster.MaterialOnMesh.create()
affectMat.setSupportMesh( monMaillage )
affectMat.addMaterialOnAllMesh( acier )
affectMat.build()
test.assertEqual( affectMat.getType(), "CHAM_MATER" )

imposedDof1 = code_aster.DisplacementDouble.create()
imposedDof1.setValue( code_aster.PhysicalQuantityComponent.Dx, 0.0 )
imposedDof1.setValue( code_aster.PhysicalQuantityComponent.Dy, 0.0 )
imposedDof1.setValue( code_aster.PhysicalQuantityComponent.Dz, 0.0 )
CharMeca1 = code_aster.ImposedDisplacementDouble.create()
CharMeca1.setSupportModel( monModel )
CharMeca1.setValue( imposedDof1, "Bas" )
CharMeca1.build()
test.assertEqual( CharMeca1.getType(), "CHAR_MECA" )

imposedPres1 = code_aster.PressureDouble.create()
imposedPres1.setValue( code_aster.PhysicalQuantityComponent.Pres, 1000. )
CharMeca2 = code_aster.DistributedPressureDouble.create()
CharMeca2.setSupportModel( monModel )
CharMeca2.setValue( imposedPres1, "Haut" )
CharMeca2.build()
test.assertEqual( CharMeca2.getType(), "CHAR_MECA" )

study = code_aster.StudyDescription.create(monModel, affectMat)
study.addMechanicalLoad(CharMeca1)
study.addMechanicalLoad(CharMeca2)
dProblem = code_aster.DiscreteProblem.create(study)
vectElem = dProblem.buildElementaryMechanicalLoadsVector()
matr_elem = dProblem.computeMechanicalRigidityMatrix()

test.assertEqual( matr_elem.getType(), "MATR_ELEM_DEPL_R" )

monSolver = code_aster.LinearSolver.create( code_aster.LinearSolverName.Mumps,
                                            code_aster.Renumbering.Metis )

numeDDL = code_aster.DOFNumbering.create()
numeDDL.setElementaryMatrix( matr_elem )
numeDDL.computeNumerotation()
numeDDL.debugPrint(6)
test.assertEqual( numeDDL.getType(), "NUME_DDL" )

vectElem.debugPrint(6)
test.assertEqual( vectElem.getType(), "VECT_ELEM_DEPL_R" )

retour = vectElem.assembleVector( numeDDL )

matrAsse = code_aster.AssemblyMatrixDouble.create()
matrAsse.setElementaryMatrix( matr_elem )
matrAsse.setDOFNumbering( numeDDL )
matrAsse.build()

try:
    import petsc4py
except ImportError:
    pass
else:
    A = code_aster.LinearAlgebra.AssemblyMatrixToPetsc4Py(matrAsse)
    v=petsc4py.PETSc.Viewer.DRAW(A.comm)
    A.view(v)

matrAsse.factorization()
test.assertEqual( matrAsse.getType(), "MATR_ASSE_DEPL_R" )

resu = monSolver.solveDoubleLinearSystem( matrAsse, retour )
resu2 = resu.exportToSimpleFieldOnNodes()
resu2.updateValuePointers()
test.assertAlmostEqual(resu2.getValue(5, 3), 0.000757555469653289)

resu.printMedFile( "fort.med" )

test.printSummary()
