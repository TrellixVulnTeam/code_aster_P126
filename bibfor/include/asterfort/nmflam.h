! --------------------------------------------------------------------
! Copyright (C) 1991 - 2017 - EDF R&D - www.code-aster.org
! This file is part of code_aster.
!
! code_aster is free software: you can redistribute it and/or modify
! it under the terms of the GNU General Public License as published by
! the Free Software Foundation, either version 3 of the License, or
! (at your option) any later version.
!
! code_aster is distributed in the hope that it will be useful,
! but WITHOUT ANY WARRANTY; without even the implied warranty of
! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
! GNU General Public License for more details.
!
! You should have received a copy of the GNU General Public License
! along with code_aster.  If not, see <http://www.gnu.org/licenses/>.
! --------------------------------------------------------------------
! aslint: disable=W1504
!
interface
    subroutine nmflam(option         ,&
                      model          , mate         , cara_elem , list_load  , list_func_acti,&
                      nume_dof       , nume_dof_inva,&
                      ds_constitutive, varc_refe    ,&
                      sddisc         , nume_inst    ,& 
                      sddyna         , sderro       , ds_contact, ds_algopara,& 
                      ds_measure     ,&
                      hval_incr      , hval_algo    ,&
                      hval_meelem    , hval_measse  ,&
                      hval_veelem    ,&
                      ds_posttimestep)
        use NonLin_Datastructure_type
        character(len=16), intent(in) :: option
        character(len=24), intent(in) :: model, mate, cara_elem
        character(len=19), intent(in) :: list_load
        integer, intent(in) :: list_func_acti(*)
        character(len=24), intent(in) :: nume_dof, nume_dof_inva
        character(len=24), intent(in) :: varc_refe
        type(NL_DS_Constitutive), intent(in) :: ds_constitutive
        character(len=19), intent(in) :: sddisc
        integer, intent(in) :: nume_inst
        character(len=19), intent(in) :: sddyna
        character(len=24), intent(in) :: sderro
        type(NL_DS_Contact), intent(in) :: ds_contact
        type(NL_DS_AlgoPara), intent(in) :: ds_algopara
        type(NL_DS_Measure), intent(inout) :: ds_measure
        character(len=19), intent(in) :: hval_incr(*), hval_algo(*)
        character(len=19), intent(in) :: hval_veelem(*), hval_meelem(*), hval_measse(*)
        type(NL_DS_PostTimeStep), intent(inout) :: ds_posttimestep
    end subroutine nmflam
end interface
