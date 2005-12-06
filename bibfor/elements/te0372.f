      SUBROUTINE TE0372(OPTION,NOMTE)
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
C.......................................................................
      IMPLICIT REAL*8 (A-H,O-Z)

C     BUT: CALCUL DES MATRICES ELEMENTAIRES EN MECANIQUE
C          CORRESPONDANT A UN TERME D'AMORTISSEMENT EN ONDE INCIDENTE
C           IMPOSEE SUR DES FACES 1D D'ELEMENTS ISOPARAMETRIQUES 2D

C!          OPTION : 'ONDE_FLUI'

C     ENTREES  ---> OPTION : OPTION DE CALCUL
C          ---> NOMTE  : NOM DU TYPE ELEMENT
C.......................................................................

      CHARACTER*2 CODRET(2)
      CHARACTER*8 NOMRES(2)
      CHARACTER*16 NOMTE,OPTION
      REAL*8 NX,NY,POIDS
      REAL*8 VALRES(2),RHO,CELER
      INTEGER IPOIDS,IVF,IDFDE,IGEOM,IMATE
      INTEGER NDI,NNO,KP,NPG,IMATUU
      INTEGER LDEC,IONDE

C---------------- COMMUNS NORMALISES  JEVEUX  --------------------------
      COMMON /IVARJE/ZI(1)
      COMMON /RVARJE/ZR(1)
      COMMON /CVARJE/ZC(1)
      COMMON /LVARJE/ZL(1)
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      INTEGER ZI
      REAL*8 ZR
      COMPLEX*16 ZC
      LOGICAL ZL
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
C------------FIN  COMMUNS NORMALISES  JEVEUX  --------------------------

      CALL ELREF4(' ','RIGI',NDIM,NNO,NNOS,NPG,IPOIDS,IVF,IDFDE,JGANO)
      NDI = NNO* (2*NNO+1)
      CALL JEVECH('PGEOMER','L',IGEOM)
      CALL JEVECH('PMATERC','L',IMATE)
      CALL JEVECH('PONDECR','L',IONDE)
      CALL JEVECH('PMATUUR','E',IMATUU)

      NOMRES(1) = 'RHO'
      NOMRES(2) = 'CELE_R'
      CALL RCVALA(ZI(IMATE),' ','FLUIDE',0,' ',RBID,2,NOMRES,VALRES,
     &           CODRET, 'FM')
      RHO = VALRES(1)
      CELER = VALRES(2)

      DO 10 I = 1,NDI
        ZR(IMATUU+I-1) = 0.D0
   10 CONTINUE

      IF (ZR(IONDE).EQ.0.D0) GO TO 60

      DO 50 KP = 1,NPG
        LDEC = (KP-1)*NNO

        NX = 0.0D0
        NY = 0.0D0

        CALL VFF2DN(NDIM,NNO,KP,IPOIDS,IDFDE,ZR(IGEOM),NX,NY,POIDS)

        IF (NOMTE(3:4).EQ.'AX') THEN
          R = 0.D0
          DO 20 I = 1,NNO
            R = R + ZR(IGEOM+2* (I-1))*ZR(IVF+LDEC+I-1)
   20     CONTINUE
          POIDS = POIDS*R
        END IF

        DO 40 I = 1,NNO
          DO 30 J = 1,I
            II = 2*I
            JJ = 2*J
            IJ = (II-1)*II/2 + JJ
            ZR(IMATUU+IJ-1) = ZR(IMATUU+IJ-1) -
     &                        POIDS*ZR(IVF+LDEC+I-1)*ZR(IVF+LDEC+J-1)*
     &                        RHO/CELER
   30     CONTINUE
   40   CONTINUE
   50 CONTINUE
   60 CONTINUE

      END
