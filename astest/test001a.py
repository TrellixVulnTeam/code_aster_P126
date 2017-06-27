#!/usr/bin/python
# coding: utf-8

import code_aster
test = code_aster.TestCase()

# Creation du maillage
mesh = code_aster.Mesh.create()
test.assertEqual( mesh.getType(), 'MAILLAGE' )

# Relecture du fichier MED
mesh.readMedFile("test001a.mmed")
# mesh.readMEDFile("epicu01b.mail.med")

#help(mesh)

coord = mesh.getCoordinates()
test.assertEqual( coord.getType(), "CHAM_NO" )
#help(coord)

# check readonly access
print "coord[3] ", coord[3]
test.assertEqual( coord[3], 1.0 )

with test.assertRaises(TypeError):
    coord[3] = 5.0

# Definition du modele Aster
model = code_aster.Model.create()
test.assertEqual( model.getType(), "MODELE" )
model.setSupportMesh(mesh)
model.addModelingOnAllMesh(code_aster.Physics.Mechanics, code_aster.Modelings.Tridimensional)

model.build()

# Definition du modele Aster
model2 = code_aster.Model.create()
model2.setSupportMesh(mesh)

with test.assertRaisesRegexp(RuntimeError, 'not allowed'):
    model2.addModelingOnAllMesh(code_aster.Physics.Thermal, code_aster.Modelings.DKT)

# Verification du comptage de référence sur le maillage
del mesh

mesh2 = model.getSupportMesh()
test.assertTrue( mesh2.hasGroupOfElements('Tout') )

# Vérification du debug
mesh2.debugPrint()

test.printSummary()
