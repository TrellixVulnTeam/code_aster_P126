        interface
          subroutine nmcine(fami,kpg,ksp,ndim,imate,compor,crit,instam&
     &,instap,epsm,deps,sigm,vim,option,sigp,vip,dsidep,iret)
            character(*) :: fami
            integer :: kpg
            integer :: ksp
            integer :: ndim
            integer :: imate
            character(len=16) :: compor(*)
            real(kind=8) :: crit(10)
            real(kind=8) :: instam
            real(kind=8) :: instap
            real(kind=8) :: epsm(6)
            real(kind=8) :: deps(6)
            real(kind=8) :: sigm(6)
            real(kind=8) :: vim(7)
            character(len=16) :: option
            real(kind=8) :: sigp(6)
            real(kind=8) :: vip(7)
            real(kind=8) :: dsidep(6,6)
            integer :: iret
          end subroutine nmcine
        end interface
