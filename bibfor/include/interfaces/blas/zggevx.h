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
    subroutine zggevx(balanc, jobvl, jobvr, sense, n,&
                      a, lda, b, ldb, alpha,&
                      beta, vl, ldvl, vr, ldvr,&
                      ilo, ihi, lscale, rscale, abnrm,&
                      bbnrm, rconde, rcondv, work, lwork,&
                      rwork, iwork, bwork, info)
        integer :: ldvr
        integer :: ldvl
        integer :: ldb
        integer :: lda
        character(len=1) :: balanc
        character(len=1) :: jobvl
        character(len=1) :: jobvr
        character(len=1) :: sense
        integer :: n
        complex(kind=8) :: a(lda, *)
        complex(kind=8) :: b(ldb, *)
        complex(kind=8) :: alpha(*)
        complex(kind=8) :: beta(*)
        complex(kind=8) :: vl(ldvl, *)
        complex(kind=8) :: vr(ldvr, *)
        integer :: ilo
        integer :: ihi
        real(kind=8) :: lscale(*)
        real(kind=8) :: rscale(*)
        real(kind=8) :: abnrm
        real(kind=8) :: bbnrm
        real(kind=8) :: rconde(*)
        real(kind=8) :: rcondv(*)
        complex(kind=8) :: work(*)
        integer :: lwork
        real(kind=8) :: rwork(*)
        integer :: iwork(*)
        logical :: bwork(*)
        integer :: info
    end subroutine zggevx
end interface
