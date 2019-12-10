# coding: utf-8

import code_aster
from code_aster.Commands import *

code_aster.init()

test = code_aster.TestCase()

#
MAILLA0=code_aster.Mesh()
MAILLA0.readAsterMeshFile("sdld107a.mail")

MAILLA=CREA_MAILLAGE(MAILLAGE=MAILLA0,
    CREA_POI1=(
        _F(NOM_GROUP_MA='MASSE',   GROUP_NO='MASSE', ),
    ),
)

# CONSTRUCTION DU MODELE NUMERIQUE
MODNUM=AFFE_MODELE(MAILLAGE=MAILLA,
                   AFFE=(_F(GROUP_MA='RESSORT',
                            PHENOMENE='MECANIQUE',
                            MODELISATION='DIS_T',),
                         _F(GROUP_MA='MASSE',
                            PHENOMENE='MECANIQUE',
                            MODELISATION='DIS_T',),),);

CARE=AFFE_CARA_ELEM(MODELE=MODNUM,
                     DISCRET=(_F(CARA='K_T_D_L',
                                 GROUP_MA='RESSORT',
                                 VALE=(1.,0.,0.,),),
                               _F(CARA='M_T_D_L',
                                  GROUP_MA='RESSORT',
                                  VALE = (0.,),),
                              _F(CARA='M_T_D_N',
                                 GROUP_MA='MASSE',
                                 VALE=1.,),),);

CHARGE_L=AFFE_CHAR_MECA(MODELE=MODNUM,
                        DDL_IMPO=(_F(TOUT='OUI',
                                     DY=0.,
                                     DZ=0.,),
                                  _F(NOEUD='NO1',
                                     DX=0.,),
                                  _F(NOEUD='NO5',
                                     DX=0.,),),);



# CONSTRUCTION DES MATRICES DU MODELE MECANIQUE

ASSEMBLAGE(MODELE=MODNUM,
           CARA_ELEM=CARE,
           CHARGE=CHARGE_L,
           NUME_DDL=CO("NU"),
           MATR_ASSE=(_F(  MATRICE = CO("K"),  OPTION = 'RIGI_MECA'),
                      _F(  MATRICE = CO("M"),  OPTION = 'MASS_MECA'),),
           );


# CONSTRUCTION DE LA MATRICE REDUITE DE GUYAN SERVANT DE NORME POUR L'ERC

# CL POUR LA CONSTRUCTION DE LA MATRICE REDUITE DE GUYAN SERVANT DE NORME POUR L'ERC

CHAR_G=AFFE_CHAR_MECA(MODELE=MODNUM,DDL_IMPO=(_F(  GROUP_NO = 'OBSPOINT',  DX=0.  ),),);

ASSEMBLAGE(MODELE=MODNUM,
           CARA_ELEM=CARE,
           CHARGE=(CHAR_G,CHARGE_L),
           NUME_DDL=CO("NU_G"),
           MATR_ASSE=(_F(  MATRICE = CO("K1"),  OPTION = 'RIGI_MECA'),
                      _F(  MATRICE = CO("M1"),  OPTION = 'MASS_MECA'),),
           );

MOD_STA=MODE_STATIQUE(MATR_RIGI=K1,
                      MATR_MASS=M1,
                      MODE_STAT=(_F(GROUP_NO='OBSPOINT',
                                    AVEC_CMP=('DX',),),),);

NUME_RED=NUME_DDL_GENE(BASE=MOD_STA,STOCKAGE='PLEIN');

MA_RE=PROJ_MATR_BASE(BASE=MOD_STA,NUME_DDL_GENE=NUME_RED,MATR_ASSE=M);
K_RE=PROJ_MATR_BASE(BASE=MOD_STA,NUME_DDL_GENE=NUME_RED,MATR_ASSE=K);

# ON CHOISIT LA MATRICE NORME COMME UNE COMBINAISON DES MATRICES
# REDUITES DE MASSE ET RAIDEUR
G_GUY=COMB_MATR_ASSE(COMB_R=(_F(MATR_ASSE = MA_RE,COEF_R = 1.),
                             _F(MATR_ASSE = K_RE, COEF_R = 1.),),);

### CREATION SYNTHETIQUE DE LA MESURE
#(CES INFORMATIONS SONT NORMALEMENT OBTENUES PAR LECTURE
# D'UN FICHIER CONTENANT DES DONNES D'ESSAI AVEC P.E. LIRE_RESU)

