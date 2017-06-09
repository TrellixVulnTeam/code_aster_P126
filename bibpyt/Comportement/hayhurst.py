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
    nom            = 'HAYHURST',
    doc            =   """Modele viscoplastique couple a l'endommagement isotrope de Kachanov."""      ,
    num_lc         = 32,
    nb_vari        = 12,
    nom_vari       = ('EPSPXX','EPSPYY','EPSPZZ','EPSPXY','EPSPXZ',
        'EPSPYZ','EPSPEQ','H1','H2','PHI',
        'ENDO','VIDE',),
    mc_mater       = ('ELAS','HAYHURST',),
    modelisation   = ('3D','AXIS','D_PLAN',),
    deformation    = ('PETIT','PETIT_REAC','GDEF_LOG',),
    algo_inte      = ('NEWTON','RUNGE_KUTTA','NEWTON_PERT',),
    type_matr_tang = ('PERTURBATION','VERIFICATION',),
    proprietes     = None,
    syme_matr_tang = ('Yes',),
)
