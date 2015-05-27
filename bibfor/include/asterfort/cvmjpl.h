!
! COPYRIGHT (C) 1991 - 2015  EDF R&D                WWW.CODE-ASTER.ORG
!
! THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
! IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
! THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
! (AT YOUR OPTION) ANY LATER VERSION.
!
! THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
! WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
! MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
! GENERAL PUBLIC LICENSE FOR MORE DETAILS.
!
! YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
! ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
! 1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
!
interface
    subroutine cvmjpl(mod, nmat, mater, timed, timef,&
                      epsd, deps, sigf, vinf, sigd,&
                      vind, nvi, nr, dsde)
        common/tdim/ ndt,ndi
        integer :: ndt
        integer :: ndi
        integer :: nr
        integer :: nvi
        integer :: nmat
        character(len=8) :: mod
        real(kind=8) :: mater(nmat, 2)
        real(kind=8) :: timed
        real(kind=8) :: timef
        real(kind=8) :: epsd(*)
        real(kind=8) :: deps(*)
        real(kind=8) :: sigf(*)
        real(kind=8) :: vinf(*)
        real(kind=8) :: sigd(*)
        real(kind=8) :: vind(*)
        real(kind=8) :: dsde(6, 6)
    end subroutine cvmjpl
end interface