# CALCUL DES MODES

MODES=CALC_MODES(MATR_RIGI=K,
                 MATR_MASS=M,
                 CALC_FREQ=_F(NMAX_FREQ=2,),);

# MODES=NORM_MODE( reuse=MODES,MODE=MODES,
#                  NORME='TRAN',
#                  MODE_SIGNE=_F(GROUP_NO = 'X1',
#                                NOM_CMP = 'DX',
#                                SIGNE = 'POSITIF'),);

MAILEXP=code_aster.Mesh()
MAILEXP.readAsterMeshFile("sdld107a.msup")
# LIRE_MAILLAGE(FORMAT="ASTER",UNITE=21,);

MODEXP=AFFE_MODELE(MAILLAGE=MAILEXP,
                   AFFE=(_F(GROUP_MA = 'MESURE',
                            PHENOMENE='MECANIQUE',
                            MODELISATION='BARRE',),),);

CARE2=AFFE_CARA_ELEM( MODELE=MODEXP,
                      BARRE=_F(GROUP_MA = 'MESURE',
                              SECTION='CERCLE',
                              CARA=('R',),
                              VALE=(1.,),),);

ACIER=DEFI_MATERIAU(ELAS=_F(E=1.,NU=0.3,  RHO=1.,),);

MATEX=AFFE_MATERIAU(MAILLAGE=MAILEXP,AFFE=_F(GROUP_MA='MESURE',MATER=ACIER,),);

ASSEMBLAGE(MODELE=MODEXP,
           CARA_ELEM=CARE2,
           CHAM_MATER=MATEX,
           NUME_DDL=CO("NUMEXP"),
           MATR_ASSE=(_F(  MATRICE = CO("KASEXP"),  OPTION = 'RIGI_MECA'),
                      _F(  MATRICE = CO("MASEXP"),  OPTION = 'MASS_MECA'),),);

## CALCUL DE LA MATRICE DE PROJECTION ENTRE MODELE NUMERIQUE ET EXPERIMENTAL (concept corresp_2_mailla)

MATPROJ = PROJ_CHAMP(METHODE='COLLOCATION', ## METHODE COLLOCATION OBLIGATOIRE POUR CALC_ERC_DYN
                     PROJECTION='NON',
                     MODELE_1=MODNUM,
                     MODELE_2=MODEXP);

OBS = OBSERVATION( RESULTAT = MODES,
                   MODELE_1 = MODNUM,
                   MODELE_2 = MODEXP,
                   PROJECTION = 'OUI',
                   TOUT_ORDRE = 'OUI',
                   MATR_RIGI = KASEXP,
                   MATR_MASS = MASEXP,
                   NOM_CHAM = 'DEPL',
                   FILTRE = _F( GROUP_MA = 'MESURE',
                                NOM_CHAM = ('DEPL'),
                                DDL_ACTIF = ('DX',),),);

### RESOLUTION DU PROBLEME DE L'ERC

# CHOIX DES FREQUENCES SUR LESQUELLES ON VA RESOUDRE L'ERC:
# LA PREMIERE EST EXACTEMENT LA FREQUENCE PROPRE DU SYSTEME
# LA DEUXIEME EST PERTURBEE ARTIFICIELLEMENT PAR UNE ERREUR DE 25%
# AFIN DE GENERER DU DEFAUT

LFREQ=DEFI_LIST_REEL(VALE=[0.12181191980055407,1.25*0.22507907903927654],);

ERC=CALC_ERC_DYN( EVAL_FONC='OUI',
                  MATR_PROJECTION=MATPROJ,
                  MESURE=OBS,
                  CHAMP_MESURE='DEPL',
                  MATR_MASS=M,
                  MATR_RIGI=K,
                  MATR_NORME=G_GUY,
                  LIST_FREQ=LFREQ,
                  GAMMA=0.5,
                  ALPHA=0.5,
                  INFO=1,
                  SOLVEUR=_F(METHODE='MUMPS',),);


