      SUBROUTINE IBCATC(TYPE,IUNIT,TITRE,IER)
      IMPLICIT REAL*8 (A-H,O-Z)
      CHARACTER*(*)     TYPE,      TITRE
      INTEGER                IUNIT,      IER
C     -----------------------------------------------------------------
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
C MAIN DE LA LECTURE DES CATALOGUE
C     -----------------------------------------------------------------
C
      COMMON /CIMP/ IMP,IULMES,IULIST,IULVIG
C
      IF(TYPE .EQ. 'CATAELEM' ) THEN
         CALL INCCAT
         IF ( IMP.GT.0) WRITE(IMP,*) TITRE
         CALL LCCATA(IUNIT)
      ELSEIF(TYPE .EQ. 'ELEMBASE' ) THEN
         CALL IBCAEL('LIRE',TITRE)
      ENDIF

      IER=0
      END
