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
    subroutine ptmtuf(m, rho, e, rof, ce,&
                      a, ai, xl, xiy, xiz,&
                      g, alfay, alfaz, ey, ez)
        real(kind=8) :: m(*)
        real(kind=8) :: rho
        real(kind=8) :: e
        real(kind=8) :: rof
        real(kind=8) :: ce
        real(kind=8) :: a
        real(kind=8) :: ai
        real(kind=8) :: xl
        real(kind=8) :: xiy
        real(kind=8) :: xiz
        real(kind=8) :: g
        real(kind=8) :: alfay
        real(kind=8) :: alfaz
        real(kind=8) :: ey
        real(kind=8) :: ez
    end subroutine ptmtuf
end interface
