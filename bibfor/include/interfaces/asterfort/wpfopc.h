        interface
          subroutine wpfopc(lmasse,lamor,lraide,fmin,sigma,matopa,&
     &raide,lqz,solveu)
            integer :: lmasse
            integer :: lamor
            integer :: lraide
            real(kind=8) :: fmin
            complex(kind=8) :: sigma
            character(*) :: matopa
            character(*) :: raide
            logical :: lqz
            character(len=19) :: solveu
          end subroutine wpfopc
        end interface
