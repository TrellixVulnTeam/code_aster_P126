        interface
          function dlange(norm,m,n,a,lda,work)
            integer :: lda
            character(len=1) :: norm
            integer :: m
            integer :: n
            real(kind=8) :: a(lda,*)
            real(kind=8) :: work(*)
            real(kind=8) :: dlange
          end function dlange
        end interface
