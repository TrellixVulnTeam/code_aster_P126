      SUBROUTINE WMEOF(
     + ICLASS,IVAL,CVAL,FIN,FINM,FINEOF,IRTETI)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CATAELEM  DATE 12/05/97   AUTEUR JMBHH01 J.M.PROIX 
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
C
      COMMON /CIMP/ IMP,IULMES,IULIST,IULVIG
C
C
C     ICLASS,IVAL,CVAL ---> CE QUI A ETET LU
C
C     ON ATTEND UN MOT QUELCONQUE OU EOF ( ICLASS = -1 )
C
C    SI MOT  FIN<-- FINM
C    SI EOF  FIN<-- FINEOF
C    SINON  RETURN *
C
      INTEGER FIN,FINM,FINEOF
      CHARACTER*(*) CVAL
      INTEGER MOT,EOF,ERREUR
C
C     ASSIGN 100 TO ERREUR
      ASSIGN 200 TO MOT
      ASSIGN 300 TO EOF
      IRTETI = 0
C
      IF ( ICLASS.EQ.-1) THEN
       GOTO EOF
      ELSE IF ( ICLASS.EQ.3) THEN
       GOTO MOT
C     ELSE
C      GOTO ERREUR
      ENDIF
C
C 100 CONTINUE
      CALL UTMESS('F','WMEOF','PB. LECTURE CATALOGUES.')
      IRTETI = 1
      GOTO 9999
  200 CONTINUE
      FIN = FINM
      IRTETI = 0
      GOTO 9999
  300 CONTINUE
      FIN = FINEOF
      IRTETI = 0
 9999 CONTINUE
      END
