# coding=utf-8

from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *

# ======================================================================
# COPYRIGHT (C) 1991 - 2015  EDF R&D                  WWW.CODE-ASTER.ORG
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
# person_in_charge: mickael.abbas at edf.fr
#
DEFI_CONTACT=OPER(nom       = "DEFI_CONTACT",
                  op        = 30,
                  sd_prod   = char_contact,
                  fr        = tr("Définit les zones soumises à des conditions de contact unilatéral avec ou sans frottement"),
                  #en        = "Allows the definition of contact surfaces as well as unilateral conditions",
                  reentrant = 'n',
                  UIinfo    = {"groupes":("Modélisation",)},

# MODELE

         MODELE          =SIMP(statut='o',typ=modele_sdaster,),
         INFO            =SIMP(statut='f',typ='I',into=(1,2),),

# FORMULATION (UNIQUE PAR OCCURRENCE DE DEFI_CONTACT)

         FORMULATION     =SIMP(statut='o',
                               position='global',
                               typ='TXM',
                               fr=tr("Choix d'une formulation de contact ou de liaisons unilatérales"),
                               defaut="DISCRETE",
                               into=("DISCRETE","CONTINUE","XFEM","LIAISON_UNIL",),),

# PARAMETRE GENERAL : FROTTEMENT

         FROTTEMENT      =SIMP(statut='f',
                               position='global',
                               typ='TXM',
                               fr=tr("Choix d'un modèle de frottement (uniquement pour les formulations de contact)"),
                               defaut="SANS",
                               into=("COULOMB","SANS",)),

### PARAMETRES GENERAUX (UNIQUEMENT POUR LE CONTACT MAILLE, NE DEPENDENT PAS DE LA ZONE DE CONTACT)

         b_contact_mail=BLOC(condition = "((FORMULATION == 'CONTINUE') or (FORMULATION == 'DISCRETE'))",
#          ARRET DU CALCUL POUR LE MODE SANS RESOLUTION DU CONTACT
           STOP_INTERP   = SIMP(statut='f',
                                typ='TXM',
                                fr=tr("Arrête le calcul dès qu'une interpénétration est détectée en mode RESOLUTION='NON'"),
                                defaut="NON",
                                into=("OUI","NON")),
#          LISSAGE DES NORMALES PAR MOYENNATION AUX NOEUDS
           LISSAGE       = SIMP(statut='f',
                                typ='TXM',
                                fr=tr("Lissage des normales par moyennation aux noeuds"),
                                defaut="NON",
                                into=("OUI","NON")),
#          VERIFICATION DE L'ORIENTATION ET DE LA COHERENCE DES NORMALES
           VERI_NORM       =SIMP(statut='f',
                                 typ='TXM',
                                 fr=tr("Vérification de l'orientation (sortante) des normales aux surfaces"),
                                 defaut="OUI",
                                 into=("OUI","NON"),),
           ),

### PARAMETRES GENERAUX (UNIQUEMENT POUR LE CONTACT, NE DEPENDENT PAS DE LA ZONE DE CONTACT)

         b_contact=BLOC(condition = "FORMULATION != 'LIAISON_UNIL' ",

# PARAMETRE GENERAL : BOUCLE DE GEOMETRIE - Cas discret

           b_bouc_geom_maild=BLOC(condition = "FORMULATION == 'DISCRETE'",
                                  ALGO_RESO_GEOM = SIMP(statut='f',
                                                        typ='TXM',
                                                        into=("POINT_FIXE",),
                                                        defaut="POINT_FIXE"),
                                  REAC_GEOM = SIMP(statut='f',
                                                   typ='TXM',
                                                   into=("AUTOMATIQUE","CONTROLE","SANS",),
                                                   defaut="AUTOMATIQUE"),
                                  b_automatique = BLOC(condition = "REAC_GEOM == 'AUTOMATIQUE' ",
                                       ITER_GEOM_MAXI = SIMP(statut='f',typ='I',defaut=10),
                                       RESI_GEOM      = SIMP(statut='f',typ='R',defaut=0.01)),
                                  b_controle    = BLOC(condition = "REAC_GEOM == 'CONTROLE' ",
                                       NB_ITER_GEOM   = SIMP(statut='f',typ='I',defaut = 2)),
                                  )),

# PARAMETRE GENERAL : BOUCLE DE GEOMETRIE - Cas continu

           b_bouc_geom_mailc=BLOC(condition = "FORMULATION == 'CONTINUE'",
                                  ALGO_RESO_GEOM = SIMP(statut='f',
                                                        typ='TXM',
                                                        into=("POINT_FIXE","NEWTON",),
                                                        defaut="POINT_FIXE"),
                                  b_algo_reso_geomNE = BLOC(condition = "ALGO_RESO_GEOM=='NEWTON'",
                                    RESI_GEOM      = SIMP(statut='f',typ='R',defaut=0.000001),),

                                  b_algo_reso_geomPF = BLOC(condition = "ALGO_RESO_GEOM=='POINT_FIXE'",
                                     REAC_GEOM = SIMP(statut='f',
                                                   typ='TXM',
                                                   into=("AUTOMATIQUE","CONTROLE","SANS",),
                                                   defaut="AUTOMATIQUE"),
                                    b_automatique = BLOC(condition = "REAC_GEOM == 'AUTOMATIQUE' ",
                                       ITER_GEOM_MAXI = SIMP(statut='f',typ='I',defaut=10),
                                       RESI_GEOM      = SIMP(statut='f',typ='R',defaut=0.01)),
                                    b_controle    = BLOC(condition = "REAC_GEOM == 'CONTROLE' ",
                                       NB_ITER_GEOM   = SIMP(statut='f',typ='I',defaut = 2)))
                                   ),

# PARAMETRE GENERAL : BOUCLE DE GEOMETRIE - Cas XFEM

           b_bouc_geom_xfem=BLOC(condition = "FORMULATION == 'XFEM' ",
                                 ALGO_RESO_GEOM = SIMP(statut='f',
                                                        typ='TXM',
                                                        into=("POINT_FIXE",),
                                                        defaut="POINT_FIXE"),
                                 REAC_GEOM =SIMP(statut='f',
                                                 typ='TXM',
                                                 into=("AUTOMATIQUE","CONTROLE","SANS",),
                                                 defaut="SANS",
                                                 ),
                                 b_automatique = BLOC(condition = "REAC_GEOM == 'AUTOMATIQUE' ",
                                   ITER_GEOM_MAXI = SIMP(statut='f',typ='I',defaut=10),
                                   RESI_GEOM      = SIMP(statut='f',typ='R',defaut=0.0001),
                                   ),
                                 b_controle    = BLOC(condition = "REAC_GEOM == 'CONTROLE' ",
                                   NB_ITER_GEOM   = SIMP(statut='f',typ='I',defaut = 2),
                                   ),
                                 ),


# PARAMETRE GENERAL : BOUCLE DE CONTACT

           b_bouc_cont_disc=BLOC(condition = "FORMULATION == 'DISCRETE' ",
                                 ITER_CONT_MULT = SIMP(statut='f',typ='I',defaut = 4),
                                 ),


           b_bouc_cont_cont=BLOC(condition = "FORMULATION == 'CONTINUE' ",
                                 ALGO_RESO_CONT = SIMP(statut='f',typ='TXM',defaut="NEWTON",
                                                      into=("POINT_FIXE","NEWTON")),
                                 b_algo_reso_contPF = BLOC(condition = "ALGO_RESO_CONT=='POINT_FIXE'",
                                   ITER_CONT_TYPE = SIMP(statut='f',typ='TXM',defaut="MAXI",
                                                      into=("MULT","MAXI")),
                                   b_bouc_cont_mult = BLOC(condition = "ITER_CONT_TYPE=='MULT'",
                                     ITER_CONT_MULT = SIMP(statut='f',typ='I',defaut = 4),
                                     ),
                                   b_bouc_cont_maxi = BLOC(condition = "ITER_CONT_TYPE=='MAXI'",
                                     ITER_CONT_MAXI = SIMP(statut='f',typ='I',defaut = 30),
                                     ),
                                   )
                                 ),

           b_bouc_cont_xfem=BLOC(condition = "FORMULATION == 'XFEM' ",
                                 ITER_CONT_TYPE= SIMP(statut='f',typ='TXM',defaut="MAXI",
                                                      into=("MULT","MAXI")),
                                 b_bouc_cont_mult = BLOC(condition = "ITER_CONT_TYPE=='MULT'",
                                                         ITER_CONT_MULT = SIMP(statut='f',typ='I',defaut = 4),
                                   ),
                                 b_bouc_cont_maxi = BLOC(condition = "ITER_CONT_TYPE=='MAXI'",
                                                         ITER_CONT_MAXI = SIMP(statut='f',typ='I',defaut = 30),
                                   ),
                                 ),

# PARAMETRE GENERAL : BOUCLE DE FROTTEMENT - Cas continu

           b_bouc_frot_cont= BLOC(condition = "FROTTEMENT=='COULOMB' and FORMULATION == 'CONTINUE' ",
                                  ALGO_RESO_FROT = SIMP(statut='f',
                                                        typ='TXM',
                                                        into=("POINT_FIXE","NEWTON",),
                                                        defaut="NEWTON"),
                                  b_algo_reso_frotPF = BLOC(condition = "ALGO_RESO_FROT=='POINT_FIXE'",
                                    ITER_FROT_MAXI = SIMP(statut='f',typ='I',defaut=10),
                                    RESI_FROT      = SIMP(statut='f',typ='R',defaut=0.0001),
                                  ),
                                  b_algo_reso_frotNE = BLOC(condition = "ALGO_RESO_FROT=='NEWTON'",

                                    RESI_FROT      = SIMP(statut='f',typ='R',defaut=0.0001),
                                    ADAPT_COEF     = SIMP(statut='f',
                                                          typ='TXM',
                                                          defaut="NON",
                                                          into=("OUI","NON")),
                                  ),
                              ),


# PARAMETRE GENERAL : BOUCLE DE FROTTEMENT - Cas XFEM

           b_bouc_frot_xfem= BLOC(condition = "FROTTEMENT=='COULOMB' and FORMULATION == 'XFEM' ",
                                  ITER_FROT_MAXI = SIMP(statut='f',typ='I',defaut=10),
                                  RESI_FROT      = SIMP(statut='f',typ='R',defaut=0.0001),
                                  ),


# Automatic elimiantion for non-vital edges
           b_arete_xfem= BLOC(condition = "FORMULATION == 'XFEM' ",
                              ELIM_ARETE  =SIMP(statut='f',
                                                typ='TXM',
                                                defaut="DUAL",
                                                into=("DUAL","ELIM"),),
                          ),

# PARAMETRES GENERAUX : METHODES DISCRETES

           b_para_discret  = BLOC(condition = "FORMULATION == 'DISCRETE' ",
#                                 ## METHODES DE DUALISATION ##
                                  STOP_SINGULIER= SIMP(statut='f',
                                                       typ='TXM',
                                                       fr=tr("Tient compte de la singularité de la matrice de contact"),
                                                       defaut="OUI",
                                                       into=("OUI","NON"),),
                                  NB_RESOL      = SIMP(statut='f',
                                                       typ='I',
                                                fr=tr("Nombre de résolutions simultanées pour la construction du complément de Schur"),
                                                       defaut=10,),
#                                 ## GCP ##
                                  RESI_ABSO     = SIMP(statut='f',
                                                       typ='R',
                                                  fr=tr("Critère de convergence (niveau d'interpénétration autorisé pour 'GCP')"),),
                                  ITER_GCP_MAXI = SIMP(statut='f',
                                                       typ='I',
                                                       fr=tr("Nombre d'itérations maximal ('GCP')"),
                                                       defaut=0,),
                                  RECH_LINEAIRE = SIMP(statut='f',
                                                       typ='TXM',
                                                  fr=tr("Autorisation de sortie du domaine admissible lors de la recherche linéaire"),
                                                       defaut="ADMISSIBLE",
                                                       into=("ADMISSIBLE","NON_ADMISSIBLE"),),
                                  PRE_COND      = SIMP(statut='f',
                                                       typ='TXM',
                                                       fr=tr("Choix d'un préconditionneur (accélère la convergence de 'GCP')"),
                                                       defaut="SANS",
                                                       into=("DIRICHLET","SANS"),),
                                  b_dirichlet   = BLOC (condition = "PRE_COND == 'DIRICHLET'",
                                     COEF_RESI     = SIMP(statut='f',
                                                          typ='R',
                                                   fr=tr("Activation du préconditionneur quand le résidu a été divisé par COEF_RESI"),
                                                          defaut = -1.0,),
                                     ITER_PRE_MAXI = SIMP(statut='f',
                                                          typ='I',
                                                          fr=tr("Nombre d'itérations maximal pour le préconditionneur ('GCP')"),
                                                          defaut=0,),
                                  ),
                                  ),

## AFFECTATIONS (ZONES PAR ZONES)

# AFFECTATION - CAS LIAISON_UNILATERALE

         b_affe_unil     = BLOC(condition = "FORMULATION == 'LIAISON_UNIL'",
                                ZONE=FACT(statut='o',
                                          max='**',
# -- Liaison unilatérale
                                          regles=(UN_PARMI('GROUP_MA','MAILLE','GROUP_NO','NOEUD'),),
                                          GROUP_MA        =SIMP(statut='f',typ=grma ,validators=NoRepeat(),max='**'),
                                          MAILLE          =SIMP(statut='f',typ=ma   ,validators=NoRepeat(),max='**'),
                                          GROUP_NO        =SIMP(statut='f',typ=grno ,validators=NoRepeat(),max='**'),
                                          NOEUD           =SIMP(statut='f',typ=no   ,validators=NoRepeat(),max='**'),
#
                                          NOM_CMP         =SIMP(statut='o',typ='TXM',max='**'),
                                          COEF_IMPO       =SIMP(statut='o',typ=(fonction_sdaster,nappe_sdaster,formule),),
                                          COEF_MULT       =SIMP(statut='o',typ=(fonction_sdaster,nappe_sdaster,formule),max='**'),
# -- Incompatibilité avec CL
                                          SANS_NOEUD      =SIMP(statut='f',typ=no   ,validators=NoRepeat(),max='**'),
                                          SANS_GROUP_NO   =SIMP(statut='f',typ=grno ,validators=NoRepeat(),max='**'),


                                          ),
                                ),

# AFFECTATION - CAS DISCRET

         b_affe_discret  = BLOC(condition = "FORMULATION == 'DISCRETE'",
                                ZONE=FACT(statut='o',
                                          max='**',
# -- Appariement
                                          APPARIEMENT     =SIMP(statut='f',typ='TXM',defaut="MAIT_ESCL",
                                                                into=("NODAL","MAIT_ESCL"),),
#
                                          regles=(UN_PARMI('GROUP_MA_ESCL','MAILLE_ESCL'),
                                                  UN_PARMI('GROUP_MA_MAIT','MAILLE_MAIT'),),
                                          GROUP_MA_MAIT   =SIMP(statut='f',typ=grma ,validators=NoRepeat(),max=1),
                                          MAILLE_MAIT     =SIMP(statut='f',typ=ma   ,validators=NoRepeat(),max='**'),
                                          GROUP_MA_ESCL   =SIMP(statut='f',typ=grma ,validators=NoRepeat(),max=1),
                                          MAILLE_ESCL     =SIMP(statut='f',typ=ma   ,validators=NoRepeat(),max='**'),
#
                                          NORMALE         =SIMP(statut='f',typ='TXM',defaut="MAIT",
                                                                into=("MAIT","MAIT_ESCL","ESCL"),),
#
                                          VECT_MAIT       =SIMP(statut='f',typ='TXM',defaut="AUTO",
                                                                into=("AUTO","FIXE","VECT_Y")),

                                          b_nmait_fixe=BLOC(condition = "VECT_MAIT == 'FIXE'",
                                            MAIT_FIXE     =SIMP(statut='o',typ='R',min=3,max=3),
                                            ),

                                          b_nmait_vecty=BLOC(condition = "VECT_MAIT == 'VECT_Y'",
                                            MAIT_VECT_Y   =SIMP(statut='o',typ='R',min=3,max=3),
                                            ),
#
                                          VECT_ESCL       =SIMP(statut='f',typ='TXM',defaut="AUTO",
                                                                into=("AUTO","FIXE","VECT_Y")),

                                          b_nescl_fixe=BLOC(condition = "VECT_ESCL == 'FIXE'",
                                            ESCL_FIXE     =SIMP(statut='o',typ='R',min=3,max=3),
                                            ),

                                          b_nescl_vecty=BLOC(condition = "VECT_ESCL == 'VECT_Y'",
                                            ESCL_VECT_Y   =SIMP(statut='o',typ='R',min=3,max=3),
                                            ),
#
                                          TYPE_APPA       =SIMP(statut='f',typ='TXM',defaut="PROCHE",
                                                           into  =("PROCHE","FIXE")),

                                          b_appa_fixe     =BLOC(condition = "TYPE_APPA == 'FIXE'",
                                            DIRE_APPA     =SIMP(statut='f',typ='R',min=3,max=3),
                                            ),
#
                                          DIST_POUTRE     =SIMP(statut='f',typ='TXM',defaut="NON", into=("OUI","NON")),
                                          DIST_COQUE      =SIMP(statut='f',typ='TXM',defaut="NON", into=("OUI","NON")),
                                          b_cara=BLOC(condition = "DIST_POUTRE == 'OUI' or DIST_COQUE == 'OUI'",
                                            CARA_ELEM     =SIMP(statut='o',typ=(cara_elem) ),
                                            ),

                                          DIST_MAIT       =SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule)),
                                          DIST_ESCL       =SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule)),
