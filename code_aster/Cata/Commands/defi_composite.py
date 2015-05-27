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
# person_in_charge: xavier.desroches at edf.fr
DEFI_COMPOSITE=OPER(nom="DEFI_COMPOSITE",op=56,sd_prod=mater_sdaster,reentrant='n',
            UIinfo={"groupes":("Modélisation",)},
                    fr=tr("Déterminer les caractéristiques matériaux homogénéisées d'une coque multicouche à partir"
                        " des caractéristiques de chaque couche"),
         COUCHE          =FACT(statut='o',max='**',
           EPAIS           =SIMP(statut='o',typ='R',val_min=0.E+0 ),
           MATER           =SIMP(statut='o',typ=(mater_sdaster) ),
           ORIENTATION     =SIMP(statut='f',typ='R',defaut= 0.E+0,
                                 val_min=-90.E+0,val_max=90.E+0   ),
         ),
         IMPRESSION      =FACT(statut='f',
           UNITE           =SIMP(statut='f',typ='I',defaut=8),
         ),
)  ;
