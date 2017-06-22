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
    subroutine mmvalp_scal(nb_dim   , elem_type, elem_nbno, ksi1, ksi2,&
                           vale_node, vale_poin)
        integer, intent(in) :: nb_dim
        character(len=8), intent(in) :: elem_type
        integer, intent(in) :: elem_nbno
        real(kind=8), intent(in) :: ksi1
        real(kind=8), intent(in) :: ksi2
        real(kind=8), intent(in) :: vale_node(*)
        real(kind=8), intent(out) :: vale_poin
    end subroutine mmvalp_scal
end interface
