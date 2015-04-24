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
    subroutine load_list_info(load_empty  , nb_load    , v_load_name, v_load_info,&
                              lload_name_ , lload_info_,&
                              list_load_  ,&
                              list_nbload_, list_name_)
        integer, intent(out) :: nb_load
        aster_logical, intent(out) :: load_empty
        character(len=24), pointer, intent(out) :: v_load_name(:)
        integer, pointer, intent(out) :: v_load_info(:)
        character(len=19), optional, intent(in) :: list_load_
        character(len=*), optional, intent(in) :: lload_name_
        character(len=*), optional, intent(in) :: lload_info_
        character(len=*), optional, target, intent(in) :: list_name_(*)
        integer, optional, intent(in) :: list_nbload_
    end subroutine load_list_info
end interface
