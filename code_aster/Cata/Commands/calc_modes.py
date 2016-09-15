# coding=utf-8

from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *

# ======================================================================
# COPYRIGHT (C) 1991 - 2016  EDF R&D                  WWW.CODE-ASTER.ORG
# THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
# IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
# THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
# (AT YOUR OPTION) ANY LATER VERSION.
#
# THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
# WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
# MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
# GENERAL PUBLIC LICENSE FOR MORE DETAILS.
#
# YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
# ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
#    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
# ======================================================================
# person_in_charge: nicolas.brie at edf.fr

def calc_modes_prod( self, TYPE_RESU, **args) :
   if (TYPE_RESU not in ("DYNAMIQUE","MODE_FLAMB","GENERAL")):
      # on retourne un type fictif pour que le plantage aie lieu dans la lecture du catalogue
      return ASSD
   if TYPE_RESU == "MODE_FLAMB" : return mode_flamb
   if TYPE_RESU == "GENERAL" :    return mode_flamb
   # sinon on est dans le cas 'DYNAMIQUE' donc **args doit contenir les mots-clés
   # MATR_RIGI et (faculativement) MATR_AMOR, et on peut y accéder
   vale_rigi = args['MATR_RIGI']
   vale_mass = args['MATR_MASS']
   if (vale_rigi== None) : # si MATR_RIGI non renseigné
      # on retourne un type fictif pour que le plantage aie lieu dans la lecture du catalogue
      return ASSD
   vale_amor = args['MATR_AMOR']
   if ( (AsType(vale_rigi) in (matr_asse_depl_r, matr_asse_depl_c)) & (AsType(vale_mass) in (matr_asse_gene_r, matr_asse_gene_c)) ) :
      raise AsException("Matrices d'entrée de types différents : physique / généralisée.")
   if (AsType(vale_amor)== matr_asse_depl_r) : return mode_meca_c
   if (AsType(vale_rigi)== matr_asse_depl_r) : return mode_meca
   if (AsType(vale_rigi)== matr_asse_temp_r) : return mode_meca
   if (AsType(vale_rigi)== matr_asse_depl_c) : return mode_meca_c
   if (AsType(vale_rigi)== matr_asse_pres_r) : return mode_acou
   if (AsType(vale_rigi)== matr_asse_gene_r) : return mode_gene
   if (AsType(vale_rigi)== matr_asse_gene_c) : return mode_gene

   raise AsException("type de concept résultat non prevu")


