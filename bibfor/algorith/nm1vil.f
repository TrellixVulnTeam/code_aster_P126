      SUBROUTINE NM1VIL(FAMI,KPG,KSP,ICDMAT,MATERI,CRIT,
     &                  INSTAM,INSTAP,
     &                  TM,TP,TREF,
     &                  DEPS,
     &                  SIGM,VIM,
     &                  OPTION,
     &                  DEFAM,DEFAP,
     &                  ANGMAS,
     &                  SIGP,VIP,DSIDEP,IRET)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 28/03/2007   AUTEUR PELLET J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2004  EDF R&D                  WWW.CODE-ASTER.ORG
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
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C TOLE CRP_7
C TOLE CRP_21
C ----------------------------------------------------------------------
C
      IMPLICIT NONE
      INTEGER            ICDMAT,KPG,KSP,IRET
      REAL*8             CRIT(*)
      REAL*8             INSTAM,INSTAP
      REAL*8             TM,TP,TREF
      REAL*8             IRRAM,IRRAP
      REAL*8             DEPS
      REAL*8             SIGM,VIM
      CHARACTER*16       OPTION
      CHARACTER*(*) FAMI
      REAL*8             DEFAM,DEFAP
      REAL*8             ANGMAS(3)
      REAL*8             SIGP,VIP,DSIDEP
      CHARACTER*8        MATERI

C ----------------------------------------------------------------------
C      VISCO_PLASTICITE FLUAGE SOUS IRRADIATION AVEC GRANDISSEMENT
C      VISC_IRRA_LOG OU GRAN_IRRA_LOG
C      LOI 1D PURE. MODIF JMP POUR ECRIRE SIMPLEMENT :
C DEPSVP=SIGMA+.EXP(-Q/T)*(A.OMEGA/(1+OMEGA*FLUENCE)+B*FLUENCE)*DFLUENCE
C
C IN  ICDMAT  : MATERIAU CODE
C IN  CRIT    : CRITERES DE CONVERGENCE LOCAUX
C IN  INSTAM  : INSTANT DU CALCUL PRECEDENT
C IN  INSTAP  : INSTANT DU CALCUL
C IN  TM      : TEMPERATURE A L'INSTANT PRECEDENT
C IN  TP      : TEMPERATURE A L'INSTANT DU CALCUL
C IN  TREF    : TEMPERATURE DE REFERENCE
C IN  DEPS    : INCREMENT DE DEFORMATION
C IN  SIGM    : CONTRAINTES A L'INSTANT DU CALCUL PRECEDENT
C IN  VIM     : VARIABLES INTERNES A L'INSTANT DU CALCUL PRECEDENT
C IN  OPTION  : OPTION DEMANDEE : RIGI_MECA_TANG , FULL_MECA , RAPH_MECA
C IN  DEFAM   : DEFORMATIONS ANELASTIQUES A L'INSTANT PRECEDENT
C IN  DEFAP   : DEFORMATIONS ANELASTIQUES A L'INSTANT DU CALCUL
C IN  ANGMAS  : LES TROIS ANGLES DU MOT_CLEF MASSIF (AFFE_CARA_ELEM)
C OUT SIGP    : CONTRAINTES A L'INSTANT ACTUEL
C OUT VIP     : VARIABLES INTERNES A L'INSTANT ACTUEL
C OUT DSIDEP  : MODULE TANGENT
C OUT IRET    : CODE RETOUR DE LA RECHERCHE DE ZERO DE F(X)=0
C                   IRET=0 => PAS DE PROBLEME
C                   IRET=1 => ECHEC

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
C     COMMON POUR LES PARAMETRES DES LOIS VISCOPLASTIQUES
      COMMON / NMPAVP / DPC,SIELEQ,DEUXMU,DELTAT,TSCHEM,PREC,THETA,NITER
      REAL*8            DPC,SIELEQ,DEUXMU,DELTAT,TSCHEM,PREC,THETA,NITER
