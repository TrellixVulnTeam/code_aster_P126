      SUBROUTINE GGPLEM(S,DPC,T,VALDEN,UNSURK,UNSURM,DEUXMU,
     *                  G,DGDST,DGDEV)
      IMPLICIT REAL*8 (A-H,O-Z)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 04/01/95   AUTEUR G8BHHAC A.Y.PORTABILITE 
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
C
CDEB
C---------------------------------------------------------------
C     VITESSE DE DEF. VISQUEUSE ET SA DERIVEE PAR RAPPORT A SIGMA
C---------------------------------------------------------------
C IN  S     :R: CONTRAINTE EQUIVALENTE SIGMA
C     DPC   :R: SCALAIRE RESUMANT L'ETAT VISCOPLASTIQUE DU POINT
C               CONSIDERE DU MATERIAU (DEFORM. PLASTIQUE CUMULEE)
C     T     :R: TEMPERATURE DU POINT CONSIDERE
C     VALDEN:R: VALEUR DE N
C     UNSURK:R: PARAMETRE 1/K
C     UNSURM:R: PARAMETRE 1/M
C OUT G     :R: VALEUR DE LA FONCTION G
C     DGDST :R: DERIVEE TOTALE DE G PAR RAPPORT A SIGMA
C     DGDEV :R: DERIVEE PARTIELLE DE G PAR RAPPORT A EV (I.E. DPC)
C---------------------------------------------------------------
C            DANS LE CAS DE LA LOI DE LEMAITRE,
C     CETTE ROUTINE CALCULE LA FONCTION G DE LA FORMULATION
C       "STRAIN HARDENING" DE L'ECOULEMENT VISCOPLASTIQUE
C       (LOI DONNEE SOUS FORME "STRAIN HARDENING")
C            .
C            EV = G(SIGMA,LAMBDA,T)
C
C     ET LA DERIVEE TOTALE DE CETTE FONCTION G PAR RAPPORT A SIGMA
C---------------------------------------------------------------
CFIN
C
      IF (S.EQ.0.D0.OR.DPC.EQ.0.D0.OR.UNSURK.EQ.0.D0)THEN
        G = 0.D0
        DGDST = 0.D0
        DGDEV = 0.D0
        GO TO 99
      ELSE
        IF (UNSURM.EQ.0.D0) THEN
          G = EXP(VALDEN*LOG(S*UNSURK))
          DGDST = VALDEN*G/S
          DGDEV = 0.D0
        ELSE
          G = EXP(VALDEN*(LOG(S*UNSURK)-UNSURM*LOG(DPC)))
          DGDST = VALDEN*(1.D0/S+UNSURM/(1.5D0*DEUXMU*DPC))*G
          DGDEV = - VALDEN*G*UNSURM/DPC
        ENDIF
      ENDIF
        G = G*0.5D0
        DGDST = DGDST*0.5D0
        DGDEV = DGDEV*0.5D0
   99 CONTINUE
C
      END
