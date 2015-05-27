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
    subroutine lceobg(ndim, typmod, imate, crit, epstm,&
                      depst, vim, option, sigp, vip,&
                      dsidep, proj, iret)
        integer :: ndim
        character(len=8) :: typmod(*)
        integer :: imate
        real(kind=8) :: crit(*)
        real(kind=8) :: epstm(12)
        real(kind=8) :: depst(12)
        real(kind=8) :: vim(7)
        character(len=16) :: option
        real(kind=8) :: sigp(6)
        real(kind=8) :: vip(7)
        real(kind=8) :: dsidep(6, 6, 2)
        real(kind=8) :: proj(6, 6)
        integer :: iret
    end subroutine lceobg
end interface
