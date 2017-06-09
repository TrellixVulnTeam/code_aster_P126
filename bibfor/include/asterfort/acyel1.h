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
#include "asterf_types.h"
!
interface
    subroutine acyel1(nmcolz, nomobz, nobl, nobc, okpart,&
                      lilig, nblig, licol, nbcol, cmat,&
                      ndim, ideb, jdeb, x)
        integer :: ndim
        integer :: nbcol
        integer :: nblig
        character(len=*) :: nmcolz
        character(len=*) :: nomobz
        integer :: nobl
        integer :: nobc
        aster_logical :: okpart
        integer :: lilig(nblig)
        integer :: licol(nbcol)
        complex(kind=8) :: cmat(ndim, ndim)
        integer :: ideb
        integer :: jdeb
        real(kind=8) :: x
    end subroutine acyel1
end interface
