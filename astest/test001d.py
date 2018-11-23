#!/usr/bin/python
# coding: utf-8

import code_aster
from code_aster import AsterError
code_aster.init()

test = code_aster.TestCase()

# Creation du maillage
monMaillage = code_aster.Mesh()

# Relecture du fichier MED
monMaillage.readMedFile("test001d.mmed")

# Definition du modele Aster
monModel = code_aster.Model()
monModel.setSupportMesh(monMaillage)
monModel.addModelingOnAllMesh(code_aster.Physics.Mechanics, code_aster.Modelings.Tridimensional)
monModel.build()

# Definition d'un chargement de type FORCE_NODALE à partir d'une ForceDouble
force = code_aster.ForceDouble()
force.setValue( code_aster.PhysicalQuantityComponent.Fz, 100.0 )

print " >>>> Construction d'un chargement NodalForceDouble"
CharMeca1 = code_aster.NodalForceDouble(monModel)
# On ne peut pas imposer une force nodale sur un groupe de mailles
with test.assertRaises( RuntimeError ):
    CharMeca1.setValue( force, "UP" )


nameOfGroup = "A"
CharMeca1.setValue( force, nameOfGroup )
print "      sur le groupe : ", nameOfGroup
ret = CharMeca1.build()
#CharMeca1.debugPrint()
test.assertTrue( ret )

# Definition d'un chargement de type FORCE_NODALE à partir d'un StructuralForceDouble

force_pour_structure = code_aster.StructuralForceDouble()
force_pour_structure.setValue( code_aster.PhysicalQuantityComponent.Mx, 10.0 )
force_pour_structure.setValue( code_aster.PhysicalQuantityComponent.My, 20.0 )
force_pour_structure.setValue( code_aster.PhysicalQuantityComponent.Mz, 30.0 )

print " >>>> Construction d'un chargement NodalStructuralForceDouble"
print "      Ce chargement est correct pour le catalogue mais conduit à une erreur Fortran "
CharMeca2 = code_aster.NodalStructuralForceDouble(monModel)
nameOfGroup = "B"
CharMeca2.setValue( force_pour_structure, nameOfGroup )
print "      sur le groupe : ", nameOfGroup

# Le Dl MX n'est pas autorisé
# fortran error
with test.assertRaises( AsterError ):
    CharMeca2.build()

#CharMeca2.debugPrint()

# Definition d'un chargement de type FORCE_FACE à partir d'un ForceDouble
print " >>>> Construction d'un chargement ForceOnFaceDouble"

CharMeca3 = code_aster.ForceOnFaceDouble(monModel)
nameOfGroup = "UP"
CharMeca3.setValue( force, nameOfGroup )
print "      sur le groupe : ", nameOfGroup
ret = CharMeca3.build()
test.assertTrue( ret )


# Definition d'un chargement de type FORCE_ARETE à partir d'un ForceDouble
print " >>>> Construction d'un chargement ForceOnEdgeDouble"
CharMeca4 = code_aster.ForceOnEdgeDouble(monModel)
nameOfGroup = "UP"
CharMeca4.setValue( force, nameOfGroup )
print "      sur le groupe : ", nameOfGroup
ret = CharMeca4.build()
test.assertTrue( ret )

# Definition d'un chargement de type FORCE_ARETE à partir d'un StructuralForceDouble
print " >>>> Construction d'un chargement StructuralForceOnEdgeDouble"
# C'est bizarre, on entre un groupe qui est une face et le fortran ne détecte rien !
CharMeca5 = code_aster.StructuralForceOnEdgeDouble(monModel)
nameOfGroup = "UP"
CharMeca5.setValue( force_pour_structure, nameOfGroup )
print "      sur le groupe : ", nameOfGroup
ret = CharMeca5.build()
test.assertTrue( ret )

# Definition d'un chargement de type FORCE_CONTOUR à partir d'un ForceDouble
print " >>>> Construction d'un chargement LineicForceDouble"

