#!/usr/bin/python
# coding: utf-8

import code_aster
from code_aster.Commands import *

code_aster.init()

test = code_aster.TestCase()

box = code_aster.Mesh.create()
box.readMedFile("zzzz282a.mmed")

grille=DEFI_GRILLE(MAILLAGE=box)

# Test trivial
test.assertTrue( True )
