# coding=utf-8
# --------------------------------------------------------------------
# Copyright (C) 1991 - 2020 - EDF R&D - www.code-aster.org
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

# person_in_charge: jean-luc.flejou at edf.fr

from .cata_comportement import LoiComportement

loi = LoiComportement(
    nom            = 'DIS_ECRO_TRAC',
    lc_type        = ('MECANIQUE',),
    doc            =   """Relation de comportement isotrope pour les éléments discrets"""              ,
    num_lc         = 0,
    nb_vari        = 17,
    nom_vari       = ('FORCEX', 'FORCEY', 'FORCEZ', 'DEPLX',  'DEPLY',  'DEPLZ',  'DISSTHER',
                      'PCUM',   'DEPLPX', 'DEPLPY', 'DEPLPZ', 'FORCXX', 'FORCXY', 'FORCXZ',
                      'RAIDEX', 'RAIDEY', 'RAIDEZ',),
    mc_mater       = None,
    modelisation   = ('DIS_T','DIS_TR','2D_DIS_T','2D_DIS_TR',),
    deformation    = ('PETIT','PETIT_REAC','GROT_GDEP',),
    algo_inte      = ('SPECIFIQUE',),
    type_matr_tang = None,
    proprietes     = None,
    syme_matr_tang = ('Yes',),
    exte_vari      = None,
    deform_ldc     = ('OLD',),
    regu_visc      = ('No',),
)
