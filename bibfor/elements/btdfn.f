      SUBROUTINE BTDFN(IND,NB1,NB2,XI,KSI3S2,INTSN,XR,EPAIS,VECTPT,
     &                                                      HSJ1FX,BTDF)
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
C
      IMPLICIT REAL*8 (A-H,O-Z)
      INTEGER NB1,NB2,INTE,INTSN
      REAL*8 XR(*),EPAIS,VECTPT(9,2,3)
      REAL*8 HSJ1FX(3,9),BTDF(3,42)
      REAL*8 DNSDSF(9,42)
      REAL*8 KSI3S2
C
      IF (IND.EQ.1) THEN
         L1=459
         L2=540
         L3=621
      ELSE IF (IND.EQ.0) THEN
         L1=351
         L2=387
         L3=423
      ENDIF
C
      DO 15 I=1,9
      DO 16 J=1,5*NB1+2
         DNSDSF(I,J)=0.D0
         IF (I.LE.3) BTDF(I,J)=0.D0
 16   CONTINUE
 15   CONTINUE
C
         INTSN1=9*(INTSN-1)
C
C                         DN   
C     CONSTRUCTION DE   ------    AUX PTS DE GAUSS NORMAL
C                        DQSI  F
C
         I3=L1+INTSN1
         I4=L2+INTSN1
         I5=L3+INTSN1
      DO 30 J=1,NB1
         J1=5*(J-1)
         DNSDSF(1,J1+4)=-KSI3S2*XR(I4+J)*EPAIS*VECTPT(J,2,1)
         DNSDSF(1,J1+5)= KSI3S2*XR(I4+J)*EPAIS*VECTPT(J,1,1)
C
         DNSDSF(2,J1+4)=-KSI3S2*XR(I5+J)*EPAIS*VECTPT(J,2,1)
         DNSDSF(2,J1+5)= KSI3S2*XR(I5+J)*EPAIS*VECTPT(J,1,1)
C
         DNSDSF(3,J1+4)=-XR(I3+J)/2*EPAIS*VECTPT(J,2,1)
         DNSDSF(3,J1+5)= XR(I3+J)/2*EPAIS*VECTPT(J,1,1)
C
         DNSDSF(4,J1+4)=-KSI3S2*XR(I4+J)*EPAIS*VECTPT(J,2,2)
         DNSDSF(4,J1+5)= KSI3S2*XR(I4+J)*EPAIS*VECTPT(J,1,2)
C
         DNSDSF(5,J1+4)=-KSI3S2*XR(I5+J)*EPAIS*VECTPT(J,2,2)
         DNSDSF(5,J1+5)= KSI3S2*XR(I5+J)*EPAIS*VECTPT(J,1,2)
C
         DNSDSF(6,J1+4)=-XR(I3+J)/2*EPAIS*VECTPT(J,2,2)
         DNSDSF(6,J1+5)= XR(I3+J)/2*EPAIS*VECTPT(J,1,2)
C
         DNSDSF(7,J1+4)=-KSI3S2*XR(I4+J)*EPAIS*VECTPT(J,2,3)
         DNSDSF(7,J1+5)= KSI3S2*XR(I4+J)*EPAIS*VECTPT(J,1,3)
C
         DNSDSF(8,J1+4)=-KSI3S2*XR(I5+J)*EPAIS*VECTPT(J,2,3)
         DNSDSF(8,J1+5)= KSI3S2*XR(I5+J)*EPAIS*VECTPT(J,1,3)
C
         DNSDSF(9,J1+4)=-XR(I3+J)/2*EPAIS*VECTPT(J,2,3)
         DNSDSF(9,J1+5)= XR(I3+J)/2*EPAIS*VECTPT(J,1,3)
 30   CONTINUE
C
         DNSDSF(1,5*NB1+1)=-KSI3S2*XR(I4+NB2)*EPAIS*VECTPT(NB2,2,1)
         DNSDSF(1,5*NB1+2)= KSI3S2*XR(I4+NB2)*EPAIS*VECTPT(NB2,1,1)
C
         DNSDSF(2,5*NB1+1)=-KSI3S2*XR(I5+NB2)*EPAIS*VECTPT(NB2,2,1)
         DNSDSF(2,5*NB1+2)= KSI3S2*XR(I5+NB2)*EPAIS*VECTPT(NB2,1,1)
C
         DNSDSF(3,5*NB1+1)=-XR(I3+J)/2*EPAIS*VECTPT(NB2,2,1)
         DNSDSF(3,5*NB1+2)= XR(I3+J)/2*EPAIS*VECTPT(NB2,1,1)
C
         DNSDSF(4,5*NB1+1)=-KSI3S2*XR(I4+NB2)*EPAIS*VECTPT(NB2,2,2)
         DNSDSF(4,5*NB1+2)= KSI3S2*XR(I4+NB2)*EPAIS*VECTPT(NB2,1,2)
C
         DNSDSF(5,5*NB1+1)=-KSI3S2*XR(I5+NB2)*EPAIS*VECTPT(NB2,2,2)
         DNSDSF(5,5*NB1+2)= KSI3S2*XR(I5+NB2)*EPAIS*VECTPT(NB2,1,2)
C
         DNSDSF(6,5*NB1+1)=-XR(I3+J)/2*EPAIS*VECTPT(NB2,2,2)
         DNSDSF(6,5*NB1+2)= XR(I3+J)/2*EPAIS*VECTPT(NB2,1,2)
C
         DNSDSF(7,5*NB1+1)=-KSI3S2*XR(I4+NB2)*EPAIS*VECTPT(NB2,2,3)
         DNSDSF(7,5*NB1+2)= KSI3S2*XR(I4+NB2)*EPAIS*VECTPT(NB2,1,3)
C
         DNSDSF(8,5*NB1+1)=-KSI3S2*XR(I5+NB2)*EPAIS*VECTPT(NB2,2,3)
         DNSDSF(8,5*NB1+2)= KSI3S2*XR(I5+NB2)*EPAIS*VECTPT(NB2,1,3)
C
         DNSDSF(9,5*NB1+1)=-XR(I3+J)/2*EPAIS*VECTPT(NB2,2,3)
         DNSDSF(9,5*NB1+2)= XR(I3+J)/2*EPAIS*VECTPT(NB2,1,3)
C
C     CONSTRUCTION DE BTILDF = HFM * S * JTILD-1 * DNSDSF  : (3,5*NB1+2)
C
      DO 40  I=1,3
      DO 50 JB=1,NB1
      DO 60  J=4,5
         J1=J+5*(JB-1)
         BTDF(I,J1)=0.D0
      DO 70  K=1,9
         BTDF(I,J1)=BTDF(I,J1)+HSJ1FX(I,K)*DNSDSF(K,J1)
 70   CONTINUE
 60   CONTINUE
 50   CONTINUE
C
      DO 80  J=1,2
         J1=J+5*NB1
         BTDF(I,J1)=0.D0
      DO 90  K=1,9
         BTDF(I,J1)=BTDF(I,J1)+HSJ1FX(I,K)*DNSDSF(K,J1)
 90   CONTINUE
 80   CONTINUE
 40   CONTINUE
C
      END
