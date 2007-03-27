      SUBROUTINE NMCINE (FAMI,KPG,KSP,NDIM,IMATE,COMPOR,CRIT,
     &                   INSTAM,INSTAP,EPSM,DEPS,SIGM,VIM,
     &                   OPTION,SIGP,VIP,DSIDEP)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 28/03/2007   AUTEUR PELLET J.PELLET 
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
      INTEGER            KPG,KSP,NDIM,IMATE
      CHARACTER*(*)      FAMI
      CHARACTER*16       COMPOR(*),OPTION
      REAL*8             CRIT(1),INSTAM,INSTAP
      REAL*8             EPSM(6),DEPS(6)
      REAL*8             SIGM(6),VIM(7),SIGP(6),VIP(7),DSIDEP(6,6)
C ----------------------------------------------------------------------
C     REALISE LA LOI DE VON MISES CINEMATIQUE POUR LES
C     ELEMENTS ISOPARAMETRIQUES EN PETITES DEFORMATIONS
C
C
C
C IN  NDIM    : DIMENSION DE L'ESPACE
C IN  IMATE   : ADRESSE DU MATERIAU CODE
C IN  COMPOR  : COMPORTEMENT : RELCOM ET DEFORM
C IN  CRIT    : CRITERES DE CONVERGENCE LOCAUX
C IN  INSTAM  : INSTANT DU CALCUL PRECEDENT
C IN  INSTAP  : INSTANT DU CALCUL
C IN  EPSM    : DEFORMATIONS A L'INSTANT DU CALCUL PRECEDENT
C IN  DEPS    : INCREMENT DE DEFORMATION
C IN  SIGM    : CONTRAINTES A L'INSTANT DU CALCUL PRECEDENT
C IN  VIM     : VARIABLES INTERNES A L'INSTANT DU CALCUL PRECEDENT
C IN  OPTION  : OPTION DEMANDEE : RIGI_MECA_TANG , FULL_MECA , RAPH_MECA
C OUT SIGP    : CONTRAINTES A L'INSTANT ACTUEL
C OUT VIP     : VARIABLES INTERNES A L'INSTANT ACTUEL
C OUT DSIDEP  : MATRICE CARREE
C
C               ATTENTION LES TENSEURS ET MATRICES SONT RANGES DANS
C               L'ORDRE :  XX YY ZZ XY XZ YZ
C
C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------
C
      CHARACTER*32       JEXNUM , JEXNOM , JEXR8 , JEXATR
      INTEGER            ZI
      COMMON  / IVARJE / ZI(1)
      REAL*8             ZR
      COMMON  / RVARJE / ZR(1)
      COMPLEX*16         ZC
      COMMON  / CVARJE / ZC(1)
      LOGICAL            ZL
      COMMON  / LVARJE / ZL(1)
      CHARACTER*8        ZK8
      CHARACTER*16                ZK16
      CHARACTER*24                          ZK24
      CHARACTER*32                                    ZK32
      CHARACTER*80                                              ZK80
      COMMON  / KVARJE / ZK8(1) , ZK16(1) , ZK24(1) , ZK32(1) , ZK80(1)
C
C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------
C
      REAL*8      DEPSTH(6),VALRES(3),LAMBDA,DEUXMU,ALPHAP,ALPHAM
      REAL*8      DEPSDV(6),SIGDV(6),SIGEL(6),EPSMO,SIGMO,E,NU
      REAL*8      SIMOEQ,SIELEQ,SIGEPS,SEUIL,DP,COEF,DSDE,SIGY
      REAL*8      TROISK,RPRIM,RP,KRON(6),TREF,TM,TP
      REAL*8      EM,NUM,TROIKM,DEUMUM,SIGMP(6),PLASTI
      INTEGER     NDIMSI
      CHARACTER*2 BL2, FB2, CODRET(3)
      CHARACTER*8 NOMRES(3)
      REAL*8      RAC2
      DATA        KRON/1.D0,1.D0,1.D0,0.D0,0.D0,0.D0/
      RAC2 = SQRT(2.D0)
C DEB ------------------------------------------------------------------

C MISE AU FORMAT DES CONTRAINTES DE RAPPEL
      NDIMSI = NDIM*2
      DO 10 K=4,NDIMSI
        VIM(K) = VIM(K)*RAC2
  10  CONTINUE
