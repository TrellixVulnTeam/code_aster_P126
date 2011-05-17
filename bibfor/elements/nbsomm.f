      SUBROUTINE NBSOMM(TYPEMA,NBSO)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 16/05/2011   AUTEUR PELLET J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2011  EDF R&D                  WWW.CODE-ASTER.ORG
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
      CHARACTER*8 TYPEMA
      INTEGER NBSO
C
C     DONNE LE NOMBRE DE SOMMETS POUR UN TYPE DE MAILLES
C
      IF (TYPEMA(1:4).EQ.'HEXA') THEN
        NBSO=8
      ELSEIF (TYPEMA(1:4).EQ.'PENT') THEN
        NBSO=6
      ELSEIF (TYPEMA(1:4).EQ.'TETR') THEN
        NBSO=4
      ELSEIF (TYPEMA(1:4).EQ.'QUAD') THEN
        NBSO=4
      ELSEIF (TYPEMA(1:4).EQ.'TRIA') THEN
        NBSO=3
      ELSEIF (TYPEMA(1:3).EQ.'SEG') THEN
        NBSO=2
      ELSE
C CONDITIONS AUX LIMITES PONCTUELLES (POUR MODELE ENDO_HETEROGENE)
        NBSO=1
C
      ENDIF
      END