#
                                          TOLE_APPA       =SIMP(statut='f',typ='R'  ,defaut=-1.0),
                                          TOLE_PROJ_EXT   =SIMP(statut='f',typ='R'  ,defaut=0.50),
# -- Incompatibilité avec CL
                                          SANS_NOEUD      =SIMP(statut='f',typ=no   ,validators=NoRepeat(),max='**'),
                                          SANS_GROUP_NO   =SIMP(statut='f',typ=grno ,validators=NoRepeat(),max='**'),
                                          SANS_MAILLE     =SIMP(statut='f',typ=ma   ,validators=NoRepeat(),max='**'),
                                          SANS_GROUP_MA   =SIMP(statut='f',typ=grma ,validators=NoRepeat(),max='**'),
# -- Mode sans calcul
                                          RESOLUTION      =SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON")),
                                          b_verif=BLOC(condition = "RESOLUTION == 'NON' ",
                                            TOLE_INTERP   = SIMP(statut='f',typ='R',defaut = 0., val_min=0.),
                                            ),
# -- Résolution
                                          ALGO_CONT       =SIMP(statut='o',typ='TXM',defaut="CONTRAINTE",
                                                                into=("CONTRAINTE","LAGRANGIEN","PENALISATION","GCP"),),

                                          b_active=BLOC(condition = "ALGO_CONT == 'CONTRAINTE' ",
                                                        fr=tr("Paramètres de la méthode des contraintes actives (contact uniquement)"),
                                                        GLISSIERE=SIMP(statut='f',typ='TXM',defaut="NON",into=("OUI","NON")),
                                                        b_glissiere=BLOC(condition = "GLISSIERE == 'OUI' ",
                                                                         ALARME_JEU  =SIMP(statut='f',typ='R',defaut=0.),
                                                                        ),
                                                        ),
