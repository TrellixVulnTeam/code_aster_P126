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

!
!
interface
    subroutine mm_cycl_d1_ss(pres_near, laug_cont_prev, laug_cont_curr, zone_cont_prev, &
                             zone_cont_curr, cycl_sub_type, alpha_cont_matr,alpha_cont_vect)
        real(kind=8), intent(in) :: pres_near
        real(kind=8), intent(in) :: laug_cont_prev, laug_cont_curr
        real(kind=8), intent(out) :: alpha_cont_vect
        real(kind=8), intent(out) :: alpha_cont_matr
        integer, intent(out) :: cycl_sub_type
        integer, intent(out) :: zone_cont_prev, zone_cont_curr
    end subroutine mm_cycl_d1_ss
end interface
