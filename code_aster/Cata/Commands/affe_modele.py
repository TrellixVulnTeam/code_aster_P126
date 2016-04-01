# coding=utf-8

from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *

# ======================================================================
# COPYRIGHT (C) 1991 - 2016  EDF R&D                  WWW.CODE-ASTER.ORG
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
AFFE_MODELE=OPER(nom="AFFE_MODELE",op=18,sd_prod=modele_sdaster,
            UIinfo={"groupes":("Modélisation",)},
                 fr=tr("Définir le phénomène physique modélisé et le type d'éléments finis sur le maillage"),reentrant='n',
         regles=(AU_MOINS_UN('AFFE','AFFE_SOUS_STRUC'),),
         MAILLAGE        =SIMP(statut='o',typ=maillage_sdaster),
         INFO            =SIMP(statut='f',typ='I',defaut=1,into=(1,2) ),
#
#====
# Définition des grandeurs caractéristiques
#====
#
         GRANDEUR_CARA =FACT(statut='f',max=1,
         fr=tr("Grandeurs caractéristiques pour l'adimensionnement des indicateurs d'erreur HM"),

#
            LONGUEUR      =SIMP(statut='f',typ='R',val_min=0,
                                fr =tr("Longueur caractéristique"),
                                ),
            PRESSION      =SIMP(statut='f',typ='R',val_min=0,
                                fr =tr("Pression caractéristique"),
                                ),
            TEMPERATURE   =SIMP(statut='f',typ='R',val_min=0,
                                fr =tr("Température caractéristique"),
                                ),),
#
         AFFE_SOUS_STRUC =FACT(statut='f',
           regles=(UN_PARMI('TOUT','SUPER_MAILLE'),),
           TOUT            =SIMP(statut='f',typ='TXM',into=("OUI",) ),
           SUPER_MAILLE    =SIMP(statut='f',typ=ma,validators=NoRepeat(),max='**'),
           PHENOMENE       =SIMP(statut='f',typ='TXM',defaut="MECANIQUE",into=("MECANIQUE",) ),
         ),
         AFFE            =FACT(statut='f',max='**',
           regles=(UN_PARMI('TOUT','GROUP_MA','MAILLE',)),
           TOUT            =SIMP(statut='f',typ='TXM',into=("OUI",) ),
           GROUP_MA        =SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
           MAILLE          =SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
           PHENOMENE       =SIMP(statut='o',typ='TXM',
                                 into=("MECANIQUE","THERMIQUE","ACOUSTIQUE") ),
                b_mecanique     =BLOC( condition = "PHENOMENE=='MECANIQUE'",
                                        fr=tr("modélisations mécaniques"),
                    MODELISATION    =SIMP(statut='o',typ='TXM',validators=NoRepeat(),max=10,into=(
                                  "2D_DIS_T",        # RESP. : FLEJOU J.L.FLEJOU
                                  "2D_DIS_TR",       # RESP. : FLEJOU J.L.FLEJOU
                                  "2D_FLUI_ABSO",    # RESP. : DEVESA G.DEVESA
                                  "2D_FLUI_PESA",    # RESP. : GREFFET N.GREFFET
                                  "2D_FLUI_STRU",    # RESP. : GREFFET N.GREFFET
                                  "2D_FLUIDE",       # RESP. : GREFFET N.GREFFET
                                  "3D",              # RESP. : DESROCHES X.DESROCHES
                                  "3D_ABSO",         # RESP. : DEVESA G.DEVESA
                                  "3D_FAISCEAU",     # RESP. : VOLDOIRE F.VOLDOIRE
                                  "3D_FLUI_ABSO",    # RESP. : DEVESA G.DEVESA
                                  "3D_FLUIDE",       # RESP. : GREFFET N.GREFFET
                                  "3D_INCO_UPG",     # RESP. : SFAYOLLE S.FAYOLLE
                                  "3D_INCO_UPGB",    # RESP. : SFAYOLLE S.FAYOLLE
                                  "3D_INCO_UP",      # RESP. : SFAYOLLE S.FAYOLLE
                                  "3D_INCO_UPO",     # RESP. : SFAYOLLE S.FAYOLLE
                                  "3D_SI",           # RESP. : DESROCHES X.DESROCHES
                                  "3D_GRAD_EPSI",    # RESP. : MICHEL S.MICHEL
                                  "3D_GRAD_VARI",    # RESP. : MICHEL S.MICHEL
                                  "3D_GVNO",         # RESP. : BEAURAIN J.BEAURAIN
                                  "3D_JOINT",        # RESP. : LAVERNE J.LAVERNE
                                  "3D_JOINT_HYME",   # RESP. : LAVERNE J.LAVERNE
                                  "3D_INTERFACE",    # RESP. : LAVERNE J.LAVERNE
                                  "3D_INTERFACE_S",  # RESP. : LAVERNE J.LAVERNE
                                  "AXIS",            # RESP. : LEFEBVRE J.P.LEFEBVRE
                                  "AXIS_FLUI_STRU",  # RESP. : GREFFET N.GREFFET
                                  "AXIS_FLUIDE",     # RESP. : GREFFET N.GREFFET
                                  "AXIS_FOURIER",    # RESP. : DESROCHES X.DESROCHES
                                  "AXIS_INCO_UPG",   # RESP. : SFAYOLLE S.FAYOLLE
                                  "AXIS_INCO_UPGB",  # RESP. : SFAYOLLE S.FAYOLLE
                                  "AXIS_INCO_UP",    # RESP. : SFAYOLLE S.FAYOLLE
                                  "AXIS_INCO_UPO",   # RESP. : SFAYOLLE S.FAYOLLE
                                  "AXIS_SI",         # RESP. : DESROCHES X.DESROCHES
                                  "AXIS_GRAD_VARI",  # RESP. : MICHEL S.MICHEL
                                  "AXIS_GVNO",       # RESP. : BEAURAIN J.BEAURAIN
                                  "AXIS_JOINT",      # RESP. : LAVERNE J.LAVERNE
                                  "AXIS_INTERFACE",  # RESP. : LAVERNE J.LAVERNE
                                  "AXIS_INTERFACE_S",# RESP. : LAVERNE J.LAVERNE
                                  "AXIS_ELDI",       # RESP. : LAVERNE J.LAVERNE
                                  "BARRE",           # RESP. : FLEJOU J.L.FLEJOU
                                  "CABLE_GAINE",     # RESP. :
                                  "2D_BARRE",        # RESP. : FLEJOU J.L.FLEJOU
                                  "C_PLAN",          # RESP. : LEFEBVRE J.P.LEFEBVRE
                                  "C_PLAN_SI",       # RESP. : DESROCHES X.DESROCHES
                                  "C_PLAN_GRAD_EPSI",# RESP. : MICHEL S.MICHEL
                                  "CABLE",           # RESP. : FLEJOU J.L.FLEJOU
                                  "CABLE_POULIE",    # RESP. : None
                                  "COQUE_3D",        # RESP. : DESROCHES X.DESROCHES
                                  "COQUE_AXIS",      # RESP. : DESROCHES X.DESROCHES
                                  "D_PLAN",          # RESP. : LEFEBVRE J.P.LEFEBVRE
                                  "D_PLAN_GRAD_EPSI",# RESP. : MICHEL S.MICHEL
                                  "D_PLAN_GRAD_VARI",# RESP. : MICHEL S.MICHEL
                                  "D_PLAN_GVNO",     # RESP. : BEAURAIN J.BEAURAIN
                                  "D_PLAN_GRAD_SIGM",# RESP. : GRANET S.GRANET
                                  "PLAN_JOINT",      # RESP. : LAVERNE J.LAVERNE
                                  "PLAN_JOINT_HYME", # RESP. : LAVERNE J.LAVERNE
                                  "PLAN_INTERFACE",  # RESP. : LAVERNE J.LAVERNE
                                  "PLAN_INTERFACE_S",# RESP. : LAVERNE J.LAVERNE
                                  "PLAN_ELDI",       # RESP. : LAVERNE J.LAVERNE
                                  "D_PLAN_ABSO",     # RESP. : DEVESA G.DEVESA
                                  "D_PLAN_INCO_UPG", # RESP. : SFAYOLLE S.FAYOLLE
                                  "D_PLAN_INCO_UPGB",# RESP. : SFAYOLLE S.FAYOLLE
                                  "D_PLAN_INCO_UP",  # RESP. : SFAYOLLE S.FAYOLLE
                                  "D_PLAN_INCO_UPO", # RESP. : SFAYOLLE S.FAYOLLE
                                  "D_PLAN_SI",       # RESP. : DESROCHES X.DESROCHES
                                  "DIS_T",           # RESP. : FLEJOU J.L.FLEJOU
                                  "DIS_TR",          # RESP. : FLEJOU J.L.FLEJOU
                                  "DKT",             # RESP. : DESROCHES X.DESROCHES
                                  "DKTG",            # RESP. : MARKOVIC D.MARKOVIC
                                  "DST",             # RESP. : DESROCHES X.DESROCHES
                                  "FLUI_STRU",       # RESP. : GREFFET N.GREFFET
                                  "GRILLE_EXCENTRE", # RESP. : ROSPARS C.ROSPARS
                                  "GRILLE_MEMBRANE", # RESP. : ROSPARS C.ROSPARS
                                  "MEMBRANE",        # RESP. : ROSPARS C.ROSPARS
                                  "POU_D_E",         # RESP. : FLEJOU J.L.FLEJOU
                                  "POU_D_EM",        # RESP. : FLEJOU J.L.FLEJOU
                                  "POU_D_T",         # RESP. : FLEJOU J.L.FLEJOU
                                  "POU_D_T_GD",      # RESP. : FLEJOU J.L.FLEJOU
                                  "POU_D_TG",        # RESP. : FLEJOU J.L.FLEJOU
                                  "POU_D_TGM",       # RESP. : FLEJOU J.L.FLEJOU
                                  "Q4G",             # RESP. : DESROCHES X.DESROCHES
                                  "Q4GG",            # RESP. : DESROCHES X.DESROCHES
                                  "TUYAU_3M",        # RESP. : PROIX J.M.PROIX
                                  "TUYAU_6M",        # RESP. : PROIX J.M.PROIX
                                  "SHB",             # RESP. : DESROCHES X.DESROCHES
                                  "D_PLAN_HHM",      # RESP. : GRANET S.GRANET
                                  "D_PLAN_HH2M_SI",   # RESP. : GRANET S.GRANET
                                  "D_PLAN_HM",       # RESP. : GRANET S.GRANET
                                  "D_PLAN_HM_SI",    # RESP. : GRANET S.GRANET
                                  "D_PLAN_THM",      # RESP. : GRANET S.GRANET
                                  "D_PLAN_HHMD",     # RESP. : GRANET S.GRANET
                                  "D_PLAN_HH2MD",    # RESP. : GRANET S.GRANET
                                  "D_PLAN_HMD",      # RESP. : GRANET S.GRANET
                                  "D_PLAN_THHD",     # RESP. : GRANET S.GRANET
                                  "D_PLAN_THH2D",    # RESP. : GRANET S.GRANET
                                  "D_PLAN_THVD",     # RESP. : GRANET S.GRANET
                                  "D_PLAN_THH2MD",   # RESP. : GRANET S.GRANET
                                  "D_PLAN_THHMD",    # RESP. : GRANET S.GRANET
                                  "D_PLAN_THMD",     # RESP. : GRANET S.GRANET
                                  "D_PLAN_HHMS",     # RESP. : GRANET S.GRANET
                                  "D_PLAN_HH2MS",    # RESP. : GRANET S.GRANET
                                  "D_PLAN_HMS",      # RESP. : GRANET S.GRANET
                                  "D_PLAN_THHS",     # RESP. : GRANET S.GRANET
                                  "D_PLAN_THH2S",    # RESP. : GRANET S.GRANET
                                  "D_PLAN_THVS",     # RESP. : GRANET S.GRANET
                                  "D_PLAN_THH2MS",   # RESP. : GRANET S.GRANET
                                  "D_PLAN_THHMS",    # RESP. : GRANET S.GRANET
                                  "D_PLAN_THMS",     # RESP. : GRANET S.GRANET
                                  "D_PLAN_HM_P",     # RESP. : GRANET S.GRANET
                                  "D_PLAN_HS",       # RESP. : GRANET S.GRANET
                                  "D_PLAN_HHD",      # RESP. : GRANET S.GRANET
                                  "D_PLAN_HHS",      # RESP. : GRANET S.GRANET
                                  "D_PLAN_HH2D",     # RESP. : GRANET S.GRANET
                                  "D_PLAN_HH2S",     # RESP. : GRANET S.GRANET
                                  "D_PLAN_2DG",      # RESP. : GRANET S.GRANET
                                  "D_PLAN_DIL",      # RESP. : GRANET S.GRANET
                                  "3D_DIL",          # RESP. : GRANET S.GRANET
                                  "AXIS_THM",        # RESP. : GRANET S.GRANET
                                  "AXIS_HHM",        # RESP. : GRANET S.GRANET
                                  "AXIS_HM",         # RESP. : GRANET S.GRANET
                                  "AXIS_HH2MD",      # RESP. : GRANET S.GRANET
                                  "AXIS_HHMD",       # RESP. : GRANET S.GRANET
                                  "AXIS_HMD",        # RESP. : GRANET S.GRANET
                                  "AXIS_THHD",       # RESP. : GRANET S.GRANET
                                  "AXIS_THH2D",      # RESP. : GRANET S.GRANET
                                  "AXIS_THVD",       # RESP. : GRANET S.GRANET
                                  "AXIS_THHMD",      # RESP. : GRANET S.GRANET
                                  "AXIS_THH2MD",     # RESP. : GRANET S.GRANET
                                  "AXIS_THMD",       # RESP. : GRANET S.GRANET
                                  "AXIS_HH2MS",      # RESP. : GRANET S.GRANET
                                  "AXIS_HHMS",       # RESP. : GRANET S.GRANET
                                  "AXIS_HMS",        # RESP. : GRANET S.GRANET
                                  "AXIS_THHS",       # RESP. : GRANET S.GRANET
                                  "AXIS_THH2S",      # RESP. : GRANET S.GRANET
                                  "AXIS_THVS",       # RESP. : GRANET S.GRANET
                                  "AXIS_THHMS",      # RESP. : GRANET S.GRANET
                                  "AXIS_THH2MS",     # RESP. : GRANET S.GRANET
                                  "AXIS_THMS",       # RESP. : GRANET S.GRANET
                                  "AXIS_HHD",        # RESP. : GRANET S.GRANET
                                  "AXIS_HHS",        # RESP. : GRANET S.GRANET
                                  "AXIS_HH2D",       # RESP. : GRANET S.GRANET
                                  "AXIS_HH2S",       # RESP. : GRANET S.GRANET
                                  "3D_HHM" ,         # RESP. : GRANET S.GRANET
                                  "3D_HH2M_SI" ,      # RESP. : GRANET S.GRANET
                                  "3D_HM",           # RESP. : GRANET S.GRANET
                                  "3D_HM_SI",        # RESP. : GRANET S.GRANET
                                  "3D_THHM",         # RESP. : GRANET S.GRANET
                                  "3D_THM",          # RESP. : GRANET S.GRANET
                                  "3D_HHMD",         # RESP. : GRANET S.GRANET
                                  "3D_HMD",          # RESP. : GRANET S.GRANET
                                  "3D_THHD",         # RESP. : GRANET S.GRANET
                                  "3D_THVD",         # RESP. : GRANET S.GRANET
                                  "3D_THHMD",        # RESP. : GRANET S.GRANET
                                  "3D_THMD",         # RESP. : GRANET S.GRANET
                                  "3D_HHMS",         # RESP. : GRANET S.GRANET
                                  "3D_HMS",          # RESP. : GRANET S.GRANET
                                  "3D_THHS",         # RESP. : GRANET S.GRANET
                                  "3D_THVS",         # RESP. : GRANET S.GRANET
                                  "3D_THHMS",        # RESP. : GRANET S.GRANET
                                  "3D_THMS",         # RESP. : GRANET S.GRANET
                                  "3D_THH2MD",       # RESP. : GRANET S.GRANET
                                  "3D_THH2MS",       # RESP. : GRANET S.GRANET
                                  "3D_HH2MD",        # RESP. : GRANET S.GRANET
                                  "3D_HH2MS",        # RESP. : GRANET S.GRANET
                                  "3D_THH2S",        # RESP. : GRANET S.GRANET
                                  "3D_THH2D",        # RESP. : GRANET S.GRANET
                                  "3D_HS",           # RESP. : GRANET S.GRANET
                                  "3D_HHD",          # RESP. : GRANET S.GRANET
                                  "3D_HHS",          # RESP. : GRANET S.GRANET
                                  "3D_HH2D",         # RESP. : GRANET S.GRANET
                                  "3D_HH2S",         # RESP. : GRANET S.GRANET
                                  "3D_HH2SUDA",      # RESP. : GRANET S.GRANET
                                  "D_PLAN_HH2SUDA",  # RESP. : GRANET S.GRANET
                                  "PLAN_JHMS",
                                  "AXIS_JHMS",
                                                                      )  )  ),

                b_thermique     =BLOC( condition = "PHENOMENE=='THERMIQUE'",
                                        fr=tr("modélisations thermiques"),
                    MODELISATION    =SIMP(statut='o',typ='TXM',validators=NoRepeat(),max=10,into=(
                                  "3D",              # RESP. : DURAND C.DURAND
                                  "3D_DIAG",         # RESP. : DURAND C.DURAND
                                  "AXIS",            # RESP. : DURAND C.DURAND
                                  "AXIS_DIAG",       # RESP. : DURAND C.DURAND
                                  "AXIS_FOURIER",    # RESP. : DESROCHES X.DESROCHES
                                  "COQUE",           # RESP. : DESROCHES X.DESROCHES
                                  "COQUE_AXIS",      # RESP. : DESROCHES X.DESROCHES
                                  "COQUE_PLAN",      # RESP. : DESROCHES X.DESROCHES
                                  "PLAN",            # RESP. : DURAND C.DURAND
                                  "PLAN_DIAG",       # RESP. : DURAND C.DURAND
                                                                      ),),),

                b_acoustique    =BLOC( condition = "PHENOMENE=='ACOUSTIQUE'",
                                        fr=tr("modélisations acoustiques"),
                     MODELISATION    =SIMP(statut='o',typ='TXM',validators=NoRepeat(),max=10,into=(
                                  "3D",              # RESP. : None
                                  "PLAN"             # RESP. : None
                                                                       ), ),),

         ),

         PARTITION         =FACT(statut='d',
             PARALLELISME    =SIMP(statut='f',typ='TXM',defaut="GROUP_ELEM",
                                   into=("MAIL_CONTIGU","MAIL_DISPERSE","CENTRALISE","GROUP_ELEM")),
             b_dist_maille          =BLOC(condition = "PARALLELISME in ('MAIL_DISPERSE','MAIL_CONTIGU')",
                 CHARGE_PROC0_MA =SIMP(statut='f',typ='I',defaut=100,val_min=0,val_max=100),
             ),
             b_dist_grel         =BLOC(condition = "PARALLELISME == 'GROUP_ELEM'",
                 PARTITION       =SIMP(statut='f',typ=sd_partit),
             ),
         ),

         VERI_JACOBIEN  =SIMP(statut='f',typ='TXM',into=('OUI','NON'),defaut='OUI',
                              fr =tr("Vérification de la forme des mailles (jacobiens tous de meme signe)."),),
) ;