C
      BL2 = '  '
      FB2 = 'F '

      CALL RCVARC('F','TEMP','-',FAMI,KPG,KSP,TM,IRET)
      CALL RCVARC('F','TEMP','+',FAMI,KPG,KSP,TP,IRET)
      CALL RCVARC('F','TEMP','REF',FAMI,KPG,KSP,TREF,IRET)
C
C LECTURE DES CARACTERISTIQUES ELASTIQUES DU MATERIAU (TEMPS - ET +)
      NOMRES(1)='E'
      NOMRES(2)='NU'
      NOMRES(3)='ALPHA'
      CALL RCVALB(FAMI,KPG,KSP,'-',IMATE,' ','ELAS',0,' ',
     &            0.D0,2,NOMRES,VALRES,CODRET,FB2)
      CALL RCVALB(FAMI,KPG,KSP,'-', IMATE,' ','ELAS',0,' ',
     &            0.D0,1,NOMRES(3),VALRES(3),CODRET(3), BL2 )
      IF ( CODRET(3) .NE. 'OK' ) VALRES(3) = 0.D0
      EM         = VALRES(1)
      NUM        = VALRES(2)
      DEUMUM = EM/(1.D0+NUM)
      TROIKM = EM/(1.D0-2.D0*NUM)
      ALPHAM = VALRES(3)

      CALL RCVALB(FAMI,KPG,KSP,'+',IMATE,' ','ELAS',0,' ',
     &            0.D0,2,NOMRES,VALRES,CODRET,FB2)
      CALL RCVALB(FAMI,KPG,KSP,'+', IMATE,' ','ELAS',0,' ',
     &            0.D0,1,NOMRES(3),VALRES(3),CODRET(3), BL2 )
      IF ( CODRET(3) .NE. 'OK' ) VALRES(3) = 0.D0
      E          = VALRES(1)
      NU         = VALRES(2)
      LAMBDA = E*NU/((1.D0-2.D0*NU)*(1.D0+NU))
      DEUXMU = E/(1.D0+NU)
      TROISK = E/(1.D0-2.D0*NU)
      ALPHAP = VALRES(3)
C
C LECTURE DES CARACTERISTIQUES D'ECROUISSAGE
      NOMRES(1)='D_SIGM_EPSI'
      NOMRES(2)='SY'
      CALL RCVALB(FAMI,KPG,KSP,'-',IMATE,' ','ECRO_LINE',0,' ',
     &            0.D0,2,NOMRES,VALRES,CODRET, FB2 )
      DSDEM=VALRES(1)
      CM = 2.D0/3.D0*DSDEM/(1.D0-DSDEM/EM)
      NOMRES(1)='D_SIGM_EPSI'
      NOMRES(2)='SY'
      CALL RCVALB(FAMI,KPG,KSP,'+',IMATE,' ','ECRO_LINE',0,' ',
     &            0.D0,2,NOMRES,VALRES,CODRET, FB2 )
      DSDE=VALRES(1)
      SIGY=VALRES(2)
      C  = 2.D0/3.D0*DSDE/(1.D0-DSDE/E)
C
C CALCUL DES CONTRAINTES ELASTIQUES
      DO 110 K=1,3
        DEPSTH(K)   = DEPS(K) -(ALPHAP*(TP-TREF)-ALPHAM*(TM-TREF))
        DEPSTH(K+3) = DEPS(K+3)
 110  CONTINUE
      EPSMO = (DEPSTH(1)+DEPSTH(2)+DEPSTH(3))/3.D0
      DO 115 K=1,NDIMSI
        DEPSDV(K)   = DEPSTH(K) - EPSMO * KRON(K)
 115  CONTINUE
      SIGMO = (SIGM(1)+SIGM(2)+SIGM(3))/3.D0
      SIELEQ = 0.D0
      DO 114 K=1,NDIMSI
        SIGDV(K) = SIGM(K) - SIGMO*KRON(K)
        SIGDV(K) = DEUXMU/DEUMUM*SIGDV(K)
        SIGEL(K) = SIGDV(K) + DEUXMU * DEPSDV(K)
        SIELEQ   = SIELEQ   + (SIGEL(K)-C/CM*VIM(K))**2
