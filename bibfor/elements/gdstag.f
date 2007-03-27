      SUBROUTINE GDSTAG (STOUDY,KP,NNO,AJACOB,EN,ENPRIM,X0K,TETAK,QIM,
     &         QIKM1,QIK,X0PG,TETAG,TETAPG,ROTM,ROTKM1,ROTK)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 28/03/2007   AUTEUR PELLET J.PELLET 
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
C
C FONCTION: POUR UN ELEMENT DE POUTRE EN GRAND DEPLACEMENT, CALCULE
C           CERTAINES GRANDEURS STATIQUES AUX POINTS DE GAUSS.
C
C     IN  : STOUDY    : 0 EN STATIQUE
C                       1 EN DYNAMIQUE
C           KP        : NUMERO DU POINT DE GAUSS
C           NNO       : NOMBRE DE NOEUDS
C           AJACOB    : JACOBIEN
C           EN        : FONCTIONS DE FORME
C           ENPRIM    : DERIVEES DES FONCTIONS DE FORME
C           X0K       : COORDONNEES ACTUALISEES DES NOEUDS
C           TETAK     : VECTEUR-INCREMENT DE ROTATION DES NOEUDS
C           QIM       : VECTEUR-ROTATION A L'INSTANT PRECEDENT
C           QIKM1     : VECTEUR-ROTATION A L'ITERATION PRECEDENTE
C           QIK       : VECTEUR-ROTATION ACTUEL
C
C     OUT, AU POINT DE GAUSS NUMERO KP:
C           X0PG      : DERIVEES DES COORDONNEES PAR RAP. A L'ABS. CURV.
C           TETAG     : VECTEUR-INCREMENT DE ROTATION
C           TETAPG    : DERIVEE DU PRECEDENT PAR RAP. A L'ABS. CURV.
C           ROTM      : MATRICE DE ROTATION A L'INSTANT PRECEDENT
C           ROTKM1    : MATRICE DE ROTATION A L'ITERATION PRECEDENTE
C           ROTK      : MATRICE DE ROTATION ACTUELLE
C ------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      REAL*8 EN(3,2),ENPRIM(3,2),X0K(3,3),TETAK(3,3),QIM(3,3),
     &QIKM1(3,3),QIK(3,3),TEMPN(3),X0PG(3),TETAG(3),TETAPG(3),ROTM(3,3),
     &ROTKM1(3,3),ROTK(3,3),QIGM(3),QIGKM1(3),QIGK(3)
C
C
      ZERO = 0.D0
      DEMI = 5.D-1
      UN   = 1.D0
      DO  1 IC=1,3
      X0PG(IC) = ZERO
      TETAG(IC) = ZERO
      TETAPG(IC) = ZERO
      QIGK(IC) = ZERO
    1 CONTINUE
      UNSURJ = UN / AJACOB
      DO  3 IC=1,3
      DO  2 NE=1,NNO
      X0PG(IC)    = X0PG(IC)  + UNSURJ*ENPRIM(NE,KP)*X0K(IC,NE)
      TETAG(IC)  = TETAG(IC)  + EN(NE,KP)*TETAK(IC,NE)
      TETAPG(IC) = TETAPG(IC) + UNSURJ*ENPRIM(NE,KP)*TETAK(IC,NE)
      QIGK(IC) = QIGK(IC) + EN(NE,KP)*QIK(IC,NE)
    2 CONTINUE
    3 CONTINUE
      CALL MAROTA (QIGK,ROTK)
C
      IF (STOUDY.LT.DEMI) GOTO 9999
C
      DO 11 IC=1,3
      QIGM  (IC) = ZERO
      QIGKM1 (IC) = ZERO
   11 CONTINUE
      DO 13 IC=1,3
      DO 12 NE=1,NNO
      QIGM  (IC) = QIGM  (IC) + EN(NE,KP)*QIM  (IC,NE)
      QIGKM1 (IC) = QIGKM1 (IC) + EN(NE,KP)*QIKM1 (IC,NE)
   12 CONTINUE
   13 CONTINUE
      CALL MAROTA (QIGM ,ROTM )
      CALL MAROTA (QIGKM1 ,ROTKM1 )
C
 9999 CONTINUE
      END
