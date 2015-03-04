# coding=utf-8

from Cata.Syntax import *
from Cata.DataStructure import *
from Cata.Commons import *

# ======================================================================
# COPYRIGHT (C) 1991 - 2008  EDF R&D                  WWW.CODE-ASTER.ORG
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
# person_in_charge: Georges-cc.devesa at edf.fr
def rest_spec_temp_prod(RESU_GENE,RESULTAT,**args):
  if AsType(RESULTAT) == dyna_harmo    : return dyna_trans
  if AsType(RESU_GENE) == harm_gene    : return tran_gene
  if AsType(RESULTAT) == dyna_trans    : return dyna_harmo
  if AsType(RESU_GENE) == tran_gene    : return harm_gene
  raise AsException("type de concept resultat non prevu")


REST_SPEC_TEMP=OPER(nom="REST_SPEC_TEMP",op=181,sd_prod=rest_spec_temp_prod,
              fr=tr("Transformée de Fourier d'un résultat"),
              reentrant='n',
            UIinfo={"groupes":("Matrices et vecteurs",)},
         regles=UN_PARMI('RESU_GENE','RESULTAT'),
         RESU_GENE       =SIMP(statut='f',typ=(harm_gene,tran_gene,) ),
         RESULTAT        =SIMP(statut='f',typ=(dyna_harmo,dyna_trans,) ),
         METHODE         =SIMP(statut='f',typ='TXM',defaut="PROL_ZERO",into=("PROL_ZERO","TRONCATURE") ),
         SYMETRIE        =SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON") ),
         TOUT_CHAM       =SIMP(statut='f',typ='TXM',into=("OUI",)),
         NOM_CHAM        =SIMP(statut='f',typ='TXM',validators=NoRepeat(),max=3,into=("DEPL","VITE","ACCE") ),
);
