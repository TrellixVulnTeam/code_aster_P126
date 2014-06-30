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
    subroutine mm_cycl_detect(sd_cont_defi  , sd_cont_solv  , &
                              l_loop_cont, l_frot_zone, point_index, &
                              coef_cont     , pres_cont_prev, dist_cont_prev, &
                              indi_frot_prev, dist_frot_prev, &
                              indi_cont_eval, indi_frot_eval, &
                              dist_cont_curr, pres_cont_curr, dist_frot_curr)
        character(len=24), intent(in) :: sd_cont_defi
        character(len=24), intent(in) :: sd_cont_solv
        logical(kind=1), intent(in) :: l_loop_cont
        logical(kind=1), intent(in) :: l_frot_zone
        integer, intent(in) :: point_index
        real(kind=8), intent(in) :: coef_cont
        real(kind=8), intent(in) :: pres_cont_prev
        real(kind=8), intent(in) :: dist_cont_prev
        integer, intent(in) :: indi_frot_prev
        real(kind=8), intent(in) :: dist_frot_prev(3)
        integer, intent(in) :: indi_cont_eval
        integer, intent(in) :: indi_frot_eval
        real(kind=8), intent(in) :: dist_cont_curr
        real(kind=8), intent(in) :: pres_cont_curr
        real(kind=8), intent(in) :: dist_frot_curr(3)
    end subroutine mm_cycl_detect
end interface
