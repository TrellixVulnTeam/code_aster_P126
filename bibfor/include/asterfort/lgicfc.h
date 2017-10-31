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
    subroutine lgicfc(ndim, nno1, nno2, npg, nddl, axi,grand,&
                      geoi, ddlm, vff1, vff2, idfde1,idfde2, &
                      iw,sigmag,fint)
        integer :: ndim
        integer :: nno1        
        integer :: nno2
        integer :: npg      
        integer :: nddl
        aster_logical :: axi
        aster_logical :: grand
        real(kind=8) :: geoi(ndim*nno1)
        real(kind=8) :: ddlm(nddl)
        real(kind=8) :: vff1(nno1,npg)
        real(kind=8) :: vff2(nno2,npg)
        integer :: idfde1        
        integer :: idfde2
        integer :: iw       
        real(kind=8) :: sigmag(3*ndim+2,npg)
        real(kind=8) :: fint(nddl)
    end subroutine lgicfc
end interface
