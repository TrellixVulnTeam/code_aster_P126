!
! COPYRIGHT (C) 1991 - 2016  EDF R&D                WWW.CODE-ASTER.ORG
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

#include "asterf_types.h"

interface
    subroutine srfsxi(nmat, materf, i1, devsig, dshds,&
                      plas, xi, para, vara, tmp, dfdsdx,&
                      dpardx)
        integer :: nmat
        real(kind=8) :: materf(nmat, 2)
        real(kind=8) :: i1
        real(kind=8) :: devsig(6)
        real(kind=8) :: dshds(6)
        aster_logical :: plas
        real(kind=8) :: xi
        real(kind=8) :: para(3)
        real(kind=8) :: vara(4)
        real(kind=8) :: tmp
        real(kind=8) :: dfdsdx(6)
        real(kind=8) :: dpardx(3)
    end subroutine srfsxi
end interface
