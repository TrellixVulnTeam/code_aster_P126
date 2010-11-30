      SUBROUTINE TRANLG (NB1,NDDLX,NDDLET,PLG,MATLOC,XR)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 15/10/96   AUTEUR SABHHLA A.LAULUSA 
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
      INTEGER NB1,NDDLET
      REAL*8 XR(*)
      REAL*8 MATLOC(NDDLX,NDDLX), PLG(9,3,3)
      REAL*8 MATXP(48,48),MATX(51,51)
      REAL*8 KB12PT(48,3),KB21PG(3,48),KB22PT(3,3)
C
      NDDLE=6*NB1
C
C     CONSTRUCTION DE LA MATRICE GLOBALE K = TLAMBDA * KB * LAMBDA
C
C             KB11 KB12                 P   0  
C       KB =                  LAMBDA =         
C             KB21 KB22                 0   P9 
C
C       KB11(NDDLE,NDDLE) , KB12(NDDLE,3) , KB21(3,NDDLE) , KB22(3,3)
C          P(NDDLE,NDDLE) ,   P9(3,3)
C     
C          P = PLG (IB,3,3) IB=1,NB1
C
C     CALCULS DU BLOC PRINCIPAL TP * KB11 * P
C
C     CONSTRUCTION DE LA MATRICE MATXP = MATLOC *  PLG  : (NDDLE,NDDLE)
C
      DO 30 I1=1,NDDLE
      DO 40 JB=1,NB1
      DO 50  J=1,3
         J1=3*(2*JB-2)+J
         MATXP(I1,J1)=MATLOC(I1,J1)
C
         J2=3*(2*JB-1)+J
         MATXP(I1,J2)=0.D0
      DO 60  K=1,3
         K1=3*(2*JB-1)+K
         MATXP(I1,J2)=MATXP(I1,J2)+MATLOC(I1,K1)*PLG(JB,K,J)
 60   CONTINUE
 50   CONTINUE
 40   CONTINUE
 30   CONTINUE
C
C   CONSTRUCTION DE LA MATRICE MATX = PLGT * MATLOC * PLG (NDDLET,NDDLE)
C
C   CONSTRUCTION EN PREMIER DE PT * KB11 * P (NDDLE,NDDLE)
C
      DO 100 IB=1,NB1
      DO 110  I=1,3
         I1=3*(2*IB-2)+I
C
         I2=3*(2*IB-1)+I
      DO 120 J1=1,NDDLE
         MATX(I1,J1)=MATXP(I1,J1)
C
         MATX(I2,J1)=0.D0
      DO 130  K=1,3
         K1=3*(2*IB-1)+K
CCC      MATX(I2,J1)=MATX(I2,J1)+PLGT(IB,I,K)*MATXP(K1,J1)
         MATX(I2,J1)=MATX(I2,J1)+PLG (IB,K,I)*MATXP(K1,J1)
 130  CONTINUE
 120  CONTINUE
 110  CONTINUE
 100  CONTINUE
C
      NB2=NB1+1
C
C     CALCULS DES SOUS MATRICES POUR FORMER LA MATRICE COMPLETE K 
C
C     CALCULS DE KB * LAMBDA
C
      DO 200 I=1,NDDLE
      DO 210 J=1,3
         KB12PT(I,J)=0.D0
      DO 220 K=1,3
         K1=NDDLE+K
         KB12PT(I,J)=KB12PT(I,J)+MATLOC(I,K1)*PLG(NB2,K,J)
 220  CONTINUE
 210  CONTINUE
 200  CONTINUE
C
      DO 230  I=1,3
         I1=NDDLE+I
      DO 240 JB=1,NB1
      DO 250  J=1,3
         J1=3*(2*JB-2)+J
         KB21PG(I,J1)=MATLOC(I1,J1)
C
         J2=3*(2*JB-1)+J
         KB21PG(I,J2)=0.D0
      DO 260  K=1,3
         K1=3*(2*JB-1)+K
         KB21PG(I,J2)=KB21PG(I,J2)+MATLOC(I1,K1)*PLG(JB,K,J)
 260  CONTINUE
 250  CONTINUE
 240  CONTINUE
 230  CONTINUE
C
      DO 270 I=1,3
         I1=NDDLE+I
      DO 280 J=1,3
         KB22PT(I,J)=0.D0
      DO 290 K=1,3
         K1=NDDLE+K
         KB22PT(I,J)=KB22PT(I,J)+MATLOC(I1,K1)*PLG(NB2,K,J)
 290  CONTINUE
 280  CONTINUE
 270  CONTINUE
C
C     CALCULS DE K = TLAMBDA * KB * LAMBDA
C
      DO 300 IB=1,NB1
      DO 310  I=1,3
         I1=3*(2*IB-2)+I
C
         I2=3*(2*IB-1)+I
      DO 320 J=1,3
         J1=NDDLE+J
         MATX(I1,J1)=KB12PT(I1,J)
C
         MATX(I2,J1)=0.D0
      DO 330 K=1,3
         K1=3*(2*IB-1)+K
         MATX(I2,J1)=MATX(I2,J1)+PLG(IB,K,I)*KB12PT(K1,J)
 330  CONTINUE
 320  CONTINUE
 310  CONTINUE
 300  CONTINUE
C
      DO 340 I=1,3
         I1=NDDLE+I
      DO 350 J=1,NDDLE
         MATX(I1,J)=0.D0
      DO 360 K=1,3
         MATX(I1,J)=MATX(I1,J)+PLG(NB2,K,I)*KB21PG(K,J)
 360  CONTINUE
 350  CONTINUE
 340  CONTINUE
C
      DO 370 I=1,3
         I1=NDDLE+I
      DO 380 J=1,3
         J1=NDDLE+J
         MATX(I1,J1)=0.D0
      DO 390 K=1,3
         MATX(I1,J1)=MATX(I1,J1)+PLG(NB2,K,I)*KB22PT(K,J)
 390  CONTINUE
 380  CONTINUE
 370  CONTINUE
C
C     STOCKAGE DE LA PARTIE TRIANGULAIRE SUPERIEURE DANS LE TABLEAU XR
C
      KOMPT=0
      DO 140 J=1,NDDLET
      DO 150 I=1,J
         KOMPT=KOMPT+1
         XR(KOMPT)=MATX(I,J)
C        XR(KOMPT)=MATLOC(I,J)
 150  CONTINUE
 140  CONTINUE
C
      END