C     COMMON POUR LES PARAMETRES DES LOIS DE FLUAGE SOUS IRRADIATION
C     ZIRC_EPRI    : FLUPHI VALDRP TTAMAX
C     ZIRC_CYRA2   : FLUPHI EPSFAB TPREC
C     VISC_IRRA_LOG: FLUPHI A      B      CTPS    ENER
      COMMON / NMPAIR / FLUPHI,
     &                  EPSFAB,TPREC,
     &                  VALDRP,TTAMAX,
     &                  A,B,CTPS,ENER
      REAL*8            FLUPHI
      REAL*8            VALDRP,TTAMAX
      REAL*8            EPSFAB,TPREC
      REAL*8            A,B,CTPS,ENER
C PARAMETRES MATERIAUX
C ELASTIQUES
      REAL*8            ALPHAP,EP,NUP,TROIKP,DEUMUP
      REAL*8            ALPHAM,EM,NUM,TROIKM,DEUMUM
C AUTRES
      INTEGER    NBCGIL,IRET2
      PARAMETER  (NBCGIL=5)
      REAL*8     COEGIL(NBCGIL)
      CHARACTER*8  NOMGIL(NBCGIL)
      CHARACTER*2 CODGIL(NBCGIL)
C GRANDISSEMENT
      INTEGER    NBCLGR
      PARAMETER (NBCLGR=3)
      REAL*8     COEFGR(NBCLGR)
      CHARACTER*8 NOMGRD(NBCLGR)
      REAL*8            T1,T2,R8VIDE
      REAL*8            DEPSGR,DEGRAN,DEPSTH,DEPSEL,DEPSAN,DEPSIM
      REAL*8            SIGEL,MULP,MULM
      REAL*8            DPCMOD,COEF1,COEF2,COEFB,EXPQT
      REAL*8            FG,FDGDST,FDGDEV
      REAL*8            ALPHA,A0,XAP,X
      REAL*8            VPAVIL
      EXTERNAL          VPAVIL
      DATA NOMGIL / 'A', 'B', 'CSTE_TPS', 'ENER_ACT', 'FLUX_PHI'/
      DATA        NOMGRD / 'GRAN_A' , 'GRAN_B' , 'GRAN_S' /

C     PARAMETRE THETA D'INTEGRATION

      THETA = CRIT(4)
      T1 = ABS(THETA-0.5D0)
      T2 = ABS(THETA-1.D0)
      PREC = 0.000001D0
      IF ((T1.GT.PREC).AND.(T2.GT.PREC))  THEN
         CALL U2MESS('F','ALGORITH6_55')
      ENDIF

C TEMPERATURE AU MILIEU DU PAS DE TEMPS  (DANS COMMON / NMPAVP /)
      TSCHEM = TM*(1.D0-THETA)+TP*THETA
C DEFORMATION PLASTIQUE CUMULEE  (DANS COMMON / NMPAVP /)
      DPC = VIM
C INCREMENT DE TEMPS (DANS COMMON / NMPAVP /)
      DELTAT = INSTAP - INSTAM
C CARACTERISTIQUES ELASTIQUES VARIABLES
      CALL NMASSE(FAMI,KPG,KSP,'-',ICDMAT,MATERI,INSTAM,
     &            EM,NUM,ALPHAM,DEUMUM,TROIKM)

      CALL NMASSE(FAMI,KPG,KSP,'+',ICDMAT,MATERI,INSTAP,
     &            EP,NUP,ALPHAP,DEUMUP,TROIKP)

C     IRRADIATION AU POINT CONSIDERE
C     FLUX NEUTRONIQUE
      CALL RCVARC('F','IRRA','-',FAMI,KPG,KSP,IRRAM,IRET2)
      IF (IRET2.GT.0) IRRAM=0.D0
      CALL RCVARC('F','IRRA','+',FAMI,KPG,KSP,IRRAP,IRET2)
      IF (IRET2.GT.0) IRRAP=0.D0

      FLUPHI = (IRRAP-IRRAM)/DELTAT
