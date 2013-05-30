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
    subroutine irmare(ifc, ndim, nno, coordo, nbma,&
                      connex, point, noma, typma, typel,&
                      lmod, titre, nbtitr, nbgrn, nbgrm,&
                      nomai, nonoe, formar)
        integer :: ifc
        integer :: ndim
        integer :: nno
        real(kind=8) :: coordo(*)
        integer :: nbma
        integer :: connex(*)
        integer :: point(*)
        character(len=8) :: noma
        integer :: typma(*)
        integer :: typel(*)
        logical :: lmod
        character(len=80) :: titre(*)
        integer :: nbtitr
        integer :: nbgrn
        integer :: nbgrm
        character(len=8) :: nomai(*)
        character(len=8) :: nonoe(*)
        character(len=16) :: formar
    end subroutine irmare
end interface
