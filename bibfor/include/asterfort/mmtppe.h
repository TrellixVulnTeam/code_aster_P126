! --------------------------------------------------------------------
! Copyright (C) 1991 - 2018 - EDF R&D - www.code-aster.org
! This file is part of code_aster.
!
! code_aster is free software: you can redistribute it and/or modify
! it under the terms of the GNU General Public License as published by
! the Free Software Foundation, either version 3 of the License, or
! (at your option) any later version.
!
! code_aster is distributed in the hope that it will be useful,
! but WITHOUT ANY WARRANTY; without even the implied warranty of
! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
! GNU General Public License for more details.
!
! You should have received a copy of the GNU General Public License
! along with code_aster.  If not, see <http://www.gnu.org/licenses/>.
! --------------------------------------------------------------------

!
!
#include "asterf_types.h"
!
interface
    subroutine mmtppe(typmae,typmam,ndim  ,nne   ,nnm   , &
                      nnl   ,nbdm  ,iresog,laxis ,ldyna , &
                      jeusup,ffe   ,ffm   ,dffm  ,ffl   , &
                      jacobi,wpg   ,jeu   ,djeut ,dlagrc, &
                      dlagrf,norm  ,tau1  ,tau2  ,mprojn, &
                      mprojt,mprt1n,mprt2n,gene11,gene21, &
              gene22,kappa ,h     ,vech1 ,vech2 , &
              a     ,ha    ,hah   ,mprt11,mprt21, &
              mprt22, l_previous)
              
        character(len=8) :: typmae
        character(len=8) :: typmam
        integer :: ndim
        integer :: nne
        integer :: nnm
        integer :: nnl
        integer :: nbdm
        integer :: iresog
        aster_logical :: laxis
        aster_logical :: ldyna
        aster_logical :: l_previous
    
        real(kind=8) :: jeusup
        real(kind=8) :: ffe(9)
        real(kind=8) :: ffm(9)
        real(kind=8) :: dffm(2, 9)
        real(kind=8) :: ffl(9)
        real(kind=8) :: jacobi
        real(kind=8) :: wpg
        real(kind=8) :: jeu
        real(kind=8) :: djeut(3)
        real(kind=8) :: dlagrc
        real(kind=8) :: dlagrf(2)
        real(kind=8) :: norm(3)
        real(kind=8) :: tau1(3)
        real(kind=8) :: tau2(3)
        
        real(kind=8) :: dnepmait1 ,dnepmait2 ,taujeu1,taujeu2
    
        real(kind=8) :: mprojn(3, 3)
        real(kind=8) :: mprojt(3, 3)
    
        real(kind=8) :: mprt1n(3, 3)
        real(kind=8) :: mprt2n(3, 3)
        real(kind=8) :: mprt11(3, 3)
        real(kind=8) :: mprt21(3, 3)
    real(kind=8) :: mprt22(3, 3)
        
        real(kind=8) :: gene11(3, 3)
        real(kind=8) :: gene21(3, 3)
    real(kind=8) :: gene22(3, 3)
    
    real(kind=8) :: kappa(2,2)
    real(kind=8) :: h(2,2)    
    real(kind=8) :: a(2,2)        
    real(kind=8) :: ha(2,2)    
    real(kind=8) :: hah(2,2)
    
    real(kind=8) :: vech1(3)
    real(kind=8) :: vech2(3)            
    
    
    end subroutine mmtppe
end interface
