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

from cata_comportement import LoiComportement

loi = LoiComportement(
    nom            = 'ELAS_VMIS_PUIS',
    doc            =   """Elasticité non linéaire de Von Mises - Hencky à écrouissage isotrope défini
par une courbe de traction analytique (loi en puissance)"""      ,
    num_lc         = 0,
    nb_vari        = 2,
    nom_vari       = ('EPSPEQ','INDIPLAS',),
    mc_mater       = ('ELAS','ECRO_PUIS',),
    modelisation   = ('3D','AXIS','D_PLAN',),
    deformation    = ('PETIT','GROT_GDEP',),
    algo_inte      = ('SECANTE',),
    type_matr_tang = None,
    proprietes     = ('COMP_ELAS',),
    syme_matr_tang = ('Yes',),
)
