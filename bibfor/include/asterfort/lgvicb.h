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

interface
    subroutine lgvicb(ndim, nno1, nno2, npg, g,axi,r,&
                      bst, vff2, dfdi2, nddl, b)
        integer :: ndim
        integer :: nno1        
        integer :: nno2
        integer :: npg
        integer :: g        
        aster_logical :: axi
        real(kind=8) :: r   
        real(kind=8) :: bst(6,nno1*ndim)
        real(kind=8) :: vff2(nno2)
        real(kind=8) :: dfdi2(nno2*ndim)
        integer :: nddl
        real(kind=8) :: b(3*ndim+4,nddl) 
    end subroutine lgvicb
end interface
