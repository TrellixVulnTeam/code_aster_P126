      SUBROUTINE LCROUS (TOLER, ITMAX, MOD, IMAT, NMAT, MATERF, NVI,
     1                   TEMPF, DEPS, SIGD, VIND, THETA, LOI, DT, 
     2                   SIGF, VINF, IRTET)
        IMPLICIT NONE
C       ================================================================
C MODIF ALGORITH  DATE 17/09/2002   AUTEUR T2BAXJM R.MASSON 
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
C              SEE THE FILE "LICENSE.TERMS" FOR INFORMATION ON USAGE AND
C              REDISTRIBUTION OF THIS FILE.
C ======================================================================
C       ================================================================
C       INTEGRATION DE LA LOI DE ROUSSELIER
C
C       VIN = (P,F,INDICATEUR DE PLASTICITE)
C       ----------------------------------------------------------------
C
C       IN  TOLER  :  TOLERANCE DE CONVERGENCE LOCALE NEWT
C           ITMAX  :  NOMBRE MAXI D'ITERATIONS LOCALES
C           MOD    :  TYPE DE MODELISATION
C           IMAT   :  ADRESSE DU MATERIAU CODE
C           NMAT   :  DIMENSION MATER
C           MATERF :  COEFFICIENTS MATERIAU A T+DT
C           NVI    :  NB VARIABLES INTERNES
C           TEMPF  :  TEMPERATURE A T+DT
C           DEPS   :  INCREMENT DE DEFORMATION
C           SIGD   :  CONTRAINTE A T
C           VIND   :  VARIABLES INTERNES A T
C           THETA  :  PARAMETRE THETA DE LA THETA-METHODE
C           LOI    :  MODELE DE COMPORTEMENT
C           DT     :  INTERVALLE DE TEMPS DT
C       OUT SIGF   :  CONTRAINTE A T+DT
C           VINF   :  VARIABLES INTERNES A T+DT
C           IRTET  :  CONTROLE DU REDECOUPAGE INTERNE DU PAS DE TEMPS
C
        INTEGER         IMAT, NMAT, IRTET, ITMAX, NCOMPT, NVI
        INTEGER         NINT, TESTCV, CONVP
C
        REAL*8          MUN, ZERO, UN, DEUX,TROIS,D13,ANN, DT
        REAL*8          TOLER, DELTA, D, S1, ACC
        REAL*8          P, PI, DP, F0, F, FI, DF
        REAL*8          DDP, RP, DRDP
        REAL*8          DF1, DF2, DDF, FITOT,FTOT
        REAL*8          PETIT, DDFM, MOYDDF
        REAL*8          PHI, PHI1, PHI2, PHIP, PHI1P, PHI2P
        REAL*8          NU, E, DEUXMU, TROIMU, TROISK,THETA
        REAL*8          DEPS(6), DEPSMO, DEPSDV(6)
        REAL*8          SIGD(6), SIGF(6), SIG0, EPS0, MEXPO
        REAL*8          RIGD(6), RIGDMO, RIGDDV(6)
        REAL*8          RIGF(6), RIGFMO, RIGFDV(6)
        REAL*8          RIGM0, RIGM, ARGMIN, ARGMAX
        REAL*8          RIGEQ, RIGEL(6), RIELEQ, DSIG
        REAL*8          VIND(NVI), VINF(NVI)
        REAL*8          MATERF(NMAT,2), TEMPF, UNRHOD, RHOF
        REAL*8          NDEPS, NSIGD, LCNRTS, LCNRTE,DEMUTH
        REAL*8          SEUIL, DSEUIL, PUISS, DPUISS, ASINH
        REAL*8          DP1, DP2
C
        LOGICAL         OVERFL
C
        PARAMETER       ( MUN  =-1.D0 )
        PARAMETER       ( ZERO = 0.D0 )
        PARAMETER       ( UN   = 1.D0 )
        PARAMETER       ( DEUX = 2.D0 )
        PARAMETER       ( D13 = .3333333333D0 )
        PARAMETER       ( TROIS = 3.D0 )
C 
        CHARACTER*8     MOD
        CHARACTER*16    LOI
        CHARACTER*24    ZK24

