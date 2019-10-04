! --------------------------------------------------------------------
! Copyright (C) 1991 - 2019 - EDF R&D - www.code-aster.org
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
#include "asterf_types.h"
!
interface
    subroutine getExternalStrainModel(l_mfront_offi, l_mfront_proto, paraExte,&
                                      defo_comp    , istrainexte)
        use Behaviour_type
        aster_logical, intent(in) :: l_mfront_offi
        aster_logical, intent(in) :: l_mfront_proto
        type(Behaviour_ParaExte), intent(in) :: paraExte
        character(len=16), intent(in) :: defo_comp
        integer, intent(out) :: istrainexte
    end subroutine getExternalStrainModel
end interface
