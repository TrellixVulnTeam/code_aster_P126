      SUBROUTINE DXEFGI(NOMTE,XYZL,PGL,EPSINI,SIGT)
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
      IMPLICIT REAL*8 (A-H,O-Z)
      CHARACTER*16 NOMTE
      REAL*8 XYZL(3,1),PGL(3,1)
      REAL*8 EPSINI(6)
      REAL*8 SIGT(1)
C     ------------------------------------------------------------------
C --- EFFORTS GENERALISES D'ORIGINE THERMIQUE AUX POINTS D'INTEGRATION
C --- POUR LES ELEMENTS COQUES A FACETTES PLANES :
C --- DST, DKT, DSQ, DKQ, Q4G
C --- CALCULES A PARTIR D'UN CHAMP DE DEFORMATIONS INITIALES QUI EST
C --- POUR L'INSTANT CONSTANT PAR ELEMENT ET QUI NE PREND PAS EN
C --- COMPTE LES DEFORMATIONS INITIALES DE CISAILLEMENT TRANSVERSE.
C     ------------------------------------------------------------------
C     IN  NOMTE        : NOM DU TYPE D'ELEMENT
C     IN  XYZL(3,NNO)  : COORDONNEES DES CONNECTIVITES DE L'ELEMENT
C                        DANS LE REPERE LOCAL DE L'ELEMENT
C     IN  PGL(3,3)     : MATRICE DE PASSAGE DU REPERE GLOBAL AU REPERE
C                        LOCAL
C     IN  EPSINI(6)    : DEFORMATIONS INITIALES CONSTANTES SUR L'ELEMENT
C                        DANS L'ORDRE : EPXX, EPYY, EPXY, KXX, KYY, KXY
C     OUT SIGT(1)      : EFFORTS  GENERALISES D'ORIGINE THERMIQUE
C                        AUX POINTS D'INTEGRATION
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
      INTEGER MULTIC
      REAL*8 DF(3,3),DM(3,3),DMF(3,3),DC(2,2),DCI(2,2),DMC(3,2),DFC(3,2)
      REAL*8 KXX,KYY,KXY,T2EV(4),T2VE(4),T1VE(9)
      LOGICAL GRILLE, ELASCO
C     ------------------------------------------------------------------

C --- INITIALISATIONS :
C     -----------------
      ZERO = 0.0D0

      DO 10 I = 1,32
        SIGT(I) = ZERO
   10 CONTINUE

      GRILLE = .FALSE.
      IF (NOMTE(1:8).EQ.'MEGRDKT ')  GRILLE = .TRUE.

      IF (NOMTE(1:8).EQ.'MEDKTR3 ' .OR. NOMTE(1:8).EQ.'MEDSTR3 ' .OR.
     &    NOMTE(1:8).EQ.'MEGRDKT ' .OR. NOMTE(1:8).EQ.'MEDKTG3 ') THEN

        NPG = 3
        NNO = 3

      ELSE IF (NOMTE(1:8).EQ.'MEDKQU4 ' .OR.
     &         NOMTE(1:8).EQ.'MEDSQU4 ' .OR.
     &         NOMTE(1:8).EQ.'MEQ4QU4 ' .OR.
     &         NOMTE(1:8).EQ.'MEDKQG4 ') THEN
        NPG = 4
        NNO = 4

      ELSE
        CALL U2MESK('F','ELEMENTS_14',1,NOMTE(1:8))
      END IF

C --- CALCUL DES MATRICES DE HOOKE DE FLEXION, MEMBRANE,
C --- MEMBRANE-FLEXION, CISAILLEMENT, CISAILLEMENT INVERSE
C     ----------------------------------------------------

      CALL DXMATE('RIGI',DF,DM,DMF,DC,DCI,DMC,DFC,NNO,PGL,MULTIC,GRILLE,
     &                                         ELASCO,T2EV,T2VE,T1VE)

C --- CHOIX DE NOTATIONS PLUS EXPLICITES POUR LES DEFORMATIONS
C --- INITIALES
C     ---------
      EPXX = EPSINI(1)
      EPYY = EPSINI(2)
      EPXY = EPSINI(3)
      KXX  = EPSINI(4)
      KYY  = EPSINI(5)
      KXY  = EPSINI(6)

C --- BOUCLE SUR LES POINTS D'INTEGRATION
C     -----------------------------------
      DO 20 IGAU = 1,NPG

        SIGT(1+8* (IGAU-1)) = DM(1,1)*EPXX + DM(1,2)*EPYY + DM(1,3)*EPXY
        SIGT(2+8* (IGAU-1)) = DM(2,1)*EPXX + DM(2,2)*EPYY + DM(2,3)*EPXY
        SIGT(3+8* (IGAU-1)) = DM(3,1)*EPXX + DM(3,2)*EPYY + DM(3,3)*EPXY

        SIGT(4+8* (IGAU-1)) = DF(1,1)*KXX + DF(1,2)*KYY + DF(1,3)*KXY
        SIGT(5+8* (IGAU-1)) = DF(2,1)*KXX + DF(2,2)*KYY + DF(2,3)*KXY
        SIGT(6+8* (IGAU-1)) = DF(3,1)*KXX + DF(3,2)*KYY + DF(3,3)*KXY

        SIGT(7+8* (IGAU-1)) = ZERO
        SIGT(8+8* (IGAU-1)) = ZERO
   20 CONTINUE

      END
