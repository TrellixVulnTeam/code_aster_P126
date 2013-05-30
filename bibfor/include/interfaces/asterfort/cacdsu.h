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
    subroutine cacdsu(maxfa, maxdim, alpha, ndim, nno,&
                      nface, geom, vol, mface, dface,&
                      xface, normfa, kdiag, yss, c,&
                      d)
        integer :: nno
        integer :: ndim
        integer :: maxdim
        integer :: maxfa
        real(kind=8) :: alpha
        integer :: nface
        real(kind=8) :: geom(ndim, nno)
        real(kind=8) :: vol
        real(kind=8) :: mface(maxfa)
        real(kind=8) :: dface(maxfa)
        real(kind=8) :: xface(maxdim, maxfa)
        real(kind=8) :: normfa(maxdim, maxfa)
        real(kind=8) :: kdiag(6)
        real(kind=8) :: yss(maxdim, maxfa, maxfa)
        real(kind=8) :: c(maxfa, maxfa)
        real(kind=8) :: d(maxfa, maxfa)
    end subroutine cacdsu
end interface
