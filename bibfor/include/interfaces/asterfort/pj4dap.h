        interface
          subroutine pj4dap(ino2,geom2,ma2,geom1,tria3,cobary,itr3,&
     &nbtrou,btdi,btvr,btnb,btlc,btco,ifm,niv,ldmax,distma,loin,dmin)
            integer :: ino2
            real(kind=8) :: geom2(*)
            character(len=8) :: ma2
            real(kind=8) :: geom1(*)
            integer :: tria3(*)
            real(kind=8) :: cobary(3)
            integer :: itr3
            integer :: nbtrou
            integer :: btdi(*)
            real(kind=8) :: btvr(*)
            integer :: btnb(*)
            integer :: btlc(*)
            integer :: btco(*)
            integer :: ifm
            integer :: niv
            logical :: ldmax
            real(kind=8) :: distma
            logical :: loin
            real(kind=8) :: dmin
          end subroutine pj4dap
        end interface
