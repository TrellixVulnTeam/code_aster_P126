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
    subroutine crirup(fami, imat, ndim, npg, lgpg,&
                      option, compor, sigp, vip, vim,&
                      instam, instap)
        integer :: lgpg
        integer :: npg
        integer :: ndim
        character(len=*) :: fami
        integer :: imat
        character(len=16) :: option
        character(len=16) :: compor(*)
        real(kind=8) :: sigp(2*ndim, npg)
        real(kind=8) :: vip(lgpg, npg)
        real(kind=8) :: vim(lgpg, npg)
        real(kind=8) :: instam
        real(kind=8) :: instap
    end subroutine crirup
end interface
