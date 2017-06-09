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
!
#include "asterf_types.h"

interface
    subroutine dsygv(itype, jobz, uplo, n, a,&
                     lda, b, ldb, w, work,&
                     lwork, info)
        integer, intent(in) :: ldb
        integer, intent(in) :: lda
        integer, intent(in) :: itype
        character(len=1) ,intent(in) :: jobz
        character(len=1) ,intent(in) :: uplo
        integer, intent(in) :: n
        real(kind=8) ,intent(inout) :: a(lda, *)
        real(kind=8) ,intent(inout) :: b(ldb, *)
        real(kind=8) ,intent(out) :: w(*)
        real(kind=8) ,intent(out) :: work(*)
        integer, intent(in) :: lwork
        blas_int, intent(out) :: info
    end subroutine dsygv
end interface
