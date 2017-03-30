!
! COPYRIGHT (C) 1991 - 2017  EDF R&D                WWW.CODE-ASTER.ORG
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
    subroutine lcumfp(fami, kpg, ksp, ndim, typmod,&
                      imate, compor, tinstm, tinstp, epsm,&
                      deps, sigm, vim, option, rela_plas,&
                      sigp, vip, dsidep)
        integer, intent(in) :: ndim
        integer, intent(in) :: imate
        integer, intent(in) :: kpg
        integer, intent(in) :: ksp
        character(len=8), intent(in) :: typmod(*)
        character(len=16), intent(in) :: compor(*)
        character(len=16), intent(in) :: rela_plas
        character(len=16), intent(in) :: option
        character(len=*), intent(in) :: fami
        real(kind=8) :: tinstm, tinstp
        real(kind=8) :: epsm(*), deps(*), sigm(*), sigp(*), vim(*), vip(*)
        real(kind=8) :: dsidep(6, 6), tbid(36)
    end subroutine lcumfp
end interface
