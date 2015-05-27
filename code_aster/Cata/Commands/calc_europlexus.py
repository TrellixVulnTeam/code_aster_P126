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
# person_in_charge: serguei.potapov at edf.fr

def calc_europlexus_prod(self,COURBE=None,**args):
  if COURBE is not None:
      self.type_sdprod(args['TABLE_COURBE'],table_sdaster)
  return evol_noli

CALC_EUROPLEXUS = MACRO(nom="CALC_EUROPLEXUS",
                        op=OPS('Macro.calc_europlexus_ops.calc_europlexus_ops'),
                        sd_prod=calc_europlexus_prod,
                        reentrant='n',
                        UIinfo={"groupes":("Outils-métier","Dynamique",)},
                        fr=tr("Chainage Code_Aster-Europlexus"),
                        regles=(UN_PARMI('ETAT_INIT','MODELE'),
                                UN_PARMI('ETAT_INIT','CHAM_MATER'),
                                EXCLUS('ETAT_INIT','FONC_PARASOL'),
                                AU_MOINS_UN('COMPORTEMENT'),),
        LOGICIEL = SIMP(statut='f', typ='TXM'),
        LANCEMENT = SIMP(statut='o', typ='TXM', defaut='OUI',into=('OUI','NON')),

        ETAT_INIT = FACT(statut='f',regles=(PRESENT_PRESENT('VARI_INT','CONTRAINTE'),),
           RESULTAT    = SIMP(statut='o',typ=evol_noli),
           CONTRAINTE = SIMP(statut='f', typ='TXM', defaut='NON',into=('OUI','NON')),
           VARI_INT   = SIMP(statut='f', typ='TXM', defaut='NON',into=('OUI','NON')),
           EQUILIBRE  = SIMP(statut='f', typ='TXM', defaut='OUI',into=('OUI','NON')),
           b_niter          =BLOC(condition = "CONTRAINTE == 'NON' ",
                                 NITER = SIMP(statut='f',typ='I',defaut=1),
                                 ),
        ),
        MODELE     = SIMP(statut='f',typ=modele_sdaster),
        CARA_ELEM  = SIMP(statut='f',typ=cara_elem),

        FONC_PARASOL = FACT(statut='f',max='**',
           regles=(PRESENT_PRESENT('NFKT','NFKR'),AU_MOINS_UN('NFKT','NFAT'),),
           NFKT       = SIMP(statut='f',typ=(fonction_sdaster,)),
           NFKR       = SIMP(statut='f',typ=(fonction_sdaster,)),
           NFAT       = SIMP(statut='f',typ=(fonction_sdaster,)),
           NFAR       = SIMP(statut='f',typ=(fonction_sdaster,)),
           GROUP_MA   = SIMP(statut='o',typ=grma,validators=NoRepeat(),max='**'),
           ),


        CHAM_MATER = SIMP(statut='f',typ=cham_mater),
        COMPORTEMENT  =C_COMPORTEMENT('CALC_EUROPLEXUS'),

        EXCIT      = FACT(statut='o',max='**',
           CHARGE         = SIMP(statut='o',typ=(char_meca,)),
           FONC_MULT      = SIMP(statut='f',typ=(fonction_sdaster,)),
          ),

        CALCUL = FACT(statut='o',max=1,
           TYPE_DISCRETISATION  = SIMP(statut='o',typ='TXM',defaut='AUTO',into=('AUTO','UTIL')),
           INST_FIN             = SIMP(statut='o',typ='R'),
           INST_INIT            = SIMP(statut='o',typ='R'),
           NMAX                 = SIMP(statut='f',typ='R'),

           b_auto =BLOC( condition = "TYPE_DISCRETISATION=='AUTO'",
              CSTAB  = SIMP(statut='o',typ='R',defaut=0.3),
#              DTMAX  = SIMP(statut='f',typ='R'),
                       ),

           b_util =BLOC( condition = "TYPE_DISCRETISATION=='UTIL'",
              PASFIX   = SIMP(statut='o',typ='R'),
                       ),
           ),

        AMORTISSEMENT = FACT(statut='f',max=1,
                TYPE_AMOR  = SIMP(statut='f',typ='TXM',defaut='QUASI_STATIQUE',into=('QUASI_STATIQUE', )),
                FREQUENCE  = SIMP(statut='o',typ='R'),
                COEF_AMOR  = SIMP(statut='o',typ='R'),
           ),

        OBSERVATION     =FACT(statut='f',max=1,
                            regles=( UN_PARMI('PAS_NBRE','PAS_INST',),
                                     AU_MOINS_UN('GROUP_NO','TOUT_GROUP_NO','GROUP_MA','TOUT_GROUP_MA',),
                                        EXCLUS('GROUP_NO','TOUT_GROUP_NO',),
                                        EXCLUS('GROUP_MA','TOUT_GROUP_MA',), ),
           NOM_CHAM        = SIMP(statut='f',typ='TXM',validators=NoRepeat(),min=1, max='**',defaut=('DEPL',),into=('DEPL'
                                         ,'VITE','ACCE','SIEF_ELGA','EPSI_ELGA','VARI_ELGA'),),
           PAS_INST        = SIMP(statut='f',typ='R'),
           PAS_NBRE        = SIMP(statut='f',typ='I'),
           GROUP_NO        = SIMP(statut='f',typ=grno,validators=NoRepeat(),max='**'),
           GROUP_MA        = SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
           TOUT_GROUP_NO   = SIMP(statut='f',typ='TXM',into=('OUI',),),
           TOUT_GROUP_MA   = SIMP(statut='f',typ='TXM',into=('OUI',),),
        ),


        ARCHIVAGE        =FACT(statut='o', regles=( UN_PARMI('PAS_NBRE','PAS_INST',),),
           PAS_INST     = SIMP(statut='f',typ='R'),
           PAS_NBRE     = SIMP(statut='f',typ='I'),
                             ),
        COURBE  =  FACT(statut='f',max='**', regles=(EXCLUS('GROUP_NO','GROUP_MA')),
            NOM_CHAM   = SIMP(statut='f',typ='TXM', into=('DEPL','VITE','ACCE','SIEF_ELGA','EPSI_ELGA','VARI_ELGA')),
            NOM_CMP    = SIMP(statut='f',typ='TXM'),
#             NOEUD      = SIMP(statut='f',typ='TXM',validators=NoRepeat(),max='**'),
#             MAILLE     = SIMP(statut='f',typ='TXM',validators=NoRepeat(),max='**'),
            GROUP_NO   = SIMP(statut='f',typ=grno,validators=NoRepeat(),max=1),
            GROUP_MA   = SIMP(statut='f',typ=grma,validators=NoRepeat(),max=1),

            b_maille = BLOC(condition = "GROUP_MA != None", regles=(AU_MOINS_UN('NUM_GAUSS')),
              NUM_GAUSS = SIMP(statut='f',typ='I',validators=NoRepeat(),max='**'),),
         ),
        b_courbe = BLOC(condition = "COURBE != None",
                        regles=(AU_MOINS_UN('PAS_NBRE_COURBE','PAS_INST_COURBE',),
                                AU_MOINS_UN('TABLE_COURBE',)),
          PAS_INST_COURBE      = SIMP(statut='f',typ='R'),
          PAS_NBRE_COURBE       = SIMP(statut='f',typ='I'),
                  TABLE_COURBE      = SIMP(statut='f', typ=CO),
          ),
        DOMAINES = FACT(statut='f',max='**',
             GROUP_MA = SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
             IDENTIFIANT =  SIMP(statut='f',typ='I'),),
        INTERFACES = FACT(statut='f',max='**',
             GROUP_MA_1 = SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
             GROUP_MA_2 = SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
             TOLE        =  SIMP(statut='f',typ='R'),
             IDENT_DOMAINE_1  = SIMP(statut='f',typ='I'),
             IDENT_DOMAINE_2  = SIMP(statut='f',typ='I'),),

         INFO            =SIMP(statut='f',typ='I',defaut=1,into=( 1, 2 ) ),
        ) ;
