# coding=utf-8

from Cata.Descriptor import *
from Cata.Commons import *

# ======================================================================
# COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
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
# person_in_charge: xavier.desroches at edf.fr
INTE_MAIL_2D=OPER(nom="INTE_MAIL_2D",op=50,sd_prod=courbe_sdaster,
            UIinfo={"groupes":("Post-traitements",)},
                  fr=tr("Définition d'une courbe dans un maillage 2D"),reentrant='n',

         MAILLAGE        =SIMP(statut='o',typ=(maillage_sdaster) ),

         regles=(PRESENT_ABSENT('TOUT','GROUP_MA','MAILLE'),
                 AU_MOINS_UN('DEFI_SEGMENT','DEFI_ARC','DEFI_CHEMIN'),
                 PRESENT_ABSENT('DEFI_CHEMIN','DEFI_SEGMENT','DEFI_ARC'),
                 PRESENT_ABSENT('DEFI_SEGMENT','NOEUD_ORIG','GROUP_NO_ORIG'),
                 PRESENT_ABSENT('DEFI_ARC','NOEUD_ORIG','GROUP_NO_ORIG'),
                 EXCLUS('NOEUD_ORIG','GROUP_NO_ORIG'),
                 EXCLUS('DEFI_CHEMIN','DEFI_SEGMENT'),
                 EXCLUS('DEFI_CHEMIN','DEFI_ARC'),),

         TOUT            =SIMP(statut='f',typ='TXM',into=("OUI",) ),
         GROUP_MA        =SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
         MAILLE          =SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),

         DEFI_SEGMENT    =FACT(statut='f',max='**',
           regles=(UN_PARMI('ORIGINE','NOEUD_ORIG','GROUP_NO_ORIG'),
                   UN_PARMI('EXTREMITE','NOEUD_EXTR','GROUP_NO_EXTR'),),
           ORIGINE         =SIMP(statut='f',typ='R',min=2,max=2),  
           NOEUD_ORIG      =SIMP(statut='f',typ=no,),
           GROUP_NO_ORIG   =SIMP(statut='f',typ=grno,),
           EXTREMITE       =SIMP(statut='f',typ='R',min=2,max=2),  
           NOEUD_EXTR      =SIMP(statut='f',typ=no,),
           GROUP_NO_EXTR   =SIMP(statut='f',typ=grno,),
         ),

         DEFI_ARC        =FACT(statut='f',max='**',
           regles=(UN_PARMI('CENTRE','NOEUD_CENTRE','GROUP_NO_CENTRE'),
                   UN_PARMI('RAYON','ORIGINE','NOEUD_ORIG','GROUP_NO_ORIG'),
                   UN_PARMI('RAYON','EXTREMITE','NOEUD_EXTR','GROUP_NO_EXTR'),               
                   PRESENT_PRESENT('RAYON','SECTEUR'),),
           CENTRE          =SIMP(statut='f',typ='R',min=2,max=2),  
           NOEUD_CENTRE    =SIMP(statut='f',typ=no,),
           GROUP_NO_CENTRE =SIMP(statut='f',typ=grno,),
           RAYON           =SIMP(statut='f',typ='R',val_min=0.E+0),  
           SECTEUR         =SIMP(statut='f',typ='R',min=2,max=2,
                                 val_min=-180.E+0,val_max=180E+0),  
           ORIGINE         =SIMP(statut='f',typ='R',min=2,max=2),  
           NOEUD_ORIG      =SIMP(statut='f',typ=no,),
           GROUP_NO_ORIG   =SIMP(statut='f',typ=grno,),
           EXTREMITE       =SIMP(statut='f',typ='R',min=2,max=2),  
           NOEUD_EXTR      =SIMP(statut='f',typ=no,),
           GROUP_NO_EXTR   =SIMP(statut='f',typ=grno,),
           PRECISION       =SIMP(statut='f',typ='R',defaut= 1.0E-3 ),  
           CRITERE         =SIMP(statut='f',typ='TXM',defaut="RELATIF",    
                                 into=("RELATIF","ABSOLU",) ),
         ),

         DEFI_CHEMIN     =FACT(statut='f',max='**',
           regles=(UN_PARMI('MAILLE','GROUP_MA'),),
           MAILLE          =SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
           GROUP_MA        =SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
         ),

         NOEUD_ORIG      =SIMP(statut='f',typ=no,),
         GROUP_NO_ORIG   =SIMP(statut='f',typ=grno,),
         PRECISION       =SIMP(statut='f',typ='R',defaut=1.0E-3),  
         INFO            =SIMP(statut='f',typ='I',defaut=1,into=(1,2)),
)  ;
