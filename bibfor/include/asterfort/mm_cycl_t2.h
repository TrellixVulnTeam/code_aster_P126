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
    subroutine mm_cycl_t2(pres_frot_prev, dist_frot_prev, coef_frot_prev, cycl_stat_prev,&
                          pres_frot_curr, dist_frot_curr, &
                          coef_frot_curr, cycl_stat_curr)
        real(kind=8), intent(in) :: pres_frot_prev(3)
        real(kind=8), intent(in) :: dist_frot_prev(3)
        integer, intent(in) :: cycl_stat_prev
        real(kind=8), intent(in) :: coef_frot_prev
        real(kind=8), intent(in) :: pres_frot_curr(3)
        real(kind=8), intent(in) :: dist_frot_curr(3)
        real(kind=8), intent(out) :: coef_frot_curr
        integer, intent(out) :: cycl_stat_curr
    end subroutine mm_cycl_t2
end interface
