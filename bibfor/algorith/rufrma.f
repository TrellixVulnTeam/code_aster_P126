      SUBROUTINE RUFRMA(IMATE,TEMP)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 21/12/1999   AUTEUR UFBHHLL C.CHAVANT 
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

      IMPLICIT NONE
      INTEGER  IMATE
      REAL*8   TEMP

C ----------------------------------------------------------------------
C  RUPTURE FRAGILE (RUFRAG) : CARACTERISTIQUES MATERIAU
C ----------------------------------------------------------------------
C IN  IMATE   NATURE DU MATERIAU
C IN  TEMP    TEMPERATURE EN T+
C ----------------------------------------------------------------------
C OUT RUFRC0 COMMON CARACTERISTIQUES DU MATERIAU (AFFECTE DANS RUFRMA)

      REAL*8 E, NU, ALPHA, LAMBDA, DEUXMU
      REAL*8 GC
      REAL*8 C, RIGMIN

      COMMON /RUFRC0/
     &         E  , NU , ALPHA , LAMBDA , DEUXMU ,
     &         GC ,
     &         C  , RIGMIN
C ----------------------------------------------------------------------

      CHARACTER*2 CODRET(3)
      CHARACTER*8 NOMRES(3)
      REAL*8      VALRES(3)


C - LECTURE DES CARACTERISTIQUES ELASTIQUES
      NOMRES(1) = 'E'
      NOMRES(2) = 'NU'
      NOMRES(3) = 'ALPHA'

      CALL RCVALA ( IMATE,'ELAS',1,'TEMP',TEMP,2,
     &              NOMRES,VALRES,CODRET, 'FM')
      CALL RCVALA ( IMATE,'ELAS',1,'TEMP',TEMP,1,
     &              NOMRES(3),VALRES(3),CODRET(3), '  ')

      IF (CODRET(3).NE.'OK') VALRES(3) = 0.D0

      E     = VALRES(1)
      NU    = VALRES(2)
      ALPHA = VALRES(3)
      LAMBDA = E * NU / (1.D0+NU) / (1.D0 - 2.D0*NU)
      DEUXMU = E/(1.D0+NU)


C    LECTURE DU PARAMETRE DE RUPTURE FRAGILE

C    GC : TENACITE (DENSITE D'ENERGIE DE SURFACE)
      NOMRES(1) = 'GC'

      CALL RCVALA(IMATE,'RUPT_FRAG',1,'TEMP',TEMP,1,
     &            NOMRES,VALRES,CODRET,'FM')

      GC = VALRES(1)


C    LECTURE DES PARAMETRES DE DELOCALISATION

C    LONGUEUR CARACTERISTIQUE
      NOMRES(1) = 'LONG_CARA'

C    RIGIDITE MINIMALE
      NOMRES(2) = 'COEF_RIGI_MINI'

      CALL RCVALA(IMATE,'NON_LOCAL',1,'TEMP',TEMP,2,
     &            NOMRES,VALRES,CODRET,'FM')

      C = VALRES(1)
      RIGMIN = VALRES(2)

      END