C       ---------------------------------------------------------------
C
C -- INITIALISATION-----------------------------------------------
C
      NU = MATERF(2,1)
      E  = MATERF(1,1)
      D  = MATERF(1,2)
      S1 = MATERF(2,2)
      F0 = MATERF(3,2)
      IF (LOI(1:10).EQ.'ROUSS_VISC') THEN
        ANN = 0.D0
        SIG0  = MATERF(8,2)
        EPS0  = MATERF(9,2)
        MEXPO = MATERF(10,2)
      ELSE IF (LOI(1:10).EQ.'ROUSS_PR') THEN
        ANN = MATERF(8,2)
        SIG0  = 0.D0
        EPS0  = 0.D0
        MEXPO = 0.D0
      END IF
      DEUXMU = E/(UN+NU)
      DEMUTH =  DEUXMU*THETA
      TROISK = E/(UN-DEUX*NU)
      TROIMU = 1.5D0*DEUXMU
      PI = VIND(1)
      FI = VIND(2)
      FITOT =FI + ANN*PI
C
C -- CAS DU MATERIAU CASSE----------------------------------------
      IF (FITOT .GE. MATERF(6,2)) THEN
        NDEPS = LCNRTE(DEPS)
        NSIGD = LCNRTS(SIGD)
        DSIG = MATERF(7,2)*E*NDEPS
        IF (DSIG .GE. NSIGD) THEN      
          CALL LCINVE(ZERO, SIGF)
        ELSE
          CALL LCPRSV(UN-DSIG/NSIGD, SIGD, SIGF)
        ENDIF
        VINF(1)   = PI
        VINF(2)   = UN
        VINF(NVI) = UN
        IRTET=0
        GOTO 9999
      ENDIF
C
C ---INTEGRATION IMPLICITE DE LA LOI DE COMPORTEMENT-------------
C
C -- DEPSMO : INCREMENT DE DEFORMATION MOYENNE
C -- DEPSDV : INCREMENT DE DEFORMATION DEVIATORIQUE
      CALL LCHYDR(DEPS,DEPSMO)
      CALL LCSOMH(DEPS,-DEPSMO,DEPSDV)
C -- REDECOUPAGE SI L'INCREMENT DE DEFORMATION EST TROP GRAND 
      IF (DEPSMO.GT.10.D0) THEN
         GOTO 50
      ENDIF
C 
C -- RIG : CONTRAINTE REDUITE
      UNRHOD = (UN-F0)/(UN-FITOT)
      CALL  LCPRSV (UNRHOD, SIGD, RIGD)
C
C -- RIGDMO : CONTRAINTE MOYENNE      REDUITE PRECEDENT
C -- RIGDDV : CONTRAINTE DEVIATORIQUE REDUITE PRECEDENT
      CALL LCHYDR(RIGD,RIGDMO)
      CALL LCSOMH(RIGD,-RIGDMO,RIGDDV)
C -- CALCUL DE RIELEQ
      CALL LCPRSV(DEMUTH,DEPSDV,RIGEL)
      CALL LCSOVE(RIGDDV,RIGEL ,RIGEL)
      RIELEQ = LCNRTS(RIGEL)

C ---CAS DU MATERIAU A POROSITE ACCELEREE--
       IF (FITOT .GE. MATERF(4,2)) THEN
         ACC = MATERF(5,2)
       ELSE
C ---CAS DU MATERIAU SAIN------------------
         ACC = UN
       ENDIF
C
C ---DEBUT RESOLUTION----------------------
C
C - CONTROLE ARGUMENT DE L EXPO : DF1 ET DF2
      DF1 = ZERO
C      
      ARGMAX = 200.D0
      RIGM0 = RIGDMO+TROISK*DEPSMO
      IF ((RIGM0/S1).GT.ARGMAX) THEN
         DF1 = (UN-FI)*(RIGM0-ARGMAX*S1)
     &         /(THETA*TROISK/(TROIS*ACC)+RIGM0-ARGMAX*S1)
      ENDIF
      ARGMIN = -50.D0
      DF2 = (UN-FI)*(RIGM0-ARGMIN*S1)
     &      /(THETA*TROISK/(TROIS*ACC)+RIGM0-ARGMIN*S1)
C -- SI POROSITE NULLE : VON MISES
      IF (FI.EQ.0.D0) DF2 = -10.D0

C -- SI POINT EN COMPRESSION : VON MISES
      IF ((DF2.LT.ZERO).OR.(DF2.GT.(UN-FI))) THEN
        RHOF = UN/UNRHOD
        DF = ZERO
        F = FI
        RIGM  =  RIGDMO 
     &           + TROISK*THETA*(DEPSMO - DF/(TROIS*(UN-F)*ACC))
        DP = 0.05D0*PI
        NCOMPT = 0
        CONVP = 1
        IF (LOI(1:10).EQ.'ROUSS_VISC') THEN
           CONVP = 0
        ENDIF
        DP1 = 0.D0
