# coding=utf-8

from Cata.Descriptor import *

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
#


IMPR_DIAG_CAMPBELL=MACRO(nom="IMPR_DIAG_CAMPBELL",
                         op=OPS('Macro.impr_diag_campbell_ops.impr_diag_campbell_ops'),
                         fr=tr("Tracé du Diagramme de Campbell"),
                         UIinfo={"groupes":("Impression","Outils-métier",)},
            MAILLAGE        =SIMP(statut='o',typ=maillage_sdaster),
            MODES           =SIMP(statut='o',typ=table_container),
            NFREQ_CAMP      =SIMP(statut='o',typ='I' ),
            TYP_PREC        =SIMP(statut='f',typ='I',defaut= 1, into=(1,2) ),
            TYP_TRI         =SIMP(statut='f',typ='I',defaut= 2, into=(0,1,2) ),
            UNIT_FLE        =SIMP(statut='o',typ='I' ,val_min=1),
            UNIT_TOR        =SIMP(statut='o',typ='I' ,val_min=1),
            UNIT_LON        =SIMP(statut='o',typ='I' ,val_min=1),
            UNIT_TOT        =SIMP(statut='o',typ='I' ,val_min=1),
            UNIT_INT        =SIMP(statut='o',typ='I' ,val_min=1),
            L_S             =SIMP(statut='f',typ='R', defaut= 1., max='**'),
);
