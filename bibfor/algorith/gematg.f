      SUBROUTINE GEMATG ( N, DELTA, MATMOY, MAT, MAT1, MAT2 )
      IMPLICIT   NONE
      INTEGER    N
      REAL*8     DELTA, MATMOY(*), MAT(*), MAT1(*), MAT2(*)
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 16/07/2002   AUTEUR VABHHTS J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2002  EDF R&D                  WWW.CODE-ASTER.ORG
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
C
C  GENERATEUR DE MATRICE ALEATOIRE DU MODELE PROBABILISTE 
C  NON PARAMETRIQUE.
C
C  LA PROCEDURE EST DUE AU PROFESSEUR CHRISTIAN SOIZE (2001).
C
C
C  N      : N X N EST LA DIMENSION DE LA MATRICE A GENERER  
C  DELTA  : PARAMETRE DE DISPERSION DE LA MATRICE ALEATOIRE.
C  MATMOY : TABLEAUX DES VALEURS DE LA MATRICE MOYENNE
C  MAT    : TABLEAUX DES VALEURS DE LA MATRICE A GENERER
C  MAT1   : TABLEAU DE TRAVAIL
C  MAT2   : TABLEAU DE TRAVAIL
C
C ----------------------------------------------------------------------
      INTEGER   I, J, K, L, IIND, JIND, LIND, KIND
      REAL*8    SUM, TLII, P, SIGMA, ALPHA, V, GAMDEV, U, GASDEV
C DEB ------------------------------------------------------------------
C      
      CALL JEMARQ()
C
C --- CALCUL DES PARAMETRES P ET SIGMA ET 
C     INITIALISATION DE LA MATRICE TL
C     
      P = (N+1D0)/(DELTA**2) 
      SIGMA = 1D0 / SQRT(P)
C
C --- CALCUL DES TERMES DIAGONAUX DE LA MATRICE ALEATOIRE TL
C 
      DO 80 J=1,N
         JIND  = J*(J+1) / 2
         ALPHA = (P-J+1.D0) / 2.D0
         V     = GAMDEV(ALPHA)
         MAT2(JIND) = SIGMA*SQRT(2.D0*V)
80     CONTINUE
C
C --- CALCUL DES TERMES EXTRADIAGONAUX DE LA MATRICE ALEATOIRE TL
C
      DO 89 J = 2,N
         JIND = J*(J-1) / 2
         DO 88 I = 1,J-1
            U = GASDEV()
            MAT2(I+JIND) = SIGMA*U
88       CONTINUE
89    CONTINUE
C
C --- CALCUL DE LA MATRICE ALEATOIRE G=L.TL
C
      DO 100 J = 1,N
         JIND = J*(J-1) / 2
         DO 99 I = 1,J
            IIND = I*(I-1) / 2
            SUM  = 0D0
            DO 98 K=1,I
               SUM = SUM + MAT2(K + IIND)*MAT2(K + JIND)
98          CONTINUE
            MAT1(I+JIND) = SUM
99       CONTINUE
100   CONTINUE
C
C --- FACTORISATION DE CHOLESKI DE K
C
      DO 113 I=1,N
         IIND = I*(I-1)/2
         DO 112 J=I,N
            JIND = J*(J-1)/2
            SUM  = MATMOY(JIND+I)
            DO 111 K=1,I-1
               SUM = SUM - MAT2(IIND +K)*MAT2(JIND +K)
111         CONTINUE
            IF(I.EQ.J) THEN
               IF(SUM.LE.0.D0) THEN
                  CALL UTMESS('F','GEMATG',
     +                        'MATRICE MOYENNE NON DEFINIE POSITIVE')
               ENDIF
               TLII = SQRT(SUM)
               MAT2(IIND+I) = TLII
            ELSE
               MAT2(I+JIND) = SUM / TLII
            ENDIF
112      CONTINUE
113   CONTINUE
C
C --- CALCUL DE LA MATRICE ALEATOIRE 
C
      DO 210 J=1,N
         JIND=J*(J-1)/2
         DO 210 I=1,J
            IIND = I*(I-1) / 2
            SUM  = 0.D0
            DO 207 L=I,J
               LIND = L*(L-1) / 2
               DO 207 K=1,I
                  SUM = SUM + MAT2(IIND+K)*MAT2(JIND+L)*MAT1(LIND+K)
207         CONTINUE
            DO 208 L=1,I-1
               LIND = L*(L-1) / 2
               DO 208 K=1,L
                 SUM = SUM + MAT2(IIND+K)*MAT2(JIND+L)*MAT1(LIND+K)
208         CONTINUE
            DO 209 K=1, I
               KIND = K*(K-1) / 2
               DO 209 L=1, K-1
                 SUM = SUM + MAT2(IIND+K)*MAT2(JIND+L)*MAT1(KIND+L)
209         CONTINUE
            MAT(JIND+I) = SUM
210   CONTINUE
C
      CALL JEDEMA()
      END
