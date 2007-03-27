      SUBROUTINE NMFGAS (FAMI,NPG,ICODMA,PGL,NNO,NC,UGL,EFFNOM,PM,
     &                   CRIT,TMOINS,TPLUS,
     &                   XLONG0,A,COEFFL,COEFGR,
     &                   IRRAM,IRRAP,
     &                   KLS,FLC,EFFNOC,PP)
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
C TOLE CRP_21
C TOLE CRP_7
C ----------------------------------------------------------------------
      IMPLICIT REAL*8 (A-H,O-Z)
      INTEGER NNO,NC,NEQ,NBT,NCOEFF,NCOEFG,NITMAX
      PARAMETER (NEQ = 12, NBT = 78, NCOEFF = 7, NCOEFG = 3)
      REAL*8  CRIT(*)
      REAL*8  XLONG0
      REAL*8  COEFFL(NCOEFF),COEFGR(NCOEFG)
      REAL*8  TMOINS,TPLUS,EFFNOM,PM
      REAL*8  UGL(NEQ),PGL(3,3)
      REAL*8  KLS(NBT),EFFNOC,FLC,PP
      CHARACTER*(*) FAMI
C ----------------------------------------------------------------------
C
C     TRAITEMENT DE LA RELATION DE COMPORTEMENT NON LINEAIRE
C     (FLUAGE + GRANDISSEMENT ) POUR LES ELEMENTS DE
C     POUTRE : CALCUL DE LA MATRICE DE RAIDEUR TANGENTE ET DES FORCES
C     NODALES.
C
C ----------------------------------------------------------------------
C
C IN  :
C       PGL    : MATRICE DE PASSAGE
C       NNO    : NOMBRE DE NOEUDS
C       NC     : NOMBRE DE DDL
C       UGL    : ACCROIS. DEPLACEMENTS EN REPERE GLOBAL
C       EFFNOM : EFFORT NORMAL ELASTIQUE PRECEDENT
C       PM     : MULTIPLICATEUR PLASTIQUE PRECEDENT
C       CRIT   : CRITERES DE CONVERGENCE LOCAUX
C       TMOINS : INSTANT PRECEDENT
C       TPLUS  : INSTANT COURANT
C       XLONG0 : LONGUEUR DE L'ELEMENT DE POUTRE AU REPOS
C       E      : MODULE D'YOUNG
C       A      : SECTION DE LA POUTRE
C       ALPHA  : COEFFICIENT DE DILATATION THERMIQUE
C       COEFFL : COEFFICIENTS CONSTANTS POUR LE FLUAGE
C                1 : N
C                2 : 1/K
C                3 : 1/M
C                4 : Q/R
C                5 : BETA
C                6 : PHI_ZERO
C                7 : L
C       COEFGR : COEFFICIENTS CONSTANTS POUR LE GRANDISS
C
C OUT : KLS    : SOUS MATRICE DE RAIDEUR TANGENTE EN REPERE LOCAL
C       FLC    : FORCE NODALE AXIALE CORRIGEE EN REPERE LOCAL
C       EFFNOC : EFFORT NORMAL CORRIGE
C       PP     : MULTIPLICATEUR PLASTIQUE COURANT
C
C *************** DECLARATION DES VARIABLES LOCALES ********************
C
      EXTERNAL NMCRI4
      REAL*8   NMCRI4, UL(12)
      REAL*8     FGRAND,DEPGRD,RIGELA,DEPTHE,PUISS,EXPON
      REAL*8     PRECI,BA,BB,FA,CORREC,XRIG,SIGP,TABS,R8T0
      REAL*8     E,EM,ALPHAM,ALPHA,TEMPM,TEMPP,TREF,TPP,TPM
      REAL*8     NU,NUM,IRRAM,IRRAP
C
C *********** FIN DES DECLARATIONS DES VARIABLES LOCALES ***************
C
C **************** COMMON COMMUN A NMCRI4 ET NMFGAS  *******************
C
      COMMON /RCONM4/ YOU,CFLUAG,SIGE,PMM,SDT
      REAL*8   CFLUAG(NCOEFF),YOU,SIGE,PMM,SDT
C
C ********************* DEBUT DE LA SUBROUTINE *************************
C --- INITIALISATIONS
C
      TABS = R8T0()

CJMP  SEMI-IMPLICITE   SEULES VALEURS POSSIBLES : THETA = 1 OU 1/2

      THETA = CRIT(4)
      T1 = ABS(THETA-0.5D0)
      T2 = ABS(THETA-1.D0)
      PREC = 0.01D0
      IF ((T1.GT.PREC).AND.(T2.GT.PREC))  THEN
         CALL U2MESS('F','ALGORITH6_55')
      ENDIF
      IF (COEFFL(1).EQ.0.D0) THEN
         CALL U2MESS('F','ALGORITH7_79')
      ENDIF

      CALL R8INIR (NBT,0.D0,KLS,1)
      CALL R8INIR (12,0.D0,UL,1)
