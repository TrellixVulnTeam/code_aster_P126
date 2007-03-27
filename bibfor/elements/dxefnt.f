      SUBROUTINE DXEFNT(NOMTE,XYZL,PGL,SIGT)
      IMPLICIT REAL*8 (A-H,O-Z)
      REAL*8        XYZL(3,1),PGL(3,1),SIGT(1)
      LOGICAL       GRILLE,LTEATT
      CHARACTER*16  NOMTE
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
C     ------------------------------------------------------------------
C --- EFFORTS GENERALISES D'ORIGINE THERMIQUE AUX NOEUDS
C --- POUR LES ELEMENTS COQUES A FACETTES PLANES :
C --- DST, DKT, DSQ, DKQ, Q4G DUS :
C ---  .A UN CHAMP DE TEMPERATURES SUR LE PLAN MOYEN DONNANT
C ---        DES EFFORTS DE MEMBRANE
C ---  .A UN GRADIENT DE TEMPERATURES DANS L'EPAISSEUR DE LA COQUE
C     ------------------------------------------------------------------
C     IN  NOMTE        : NOM DU TYPE D'ELEMENT
C     IN  XYZL(3,NNO)  : COORDONNEES DES CONNECTIVITES DE L'ELEMENT
C                        DANS LE REPERE LOCAL DE L'ELEMENT
C     IN  PGL(3,3)     : MATRICE DE PASSAGE DU REPERE GLOBAL AU REPERE
C                        LOCAL
C     OUT SIGT(1)      : EFFORTS  GENERALISES D'ORIGINE THERMIQUE
C                        AUX NOEUDS
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
      CHARACTER*2 CODRET(56)
      CHARACTER*10 PHENOM
      REAL*8 DF(3,3),DM(3,3),DMF(3,3),DC(2,2),DCI(2,2)
      REAL*8 N(4),T2EV(4),T2VE(4),T1VE(9),TGINF(4),TGSUP(4),TGMOY(4)
      REAL*8 TSUP(4),TINF(4),TMOY(4)
      INTEGER MULTIC,IRET,NBCOU,JCOU,IMOY
C     ------------------------------------------------------------------

C --- INITIALISATIONS :
C     -----------------
      ZERO = 0.0D0

      DO 10 I = 1,32
        SIGT(I) = ZERO
   10 CONTINUE
      GRILLE= LTEATT(' ','GRILLE','OUI')
      CALL JEVECH('PNBSP_I','L',JCOU)
      NBCOU=ZI(JCOU)
      CALL RCVARC('F','TEMP','REF','NOEU',1,1,TREF,IRET)


      IF (NOMTE(1:8).EQ.'MEDKTR3 ' .OR. NOMTE(1:8).EQ.'MEDSTR3 ' .OR.
     &    NOMTE(1:8).EQ.'MEGRDKT ' .OR. NOMTE(1:8).EQ.'MEDKTG3 ') THEN
         NNO = 3
      ELSE IF (NOMTE(1:8).EQ.'MEDKQU4 ' .OR.
     &         NOMTE(1:8).EQ.'MEDKQG4 ' .OR.
     &         NOMTE(1:8).EQ.'MEDSQU4 ' .OR.
     &         NOMTE(1:8).EQ.'MEQ4QU4 ') THEN
         NNO = 4
      ELSE
         CALL U2MESK('F','ELEMENTS_14',1,NOMTE(1:8))
      END IF

C===============================================================
C          -- RECUPERATION DE LA TEMPERATURE  AUX NOEUDS
      IF (GRILLE) THEN
C UNE COUCHE AVEC UN SEUL POINT DANS L EPAISSEUR.
C LA TEMPERATURE EST IDENTIQUE
        DO 41 INO=1,NNO
          CALL RCVARC('F','TEMP','+','NOEU',INO,1,TINF(INO),IRET)
          TMOY(INO)=TINF(INO)
          TSUP(INO)=TINF(INO)
  41    CONTINUE
      ELSE
C COQUE MULTI-COUCHE.
C ON RECUPERE LA TEMPERATURE INFERIEURE, SUPERIEURE ET DANS LA FIBRE
C MOYENNE
        IMOY=(3*NBCOU+1)/2
        DO 42 INO = 1,NNO
          CALL RCVARC('F','TEMP','+','NOEU',INO,IMOY,TMOY(INO),IRET)
          CALL RCVARC('F','TEMP','+','NOEU',INO,NBCOU*3,TSUP(INO),IRET)
          CALL RCVARC('F','TEMP','+','NOEU',INO,1,TINF(INO),IRET)
  42    CONTINUE
      ENDIF

      CALL JEVECH('PMATERC','L',JMATE)
      CALL RCCOMA(ZI(JMATE),'ELAS',PHENOM,CODRET)

      IF ((PHENOM.EQ.'ELAS') .OR. (PHENOM.EQ.'ELAS_COQUE') .OR.
     &    (PHENOM.EQ.'ELAS_COQMU')) THEN

C --- RECUPERATION DE LA TEMPERATURE DE REFERENCE ET
C --- DE L'EPAISSEUR DE LA COQUE
C     --------------------------

        CALL JEVECH('PCACOQU','L',JCARA)
        EPAIS = ZR(JCARA)

C --- CALCUL DES MATRICES DE HOOKE DE FLEXION, MEMBRANE,
C --- MEMBRANE-FLEXION, CISAILLEMENT, CISAILLEMENT INVERSE
C     ----------------------------------------------------
        CALL DXMATH('NOEU',EPAIS,DF,DM,DMF,NNO,PGL,MULTIC,INDITH,
     &                                   GRILLE,T2EV,T2VE,T1VE,NNO)
        IF (INDITH.EQ.-1) GO TO 30

C --- BOUCLE SUR LES NOEUDS
C     ---------------------
        DO 20 INO = 1,NNO

C  --      LES COEFFICIENTS SUIVANTS RESULTENT DE L'HYPOTHESE SELON
C  --      LAQUELLE LA TEMPERATURE EST PARABOLIQUE DANS L'EPAISSEUR.
C  --      ON NE PREJUGE EN RIEN DE LA NATURE DU MATERIAU.
C  --      CETTE INFORMATION EST CONTENUE DANS LES MATRICES QUI
C  --      SONT LES RESULTATS DE LA ROUTINE DXMATH.
C          ----------------------------------------
          COE1 = (TSUP(INO)+TINF(INO)+4.D0*TMOY(INO))/6.D0 - TREF
          COE2 = (TSUP(INO)-TINF(INO))/EPAIS

          SIGT(1+8* (INO-1)) = COE1* (DM(1,1)+DM(1,2)) +
     &                         COE2* (DMF(1,1)+DMF(1,2))
          SIGT(2+8* (INO-1)) = COE1* (DM(2,1)+DM(2,2)) +
     &                         COE2* (DMF(2,1)+DMF(2,2))
          SIGT(3+8* (INO-1)) = COE1* (DM(3,1)+DM(3,2)) +
     &                         COE2* (DMF(3,1)+DMF(3,2))
          SIGT(4+8* (INO-1)) = COE2* (DF(1,1)+DF(1,2)) +
     &                         COE1* (DMF(1,1)+DMF(1,2))
          SIGT(5+8* (INO-1)) = COE2* (DF(2,1)+DF(2,2)) +
     &                         COE1* (DMF(2,1)+DMF(2,2))
          SIGT(6+8* (INO-1)) = COE2* (DF(3,1)+DF(3,2)) +
     &                         COE1* (DMF(3,1)+DMF(3,2))
   20   CONTINUE

      END IF

   30 CONTINUE

      END
