# coding=utf-8
# person_in_charge: xavier.desroches at edf.fr


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

from cataelem.Tools.base_objects import InputParameter, OutputParameter, Option, CondCalcul
import cataelem.Commons.physical_quantities as PHY
import cataelem.Commons.parameters as SP
import cataelem.Commons.attributes as AT


PPINTTO = InputParameter(phys=PHY.N132_R)


PCNSETO = InputParameter(phys=PHY.N1280I, container='MODL!.TOPOSE.CNS',
                         comment="""  XFEM - CONNECTIVITE DES SOUS-ELEMENTS  """)


PHEAVTO = InputParameter(phys=PHY.N512_I)


PHEA_NO = InputParameter(phys=PHY.N120_I)


PLONCHA = InputParameter(phys=PHY.N120_I, container='MODL!.TOPOSE.LON',
                         comment="""  XFEM - NBRE DE TETRAEDRES ET DE SOUS-ELEMENTS  """)


PLSN = InputParameter(phys=PHY.NEUT_R)


PLST = InputParameter(phys=PHY.NEUT_R)


PSTANO = InputParameter(phys=PHY.N120_I)


PPMILTO = InputParameter(phys=PHY.N792_R)

PBASLOR  = InputParameter(phys=PHY.NEUT_R)

CHAR_MECA_FR3D3D = Option(
    para_in=(
        PCNSETO,
        SP.PFR3D3D,
        SP.PGEOMER,
        PHEAVTO,
        PHEA_NO,
        PLONCHA,
        PLSN,
        PLST,
        PPINTTO,
        PPMILTO,
        PSTANO,
        PBASLOR,
        SP.PMATERC,
    ),
    para_out=(
        SP.PVECTUR,
    ),
    condition=(
# L'attribut INTERFACE='OUI' designe les elements "ecrases".
# Ils n'ont pas de "volume" et ne peuvent pas calculer ce chargement.
# La modelisation 3D_DIL ('D3D') se "superpose" a une autre modelisation.
# Ce n'est pas a elle de calculer les chargements repartis :
        CondCalcul(
            '+', ((AT.PHENO, 'ME'), (AT.BORD, '0'), (AT.DIM_TOPO_MODELI, '3'),)),
        CondCalcul('-', ((AT.PHENO, 'ME'), (AT.INTERFACE, 'OUI'),)),
        CondCalcul('-', ((AT.PHENO, 'ME'), (AT.MODELI, 'D3D'),)),
    ),
    comment=""" CHAR_MECA_FR3D3D (MOT-CLE : FORCE_INTERNE): CALCUL DU SECOND
           MEMBRE ELEMENTAIRE CORRESPONDANT A DES FORCES INTERNES APPLIQUEES
           A UN DOMAINE 3D""",
)
