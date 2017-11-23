import code_aster
from code_aster.Commands import *

code_aster.init()

test = code_aster.TestCase()

MA = code_aster.Mesh()
MA.readMedFile("zzzz315a.mmed")

DEFI_GROUP(MAILLAGE=MA,
            reuse=MA,
            CREA_GROUP_NO=_F(NOEUD=('N1','N8','N7'),
                                NOM = "charcine"))

MO=AFFE_MODELE(MAILLAGE=MA,
               AFFE=_F(TOUT='OUI', PHENOMENE='MECANIQUE', MODELISATION='3D',),)
               
MAT=DEFI_MATERIAU(ELAS=_F(E=1., NU=0.3,),)

CHMAT=AFFE_MATERIAU(MAILLAGE=MA, AFFE=_F(TOUT='OUI', MATER=MAT,),)

CHA1=AFFE_CHAR_CINE(MODELE=MO, MECA_IMPO=_F(GROUP_NO="charcine", DX=0.02,DY=0.03,DZ=0.01,))

MEL1=CALC_MATR_ELEM(OPTION='RIGI_MECA', MODELE=MO, CHAM_MATER=CHMAT)

NU1=NUME_DDL(MATR_RIGI=MEL1, )

SECM1=CREA_CHAMP(TYPE_CHAM='NOEU_DEPL_R', NUME_DDL=NU1, OPERATION='AFFE', MAILLAGE=MA,
                 AFFE=_F(TOUT='OUI', NOM_CMP=('DX','DY','DZ',),  VALE=(1.,2.,3.,),),)
                 
MATAS1=ASSE_MATRICE(MATR_ELEM=MEL1, NUME_DDL=NU1, CHAR_CINE=CHA1)

VCINE1=CALC_CHAR_CINE(NUME_DDL=NU1, CHAR_CINE=CHA1,)

MATAS1=FACTORISER(reuse=MATAS1,MATR_ASSE=MATAS1, METHODE='MULT_FRONT',)

test.assertTrue( True )
