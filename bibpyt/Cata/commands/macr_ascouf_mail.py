# coding=utf-8

from Cata.Descriptor import *

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

MACR_ASCOUF_MAIL=MACRO(nom="MACR_ASCOUF_MAIL",
                       op=OPS('Macro.macr_ascouf_mail_ops.macr_ascouf_mail_ops'),
                       sd_prod=maillage_sdaster,
                       fr=tr("Engendre le maillage d'un coude sain ou comportant une fissure ou une (ou plusieurs) sous-épaisseur(s)"),
                       UIinfo={"groupes":("Maillage","Outils-métier",)},
                       reentrant='n',

         regles=(EXCLUS('SOUS_EPAIS_COUDE','FISS_COUDE','SOUS_EPAIS_MULTI'),),

         EXEC_MAILLAGE   =FACT(statut='o',
           LOGICIEL        =SIMP(statut='o',typ='TXM',defaut="GIBI2000",into=("GIBI98","GIBI2000") ),
           UNITE_DATG      =SIMP(statut='f',typ='I',defaut=70),
           UNITE_MGIB      =SIMP(statut='f',typ='I',defaut=19),
           NIVE_GIBI       =SIMP(statut='f',typ='I',defaut=10,into=(3,4,5,6,7,8,9,10,11)),
         ),

         TYPE_ELEM       =SIMP(statut='f',typ='TXM',defaut="CU20",into=("CU20","CUB8") ),

         COUDE           =FACT(statut='o',
           ANGLE           =SIMP(statut='o',typ='R' ),
           R_CINTR         =SIMP(statut='o',typ='R' ),
           L_TUBE_P1       =SIMP(statut='o',typ='R' ),
           L_TUBE_P2       =SIMP(statut='f',typ='R',defaut= 0.E+0 ),
           NB_ELEM_EPAIS   =SIMP(statut='f',typ='I',defaut= 3 ),
           SYME            =SIMP(statut='f',typ='TXM',defaut="ENTIER",into=("ENTIER","QUART","DEMI") ),
           TRANSFORMEE     =SIMP(statut='o',typ='TXM',defaut="COUDE",into=("COUDE","TUBE") ),
           b_transf_coude  =BLOC(condition = "TRANSFORMEE == 'COUDE' ",
              DEXT            =SIMP(statut='o',typ='R' ),
              EPAIS           =SIMP(statut='o',typ='R' ),
              SUR_EPAIS       =SIMP(statut='f',typ='R',defaut= 0.E+0 ),
              BOL_P2          =SIMP(statut='f',typ='TXM',into=("ASP_MPP","CUVE") ),
           ),
           b_transf_tube   =BLOC(condition = "TRANSFORMEE == 'TUBE' ",
              TRAN_EPAIS      =SIMP(statut='o',typ='TXM',defaut="NON",into=("OUI","NON") ),
              b_trans_epais_oui    =BLOC(condition = "TRAN_EPAIS == 'OUI' ",
                      regles=(ENSEMBLE('ANGL_TETA2','EPAIS_TI'),
                              UN_PARMI('ABSC_CURV_TRAN','POSI_ANGU_TRAN'),),
                      DEXT_T1         =SIMP(statut='o',typ='R' ),
                      EPAIS_T1        =SIMP(statut='o',typ='R' ),
                      EPAIS_T2        =SIMP(statut='o',typ='R' ),
                      EPAIS_TI        =SIMP(statut='f',typ='R' ),
                      ANGL_TETA1      =SIMP(statut='o',typ='R' ),
                      ANGL_TETA2      =SIMP(statut='f',typ='R' ),
                      ABSC_CURV_TRAN  =SIMP(statut='f',typ='R' ),
                      POSI_ANGU_TRAN  =SIMP(statut='f',typ='R' ),
              ),
              b_trans_epais_non    =BLOC(condition = "TRAN_EPAIS == 'NON' ",
                      DEXT            =SIMP(statut='o',typ='R' ),
                      EPAIS           =SIMP(statut='o',typ='R' ),
                      SUR_EPAIS       =SIMP(statut='f',typ='R',defaut= 0.E+0 ),
                      BOL_P2          =SIMP(statut='f',typ='TXM',into=("ASP_MPP","CUVE") ),
              ),
           ),
         ),

         SOUS_EPAIS_COUDE=FACT(statut='f',
           regles=(UN_PARMI('POSI_CURV_LONGI','POSI_ANGUL'),
                   UN_PARMI('POSI_CURV_CIRC','AZIMUT'),),
           TYPE            =SIMP(statut='o',typ='TXM',into=("AXIS","ELLI") ),
           AXE_CIRC        =SIMP(statut='f',typ='R' ),
           AXE_LONGI       =SIMP(statut='o',typ='R' ),
           PROFONDEUR      =SIMP(statut='o',typ='R' ),
           POSI_CURV_LONGI =SIMP(statut='f',typ='R' ),
           POSI_ANGUL      =SIMP(statut='f',typ='R' ),
           POSI_CURV_CIRC  =SIMP(statut='f',typ='R' ),
           AZIMUT          =SIMP(statut='f',typ='R' ),
           SOUS_EPAIS      =SIMP(statut='o',typ='TXM',into=("INTERNE","EXTERNE") ),
           NB_ELEM_LONGI   =SIMP(statut='o',typ='I' ),
           NB_ELEM_CIRC    =SIMP(statut='o',typ='I' ),
           NB_ELEM_RADI    =SIMP(statut='f',typ='I',defaut= 3 ),
           EMPREINTE       =SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON") ),
         ),

         SOUS_EPAIS_MULTI=FACT(statut='f',max='**',
           regles=(UN_PARMI('POSI_CURV_LONGI','POSI_ANGUL'),
                   UN_PARMI('POSI_CURV_CIRC','AZIMUT'),),
           TYPE            =SIMP(statut='o',typ='TXM',into=("AXIS","ELLI") ),
           AXE_CIRC        =SIMP(statut='f',typ='R' ),
           AXE_LONGI       =SIMP(statut='o',typ='R' ),
           PROFONDEUR      =SIMP(statut='o',typ='R' ),
           POSI_CURV_LONGI =SIMP(statut='f',typ='R' ),
           POSI_ANGUL      =SIMP(statut='f',typ='R' ),
           POSI_CURV_CIRC  =SIMP(statut='f',typ='R' ),
           AZIMUT          =SIMP(statut='f',typ='R' ),
           SOUS_EPAIS      =SIMP(statut='o',typ='TXM',into=("INTERNE","EXTERNE") ),
           NB_ELEM_LONGI   =SIMP(statut='o',typ='I' ),
           NB_ELEM_CIRC    =SIMP(statut='o',typ='I' ),
           EMPREINTE       =SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON") ),
         ),

         FISS_COUDE      =FACT(statut='f',
           regles=(UN_PARMI('ABSC_CURV','POSI_ANGUL'),),
           AXIS            =SIMP(statut='f',typ='TXM',into=("OUI","NON"),defaut="NON" ),
           b_axis_non    =BLOC(condition = "AXIS == 'NON' ",
                   LONGUEUR        =SIMP(statut='o',typ='R' ),
           ),
           b_axis_oui    =BLOC(condition = "AXIS == 'OUI' ",
                   LONGUEUR        =SIMP(statut='f',typ='R' ),
           ),
           PROFONDEUR      =SIMP(statut='o',typ='R' ),
           ABSC_CURV       =SIMP(statut='f',typ='R' ),
           POSI_ANGUL      =SIMP(statut='f',typ='R' ),
           FISSURE         =SIMP(statut='o',typ='TXM',into=("DEB_INT","DEB_EXT") ),
           AZIMUT          =SIMP(statut='f',typ='R',defaut= 90. ),
           ORIEN           =SIMP(statut='o',typ='R',
                                 into=(45.,-45.,90.,0.E+0) ),
           NB_TRANCHE      =SIMP(statut='o',typ='I' ),
           NB_SECTEUR      =SIMP(statut='o',typ='I' ),
           NB_COURONNE     =SIMP(statut='o',typ='I' ),
           RAYON_TORE      =SIMP(statut='f',typ='R' ),
           COEF_MULT_RC2   =SIMP(statut='f',typ='R',defaut= 1. ),
           COEF_MULT_RC3   =SIMP(statut='f',typ='R' ),
           ANGL_OUVERTURE  =SIMP(statut='f',typ='R',defaut= 0.5 ),
         ),

         IMPRESSION      =FACT(statut='f',max='**',
           regles=(PRESENT_PRESENT('FICHIER','UNITE'),),
           FORMAT          =SIMP(statut='f',typ='TXM',defaut="ASTER",
                                 into=("ASTER","IDEAS","CASTEM") ),
           b_format_ideas  =BLOC(condition="FORMAT=='IDEAS'",fr=tr("version Ideas"),
             VERSION         =SIMP(statut='f',typ='I',defaut=5,into=(4,5)),
           ),
           b_format_castem =BLOC(condition="FORMAT=='CASTEM'",fr=tr("version Castem"),
             NIVE_GIBI       =SIMP(statut='f',typ='I',defaut=10,into=(3,10)),
           ),
           FICHIER         =SIMP(statut='f',typ='TXM' ),
           UNITE           =SIMP(statut='f',typ='I' ),
         ),

         INFO            =SIMP(statut='f',typ='I',defaut= 1,into=(1,2) ),
)  ;
