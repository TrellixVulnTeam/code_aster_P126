      SUBROUTINE NMGEOM(NDIM, NNO, AXI, GRAND, GEOM, KPG, POIDSG, VFF,
     &                  DFDE, DFDN, DFDK, DEPL, POIDS, DFDI, F, EPS, R)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 14/05/96   AUTEUR D6BHHJP J.P.LEFEBVRE 
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.      
C ======================================================================
      IMPLICIT REAL*8 (A-H,O-Z)
C
      LOGICAL AXI, GRAND
      INTEGER NDIM, NNO, KPG
      REAL*8  POIDSG, VFF(NNO), DFDE(*), DFDN(*), DFDK(*)
      REAL*8  GEOM(NDIM,NNO), DFDI(NNO,NDIM), DEPL(NDIM,NNO)
      REAL*8  POIDS,F(3,3), EPS(6), R
C
C.......................................................................
C
C     BUT:  CALCUL DES ELEMENTS CINEMATIQUES (MATRICES F ET E, RAYON R)
C           EN UN POINT DE GAUSS (EVENTUELLEMENT EN GRANDES TRANSFORM.)
C
C IN  NDIM    : DIMENSION DE L'ESPACE
C IN  NNO     : NOMBRE DE NOEUDS DE L'ELEMENT
C IN  AXI     : INDICATEUR SI AXISYMETRIQUE
C IN  GRAND   : INDICATEUR SI GRANDES TRANSFORMATIONS
C IN  GEOM    : COORDONEES DES NOEUDS
C IN  KPG     : NUMERO DU POINT DE GAUSS (POUR L'ACCES AUX FCT. FORMES)
C IN  POIDSG  : POIDS DU POINT DE GAUSS DE L'ELEMENT DE REFERENCE
C IN  VFF     : VALEUR DES FONCTIONS DE FORME (EN AXISYMETRIQUE)
C IN  DFDE    : DERIVEE DES FONCTIONS DE FORME DE REFERENCE (X)
C IN  DFDN    : DERIVEE DES FONCTIONS DE FORME DE REFERENCE (Y) (3D)
C IN  DFDK    : DERIVEE DES FONCTIONS DE FORME DE REFERENCE (Z)
C IN  DEPL    : DEPLACEMENT A PARTIR DE LA CONF DE REF
C OUT POIDS   : POIDS D'INTEGRATION (*R EN AXI)
C OUT DFDI    : DERIVEE DES FONCTIONS DE FORME
C OUT F       : GRADIENT DE LA TRANSFORMATION
C OUT EPS     : DEFORMATIONS
C OUT R       : DISTANCE DU POINT DE GAUSS A L'AXE (EN AXISYMETRIQUE)
C......................................................................
C
      LOGICAL TRIDIM
      INTEGER I,J,K,N,KK
      REAL*8  GRAD(3,3), EPSTAB(3,3), UR, TMP
      REAL*8  RAC2, KRON(3,3)
      DATA KRON/1.D0,0.D0,0.D0, 0.D0,1.D0,0.D0, 0.D0,0.D0,1.D0/
      RAC2 = SQRT(2.D0)
C
C
C - CALCUL DES DERIVEES DES FONCTIONS DE FORME ET JACOBIEN
      TRIDIM = (NDIM.EQ.3)
      IF (TRIDIM) THEN
        KK = (KPG-1)*NNO*3 +1
        CALL DFDM3D (NNO,POIDSG,DFDE(KK),DFDN(KK),DFDK(KK),
     &               GEOM,DFDI(1,1),DFDI(1,2),DFDI(1,3),POIDS)
      ELSE
        KK=(KPG-1)*NNO + 1
        CALL DFDM2D ( NNO,POIDSG,DFDE(KK),DFDK(KK),GEOM,DFDI(1,1),
     &                DFDI(1,2),POIDS )
      ENDIF
C
C
C - CALCUL DE LA DISTANCE A L'AXE (AXISYMETRIQUE) ET DU DEPL. RADIAL
      IF (AXI) THEN
        R  = 0.D0
        UR = 0.D0
        DO 10 N=1,NNO
          R  = R  + VFF(N)*GEOM(1,N)
          UR = UR + VFF(N)*DEPL(1,N)
10      CONTINUE
        POIDS = POIDS*R
      ENDIF
C
C - CALCUL DES GRADIENT : GRAD(U) ET F
C
      DO 13 I=1,3
        DO 16 J=1,3
          F(I,J) = KRON(I,J)
          GRAD(I,J) = 0.D0
16      CONTINUE
13    CONTINUE
C
      IF (TRIDIM) THEN
        DO 20 N=1,NNO
          DO 22 I=1,3
            DO 24 J=1,3
              GRAD(I,J) = GRAD(I,J) + DFDI(N,J)*DEPL(I,N)
 24         CONTINUE
 22       CONTINUE
 20     CONTINUE
      ELSE
        DO 30 N=1,NNO
          DO  32 I = 1,2
            DO 34  J = 1,2
              GRAD(I,J) = GRAD(I,J) + DFDI(N,J)*DEPL(I,N)
 34         CONTINUE
 32       CONTINUE
 30     CONTINUE
      ENDIF
C
      IF (GRAND) THEN
        DO 40 I=1,3
          DO 42 J=1,3
            F(I,J) = F(I,J) + GRAD(I,J)
 42       CONTINUE
 40     CONTINUE
        IF (AXI) F(3,3) = 1.D0 + UR/R
      ENDIF
C
C - CALCUL DES DEFORMATIONS : E
C
      DO 90 I=1,NDIM
        DO 100 J=1,I
          TMP = GRAD(I,J) + GRAD(J,I)
C
          IF (GRAND) THEN
            DO 110 K=1,NDIM
              TMP = TMP + GRAD(K,I)*GRAD(K,J)
110         CONTINUE
          ENDIF
C
          EPSTAB(I,J) = 0.5D0*TMP
C
100     CONTINUE
90    CONTINUE
C
      EPS(1) = EPSTAB(1,1)
      EPS(2) = EPSTAB(2,2)
      EPS(4) = EPSTAB(2,1)*RAC2
C
      IF (TRIDIM) THEN
        EPS(3) = EPSTAB(3,3)
        EPS(5) = EPSTAB(3,1)*RAC2
        EPS(6) = EPSTAB(3,2)*RAC2
      ELSE IF (AXI) THEN
        EPS(3) = UR/R
        IF (GRAND) EPS(3) = EPS(3) + 0.5D0*UR*UR/(R*R)
      ELSE
        EPS(3) = 0.D0
      ENDIF
C
      END
