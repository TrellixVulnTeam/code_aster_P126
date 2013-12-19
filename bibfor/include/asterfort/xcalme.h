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
    subroutine xcalme(option, meca, imate, ndim, dimenr,&
                      dimcon, addeme, adcome, congep,&
                      yaenrm, adenme, dsde, deps, t,&
                      idecpg, kpi, ang2, aniso, phenom)
        integer :: dimcon
        integer :: dimenr
        character(len=16) :: option
        character(len=16) :: meca
        integer :: imate
        integer :: ndim
        integer :: addeme
        integer :: adcome
        real(kind=8) :: congep(dimcon)
        integer :: yaenrm
        integer :: adenme
        real(kind=8) :: dsde(dimcon, dimenr)
        real(kind=8) :: deps(6)
        real(kind=8) :: t
        integer :: idecpg
        integer :: kpi
        real(kind=8) :: ang2(3)
        integer :: aniso
        character(len=16) :: phenom
    end subroutine xcalme
end interface 