#
                                          b_penal_contact=BLOC(condition = "ALGO_CONT == 'PENALISATION' ",
                                                               fr=tr("Paramètres de la méthode pénalisée (contact)"),
                                                               E_N=SIMP(statut='o',typ='R'),
                                                               ),
#
                                          b_frottement=BLOC(condition = "FROTTEMENT == 'COULOMB' ",
                                                            fr=tr("Paramètres du frottement de Coulomb"),
                                                            COULOMB       =SIMP(statut='o',typ='R',),
                                                            COEF_MATR_FROT=SIMP(statut='f',typ='R',defaut=0.E+0),
                                                            ALGO_FROT     =SIMP(statut='o',typ='TXM',defaut="PENALISATION",
                                                                                into=("PENALISATION","LAGRANGIEN"),),
#
                                                            b_penal_frot=BLOC(condition = "ALGO_FROT == 'PENALISATION' ",
                                                                              fr=tr("Paramètres de la méthode pénalisée (frottement)"),
                                                                              E_T=SIMP(statut='o',typ='R'),
                                                                              ),
                                                           ),
                                          ), #fin mot-clé facteur ZONE
                                ), #fin bloc b_affe_discret

# AFFECTATION - CAS CONTINUE

         b_affe_continue = BLOC(condition = "FORMULATION == 'CONTINUE'",
                                ZONE=FACT(statut='o',
                                          max='**',
# -- Appariement
                                          APPARIEMENT     =SIMP(statut='f',typ='TXM',defaut="MAIT_ESCL",
                                                                into=("MAIT_ESCL",)),


#
                                          regles=(UN_PARMI('GROUP_MA_ESCL','MAILLE_ESCL'),
                                                  UN_PARMI('GROUP_MA_MAIT','MAILLE_MAIT'),),
                                          GROUP_MA_MAIT   =SIMP(statut='f',typ=grma ,validators=NoRepeat(),max=1),
                                          MAILLE_MAIT     =SIMP(statut='f',typ=ma   ,validators=NoRepeat(),max='**'),
                                          GROUP_MA_ESCL   =SIMP(statut='f',typ=grma ,validators=NoRepeat(),max=1),
                                          MAILLE_ESCL     =SIMP(statut='f',typ=ma   ,validators=NoRepeat(),max='**'),
#
                                          NORMALE         =SIMP(statut='f',typ='TXM',defaut="MAIT",
                                                                into=("MAIT","MAIT_ESCL","ESCL"),),
#
                                          VECT_MAIT       =SIMP(statut='f',typ='TXM',defaut="AUTO",
                                                                into=("AUTO","FIXE","VECT_Y")),

                                          b_nmait_fixe=BLOC(condition = "VECT_MAIT == 'FIXE'",
                                            MAIT_FIXE     =SIMP(statut='o',typ='R',min=3,max=3),
                                            ),

                                          b_nmait_vecty=BLOC(condition = "VECT_MAIT == 'VECT_Y'",
                                            MAIT_VECT_Y   =SIMP(statut='o',typ='R',min=3,max=3),
                                            ),
#
                                          VECT_ESCL       =SIMP(statut='f',typ='TXM',defaut="AUTO",
                                                                into=("AUTO","FIXE","VECT_Y")),

                                          b_nescl_fixe=BLOC(condition = "VECT_ESCL == 'FIXE'",
                                            ESCL_FIXE     =SIMP(statut='o',typ='R',min=3,max=3),
                                            ),

                                          b_nescl_vecty=BLOC(condition = "VECT_ESCL == 'VECT_Y'",
                                            ESCL_VECT_Y   =SIMP(statut='o',typ='R',min=3,max=3),
                                            ),
#
                                          TYPE_APPA       =SIMP(statut='f',typ='TXM',defaut="PROCHE",
                                                           into  =("PROCHE","FIXE")),

                                          b_appa_fixe=BLOC(condition = "TYPE_APPA == 'FIXE'",
                                            DIRE_APPA     =SIMP(statut='f',typ='R',min=3,max=3),
                                            ),
#
                                          DIST_POUTRE     =SIMP(statut='f',typ='TXM',defaut="NON", into=("OUI","NON")),
                                          DIST_COQUE      =SIMP(statut='f',typ='TXM',defaut="NON", into=("OUI","NON")),
                                          b_cara=BLOC(condition = "DIST_POUTRE == 'OUI' or DIST_COQUE == 'OUI'",
                                            CARA_ELEM     =SIMP(statut='o',typ=(cara_elem) ),
                                            ),

                                          DIST_MAIT       =SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule)),
                                          DIST_ESCL       =SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule)),
