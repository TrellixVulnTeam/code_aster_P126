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
    subroutine merxth(model    , lload_name, lload_info, cara_elem, mate     ,&
                      time_curr, time      , temp_iter , compor   , varc_curr,&
                      dry_prev , dry_curr  , matr_elem)
        character(len=24), intent(in) :: model
        character(len=24), intent(in) :: lload_name
        character(len=24), intent(in) :: lload_info
        real(kind=8), intent(in) :: time_curr
        character(len=24), intent(in) :: time
        character(len=24), intent(in) :: mate
        character(len=24), intent(in) :: cara_elem
        character(len=24), intent(in) :: temp_iter
        character(len=24), intent(in) :: dry_prev   
        character(len=24), intent(in) :: dry_curr
        character(len=24), intent(in) :: compor
        character(len=19), intent(in) :: varc_curr
        character(len=24), intent(inout) :: matr_elem
    end subroutine merxth
end interface
