      SUBROUTINE NMFIFI(TYPMOD,GEOM,SIGMA,FINT)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 26/03/2002   AUTEUR LAVERNE J.LAVERNE 
C ======================================================================
C COPYRIGHT (C) 1991 - 2002  EDF R&D                  WWW.CODE-ASTER.ORG
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
C                                                                       
C                                                                       
C ======================================================================

      IMPLICIT NONE
      REAL*8  GEOM(2,4),SIGMA(2),FINT(8)
      CHARACTER*8 TYPMOD(2)
     
C***********************************************************************
C
C BUT: 
C      CALCUL DES FINT = ( B_T SIGMA) POUR L'OPTION FORC_NODA
C      SUBROUTINE APPELEE DANS LE TE0202
C
C IN  : GEOM,SIGMA
C OUT : FINT
C I/O :
C
C***********************************************************************

      LOGICAL AXI
      INTEGER I,J
      REAL*8  AIRE, B(2,8)     
                  
      AXI = TYPMOD(1).EQ.'AXIS'
      
C CALCUL DE L'AIRE DES PAROIS DE LA FISSURE :
C  * EN 2D ON CONSIDERE QUE L'EPAISSEUR EST DE 1 DONC 
C    L'AIRE EST EGALE A : 1*(LONGUEUR DE L'ELEMENT) 
C  * EN AXIS ON MULTIPLIE CETTE LONGEUR PAR LA DISTANCE DU CENTRE DE 
C    L'ELEMENT A L'AXE DE SYMETRIE.

      AIRE = SQRT( (GEOM(1,2)-GEOM(1,1))**2 + (GEOM(2,2)-GEOM(2,1))**2 )
      IF (AXI) AIRE = AIRE * (GEOM(1,1)+GEOM(1,2))/2.D0
          
C CALCUL DE LA MATRICE B DONNANT LES SAUT PAR ELEMENTS A PARTIR DES 
C DEPLACEMENTS AUX NOEUDS :  
C LE CHANGEMENT DE REPERE EST INTEGRE DANS LA MATRICE B (VOIR NMFISA) 

      CALL NMFISA(GEOM,B)
      

C CALCUL DES FINT = ( B_T SIGMA ) :
          
      DO 20 I=1,8
        FINT(I) = 0.D0
        DO 40 J=1,2          
          FINT(I) = FINT(I) +  AIRE*B(J,I)*SIGMA(J)
 40     CONTINUE
 20   CONTINUE

      END