114   CONTINUE
      SIGMO = TROISK/TROIKM * SIGMO
      SIELEQ = SQRT(1.5D0*SIELEQ)
      SEUIL  = SIELEQ - SIGY
      DP = 0.D0
      PLASTI=VIM(7)
C
C CALCUL DES CONTRAINTES ELASTO-PLASTIQUES ET DES VARIABLES INTERNES
      IF ( OPTION(1:9) .EQ. 'RAPH_MECA' .OR.
     &     OPTION(1:9) .EQ. 'FULL_MECA' ) THEN
        IF (SEUIL.LT.0.D0) THEN
          VIP(7) = 0.D0
          DP = 0.D0
          SIELEQ = 1.D0
          A1 = 0.D0
          A2 = 0.D0
        ELSE
          VIP(7) = 1.D0
          DP = SEUIL/(1.5D0*(DEUXMU+C))
          A1 = (DEUXMU/(DEUXMU+C))*(SEUIL/SIELEQ)
          A2 = (C     /(DEUXMU+C))*(SEUIL/SIELEQ)
        ENDIF
        PLASTI=VIP(7)
        DO 160 K = 1,NDIMSI
          SIGDV(K) = SIGEL(K) - A1*(SIGEL(K)-VIM(K)*C/CM)
          SIGP(K)  = SIGDV(K) + (SIGMO + TROISK*EPSMO)*KRON(K)
          VIP(K)   = VIM(K)*C/CM   + A2*(SIGEL(K)-VIM(K)*C/CM)
 160    CONTINUE
      ENDIF
C
C CALCUL DE LA RIGIDITE TANGENTE
      IF ( OPTION(1:14) .EQ. 'RIGI_MECA_TANG' .OR.
     &     OPTION(1:9)    .EQ. 'FULL_MECA' ) THEN
        DO 100 K=1,6
        DO 100 L=1,6
          DSIDEP(K,L) = 0.D0
 100    CONTINUE
        DO 120 K=1,6
          DSIDEP(K,K) = DEUXMU
 120    CONTINUE
        IF ( OPTION(1:14) .EQ. 'RIGI_MECA_TANG') THEN
          DO 174 K = 1,NDIMSI
            SIGDV(K) = SIGDV(K) - VIM(K)*C/CM
 174      CONTINUE
        ELSE
          DO 175 K = 1,NDIMSI
            SIGDV(K) = SIGDV(K) - VIP(K)
 175      CONTINUE
        ENDIF
        SIGEPS = 0.D0
        DO 170 K = 1,NDIMSI
          SIGEPS = SIGEPS + SIGDV(K)*DEPSDV(K)
 170    CONTINUE
        A1 = 1.D0/(1.D0+1.5D0*(DEUXMU+C)*DP/SIGY)
        A2 = (1.D0+1.5D0*C*DP/SIGY)*A1
        IF(PLASTI.GE.0.5D0.AND.SIGEPS.GE.0.D0) THEN
          COEF = -1.5D0*(DEUXMU/SIGY)**2 / (DEUXMU+C) * A1
          DO 135 K=1,NDIMSI
            DO 135 L=1,NDIMSI
              DSIDEP(K,L) = A2 * DSIDEP(K,L) + COEF*SIGDV(K)*SIGDV(L)
 135      CONTINUE
          LAMBDA = LAMBDA + DEUXMU**2*A1*DP/SIGY/2.D0
        ENDIF
        DO 130 K=1,3
          DO 131 L=1,3
            DSIDEP(K,L) = DSIDEP(K,L) + LAMBDA
 131      CONTINUE
 130    CONTINUE
      ENDIF
C
C MISE AU FORMAT DES CONTRAINTES DE RAPPEL
      DO 20 K=4,NDIMSI
        VIM(K) = VIM(K)/RAC2
 20   CONTINUE
      IF (OPTION(1:9).EQ.'RAPH_MECA' .OR.
     &    OPTION(1:9).EQ.'FULL_MECA')     THEN
        DO 30 K=4,NDIMSI
          VIP(K) = VIP(K)/RAC2
 30     CONTINUE
      END IF
C
 9999 CONTINUE
C FIN ------------------------------------------------------------------
      END
