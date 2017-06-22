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
    subroutine brdefv(e1i, e2i, a, t, b,&
                      k0, k1, eta1, k2, eta2,&
                      pw, e0f, e1f, e2f, e2pc,&
                      e2pt, sige2)
        real(kind=8) :: e1i
        real(kind=8) :: e2i
        real(kind=8) :: a
        real(kind=8) :: t
        real(kind=8) :: b
        real(kind=8) :: k0
        real(kind=8) :: k1
        real(kind=8) :: eta1
        real(kind=8) :: k2
        real(kind=8) :: eta2
        real(kind=8) :: pw
        real(kind=8) :: e0f
        real(kind=8) :: e1f
        real(kind=8) :: e2f
        real(kind=8) :: e2pc
        real(kind=8) :: e2pt
        real(kind=8) :: sige2
    end subroutine brdefv
end interface
