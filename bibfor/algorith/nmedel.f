      SUBROUTINE NMEDEL(NDIM,TYPMOD,IMATE,DEPS,SIGM,OPTION,SIGP,DSIDEP)
      
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 26/04/2005   AUTEUR LAVERNE J.LAVERNE 
C ======================================================================
C COPYRIGHT (C) 1991 - 2005  EDF R&D                  WWW.CODE-ASTER.ORG
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

      IMPLICIT NONE
      
      INTEGER            NDIM,IMATE
      CHARACTER*8        TYPMOD(*)
      CHARACTER*16       OPTION
      REAL*8             DEPS(6)
      REAL*8             SIGM(6),SIGP(6),DSIDEP(6,6)
      
C ----------------------------------------------------------------------
C     LOI ELASTIQUE POUR L'ELEMENT A DISCONTINUITE
C ----------------------------------------------------------------------
C
C IN  NDIM    : DIMENSION DE L'ESPACE
C IN  TYPMOD  : TYPE DE MODELISATION
C IN  IMATE   : ADRESSE DU MATERIAU CODE
C IN  DEPS    : INCREMENT DE DEFORMATION
C               SI C_PLAN DEPS(3) EST EN FAIT INCONNU (ICI:0)
C                 =>  ATTENTION LA PLACE DE DEPS(3) EST ALORS UTILISEE.
C IN  SIGM    : CONTRAINTES A L'INSTANT DU CALCUL PRECEDENT
C IN  OPTION  : OPTION DEMANDEE : RIGI_MECA_TANG , FULL_MECA , RAPH_MECA
C OUT SIGP    : CONTRAINTES A L'INSTANT ACTUEL
C OUT DSIDEP  : MATRICE CARREE (INUTILISE POUR RAPH_MECA)
C
C               ATTENTION LES TENSEURS ET MATRICES SONT RANGES DANS
C               L'ORDRE :  XX,YY,ZZ,SQRT(2)*XY,SQRT(2)*XZ,SQRT(2)*YZ
C-----------------------------------------------------------------------

      LOGICAL     CPLAN
      REAL*8      DEUXMU
      REAL*8      VALRES(3)
      REAL*8      DEPSMO,E,NU,TROISK
      REAL*8      KRON(6),DEPSDV(6)
      INTEGER     NDIMSI
      INTEGER     K,J
      CHARACTER*2 CODRET(3)
      CHARACTER*8 NOMRES(3)
      DATA        KRON/1.D0,1.D0,1.D0,0.D0,0.D0,0.D0/

C     INITIALISATIONS
C     ---------------

      CPLAN =  TYPMOD(1) .EQ. 'C_PLAN'
      NDIMSI = 2*NDIM

C     RECUPERATION DES CARACTERISTIQUES
C     ---------------------------------
      NOMRES(1)='E'
      NOMRES(2)='NU'

      CALL RCVALA ( IMATE,' ','ELAS',0,' ',0.D0,2,
     +                 NOMRES(1),VALRES(1),CODRET(1), 'F ' )
      E      = VALRES(1)
      NU     = VALRES(2)
            
      DEUXMU = E/(1.D0+NU)
      TROISK = E/(1.D0-2.D0*NU)


      IF (CPLAN) DEPS(3)=-NU/(1.D0-NU)*(DEPS(1)+DEPS(2))
     +                +(1.D0+NU)/(1.D0-NU)
     
      DEPSMO = (DEPS(1)+DEPS(2)+DEPS(3))/3.D0
      DO 115 K=1,NDIMSI
        DEPSDV(K)   = DEPS(K) - DEPSMO * KRON(K)
 115  CONTINUE


      DO 145 K = 1,NDIMSI
        SIGP(K) = SIGM(K)+DEUXMU*DEPSDV(K)+TROISK*DEPSMO*KRON(K)
 145  CONTINUE
 

C      CALCUL DE DSIDEP(6,6) :
C     ------------------------

      IF ( OPTION(1:14) .EQ. 'RIGI_MECA_TANG'.OR.
     &     OPTION(1:9)  .EQ. 'FULL_MECA'         ) THEN
     
        CALL R8INIR(36,0.D0,DSIDEP,1)

        DO 130 K=1,3
          DO 131 J=1,3
            DSIDEP(K,J) = TROISK/3.D0-DEUXMU/(3.D0)
 131      CONTINUE
 130    CONTINUE
        DO 120 K=1,NDIMSI
          DSIDEP(K,K) = DSIDEP(K,K) + DEUXMU
 120    CONTINUE

      ENDIF

      END
