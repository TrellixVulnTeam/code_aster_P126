# coding=utf-8

from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *

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
# person_in_charge: samuel.geniaut at edf.fr

PROPA_XFEM=OPER(nom="PROPA_XFEM",op=10,sd_prod=fiss_xfem,reentrant='n',
                UIinfo={"groupes":("Post-traitements","Rupture",)},
                fr=tr("Propagation de fissure avec X-FEM"),
    
    METHODE =SIMP(statut='f',typ='TXM',into=("SIMPLEXE","GEOMETRIQUE","UPWIND"),defaut="GEOMETRIQUE"),

    OPERATION =SIMP(statut='f',typ='TXM',into=("RIEN","DETECT_COHESIF","PROPA_COHESIF"),defaut="RIEN"),

    MODELE        =SIMP(statut='o',typ=modele_sdaster),

    TEST_MAIL     =SIMP(statut='f',typ='TXM',into=("NON","OUI",),defaut="NON"),

    b_detec =BLOC( condition = "OPERATION != 'DETECT_COHESIF' ",
    DA_MAX        =SIMP(statut='o',typ='R'),
    ),

    FISS_PROP     =SIMP(statut='o',typ=fiss_xfem),

    ZONE_MAJ      =SIMP(statut='f',typ='TXM',into=("TOUT","TORE"),defaut="TORE"),

    RAYON_TORE    =SIMP(statut='f',typ='R'),

    LISTE_FISS    =SIMP(statut='o',typ=fiss_xfem,min=1,max='**'),

    ANGLE_BETA         =SIMP(statut='f',typ='R',max='**'),
    
    ANGLE_GAMMA         =SIMP(statut='f',typ='R',max='**'),
    
    NOM_PARA_ANGLE =SIMP(statut='f',typ='TXM', into=("BETA","BETA_GAMMA"),defaut="BETA"),        
    
    VITESSE       =SIMP(statut='f',typ='R',max='**'),
    b_pas_cohe    =BLOC(condition = "(OPERATION!= 'PROPA_COHESIF') and (OPERATION != 'DETECT_COHESIF')",
        DA_FISS       =SIMP(statut='f',typ='R'),
        NB_CYCLES     =SIMP(statut='f',typ='R'),        
        RAYON          =SIMP(statut='o',typ='R',),
    ),

    b_test_mail_const =BLOC( condition = "TEST_MAIL == 'OUI' ",
                             FISS_INITIALE =SIMP(statut='o',typ=fiss_xfem,max=1),
                             DISTANCE      =SIMP(statut='o',typ='R',max=1),
                             TOLERANCE     =SIMP(statut='o',typ='R',max=1),
                           ),
          
    INFO           =SIMP(statut='f',typ='I',defaut= 0,into=(0,1,2) ),
)  ;
