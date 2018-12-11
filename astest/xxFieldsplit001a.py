#!/usr/bin/python
# coding: utf-8

import code_aster
from code_aster.Commands import *

code_aster.init()

test = code_aster.TestCase()

parallel=False
#parallel = True

if parallel:
    MAIL = code_aster.ParallelMesh()
    MAIL.readMedFile("xxFieldsplit001a")
else:
    MAIL = code_aster.Mesh()
    MAIL.readMedFile("xxFieldsplit001a.med")

model = AFFE_MODELE(
                    AFFE=_F(MODELISATION=('3D_INCO_UP', ), PHENOMENE='MECANIQUE', TOUT='OUI'),
                    MAILLAGE=MAIL
                )

mater = DEFI_MATERIAU(ELAS=_F(E=1.0, NU=0.4999))

fieldmat = AFFE_MATERIAU(
                        AFFE=_F(MATER=(mater, ), TOUT='OUI'), MAILLAGE=MAIL, MODELE=model
                    )

listr0 = DEFI_LIST_REEL(DEBUT=0.0, INTERVALLE=_F(JUSQU_A=1.0, NOMBRE=1))

times0 = DEFI_LIST_INST(
                        DEFI_LIST=_F(LIST_INST=listr0),
                        ECHEC=_F(ACTION='DECOUPE', EVENEMENT='ERREUR', SUBD_NIVEAU=2)
                    )

myOptions=""" -fieldsplit_PRES_ksp_max_it 5  -fieldsplit_PRES_ksp_monitor  -fieldsplit_PRES_ksp_converged_reason  -fieldsplit_PRES_ksp_rtol 1.e-3  -fieldsplit_PRES_ksp_type fgmres  -fieldsplit_PRES_pc_type jacobi  -fieldsplit_DXDYDZ_ksp_monitor  -fieldsplit_DXDYDZ_ksp_converged_reason  -fieldsplit_DXDYDZ_ksp_rtol 1e-3  -fieldsplit_DXDYDZ_ksp_max_it 20  -fieldsplit_DXDYDZ_ksp_type gmres  -fieldsplit_DXDYDZ_pc_type gamg  -fieldsplit_DXDYDZ_pc_gamg_threshold -1  -ksp_monitor  -ksp_converged_reason   -ksp_type fgmres  -pc_fieldsplit_schur_factorization_type upper  -pc_fieldsplit_schur_precondition a11  -pc_fieldsplit_type schur  -log_view """

BC = AFFE_CHAR_CINE(
                    MECA_IMPO=(
                                _F(DZ=0.0, GROUP_MA=('Zinf', )),
                                _F(DY=0.0, GROUP_MA=('Yinf', 'Ysup')),
                                _F(DX=0.0, GROUP_MA=('Xsup', 'Xinf')),
                                _F(DX=1.0, DZ=0.0, GROUP_MA=('Zsup', )),
                                _F(PRES=0.0, GROUP_NO='pNode',),
                    ),
                    MODELE=model
                )

resnonl = STAT_NON_LINE(
                        CHAM_MATER=fieldmat,
                        EXCIT=_F(CHARGE=BC, ),
                        INCREMENT=_F(LIST_INST=times0),
                        MODELE=model,
                        SOLVEUR=_F(MATR_DISTRIBUEE='OUI', METHODE='PETSC', PRE_COND='FIELDSPLIT',RESI_RELA=1.e-8,
                                   NOM_CMP=('DX','DY','DZ','PRES'), PARTITION_CMP=(3,1), OPTION_PETSC=myOptions),
                        INFO=2,
                    )

# at least it pass here!
test.assertTrue(True)
test.printSummary()

# if parallel:
#     rank = code_aster.getMPIRank()
#     resnonl.printMedFile('/tmp/par_%d.resu.med'%rank)
# else:
#     resnonl.printMedFile('/tmp/seq.resu.med')
