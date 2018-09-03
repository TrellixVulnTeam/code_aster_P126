! --------------------------------------------------------------------
! Copyright (C) 1991 - 2018 - EDF R&D - www.code-aster.org
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
#include "asterf_types.h"
!
interface
    subroutine mmnsta(ndim, leltf, lpenaf, loptf, djeut,&
                      dlagrf, coefaf,  tau1, tau2,&
                      lcont, ladhe, lambda, rese, nrese)
        integer :: ndim
        aster_logical :: leltf
        aster_logical :: lpenaf
        aster_logical :: loptf
        real(kind=8) :: djeut(3)
        real(kind=8) :: dlagrf(2)
        real(kind=8) :: coefaf
        real(kind=8) :: tau1(3)
        real(kind=8) :: tau2(3)
        aster_logical :: lcont
        aster_logical :: ladhe
        real(kind=8) :: lambda
        real(kind=8) :: rese(3)
        real(kind=8) :: nrese
    end subroutine mmnsta
end interface
