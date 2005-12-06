      SUBROUTINE GDMB (NE,KP,AJACOB,EN,ENPRIM,X0PG,   B)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 02/10/95   AUTEUR GIBHHAY A.Y.PORTABILITE 
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
C FONCTION: POUR UN ELEMENT DE POUTRE EN GRAND DEPLACEMENT, CALCULE LA
C           CONTRIBUTION DU DEPLACEMENT DU NOEUD NE A LA MATRICE DE
C           DEFORMATION B AU POINT DE GAUSS KP.
C
C     IN  : NE        : NUMERO DU NOEUD
C           KP        : NUMERO DU POINT DE GAUSS
C           AJACOB    : JACOBIEN
C           EN        : FONCTIONS DE FORME
C           ENPRIM    : DERIVEES DES FONCTIONS DE FORME
C           X0PG      : DERIVEES DES COORDONNEES PAR RAP. A L'ABS. CURV.
C
C     OUT : B         : MATRICE DE DEFORMATION 6*6
C ------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      REAL*8 EN(3,2),ENPRIM(3,2),X0PG(3),B(6,6),AMAT(3,3)
C
      ZERO = 0.D0
      UN   = 1.D0
      DO 1 M=1,6
      DO 1 L=1,6
      B(L,M) = ZERO
    1 CONTINUE
      UNSURJ = UN / AJACOB
      FORM   = EN(NE,KP)
      FORMPR = UNSURJ * ENPRIM(NE,KP)
      DO 2 L=1,6
      B(L,L) = FORMPR
    2 CONTINUE
      CALL ANTISY (X0PG,UN,AMAT)
      DO 5 M=1,3
      DO 4 L=1,3
      B(L,M+3) = FORM * AMAT(L,M)
    4 CONTINUE
    5 CONTINUE
 9999 CONTINUE
      END