CALC_MODES=MACRO(nom="CALC_MODES",
                 op=OPS('Modal.calc_modes_ops.calc_modes_ops'),
                 sd_prod=calc_modes_prod,
                 reentrant='n',
                 fr=tr("Calculer les modes propres ou de flambement d'une structure"),
                 UIinfo={"groupes":("Résolution","Dynamique",)},

                 TYPE_RESU    =SIMP(statut='f',typ='TXM',defaut="DYNAMIQUE", into=("DYNAMIQUE","MODE_FLAMB","GENERAL"),
                                    fr=tr("Type d'analyse"), position='global'),

                 OPTION       =SIMP(statut='d',typ='TXM',defaut="PLUS_PETITE",into=("PLUS_PETITE","PLUS_GRANDE","BANDE","CENTRE","TOUT","SEPARE","AJUSTE","PROCHE"),
                                    fr=tr("Choix de la zone de recherche et par conséquent du shift du problème modal"), position='global'),

         # b_bande = BLOC( condition = "(TYPE_RESU != 'DYNAMIQUE') or (TYPE_RESU == 'DYNAMIQUE' and OPTION != 'BANDE')",
         b_bande = BLOC( condition = "not(TYPE_RESU == 'DYNAMIQUE' and OPTION == 'BANDE')",
                 STOP_BANDE_VIDE =SIMP(statut='f',typ='TXM',defaut="OUI" ,into=("OUI","NON") ),
                        ),

                 SOLVEUR_MODAL =FACT(statut='d',
             b_solveur_simult = BLOC( condition = "OPTION in ('PLUS_PETITE','PLUS_GRANDE','BANDE','CENTRE','TOUT')",
                     METHODE         =SIMP(statut='f',typ='TXM',defaut="SORENSEN",
                                           into=("TRI_DIAG","JACOBI","SORENSEN","QZ") ),
             b_tri_diag =BLOC( condition = "METHODE == 'TRI_DIAG'",
                     PREC_ORTHO      =SIMP(statut='f',typ='R',defaut= 1.E-12,val_min=0.E+0 ),
                     NMAX_ITER_ORTHO =SIMP(statut='f',typ='I',defaut= 5,val_min=0 ),
                     PREC_LANCZOS    =SIMP(statut='f',typ='R',defaut= 1.E-8,val_min=0.E+0 ),
                     NMAX_ITER_QR    =SIMP(statut='f',typ='I',defaut= 30,val_min=0 ),
                     MODE_RIGIDE     =SIMP(statut='f',typ='TXM',defaut="NON",into=("OUI","NON"),
                                           fr=tr("Calcul des modes de corps rigide, uniquement pour la méthode TRI_DIAG")),
                             ),
             b_jacobi =BLOC( condition = "METHODE == 'JACOBI'",
                     PREC_BATHE      =SIMP(statut='f',typ='R',defaut= 1.E-10,val_min=0.E+0 ),
                     NMAX_ITER_BATHE =SIMP(statut='f',typ='I',defaut= 40,val_min=0 ),
                     PREC_JACOBI     =SIMP(statut='f',typ='R',defaut= 1.E-2,val_min=0.E+0 ),
                     NMAX_ITER_JACOBI=SIMP(statut='f',typ='I',defaut= 12,val_min=0 ),
                            ),
             b_sorensen =BLOC( condition = "METHODE == 'SORENSEN'",
                     PREC_SOREN      =SIMP(statut='f',typ='R',defaut= 0.E+0,val_min=0.E+0 ),
                     NMAX_ITER_SOREN =SIMP(statut='f',typ='I',defaut= 20,val_min=0 ),
                     PARA_ORTHO_SOREN=SIMP(statut='f',typ='R',defaut= 0.717),
                              ),
             b_qz =BLOC( condition = "METHODE == 'QZ'",
                     TYPE_QZ      =SIMP(statut='f',typ='TXM',defaut="QZ_SIMPLE",into=("QZ_QR","QZ_SIMPLE","QZ_EQUI") ),
                        ),
                     APPROCHE     =SIMP(statut='f',typ='TXM',defaut="REEL",into=("REEL","IMAG","COMPLEXE"),
                                       fr=tr("Choix du pseudo-produit scalaire pour la résolution du problème quadratique")),
                 regles=(EXCLUS('DIM_SOUS_ESPACE','COEF_DIM_ESPACE'),),
                     DIM_SOUS_ESPACE =SIMP(statut='f',typ='I'),
                     COEF_DIM_ESPACE =SIMP(statut='f',typ='I'),
                                     ),
             b_solveur_inv    = BLOC( condition = "OPTION in ('SEPARE','AJUSTE','PROCHE')",
                     NMAX_ITER_SEPARE=SIMP(statut='f',typ='I' ,defaut= 30,val_min=1 ),
                     PREC_SEPARE     =SIMP(statut='f',typ='R',defaut= 1.E-4,val_min=1.E-70 ),
                     NMAX_ITER_AJUSTE=SIMP(statut='f',typ='I',defaut= 15,val_min=1 ),
                     PREC_AJUSTE     =SIMP(statut='f',typ='R',defaut= 1.E-4,val_min=1.E-70 ),
                     OPTION_INV      =SIMP(statut='f',typ='TXM',defaut="DIRECT",into=("DIRECT","RAYLEIGH") ),
                     PREC_INV        =SIMP(statut='f',typ='R',defaut= 1.E-5,val_min=1.E-70,fr=tr("Précision de convergence")),
                     NMAX_ITER_INV   =SIMP(statut='f',typ='I',defaut= 30,val_min=1 ),
                                    ),
                                     ),

         

#########################################################################################
#  catalogue du cas DYNAMIQUE
#########################################################################################
         b_dynam =BLOC(condition = "TYPE_RESU == 'DYNAMIQUE'",

                 MATR_RIGI  =SIMP(statut='o',typ=(matr_asse_depl_r,matr_asse_depl_c,matr_asse_temp_r,
                                                  matr_asse_gene_r,matr_asse_gene_c,matr_asse_pres_r ) ),
                 MATR_MASS  =SIMP(statut='o',typ=(matr_asse_depl_r,matr_asse_gene_r,matr_asse_pres_r,matr_asse_temp_r ) ),
                 MATR_AMOR  =SIMP(statut='f',typ=(matr_asse_depl_r,matr_asse_gene_r) ),
      
                 CALC_FREQ  =FACT(statut='d', min=0,
             b_plus_petite =BLOC(condition = "OPTION == 'PLUS_PETITE'",
                                 fr=tr("Recherche des plus petites fréquences propres"),
                     NMAX_FREQ  =SIMP(statut='f',typ='I',defaut=10,val_min=0 ),
                                 ),
             b_plus_grande =BLOC(condition = "OPTION == 'PLUS_GRANDE'",
                                 fr=tr("Recherche des plus grandes fréquences propres"),
                     NMAX_FREQ  =SIMP(statut='f',typ='I',defaut=1,val_min=0 ),
                                 ),
             b_centre      =BLOC(condition = "OPTION == 'CENTRE'",
                                 fr=tr("Recherche des fréquences propres les plus proches d'une valeur donnée"),
                     FREQ       =SIMP(statut='o',typ='R',
                                      fr=tr("Fréquence autour de laquelle on cherche les fréquences propres")),
                     AMOR_REDUIT=SIMP(statut='f',typ='R',),
                     NMAX_FREQ  =SIMP(statut='f',typ='I',defaut= 10,val_min=0 ),
                                 ),
             b_bande       =BLOC(condition = "OPTION == 'BANDE'",
                                 fr=tr("Recherche des fréquences propres dans une bande donnée"),
                     FREQ       =SIMP(statut='o',typ='R',min=2,max='**', validators=AndVal((OrdList('croissant'), NoRepeat())),
                                      fr=tr("Valeurs des fréquences délimitant la (les) bande(s) de recherche"), position='global'),
                     TABLE_FREQ =SIMP(statut= 'f',typ=table_sdaster),
                                 ),
             b_param_inv_dyn = BLOC( condition = "(OPTION in ('SEPARE','AJUSTE','PROCHE'))",
                     FREQ            =SIMP(statut='o',typ='R',max='**',
                                           validators=AndVal((OrdList('croissant'), NoRepeat())),),
                     AMOR_REDUIT     =SIMP(statut='f',typ='R',max='**'),
                     NMAX_FREQ       =SIMP(statut='f',typ='I',defaut= 0,val_min=0 ), # il faudra supprimer la valeur par défaut qui est inutile car ignorée dans le fortran
                                    ),
                     NMAX_ITER_SHIFT =SIMP(statut='f',typ='I',defaut= 3,val_min=0 ),
                     PREC_SHIFT      =SIMP(statut='f',typ='R',defaut= 5.E-2,val_min=0.E+0 ),
                     SEUIL_FREQ      =SIMP(statut='f',typ='R',defaut= 1.E-2,val_min=0.E+0 ),
                                  ),

             b_multi_bande =BLOC( condition= "OPTION == 'BANDE' and len(FREQ)>2",
                 NIVEAU_PARALLELISME  =SIMP(statut='f',typ='TXM',defaut="COMPLET",into=("PARTIEL","COMPLET") ),
                 STOP_BANDE_VIDE      =SIMP(statut='f',typ='TXM',defaut="NON" ,into=("OUI","NON") ),
                                 ),
             b_mono_bande  =BLOC( condition= "OPTION == 'BANDE' and len(FREQ)<=2",
                 STOP_BANDE_VIDE      =SIMP(statut='f',typ='TXM',defaut="OUI" ,into=("OUI","NON") ),
                                 ),

             # opérandes de post-traitement
             b_dyn_phys =BLOC( condition= "AsType(MATR_RIGI) == matr_asse_depl_r",
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
                              ),
                       ),

#########################################################################################
#  catalogue des cas MODE_FLAMB et GENERAL
#########################################################################################
         b_flamb    =BLOC(condition = "TYPE_RESU == 'MODE_FLAMB'",
                 MATR_RIGI      =SIMP(statut='o',typ=(matr_asse_depl_r,matr_asse_gene_r,matr_asse_pres_r ) ),
                 MATR_RIGI_GEOM =SIMP(statut='o',typ=(matr_asse_depl_r,matr_asse_gene_r,matr_asse_pres_r ) ),
                          ),
         
         b_general  =BLOC(condition = "TYPE_RESU == 'GENERAL'",
                 MATR_A         =SIMP(statut='o',typ=(matr_asse_depl_r,matr_asse_gene_r,matr_asse_pres_r ) ),
                 MATR_B         =SIMP(statut='o',typ=(matr_asse_depl_r,matr_asse_gene_r,matr_asse_pres_r ) ),
                          ),

         b_flamb_general =BLOC(condition = "TYPE_RESU in ('MODE_FLAMB','GENERAL')",
                 CALC_CHAR_CRIT  =FACT(statut='d',min=0,
             b_plus_petite =BLOC(condition = "OPTION == 'PLUS_PETITE'",
                                 fr=tr("Recherche des plus petites valeurs propres"),
                     NMAX_CHAR_CRIT =SIMP(statut='f',typ='I',defaut= 10,val_min=0 ),
                                 ),
             b_centre    =BLOC(condition = "OPTION == 'CENTRE'",
                               fr=tr("Recherche des valeurs propres les plus proches d'une valeur donnée"),
                     CHAR_CRIT      =SIMP(statut='o',typ='R',
                                          fr=tr("Charge critique autour de laquelle on cherche les charges critiques propres")),
                     NMAX_CHAR_CRIT =SIMP(statut='f',typ='I',defaut= 10,val_min=0 ),
                               ),
             b_bande     =BLOC(condition = "OPTION == 'BANDE'",
                               fr=tr("Recherche des valeurs propres dans une bande donnée"),
                     CHAR_CRIT      =SIMP(statut='o',typ='R',min=2,max=2,
                                          validators=AndVal((OrdList('croissant'), NoRepeat())),
                                          fr=tr("Valeur des deux charges critiques délimitant la bande de recherche")),
                     TABLE_CHAR_CRIT=SIMP(statut= 'f',typ=table_sdaster),
      
                               ),
         b_param_inv_flamb_gen =BLOC(condition = "OPTION in ('SEPARE','AJUSTE','PROCHE')",
                     CHAR_CRIT      =SIMP(statut='o',typ='R',max='**',
                                          validators=AndVal((OrdList('croissant'), NoRepeat())),),
                     NMAX_CHAR_CRIT =SIMP(statut='f',typ='I',defaut= 0,val_min=0 ),
                                     ),
                     NMAX_ITER_SHIFT=SIMP(statut='f',typ='I',defaut= 3,val_min=0 ),
                     PREC_SHIFT     =SIMP(statut='f',typ='R',defaut= 5.E-2,val_min=0.E+0 ),
                     SEUIL_CHAR_CRIT=SIMP(statut='f',typ='R',defaut= 1.E-2,val_min=0.E+0 ),
                                       ),
                               ),

#########################################################################################
#        Catalogue commun SOLVEUR
         b_solveur_lin_simult =BLOC(condition = "OPTION in ('PLUS_PETITE','PLUS_GRANDE','BANDE','CENTRE','TOUT')",
                 SOLVEUR =C_SOLVEUR('MODE_ITER_SIMULT'),
                                    ),
         b_solveur_lin_inv    =BLOC(condition = "OPTION in ('SEPARE','AJUSTE','PROCHE')",
                 SOLVEUR =C_SOLVEUR('MODE_ITER_INV'),
                                    ),
#########################################################################################

#########################################################################################
#        Vérification a posteriori
                 VERI_MODE =FACT(statut='d',min=0,
                     STOP_ERREUR =SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON") ),
             b_veri_mode_simlut = BLOC( condition = "OPTION in ('PLUS_PETITE','PLUS_GRANDE','BANDE','CENTRE','TOUT')",
                     SEUIL       =SIMP(statut='f',typ='R',val_min=0.E+0,defaut=1.e-6,
                                       fr=tr("Valeur limite admise pour l'erreur a posteriori des modes")),
                     PREC_SHIFT  =SIMP(statut='f',typ='R',defaut= 5.E-3,val_min=0.E+0 ),
                 b_sturm_simult=BLOC( condition = "(OPTION in ('PLUS_PETITE','PLUS_GRANDE','CENTRE','TOUT')) or (TYPE_RESU!='DYNAMIQUE' and OPTION == 'BANDE')", 
                     STURM       =SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON") ),
                                      ),
                 b_sturm_bande =BLOC( condition = "TYPE_RESU=='DYNAMIQUE' and OPTION == 'BANDE'", 
                     STURM       =SIMP(statut='f',typ='TXM',defaut="GLOBAL",into=("GLOBAL","LOCAL","OUI","NON") ),
                                     ),
                                       ),
             b_veri_mode_inv = BLOC( condition = "OPTION in ('SEPARE','AJUSTE','PROCHE')",
                     SEUIL       =SIMP(statut='f',typ='R',val_min=0.E+0,defaut=1.e-2,
                                       fr=tr("Valeur limite admise pour l'erreur a posteriori des modes")),
                                    ),
                                 ),
#########################################################################################
#        Amélioration de la qualité des modes
                 AMELIORATION=SIMP(statut='d',typ='TXM',defaut="NON",into=("OUI","NON"),min=0 ),
#########################################################################################

                 INFO       =SIMP(statut='f',typ='I',defaut=1,into=(1,2) ),
                 TITRE      =SIMP(statut='f',typ='TXM',max='**'),

);
