        interface
          subroutine vppgec(lmasse,lamor,lraide,masseg,amorg,raideg,&
     &vect,neq,nbvect,iddl)
            integer :: neq
            integer :: lmasse
            integer :: lamor
            integer :: lraide
            real(kind=8) :: masseg(*)
            real(kind=8) :: amorg(*)
            real(kind=8) :: raideg(*)
            complex(kind=8) :: vect(neq,*)
            integer :: nbvect
            integer :: iddl(*)
          end subroutine vppgec
        end interface
