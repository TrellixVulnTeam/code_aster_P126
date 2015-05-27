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
# person_in_charge: mathieu.corus at edf.fr

IMPR_MACR_ELEM=PROC(nom="IMPR_MACR_ELEM",op= 160,
                    UIinfo={"groupes":("Impression","Outils-métier",)},
         fr=tr("Impression d'une structure de données MACR_ELEM_DYNA au format IDEAS MISS3D"),
         MACR_ELEM_DYNA  =SIMP(statut='o',typ=macr_elem_dyna ),
         FORMAT          =SIMP(statut='f',typ='TXM',defaut="IDEAS",
                               into=("MISS_3D","IDEAS") ),

         b_ideas         =BLOC(condition = "FORMAT == 'IDEAS'",
           UNITE           =SIMP(statut='f',typ='I',defaut=30),
           VERSION          =SIMP(statut='f',typ='I',defaut= 5,into=( 5 ,) ),
         ),             

         b_miss_3d       =BLOC(condition = "FORMAT == 'MISS_3D'",
           regles=(EXCLUS('AMOR_REDUIT','LIST_AMOR'),),
           UNITE           =SIMP(statut='f',typ='I',defaut= 26 ),
           SOUS_TITRE      =SIMP(statut='f',typ='TXM',max='**'),
           AMOR_REDUIT     =SIMP(statut='f',typ='R'  ,max='**'),
           LIST_AMOR       =SIMP(statut='f',typ=listr8_sdaster ),
           GROUP_MA_INTERF =SIMP(statut='o',typ=grma ,max='**'),
           GROUP_MA_FLU_STR=SIMP(statut='f',typ=grma,max='**'),
           GROUP_MA_FLU_SOL=SIMP(statut='f',typ=grma,max='**'),
           GROUP_MA_SOL_SOL=SIMP(statut='f',typ=grma,max='**'),
           GROUP_MA_CONTROL=SIMP(statut='f',typ=grma,max='**'),
           FORMAT_R        =SIMP(statut='f',typ='TXM',defaut="1PE12.5",into=("1PE12.5","1PE16.9") ),
           IMPR_MODE_MECA  =SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON") ),
           IMPR_MODE_STAT  =SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON") ),
         ),


)  ;
