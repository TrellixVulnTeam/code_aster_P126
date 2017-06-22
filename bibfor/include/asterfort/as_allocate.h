! --------------------------------------------------------------------
! Copyright (C) 1991 - 2017 - EDF R&D - www.code-aster.org
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
! because macros must be on a single line
! aslint: disable=C1509
!
#include "asterf.h"
#include "asterf_debug.h"

#ifdef __DEBUG_ALLOCATE__
#   define DEBUG_LOC_ALLOCATE(a, b, c) DEBUG_LOC(a, b, c)
#else
#   define DEBUG_LOC_ALLOCATE(a, b, c) continue
#endif

! To have a syntax similar to the standard ALLOCATE
#define AS_ALLOCATE(arg, size) DEBUG_LOC_ALLOCATE("alloc", __FILE__, __LINE__) ; call as_allocate(arg, size, strdbg=TO_STRING((arg, size)))
!
#include "asterf_types.h"
!
interface
    subroutine as_allocate(size, vl, vi, vi4, vr, &
                           vc, vk8, vk16, vk24, vk32, &
                           vk80, strdbg)
        integer :: size
    aster_logical,           pointer, optional, intent(out) :: vl(:)
    integer,           pointer, optional, intent(out) :: vi(:)
    integer(kind=4),   pointer, optional, intent(out) :: vi4(:)
    real(kind=8),      pointer, optional, intent(out) :: vr(:)
    complex(kind=8),   pointer, optional, intent(out) :: vc(:)
    character(len=8),  pointer, optional, intent(out) :: vk8(:)
    character(len=16), pointer, optional, intent(out) :: vk16(:)
    character(len=24), pointer, optional, intent(out) :: vk24(:)
    character(len=32), pointer, optional, intent(out) :: vk32(:)
    character(len=80), pointer, optional, intent(out) :: vk80(:)
!
        character(len=*) :: strdbg
    end subroutine as_allocate
end interface
