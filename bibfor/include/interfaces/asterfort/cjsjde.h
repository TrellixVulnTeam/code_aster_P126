        interface
          subroutine cjsjde(mod,mater,epsd,deps,yd,yf,gd,r,signe,drdy)
            character(len=8) :: mod
            real(kind=8) :: mater(14,2)
            real(kind=8) :: epsd(6)
            real(kind=8) :: deps(6)
            real(kind=8) :: yd(14)
            real(kind=8) :: yf(14)
            real(kind=8) :: gd(6)
            real(kind=8) :: r(14)
            real(kind=8) :: signe
            real(kind=8) :: drdy(14,14)
          end subroutine cjsjde
        end interface