C -- BOUCLE SUR DP
 11     CONTINUE
        NCOMPT = NCOMPT + 1
        P = PI + THETA*DP
        CALL RSLISO (IMAT, TEMPF, P, RP, DRDP)
        RIGEQ = RIELEQ - TROIMU*THETA*DP
        PHI = RIGEQ - RP + D*S1*F*EXP(RIGM/S1)
        PHIP = -(TROIMU + DRDP)*THETA
        IF ((LOI(1:10).EQ.'ROUSS_VISC').AND.(CONVP.EQ.1)) THEN
           SEUIL = PHI
           DSEUIL = PHIP
           IF (SEUIL.GT.ZERO) THEN
             PUISS = (DP/(DT*EPS0))**(UN/MEXPO)
             DPUISS = ((DP/(DT*EPS0))**(UN/MEXPO-UN))/(MEXPO*(DT*EPS0))
             ASINH = LOG(PUISS + SQRT(UN + PUISS**2)) 
             PHI = SEUIL - SIG0*ASINH
             PHIP = DSEUIL - SIG0*DPUISS/SQRT(UN+PUISS**2)*THETA
           ENDIF
           IF (PHI.GT.ZERO) DP1 = DP
        ENDIF
        IF (PHI.LT.ZERO) DP2 = DP

C -- SI CONVERGENCE
        IF (ABS(PHI/S1).LT.TOLER) THEN
           IF (CONVP.EQ.1) THEN 
              GOTO 21
           ELSE
              DP2 = DP
              CONVP = 1
           ENDIF
        ENDIF
C -- SI RECHERCHE TROP LONGUE
        IF (NCOMPT.GE.ITMAX) THEN
           GOTO 60
        ENDIF
C -- SINON CONTINUER
        DDP = - PHI/PHIP
C -- BORNE INF CONTROLEE
        IF ((DP+DDP).LT.0.D0) THEN
           DP = (DP1 + DP2)/DEUX
        ELSE
           DP = DP + DDP
        ENDIF
        GOTO 11
 21     CONTINUE
        P = PI + DP
        IRTET = 0
        GOTO 20
      ENDIF
C -- CALCUL DE PHI1 ET PHI2
      CALL RSLPHI(LOI,IMAT,TEMPF,TROISK,TROIMU,DEPSMO,RIGDMO,RIELEQ,
     &   PI,D,S1,ANN,THETA,ACC,FI+DF1,DF1,SIG0,EPS0,MEXPO,DT,PHI1,
     &   PHI1P,RIGEQ,RIGM,P,OVERFL)
      IF (OVERFL) GOTO 45
      CALL RSLPHI(LOI,IMAT,TEMPF,TROISK,TROIMU,DEPSMO,RIGDMO,RIELEQ,
     &   PI,D,S1,ANN,THETA,ACC,FI+DF2,DF2,SIG0,EPS0,MEXPO,DT,PHI2,
     &   PHI2P,RIGEQ,RIGM,P,OVERFL)
      IF (OVERFL) GOTO 45
      IF ((PHI1.LT.0.D0).OR.(PHI2.GT.0.D0)) THEN
         GOTO 50
      ENDIF
C -- INITIALISATION DES INCREMENTS
      IF (LOI(1:10).EQ.'ROUSS_VISC') THEN
         DF = DF2
         PHI  = PHI2
         PHIP = PHI2P
      ELSE
         DF    = DF1
         PHI  = PHI1
         PHIP = PHI1P
      ENDIF
C - 
      DELTA = UN
      NCOMPT= 0
      NINT = 0
      DDFM = 0.D0
      MOYDDF = 0.D0
      TESTCV = 1
      PETIT = 1.D-12
C
C -- BOUCLE PRINCIPALE---------------
 10   CONTINUE
C
C -- CALCUL DE L INCREMENT
      NCOMPT=NCOMPT+1
      DDF = -PHI/PHIP
C - CONTROLE VITESSE EVOLUTION DES DDF?
      NINT = NINT + 1
      MOYDDF = MOYDDF + (DDF-DDFM)
      DDFM = DDF
C - CALCUL DE DF
C - CONTROLE CONV NEWTON
      IF (NINT.EQ.5) THEN
