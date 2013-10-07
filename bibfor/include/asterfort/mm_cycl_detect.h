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
    subroutine mm_cycl_detect(sd_cont_defi, sd_cont_solv, l_loop_cont, l_frot_zone, point_index, &
                              pres_cont_prev, dist_cont_prev, coef_cont_prev, indi_frot_prev, &
                              dist_frot_prev, indi_cont, dist_cont, pres_cont, indi_frot,&
                              dist_frot)
        character(len=24), intent(in) :: sd_cont_defi
        character(len=24), intent(in) :: sd_cont_solv
        logical, intent(in) :: l_loop_cont
        logical, intent(in) :: l_frot_zone
        integer, intent(in) :: point_index
        real(kind=8), intent(in) :: pres_cont_prev
        real(kind=8), intent(in) :: dist_cont_prev
        integer, intent(in) :: indi_frot_prev
        real(kind=8), intent(in) :: dist_frot_prev(3)
        real(kind=8), intent(in) :: coef_cont_prev
        real(kind=8), intent(in) :: dist_frot(3)
        integer, intent(in) :: indi_cont
        real(kind=8), intent(in) :: pres_cont
        real(kind=8), intent(in) :: dist_cont
        integer, intent(in) :: indi_frot
    end subroutine mm_cycl_detect
end interface
