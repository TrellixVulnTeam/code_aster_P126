      SUBROUTINE FTRSEN( JOB, COMPQ, SELECT, N, T, LDT, Q, LDQ, WR, WI,
     &                   M, S, SEP, WORK, LWORK, IWORK, LIWORK, INFO )
C----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILIFOR  DATE 20/09/2002   AUTEUR D6BHHJP J.P.LEFEBVRE 
C ======================================================================
C COPYRIGHT (C) LAPACK
C ======================================================================
C TOLE CRP_21
C
C     SUBROUTINE LAPACK REORDONNANT LA FACTORISATION DE SCHUR REELLE
C     DEJA CALCULEES PAR DHSEQR, POUR OBTENIR UN CLUSTER DE VALEURS
C     PROPRES SUR LA DIAGONALE DE LA MATRICE TRIANGULAIRE SUPERIEURE.
C-----------------------------------------------------------------------
C  -- LAPACK ROUTINE (VERSION 2.0) --
C     UNIV. OF TENNESSEE, UNIV. OF CALIFORNIA BERKELEY, NAG LTD.,
C     COURANT INSTITUTE, ARGONNE NATIONAL LAB, AND RICE UNIVERSITY
C     SEPTEMBER 30, 1994
C
C  PURPOSE
C  =======
C
C  FTRSEN REORDERS THE REAL SCHUR FACTORIZATION OF A REAL MATRIX
C  A = Q*T*Q**T, SO THAT A SELECTED CLUSTER OF EIGENVALUES APPEARS IN
C  THE LEADING DIAGONAL BLOCKS OF THE UPPER QUASI-TRIANGULAR MATRIX T,
C  AND THE LEADING COLUMNS OF Q FORM AN ORTHONORMAL BASIS OF THE
C  CORRESPONDING RIGHT INVARIANT SUBSPACE.
C
C  OPTIONALLY THE ROUTINE COMPUTES THE RECIPROCAL CONDITION NUMBERS OF
C  THE CLUSTER OF EIGENVALUES AND/OR THE INVARIANT SUBSPACE.
C
C  T MUST BE IN SCHUR CANONICAL FORM (AS RETURNED BY DHSEQR), THAT IS,
C  BLOCK UPPER TRIANGULAR WITH 1-BY-1 AND 2-BY-2 DIAGONAL BLOCKS, EACH
C  2-BY-2 DIAGONAL BLOCK HAS ITS DIAGONAL ELEMNTS EQUAL AND ITS
C  OFF-DIAGONAL ELEMENTS OF OPPOSITE SIGN.
C
C  ARGUMENTS
C  =========
C
C  JOB     (INPUT) CHARACTER*1
C          SPECIFIES WHETHER CONDITION NUMBERS ARE REQUIRED FOR THE
C          CLUSTER OF EIGENVALUES (S) OR THE INVARIANT SUBSPACE (SEP):
C          = 'N': NONE,
C          = 'E': FOR EIGENVALUES ONLY (S),
C          = 'V': FOR INVARIANT SUBSPACE ONLY (SEP),
C          = 'B': FOR BOTH EIGENVALUES AND INVARIANT SUBSPACE (S AND
C                 SEP).
C
C  COMPQ   (INPUT) CHARACTER*1
C          = 'V': UPDATE THE MATRIX Q OF SCHUR VECTORS,
C          = 'N': DO NOT UPDATE Q.
C
C  SELECT  (INPUT) LOGICAL ARRAY, DIMENSION (N)
C          SELECT SPECIFIES THE EIGENVALUES IN THE SELECTED CLUSTER. TO
C          SELECT A REAL EIGENVALUE W(J), SELECT(J) MUST BE SET TO
C          .TRUE.. TO SELECT A COMPLEX CONJUGATE PAIR OF EIGENVALUES
C          W(J) AND W(J+1), CORRESPONDING TO A 2-BY-2 DIAGONAL BLOCK,
C          EITHER SELECT(J) OR SELECT(J+1) OR BOTH MUST BE SET TO
C          .TRUE., A COMPLEX CONJUGATE PAIR OF EIGENVALUES MUST BE
C          EITHER BOTH INCLUDED IN THE CLUSTER OR BOTH EXCLUDED.
C
C  N       (INPUT) INTEGER
C          THE ORDER OF THE MATRIX T. N >= 0.
C
C  T       (INPUT/OUTPUT) REAL*8 ARRAY, DIMENSION (LDT,N)
C          ON ENTRY, THE UPPER QUASI-TRIANGULAR MATRIX T, IN SCHUR
C          CANONICAL FORM.
C          ON EXIT, T IS OVERWRITTEN BY THE REORDERED MATRIX T, AGAIN IN
C          SCHUR CANONICAL FORM, WITH THE SELECTED EIGENVALUES IN THE
C          LEADING DIAGONAL BLOCKS.
C
C  LDT     (INPUT) INTEGER
C          THE LEADING DIMENSION OF THE ARRAY T. LDT >= MAX(1,N).
C
C  Q       (INPUT/OUTPUT) REAL*8 ARRAY, DIMENSION (LDQ,N)
C          ON ENTRY, IF COMPQ = 'V', THE MATRIX Q OF SCHUR VECTORS.
C          ON EXIT, IF COMPQ = 'V', Q HAS BEEN POSTMULTIPLIED BY THE
C          ORTHOGONAL TRANSFORMATION MATRIX WHICH REORDERS T, THE
C          LEADING M COLUMNS OF Q FORM AN ORTHONORMAL BASIS FOR THE
C          SPECIFIED INVARIANT SUBSPACE.
C          IF COMPQ = 'N', Q IS NOT REFERENCED.
C
C  LDQ     (INPUT) INTEGER
C          THE LEADING DIMENSION OF THE ARRAY Q.
C          LDQ >= 1, AND IF COMPQ = 'V', LDQ >= N.
C
C  WR      (OUTPUT) REAL*8 ARRAY, DIMENSION (N)
C  WI      (OUTPUT) REAL*8 ARRAY, DIMENSION (N)
C          THE REAL AND IMAGINARY PARTS, RESPECTIVELY, OF THE REORDERED
C          EIGENVALUES OF T. THE EIGENVALUES ARE STORED IN THE SAME
C          ORDER AS ON THE DIAGONAL OF T, WITH WR(I) = T(I,I) AND, IF
C          T(I:I+1,I:I+1) IS A 2-BY-2 DIAGONAL BLOCK, WI(I) > 0 AND
C          WI(I+1) = -WI(I). NOTE THAT IF A COMPLEX EIGENVALUE IS
C          SUFFICIENTLY ILL-CONDITIONED, THEN ITS VALUE MAY DIFFER
C          SIGNIFICANTLY FROM ITS VALUE BEFORE REORDERING.
C
C  M       (OUTPUT) INTEGER
C          THE DIMENSION OF THE SPECIFIED INVARIANT SUBSPACE.
C          0 < = M <= N.
C
C  S       (OUTPUT) REAL*8
C          IF JOB = 'E' OR 'B', S IS A LOWER BOUND ON THE RECIPROCAL
C          CONDITION NUMBER FOR THE SELECTED CLUSTER OF EIGENVALUES.
C          S CANNOT UNDERESTIMATE THE TRUE RECIPROCAL CONDITION NUMBER
C          BY MORE THAN A FACTOR OF SQRT(N). IF M = 0 OR N, S = 1.
C          IF JOB = 'N' OR 'V', S IS NOT REFERENCED.
C
C  SEP     (OUTPUT) REAL*8
C          IF JOB = 'V' OR 'B', SEP IS THE ESTIMATED RECIPROCAL
C          CONDITION NUMBER OF THE SPECIFIED INVARIANT SUBSPACE. IF
C          M = 0 OR N, SEP = NORM(T).
C          IF JOB = 'N' OR 'E', SEP IS NOT REFERENCED.
C
C  WORK    (WORKSPACE) REAL*8 ARRAY, DIMENSION (LWORK)
C
C  LWORK   (INPUT) INTEGER
C          THE DIMENSION OF THE ARRAY WORK.
C          IF JOB = 'N', LWORK >= MAX(1,N),
C          IF JOB = 'E', LWORK >= M*(N-M),
C          IF JOB = 'V' OR 'B', LWORK >= 2*M*(N-M).
C
C  IWORK   (WORKSPACE) INTEGER ARRAY, DIMENSION (LIWORK)
C          IF JOB = 'N' OR 'E', IWORK IS NOT REFERENCED.
C
C  LIWORK  (INPUT) INTEGER
C          THE DIMENSION OF THE ARRAY IWORK.
C          IF JOB = 'N' OR 'E', LIWORK >= 1,
C          IF JOB = 'V' OR 'B', LIWORK >= M*(N-M).
C
C  INFO    (OUTPUT) INTEGER
C          = 0: SUCCESSFUL EXIT
C          < 0: IF INFO = -I, THE I-TH ARGUMENT HAD AN ILLEGAL VALUE
C          = 1: REORDERING OF T FAILED BECAUSE SOME EIGENVALUES ARE TOO
C               CLOSE TO SEPARATE (THE PROBLEM IS VERY ILL-CONDITIONED),
C               T MAY HAVE BEEN PARTIALLY REORDERED, AND WR AND WI
C               CONTAIN THE EIGENVALUES IN THE SAME ORDER AS IN T, S AND
C               SEP (IF REQUESTED) ARE SET TO ZERO.
C
C  FURTHER DETAILS
C  ===============
C
C  FTRSEN FIRST COLLECTS THE SELECTED EIGENVALUES BY COMPUTING AN
C  ORTHOGONAL TRANSFORMATION Z TO MOVE THEM TO THE TOP LEFT CORNER OF T.
C  IN OTHER WORDS, THE SELECTED EIGENVALUES ARE THE EIGENVALUES OF T11
C  IN:
C
C                Z'*T*Z = ( T11 T12 ) N1
C                         (  0  T22 ) N2
C                            N1  N2
C
C  WHERE N = N1+N2 AND Z' MEANS THE TRANSPOSE OF Z. THE FIRST N1 COLUMNS
C  OF Z SPAN THE SPECIFIED INVARIANT SUBSPACE OF T.
C
C  IF T HAS BEEN OBTAINED FROM THE REAL SCHUR FACTORIZATION OF A MATRIX
C  A = Q*T*Q', THEN THE REORDERED REAL SCHUR FACTORIZATION OF A IS GIVEN
C  BY A = (Q*Z)*(Z'*T*Z)*(Q*Z)', AND THE FIRST N1 COLUMNS OF Q*Z SPAN
C  THE CORRESPONDING INVARIANT SUBSPACE OF A.
C
C  THE RECIPROCAL CONDITION NUMBER OF THE AVERAGE OF THE EIGENVALUES OF
C  T11 MAY BE RETURNED IN S. S LIES BETWEEN 0 (VERY BADLY CONDITIONED)
C  AND 1 (VERY WELL CONDITIONED). IT IS COMPUTED AS FOLLOWS. FIRST WE
C  COMPUTE R SO THAT
C
C                         P = ( I  R ) N1
C                             ( 0  0 ) N2
C                               N1 N2
C
C  IS THE PROJECTOR ON THE INVARIANT SUBSPACE ASSOCIATED WITH T11.
C  R IS THE SOLUTION OF THE SYLVESTER EQUATION:
C
C                        T11*R - R*T22 = T12.
C
C  LET F-NORM(M) DENOTE THE FROBENIUS-NORM OF M AND 2-NORM(M) DENOTE
C  THE TWO-NORM OF M. THEN S IS COMPUTED AS THE LOWER BOUND
C
C                      (1 + F-NORM(R)**2)**(-1/2)
C
C  ON THE RECIPROCAL OF 2-NORM(P), THE TRUE RECIPROCAL CONDITION NUMBER.
C  S CANNOT UNDERESTIMATE 1 / 2-NORM(P) BY MORE THAN A FACTOR OF
C  SQRT(N).
C
C  AN APPROXIMATE ERROR BOUND FOR THE COMPUTED AVERAGE OF THE
C  EIGENVALUES OF T11 IS
C
C                         EPS * NORM(T) / S
C
C  WHERE EPS IS THE MACHINE PRECISION.
C
C  THE RECIPROCAL CONDITION NUMBER OF THE RIGHT INVARIANT SUBSPACE
C  SPANNED BY THE FIRST N1 COLUMNS OF Z (OR OF Q*Z) IS RETURNED IN SEP.
C  SEP IS DEFINED AS THE SEPARATION OF T11 AND T22:
C
C                     SEP( T11, T22 ) = SIGMA-MIN( C )
C
C  WHERE SIGMA-MIN(C) IS THE SMALLEST SINGULAR VALUE OF THE
C  N1*N2-BY-N1*N2 MATRIX
C
C     C  = KPROD( I(N2), T11 ) - KPROD( TRANSPOSE(T22), I(N1) )
C
C  I(M) IS AN M BY M IDENTITY MATRIX, AND KPROD DENOTES THE KRONECKER
C  PRODUCT. WE ESTIMATE SIGMA-MIN(C) BY THE RECIPROCAL OF AN ESTIMATE OF
C  THE 1-NORM OF INVERSE(C). THE TRUE RECIPROCAL 1-NORM OF INVERSE(C)
C  CANNOT DIFFER FROM SIGMA-MIN(C) BY MORE THAN A FACTOR OF SQRT(N1*N2).
C
C  WHEN SEP IS SMALL, SMALL CHANGES IN T CAN CAUSE LARGE CHANGES IN
C  THE INVARIANT SUBSPACE. AN APPROXIMATE BOUND ON THE MAXIMUM ANGULAR
C  ERROR IN THE COMPUTED RIGHT INVARIANT SUBSPACE IS
C
C                      EPS * NORM(T) / SEP
C
C-----------------------------------------------------------------------
C ASTER INFORMATION
C 14/01/2000 TOILETTAGE DU FORTRAN SUIVANT LES REGLES ASTER,
C            REMPLACEMENT DE 1 RETURN PAR GOTO 1000,
C            IMPLICIT NONE.
C INTRINSIC FUNCTIONS
C            ABS, MAX, SQRT.
C-----------------------------------------------------------------------
C CORPS DU PROGRAMME
      IMPLICIT NONE

C     .. SCALAR ARGUMENTS ..
      CHARACTER*1 COMPQ, JOB
      INTEGER  INFO, LDQ, LDT, LIWORK, LWORK, M, N
      REAL*8   S, SEP
C     ..
C     .. ARRAY ARGUMENTS ..
      LOGICAL        SELECT( * )
      INTEGER        IWORK( * )
      REAL*8   Q( LDQ, * ), T( LDT, * ), WI( * ), WORK( * ),
     &                   WR( * )
C     .. PARAMETERS ..
      REAL*8   ZERO, ONE
      PARAMETER          ( ZERO = 0.0D+0, ONE = 1.0D+0 )
C     ..
C     .. LOCAL SCALARS ..
      LOGICAL            PAIR, SWAP, WANTBH, WANTQ, WANTS, WANTSP
      INTEGER            IERR, K, KASE, KK, KS, N1, N2, NN
      REAL*8   EST, RNORM, SCALE
C     ..
C     .. EXTERNAL FUNCTIONS ..
      LOGICAL  LLSAME
      REAL*8   FLANGE
C     ..
C     .. EXECUTABLE STATEMENTS ..
C
C     DECODE AND TEST THE INPUT PARAMETERS
C
      WANTBH = LLSAME( JOB, 'B' )
      WANTS = LLSAME( JOB, 'E' ) .OR. WANTBH
      WANTSP = LLSAME( JOB, 'V' ) .OR. WANTBH
      WANTQ = LLSAME( COMPQ, 'V' )
C
      INFO = 0
      IF( .NOT.LLSAME( JOB, 'N' ) .AND. .NOT.WANTS .AND. .NOT.WANTSP )
     &     THEN
         INFO = -1
      ELSE IF( .NOT.LLSAME( COMPQ, 'N' ) .AND. .NOT.WANTQ ) THEN
         INFO = -2
      ELSE IF( N.LT.0 ) THEN
         INFO = -4
      ELSE IF( LDT.LT.MAX( 1, N ) ) THEN
         INFO = -6
      ELSE IF( LDQ.LT.1 .OR. ( WANTQ .AND. LDQ.LT.N ) ) THEN
         INFO = -8
      ELSE
C
C        SET M TO THE DIMENSION OF THE SPECIFIED INVARIANT SUBSPACE,
C        AND TEST LWORK AND LIWORK.
C
         M = 0
         PAIR = .FALSE.
         DO 10 K = 1, N
            IF( PAIR ) THEN
               PAIR = .FALSE.
            ELSE
               IF( K.LT.N ) THEN
                  IF( T( K+1, K ).EQ.ZERO ) THEN
                     IF( SELECT( K ) )
     &                  M = M + 1
                  ELSE
                     PAIR = .TRUE.
                     IF( SELECT( K ) .OR. SELECT( K+1 ) )
     &                  M = M + 2
                  END IF
               ELSE
                  IF( SELECT( N ) )
     &               M = M + 1
               END IF
            END IF
   10    CONTINUE
C
         N1 = M
         N2 = N - M
         NN = N1*N2
C
         IF( LWORK.LT.1 .OR. ( ( WANTS .AND. .NOT.WANTSP ) .AND.
     &       LWORK.LT.NN ) .OR. ( WANTSP .AND. LWORK.LT.2*NN ) ) THEN
            INFO = -15
         ELSE IF( LIWORK.LT.1 .OR. ( WANTSP .AND. LIWORK.LT.NN ) ) THEN
            INFO = -17
         END IF
      END IF
      IF( INFO.NE.0 ) THEN
         CALL XERBLA( 'FTRSEN', -INFO )
         GOTO 1000
      END IF
C
C     QUICK RETURN IF POSSIBLE.
C
      IF( M.EQ.N .OR. M.EQ.0 ) THEN
         IF( WANTS )
     &      S = ONE
         IF( WANTSP )
     &      SEP = FLANGE( '1', N, N, T, LDT, WORK )
         GO TO 40
      END IF
C
C     COLLECT THE SELECTED BLOCKS AT THE TOP-LEFT CORNER OF T.
C
      KS = 0
      PAIR = .FALSE.
      DO 20 K = 1, N
         IF( PAIR ) THEN
            PAIR = .FALSE.
         ELSE
            SWAP = SELECT( K )
            IF( K.LT.N ) THEN
               IF( T( K+1, K ).NE.ZERO ) THEN
                  PAIR = .TRUE.
                  SWAP = SWAP .OR. SELECT( K+1 )
               END IF
            END IF
            IF( SWAP ) THEN
               KS = KS + 1
C
C              SWAP THE K-TH BLOCK TO POSITION KS.
C
               IERR = 0
               KK = K
               IF( K.NE.KS )
     &            CALL FTREXC( COMPQ, N, T, LDT, Q, LDQ, KK, KS, WORK,
     &                         IERR )
               IF( IERR.EQ.1 .OR. IERR.EQ.2 ) THEN
C
C                 BLOCKS TOO CLOSE TO SWAP: EXIT.
C
                  INFO = 1
                  IF( WANTS )
     &               S = ZERO
                  IF( WANTSP )
     &               SEP = ZERO
                  GO TO 40
               END IF
               IF( PAIR )
     &            KS = KS + 1
            END IF
         END IF
   20 CONTINUE
C
      IF( WANTS ) THEN
C
C        SOLVE SYLVESTER EQUATION FOR R:
C
C           T11*R - R*T22 = SCALE*T12
C
         CALL FLACPY( 'F', N1, N2, T( 1, N1+1 ), LDT, WORK, N1 )
         CALL FLRSYL( 'N', 'N', -1, N1, N2, T, LDT, T( N1+1, N1+1 ),
     &                LDT, WORK, N1, SCALE, IERR )
C
C        ESTIMATE THE RECIPROCAL OF THE CONDITION NUMBER OF THE CLUSTER
C        OF EIGENVALUES.
C
         RNORM = FLANGE( 'F', N1, N2, WORK, N1, WORK )
         IF( RNORM.EQ.ZERO ) THEN
            S = ONE
         ELSE
            S = SCALE / ( SQRT( SCALE*SCALE / RNORM+RNORM )*
     &          SQRT( RNORM ) )
         END IF
      END IF
C
      IF( WANTSP ) THEN
C
C        ESTIMATE SEP(T11,T22).
C
         EST = ZERO
         KASE = 0
   30    CONTINUE
         CALL FLACON( NN, WORK( NN+1 ), WORK, IWORK, EST, KASE )
         IF( KASE.NE.0 ) THEN
            IF( KASE.EQ.1 ) THEN
C
C              SOLVE  T11*R - R*T22 = SCALE*X.
C
               CALL FLRSYL( 'N', 'N', -1, N1, N2, T, LDT,
     &                      T( N1+1, N1+1 ), LDT, WORK, N1, SCALE,
     &                      IERR )
            ELSE
C
C              SOLVE  T11'*R - R*T22' = SCALE*X.
C
               CALL FLRSYL( 'T', 'T', -1, N1, N2, T, LDT,
     &                      T( N1+1, N1+1 ), LDT, WORK, N1, SCALE,
     &                      IERR )
            END IF
            GO TO 30
         END IF
C
         SEP = SCALE / EST
      END IF
C
   40 CONTINUE
C
C     STORE THE OUTPUT EIGENVALUES IN WR AND WI.
C
      DO 50 K = 1, N
         WR( K ) = T( K, K )
         WI( K ) = ZERO
   50 CONTINUE
      DO 60 K = 1, N - 1
         IF( T( K+1, K ).NE.ZERO ) THEN
            WI( K ) = SQRT( ABS( T( K, K+1 ) ) )*
     &                SQRT( ABS( T( K+1, K ) ) )
            WI( K+1 ) = -WI( K )
         END IF
   60 CONTINUE
 1000 CONTINUE
C
C     END OF FTRSEN
C
      END
