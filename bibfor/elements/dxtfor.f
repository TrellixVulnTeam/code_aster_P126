      SUBROUTINE DXTFOR(TYPELE,GLOBAL,XYZL,PGL,FOR,VECL)
C MODIF ELEMENTS  DATE 22/11/2001   AUTEUR VABHHTS J.PELLET 
C ======================================================================
C            CONFIGURATION MANAGEMENT OF EDF VERSION
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
      CHARACTER*8 TYPELE
      LOGICAL GLOBAL
      REAL*8 XYZL(3,*),PGL(3,*)
      REAL*8 FOR(6,3)
      REAL*8 VECL(*)
C     ------------------------------------------------------------------
C     CHARGEMENT FORCE_FACE DES ELEMENTS DE PLAQUE DKT ET DST
C     ------------------------------------------------------------------
C     IN  TYPELE : TYPE DE L'ELEMENT
C     IN  GLOBAL : VARIABLE LOGIQUE DE REPERE GLOBAL OU LOCAL
C     IN  XYZL   : COORDONNEES LOCALES DES TROIS NOEUDS
C     IN  PGL    : MATRICE DE PASSAGE GLOBAL - LOCAL
C     IN  FOR    : FORCE APPLIQUEE SUR LA FACE
C     OUT VECL   : CHARGEMENT NODAL RESULTANT
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
      CHARACTER*32 JEXNUM,JEXNOM,JEXR8,JEXATR
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------
      CHARACTER*24 DESR
      REAL*8 AIRE,C1,C2
      REAL*8 L4,L5,L6
      REAL*8 A1,A2,A3,PI,R8PI
      REAL*8 FX,FY
C     ------------------ PARAMETRAGE TRIANGLE --------------------------
      INTEGER NPG,NC,NNO
      INTEGER LJACO,LTOR,LQSI,LETA,LWGT,LXYC,LCOTE,LCOS,LSIN
      INTEGER LAIRE,LT1VE,LT2VE
      PARAMETER (NPG=3)
      PARAMETER (NNO=3)
      PARAMETER (NC=3)
      PARAMETER (LJACO=2)
      PARAMETER (LTOR=LJACO+4)
      PARAMETER (LQSI=LTOR+1)
      PARAMETER (LETA=LQSI+NPG+NNO)
      PARAMETER (LWGT=LETA+NPG+NNO)
      PARAMETER (LXYC=LWGT+NPG)
      PARAMETER (LCOTE=LXYC+2*NC)
      PARAMETER (LCOS=LCOTE+NC)
      PARAMETER (LSIN=LCOS+NC)
      PARAMETER (LAIRE=LSIN+NC)
      PARAMETER (LT1VE=LAIRE+1)
      PARAMETER (LT2VE=LT1VE+9)
C     ------------------------------------------------------------------
      CALL JEMARQ()
      PI = R8PI()

      DESR = '&INEL.'//TYPELE//'.DESR'
      CALL JEVETE(DESR,' ',LZR)

C     ----- CALCUL DES GRANDEURS GEOMETRIQUES SUR LE TRIANGLE ----------
      CALL GTRIA3(XYZL,ZR(LZR))
      CALL DXREPE(NNO,PGL,ZR(LZR))

      IF (.NOT.GLOBAL) THEN
        DO 10 I = 1,NNO
          FX = FOR(1,I)
          FY = FOR(2,I)
          FOR(1,I) = FX*ZR(LZR-1+LT2VE) + FY*ZR(LZR-1+LT2VE+2)
          FOR(2,I) = FX*ZR(LZR-1+LT2VE+1) + FY*ZR(LZR-1+LT2VE+3)
          FX = FOR(4,I)
          FY = FOR(5,I)
          FOR(4,I) = FX*ZR(LZR-1+LT2VE) + FY*ZR(LZR-1+LT2VE+2)
          FOR(5,I) = FX*ZR(LZR-1+LT2VE+1) + FY*ZR(LZR-1+LT2VE+3)
   10   CONTINUE
      END IF
      L4 = ZR(LZR-1+LCOTE)
      L5 = ZR(LZR-1+LCOTE+1)
      L6 = ZR(LZR-1+LCOTE+2)
      AIRE = ZR(LZR-1+LAIRE)
C     ---- CALCUL DES ANGLES DU TRIANGLE ---------
      A1 = TRIGOM('ACOS', (L4*L4+L6*L6-L5*L5)/ (2.D0*L4*L6))
      A2 = TRIGOM('ACOS', (L4*L4+L5*L5-L6*L6)/ (2.D0*L4*L5))
      A3 = PI - A1 - A2
      A1 = A1/PI
      A2 = A2/PI
      A3 = A3/PI

      DO 20 I = 1,6*NNO
        VECL(I) = 0.D0
   20 CONTINUE
      C1 = 1.D0/2.D0
      C2 = 1.D0/4.D0
      DO 30 I = 1,6
        VECL(I) = (C1*FOR(I,1)+C2*FOR(I,2)+C2*FOR(I,3))*AIRE*A1
        VECL(I+6) = (C2*FOR(I,1)+C1*FOR(I,2)+C2*FOR(I,3))*AIRE*A2
        VECL(I+12) = (C2*FOR(I,1)+C2*FOR(I,2)+C1*FOR(I,3))*AIRE*A3
   30 CONTINUE

      CALL JEDEMA()
      END
