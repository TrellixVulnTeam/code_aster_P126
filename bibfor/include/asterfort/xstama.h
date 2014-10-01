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
    subroutine xstama(noma, nbma, nmafis, jmafis,&
                      ncouch, lisnoe, stano, cnslt, cnsln,&
                      jmafon, jmaen1, jmaen2, jmaen3, nmafon,&
                      nmaen1, nmaen2, nmaen3)
        character(len=8) :: noma
        integer :: nbma
        integer :: nmafis
        integer :: jmafis
        integer :: ncouch
        character(len=24) :: lisnoe
        integer :: stano(*)
        character(len=19) :: cnslt
        character(len=19) :: cnsln
        integer :: jmafon
        integer :: jmaen1
        integer :: jmaen2
        integer :: jmaen3
        integer :: nmafon
        integer :: nmaen1
        integer :: nmaen2
        integer :: nmaen3
    end subroutine xstama
end interface
