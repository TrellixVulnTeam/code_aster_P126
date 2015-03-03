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
# person_in_charge: serguei.potapov at edf.fr

LIRE_PLEXUS=OPER(nom="LIRE_PLEXUS",op= 184,sd_prod=evol_char,
                 fr=tr("Lire le fichier de résultats au format IDEAS produit par le logiciel EUROPLEXUS"),
                 reentrant='n',
            UIinfo={"groupes":("Lecture","Outils-métier",)},
         regles=(UN_PARMI('TOUT_ORDRE','NUME_ORDRE','INST','LIST_INST','LIST_ORDRE'),),
         UNITE           =SIMP(statut='f',typ='I',defaut= 19 ),
         FORMAT          =SIMP(statut='f',typ='TXM',defaut="IDEAS",into=("IDEAS",)),
         MAIL_PLEXUS     =SIMP(statut='o',typ=maillage_sdaster ),
         MAILLAGE        =SIMP(statut='o',typ=maillage_sdaster ),
         MODELE          =SIMP(statut='o',typ=modele_sdaster ),
         TOUT_ORDRE      =SIMP(statut='f',typ='TXM',into=("OUI",) ),
         NUME_ORDRE      =SIMP(statut='f',typ='I',validators=NoRepeat(),max='**'),
         LIST_ORDRE      =SIMP(statut='f',typ=listis_sdaster ),
         INST            =SIMP(statut='f',typ='R',validators=NoRepeat(),max='**'),
         LIST_INST       =SIMP(statut='f',typ=listr8_sdaster ),
         b_prec_crit     =BLOC(condition = "LIST_INST != None or INST != None",
               CRITERE         =SIMP(statut='f',typ='TXM',defaut="RELATIF",into=("RELATIF","ABSOLU",),),
               b_prec_rela=BLOC(condition="(CRITERE=='RELATIF')",
                   PRECISION       =SIMP(statut='f',typ='R',defaut= 1.E-6,),),
               b_prec_abso=BLOC(condition="(CRITERE=='ABSOLU')",
                   PRECISION       =SIMP(statut='o',typ='R',),),),
         TITRE           =SIMP(statut='f',typ='TXM',max='**'),
)  ;
