# coding=utf-8

from Cata.Descriptor import *

# ======================================================================
# COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
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
# person_in_charge: mathieu.courtois at edf.fr
def recu_fonction_prod(RESULTAT=None,TABLE=None,RESU_GENE=None,
                       BASE_ELAS_FLUI=None,CHAM_GD=None,NAPPE=None,
                       INTE_SPEC=None,NOEUD_J=None,NUME_ORDRE_J=None,
                       NOM_CMP_J=None,NOM_CMP_I=None,NUME_ORDRE_I=None,NOEUD_I=None,
                       NOM_PARA_TABL=None,PARA_Y=None,**args):
   if AsType(RESULTAT)  == dyna_harmo or \
      AsType(RESU_GENE) == harm_gene or \
      (INTE_SPEC and NUME_ORDRE_J and (NUME_ORDRE_I != NUME_ORDRE_J) ) or \
      (INTE_SPEC and NOEUD_J and ((NOEUD_I != NOEUD_J) or (NOM_CMP_I != NOM_CMP_J)) ) or \
      (TABLE != None and NOM_PARA_TABL == "FONCTION_C")  or \
      (TABLE != None and PARA_Y == "VALE_C") :
      return fonction_c
   else:
      return fonction_sdaster

RECU_FONCTION=OPER(nom="RECU_FONCTION",op=90,sd_prod=recu_fonction_prod,
                   fr=tr("Extraire sous forme d'une fonction, l'évolution d'une grandeur en fonction d'une autre"),
                   reentrant='f',
            UIinfo={"groupes":("Résultats et champs","Fonctions",)},
         regles=(UN_PARMI('CHAM_GD','RESULTAT','RESU_GENE','TABLE','BASE_ELAS_FLUI','NAPPE','INTE_SPEC'),),

         CHAM_GD         =SIMP(statut='f',typ=(cham_no_sdaster,cham_elem,),),
         RESULTAT        =SIMP(statut='f',typ=resultat_sdaster),
         RESU_GENE       =SIMP(statut='f',typ=(tran_gene, mode_gene, harm_gene)),
         TABLE           =SIMP(statut='f',typ=(table_sdaster,table_fonction)),
         BASE_ELAS_FLUI  =SIMP(statut='f',typ=melasflu_sdaster),
         NAPPE           =SIMP(statut='f',typ=nappe_sdaster),
         INTE_SPEC       =SIMP(statut='f',typ=interspectre),

# ======= ACCES A LA SD RESULTAT =================================================
         b_acces = BLOC ( condition = "(RESULTAT != None) or (RESU_GENE != None)",
                          fr=tr("acces a une SD résultat"),
# on ne peut pas mettre de regles, le défaut TOUT_ORDRE est pris en compte dans le fortran
           TOUT_ORDRE      =SIMP(statut='f',typ='TXM',into=("OUI",) ),
           NUME_ORDRE      =SIMP(statut='f',typ='I',validators=NoRepeat(),max='**'),
           LIST_ORDRE      =SIMP(statut='f',typ=listis_sdaster ),
           TOUT_INST       =SIMP(statut='f',typ='TXM',into=("OUI",) ),
           INST            =SIMP(statut='f',typ='R',validators=NoRepeat(),max='**'),
           LIST_INST       =SIMP(statut='f',typ=listr8_sdaster ),
           FREQ            =SIMP(statut='f',typ='R',validators=NoRepeat(),max='**'),
           LIST_FREQ       =SIMP(statut='f',typ=listr8_sdaster ),
           NUME_MODE       =SIMP(statut='f',typ='I',validators=NoRepeat(),max='**'),
           b_prec = BLOC ( condition = "(INST != None) or (LIST_INST != None) or (FREQ != None) or (LIST_FREQ != None)",
             CRITERE         =SIMP(statut='f',typ='TXM',defaut="RELATIF",into=("RELATIF","ABSOLU",),),
             b_prec_rela=BLOC(condition="(CRITERE=='RELATIF')",
                 PRECISION       =SIMP(statut='f',typ='R',defaut= 1.E-6,),),
             b_prec_abso=BLOC(condition="(CRITERE=='ABSOLU')",
                 PRECISION       =SIMP(statut='o',typ='R',),),
             INTERP_NUME     =SIMP(statut='f',typ='TXM',into=("NON","LIN") ),
           ),
         ),
# ======= BASE_ELAS_FLUI =================================================
         b_base_elas_flui = BLOC ( condition = "BASE_ELAS_FLUI != None",
                                   fr=tr("Récupération de la fonction à partir d un concept melasflu"),
           regles=(UN_PARMI('TOUT_ORDRE','NUME_ORDRE'),),
           TOUT_ORDRE      =SIMP(statut='f',typ='TXM',into=("OUI",) ),
           NUME_ORDRE      =SIMP(statut='f',typ='I',validators=NoRepeat(),max='**'),
           NUME_MODE       =SIMP(statut='o',typ='I' ),
           PARA_X          =SIMP(statut='o',typ='TXM',into=("VITE_FLU",) ),
           PARA_Y          =SIMP(statut='o',typ='TXM',into=("FREQ","AMOR") ),
         ),

# ======= INTERSPECTRE =================================================
         b_inte_spec = BLOC ( condition = "INTE_SPEC != None",
                              fr=tr("Récupération de fonction dans un concept interspectre"),
           regles=(UN_PARMI('NUME_ORDRE_I','NOEUD_I','NUME_ORDRE',),),
           NOM_CHAM        =SIMP(statut='f',typ='TXM',validators=NoRepeat(),into=C_NOM_CHAM_INTO()),
           NUME_ORDRE    =SIMP(statut='f',typ='I',max=1 ),
           NOEUD_I         =SIMP(statut='f',typ=no,max=1),
           NUME_ORDRE_I    =SIMP(statut='f',typ='I',max=1 ),
           b_nume_ordre_i = BLOC (condition = "NUME_ORDRE_I != None",
             NUME_ORDRE_J    =SIMP(statut='f',typ='I',max=1 ),
           ),
           b_noeud_i = BLOC (condition = "NOEUD_I != None",
             NOEUD_J         =SIMP(statut='f',typ=no,max=1),
             NOM_CMP_I       =SIMP(statut='o',typ='TXM',max=1 ),
             NOM_CMP_J       =SIMP(statut='f',typ='TXM',max=1 ),
           ),
         ),

# ======= TABLE =================================================
         b_table = BLOC ( condition = "TABLE != None",
                          fr=tr("Récupération de la fonction à partir d un concept table"),
                          regles=(UN_PARMI('PARA_X','NOM_PARA_TABL'),
                                  PRESENT_PRESENT('PARA_X','PARA_Y'),),
           PARA_X        = SIMP(statut='f',typ='TXM',
                                 fr=tr("1ère colonne de la table qui définit la fonction à récupérer"), ),
           PARA_Y        = SIMP(statut='f',typ='TXM',
                                 fr=tr("2ème colonne de la table qui définit la fonction à récupérer"), ),
           #b_tabl_fonc = BLOC(condition = "AsType(TABLE) == table_fonction",
           NOM_PARA_TABL = SIMP(statut='f',typ='TXM',into=("FONCTION","FONCTION_C"),
                                fr=tr("Nom du paramètre de la table contenant la fonction") ),
           #),

           FILTRE        = FACT(statut='f',max='**',
              NOM_PARA        =SIMP(statut='o',typ='TXM' ),
              CRIT_COMP       =SIMP(statut='f',typ='TXM',defaut="EQ",
                                    into=("EQ","LT","GT","NE","LE","GE","VIDE",
                                          "NON_VIDE","MAXI","MAXI_ABS","MINI","MINI_ABS") ),
              b_vale          =BLOC(condition = "(CRIT_COMP in ('EQ','NE','GT','LT','GE','LE'))",
                 regles=(UN_PARMI('VALE','VALE_I','VALE_K','VALE_C',),),
                 VALE            =SIMP(statut='f',typ='R' ),
                 VALE_I          =SIMP(statut='f',typ='I' ),
                 VALE_C          =SIMP(statut='f',typ='C' ),
                 VALE_K          =SIMP(statut='f',typ='TXM' ),),

              CRITERE         =SIMP(statut='f',typ='TXM',defaut="RELATIF",into=("RELATIF","ABSOLU") ),
              PRECISION       =SIMP(statut='f',typ='R',defaut= 1.E-3 ),
           ),
         ),

# ======= RESULTAT =================================================
         b_resu = BLOC ( condition = "RESULTAT != None", fr=tr("Opérandes en cas de RESULTAT"),
                         regles=(UN_PARMI('NOM_CHAM','NOM_PARA_RESU'),),
           NOM_CHAM        =SIMP(statut='f',typ='TXM',validators=NoRepeat(),into=C_NOM_CHAM_INTO()),
           NOM_PARA_RESU   =SIMP(statut='f',typ='TXM' ),
           b_cham = BLOC ( condition = "NOM_CHAM != None",
                           regles=(AU_MOINS_UN('MAILLE','GROUP_MA','GROUP_NO','NOEUD'),
                                   PRESENT_ABSENT('POINT','NOEUD','GROUP_NO'),
                                   PRESENT_ABSENT('SOUS_POINT','NOEUD','GROUP_NO'),
                                   EXCLUS('GROUP_MA','MAILLE'),
                                   EXCLUS('GROUP_NO','NOEUD'),),
             NOM_CMP         =SIMP(statut='o',typ='TXM' ),
             MAILLE          =SIMP(statut='f',typ=ma),
             GROUP_MA        =SIMP(statut='f',typ=grma),
             NOEUD           =SIMP(statut='f',typ=no),
             GROUP_NO        =SIMP(statut='f',typ=grno),
             POINT           =SIMP(statut='f',typ='I' ),
             SOUS_POINT      =SIMP(statut='f',typ='I' ),
           ),
         ),

# ======= RESU_GENE =================================================
         b_tran_gene = BLOC ( condition = "AsType(RESU_GENE) == tran_gene",
                              fr=tr("Récupération d'une fonction à partir d un concept TRAN_GENE"),
                              regles=(UN_PARMI('NOM_CHAM','NOEUD_CHOC','GROUP_NO_CHOC'),),
             NOM_CHAM        =SIMP(statut='f',typ='TXM',validators=NoRepeat(),into=("DEPL","VITE","ACCE","PTEM") ),
             NOEUD_CHOC      =SIMP(statut='f',typ=no),
             GROUP_NO_CHOC   =SIMP(statut='f',typ=grno),
           b_cham = BLOC ( condition = "(NOM_CHAM=='DEPL') or (NOM_CHAM=='VITE') or (NOM_CHAM=='ACCE')",
                           regles=(UN_PARMI('GROUP_NO','NOEUD','NUME_CMP_GENE',),
                                   UN_PARMI('NOM_CMP','NUME_CMP_GENE',),
                                   EXCLUS('MULT_APPUI','CORR_STAT'),),
             NOM_CMP         =SIMP(statut='f',typ='TXM' ),
             NUME_CMP_GENE   =SIMP(statut='f',typ='I',val_min = 1 ),
             NOEUD           =SIMP(statut='f',typ=no),
             GROUP_NO        =SIMP(statut='f',typ=grno),
             MULT_APPUI      =SIMP(statut='f',typ='TXM',into=("OUI",) ),
             CORR_STAT       =SIMP(statut='f',typ='TXM',into=("OUI",) ),
             ACCE_MONO_APPUI =SIMP(statut='f',typ=(fonction_sdaster,formule)),
           ),
           b_choc = BLOC ( condition = "(NOEUD_CHOC != None) or (GROUP_NO_CHOC != None)",
                           regles=(PRESENT_PRESENT('SOUS_STRUC','INTITULE'),),
             PARA_X          =SIMP(statut='o',typ='TXM',
                              into=("INST","FN","FT1","FT2","VN","VT1","VT2","DXLOC","DYLOC","DZLOC") ),
             PARA_Y          =SIMP(statut='o',typ='TXM',
                              into=("INST","FN","FT1","FT2","VN","VT1","VT2","DXLOC","DYLOC","DZLOC") ),
             LIST_PARA       =SIMP(statut='f',typ=listr8_sdaster ),
             INTITULE        =SIMP(statut='f',typ='TXM' ),
             SOUS_STRUC      =SIMP(statut='f',typ='TXM' ),
           ),
         ),
         b_harm_gene = BLOC ( condition = "AsType(RESU_GENE)==harm_gene",
                              fr=tr("Récupération d'une fonction à partir d un concept HARM_GENE"),
                              regles=(UN_PARMI('NOM_CMP','NUME_CMP_GENE'),
                                      UN_PARMI('GROUP_NO','NOEUD','NUME_CMP_GENE',),),
             NOM_CHAM        =SIMP(statut='f',typ='TXM',validators=NoRepeat(),into=("DEPL","VITE","ACCE") ),
             NOM_CMP         =SIMP(statut='f',typ='TXM' ),
             NUME_CMP_GENE   =SIMP(statut='f',typ='I',val_min = 1 ),
             NOEUD           =SIMP(statut='f',typ=no),
             GROUP_NO        =SIMP(statut='f',typ=grno),
         ),
         # b_harm_gene = BLOC ( condition = "AsType(RESU_GENE)==harm_gene",
         #                      fr=tr("Récupération d'une fonction à partir d un concept HARM_GENE"),
         #                      regles=(UN_PARMI('NOM_CHAM','NOM_PARA_RESU'),),
         #     NOM_CHAM        =SIMP(statut='f',typ='TXM',validators=NoRepeat(),into=C_NOM_CHAM_INTO()),
         #     NOM_PARA_RESU   =SIMP(statut='f',typ='TXM' ),
         #   b_cham = BLOC ( condition = "NOM_CHAM != None",
         #                   regles=(UN_PARMI('NUME_CMP_GENE','NOM_CMP'),),
         #     NUME_CMP_GENE   =SIMP(statut='f',typ='I' ),
         #     NOM_CMP         =SIMP(statut='f',typ='TXM' ),
         #     b_cmp = BLOC ( condition = "NOM_CMP != None",
         #                    regles=(UN_PARMI('NOEUD','GROUP_NO'),),
         #       NOEUD         =SIMP(statut='f',typ=no),
         #       GROUP_NO      =SIMP(statut='f',typ=grno),
         #     ),
         #   ),
         # ),
         b_mode_gene = BLOC ( condition = "AsType(RESU_GENE)==mode_gene",
                              fr=tr("Récupération d'une fonction à partir d un concept MODE_GENE"),
                              regles=(UN_PARMI('NOM_CHAM','NOM_PARA_RESU'),),
             NOM_CHAM        =SIMP(statut='f',typ='TXM',validators=NoRepeat(),into=C_NOM_CHAM_INTO()),
             NOM_PARA_RESU   =SIMP(statut='f',typ='TXM' ),
           b_cham = BLOC ( condition = "NOM_CHAM != None",
                           regles=(UN_PARMI('NUME_CMP_GENE','NOM_CMP'),),
             NUME_CMP_GENE   =SIMP(statut='f',typ='I',val_min = 1 ),
             NOM_CMP         =SIMP(statut='f',typ='TXM' ),
             b_cmp = BLOC ( condition = "NOM_CMP != None",
                            regles=(UN_PARMI('NOEUD','GROUP_NO'),
                                    UN_PARMI('SQUELETTE','SOUS_STRUC'),),
               NOEUD         =SIMP(statut='f',typ=no),
               GROUP_NO      =SIMP(statut='f',typ=grno),
               SQUELETTE     =SIMP(statut='f',typ=squelette ),
               SOUS_STRUC    =SIMP(statut='f',typ='TXM' ),  
             ),
           ),
         ),

# ======= CHAM_GD =================================================
         b_cham_gd = BLOC ( condition = "(CHAM_GD != None)", fr=tr("Opérandes en cas de CHAM_GD"),
                            regles=(AU_MOINS_UN('MAILLE','GROUP_MA','GROUP_NO','NOEUD'),
                                    PRESENT_ABSENT('POINT','NOEUD','GROUP_NO'),
                                    PRESENT_ABSENT('SOUS_POINT','NOEUD','GROUP_NO'),
                                    EXCLUS('GROUP_MA','MAILLE'),
                                    EXCLUS('GROUP_NO','NOEUD'),),
           NOM_CMP         =SIMP(statut='o',typ='TXM' ),
           MAILLE          =SIMP(statut='f',typ=ma),
           GROUP_MA        =SIMP(statut='f',typ=grma),
           NOEUD           =SIMP(statut='f',typ=no),
           GROUP_NO        =SIMP(statut='f',typ=grno),
           POINT           =SIMP(statut='f',typ='I' ),
           SOUS_POINT      =SIMP(statut='f',typ='I' ),
         ),

# ======= NAPPE =================================================
         b_nappe = BLOC ( condition = "(NAPPE != None)", fr=tr("Opérandes en cas de NAPPE"),
         VALE_PARA_FONC  =SIMP(statut='o',typ='R' ),
         PRECISION       =SIMP(statut='f',typ='R',defaut= 1.E-3 ),
         CRITERE         =SIMP(statut='f',typ='TXM',defaut="RELATIF",into=("RELATIF","ABSOLU") ),
         ),

# ======= SURCHARGE DES ATTRIBUTS =================================================
         NOM_PARA        =SIMP(statut='f',typ='TXM', into=C_PARA_FONCTION() ),
         NOM_RESU        =SIMP(statut='f',typ='TXM' ),
         INTERPOL        =SIMP(statut='f',typ='TXM',max=2,into=("NON","LIN","LOG") ),
         PROL_DROITE     =SIMP(statut='f',typ='TXM',into=("CONSTANT","LINEAIRE","EXCLU") ),
         PROL_GAUCHE     =SIMP(statut='f',typ='TXM',into=("CONSTANT","LINEAIRE","EXCLU") ),

         TITRE           =SIMP(statut='f',typ='TXM',max='**'),
         INFO            =SIMP(statut='f',typ='I',defaut= 1,into=( 1 , 2 ) ),
)  ;