#
                                          TOLE_APPA       =SIMP(statut='f',typ='R'  ,defaut=-1.0),
                                          TOLE_PROJ_EXT   =SIMP(statut='f',typ='R'  ,defaut=0.50),
# -- Incompatibilité avec CL
                                          SANS_NOEUD      =SIMP(statut='f',typ=no   ,validators=NoRepeat(),max='**'),
                                          SANS_GROUP_NO   =SIMP(statut='f',typ=grno ,validators=NoRepeat(),max='**'),
                                          SANS_MAILLE     =SIMP(statut='f',typ=ma   ,validators=NoRepeat(),max='**'),
                                          SANS_GROUP_MA   =SIMP(statut='f',typ=grma ,validators=NoRepeat(),max='**'),
# -- Mode sans calcul
                                          RESOLUTION       =SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON")),
                                          b_verif=BLOC(condition = "RESOLUTION == 'NON' ",
                                                       TOLE_INTERP   = SIMP(statut='f',typ='R',defaut = 0.),
                                                       ),
# -- Fonctionnalités spécifiques 'CONTINUE'

                                          INTEGRATION     =SIMP(statut='f',typ='TXM',defaut="AUTO",
                                          into=("AUTO","GAUSS","SIMPSON","NCOTES",),),
                                          b_gauss   =BLOC(condition = "INTEGRATION == 'GAUSS' ",
                                                          fr=tr("Degré du polynôme de Legendre donnant les points de Gauss"),
                                                          ORDRE_INT = SIMP(statut='f',typ='I',defaut=3,val_min=1,val_max=6),
                                            ),
                                          b_simpson =BLOC(condition = "INTEGRATION == 'SIMPSON' ",
                                                          fr=tr("Nombre de subdivisions du domaine"),
                                                          ORDRE_INT = SIMP(statut='f',typ='I',defaut=1,val_min=1,val_max=4),
                                            ),
                                          b_ncotes  =BLOC(condition = "INTEGRATION == 'NCOTES' ",
                                                          fr=tr("Degré du polynôme interpolateur"),
                                                          ORDRE_INT = SIMP(statut='f',typ='I',defaut=3,val_min=3,val_max=8),
                                            ),
