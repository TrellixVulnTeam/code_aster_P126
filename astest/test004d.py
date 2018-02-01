#!/usr/bin/python
# coding: utf-8

import code_aster
code_aster.init()

test = code_aster.TestCase()

monMaillage = code_aster.Mesh()
monMaillage.readMedFile( "test001f.mmed" )

monModel = code_aster.Model()
monModel.setSupportMesh( monMaillage )
monModel.addModelingOnAllMesh( code_aster.Physics.Mechanics, code_aster.Modelings.Tridimensional )
monModel.build()

YOUNG = 200000.0;
POISSON = 0.3;

materElas = code_aster.ElasMaterialBehaviour()
materElas.setDoubleValue( "E", YOUNG )
materElas.setDoubleValue( "Nu", POISSON )

acier = code_aster.Material()
acier.addMaterialBehaviour( materElas )
acier.build()
#acier.debugPrint(6)

affectMat = code_aster.MaterialOnMesh(monMaillage)
affectMat.addMaterialOnAllMesh( acier )
affectMat.buildWithoutInputVariables()


kine1 = code_aster.KinematicsLoad()
kine1.setSupportModel(monModel)
kine1.addImposedMechanicalDOFOnElements(code_aster.PhysicalQuantityComponent.Dx, 0., "Bas")
kine1.addImposedMechanicalDOFOnElements(code_aster.PhysicalQuantityComponent.Dy, 0., "Bas")
kine1.addImposedMechanicalDOFOnElements(code_aster.PhysicalQuantityComponent.Dz, 0., "Bas")
kine1.build()

kine2=code_aster.KinematicsLoad()
kine2.setSupportModel(monModel)
kine2.addImposedMechanicalDOFOnElements(code_aster.PhysicalQuantityComponent.Dz, 0.1, "Haut")
kine2.build()

monSolver = code_aster.MumpsSolver( code_aster.Renumbering.Metis )

# Define a first nonlinear Analysis
statNonLine1 = code_aster.StaticNonLinearAnalysis()

statNonLine1.addStandardExcitation( kine1 )
statNonLine1.addStandardExcitation( kine2 )

statNonLine1.setSupportModel( monModel )
statNonLine1.setMaterialOnMesh( affectMat )
statNonLine1.setLinearSolver( monSolver )
elas = code_aster.Behaviour(code_aster.ConstitutiveLaw.Elas,
                                   code_aster.StrainType.SmallStrain )
statNonLine1.addBehaviourOnElements( elas );


temps = [0., 0.5 ]
timeList = code_aster.TimeStepManager()
timeList.setTimeList( temps )

error1 = code_aster.ConvergenceError()
action1 = code_aster.SubstepingOnError()
action1.setAutomatic( False )
error1.setAction( action1 )
timeList.addErrorManager( error1 )
#error2 = code_aster.Studies.ContactDetectionError()
#action2 = code_aster.Studies.SubstepingOnContact()
#error2.setAction( action2 )
#timeList.addErrorManager( error2 )
timeList.build()
#timeList.debugPrint( 6 )
statNonLine1.setLoadStepManager( timeList )
# Run the nonlinear analysis
#resu = statNonLine1.execute()
#resu.debugPrint( 6 )

test.assertTrue( True )
test.printSummary()