CharMeca6 = code_aster.LineicForceDouble(monModel)
nameOfGroup = "BOTTOM"
CharMeca6.setValue( force, nameOfGroup )
print "      sur le groupe : ", nameOfGroup
ret = CharMeca6.build()
test.assertTrue( ret )

# Definition d'un chargement de type FORCE_INTERNE à partir d'un ForceDouble
print " >>>> Construction d'un chargement InternalForceDouble"

CharMeca7 = code_aster.InternalForceDouble(monModel)
nameOfGroup = "BOTTOM"
CharMeca7.setValue( force, nameOfGroup )
print "      sur le groupe : ", nameOfGroup
ret = CharMeca7.build()
test.assertTrue( ret )

# Definition d'un chargement de type FORCE_POUTRE à partir d'un StructuralForceDouble
print " >>>> Construction d'un chargement StructuralForceOnBeamDouble"

CharMeca8 = code_aster.StructuralForceOnBeamDouble(monModel)
nameOfGroup = "OA"
CharMeca8.setValue( force_pour_structure, nameOfGroup )
print "      sur le groupe : ", nameOfGroup
ret = CharMeca8.build()
test.assertTrue( ret )

# Definition d'un chargement de type FORCE_POUTRE à partir d'un LocalBeamForceDouble
print " >>>> Construction d'un chargement LocalForceOnBeamDouble"

fpoutre = code_aster.LocalBeamForceDouble()
fpoutre.setValue(code_aster.PhysicalQuantityComponent.N, 5.0)

CharMeca9 = code_aster.LocalForceOnBeamDouble(monModel)
nameOfGroup = "BOTTOM"
CharMeca9.setValue( fpoutre, nameOfGroup )
print "      sur le groupe : ", nameOfGroup
ret = CharMeca9.build()
test.assertTrue( ret )

# Definition d'un chargement de type FORCE_COQUE à partir d'un StructuralForceDouble
print " >>>> Construction d'un chargement StructuralForceOnShellDouble"

CharMeca10 = code_aster.StructuralForceOnShellDouble(monModel)
nameOfGroup = "UP"
CharMeca10.setValue( force_pour_structure, nameOfGroup )
print "      sur le groupe : ", nameOfGroup
ret = CharMeca10.build()
test.assertTrue( ret )

# Definition d'un chargement de type FORCE_COQUE à partir d'un LocalShellForceDouble
print " >>>> Construction d'un chargement LocalForceOnShellDouble"

fshell = code_aster.LocalShellForceDouble()
fshell.setValue(code_aster.PhysicalQuantityComponent.F1, 11.0)
fshell.setValue(code_aster.PhysicalQuantityComponent.F2, 12.0)
fshell.setValue(code_aster.PhysicalQuantityComponent.F3, 13.0)

CharMeca11 = code_aster.LocalForceOnShellDouble(monModel)
nameOfGroup = "UP"
CharMeca11.setValue( fshell, nameOfGroup )
print "      sur le groupe : ", nameOfGroup
ret = CharMeca11.build()
test.assertTrue( ret )

# Definition d'un chargement de type FORCE_COQUE à partir d'une PressureDouble
print " >>>> Construction d'un chargement PressureOnShellDouble"

pression = code_aster.PressureDouble()
pression.setValue(code_aster.PhysicalQuantityComponent.Pres, 14.0)

CharMeca12 = code_aster.PressureOnShellDouble(monModel)
nameOfGroup = "UP"
CharMeca12.setValue( pression, nameOfGroup )
print "      sur le groupe : ", nameOfGroup
ret = CharMeca12.build()
test.assertTrue( ret )

# Imposer une PressureDouble sur un groupe de noeuds
print " >>>> Construction d'un chargement ImposedPressureDouble"
CharMeca13 = code_aster.ImposedPressureDouble(monModel)
nameOfGroup = "O"
CharMeca13.setValue( pression, nameOfGroup )
print "      sur le groupe : ", nameOfGroup
# fortran error
with test.assertRaises( AsterError ):
    CharMeca13.build()

test.printSummary()