C     RECUPERATION DES CARACTERISTIQUES DE GRANDISSEMENT
      CALL RCVALA(ICDMAT,MATERI,'GRAN_IRRA_',0,' ',0.D0,
     &              3,NOMGRD(1),COEFGR(1),CODGIL(1), '  ' )
C     RECUPERATION DES CARACTERISTIQUES DES LOIS DE FLUAGE
      CALL RCVALA(ICDMAT,MATERI,'GRAN_IRRA_',0,' ',0.D0,
     &              NBCGIL,NOMGIL(1),COEGIL(1),CODGIL(1), '  ' )
C     TRAITEMENT DES PARAMETRES DE LA LOI DE FLUAGE
      IF (CODGIL(1).EQ.'OK') THEN
C         LOI DE TYPE VISC_IRRA_LOG
C         PARAMETRES DE LA LOI DE FLUAGE

          A       = COEGIL(1)
          B       = COEGIL(2)
          CTPS    = COEGIL(3)
          ENER    = COEGIL(4)

          IF (COEGIL(5).NE.1.D0) THEN
            CALL U2MESS('A','ALGORITH6_56')
          ENDIF
          IF (FLUPHI.LT.-PREC) THEN
            CALL U2MESS('F','ALGORITH6_57')
          ENDIF
      ELSE
          CALL U2MESS('F','ALGORITH6_58')
      ENDIF

C     INCREMENT DEFORMATION DE GRANDISSEMENT UNIDIMENSIONNEL


C     on ajoute ce test pour eviter le cas 0**0
      IF (COEFGR(3).EQ.0.D0) THEN
        IF (IRRAP.EQ.0.D0) THEN
          MULP=0.D0
        ELSE
          MULP=(IRRAP**COEFGR(3))
        ENDIF
        IF (IRRAM.EQ.0.D0) THEN
          MULM=0.D0
        ELSE
          MULM=(IRRAM**COEFGR(3))
        ENDIF
      ELSE
        MULP=(IRRAP**COEFGR(3))
        MULM=(IRRAM**COEFGR(3))
      ENDIF

      DEPSGR = (COEFGR(1)*TP+COEFGR(2))*MULP-
     &         (COEFGR(1)*TM+COEFGR(2))*MULM

C     RECUPERATION DU REPERE POUR LE GRANDISSEMENT
      ALPHA = ANGMAS(1)
      IF ( ANGMAS(2) .NE. 0.D0 ) THEN
         CALL U2MESS('F','ALGORITH6_59')
      ENDIF

C     INCREMENT DEFORMATION DE GRANDISSEMENT DANS LE REPERE
      DEGRAN = DEPSGR*COS(ALPHA)*COS(ALPHA)
C     INCREMENT DEFORMATION ANELASTIQUE
      DEPSAN = DEFAP-DEFAM
C     INCREMENT DEFORMATION THERMIQUE
      DEPSTH = ALPHAP*(TP-TREF)-ALPHAM*(TM-TREF)
C     INCREMENT DEFORMATION IMPOSEE
      DEPSIM = DEPSTH+DEPSAN+DEGRAN

      EXPQT=EXP(-ENER/(TP+273.15D0))

      COEFB=EXPQT*((A*CTPS/(1.D0+CTPS*IRRAP))+B)*(IRRAP-IRRAM)
      COEF1 = EP/(1.D0+EP*COEFB)

C CONTRAINTE ACTUALISEE


      SIGP =COEF1*(SIGM/EM+DEPS-DEPSIM)

C DEFORMATION PLASTIQUE CUMULEE ACTUALISEE

      VIP  = VIM+(ABS(SIGP)*COEFB)

C MODULE TANGENT POUR MATRICE TANGENTE

      DSIDEP = COEF1

      END
