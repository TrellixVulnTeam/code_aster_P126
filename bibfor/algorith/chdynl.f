      SUBROUTINE CHDYNL ( POINTM,POINTA,LAMORT,VIT,ACC,   FORDYN)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 30/01/95   AUTEUR G8BHHAC A.Y.PORTABILITE 
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
      INTEGER POINTM,POINTA
      LOGICAL LAMORT
      REAL*8 VIT(*), ACC(*), FORDYN(*)
C ----------------------------------------------------------------------
C     D Y N A M I Q U E  N O N  L I N E A I R E
C     CALCUL DES CHARGES DYNAMIQUES
C
C  IN :
C
C  OUT FORDYN : VECTEUR DES FORCES DYNAMIQUES
C
C
C ----------------------------------------------------------------------
      CALL MRMULT ('ZERO',POINTM,ACC,'R',FORDYN,1)
      IF (LAMORT) THEN
        CALL MRMULT ('CUMU',POINTA,VIT,'R',FORDYN,1)
      ENDIF
      END