### test sur le champ u
TEST_RESU(RESU=(_F(NUME_ORDRE=3,
                   VALE_CALC=0.957415448053491,
                   VALE_REFE=0.957415448053491,
                   VALE_ABS='OUI',
                   REFERENCE='NON_DEFINI',
                   RESULTAT=ERC,
                   NOM_CHAM='DEPL',
                   NOEUD='NO2',
                   NOM_CMP='DX',),
                _F(NUME_ORDRE=3,
                   VALE_CALC=-0.038110367724860,
                   VALE_REFE=-0.038110367724860,
                   VALE_ABS='OUI',
                   REFERENCE='NON_DEFINI',
                   RESULTAT=ERC,
                   NOM_CHAM='DEPL',
                   NOEUD='NO3',
                   NOM_CMP='DX',),
                _F(NUME_ORDRE=3,
                   VALE_CALC=-0.494584477951991,
                   VALE_REFE=-0.494584477951991,
                   VALE_ABS='OUI',
                   REFERENCE='NON_DEFINI',
                   RESULTAT=ERC,
                   NOM_CHAM='DEPL',
                   NOEUD='NO4',
                   NOM_CMP='DX',),),);

### test sur le champ u-v
TEST_RESU(RESU=(_F(NUME_ORDRE=4,
                   VALE_CALC=-0.223608826207038,
                   VALE_REFE=-0.223608826207038,
                   VALE_ABS='OUI',
                   REFERENCE='NON_DEFINI',
                   RESULTAT=ERC,
                   NOM_CHAM='DEPL',
                   NOEUD='NO2',
                   NOM_CMP='DX',),
                _F(NUME_ORDRE=4,
                   VALE_CALC=-0.107013222975753,
                   VALE_REFE=-0.107013222975753,
                   VALE_ABS='OUI',
                   REFERENCE='NON_DEFINI',
                   RESULTAT=ERC,
                   NOM_CHAM='DEPL',
                   NOEUD='NO3',
                   NOM_CMP='DX',),
                _F(NUME_ORDRE=4,
                   VALE_CALC=0.095122864867336,
                   VALE_REFE=0.095122864867336,
                   VALE_ABS='OUI',
                   REFERENCE='NON_DEFINI',
                   RESULTAT=ERC,
                   NOM_CHAM='DEPL',
                   NOEUD='NO4',
                   NOM_CMP='DX',),),);

########## POST-TRAITEMENTS

### Si on s'interesse a l'expansion de donnees sur le modele, les champs solution
### sont stockes directement dans le concept de sortie de CALC_ERC_DYN:
###   --> Le champ solution u est stocke dans les nume_ordre impairs
###   --> Le champ d'erreur solution u-v est stocke dans les nume_ordre pairs

### Pour la localisation spatiale des defauts on calcule l'energie des champs d'erreur

E_POT=CALC_CHAMP(RESULTAT=ERC,
                 ENERGIE='EPOT_ELEM',);

# E_CIN=CALC_CHAMP(RESULTAT=MODES,
#                  ENERGIE='ECIN_ELEM',);

## si on souhaite faire du recalage, on recupere la valeur de la fonctionnelle dans une table
## sous le parametre  'ERC_EVAL_FONC' :
##   --> dans les nume_ordre impairs on a la valeur totale de la fonctionnelle d'erreur
##   --> dans les nume_ordre pairs on a la contribution des champs u-v et u-w seulement

F_COUT=RECU_TABLE(CO=ERC,NOM_PARA='ERC_EVAL_FONC')


TEST_TABLE( TABLE   = F_COUT,
            NOM_PARA  = 'ERC_EVAL_FONC',
            FILTRE =(_F(VALE_I=1,NOM_PARA  = 'NUME_ORDRE',),),
            TYPE_TEST = 'MIN',
            REFERENCE='ANALYTIQUE',
            VALE_REFE = 0.,
            VALE_CALC = 2.13860631521E-31,
            CRITERE   = 'ABSOLU',)

TEST_TABLE( TABLE   = F_COUT,
            NOM_PARA  = 'ERC_EVAL_FONC',
            FILTRE =(_F(VALE_I=3,NOM_PARA  = 'NUME_ORDRE',),),
            TYPE_TEST = 'MIN',
            REFERENCE='ANALYTIQUE',
            VALE_CALC = 0.0896432881147,
            VALE_REFE=  0.089643288114668,
            CRITERE   = 'RELATIF',)

TEST_TABLE( TABLE   = F_COUT,
            NOM_PARA  = 'ERC_EVAL_FONC',
            FILTRE =(_F(VALE_I=4,NOM_PARA  = 'NUME_ORDRE',),),
            TYPE_TEST = 'MIN',
            REFERENCE='ANALYTIQUE',
            VALE_CALC = 0.083454681437,
            VALE_REFE=  0.083454681437031,
            CRITERE   = 'RELATIF',)

test.printSummary()

FIN()
