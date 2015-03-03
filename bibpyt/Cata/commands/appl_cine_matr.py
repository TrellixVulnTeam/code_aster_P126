# coding=utf-8

from Cata.Descriptor import *
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
# person_in_charge: jacques.pellet at edf.fr

def appl_cine_matr_prod(MATR_ASSE,**args):
  if AsType(MATR_ASSE) == matr_asse_depl_r : return matr_asse_depl_r
  if AsType(MATR_ASSE) == matr_asse_depl_c : return matr_asse_depl_c
  if AsType(MATR_ASSE) == matr_asse_temp_r : return matr_asse_temp_r
  if AsType(MATR_ASSE) == matr_asse_temp_c : return matr_asse_temp_c
  if AsType(MATR_ASSE) == matr_asse_pres_r : return matr_asse_pres_r
  if AsType(MATR_ASSE) == matr_asse_pres_c : return matr_asse_pres_c
  raise AsException("type de concept resultat non prevu")

APPL_CINE_MATR=OPER(nom="APPL_CINE_MATR",op=158,sd_prod=appl_cine_matr_prod,
               fr=tr("Appliquer les C.L. cinématiques sur la matrice"),
               reentrant='f', UIinfo={"groupes":("Résolution",)},
         MATR_ASSE       =SIMP(statut='o',typ=(matr_asse_depl_r,matr_asse_depl_c,matr_asse_temp_r,
                                               matr_asse_temp_c,matr_asse_pres_r,matr_asse_pres_c) ),
         TITRE           =SIMP(statut='f',typ='TXM',max='**'),
         INFO            =SIMP(statut='f',typ='I',into=(1,2) ),
)  ;
