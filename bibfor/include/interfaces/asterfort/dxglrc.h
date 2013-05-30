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
    subroutine dxglrc(nomte, opt, compor, xyzl, ul,&
                      dul, btsig, ktan, pgl, crit,&
                      codret)
        character(len=16) :: nomte
        character(len=16) :: opt
        character(len=16) :: compor(*)
        real(kind=8) :: xyzl(3, 4)
        real(kind=8) :: ul(6, 4)
        real(kind=8) :: dul(6, 4)
        real(kind=8) :: btsig(6, 4)
        real(kind=8) :: ktan(300)
        real(kind=8) :: pgl(3, 3)
        real(kind=8) :: crit(*)
        integer :: codret
    end subroutine dxglrc
end interface
