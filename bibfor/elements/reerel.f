      SUBROUTINE REEREL(ELREFP,NNOP,NDIM,JTABAR,XE,XG)
      IMPLICIT NONE

      INTEGER       NDIM,NNOP,JTABAR
      REAL*8        XE(NDIM),XG(NDIM)
      CHARACTER*8   ELREFP


C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 20/12/2010   AUTEUR PELLET J.PELLET 
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
C                      TROUVER LES COORDONNEES REELLES D'UN POINT
C                      A PARTIR DE SES COORDONNEES DE REFERENCE
C
C     ENTREE
C       NDIM    : DIMENSION TOPOLOGIQUE DU MAILLAGE
C       IGEOM   : COORDONNEES DES NOEUDS DE L'ELEMENT
C       ELP     : TYPE DE L'ELEMENT
C       XE      : COORDONNES DE REFERENCE DU POINT
C
C     SORTIE
C       XG       : COORDONNES REELLES DU POINT
C......................................................................
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  ------------------------
      REAL*8           ZR
      COMMON  /RVARJE/ ZR(1)
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  ------------------------

      REAL*8      FF(NNOP)
      INTEGER     I,J,NBNOMX,NNO
      PARAMETER   (NBNOMX = 27)

C......................................................................

      CALL JEMARQ()

      CALL VECINI(NDIM,0.D0,XG)

C --- VALEURS DES FONCTIONS DE FORME EN XE: FF
C
      IF (ELREFP(1:2).EQ.'SE') THEN
        CALL ELRFVF(ELREFP,XE(1),NBNOMX,FF,NNO)
      ELSE
        CALL ELRFVF(ELREFP,XE,NBNOMX,FF,NNO)
      ENDIF

C
C --- COORDONNES DU POINT DANS L'ELEMENT REEL
C
      DO 100 J=1,NDIM
        DO 200 I=1,NNOP
          XG(J) = XG(J) + ZR(JTABAR-1+NDIM*(I-1)+J)*FF(I)
 200    CONTINUE
 100  CONTINUE

      CALL JEDEMA()
      END
