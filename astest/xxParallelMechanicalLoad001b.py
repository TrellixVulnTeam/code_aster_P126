# coding: utf-8

import code_aster
from code_aster.Commands import *
test = code_aster.TestCase()

code_aster.init()

rank = code_aster.getMPIRank()

pMesh2 = code_aster.ParallelMesh()
pMesh2.readMedFile("xxParallelMechanicalLoad001b")

model = AFFE_MODELE(MAILLAGE = pMesh2,
                    AFFE = _F(MODELISATION = "D_PLAN_INCO_UPG",
                              PHENOMENE = "MECANIQUE",
                              TOUT = "OUI",),)

char_cin = AFFE_CHAR_CINE(MODELE=model,
                          MECA_IMPO=(_F(GROUP_NO="N2",
                                        DX=0.,DY=0.,DZ=0.,),
                                     _F(GROUP_NO="N4",
                                        DX=0.,DY=0.,DZ=0.,),),)

char_meca = AFFE_CHAR_MECA(MODELE=model,
                           LIAISON_DDL=_F(GROUP_NO=("N1", "N3"),
                                          DDL=('PRES','PRES'),
                                          COEF_MULT=(1.0,1.0),
                                          COEF_IMPO=0,),
                           DDL_IMPO=(_F(GROUP_NO="N1",PRES=200000.0),
                                          ))
char_meca.debugPrint(10+rank)

MATER1 = DEFI_MATERIAU(ELAS=_F(E=200000.0,
                               NU=0.499999,),)

AFFMAT = AFFE_MATERIAU(MAILLAGE=pMesh2,
                       AFFE=_F(TOUT='OUI',
                               MATER=MATER1,),)

resu = MECA_STATIQUE(CHAM_MATER=AFFMAT,
                     MODELE=model,
                     EXCIT=(_F(CHARGE=char_cin,),
                            _F(CHARGE=char_meca,),),
                     )
resu.debugPrint(10+rank)

resu.printMedFile("test"+str(rank)+".med")
#from shutil import copyfile
#copyfile("test"+str(rank)+".med", "/home/siavelis/test"+str(rank)+".med")

MyFieldOnNodes = resu.getRealFieldOnNodes("DEPL", 1)
sfon = MyFieldOnNodes.exportToSimpleFieldOnNodes()
sfon.debugPrint(10+rank)
sfon.updateValuePointers()


# DX displacement on nodes "N1" and "N3", comparison with sequential results
if rank == 0:
    test.assertAlmostEqual(sfon.getValue(1, 0), 1.14977255749554, 6)
elif rank == 1:
    test.assertAlmostEqual(sfon.getValue(1, 0), 1.14977255749554, 6)

FIN()
