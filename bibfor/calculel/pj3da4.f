      SUBROUTINE  PJ3DA4(M,A,B,LA,LB,D2)
      IMPLICIT NONE
      REAL*8  M(3),A(3),B(3),D2,LA,LB
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 06/04/98   AUTEUR VABHHTS J.PELLET 
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
C BUT :
C   TROUVER LES COORDONNEES BARYCENTRIQUES (LA,LB) DU POINT P
C   LE PLUS PROCHE DE M SUR UN SEGMENT (A,B) .
C
C  IN   M(3)    R : COORDONNEES DE M
C  IN   A(3)    R : COORDONNEES DE A
C  IN   B(3)    R : COORDONNEES DE B

C  OUT  D2      R  : CARRE DE LA DISTANCE ENTRE M ET P
C  OUT  LA,LB   R  : COORDONNEES BARYCENTRIQUES DE P SUR AB


C ----------------------------------------------------------------------
      INTEGER K
      REAL*8 P(3),A1,A2
      REAL*8 AB(3),AM(3)
C DEB ------------------------------------------------------------------
      DO 1,K=1,3
        AB(K)=B(K)-A(K)
        AM(K)=M(K)-A(K)
1     CONTINUE

      A1= AM(1)*AB(1)+AM(2)*AB(2)+AM(3)*AB(3)
      A2= AB(1)*AB(1)+AB(2)*AB(2)+AB(3)*AB(3)

      LB=A1/A2

      IF (LB.LT.0.D0) LB=0.D0
      IF (LB.GT.1.D0) LB=1.D0

      LA=1.D0-LB
      DO 2,K=1,3
        P(K)=LA*A(K)+LB*B(K)
        P(K)=M(K)-P(K)
2     CONTINUE
      D2=P(1)*P(1)+P(2)*P(2)+P(3)*P(3)
      END
