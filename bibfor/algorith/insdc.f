      SUBROUTINE INSDC(S1X,EDC,EPST,EDT,RTM,EPSC,DEFR,SIGRX,
     1   STRNX,STRNRX,EPSRX,IFISU,JFISU,SIGMRX,IPLA,TANG,IDIR)
        IMPLICIT REAL*8 (A-H,O-Z)
C       -----------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 27/03/2002   AUTEUR VABHHTS J.PELLET 
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
C       -----------------------------------------------------------
C       NADAI_B :  BETON FISSURE
C
C   CE SOUS-PROGRAMME CALCULE LA CONTRAINTE REELLE S1X LORSQU'IL Y A
C   DECHARGE (ENDOMMAGEE) A PARTIR DE LA COURBE DE COMPRESSION 1-D
C                            1 :  HYPER-SOFTENING (KRISHNAN)
C                            2 :  PARABOLE-RECTANGLE
C                            3 :  HYPERBOLE-RECTANGLE
C ENTREES :
C           SIGRX : CONTRAINTE  A T
C           SIGMRX: PREDICTEUR ELASTIQUE SIGRX+DSIG
C           EPSRX : DEFORMATION TOTALE A T
C           STRNX : INCREMENT DE DEFORMATION
C
C  E/S :IFISU,IPLA,EQSTR,EPSEQ,JFISU,TANG,EPST,EPSC,EDC,EDT,RTM,DEFR
C        CE SONT TOUTES DES VARIABLES INTERNES, VOIR LEUR
C        SIGNIFICATION DANS LA PROCEDURE  INSPIF
C
C SORTIES :  S1X :  CONTRAINTE UNIAXIALE A T+DT
C       -----------------------------------------------------------
      INTEGER   IFISU,IPLA,JFISU,IDIR,ICU
      REAL*8  EPSRX,STRNX,STRNRX,SIGMRX,SIGRX,TANG,S1X,EDT,EDC,EPST
      REAL*8  EPSC,DEFR,RTM,EQSTR,PF,RBT,ALPHA,EX,RB,EMAX,PENT,EPO1
      COMMON /CARMA/ EX,RB,ALPHA,EMAX,PENT,ICU
      COMMON /DBETO/ POU1(4),RBB,ALPH,EXX,PXY,EMAXX,EPSUT,FTC,FLIM,
     &    EPO,EPO1,POU2(6),ICC,IPOU1(9)
C------------------------------------------------------------------
      ZERO = 0.D0
      TOL  = 1.D-10
      RBT  = ALPHA*RB
      PF   = RB / EX
C
      IF(ABS(EDC).LT.0.1D-5) EDC=0.D0
      IF(EDC.EQ.0.D0.OR.(EPSRX.LT.EPSC.AND.EPSC.NE.0.D0)) THEN
C
C       CALCULS DE EDC,DEFR,RTM,EPSC,EPST
C
C     DEUX CAS PEUVENT SE PRESENTER :  1- POINT INTEGRE
C                                      2- POINT DEJA FISSURE
C
C
C       PENTE ENDOMMAGEE
C
      SEQ = -1.D0*ABS(SIGRX)
      IF( ABS(EPSRX-PF) .GT. 1.D-5 ) THEN
        EDC = ( SEQ - RB ) / ( EPSRX - PF )
      ELSE
        EDC = EX
      ENDIF
      IF( EDC .GT. EX .OR. ABS(EDC) .LT. 1.D-5 ) EDC = EX
      DEFR = RB * ( 1.D0 / EX - 1.D0 / EDC )
C----------------------------------------------------------
C
      IF ( ABS(DEFR) .LT. TOL .AND. ABS(EPSRX) .LT. TOL ) THEN
       DEFR  = ZERO
       EPSC  = ZERO
       S1X   = ZERO
       GOTO 9999
      ENDIF
C
C       RESISTANCE EN TRACTION MODIFIEE
C
      EPOC = -1.D0 * EPO1
      IF ( DEFR .LT. EPOC ) THEN
        RTMC = ZERO
      ELSE
        AS2  = RBT/(EPO1+RBT/EX)
        IF(ABS(EDC-AS2).GT.1.D-5) THEN
          EPS1 = (EDC*DEFR-AS2*EPOC)/(EDC-AS2)
          RTMC = EDC*(EPS1-DEFR)
        ELSE
          RTMC = ZERO
        ENDIF
C
        IF(RTMC.GT.RBT) RTMC = RBT
      ENDIF
C
      IF ( RTMC .LT. ZERO ) RTMC = ZERO
      IF ( RTMC .LT. RTM  ) RTM = RTMC
C
C    MEMORISATION DE LA DEFORMATION A L'INSTANT DE LA DECHARGE (EPSC)
C
      EPSC = EPSRX
C
C       CALCUL DE LA DEFORMATION CORRESPONDANT A -RBT
C
      IF(ABS(EDC).LT.1.D-5) EDC=EX
      EPST=DEFR-RBT/EDC
C
C     DANS LE CAS OU LA DECHARGE S EFFECTUE DANS LE REGIME POST-PIC EN
C     COMPRESSION, EN DESSOUS DU NIVEAU ABS(RBT), ON MEMORISE EPSC
C
      IF(IPLA.EQ.1.AND.ABS(SIGRX).LE.RBT) EPST=EPSC
      ENDIF
C=======================================================================
C        CAS OU LE POINT A DEJA SUBIT UNE DECHARGE (EDC .NE. 0)
C=======================================================================
C
C   CALCUL DE LA CONTRAINTE A T+DT
C   DECHARGE D'UN POINT INTEGRE OU DECHARGE D'UN POINT INITIALLEMENT
C    FISSURE AVANT L'ATTEINTE DE LA PENTE EDT
C
      S1X=SIGRX+STRNX*EDC
      TANG=EDC
      IF(IPLA.EQ.1.AND.ABS(SIGRX).LE.RBT) GOTO 10
C
C       POINT INITIALLEMENT FISSURE
C
      IF(JFISU.EQ.1. AND. STRNRX .GT. EPST) THEN
C
C       ON EST SUR LA PENTE EDT
C
      S1X=-RBT+EDT*(STRNRX-EPST)
      TANG=EDT
      ENDIF
   10 CONTINUE
      IF(S1X.GE.RTM) THEN
C
C      1ERE FISSURATION APRES DECHARGE EN COMPRESSION (TANG=EDC)
C       OU REOUVERTURE DE LA FISSURE (TANG=EDT)
C
      CALL INSFI2 (S1X,SIGRX,STRNX,RTM,PENT,TANG)
       IFISU=1
       JFISU=1
      ENDIF
 9999 CONTINUE
      END
