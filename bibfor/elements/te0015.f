      SUBROUTINE TE0015(OPTION,NOMTE)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 29/04/2004   AUTEUR JMBHH01 J.M.PROIX 
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
C (AT YOUR OPTION) ANY LATER VERSION.

C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.

C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
      IMPLICIT NONE
      CHARACTER*16 NOMTE,OPTION
C.......................................................................

C     BUT: CALCUL DES VECTEURS ELEMENTAIRES EN MECANIQUE
C          ELEMENTS ISOPARAMETRIQUES 3D

C          OPTION : 'CHAR_MECA_PESA_R '

C     ENTREES  ---> OPTION : OPTION DE CALCUL
C          ---> NOMTE  : NOM DU TYPE ELEMENT
C.......................................................................


      CHARACTER*2 CODRET
      CHARACTER*16 PHENOM
      REAL*8 R8BID,RHO,COEF
      REAL*8 DFDX(27),DFDY(27),DFDZ(27),POIDS
      INTEGER IPOIDS,IVF,IDFDE,IGEOM
      INTEGER JGANO,IMATE,IPESA,IVECTU,NNOS
      INTEGER NDIM,NNO,NPG,NDL,KP,L,I,II,J


C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------

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

C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------


      CALL ELREF4(' ','RIGI',NDIM,NNO,NNOS,NPG,IPOIDS,IVF,IDFDE,JGANO)

      CALL JEVECH('PGEOMER','L',IGEOM)
      CALL JEVECH('PMATERC','L',IMATE)
      CALL JEVECH('PPESANR','L',IPESA)
      CALL JEVECH('PVECTUR','E',IVECTU)

      CALL RCCOMA(ZI(IMATE),'ELAS',PHENOM,CODRET)
      CALL RCVALA(ZI(IMATE),' ',PHENOM,1,' ',R8BID,1,'RHO',RHO,
     &            CODRET,'FM')

      NDL = 3*NNO
      DO 10 I = 1,NDL
        ZR(IVECTU+I-1) = 0.0D0
   10 CONTINUE

C    BOUCLE SUR LES POINTS DE GAUSS

      DO 40 KP = 1,NPG

        L = (KP-1)*NNO
        CALL DFDM3D ( NNO, KP, IPOIDS, IDFDE,
     &                ZR(IGEOM), DFDX, DFDY, DFDZ, POIDS )

        COEF = RHO*POIDS*ZR(IPESA)

        DO 30 I = 1,NNO
          II = 3* (I-1)

          DO 20 J = 1,3
            ZR(IVECTU+II+J-1) = ZR(IVECTU+II+J-1) +
     &                          COEF*ZR(IVF+L+I-1)*ZR(IPESA+J)
   20     CONTINUE

   30   CONTINUE

   40 CONTINUE


   50 CONTINUE
      END
