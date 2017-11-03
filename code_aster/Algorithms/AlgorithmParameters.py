# coding=utf-8
# --------------------------------------------------------------------
# Copyright (C) 1991 - 2017 - EDF R&D - www.code-aster.org
# This file is part of code_aster.
#
# code_aster is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# code_aster is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with code_aster.  If not, see <http://www.gnu.org/licenses/>.
# --------------------------------------------------------------------

# person_in_charge: mathieu.courtois@edf.fr

"""
*Work in progress*: How to share ConstitutiveLaw enumeration between
C++ and Python?

.. todo::
    Building the ConstitutiveLaw enumeration from the 'catalc' object
    seems a good way.

    Currently, values are just copy from :file:`AllowedBehaviour.cxx`.
"""

from collections import namedtuple


class Data(object):
    allConstitutiveLaw = """
            Elas,
            Elas_Vmis_Line,
            Elas_Vmis_Trac,
            Elas_Vmis_Puis,
            Elas_Hyper,
            Elas_Poutre_Gr,
            Cable,
            Arme,
            Asse_Corn,
            Barcelone,
            Beton_Burger_Fp,
            Beton_Double_Dp,
            Beton_Rag,
            Beton_Regle_Pr,
            Beton_Umlv_Fp,
            Cable_Gaine_Frot,
            Cam_Clay,
            Cjs,
            Corr_Acier,
            Czm_Exp,
            Czm_Exp_Reg,
            Czm_Exp_Mix,
            Czm_Fat_Mix,
            Czm_Lin_Reg,
            Czm_Ouv_Mix,
            Czm_Tac_Mix,
            Czm_Lab_Mix,
            Czm_Tra_Mix,
            Dis_Bili_Elas,
            Dis_Choc,
            Dis_Ecro_Cine,
            Dis_Gouj2e_Elas,
            Dis_Gouj2e_Plas,
            Dis_Gricra,
            Dis_Visc,
            Druck_Prager,
            Druck_Prag_N_A,
            Elas_Gonf,
            Endo_Poro_Beton,
            Endo_Carre,
            Endo_Fiss_Exp,
            BrittleDamage,
            HeterogeneousDamage,
            ConcreteIsotropicDamage,
            ConcreteOrthotropicDamage,
            ScalarDamage,
            Flua_Poro_Beton,
            Glrc_Damage,
            Glrc_Dm,
            Dhrc,
            Granger_Fp,
            Granger_Fp_Indt,
            Granger_Fp_V,
            Gran_Irra_Log,
            Grille_Cine_Line,
            Grille_Isot_Line,
            Grille_Pinto_Men,
            Hayhurst,
            Hoek_Brown,
            Hoek_Brown_Eff,
            Hoek_Brown_Tot,
            Hujeux,
            Irrad3m,
            Joint_Ba,
            Joint_Bandis,
            Joint_Meca_Rupt,
            Joint_Meca_Frot,
            Kit_Cg,
            Kit_Ddi,
            Kit_Hh,
            Kit_H,
            Kit_Hhm,
            Kit_Hm,
            Kit_Thh,
            Kit_Thhm,
            Kit_Thm,
            Kit_Thv,
            Laigle,
            Lemaitre,
            Lemaitre_Irra,
            Lema_Seuil,
            Letk,
            Mazars,
            Mazars_Gc,
            Meta_Lema_Ani,
            Meta_P_Cl,
            Meta_P_Cl_Pt,
            Meta_P_Cl_Pt_Re,
            Meta_P_Cl_Re,
            Meta_P_Il,
            Meta_P_Il_Pt,
            Meta_P_Il_Pt_Re,
            Meta_P_Il_Re,
            Meta_P_Inl,
            Meta_P_Inl_Pt,
            Meta_P_Inl_Pt_Re,
            Meta_P_Inl_Re,
            Meta_V_Cl,
            Meta_V_Cl_Pt,
            Meta_V_Cl_Pt_Re,
            Meta_V_Cl_Re,
            Meta_V_Il,
            Meta_V_Il_Pt,
            Meta_V_Il_Pt_Re,
            Meta_V_Il_Re,
            Meta_V_Inl,
            Meta_V_Inl_Pt,
            Meta_V_Inl_Pt_Re,
            Meta_V_Inl_Re,
            Mohr_Coulomb,
            Monocristal,
            Multifibre,
            Norton,
            Norton_Hoff,
            Pinto_Menegotto,
            Polycristal,
            Rgi_Beton,
            Rousselier,
            Rouss_Pr,
            Rouss_Visc,
            Rupt_Frag,
            WithoutConstitutiveLaw,
            Vendochab,
            Visc_Endo_Lema,
            Viscochab,
            Visc_Cin1_Chab,
            Visc_Cin2_Chab,
            Visc_Cin2_Memo,
            Visc_Cin2_Nrad,
            Visc_Memo_Nrad,
            Visc_Druc_Prag,
            Visc_Irra_Log,
            Visc_Isot_Line,
            Visc_Isot_Trac,
            Visc_Taheri,
            Vmis_Asym_Line,
            Vmis_Cin1_Chab,
            Vmis_Cin2_Chab,
            Vmis_Cine_Gc,
            Vmis_Cin2_Memo,
            Vmis_Cin2_Nrad,
            Vmis_Memo_Nrad,
            Vmis_Cine_Line,
            Vmis_Ecmi_Line,
            Vmis_Ecmi_Trac,
            Vmis_Isot_Line,
            Vmis_Isot_Puis,
            Vmis_Isot_Trac,
            Vmis_John_Cook,
            Umat,
            Mfront
    """.replace(",", "").split()

    allConstitutiveLawNames = [
                                        "ELAS",
                                        "ELAS_VMIS_LINE",
                                        "ELAS_VMIS_TRAC",
                                        "ELAS_VMIS_PUIS",
                                        "ELAS_HYPER",
                                        "ELAS_POUTRE_GR",
                                        "CABLE",
                                        "ARME",
                                        "ASSE_CORN",
                                        "BARCELONE",
                                        "BETON_BURGER_FP",
                                        "BETON_DOUBLE_DP",
                                        "BETON_RAG",
                                        "BETON_REGLE_PR",
                                        "BETON_UMLV_FP",
                                        "CABLE_GAINE_FROT",
                                        "CAM_CLAY",
                                        "CJS",
                                        "CORR_ACIER",
                                        "CZM_EXP",
                                        "CZM_EXP_REG",
                                        "CZM_EXP_MIX",
                                        "CZM_FAT_MIX",
                                        "CZM_LIN_REG",
                                        "CZM_OUV_MIX",
                                        "CZM_TAC_MIX",
                                        "CZM_LAB_MIX",
                                        "CZM_TRA_MIX",
                                        "DIS_BILI_ELAS",
                                        "DIS_CHOC",
                                        "DIS_ECRO_CINE",
                                        "DIS_GOUJ2E_ELAS",
                                        "DIS_GOUJ2E_PLAS",
                                        "DIS_GRICRA",
                                        "DIS_VISC",
                                        "DRUCK_PRAGER",
                                        "DRUCK_PRAG_N_A",
                                        "ELAS_GONF",
                                        "ENDO_PORO_BETON",
                                        "ENDO_CARRE",
                                        "ENDO_FISS_EXP",
                                        "ENDO_FRAGILE",
                                        "ENDO_HETEROGENE",
                                        "ENDO_ISOT_BETON",
                                        "ENDO_ORTH_BETON",
                                        "ENDO_SCALAIRE",
                                        "FLUA_PORO_BETON",
                                        "GLRC_DAMAGE",
                                        "GLRC_DM",
                                        "DHRC",
                                        "GRANGER_FP",
                                        "GRANGER_FP_INDT",
                                        "GRANGER_FP_V",
                                        "GRAN_IRRA_LOG",
                                        "GRILLE_CINE_LINE",
                                        "GRILLE_ISOT_LINE",
                                        "GRILLE_PINTO_MEN",
                                        "HAYHURST",
                                        "HOEK_BROWN",
                                        "HOEK_BROWN_EFF",
                                        "HOEK_BROWN_TOT",
                                        "HUJEUX",
                                        "IRRAD3M",
                                        "JOINT_BA",
                                        "JOINT_BANDIS",
                                        "JOINT_MECA_RUPT",
                                        "JOINT_MECA_FROT",
                                        "KIT_CG",
                                        "KIT_DDI",
                                        "KIT_HH",
                                        "KIT_H",
                                        "KIT_HHM",
                                        "KIT_HM",
                                        "KIT_THH",
                                        "KIT_THHM",
                                        "KIT_THM",
                                        "KIT_THV",
                                        "LAIGLE",
                                        "LEMAITRE",
                                        "LEMAITRE_IRRA",
                                        "LEMA_SEUIL",
                                        "LETK",
                                        "MAZARS",
                                        "MAZARS_GC",
                                        "META_LEMA_ANI",
                                        "META_P_CL",
                                        "META_P_CL_PT",
                                        "META_P_CL_PT_RE",
                                        "META_P_CL_RE",
                                        "META_P_IL",
                                        "META_P_IL_PT",
                                        "META_P_IL_PT_RE",
                                        "META_P_IL_RE",
                                        "META_P_INL",
                                        "META_P_INL_PT",
                                        "META_P_INL_PT_RE",
                                        "META_P_INL_RE",
                                        "META_V_CL",
                                        "META_V_CL_PT",
                                        "META_V_CL_PT_RE",
                                        "META_V_CL_RE",
                                        "META_V_IL",
                                        "META_V_IL_PT",
                                        "META_V_IL_PT_RE",
                                        "META_V_IL_RE",
                                        "META_V_INL",
                                        "META_V_INL_PT",
                                        "META_V_INL_PT_RE",
                                        "META_V_INL_RE",
                                        "MOHR_COULOMB",
                                        "MONOCRISTAL",
                                        "MULTIFIBRE",
                                        "NORTON",
                                        "NORTON_HOFF",
                                        "PINTO_MENEGOTTO",
                                        "POLYCRISTAL",
                                        "RGI_BETON",
                                        "ROUSSELIER",
                                        "ROUSS_PR",
                                        "ROUSS_VISC",
                                        "RUPT_FRAG",
                                        "SANS",
                                        "VENDOCHAB",
                                        "VISC_ENDO_LEMA",
                                        "VISCOCHAB",
                                        "VISC_CIN1_CHAB",
                                        "VISC_CIN2_CHAB",
                                        "VISC_CIN2_MEMO",
                                        "VISC_CIN2_NRAD",
                                        "VISC_MEMO_NRAD",
                                        "VISC_DRUC_PRAG",
                                        "VISC_IRRA_LOG",
                                        "VISC_ISOT_LINE",
                                        "VISC_ISOT_TRAC",
                                        "VISC_TAHERI",
                                        "VMIS_ASYM_LINE",
                                        "VMIS_CIN1_CHAB",
                                        "VMIS_CIN2_CHAB",
                                        "VMIS_CINE_GC",
                                        "VMIS_CIN2_MEMO",
                                        "VMIS_CIN2_NRAD",
                                        "VMIS_MEMO_NRAD",
                                        "VMIS_CINE_LINE",
                                        "VMIS_ECMI_LINE",
                                        "VMIS_ECMI_TRAC",
                                        "VMIS_ISOT_LINE",
                                        "VMIS_ISOT_PUIS",
                                        "VMIS_ISOT_TRAC",
                                        "VMIS_JOHN_COOK",
                                        "UMAT",
                                        "MFRONT",
    ]
    size = len(allConstitutiveLaw)
    assert size == len(allConstitutiveLawNames), (
        "Sizes differ: {0} vs {1}".format(size,
                                          len(allConstitutiveLawNames)))

    # StrainType
    allStrainEnum = """SmallStrain, PetitReac, LargeStrainAndRotation,
        SimoMiehe, GdefLog""".replace(",", "").split()
    allStrainNames = "PETIT","PETIT_REAC","GROT_GDEP","SIMO_MIEHE","GDEF_LOG"
    size = len(allStrainEnum)
    assert size == len(allStrainNames), (
        "Sizes differ: {0} vs {1}".format(size, len(allStrainNames)))

    # TangentMatrixType
    allTangentMatrix = ["PerturbationMatrix", "VerificationMatrix",
                        "TangentSecantMatrix"]
    allTangentMatrixNames = "PERTURBATION","VERIFICATION","TANGENTE_SECANTE"
    size = len(allTangentMatrix)
    assert size == len(allTangentMatrixNames), (
        "Sizes differ: {0} vs {1}".format(size, len(allTangentMatrixNames)))

    # IntegrationAlgorithm
    allIntegrationAlgo = """AnalyticalAlgo, SecantAlgo, DekkerAlgo,
        Newton1DAlgo, BrentAlgo, NewtonAlgo, NewtonReliAlgo,
        NewtonLossAlgo, RungeKuttaAlgo, ParticularAlgo,
        NoAlgo""".replace(",", "").split()
    allIntegrationAlgoNames = ["ANALYTIQUE", "SECANTE", "DEKKER", "NEWTON_1D",
        "BRENT", "NEWTON", "NEWTON_RELI", "NEWTON_PERT", "RUNGE_KUTTA",
        "SPECIFIQUE", "SANS_OBJET"]
    size = len(allIntegrationAlgo)
    assert size == len(allIntegrationAlgoNames), (
        "Sizes differ: {0} vs {1}".format(size, len(allIntegrationAlgoNames)))


ConstitutiveLaw = namedtuple("ConstitutiveLaw", Data.allConstitutiveLaw)._make(
    range(len(Data.allConstitutiveLaw)))
ConstitutiveLawNames = dict(zip(ConstitutiveLaw, Data.allConstitutiveLawNames))

StrainType = namedtuple("StrainType", Data.allStrainEnum)._make(
    range(len(Data.allStrainEnum)))
StrainTypeNames = dict(zip(StrainType, Data.allStrainNames))

TangentMatrixType = namedtuple("TangentMatrixType", Data.allTangentMatrix)._make(
    range(len(Data.allTangentMatrix)))
TangentMatrixTypeNames = dict(zip(TangentMatrixType, Data.allTangentMatrixNames))

IntegrationAlgorithm = namedtuple("IntegrationAlgorithm",
                                  Data.allIntegrationAlgo)._make(
                           range(len(Data.allIntegrationAlgo)))
IntegrationAlgorithmNames = dict(zip(IntegrationAlgorithm,
                                     Data.allIntegrationAlgoNames))

del Data
