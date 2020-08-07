! --------------------------------------------------------------------
! Copyright (C) 1991 - 2020 - EDF R&D - www.code-aster.org
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
!
interface
    subroutine lc6076(fami, kpg, ksp, ndim, imate,&
                    compor, carcri, instam, instap, neps, &
                    epsm, deps, nsig, sigm, nvi, &
                    vim, option, angmas, sigp, vip, &
                    typmod, icomp, ndsde, dsidep, codret)
        character(len=*) :: fami
        integer :: kpg
        integer :: ksp
        integer :: ndim
        integer :: imate
        character(len=16) :: compor(*)
        real(kind=8) :: carcri(*)
        real(kind=8) :: instam
        real(kind=8) :: instap
        integer :: neps
        real(kind=8) :: epsm(neps)
        real(kind=8) :: deps(neps)
        integer :: nsig
        real(kind=8) :: sigm(nsig)
        integer :: nvi
        real(kind=8) :: vim(nvi)
        character(len=16) :: option
        real(kind=8) :: angmas(*)
        real(kind=8) :: sigp(nsig)
        real(kind=8) :: vip(nvi)
        character(len=8) :: typmod(*)
        integer :: icomp
        integer :: ndsde
        real(kind=8) :: dsidep(nsig,neps)
        integer :: codret
    end subroutine lc6076
end interface
