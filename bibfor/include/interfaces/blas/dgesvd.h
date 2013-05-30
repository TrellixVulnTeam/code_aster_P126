!
! COPYRIGHT (C) 1991 - 2013  EDF R&D                WWW.CODE-ASTER.ORG
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
    subroutine dgesvd(jobu, jobvt, m, n, a,&
                      lda, s, u, ldu, vt,&
                      ldvt, work, lwork, info)
        integer :: ldvt
        integer :: ldu
        integer :: lda
        character(len=1) :: jobu
        character(len=1) :: jobvt
        integer :: m
        integer :: n
        real(kind=8) :: a(lda, *)
        real(kind=8) :: s(*)
        real(kind=8) :: u(ldu, *)
        real(kind=8) :: vt(ldvt, *)
        real(kind=8) :: work(*)
        integer :: lwork
        integer :: info
    end subroutine dgesvd
end interface
