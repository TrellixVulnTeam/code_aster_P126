# coding=utf-8

from Cata.Descriptor import *
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
# person_in_charge: samuel.geniaut at edf.fr


MACR_ASPIC_MAIL=MACRO(nom="MACR_ASPIC_MAIL",
                      op=OPS('Macro.macr_aspic_mail_ops.macr_aspic_mail_ops'),
                      sd_prod=maillage_sdaster,
                      reentrant='n',
                      fr=tr("Engendre le maillage d'un piquage sain ou avec fissure (longue ou courte)"),
                      UIinfo={"groupes":("Maillage","Outils-métier",)},

         EXEC_MAILLAGE   =FACT(statut='o',
           LOGICIEL        =SIMP(statut='o',typ='TXM',defaut="GIBI2000",into=("GIBI98","GIBI2000")),
           UNITE_DATG      =SIMP(statut='f',typ='I',defaut=70),
           UNITE_MGIB      =SIMP(statut='f',typ='I',defaut=19),
           NIVE_GIBI       =SIMP(statut='f',typ='I',defaut=10,into=(3,4,5,6,7,8,9,10,11)),
         ),

         TYPE_ELEM       =SIMP(statut='f',typ='TXM',defaut="CU20",into=("CU20","CUB8")),

         RAFF_MAIL       =SIMP(statut='f',typ='TXM',defaut="GROS",into=("GROS","FIN")),

         TUBULURE        =FACT(statut='o',
           E_BASE          =SIMP(statut='o',typ='R'),
           DEXT_BASE       =SIMP(statut='o',typ='R'),
           L_BASE          =SIMP(statut='o',typ='R'),
           L_CHANF         =SIMP(statut='o',typ='R'),
           E_TUBU          =SIMP(statut='o',typ='R'),
           DEXT_TUBU       =SIMP(statut='o',typ='R'),
           Z_MAX           =SIMP(statut='o',typ='R'),
           TYPE            =SIMP(statut='o',typ='TXM',into=("TYPE_1","TYPE_2")),
           L_PENETR        =SIMP(statut='f',typ='R',defaut= 0.0E+0),
         ),

         SOUDURE         =FACT(statut='o',
           H_SOUD          =SIMP(statut='o',typ='R'),
           ANGL_SOUD       =SIMP(statut='o',typ='R'),
           JEU_SOUD        =SIMP(statut='o',typ='R'),
         ),

         CORPS           =FACT(statut='o',
           E_CORP          =SIMP(statut='o',typ='R'),
           DEXT_CORP       =SIMP(statut='o',typ='R'),
           X_MAX           =SIMP(statut='o',typ='R'),
         ),

         FISS_SOUDURE    =FACT(statut='f',
           TYPE            =SIMP(statut='o',typ='TXM',into=("LONGUE","COURTE")),
           AXIS            =SIMP(statut='f',typ='TXM',defaut="NON",into=("OUI","NON")),
           PROFONDEUR      =SIMP(statut='o',typ='R'),
           LONGUEUR        =SIMP(statut='f',typ='R'),
           AZIMUT          =SIMP(statut='o',typ='R'),
           RAYON_TORE      =SIMP(statut='f',typ='R'),
           POSITION        =SIMP(statut='o',typ='TXM',into=("DROIT","INCLINE")),
           FISSURE         =SIMP(statut='o',typ='TXM',into=("DEB_INT","DEB_EXT","NON_DEB","TRAVERS")),
           LIGA_INT        =SIMP(statut='f',typ='R'),
           ANGL_OUVERTURE  =SIMP(statut='f',typ='R',defaut= 0.0E+0),
           COEF_MULT_RC1   =SIMP(statut='f',typ='R'),
           COEF_MULT_RC2   =SIMP(statut='f',typ='R'),
           COEF_MULT_RC3   =SIMP(statut='f',typ='R'),
           NB_TRANCHE      =SIMP(statut='f',typ='I'),
           NB_SECTEUR      =SIMP(statut='f',typ='I'),
           NB_COURONNE     =SIMP(statut='f',typ='I'),
         ),

         IMPRESSION      =FACT(statut='f',max='**',
           regles=(PRESENT_PRESENT('FICHIER','UNITE'),),
           FORMAT          =SIMP(statut='f',typ='TXM',defaut="ASTER",into=("ASTER","IDEAS","CASTEM")),

           b_format_ideas  =BLOC(condition="FORMAT=='IDEAS'",fr=tr("version Ideas"),
             VERSION         =SIMP(statut='f',typ='I',defaut=5,into=(4,5)),
           ),

           b_format_castem =BLOC(condition="FORMAT=='CASTEM'",fr=tr("version Castem"),
             NIVE_GIBI       =SIMP(statut='f',typ='I',defaut=10,into=(3,10)),
           ),
           FICHIER         =SIMP(statut='f',typ='TXM'),
           UNITE           =SIMP(statut='f',typ='I'),
         ),

         INFO            =SIMP(statut='f',typ='I',defaut=1,into=(1,2)),
)  ;
