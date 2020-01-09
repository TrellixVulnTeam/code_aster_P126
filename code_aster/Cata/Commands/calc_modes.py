# coding=utf-8
# --------------------------------------------------------------------
# Copyright (C) 1991 - 2020 - EDF R&D - www.code-aster.org
# This file is part of code_aster.
#
# code_aster is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# code_aster is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with code_aster.  If not, see <http://www.gnu.org/licenses/>.
# --------------------------------------------------------------------

# person_in_charge: olivier.boiteau at edf.fr

from ..Commons import *
from ..Language.DataStructure import *
from ..Language.Syntax import *


def calc_modes_prod( self, TYPE_RESU, **args) :
   if args.get('__all__'):
       return (mode_flamb, mode_meca, mode_meca_c, mode_acou, mode_gene, ASSD)

   if (TYPE_RESU not in ("DYNAMIQUE","MODE_FLAMB","GENERAL")):
      # on retourne un type fictif pour que le plantage aie lieu dans la lecture du catalogue
      return ASSD
   if TYPE_RESU == "MODE_FLAMB" : return mode_flamb
   if TYPE_RESU == "GENERAL" :    return mode_flamb
   # sinon on est dans le cas 'DYNAMIQUE' donc **args doit contenir les mots-cles
   # MATR_RIGI et (faculativement) MATR_AMOR, et on peut y acceder
   vale_rigi = args['MATR_RIGI']
   vale_mass = args['MATR_MASS']
   if (vale_rigi is None) : # si MATR_RIGI non renseigne
      # on retourne un type fictif pour que le plantage aie lieu dans la lecture du catalogue
      return ASSD
   vale_amor = args.get('MATR_AMOR')
   if ( (AsType(vale_rigi) in (matr_asse_depl_r, matr_asse_depl_c)) & (AsType(vale_mass) in (matr_asse_gene_r, matr_asse_gene_c)) ) :
      raise AsException("Matrices d'entree de types differents : physique / generalisee.")
   if (AsType(vale_amor)== matr_asse_depl_r) : return mode_meca_c
   if (AsType(vale_rigi)== matr_asse_depl_r) : return mode_meca
   if (AsType(vale_rigi)== matr_asse_elim_r) : return mode_meca
   if (AsType(vale_rigi)== matr_asse_temp_r) : return mode_meca
   if (AsType(vale_rigi)== matr_asse_depl_c) : return mode_meca_c
   if (AsType(vale_rigi)== matr_asse_pres_r) : return mode_acou
   if (AsType(vale_rigi)== matr_asse_gene_r) : return mode_gene
   if (AsType(vale_rigi)== matr_asse_gene_c) : return mode_gene

   raise AsException("type de concept resultat non prevu")

