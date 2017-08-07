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
interface
    subroutine majpad(p2, pvp, r, temp, kh,&
                      dp2, pvpm, dt, padp, padm,&
                      dpad)
        real(kind=8) :: p2
        real(kind=8) :: pvp
        real(kind=8) :: r
        real(kind=8), intent(in) :: temp
        real(kind=8) :: kh
        real(kind=8) :: dp2
        real(kind=8) :: pvpm
        real(kind=8) :: dt
        real(kind=8) :: padp
        real(kind=8) :: padm
        real(kind=8) :: dpad
    end subroutine majpad
end interface
