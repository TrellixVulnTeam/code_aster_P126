
import code_aster
from code_aster.Commands import *

test = code_aster.TestCase()

box = code_aster.Mesh()
box.readMedFile("zzzz282a.mmed")

grille=DEFI_GRILLE(MAILLAGE=box)

# Test trivial
test.assertTrue( True )