C - SI NEWTON LENT : DICHOTOMIE POUR LA SUITE
        MOYDDF = MOYDDF*TESTCV/NINT
        IF (MOYDDF.LE.PETIT) THEN
          DF= DF1 + (DF2 - DF1)/DEUX
          NINT = 4
          TESTCV = 0
        ELSE
          NINT = 0
          MOYDDF = 0.D0
        ENDIF
      ENDIF
C - SI TESTS PRECEDENTS OK : NEWTON + BORNES CONTROLEES
      IF (TESTCV.EQ.1) THEN
C - DF1<DF+DDF<DDF2? SINON CORDE
         IF (((DELTA*DDF).LE.ZERO).OR.((DELTA*DDF).GE.(DF2-DF1))) THEN
           DF= (PHI1*DF2 - PHI2*DF1)/(PHI1-PHI2)
         ELSE
           DF=DF+DDF
         ENDIF
      ENDIF
      F=FI+DF
      CALL RSLPHI(LOI,IMAT,TEMPF,TROISK,TROIMU,DEPSMO,RIGDMO,RIELEQ,
     &    PI,D,S1,ANN,THETA,ACC,F,DF,SIG0,EPS0,MEXPO,DT,PHI,PHIP,
     &    RIGEQ,RIGM,P,OVERFL)
      IF (OVERFL) GOTO 45
C
C -- SI CONVERGENCE
      IF (ABS(PHI/S1).LT.TOLER) GOTO 20
      IF (((DF2-DF1).LT.1.D-15).AND.(NCOMPT.EQ.ITMAX)) THEN
           GOTO 20
      ENDIF
C
C -- SI RECHERCHE TROP LONGUE
      IF (NCOMPT.GE.ITMAX) THEN
         GOTO 60
      ENDIF
C
C -- SINON CONTINUER
      IF (PHI.GT.ZERO) THEN
        DF1  = DF
        PHI1 = PHI
        DELTA= UN
      ELSE
        DF2  = DF
        PHI2 = PHI
        DELTA= MUN
      ENDIF
      GOTO 10
C
C -- CONVERGENCE---------------
 20   CONTINUE
C -- CALCUL DE RIELEQ AVEC THETA =1----
      CALL LCPRSV(DEUXMU,DEPSDV,RIGEL)
      CALL LCSOVE(RIGDDV,RIGEL ,RIGEL)
      RIELEQ = LCNRTS(RIGEL)
      DP=P-PI
      RIGEQ = RIELEQ - TROIMU*DP
      RIGM  =  RIGDMO + TROISK*(DEPSMO - D13*DF/((UN -F)*ACC))
      VINF(1) = P
      FTOT = F + ANN*P
      VINF(2) = F 
      VINF(NVI) = UN
      RHOF = (UN-FTOT)/(UN-F0)
      CALL LCPRSV(RIGEQ/RIELEQ,RIGEL,RIGFDV)
      CALL LCSOMH(RIGFDV,RIGM,RIGF)
      CALL LCPRSV(RHOF,RIGF,SIGF)
      IRTET=0
      GOTO 9999
C
C -- ERREURS--------------------------------------------------------
 40   CONTINUE
      CALL UTMESS('S','LCROUS','VALEURS INITIALES NON CONFORMES : '//
     &    'IL Y A PROBABLEMENT UNE ERREUR DANS LA PROGRAMMATION')
      GOTO 9999
 45   CONTINUE
      CALL UTMESS('S','LCROUS','OVERFLOW NUMERIQUE : '//
     &    'LA PLASTICITE CUMULEE EXPLOSE DANS RSLPHI')
      GOTO 9999
C
C -- PROBABLEMENT UN INCREMENT TROP GRAND DE DEFORMATION-----------
 50   CONTINUE
C      CALL UTMESS('I','LCROUS','DIFFICULTE DANS LE CALCUL DE L '//
C     &    'INCREMENT MAXIMAL DE POROSITE : REDECOUPAGE')
      IRTET=1
      GOTO 9999
C
C -- NON CONVERGENCE------------------------------------------------
 60   CONTINUE
C      CALL UTMESS('I','LCROUS','NON CONVERGENCE : REDECOUPAGE '//
C     &     'INTERNE : SI POSSIBLE, AUGMENTER ITER_INTE_MAXI')
      IRTET=1
      GOTO 9999
C
C ------------------------------------------------------------------
 9999 CONTINUE
      END
