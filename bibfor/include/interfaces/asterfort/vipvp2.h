        interface
          subroutine vipvp2(nbvari,vintm,vintp,advico,vicpvp,pvp0,pvp1&
     &,p2,dp2,t,dt,kh,mamolv,r,rho11m,yate,pvp,pvpm,retcom)
            integer :: nbvari
            real(kind=8) :: vintm(nbvari)
            real(kind=8) :: vintp(nbvari)
            integer :: advico
            integer :: vicpvp
            real(kind=8) :: pvp0
            real(kind=8) :: pvp1
            real(kind=8) :: p2
            real(kind=8) :: dp2
            real(kind=8) :: t
            real(kind=8) :: dt
            real(kind=8) :: kh
            real(kind=8) :: mamolv
            real(kind=8) :: r
            real(kind=8) :: rho11m
            integer :: yate
            real(kind=8) :: pvp
            real(kind=8) :: pvpm
            integer :: retcom
          end subroutine vipvp2
        end interface
