# code_aster.Commands compatibility package

__all__ = ['_F',             'AFFE_CARA_ELEM', 'AFFE_CHAR_CINE', 'AFFE_CHAR_MECA', 'AFFE_MATERIAU',
           'AFFE_MODELE',    'ASSE_MATRICE',   'CALC_MATR_ELEM', 'COMB_FOURIER',
           'CREA_CHAMP',     'CREA_RESU',      'CREA_TABLE',     'DEFI_COMPOR',    'DEFI_FISS_XFEM',
           'DEFI_FONCTION',  'DEFI_FOND_FISS', 'DEFI_GEOM_FIBRE','DEFI_GRILLE',    'DEFI_INTE_SPEC',
           'DEFI_LIST_REEL', 'DEFI_MATERIAU',  'LIRE_MAILLAGE',  'MECA_STATIQUE',
           'MODE_STATIQUE',  'NUME_DDL',       'PROJ_CHAMP',
          ]

from code_aster.Cata.Syntax import _F

from code_aster.Commands.affe_cara_elem import AFFE_CARA_ELEM
from code_aster.Commands.affe_char_cine import AFFE_CHAR_CINE
from code_aster.Commands.affe_char_meca import AFFE_CHAR_MECA
from code_aster.Commands.affe_materiau import AFFE_MATERIAU
from code_aster.Commands.affe_modele import AFFE_MODELE
from code_aster.Commands.asse_matrice import ASSE_MATRICE
from code_aster.Commands.calc_matr_elem import CALC_MATR_ELEM
from code_aster.Commands.comb_fourier import COMB_FOURIER
from code_aster.Commands.crea_champ import CREA_CHAMP
from code_aster.Commands.crea_resu import CREA_RESU
from code_aster.Commands.crea_table import CREA_TABLE
from code_aster.Commands.defi_compor import DEFI_COMPOR
from code_aster.Commands.defi_fonction import DEFI_FONCTION
from code_aster.Commands.defi_fond_fiss import DEFI_FOND_FISS
from code_aster.Commands.defi_geom_fibre import DEFI_GEOM_FIBRE
from code_aster.Commands.defi_grille import DEFI_GRILLE
from code_aster.Commands.defi_inte_spec import DEFI_INTE_SPEC
from code_aster.Commands.defi_list_reel import DEFI_LIST_REEL
from code_aster.Commands.defi_materiau import DEFI_MATERIAU
from code_aster.Commands.lire_maillage import LIRE_MAILLAGE
from code_aster.Commands.meca_statique import MECA_STATIQUE
from code_aster.Commands.defi_fiss_xfem import DEFI_FISS_XFEM
from code_aster.Commands.mode_statique import MODE_STATIQUE
from code_aster.Commands.nume_ddl import NUME_DDL
from code_aster.Commands.proj_champ import PROJ_CHAMP