#
                                          CONTACT_INIT    =SIMP(statut='f',typ='TXM',defaut="INTERPENETRE",
                                                                into=("OUI","INTERPENETRE","NON"),),
#
                                          GLISSIERE       =SIMP(statut='f',typ='TXM',defaut="NON",into=("OUI","NON"),),
#
                                          ALGO_CONT       =SIMP(statut='f',typ='TXM',defaut="STANDARD",
                                                                into=("STANDARD","PENALISATION"),),

                                          b_cont_std=BLOC(condition = "ALGO_CONT == 'STANDARD' ",
                                                          fr=tr("Paramètres de la formulation Lagrangienne"),
                                                          COEF_CONT = SIMP(statut='f',typ='R',defaut=100.E+0),
                                                          ),
                                          b_cont_pena=BLOC(condition = "ALGO_CONT == 'PENALISATION' ",
                                                            fr=tr("Paramètres de la méthode pénalisée"),
                                                            COEF_PENA_CONT  =SIMP(statut='o',typ='R'),
                                                            ),
#
                                          b_frottement=BLOC(condition = "FROTTEMENT == 'COULOMB' ",
                                                            fr=tr("Paramètres du frottement de Coulomb"),
                                                            COULOMB    = SIMP(statut='o',typ='R',),
                                                            SEUIL_INIT = SIMP(statut='f',typ='R',defaut=0.E+0),
#
                                          regles=(EXCLUS('SANS_NOEUD_FR','SANS_GROUP_NO_FR'),),
                                                  SANS_NOEUD_FR    =SIMP(statut='f',typ=no  ,validators=NoRepeat(),max='**'),
                                                  SANS_GROUP_NO_FR =SIMP(statut='f',typ=grno,validators=NoRepeat(),max='**'),
                                                            b_sans_group_no_frot=BLOC(condition = " SANS_GROUP_NO_FR != None or \
                                                                                                    SANS_NOEUD_FR != None ",
                                                            fr=tr("Direction de frottement à exclure (uniquement dans le cas 3D)"),
                                                            DIRE_EXCL_FROT=SIMP(statut='f',typ='R',min=3,max=3),
                                                            ),

                                            ALGO_FROT       =SIMP(statut='f',typ='TXM',defaut="STANDARD",
                                                                  into=("STANDARD","PENALISATION"),),
                                            b_frot_std      =BLOC(condition = "ALGO_FROT == 'STANDARD' ",
                                                                  fr=tr("Paramètres de la formulation Lagrangienne"),
                                                                  COEF_FROT  =SIMP(statut='f',typ='R',defaut=100.E+0),
                                                                  ),

                                            b_frot_pena     =BLOC(condition = "ALGO_FROT == 'PENALISATION' ",
                                                                  fr=tr("Paramètres de la méthode pénalisée"),
                                                                  COEF_PENA_FROT  =SIMP(statut='o',typ='R'),
                                                                  ),

                                            ), #fin bloc b_frottement
                                          ), #fin mot-clé facteur ZONE
                                ), #fin bloc b_affe_continue


