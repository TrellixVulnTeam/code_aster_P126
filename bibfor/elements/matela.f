      SUBROUTINE MATELA(ICODMA,ITEMP,TEMP,E,NU,ALPHA)
      IMPLICIT REAL*8 (A-H,O-Z)
      REAL*8 TEMP,E,NU,ALPHA
      INTEGER ICODMA,ITEMP
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 29/04/2004   AUTEUR JMBHH01 J.M.PROIX 
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
C     RECUPERATION DES VALEURS DE E, NU, ALPHA
C     FONCTION EVENTUELLEMENT DE LA TEMPERATURE TEMP
C     COMPORTEMENT : 'ELAS'
C     ------------------------------------------------------------------
C IN  ICODMA : IS  : ADRESSE DU MATERIAU CODE
C IN  ITEMP  : IS  : =0 : PAS DE TEMPERATURE
C IN  TEMP   : R8  : VALEUR DE LA TEMPERATURE
C
C OUT E      : R8  : MODULE D'YOUNG
C OUT NU     : R8  : COEFFICIENT DE POISSON
C OUT ALPHA  : R8  : COEFFICIENT DE DILATATION
C
      INTEGER NBRES,NBPAR,I
      PARAMETER    (NBRES=3)
      REAL*8       VALPAR,VALRES(NBRES)
      CHARACTER*2    BL2, CODRES(NBRES)
      CHARACTER*8  NOMPAR,NOMRES(NBRES)
      DATA NOMRES / 'E', 'NU', 'ALPHA'/
      BL2 = '  '
      IF ( ITEMP .EQ. 0 ) THEN
         NBPAR  = 0
         NOMPAR = ' '
         VALPAR = 0.D0
      ELSE
         NBPAR  = 1
         NOMPAR = 'TEMP'
         VALPAR = TEMP
      ENDIF
      DO 10 I=1, NBRES
        VALRES(I) = 0.D0
 10   CONTINUE
      CALL RCVALA(ICODMA,' ','ELAS',NBPAR,NOMPAR,VALPAR,2,
     +              NOMRES, VALRES, CODRES, 'FM' )
      CALL RCVALA(ICODMA,' ','ELAS',NBPAR,NOMPAR,VALPAR,1,
     +              NOMRES(3), VALRES(3), CODRES(3), BL2 )
      IF ( CODRES(3) .NE. 'OK' )  VALRES(3) = 0.D0
      E      = VALRES(1)
      NU     = VALRES(2)
      ALPHA  = VALRES(3)
      END
