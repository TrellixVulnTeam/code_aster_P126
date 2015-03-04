# coding=utf-8

from Cata.Syntax import *
from Cata.DataStructure import *
from Cata.Commons import *

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
# person_in_charge: andre.adobes at edf.fr
REST_SPEC_PHYS=OPER(nom="REST_SPEC_PHYS",op= 148,sd_prod=interspectre,
                    reentrant='n',
            fr=tr("Calculer la réponse d'une structure dans la base physique"),
            UIinfo={"groupes":("Matrices et vecteurs",)},
         regles=(AU_MOINS_UN('BASE_ELAS_FLUI','MODE_MECA'),),        
         BASE_ELAS_FLUI  =SIMP(statut='f',typ=melasflu_sdaster ),
         b_fluide = BLOC(condition="BASE_ELAS_FLUI !=None",
           VITE_FLUI      =SIMP(statut='o',typ='R'),
           PRECISION       =SIMP(statut='f',typ='R',defaut=1.0E-3 ),
         ),
         MODE_MECA       =SIMP(statut='f',typ=mode_meca,),
         BANDE           =SIMP(statut='f',typ='R',min=2,validators=NoRepeat(),max=2    ),  
         NUME_ORDRE      =SIMP(statut='f',typ='I'      ,validators=NoRepeat(),max='**' ),
         TOUT_ORDRE       =SIMP(statut='f',typ='TXM',defaut="NON",  into=("OUI","NON")  ),
         INTE_SPEC_GENE  =SIMP(statut='o',typ=interspectre),
         NOEUD           =SIMP(statut='o',typ=no   ,max='**'),
         MAILLE          =SIMP(statut='f',typ=ma   ,max='**'),
         NOM_CMP         =SIMP(statut='o',typ='TXM',max='**'),  
         NOM_CHAM        =SIMP(statut='o',typ='TXM',validators=NoRepeat(),max=7,into=("DEPL",
                               "VITE","ACCE","EFGE_ELNO","SIPO_ELNO","SIGM_ELNO","FORC_NODA") ),
         MODE_STAT       =SIMP(statut='f',typ=mode_meca ),
         EXCIT           =FACT(statut='f',
           NOEUD           =SIMP(statut='o',typ=no   ,max='**'),
           NOM_CMP         =SIMP(statut='o',typ='TXM',max='**'),  
         ),
         MOUVEMENT       =SIMP(statut='f',typ='TXM',defaut="ABSOLU",into=("RELATIF","ABSOLU","DIFFERENTIEL") ),
         OPTION          =SIMP(statut='f',typ='TXM',defaut="DIAG_DIAG",    
                               into=("DIAG_TOUT","DIAG_DIAG","TOUT_TOUT","TOUT_DIAG") ),
         TITRE           =SIMP(statut='f',typ='TXM',max='**' ),  
)  ;
