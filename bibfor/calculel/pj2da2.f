      SUBROUTINE  PJ2DA2(INO2,GEOM2,I,GEOM1,TRIA3,COBARY,D2,SURF)
      IMPLICIT NONE
      REAL*8  COBARY(3),GEOM1(*),GEOM2(*),D2,SURF
      INTEGER INO2,I,TRIA3(*)
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 12/05/99   AUTEUR VABHHTS J.PELLET 
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

C     BUT :
C       DETERMINER LA DISTANCE D2 ENTRE LE NOEUD INO2 ET LE TRIA3 I.
C       DETERMINER LES COORDONNEES BARYCENTRIQUES
C       DU POINT DE I LE PLUS PROCHE DE INO2.
C
C  IN   INO2       I  : NUMERO DU NOEUD DE M2 CHERCHE
C  IN   GEOM2(*)   R  : COORDONNEES DES NOEUDS DU MAILLAGE M2
C  IN   GEOM1(*)   R  : COORDONNEES DES NOEUDS DU MAILLAGE M1
C  IN   I          I  : NUMERO DU TRIA3 CANDIDAT
C  IN   TRIA3(*)   I  : OBJET '&&PJXXCO.TRIA3'
C  OUT  COBARY(3)  R  : COORDONNEES BARYCENTRIQUES DE INO2 PROJETE SUR I
C  OUT  D2         R  : CARRE DE LA DISTANCE ENTRE I ET INO2
C  OUT  SURF       R  : SURFACE DU TRIA3 I


C ----------------------------------------------------------------------
      CHARACTER*8   KB
      REAL*8 X1,Y1,X2,Y2,X3,Y3,XP,YP,XM,YM
      REAL*8 KSI,DIST,R8MAEM
      REAL*8 V1(2),V2(2),V3(2),P(2),M(2)
C DEB ------------------------------------------------------------------
      XM=GEOM2(3*(INO2-1)+1)
      YM=GEOM2(3*(INO2-1)+2)

      X1=GEOM1(3*(TRIA3(1+4*(I-1)+1)-1)+1)
      Y1=GEOM1(3*(TRIA3(1+4*(I-1)+1)-1)+2)
      X2=GEOM1(3*(TRIA3(1+4*(I-1)+2)-1)+1)
      Y2=GEOM1(3*(TRIA3(1+4*(I-1)+2)-1)+2)
      X3=GEOM1(3*(TRIA3(1+4*(I-1)+3)-1)+1)
      Y3=GEOM1(3*(TRIA3(1+4*(I-1)+3)-1)+2)


      V1(1)=X3-X2
      V1(2)=Y3-Y2
      V2(1)=X1-X3
      V2(2)=Y1-Y3
      V3(1)=X2-X1
      V3(2)=Y2-Y1

      SURF=ABS(V2(1)*V3(2)-V2(2)*V3(1))
      D2=R8MAEM()

C     COTE 1 (2->3):
C     --------------
      M(1)= XM-X2
      M(2)= YM-Y2
      KSI=(M(1)*V1(1)+M(2)*V1(2))/(V1(1)*V1(1)+V1(2)*V1(2))
      IF (KSI.GE.1.D0) THEN
        KSI=1.D0
      ELSE IF (KSI.LE.0.D0) THEN
        KSI=0.D0
      END IF
      XP=KSI*X3+(1.D0-KSI)*X2
      YP=KSI*Y3+(1.D0-KSI)*Y2
      DIST=(XP-XM)*(XP-XM)+(YP-YM)*(YP-YM)
      IF (DIST.LT.D2) THEN
        COBARY(1)=0.D0
        COBARY(2)=1.D0-KSI
        COBARY(3)=KSI
        D2=DIST
      END IF


C     COTE 2 (3->1):
C     --------------
      M(1)= XM-X3
      M(2)= YM-Y3
      KSI=(M(1)*V2(1)+M(2)*V2(2))/(V2(1)*V2(1)+V2(2)*V2(2))
      IF (KSI.GE.1.D0) THEN
        KSI=1.D0
      ELSE IF (KSI.LE.0.D0) THEN
        KSI=0.D0
      END IF
      XP=KSI*X1+(1.D0-KSI)*X3
      YP=KSI*Y1+(1.D0-KSI)*Y3
      DIST=(XP-XM)*(XP-XM)+(YP-YM)*(YP-YM)
      IF (DIST.LT.D2) THEN
        COBARY(2)=0.D0
        COBARY(3)=1.D0-KSI
        COBARY(1)=KSI
        D2=DIST
      END IF


C     COTE 3 (1->2):
C     --------------
      M(1)= XM-X1
      M(2)= YM-Y1
      KSI=(M(1)*V3(1)+M(2)*V3(2))/(V3(1)*V3(1)+V3(2)*V3(2))
      IF (KSI.GE.1.D0) THEN
        KSI=1.D0
      ELSE IF (KSI.LE.0.D0) THEN
        KSI=0.D0
      END IF
      XP=KSI*X2+(1.D0-KSI)*X1
      YP=KSI*Y2+(1.D0-KSI)*Y1
      DIST=(XP-XM)*(XP-XM)+(YP-YM)*(YP-YM)
      IF (DIST.LT.D2) THEN
        COBARY(3)=0.D0
        COBARY(1)=1.D0-KSI
        COBARY(2)=KSI
        D2=DIST
      END IF

      END
