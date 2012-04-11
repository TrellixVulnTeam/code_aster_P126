      SUBROUTINE MEMZME(MODELE,MATEL)
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 10/04/2012   AUTEUR DELMAS J.DELMAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
C (AT YOUR OPTION) ANY LATER VERSION.

C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.

C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
      IMPLICIT REAL*8 (A-H,O-Z)
C     CALCUL DES MATRICES ELEMENTAIRES DE MASSE MECA

C ----------------------------------------------------------------------
C IN  : MODELE : NOM DU MODELE (OBLIGATOIRE)
C IN  : MATEL  : NOM DU MATR_ELEM RESULTAT
C ----------------------------------------------------------------------
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C ----------------------------------------------------------------------
      LOGICAL EXIGEO
      CHARACTER*19 MATEL
      CHARACTER*8 LPAIN(1),LPAOUT(1),MODELE
      CHARACTER*24 LIGRMO,LCHIN(1),LCHOUT(1),OPTION,CHGEOM

      CALL JEMARQ()
      IF (MODELE(1:1).EQ.' ') CALL U2MESS('F','CALCULEL2_82')

      CALL MEGEOM(MODELE,' ',EXIGEO,CHGEOM)
      IF (.NOT.EXIGEO) CALL U2MESS('F','CALCULEL3_63')

      CALL MEMARE('V',MATEL,MODELE,' ',' ','MASS_ZZ1')
      CALL JEVEUO(MATEL//'.RERR','E',IAREFE)
      ZK24(IAREFE-1+3) (1:3) = 'OUI'

      CALL JEDETR(MATEL//'.RELR')

      LPAOUT(1) = 'PMATZZR'
      LCHOUT(1) = MATEL(1:8)//'.ME001'

      LIGRMO = MODELE//'.MODELE'
      LPAIN(1) = 'PGEOMER'
      LCHIN(1) = CHGEOM

      OPTION = 'MASS_ZZ1'
      CALL CALCUL('S',OPTION,LIGRMO,1,LCHIN,LPAIN,1,LCHOUT,LPAOUT,'V',
     &               'OUI')
      CALL REAJRE(MATEL,LCHOUT(1),'V')

      CALL JEDEMA()
      END