# AFFECTATION - CAS XFEM

           b_affe_xfem =BLOC(condition = "FORMULATION == 'XFEM'",
                             ZONE=FACT(statut='o',
                                       max='**',
# -- Fissure
                                       FISS_MAIT      = SIMP(statut='o',typ=fiss_xfem,max=1),
                                       TOLE_PROJ_EXT   =SIMP(statut='f',typ='R'  ,defaut=0.50),

# -- Fonctionnalités spécifiques 'XFEM'
                                       INTEGRATION    = SIMP(statut='f',
                                                             typ='TXM',
                                                             defaut="GAUSS",

                                          into=("NOEUD","GAUSS","SIMPSON","NCOTES",),),
                                          b_gauss   =BLOC(condition = "INTEGRATION == 'GAUSS' ",
                                                          fr=tr("Dégré du polynôme de Legendre donnant les points de Gauss"),
                                                          ORDRE_INT = SIMP(statut='f',typ='I',defaut=6,val_min=1,val_max=6),
                                            ),
                                          b_simpson =BLOC(condition = "INTEGRATION == 'SIMPSON' ",
                                                          fr=tr("Nombre de subdivisions du domaine"),
                                                          ORDRE_INT = SIMP(statut='f',typ='I',defaut=1,val_min=1,val_max=4),
                                            ),
                                          b_ncotes  =BLOC(condition = "INTEGRATION == 'NCOTES' ",
                                                          fr=tr("Dégré du polynôme interpolateur"),
                                                          ORDRE_INT = SIMP(statut='f',typ='I',defaut=3,val_min=3,val_max=8),
                                            ),

                                       ALGO_LAGR      = SIMP(statut='f',typ='TXM',defaut="VERSION1",
                                                             into=("NON","VERSION1","VERSION2"),),

                                       ALGO_CONT      = SIMP(statut='f',typ='TXM',defaut="STANDARD",
                                                                  into=("STANDARD","PENALISATION","CZM"),),

                                       b_cont_nczm =BLOC(condition = "ALGO_CONT!='CZM'",
                                                CONTACT_INIT   = SIMP(statut='f',typ='TXM',defaut="NON",into=("OUI","NON"),),
                                                GLISSIERE      = SIMP(statut='f',typ='TXM',defaut="NON",into=("OUI","NON"),),
                                                ),

                                       b_cont_std=BLOC(condition = "ALGO_CONT == 'STANDARD'",
                                                fr=tr("Parametres de la formulation Lagrangienne"),
                                                COEF_CONT    =SIMP(statut='f',typ='R',defaut=100.E+0),
                                                ),

                                       b_cont_pen=BLOC(condition = "ALGO_CONT == 'PENALISATION' ",
                                                 fr=tr("Paramètre de la méthode pénalisée"),
                                                 COEF_PENA_CONT =SIMP(statut='o',typ='R'),
                                                 ),

                                       b_cont_czm=BLOC(condition = "ALGO_CONT == 'CZM'",
                                                fr=tr("Parametres de la formulation cohesive"),
                                                RELATION       = SIMP(statut='o',typ='TXM',
                                                                 into=("CZM_EXP_REG","CZM_LIN_REG","CZM_TAC_MIX","CZM_OUV_MIX","CZM_LIN_MIX"),)
                                                ),

                                       b_frottement=BLOC(condition = "FROTTEMENT == 'COULOMB' and  ALGO_CONT != 'CZM' ",
                                                 fr=tr("Paramètres du frottement"),
                                                 COULOMB      =SIMP(statut='o',typ='R',),
                                                 SEUIL_INIT   =SIMP(statut='f',typ='R',defaut=0.E+0),
                                                 ALGO_FROT    =SIMP(statut='f',typ='TXM',defaut="STANDARD",
                                                                            into=("STANDARD","PENALISATION"),),

                                                 b_frot_std=BLOC(condition = "ALGO_FROT == 'STANDARD' ",
                                                                  fr=tr("Parametres de la formulation Lagrangienne"),
                                                                  COEF_FROT  =SIMP(statut='f',typ='R',defaut=100.E+0),
                                                                  ),
                                                 b_frot_pen=BLOC(condition = "ALGO_FROT == 'PENALISATION' ",
                                                                  fr=tr("Paramètre de la méthode pénalisée"),
                                                                  COEF_PENA_FROT  =SIMP(statut='o',typ='R'),
                                                                  ),
                                                        ), #fin bloc b_frottement
                                       ), #fin mot-clé facteur ZONE
                             ), #fin bloc b_affe_xfem

                  ) #fin OPER
