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
    subroutine recuma(mailla, nbma, nbgr, nomma, nomgr,&
                      nbto, numnot)
        integer :: nbto
        integer :: nbgr
        integer :: nbma
        character(len=8) :: mailla
        character(len=8) :: nomma(nbma)
        character(len=24) :: nomgr(nbgr)
        integer :: numnot(nbto)
    end subroutine recuma
end interface
