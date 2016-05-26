/**
 * @file AllowedBehaviour.cxx
 * @brief Initialise les noms et possibles pour les comportements
 * @author Natacha Béreux
 * @section LICENCE
 *   Copyright (C) 1991 - 2016  EDF R&D                www.code-aster.org
 *
 *   This file is part of Code_Aster.
 *
 *   Code_Aster is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 2 of the License, or
 *   (at your option) any later version.
 *
 *   Code_Aster is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with Code_Aster.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "AllowedBehaviour.h"


const char* ConstitutiveLawNames[nbLaw] = {
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
                                        "MFRONT",};
const char* DeformationNames[nbDeformation] = {"PETIT","PETIT_REAC","GROT_GDEP","SIMO_MIEHE","GDEF_LOG"};

const char* TangentMatrixNames[nbTangMatr] = {"PERTURBATION","VERIFICATION","TANGENTE_SECANTE" }; 
