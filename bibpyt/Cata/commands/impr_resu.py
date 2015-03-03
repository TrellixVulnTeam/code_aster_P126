# coding=utf-8

from Cata.Descriptor import *

# ======================================================================
# COPYRIGHT (C) 1991 - 2013  EDF R&D                  WWW.CODE-ASTER.ORG
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
# person_in_charge: nicolas.sellenet at edf.fr
IMPR_RESU=PROC(nom="IMPR_RESU",op=39,
            UIinfo={"groupes":("Impression","Résultats et champs",)},
               fr=tr("Imprimer un maillage et/ou les résultats d'un calcul (différents formats)"),

         FORMAT          =SIMP(statut='f',typ='TXM',position='global',defaut="RESULTAT",
                                 into=("RESULTAT","IDEAS","ASTER","CASTEM","MED","GMSH") ),

         b_modele =BLOC(condition="FORMAT!='MED'",fr=tr("Modèle"),
           MODELE          =SIMP(statut='f',typ=modele_sdaster),
         ),

         b_format_resultat  =BLOC(condition="FORMAT=='RESULTAT'",fr=tr("unité logique d'impression au format RESULTAT"),
           UNITE           =SIMP(statut='f',typ='I',defaut=8),
         ),

         b_format_ideas  =BLOC(condition="FORMAT=='IDEAS'",fr=tr("unité logique d'impression et version IDEAS"),
           UNITE           =SIMP(statut='f',typ='I',defaut=30),
           VERSION         =SIMP(statut='f',typ='I',defaut=5,into=(4,5)),
         ),

         b_format_aster  =BLOC(condition="FORMAT=='ASTER'",fr=tr("unité logique d'impression au format ASTER"),
           UNITE           =SIMP(statut='f',typ='I',defaut=26),
         ),

         b_format_castem =BLOC(condition="FORMAT=='CASTEM'",fr=tr("unité logique d'impression et version CASTEM"),
           UNITE           =SIMP(statut='f',typ='I',defaut=37),
           NIVE_GIBI       =SIMP(statut='f',typ='I',defaut=10,into=(3,10)),
         ),

         b_format_med  =BLOC(condition="FORMAT=='MED'",fr=tr("unité logique d'impression au format MED"),
           UNITE           =SIMP(statut='f',typ='I',defaut=80),
         ),

         b_format_gmsh  =BLOC(condition="FORMAT=='GMSH'",fr=tr("unité logique d'impression et version GMSH"),
           UNITE           =SIMP(statut='f',typ='I',defaut=37),
           VERSION         =SIMP(statut='f',typ='R',defaut=1.2,into=(1.0,1.2)),
         ),

         regles=(AU_MOINS_UN('CONCEPT','RESU',),),

         CONCEPT          =FACT(statut='f',max='**',
           fr=tr('Pour imprimer les champs de "données" à des fins de visualisation (controle des affectations).'),
           # (valide pour les format RESULTAT et MED)
           regles=(UN_PARMI('CHAM_MATER','CARA_ELEM','CHARGE'),),
           CHAM_MATER      =SIMP(statut='f',typ=cham_mater),
           CARA_ELEM       =SIMP(statut='f',typ=cara_elem),
           CHARGE          =SIMP(statut='f',typ=char_meca),

           b_cara_elem        =BLOC(condition="CARA_ELEM != None", fr=tr("impression des reperes locaux."),
              REPERE_LOCAL    =SIMP(statut='f',typ='TXM',defaut="NON",into=("OUI","NON")),
              b_reploc        =BLOC(condition="REPERE_LOCAL == 'OUI'", fr=tr("impression des reperes locaux."),
                 MODELE          =SIMP(statut='o',typ=modele_sdaster),
              ),
           ),
         ),

         RESU            =FACT(statut='f',max='**',

           regles=(AU_MOINS_UN('CHAM_GD','RESULTAT','MAILLAGE',),
                   EXCLUS('CHAM_GD','RESULTAT'),),
           MAILLAGE        =SIMP(statut='f',typ=(maillage_sdaster,squelette)),
           CARA_ELEM       =SIMP(statut='f',typ=cara_elem),
           CHAM_GD         =SIMP(statut='f',typ=cham_gd_sdaster),
           RESULTAT        =SIMP(statut='f',typ=resultat_sdaster),

           b_info_med  =BLOC(condition="FORMAT=='MED'",
             INFO_MAILLAGE   =SIMP(statut='f',typ='TXM',defaut="NON",into=("OUI","NON") ),
           ),


           b_partie        =BLOC(condition="""(AsType(RESULTAT) in (dyna_harmo, acou_harmo) or
                          AsType(CHAM_GD) != carte_sdaster) and FORMAT in ('CASTEM', 'GMSH', 'MED')""",
             PARTIE          =SIMP(statut='f',typ='TXM',into=("REEL","IMAG") ),
           ),

           b_vari_el       =BLOC(condition="FORMAT==('MED')",
             IMPR_NOM_VARI=SIMP(statut='f',typ='TXM',into=("OUI","NON"),defaut="NON",),
           ),

           b_extrac        =BLOC(condition="RESULTAT != None",
                                 fr=tr("extraction d un champ de grandeur"),
             regles=(EXCLUS('TOUT_CHAM','NOM_CHAM'),
                     EXCLUS('TOUT_ORDRE','NUME_ORDRE','INST','FREQ','NUME_MODE','NOEUD_CMP',
                            'LIST_INST','LIST_FREQ','LIST_ORDRE','NOM_CAS','ANGLE'),),
             TOUT_CHAM       =SIMP(statut='f',typ='TXM',into=("OUI","NON") ),
             NOM_CHAM        =SIMP(statut='f',typ='TXM',validators=NoRepeat(),max='**',into=C_NOM_CHAM_INTO()),

             TOUT_ORDRE      =SIMP(statut='f',typ='TXM',into=("OUI",) ),
             NUME_ORDRE      =SIMP(statut='f',typ='I',validators=NoRepeat(),max='**'),
             NUME_MODE       =SIMP(statut='f',typ='I',validators=NoRepeat(),max='**'),
             LIST_ORDRE      =SIMP(statut='f',typ=listis_sdaster),
             NOEUD_CMP       =SIMP(statut='f',typ='TXM',validators=NoRepeat(),max='**'),
             NOM_CAS         =SIMP(statut='f',typ='TXM',validators=NoRepeat(),max='**'),
             ANGLE           =SIMP(statut='f',typ='R',validators=NoRepeat(),max='**'),
             FREQ            =SIMP(statut='f',typ='R',validators=NoRepeat(),max='**'),
             LIST_FREQ       =SIMP(statut='f',typ=listr8_sdaster),
             INST            =SIMP(statut='f',typ='R',validators=NoRepeat(),max='**'),
             LIST_INST       =SIMP(statut='f',typ=listr8_sdaster),

             b_acce_reel     =BLOC(condition="(ANGLE != None)or(FREQ != None)or(LIST_FREQ != None)or(INST != None)or(LIST_INST != None)",
                CRITERE         =SIMP(statut='f',typ='TXM',defaut="RELATIF",into=("RELATIF","ABSOLU",),),
                b_prec_rela=BLOC(condition="(CRITERE=='RELATIF')",
                     PRECISION       =SIMP(statut='f',typ='R',defaut= 1.E-6,),),
                b_prec_abso=BLOC(condition="(CRITERE=='ABSOLU')",
                     PRECISION       =SIMP(statut='o',typ='R',),),
             ),
           ),
###
           b_parametres    =BLOC(condition="""(RESULTAT != None)and(FORMAT == 'RESULTAT')""",
             regles=(EXCLUS('TOUT_PARA','NOM_PARA'),),
             TOUT_PARA       =SIMP(statut='f',typ='TXM',into=("OUI","NON",) ),
             NOM_PARA        =SIMP(statut='f',typ='TXM',max='**'),
             FORM_TABL       =SIMP(statut='f',typ='TXM',defaut="NON",into=("OUI","NON","EXCEL") ),
           ),
###
           b_cmp=BLOC(condition="""((CHAM_GD != None)or(RESULTAT != None))and\
           ((FORMAT == 'CASTEM')or(FORMAT == 'RESULTAT')or(FORMAT == 'IDEAS')or(FORMAT == 'MED'))""",
                                fr=tr("sélection des composantes"),
             regles=(EXCLUS('TOUT_CMP','NOM_CMP'),),
             TOUT_CMP        =SIMP(statut='f',typ='TXM',into=("OUI",) ),
             NOM_CMP         =SIMP(statut='f',typ='TXM',max='**'),
           ),
###
           b_med=BLOC(condition="""((CHAM_GD != None)or(RESULTAT != None))and(FORMAT == 'MED')""",
                                fr=tr("renommage du champ"),
             regles=(EXCLUS('NOM_CHAM_MED','NOM_RESU_MED'),),
             NOM_CHAM_MED    =SIMP(statut='f',typ='TXM',
                                   validators=AndVal((LongStr(1,64), NoRepeat())), max='**'),
             NOM_RESU_MED    =SIMP(statut='f',typ='TXM'),
           ),
###
           b_gmsh=BLOC(condition="""((CHAM_GD != None)or(RESULTAT != None))and((FORMAT == 'GMSH'))""",
                                fr=tr("sélection des composantes et des entités toplogiques"),
             MAILLE          =SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
             GROUP_MA        =SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
             TYPE_CHAM       =SIMP(statut='f',typ='TXM',defaut="SCALAIRE",
                                   into=("VECT_2D","VECT_3D","SCALAIRE","TENS_2D","TENS_3D"),),
             b_scal          =BLOC(condition = "TYPE_CHAM=='SCALAIRE'",
               NOM_CMP         =SIMP(statut='f',typ='TXM',max='**' ),),
             b_vect_2d       =BLOC(condition = "TYPE_CHAM=='VECT_2D'",
               NOM_CMP         =SIMP(statut='o',typ='TXM',min=2,max=2 ),),
             b_vect_3d       =BLOC(condition = "TYPE_CHAM=='VECT_3D'",
               NOM_CMP         =SIMP(statut='o',typ='TXM',min=3,max=3 ),),
             b_tens_2d       =BLOC(condition = "TYPE_CHAM=='TENS_2D'",
               NOM_CMP         =SIMP(statut='o',typ='TXM',min=4,max=4 ),),
             b_tens_3d       =BLOC(condition = "TYPE_CHAM=='TENS_3D'",
               NOM_CMP         =SIMP(statut='o',typ='TXM',min=6,max=6 ),),
           ),
###
           b_topologie=BLOC(condition="""((CHAM_GD != None)or(RESULTAT != None))and\
           ((FORMAT == 'RESULTAT')or(FORMAT == 'IDEAS')or(FORMAT == 'MED'))""",
                                fr=tr("sélection des entités topologiques"),
             TOUT            =SIMP(statut='f',typ='TXM',into=("OUI",) ),
             NOEUD           =SIMP(statut='f',typ=no  ,validators=NoRepeat(),max='**'),
             GROUP_NO        =SIMP(statut='f',typ=grno,validators=NoRepeat(),max='**'),
             MAILLE          =SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
             GROUP_MA        =SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
           ),
###
           b_valeurs=BLOC(condition="(FORMAT == 'RESULTAT')",
                               fr=tr("sélection sur les valeurs"),
             VALE_MAX        =SIMP(statut='f',typ='TXM',into=("OUI",) ),
             VALE_MIN        =SIMP(statut='f',typ='TXM',into=("OUI",) ),
             BORNE_SUP       =SIMP(statut='f',typ='R'),
             BORNE_INF       =SIMP(statut='f',typ='R'),
             IMPR_COOR       =SIMP(statut='f',typ='TXM',defaut="NON",into=("OUI","NON") ),
           ),

           b_format_r=BLOC(condition="""((FORMAT == 'RESULTAT')or(FORMAT == 'ASTER'))""",
                           fr=tr("Format des nombres réels"),
             FORMAT_R        =SIMP(statut='f',typ='TXM',defaut="1PE21.14"),
           ),

           SOUS_TITRE      =SIMP(statut='f',typ='TXM',max='**'),
         ),
         INFO            =SIMP(statut='f',typ='I',defaut=1,into=(1,2) ),
) ;