C
      CALL DCOPY (NCOEFF,COEFFL,1,CFLUAG,1)
C
      CALL UTPVGL (NNO,NC,PGL,UGL,UL)
C
      SIGM   = EFFNOM/A
      PMM    = PM
C
C --- COEFFICIENTS DE FLUAGE ET GRANDISSEMENT
      CALL RCVARC('F','TEMP','REF',FAMI,1,1,TREF,IRET)
      CALL MOYTEM(FAMI,NPG,1,'+',TEMPP)
      CALL MOYTEM(FAMI,NPG,1,'-',TEMPM)
      CALL MATELA(ICODMA,' ',ITEMP,TEMPP,E,NU,ALPHA)
      CALL MATELA(ICODMA,' ',ITEMP,TEMPM,EM,NUM,ALPHAM)
      YOU    = E

      DLONG0 = UL(7) - UL(1)
      DEPSI  = DLONG0/XLONG0

      DEPSI = DEPSI * THETA
      TEMPP2=TEMPM+(TEMPP-TEMPM)*THETA
      FGRAND = (COEFGR(1)*TEMPP+COEFGR(2))*(IRRAP**COEFGR(3))-
     &         (COEFGR(1)*TEMPM+COEFGR(2))*(IRRAM**COEFGR(3))
      DEPTHE = ALPHA*(TEMPP-TREF)-ALPHAM*(TEMPM-TREF)
      DEPGRD = THETA * (FGRAND + DEPTHE)

CJMP  CETTE FORMULE NE FONCTIONNE QUE POUR THETA=1 OU 0.5
      SIGE=E/EM*SIGM+(1.D0-THETA)*(1.D0-E/EM)*SIGM+E*DEPSI-E*DEPGRD

      PRECI = CRIT(3)*CRIT(3)

      EXPON = EXP(-1.D0*COEFFL(4)/(TEMPP2+TABS))
      SDT = (IRRAP-IRRAM)/(COEFFL(6)*(TPLUS-TMOINS))
      IF (COEFFL(6).LE.0.D0) THEN
        CALL U2MESS('F','ALGORITH7_80')
      ENDIF
      IF (SDT.LT.0.D0) THEN
        CALL U2MESS('F','ALGORITH6_57')
      ENDIF
      SDT = SDT * COEFFL(2) + COEFFL(7)
      IF (SDT.LT.0.D0) THEN
        CALL U2MESS('F','ALGORITH7_81')
      ENDIF
      IF (SDT.EQ.0.D0) THEN
        IF (COEFFL(5).EQ.0.D0) SDT=1.D0
        IF (COEFFL(5).LT.0.D0) THEN
          CALL U2MESS('F','ALGORITH7_82')
        ENDIF
      ENDIF
      IF (SDT.GT.0.D0) THEN
        SDT = SDT**COEFFL(5)
      ENDIF
      SDT = SDT*EXPON*THETA*(TPLUS-TMOINS)
C
      BA = 0.D0
      FA = NMCRI4(BA)
C      FA0 = FA
      IF (FA.GT.0.D0) THEN
         CALL U2MESS('F','ALGORITH7_83')
      ENDIF
      IF (SIGE.NE.0.D0) THEN
         BB = ABS(SIGE)/E

         NITMAX = INT(CRIT(1))
C         PRECI = CRIT(3)*CRIT(3)*(ABS(SIGE)*COEFFL(2))**COEFFL(1)
         CALL ZEROF3 (NMCRI4,BA,BB,PRECI,NITMAX,DP)
30       CONTINUE

         PP = PM + DP/THETA

         SIGP = SIGE * (1.D0 - E * DP/ABS(SIGE) )

      ELSE
         PP = PM
         SIGP = SIGE
      ENDIF

         SIGP = (SIGP-SIGM)/THETA + SIGM

      EFFNOC = SIGP * A
C
C --- CALCUL DES COEFFICIENTS NON ELASTIQUES DE LA MATRICE TANGENTE
C
C      FFLUAG = 0.D0
C      CORREC = (E*FFLUAG*COEFFL(2)*(EFFNOC/A)**(COEFFL(2)-1.D0))
      CORREC = 0.D0
      RIGELA = E*A/XLONG0
      XRIG = RIGELA / (1.D0 + CORREC)
      KLS(1)  =  XRIG
      KLS(22) = -XRIG
      KLS(28) =  XRIG
C
C --- CALCUL DES FORCES NODALES
C
      FLC = EFFNOC
C
C ----------------------------------------------------------------------
C
      END