CALC_MODES=MACRO(nom="CALC_MODES",
                 op=OPS('Modal.calc_modes_ops.calc_modes_ops'),
                 sd_prod=calc_modes_prod,
                 reentrant='n',
                 fr=tr("Calculer les modes propres ou de flambement d'une structure"),

           TYPE_RESU    =SIMP(statut='f',typ='TXM',defaut="DYNAMIQUE", into=("DYNAMIQUE","MODE_FLAMB","GENERAL"), fr=tr("Type d'analyse")),
           OPTION       =SIMP(statut='f',typ='TXM',defaut="PLUS_PETITE",into=("PLUS_PETITE","PLUS_GRANDE","BANDE","CENTRE","TOUT","SEPARE","AJUSTE","PROCHE"),
                                    fr=tr("Choix de la zone de recherche et par consequent du shift du probleme modal"),),
           STOP_BANDE_VIDE =SIMP(statut='f',typ='TXM',defaut="OUI" ,into=("OUI","NON") ),
           b_solveur_simult = BLOC( condition = """is_in("OPTION", ('PLUS_PETITE','PLUS_GRANDE','BANDE','CENTRE','TOUT'))""",
               SOLVEUR_MODAL =FACT(statut='d',
                   METHODE         =SIMP(statut='f',typ='TXM',defaut="SORENSEN", into=("TRI_DIAG","JACOBI","SORENSEN","QZ") ,),
                   b_tri_diag =BLOC( condition = """equal_to("METHODE", 'TRI_DIAG')""",
                           PREC_ORTHO      =SIMP(statut='f',typ='R',defaut= 1.E-12,val_min=0.E+0 ),
                           NMAX_ITER_ORTHO =SIMP(statut='f',typ='I',defaut= 5,val_min=0 ),
                           PREC_LANCZOS    =SIMP(statut='f',typ='R',defaut= 1.E-8,val_min=0.E+0 ),
                           NMAX_ITER_QR    =SIMP(statut='f',typ='I',defaut= 30,val_min=0 ),
                           MODE_RIGIDE     =SIMP(statut='f',typ='TXM',defaut="NON",into=("OUI","NON"),
                                                 fr=tr("Calcul des modes de corps rigide, uniquement pour la methode TRI_DIAG")),
                   ),
                   b_jacobi =BLOC( condition = """equal_to("METHODE", 'JACOBI')""",
                           PREC_BATHE      =SIMP(statut='f',typ='R',defaut= 1.E-10,val_min=0.E+0 ),
                           NMAX_ITER_BATHE =SIMP(statut='f',typ='I',defaut= 40,val_min=0 ),
                           PREC_JACOBI     =SIMP(statut='f',typ='R',defaut= 1.E-2,val_min=0.E+0 ),
                           NMAX_ITER_JACOBI=SIMP(statut='f',typ='I',defaut= 12,val_min=0 ),
                   ),
                   b_sorensen =BLOC( condition = """equal_to("METHODE", 'SORENSEN')""",
                           PREC_SOREN      =SIMP(statut='f',typ='R',defaut= 0.E+0,val_min=0.E+0 ),
                           NMAX_ITER_SOREN =SIMP(statut='f',typ='I',defaut= 20,val_min=0 ),
                           PARA_ORTHO_SOREN=SIMP(statut='f',typ='R',defaut= 0.717),
                                    ),
                   b_qz =BLOC( condition = """equal_to("METHODE", 'QZ')""",
                           TYPE_QZ      =SIMP(statut='f',typ='TXM',defaut="QZ_SIMPLE",into=("QZ_QR","QZ_SIMPLE","QZ_EQUI") ),
                   ),
                   APPROCHE     =SIMP(statut='f',typ='TXM',defaut="REEL",into=("REEL","IMAG","COMPLEXE"),
                                             fr=tr("Choix du pseudo-produit scalaire pour la resolution du probleme quadratique")),
                   regles=(EXCLUS('DIM_SOUS_ESPACE','COEF_DIM_ESPACE'),),
                   DIM_SOUS_ESPACE =SIMP(statut='f',typ='I'),
                   COEF_DIM_ESPACE =SIMP(statut='f',typ='I'),
              ), # fin mcf_solveur_modal
          ), # fin b_solveur_simult
          b_solveur_inv    = BLOC( condition = """is_in("OPTION", ('SEPARE','AJUSTE','PROCHE'))""",
              SOLVEUR_MODAL =FACT(statut='d',
                     NMAX_ITER_SEPARE=SIMP(statut='f',typ='I' ,defaut= 30,val_min=1 ),
                     PREC_SEPARE     =SIMP(statut='f',typ='R',defaut= 1.E-4,val_min=1.E-70 ),
                     NMAX_ITER_AJUSTE=SIMP(statut='f',typ='I',defaut= 15,val_min=1 ),
                     PREC_AJUSTE     =SIMP(statut='f',typ='R',defaut= 1.E-4,val_min=1.E-70 ),
                     OPTION_INV      =SIMP(statut='f',typ='TXM',defaut="DIRECT",into=("DIRECT","RAYLEIGH") ),
                     PREC_INV        =SIMP(statut='f',typ='R',defaut= 1.E-5,val_min=1.E-70,fr=tr("Precision de convergence")),
                     NMAX_ITER_INV   =SIMP(statut='f',typ='I',defaut= 30,val_min=1 ),
              ), # fin mcf_solveur_modal
          ), # fin b_solveur_inv
#########################################################################################
#  catalogue du cas DYNAMIQUE
#########################################################################################
          b_tout =BLOC(condition = """equal_to("TYPE_RESU", 'DYNAMIQUE') and equal_to("OPTION", 'TOUT')""",
                 MATR_RIGI  =SIMP(statut='o',typ=(matr_asse_depl_r,matr_asse_depl_c,matr_asse_temp_r,
                                                  matr_asse_gene_r,matr_asse_gene_c,matr_asse_pres_r,
                                                  matr_asse_elim_r, ) ),
                 MATR_MASS  =SIMP(statut='o',typ=(matr_asse_depl_r,matr_asse_gene_r,matr_asse_pres_r,
                                                  matr_asse_temp_r, matr_asse_elim_r ) ),
                 MATR_AMOR  =SIMP(statut='f',typ=(matr_asse_depl_r,matr_asse_gene_r ) ),
                 CALC_FREQ  =FACT(statut='d',
                        NMAX_FREQ  =SIMP(statut='f',typ='I',defaut=10,val_min=0 ),
                        NMAX_ITER_SHIFT =SIMP(statut='f',typ='I',defaut= 3,val_min=0 ),
                        PREC_SHIFT      =SIMP(statut='f',typ='R',defaut= 5.E-2,val_min=0.E+0 ),
                        SEUIL_FREQ      =SIMP(statut='f',typ='R',defaut= 1.E-2,val_min=0.E+0 ),
                 ), # fin mcf_calc_freq
                 b_dyn_phys_0 =BLOC( condition= """is_type("MATR_RIGI") == matr_asse_depl_r""",
                        NORM_MODE  =FACT(statut='f',
                          NORME     =SIMP(statut='f',typ='TXM',defaut="TRAN_ROTA",
                                          into=("MASS_GENE","RIGI_GENE","EUCL","EUCL_TRAN","TRAN","TRAN_ROTA") ),
                          INFO      =SIMP(statut='f',typ='I',defaut= 1 ,into=(1,2) ),
                        ),
                        FILTRE_MODE=FACT(statut='f',
                          CRIT_EXTR =SIMP(statut='f',typ='TXM',defaut="MASS_EFFE_UN", into=("MASS_EFFE_UN","MASS_GENE") ),
                          SEUIL     =SIMP(statut='f',typ='R',defaut= 1.E-3 ),
                        ),
                        IMPRESSION =FACT(statut='f',
                          TOUT_PARA       =SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON") ),
                          CUMUL           =SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON") ),
                          CRIT_EXTR       =SIMP(statut='f',typ='TXM',defaut="MASS_EFFE_UN", into=("MASS_EFFE_UN","MASS_GENE",) ),
                        ),
                 ), # fin b_dyn_phys_0
                 SOLVEUR =C_SOLVEUR('MODE_ITER_SIMULT'),
          ), # fin b_tout
          b_plus_petite =BLOC(condition = """equal_to("TYPE_RESU", 'DYNAMIQUE') and equal_to("OPTION", 'PLUS_PETITE')""",
                        fr=tr("Recherche des plus petites frequences propres"),
                   MATR_RIGI  =SIMP(statut='o',typ=(matr_asse_depl_r,matr_asse_depl_c,matr_asse_temp_r,
                                                    matr_asse_gene_r,matr_asse_gene_c,matr_asse_pres_r,
                                                    matr_asse_elim_r, ) ),
                   MATR_MASS  =SIMP(statut='o',typ=(matr_asse_depl_r,matr_asse_gene_r,matr_asse_pres_r,
                                                    matr_asse_temp_r, matr_asse_elim_r ) ),
                   MATR_AMOR  =SIMP(statut='f',typ=(matr_asse_depl_r,matr_asse_gene_r ) ),
                   CALC_FREQ  =FACT(statut='d',
                        NMAX_FREQ  =SIMP(statut='f',typ='I',defaut=10,val_min=0 ),
                        NMAX_ITER_SHIFT =SIMP(statut='f',typ='I',defaut= 3,val_min=0 ),
                        PREC_SHIFT      =SIMP(statut='f',typ='R',defaut= 5.E-2,val_min=0.E+0 ),
                        SEUIL_FREQ      =SIMP(statut='f',typ='R',defaut= 1.E-2,val_min=0.E+0 ),
                   ), # fin mcf_calc_freq
                   b_dyn_phys_1 =BLOC( condition= """is_type("MATR_RIGI") == matr_asse_depl_r""",
                        NORM_MODE  =FACT(statut='f',
                          NORME     =SIMP(statut='f',typ='TXM',defaut="TRAN_ROTA",
                                          into=("MASS_GENE","RIGI_GENE","EUCL","EUCL_TRAN","TRAN","TRAN_ROTA") ),
                          INFO      =SIMP(statut='f',typ='I',defaut= 1 ,into=(1,2) ),
                        ),
                        FILTRE_MODE=FACT(statut='f',
                          CRIT_EXTR =SIMP(statut='f',typ='TXM',defaut="MASS_EFFE_UN", into=("MASS_EFFE_UN","MASS_GENE") ),
                          SEUIL     =SIMP(statut='f',typ='R',defaut= 1.E-3 ),
                        ),
                        IMPRESSION =FACT(statut='f',
                          TOUT_PARA       =SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON") ),
                          CUMUL           =SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON") ),
                          CRIT_EXTR       =SIMP(statut='f',typ='TXM',defaut="MASS_EFFE_UN", into=("MASS_EFFE_UN","MASS_GENE",) ),
                        ),
                   ), # fin b_dyn_phys_1
                   SOLVEUR =C_SOLVEUR('MODE_ITER_SIMULT'),
          ), # fin b_plus_petite
          b_plus_grande =BLOC(condition = """equal_to("TYPE_RESU", 'DYNAMIQUE') and equal_to("OPTION", 'PLUS_GRANDE')""",
                                fr=tr("Recherche des plus grandes frequences propres"),
                   MATR_RIGI  =SIMP(statut='o',typ=(matr_asse_depl_r,matr_asse_depl_c,matr_asse_temp_r,
                                                    matr_asse_gene_r,matr_asse_gene_c,matr_asse_pres_r,
                                                    matr_asse_elim_r ) ),
                   MATR_MASS  =SIMP(statut='o',typ=(matr_asse_depl_r,matr_asse_gene_r,matr_asse_pres_r,
                                                    matr_asse_temp_r, matr_asse_elim_r ) ),
                   MATR_AMOR  =SIMP(statut='f',typ=(matr_asse_depl_r,matr_asse_gene_r) ),
                   CALC_FREQ  =FACT(statut='d',
                       NMAX_FREQ  =SIMP(statut='f',typ='I',defaut=1,val_min=0 ),
                       NMAX_ITER_SHIFT =SIMP(statut='f',typ='I',defaut= 3,val_min=0 ),
                       PREC_SHIFT      =SIMP(statut='f',typ='R',defaut= 5.E-2,val_min=0.E+0 ),
                       SEUIL_FREQ      =SIMP(statut='f',typ='R',defaut= 1.E-2,val_min=0.E+0 ),
                   ), # fin mcf_calc_freq
                   b_dyn_phys_2 =BLOC( condition= """is_type("MATR_RIGI") == matr_asse_depl_r""",
                        NORM_MODE  =FACT(statut='f',
                          NORME     =SIMP(statut='f',typ='TXM',defaut="TRAN_ROTA",
                                          into=("MASS_GENE","RIGI_GENE","EUCL","EUCL_TRAN","TRAN","TRAN_ROTA") ),
                          INFO      =SIMP(statut='f',typ='I',defaut= 1 ,into=(1,2) ),
                        ),
                        FILTRE_MODE=FACT(statut='f',
                          CRIT_EXTR =SIMP(statut='f',typ='TXM',defaut="MASS_EFFE_UN", into=("MASS_EFFE_UN","MASS_GENE") ),
                          SEUIL     =SIMP(statut='f',typ='R',defaut= 1.E-3 ),
                        ),
                        IMPRESSION =FACT(statut='f',
                          TOUT_PARA       =SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON") ),
                          CUMUL           =SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON") ),
                          CRIT_EXTR       =SIMP(statut='f',typ='TXM',defaut="MASS_EFFE_UN", into=("MASS_EFFE_UN","MASS_GENE",) ),
                        ),
                   ), # fin b_dyn_phys_2
                   SOLVEUR =C_SOLVEUR('MODE_ITER_SIMULT'),
          ), # fin b_plus_grande
          b_centre      =BLOC(condition = """equal_to("TYPE_RESU", 'DYNAMIQUE') and equal_to("OPTION", 'CENTRE')""",
                                fr=tr("Recherche des frequences propres les plus proches d'une valeur donnee"),
                   MATR_RIGI  =SIMP(statut='o',typ=(matr_asse_depl_r,matr_asse_depl_c,matr_asse_temp_r,
                                                    matr_asse_gene_r,matr_asse_gene_c,matr_asse_pres_r,
                                                    matr_asse_elim_r ) ),
                   MATR_MASS  =SIMP(statut='o',typ=(matr_asse_depl_r,matr_asse_gene_r,matr_asse_pres_r,
                                                    matr_asse_temp_r, matr_asse_elim_r ) ),
                   MATR_AMOR  =SIMP(statut='f',typ=(matr_asse_depl_r,matr_asse_gene_r) ),
                   CALC_FREQ  =FACT(statut='d',
                       FREQ       =SIMP(statut='o',typ='R', fr=tr("Frequence autour de laquelle on cherche les frequences propres")),
                       AMOR_REDUIT=SIMP(statut='f',typ='R',),
                       NMAX_FREQ  =SIMP(statut='f',typ='I',defaut= 10,val_min=0 ),
                       NMAX_ITER_SHIFT =SIMP(statut='f',typ='I',defaut= 3,val_min=0 ),
                       PREC_SHIFT      =SIMP(statut='f',typ='R',defaut= 5.E-2,val_min=0.E+0 ),
                       SEUIL_FREQ      =SIMP(statut='f',typ='R',defaut= 1.E-2,val_min=0.E+0 ),
                   ), # fin mcf_calc_freq
                   b_dyn_phys_3 =BLOC( condition= """is_type("MATR_RIGI") == matr_asse_depl_r""",
                        NORM_MODE  =FACT(statut='f',
                          NORME     =SIMP(statut='f',typ='TXM',defaut="TRAN_ROTA",
                                          into=("MASS_GENE","RIGI_GENE","EUCL","EUCL_TRAN","TRAN","TRAN_ROTA") ),
                          INFO      =SIMP(statut='f',typ='I',defaut= 1 ,into=(1,2) ),
                        ),
                        FILTRE_MODE=FACT(statut='f',
                          CRIT_EXTR =SIMP(statut='f',typ='TXM',defaut="MASS_EFFE_UN", into=("MASS_EFFE_UN","MASS_GENE") ),
                          SEUIL     =SIMP(statut='f',typ='R',defaut= 1.E-3 ),
                        ),
                        IMPRESSION =FACT(statut='f',
                          TOUT_PARA       =SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON") ),
                          CUMUL           =SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON") ),
                          CRIT_EXTR       =SIMP(statut='f',typ='TXM',defaut="MASS_EFFE_UN", into=("MASS_EFFE_UN","MASS_GENE",) ),
                        ),
                   ), # fin b_dyn_phys_3
                   SOLVEUR =C_SOLVEUR('MODE_ITER_SIMULT'),
          ), # fin b_centre
          b_bande       =BLOC(condition = """equal_to("TYPE_RESU", 'DYNAMIQUE') and equal_to("OPTION", 'BANDE')""",
                                fr=tr("Recherche des frequences propres dans une bande donnee"),
                   MATR_RIGI  =SIMP(statut='o',typ=(matr_asse_depl_r,matr_asse_depl_c,matr_asse_temp_r,
                                                    matr_asse_gene_r,matr_asse_gene_c,matr_asse_pres_r,
                                                    matr_asse_elim_r ) ),
                   MATR_MASS  =SIMP(statut='o',typ=(matr_asse_depl_r,matr_asse_gene_r,matr_asse_pres_r,
                                                    matr_asse_temp_r, matr_asse_elim_r ) ),
                   MATR_AMOR  =SIMP(statut='f',typ=(matr_asse_depl_r,matr_asse_gene_r ) ),
                   CALC_FREQ  =FACT(statut='d',
                       FREQ       =SIMP(statut='o',typ='R',min=2,max='**', validators=AndVal((OrdList('croissant'), NoRepeat())),
                                      fr=tr("Valeurs des frequences delimitant la (les) bande(s) de recherche")),
                       TABLE_FREQ =SIMP(statut= 'f',typ=table_sdaster),
                       b_multi_bande =BLOC( condition= """size('FREQ') > 2""",
                           NIVEAU_PARALLELISME  =SIMP(statut='f',typ='TXM',defaut="COMPLET",into=("PARTIEL","COMPLET") ),
                       ),
                       NMAX_ITER_SHIFT =SIMP(statut='f',typ='I',defaut= 3,val_min=0 ),
                       PREC_SHIFT      =SIMP(statut='f',typ='R',defaut= 5.E-2,val_min=0.E+0 ),
                       SEUIL_FREQ      =SIMP(statut='f',typ='R',defaut= 1.E-2,val_min=0.E+0 ),
                   ), # fin mcf_calc_freq
                   b_dyn_phys_4 =BLOC( condition= """is_type("MATR_RIGI") == matr_asse_depl_r""",
                        NORM_MODE  =FACT(statut='f',
                          NORME     =SIMP(statut='f',typ='TXM',defaut="TRAN_ROTA",
                                          into=("MASS_GENE","RIGI_GENE","EUCL","EUCL_TRAN","TRAN","TRAN_ROTA") ),
                          INFO      =SIMP(statut='f',typ='I',defaut= 1 ,into=(1,2) ),
                        ),
                        FILTRE_MODE=FACT(statut='f',
                          CRIT_EXTR =SIMP(statut='f',typ='TXM',defaut="MASS_EFFE_UN", into=("MASS_EFFE_UN","MASS_GENE") ),
                          SEUIL     =SIMP(statut='f',typ='R',defaut= 1.E-3 ),
                        ),
                        IMPRESSION =FACT(statut='f',
                          TOUT_PARA       =SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON") ),
                          CUMUL           =SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON") ),
                          CRIT_EXTR       =SIMP(statut='f',typ='TXM',defaut="MASS_EFFE_UN", into=("MASS_EFFE_UN","MASS_GENE",) ),
                        ),
                   ), # fin b_dyn_phys_4
                   SOLVEUR =C_SOLVEUR('MODE_ITER_SIMULT'),
          ), # fin b_bande
          b_param_inv_dyn1 = BLOC( condition = """equal_to("TYPE_RESU", 'DYNAMIQUE') and equal_to("OPTION", 'PROCHE')""",
                   MATR_RIGI  =SIMP(statut='o',typ=(matr_asse_depl_r,matr_asse_depl_c,matr_asse_temp_r,
                                                    matr_asse_gene_r,matr_asse_gene_c,matr_asse_pres_r,
                                                    matr_asse_elim_r ) ),
                   MATR_MASS  =SIMP(statut='o',typ=(matr_asse_depl_r,matr_asse_gene_r,matr_asse_pres_r,
                                                    matr_asse_temp_r, matr_asse_elim_r ) ),
                   MATR_AMOR  =SIMP(statut='f',typ=(matr_asse_depl_r,matr_asse_gene_r ) ),
                   CALC_FREQ  =FACT(statut='d',
                       FREQ            =SIMP(statut='o',typ='R',max='**',validators=AndVal((OrdList('croissant'), NoRepeat())),),
                       AMOR_REDUIT     =SIMP(statut='f',typ='R',max='**'),
                       NMAX_FREQ       =SIMP(statut='f',typ='I',defaut= 0,val_min=0 ), # il faudra supprimer la valeur par defaut qui est inutile car ignore dans le fortran
                       NMAX_ITER_SHIFT =SIMP(statut='f',typ='I',defaut= 3,val_min=0 ),
                       PREC_SHIFT      =SIMP(statut='f',typ='R',defaut= 5.E-2,val_min=0.E+0 ),
                       SEUIL_FREQ      =SIMP(statut='f',typ='R',defaut= 1.E-2,val_min=0.E+0 ),
                   ),# fin mcf_calc_freq
                   b_dyn_phys_5 =BLOC( condition= """is_type("MATR_RIGI") == matr_asse_depl_r""",
                        NORM_MODE  =FACT(statut='f',
                          NORME     =SIMP(statut='f',typ='TXM',defaut="TRAN_ROTA",
                                          into=("MASS_GENE","RIGI_GENE","EUCL","EUCL_TRAN","TRAN","TRAN_ROTA") ),
                          INFO      =SIMP(statut='f',typ='I',defaut= 1 ,into=(1,2) ),
                        ),
                        FILTRE_MODE=FACT(statut='f',
                          CRIT_EXTR =SIMP(statut='f',typ='TXM',defaut="MASS_EFFE_UN", into=("MASS_EFFE_UN","MASS_GENE") ),
                          SEUIL     =SIMP(statut='f',typ='R',defaut= 1.E-3 ),
                        ),
                        IMPRESSION =FACT(statut='f',
                          TOUT_PARA       =SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON") ),
                          CUMUL           =SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON") ),
                          CRIT_EXTR       =SIMP(statut='f',typ='TXM',defaut="MASS_EFFE_UN", into=("MASS_EFFE_UN","MASS_GENE",) ),
                        ),
                   ), # fin b_dyn_phys_5
                   SOLVEUR =C_SOLVEUR('MODE_ITER_INV'),
          ), # fin b_param_inv_dyn1
          b_param_inv_dyn2 = BLOC( condition = """equal_to("TYPE_RESU", 'DYNAMIQUE') and is_in("OPTION", ('SEPARE','AJUSTE'))""",
                   MATR_RIGI  =SIMP(statut='o',typ=(matr_asse_depl_r,matr_asse_depl_c,matr_asse_temp_r,
                                                    matr_asse_gene_r,matr_asse_gene_c,matr_asse_pres_r,
                                                    matr_asse_elim_r ) ),
                   MATR_MASS  =SIMP(statut='o',typ=(matr_asse_depl_r,matr_asse_gene_r,matr_asse_pres_r,
                                                    matr_asse_temp_r, matr_asse_elim_r ) ),
                   MATR_AMOR  =SIMP(statut='f',typ=(matr_asse_depl_r,matr_asse_gene_r ) ),
                   CALC_FREQ  =FACT(statut='d',
                       FREQ            =SIMP(statut='o',typ='R',max='**',validators=AndVal((OrdList('croissant'), NoRepeat())),),
                       AMOR_REDUIT     =SIMP(statut='f',typ='R',max='**'),
                       NMAX_FREQ       =SIMP(statut='f',typ='I',defaut= 0,val_min=0 ), # il faudra supprimer la valeur par defaut qui est inutile car ignore dans le fortran
                       NMAX_ITER_SHIFT =SIMP(statut='f',typ='I',defaut= 3,val_min=0 ),
                       PREC_SHIFT      =SIMP(statut='f',typ='R',defaut= 5.E-2,val_min=0.E+0 ),
                       SEUIL_FREQ      =SIMP(statut='f',typ='R',defaut= 1.E-2,val_min=0.E+0 ),
                   ),# fin mcf_calc_freq
                   b_dyn_phys_5 =BLOC( condition= """is_type("MATR_RIGI") == matr_asse_depl_r""",
                        NORM_MODE  =FACT(statut='f',
                          NORME     =SIMP(statut='f',typ='TXM',defaut="TRAN_ROTA",
                                          into=("MASS_GENE","RIGI_GENE","EUCL","EUCL_TRAN","TRAN","TRAN_ROTA") ),
                          INFO      =SIMP(statut='f',typ='I',defaut= 1 ,into=(1,2) ),
                        ),
                        FILTRE_MODE=FACT(statut='f',
                          CRIT_EXTR =SIMP(statut='f',typ='TXM',defaut="MASS_EFFE_UN", into=("MASS_EFFE_UN","MASS_GENE") ),
                          SEUIL     =SIMP(statut='f',typ='R',defaut= 1.E-3 ),
                        ),
                        IMPRESSION =FACT(statut='f',
                          TOUT_PARA       =SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON") ),
                          CUMUL           =SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON") ),
                          CRIT_EXTR       =SIMP(statut='f',typ='TXM',defaut="MASS_EFFE_UN", into=("MASS_EFFE_UN","MASS_GENE",) ),
                        ),
                   ), # fin b_dyn_phys_5
                   #SI GEP LES TROIS SOLVEURS LINEAIRES DIRECTS SONT POSSIBLES
                   b_solveur_lin_inv1    =BLOC(condition = """not exists("MATR_AMOR")""",
                     SOLVEUR =C_SOLVEUR('MODE_ITER_INV'),
                   ),
                   #SI QEP ON ENLEVE MUMPS CAR IL EST HORS PERIMETRE (..._SansMumps)
                   b_solveur_lin_inv2    =BLOC(condition = """exists("MATR_AMOR")""",
                     SOLVEUR =C_SOLVEUR('MODE_ITER_INV_SM'),
                   ),
          ), # fin b_param_inv_dyn2
          # operandes de post-traitement
          b_dyn_phys_1 =BLOC( condition= """is_type("MATR_RIGI")==matr_asse_depl_r""",
              NORM_MODE  =FACT(statut='f',
                  NORME     =SIMP(statut='f',typ='TXM',defaut="TRAN_ROTA",
                                  into=("MASS_GENE","RIGI_GENE","EUCL","EUCL_TRAN","TRAN","TRAN_ROTA") ),
                  INFO      =SIMP(statut='f',typ='I',defaut= 1 ,into=(1,2) ),
                              ),
              FILTRE_MODE=FACT(statut='f',
                  CRIT_EXTR =SIMP(statut='f',typ='TXM',defaut="MASS_EFFE_UN",
                                  into=("MASS_EFFE_UN","MASS_GENE") ),
                  SEUIL     =SIMP(statut='f',typ='R',defaut= 1.E-3 ),
                               ),
              IMPRESSION =FACT(statut='f',
                  TOUT_PARA       =SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON") ),
                  CUMUL           =SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON") ),
                  CRIT_EXTR       =SIMP(statut='f',typ='TXM',defaut="MASS_EFFE_UN",
                                        into=("MASS_EFFE_UN","MASS_GENE",) ),
              ),
          ), # fin b_dyn_phys_1
#########################################################################################
#  catalogue des cas MODE_FLAMB et GENERAL
#########################################################################################
          b_flamb    =BLOC(condition = """equal_to("TYPE_RESU", 'MODE_FLAMB')""",
                 MATR_RIGI      =SIMP(statut='o',typ=(matr_asse_depl_r,matr_asse_gene_r,matr_asse_pres_r ) ),
                 MATR_RIGI_GEOM =SIMP(statut='o',typ=(matr_asse_depl_r,matr_asse_gene_r,matr_asse_pres_r ) ),
                 NORM_MODE      =FACT(statut='f',
                                      NORME     =SIMP(statut='f',typ='TXM',defaut="TRAN_ROTA",
                                                      into=("MASS_GENE","RIGI_GENE","EUCL","EUCL_TRAN","TRAN","TRAN_ROTA") ),
                                      INFO      =SIMP(statut='f',typ='I',defaut= 1 ,into=(1,2) ),
                                      ),
          ),
          b_general  =BLOC(condition = """equal_to("TYPE_RESU", 'GENERAL')""",
                 MATR_A         =SIMP(statut='o',typ=(matr_asse_depl_r,matr_asse_gene_r,matr_asse_pres_r ) ),
                 MATR_B         =SIMP(statut='o',typ=(matr_asse_depl_r,matr_asse_gene_r,matr_asse_pres_r ) ),
                 NORM_MODE      =FACT(statut='f',
                                      NORME     =SIMP(statut='f',typ='TXM',defaut="TRAN_ROTA",
                                                      into=("MASS_GENE","RIGI_GENE","EUCL","EUCL_TRAN","TRAN","TRAN_ROTA") ),
                                      INFO      =SIMP(statut='f',typ='I',defaut= 1 ,into=(1,2) ),
                                      ),
          ),

          b_tout_flamb =BLOC(condition = """is_in("TYPE_RESU", ('MODE_FLAMB','GENERAL')) and equal_to("OPTION", 'TOUT')""",
            CALC_CHAR_CRIT  =FACT(statut='d',
                              fr=tr("Recherche des plus petites valeurs propres"),
                  NMAX_CHAR_CRIT =SIMP(statut='f',typ='I',defaut= 10,val_min=0 ),
                  NMAX_ITER_SHIFT=SIMP(statut='f',typ='I',defaut= 3,val_min=0 ),
                  PREC_SHIFT     =SIMP(statut='f',typ='R',defaut= 5.E-2,val_min=0.E+0 ),
                  SEUIL_CHAR_CRIT=SIMP(statut='f',typ='R',defaut= 1.E-2,val_min=0.E+0 ),
            ), # fin mcf_calc_char_crit
            SOLVEUR =C_SOLVEUR('MODE_ITER_SIMULT'),
          ),# fin b_tout_flamb
          b_plus_petite_flamb =BLOC(condition = """is_in("TYPE_RESU", ('MODE_FLAMB','GENERAL')) and equal_to("OPTION", 'PLUS_PETITE')""",
            CALC_CHAR_CRIT  =FACT(statut='d',
                              fr=tr("Recherche des plus petites valeurs propres"),
                  NMAX_CHAR_CRIT =SIMP(statut='f',typ='I',defaut= 10,val_min=0 ),
                  NMAX_ITER_SHIFT=SIMP(statut='f',typ='I',defaut= 3,val_min=0 ),
                  PREC_SHIFT     =SIMP(statut='f',typ='R',defaut= 5.E-2,val_min=0.E+0 ),
                  SEUIL_CHAR_CRIT=SIMP(statut='f',typ='R',defaut= 1.E-2,val_min=0.E+0 ),
            ), # fin mcf_calc_char_crit
            SOLVEUR =C_SOLVEUR('MODE_ITER_SIMULT'),
          ),# fin b_plus_petite_flamb
          b_centre_flamb    =BLOC(condition = """is_in("TYPE_RESU", ('MODE_FLAMB','GENERAL')) and equal_to("OPTION", 'CENTRE')""",
                            fr=tr("Recherche des valeurs propres les plus proches d'une valeur donnee"),
            CALC_CHAR_CRIT  =FACT(statut='d',
                  CHAR_CRIT      =SIMP(statut='o',typ='R', fr=tr("Charge critique autour de laquelle on cherche les charges critiques propres")),
                  NMAX_CHAR_CRIT =SIMP(statut='f',typ='I', defaut= 10,val_min=0 ),
                  NMAX_ITER_SHIFT=SIMP(statut='f',typ='I',defaut= 3,val_min=0 ),
                  PREC_SHIFT     =SIMP(statut='f',typ='R',defaut= 5.E-2,val_min=0.E+0 ),
                  SEUIL_CHAR_CRIT=SIMP(statut='f',typ='R',defaut= 1.E-2,val_min=0.E+0 ),
            ), # fin mcf_calc_char_crit
            SOLVEUR =C_SOLVEUR('MODE_ITER_SIMULT'),
          ),# fin b_centre_flamb
          b_bande_flamb     =BLOC(condition = """is_in("TYPE_RESU", ('MODE_FLAMB','GENERAL')) and equal_to("OPTION", 'BANDE')""",
                            fr=tr("Recherche des valeurs propres dans une bande donnee"),
            CALC_CHAR_CRIT  =FACT(statut='d',
                  CHAR_CRIT      =SIMP(statut='o',typ='R',min=2,max=2,
                                       validators=AndVal((OrdList('croissant'), NoRepeat())),
                                       fr=tr("Valeur des deux charges critiques delimitant la bande de recherche")),
                  TABLE_CHAR_CRIT=SIMP(statut= 'f',typ=table_sdaster),
                  NMAX_ITER_SHIFT=SIMP(statut='f',typ='I',defaut= 3,val_min=0 ),
                  PREC_SHIFT     =SIMP(statut='f',typ='R',defaut= 5.E-2,val_min=0.E+0 ),
                  SEUIL_CHAR_CRIT=SIMP(statut='f',typ='R',defaut= 1.E-2,val_min=0.E+0 ),
            ), # fin mcf_calc_char_crit
            SOLVEUR =C_SOLVEUR('MODE_ITER_SIMULT'),
          ),# fin b_bande_flamb
          b_param_inv_flamb_gen =BLOC(condition = """is_in("TYPE_RESU", ('MODE_FLAMB','GENERAL')) and is_in("OPTION", ('SEPARE','AJUSTE','PROCHE'))""",
            CALC_CHAR_CRIT  =FACT(statut='d',
                  CHAR_CRIT      =SIMP(statut='o',typ='R',max='**', validators=AndVal((OrdList('croissant'), NoRepeat())),),
                  NMAX_CHAR_CRIT =SIMP(statut='f',typ='I',defaut= 0,val_min=0 ),
                  NMAX_ITER_SHIFT=SIMP(statut='f',typ='I',defaut= 3,val_min=0 ),
                  PREC_SHIFT     =SIMP(statut='f',typ='R',defaut= 5.E-2,val_min=0.E+0 ),
                  SEUIL_CHAR_CRIT=SIMP(statut='f',typ='R',defaut= 1.E-2,val_min=0.E+0 ),
            ), # fin mcf_calc_char_crit
            SOLVEUR =C_SOLVEUR('MODE_ITER_INV'),
          ),# fin b_param_inv_flamb_gen

#        Verification a posteriori
           b_sturm_simult=BLOC( condition = """(is_in("OPTION", ('PLUS_PETITE','PLUS_GRANDE','CENTRE','TOUT')) or (not equal_to("TYPE_RESU", 'DYNAMIQUE') and equal_to("OPTION", 'BANDE')))""",
             VERI_MODE =FACT(statut='d',
               STOP_ERREUR =SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON") ),
               SEUIL        =SIMP(statut='f',typ='R',val_min=0.E+0,defaut=1.e-6,
                                  fr=tr("Valeur limite admise pour l'erreur a posteriori des modes")),
               PREC_SHIFT  =SIMP(statut='f',typ='R',defaut= 5.E-3,val_min=0.E+0 ),
               STURM       =SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON") ),
             ), #fin mcf_veri_mode
           ), # fin b_sturm_simult
           b_sturm_bande =BLOC( condition = """equal_to("TYPE_RESU", 'DYNAMIQUE') and equal_to("OPTION", 'BANDE')""",
             VERI_MODE =FACT(statut='d',
               STOP_ERREUR =SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON") ),
               SEUIL        =SIMP(statut='f',typ='R',val_min=0.E+0,defaut=1.e-6,
                                  fr=tr("Valeur limite admise pour l'erreur a posteriori des modes")),
               PREC_SHIFT  =SIMP(statut='f',typ='R',defaut= 5.E-3,val_min=0.E+0 ),
               STURM       =SIMP(statut='f',typ='TXM',defaut="GLOBAL",into=("GLOBAL","LOCAL","OUI","NON") ),
             ), #fin mcf_veri_mode
           ), # fin b_sturm_bande
         b_veri_mode_inv = BLOC( condition = """is_in("OPTION", ('SEPARE','AJUSTE','PROCHE'))""",
           VERI_MODE =FACT(statut='d',
             STOP_ERREUR =SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON") ),
             SEUIL       =SIMP(statut='f',typ='R',val_min=0.E+0,defaut=1.e-2,
                                       fr=tr("Valeur limite admise pour l'erreur a posteriori des modes")),
             PREC_SHIFT  =SIMP(statut='f',typ='R',defaut= 5.E-3,val_min=0.E+0 ),
             STURM       =SIMP(statut='f',typ='TXM',defaut="NON",into=("OUI","NON") ),
           ), #fin mcf_veri_mode
         ),# fin b_veri_mode_inv

#########################################################################################
#        Amelioration de la qualite des modes
         AMELIORATION=SIMP(statut='f',typ='TXM',defaut="NON",into=("OUI","NON"), ),
#########################################################################################
         INFO       =SIMP(statut='f',typ='I',defaut=1,into=(1,2) ),
         TITRE      =SIMP(statut='f',typ='TXM'),
);
