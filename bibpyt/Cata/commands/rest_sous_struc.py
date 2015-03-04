# coding=utf-8

from Cata.Syntax import *
from Cata.DataStructure import *
from Cata.Commons import *

# ======================================================================
# COPYRIGHT (C) 1991 - 2011  EDF R&D                  WWW.CODE-ASTER.ORG
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

# person_in_charge: mathieu.corus at edf.fr
def rest_sous_struc_prod(RESU_GENE,RESULTAT,**args ):
  if AsType(RESU_GENE) == tran_gene : return dyna_trans
  if AsType(RESU_GENE) == mode_gene : return mode_meca
  if AsType(RESU_GENE) == mode_cycl : return mode_meca
  if AsType(RESU_GENE) == harm_gene : return dyna_harmo
  if AsType(RESULTAT)  == evol_noli      : return evol_noli
  if AsType(RESULTAT)  == dyna_trans     : return dyna_trans
  if AsType(RESULTAT)  == mode_meca      : return mode_meca
  raise AsException("type de concept resultat non prevu")

REST_SOUS_STRUC=OPER(nom="REST_SOUS_STRUC",op=  77,sd_prod=rest_sous_struc_prod,
          fr=tr("Restituer dans la base physique des résultats obtenus par sous-structuration"),
                    reentrant='n',
            UIinfo={"groupes":("Matrices et vecteurs",)},
        regles=(UN_PARMI('RESU_GENE','RESULTAT'),
# ajout d'une regle de Ionel et Nicolas:
#                UN_PARMI('NOM_CHAM','TOUT_CHAM'),
#
              EXCLUS('TOUT_ORDRE','NUME_ORDRE','INST','LIST_INST','TOUT_INST','NUME_MODE',
                     'FREQ', 'LIST_FREQ'),
#  Doc U à revoir
              EXCLUS('NOEUD','GROUP_NO'),
              EXCLUS('MAILLE','GROUP_MA'),
              PRESENT_PRESENT('RESULTAT','SQUELETTE'),
              UN_PARMI('SQUELETTE','SOUS_STRUC','SECTEUR'),

                ),
         RESULTAT        =SIMP(statut='f',typ=(evol_noli,dyna_trans,
                                            mode_meca) ),
         RESU_GENE       =SIMP(statut='f',typ=(tran_gene,mode_gene,mode_cycl,harm_gene) ),
         NUME_DDL        =SIMP(statut='f',typ=nume_ddl_sdaster ),
         MODE_MECA       =SIMP(statut='f',typ=mode_meca ),
         TOUT_ORDRE      =SIMP(statut='f',typ='TXM',into=("OUI",) ),
         NUME_ORDRE      =SIMP(statut='f',typ='I',validators=NoRepeat(),max='**' ),  
         NUME_MODE       =SIMP(statut='f',typ='I',validators=NoRepeat(),max='**' ),  
         TOUT_INST       =SIMP(statut='f',typ='TXM',into=("OUI",) ),
         INST            =SIMP(statut='f',typ='R',validators=NoRepeat(),max='**' ),  
         LIST_INST       =SIMP(statut='f',typ=listr8_sdaster ),
         FREQ            =SIMP(statut='f',typ='R',validators=NoRepeat(),max='**' ),  
         LIST_FREQ       =SIMP(statut='f',typ=listr8_sdaster ),
         CRITERE         =SIMP(statut='f',typ='TXM',defaut="RELATIF",into=("ABSOLU","RELATIF") ),
         b_prec_rela=BLOC(condition="(CRITERE=='RELATIF')",
             PRECISION       =SIMP(statut='f',typ='R',defaut= 1.E-6,),),
         b_prec_abso=BLOC(condition="(CRITERE=='ABSOLU')",
             PRECISION       =SIMP(statut='o',typ='R',),),
         INTERPOL        =SIMP(statut='f',typ='TXM',defaut="NON",into=("NON","LIN") ),
         TOUT_CHAM       =SIMP(statut='f',typ='TXM',into=("OUI",) ),
         b_nom_cham=BLOC(condition="TOUT_CHAM == None",
             NOM_CHAM        =SIMP(statut='f',typ='TXM',validators=NoRepeat(),max=8,defaut="ACCE",into=("DEPL",
                                   "VITE","ACCE","ACCE_ABSOLU","EFGE_ELNO","SIPO_ELNO","SIGM_ELNO","FORC_NODA",) ),),
         GROUP_NO        =SIMP(statut='f',typ=grno,validators=NoRepeat(),max='**'),
         NOEUD           =SIMP(statut='f',typ=no  ,validators=NoRepeat(),max='**'),
         GROUP_MA        =SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
         MAILLE          =SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
         CYCLIQUE    =FACT(statut='f',max='**',
           NB_SECTEUR      =SIMP(statut='f',typ='I',validators=NoRepeat(),max=1 ),
           NUME_DIAMETRE    =SIMP(statut='f',typ='I',validators=NoRepeat(),max=1 ),
           RESULTAT2       =SIMP(statut='f',typ=(evol_elas,evol_noli,dyna_trans,evol_char,
                                               mode_meca) ),
         ),

         SQUELETTE       =SIMP(statut='f',typ=squelette ),
         SOUS_STRUC      =SIMP(statut='f',typ='TXM' ),  
         SECTEUR         =SIMP(statut='f',typ='I'),  
         TITRE           =SIMP(statut='f',typ='TXM',max='**' ),  
)  ;
