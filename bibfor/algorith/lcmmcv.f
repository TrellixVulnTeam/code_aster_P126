        SUBROUTINE LCMMCV ( DY,   DDY,    NR,    ITMAX, TOLER, ITER,
     &               NMAT,NBCOMM,   R,RINI,IRTETI)
C RESPONSABLE JMBHH01 J.M.PROIX
        IMPLICIT NONE
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 13/03/2006   AUTEUR JOUMANA J.EL-GHARIB 
C ======================================================================
C COPYRIGHT (C) 1991 - 2004  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY  
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY  
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR     
C (AT YOUR OPTION) ANY LATER VERSION.                                   
C                                                                       
C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT   
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF            
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU      
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.                              
C                                                                       
C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE     
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,         
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.         
C ======================================================================
C       ----------------------------------------------------------------
C       MONOCRISTAL        : CONTROLE DE LA CONVERGENCE
C                                  DE LA CONFORMITE DE LA SOLUTION DP
C                                  ET DE LA RE-INTEGRATION
C                                  ET DU REDECOUPAGE DU PAS DE TEMPS
C                                  SUR LA NORME DU RESIDU
C       ----------------------------------------------------------------
C       IN 
C            DY     :  VECTEUR SOLUTION DY = ( DSIG DVINT)
C            DDY    :  VECTEUR CORRECTION SUR LA SOLUTION
C            NR     :  DIMENSION DY DDY
C            ITMAX  :  NB MAXI D ITERATIONS LOCALES
C            TOLER  :  TOLERANCE A CONVERGENCE
C            ITER   :  NUMERO ITERATION COURANTE
C            R      :  R(Y) RESIDU A L'ITERATION COURANTE
C            RINI   :  R(Y0) RESIDU A L'ITERATION 1
C       OUT  IRTETI  :  =0 CONVERGENCE
C                       =1 ITERATIONS SUPPLEMENTAIRE (ITER<ITMAX)
C                       =3 ITMAX ATTEINT REDECOUPAGE LOCAL
C                       =4 ITMAX ATTEINT  REDECOUPAGE GLOBAL
C       ----------------------------------------------------------------
        INTEGER         ITMAX,  ITER,  NR,IRTETI,NDT,NDI,I,NMAT,MONO1
        REAL*8          TOLER,  DDY(NR), DY(NR), R(NR),RINI(NR)
C       ----------------------------------------------------------------
        COMMON /TDIM/   NDT  , NDI
        REAL*8          ERRDY(NR), ERRR(NR)
        REAL*8          TER(100)
        SAVE            TER
        INTEGER         NBCOMM(NMAT,3)
C       ----------------------------------------------------------------
C
C -   EVALUATION  DE L'ERREUR ABSOLUE EN RESIDU (DEFORMATIONS)
C
      MONO1=NBCOMM(NMAT,1)
      
      IF (MONO1.EQ.1) THEN
      
          ERRR(1)=0.D0
          DO 100 I = 1,NR
             ERRR(1) = MAX(ERRR(1), ABS(R(I)))
 100      CONTINUE

          ERRDY(1)=0.D0
          DO 101 I = NDT+1,NR
             ERRDY(1) = MAX(ERRDY(1), ABS(DY(I)))
 101      CONTINUE

      ELSE
C
C - EVALUATION  DE L'ERREUR RELATIVE EN DY, ERR =  !!DDY!!/!!DY!!
C
          CALL LCVERR ( DY, DDY, NR, 1, ERRDY  )
 
C - EVALUATION  DE L'ERREUR RELATIVE EN RESIDU, ERR = !!R!!/!!RINI!!
C          CALL LCVERR ( RINI, R, NR, 0, ERRR  )
          CALL LCVERR ( RINI, R, NR, 1, ERRR  )
      
      ENDIF
         
 
      TER(ITER) = ERRR(1)
C
C
C -         ITER < ITMAX
C           ------------
C
      IF ( ITER .LT. ITMAX ) THEN
C
C -             CONVERGENCE
C
          IF ( ERRR(1) .LE. TOLER ) THEN
             IRTETI = 0
             GOTO 9999
          ENDIF
          
          IF (MONO1.EQ.1) THEN
      
C        CAS OU LES VARIABLES INTERNES S'ENVOLENT
             IF ( ERRDY(1) .GT. 1.D0 ) THEN
                IRTETI = 3
                GOTO 9999
             ENDIF
             
          ENDIF
C
C -     NON CONVERGENCE ITERATION SUIVANTE
C
          IF((ITER.GE.4).AND.(ITMAX.GE.4)) THEN
             IF ((TER(ITER) .LT. TER(ITER-1)).AND.
     1           (TER(ITER-1) .LT. TER(ITER-2))   ) THEN
                IRTETI = 1
                GOTO 9999
             ELSE 
C ESSAI                 IRTETI = 3
                 IRTETI = 1
                 GOTO 9999             
             ENDIF
          ELSE
               IRTETI = 1
               GOTO 9999             
          ENDIF
C
C -         ITER >= ITMAX
C           ------------
C
      ELSEIF ( ITER .GE. ITMAX ) THEN
      
C -     TEST DE NON DIVERGENCE
         CALL LCVERR ( DY, DDY, NR, 0, ERRDY  )
         
         IF ( ERRR(1) .LE. TOLER ) THEN
            IRTETI = 0
            GOTO 9999
C
C        RESIDU NON NUL MAIS SOLUTION STABLE. ON ACCEPTE
         ELSEIF ( ERRDY(1) .LE. TOLER ) THEN
            IRTETI = 0
            GOTO 9999
          ENDIF
C
C -      NON CONVERGENCE ET ITMAX ATTEINT
C
         IF(ITER.GE.4) THEN
          IF ((TER(ITER) .LT. TER(ITER-1)).AND.
     1           (TER(ITER-1) .LT. TER(ITER-2) )    ) THEN
            IRTETI = 3
            GOTO 9999
          ENDIF
          ELSE 
            IRTETI=3
            GOTO 9999
          ENDIF
C
      ENDIF
C
 9999 CONTINUE
      END
