        interface
          subroutine dfddd(eps,endo,ndim,lambda,mu,ecrod,dfd)
            real(kind=8) :: eps(6)
            real(kind=8) :: endo
            integer :: ndim
            real(kind=8) :: lambda
            real(kind=8) :: mu
            real(kind=8) :: ecrod
            real(kind=8) :: dfd
          end subroutine dfddd
        end interface
