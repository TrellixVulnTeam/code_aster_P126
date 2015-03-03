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
# person_in_charge: sebastien.fayolle at edf.fr
DEFI_GLRC=OPER(nom="DEFI_GLRC",op=57,sd_prod=mater_sdaster,reentrant='f',
               UIinfo={"groupes":("Modélisation",)},
               fr=tr("Déterminer les caractéristiques homogenéisées du béton armé à partir des propriétés du béton et des  "
                     " armatures"),
               reuse = SIMP(statut='f',typ=mater_sdaster),
               RELATION = SIMP(statut='o',typ='TXM',defaut="GLRC_DAMAGE",
                          into=("GLRC_DM","GLRC_DAMAGE"),),
               ALPHA = SIMP(statut='f',typ='R',val_min=0.E+0,fr="Coef. dilatation thermique",),
               INFO = SIMP(statut='f',typ='I',defaut=1,into=(1,2),),

               b_glrc_dm=BLOC(condition = "RELATION == 'GLRC_DM'",
                              fr=tr("Paramètres de la loi GLRC_DM"),
                              BETON = FACT(statut='o',max=1,
                                MATER = SIMP(statut='o',typ=(mater_sdaster),),
                                EPAIS = SIMP(statut='o',typ='R',val_min=0.E+0 ),),
                              NAPPE = FACT(statut='o',max=1,
                                MATER = SIMP(statut='o',typ=(mater_sdaster),),
                                OMY   = SIMP(statut='o',typ='R',val_min=0.E+0,),
                                OMX   = SIMP(statut='o',typ='R',val_min=0.E+0,),
                                RY    = SIMP(statut='o',typ='R',val_min=-1.0E+0,val_max=1.0E+0,),
                                RX    = SIMP(statut='o',typ='R',val_min=-1.0E+0,val_max=1.0E+0),),
                              RHO = SIMP(statut='f',typ='R',val_min=0.E+0,),
                              AMOR_ALPHA = SIMP(statut='f',typ='R',val_min=0.E+0,),
                              AMOR_BETA = SIMP(statut='f',typ='R',val_min=0.E+0,),
                              AMOR_HYST = SIMP(statut='f',typ='R',val_min=0.E+0,),
                              COMPR = SIMP(statut='o',typ='TXM',defaut="GAMMA",
                                           into=("GAMMA","SEUIL")),
                   b_gamma=BLOC(condition = "COMPR == 'GAMMA'",
                                fr=tr("Paramètre d'endommagement en compression "),
                                GAMMA_C = SIMP(statut='o',typ='R',defaut=1.0E+0,val_min=0.0E+0, val_max=1.0E+0),),
                   b_seuil=BLOC(condition = "COMPR == 'SEUIL'",
                                fr=tr("Seuil d'endommagement en compression "),
                                NYC = SIMP(statut='o',typ='R'),),
                   PENTE = SIMP(statut='o',typ='TXM',defaut="RIGI_ACIER",
                                into=("PLAS_ACIER","UTIL","RIGI_ACIER")),
                   b_util = BLOC(condition = "PENTE == 'UTIL'",
                                 fr=tr("Valeur de la déformation maximale de l'élément"),
                                  EPSI_MEMB = SIMP(statut='o',typ='R',defaut=0.E+0),
                                  KAPPA_FLEX = SIMP(statut='o',typ='R',defaut=0.E+0),),
                   CISAIL = SIMP(statut='o',typ='TXM',defaut="NON",
                                 into=("OUI","NON"),),
                   METHODE_ENDO = SIMP(statut='o',typ='TXM',defaut="ENDO_INTER",
                                  into=("ENDO_NAISS","ENDO_LIM","ENDO_INTER"),),
                           ),
           b_glrc_damage=BLOC(condition = "RELATION == 'GLRC_DAMAGE'",
                            fr=tr("Paramètres de la loi GLRC_DAMAGE"),
                   CISAIL_NL          =FACT(statut='f',max=1,
                     BTD1            =SIMP(statut='o',typ='R'),
                     BTD2            =SIMP(statut='o',typ='R'),
                     TSD             =SIMP(statut='o',typ='R'),
                                         ),
                   BETON            =FACT(statut='o',max=1,
                   regles=(ENSEMBLE('MP1X', 'MP1Y', 'MP2X', 'MP2Y'),
                           ENSEMBLE('MP1X_FO', 'MP1Y_FO', 'MP2X_FO', 'MP2Y_FO'),
                           PRESENT_ABSENT('MP1X', 'MP1X_FO', 'MP1Y_FO', 'MP2X_FO', 'MP2Y_FO'),
                           ENSEMBLE('OMT', 'EAT'),
                           ENSEMBLE('BT1','BT2'),),
                     MATER           =SIMP(statut='o',typ=(mater_sdaster) ),
                     EPAIS           =SIMP(statut='o',typ='R',val_min=0.E+0 ),
                     GAMMA           =SIMP(statut='o',typ='R',val_min=0.E+0,val_max=1.E+0),
                     QP1             =SIMP(statut='o',typ='R',val_min=0.E+0,val_max=1.E+0),
                     QP2             =SIMP(statut='o',typ='R',val_min=0.E+0,val_max=1.E+0),

                     C1N1            =SIMP(statut='o',typ='R',val_min=0.E+0),
                     C1N2            =SIMP(statut='o',typ='R',val_min=0.E+0),
                     C1N3            =SIMP(statut='o',typ='R',val_min=0.E+0),
                     C2N1            =SIMP(statut='o',typ='R',val_min=0.E+0),
                     C2N2            =SIMP(statut='o',typ='R',val_min=0.E+0),
                     C2N3            =SIMP(statut='o',typ='R',val_min=0.E+0),
                     C1M1            =SIMP(statut='o',typ='R',val_min=0.E+0),
                     C1M2            =SIMP(statut='o',typ='R',val_min=0.E+0),
                     C1M3            =SIMP(statut='o',typ='R',val_min=0.E+0),
                     C2M1            =SIMP(statut='o',typ='R',val_min=0.E+0),
                     C2M2            =SIMP(statut='o',typ='R',val_min=0.E+0),
                     C2M3            =SIMP(statut='o',typ='R',val_min=0.E+0),

                     OMT             =SIMP(statut='f',typ='R',val_min=0.E+0),
                     EAT             =SIMP(statut='f',typ='R',val_min=0.E+0),
                     BT1             =SIMP(statut='f',typ='R',val_min=0.E+0),
                     BT2             =SIMP(statut='f',typ='R',val_min=0.E+0),

                     MP1X            =SIMP(statut='f',typ='R'),
                     MP2X            =SIMP(statut='f',typ='R'),
                     MP1Y            =SIMP(statut='f',typ='R'),
                     MP2Y            =SIMP(statut='f',typ='R'),

                     MP1X_FO         =SIMP(statut='f',typ=fonction_sdaster),
                     MP2X_FO         =SIMP(statut='f',typ=fonction_sdaster),
                     MP1Y_FO         =SIMP(statut='f',typ=fonction_sdaster),
                     MP2Y_FO         =SIMP(statut='f',typ=fonction_sdaster),
         ),
                   NAPPE     =FACT(statut='o',max=10,
                     MATER           =SIMP(statut='o',typ=(mater_sdaster) ),
                     OMX             =SIMP(statut='o',typ='R',val_min=0.E+0),
                     OMY             =SIMP(statut='o',typ='R',val_min=0.E+0),
                     RX              =SIMP(statut='o',typ='R',val_min=-1.E+0,val_max=1.E+0),
                     RY              =SIMP(statut='o',typ='R',val_min=-1.E+0,val_max=1.E+0),
         ),
                   CABLE_PREC   =FACT(statut='f',max=1,
                     MATER           =SIMP(statut='o',typ=(mater_sdaster) ),
                     OMX             =SIMP(statut='o',typ='R',val_min=0.E+0),
                     OMY             =SIMP(statut='o',typ='R',val_min=0.E+0),
                     RX              =SIMP(statut='o',typ='R',val_min=-1.E+0,val_max=1.E+0),
                     RY              =SIMP(statut='o',typ='R',val_min=-1.E+0,val_max=1.E+0),
                     PREX            =SIMP(statut='o',typ='R'),
                     PREY            =SIMP(statut='o',typ='R'),
         ),
                   LINER           =FACT(statut='f',max=10,
                     MATER           =SIMP(statut='o',typ=(mater_sdaster) ),
                     OML             =SIMP(statut='o',typ='R',val_min=0.E+0),
                     RLR             =SIMP(statut='o',typ='R',val_min=-1.E+0,val_max=1.E+0),
         ),
         ),
)  ;
