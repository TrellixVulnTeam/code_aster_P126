      SUBROUTINE PERMLO(TAB,SHIFT,NBR)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILIFOR  DATE 20/12/2010   AUTEUR PELLET J.PELLET 
C TOLE CRS_1404
C ======================================================================
C COPYRIGHT (C) 1991 - 2010  EDF R&D                  WWW.CODE-ASTER.ORG
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
      INTEGER       SHIFT,NBR
      LOGICAL       TAB(NBR)

C-----------------------------------------------------------------------
C PERMUTATION CIRCULAIRE DES ELEMENTS D'UN TABLEAU DE LOGICAL
C
C IN : TAB   = TABLEAU A PERMUTER
C      SHIFT = INDICE DU TABLEAU PAR LEQUEL ON SOUHAITE DEBUTER
C      NBR   = NOMBRE D'ELEMENTS DU TABLEAU
C
C OUT : TAB = TABLEAU AVEC PERMUTATION
C
C-----------------------------------------------------------------------

      INTEGER I
      LOGICAL TAMPON(NBR)

      CALL ASSERT((SHIFT.GE.1).AND.(SHIFT.LE.NBR))

      DO 10 I=1,NBR
        TAMPON(I) = TAB( MOD(I+SHIFT-2,NBR) + 1 )
  10  CONTINUE

      DO 20 I=1,NBR
        TAB(I) = TAMPON(I)
  20  CONTINUE

      END
