      SUBROUTINE MEGANO(OPTION,MODELE,COMPOR,CHAIN,CHAOUT,CHGEOM,CARELE,
     &                  MATE,DEPPLU,TEMPLU)
C MODIF CALCULEL  DATE 11/09/2002   AUTEUR VABHHTS J.PELLET 
C ======================================================================
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
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
      CHARACTER*24 COMPOR,CHGEOM,CARELE,DEPPLU,CHCARA(15),TEMPLU
      CHARACTER*16 OPTION
      CHARACTER*24 MODELE
      CHARACTER*(*) CHAIN,CHAOUT,MATE
C ----------------------------------------------------------------------
C     PASSAGE D'UN CHAMELEM DES POINTS DE GAUSS AUX NOEUDS

C IN  OPTION : OPTION DE CALCUL
C IN  MODELE : NOM DU MODELE
C IN  CHAIN  : CHAMELEM EN ENTREE
C IN  CHGEOM : CHAMP DE GEOMETRIE
C IN  CARELE : CARACTERISTIQUES ELEMENTAIRES
C IN  MATE   : CHAMP DE MATERIAU
C IN  DEPPLU : CHAM_NO DE DEPLACEMENT
C IN  TEMPLU : CHAM_NO DE TEMPERATURE

C OUT CHAOUT : CHAMELEM EN SORTIE

C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------

      CHARACTER*32 JEXNUM,JEXNOM,JEXR8,JEXATR
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

C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------

      INTEGER NBC
      CHARACTER*8 LPAIN(10),LPAOUT(1),NOMGD
      CHARACTER*24 LCHIN(10),LCHOUT(1),LIGRMO
      CHARACTER*19 CHTEM2
      LOGICAL EXICAR

      CALL JEMARQ()
      CHTEM2 = TEMPLU

      CALL MECARA(CARELE,EXICAR,CHCARA)

      IF (MODELE(1:1).EQ.' ') THEN
        CALL UTMESS('F','MEGANO_01','IL MANQUE LE MODELE')
      END IF

      LCHOUT(1) = CHAOUT
      LCHIN(1) = CHAIN
      LIGRMO = MODELE(1:8)//'.MODELE'
      NBC = 1

      IF (OPTION.EQ.'SIEF_ELNO_ELGA  ') THEN
        LPAOUT(1) = 'PSIEFNOR'
        LPAIN(1) = 'PCONTRR'
        LPAIN(2) = 'PGEOMER'
        LCHIN(2) = CHGEOM
        LPAIN(3) = 'PMATERC'
        LCHIN(3) = MATE
        LPAIN(4) = 'PCAGNPO'
        LCHIN(4) = CARELE(1:8)//'.CARGENPO'
        LPAIN(5) = 'PCAORIE'
        LCHIN(5) = CARELE(1:8)//'.CARORIEN'
        LPAIN(6) = 'PDEPPLU'
        LCHIN(6) = DEPPLU
        LPAIN(7) = 'PCOMPOR'
        LCHIN(7) = COMPOR
        LPAIN(8) = 'PCACOQU'
        LCHIN(8) = CHCARA(7)
        LPAIN(9) = 'PCAGEPO'
        LCHIN(9) = CHCARA(5)
C     -- ON TESTE LA NATURE DU CHAMP DE TEMPERATURE
        CALL EXISD('CHAMP_GD',CHTEM2,IRET)
        IF (IRET.GT.0) THEN
          CALL DISMOI('F','NOM_GD',CHTEM2,'CHAMP',IBID,NOMGD,IERD)
          IF (NOMGD.EQ.'TEMP_R') THEN
            LPAIN(10) = 'PTEMPER'
          ELSE IF (NOMGD.EQ.'TEMP_F') THEN
            LPAIN(10) = 'PTEMPEF'
          ELSE
            CALL UTMESS('F','MEGANO','GRANDEUR INCONNUE.')
          END IF
          LCHIN(10) = CHTEM2
        ELSE
          LPAIN(10) = ' '
          LCHIN(10) = ' '
        END IF
        NBC = 10
      ELSE IF (OPTION.EQ.'VARI_ELNO_ELGA  ') THEN
        NBC = 2
        LPAOUT(1) = 'PVARINR'
        LPAIN(1) = 'PVARIGR'
        LPAIN(2) = 'PCOMPOR'
        LCHIN(2) = COMPOR
      ELSE
        CALL UTDEBM('F','MEGANO_02',' ')
        CALL UTIMPK('S','OPTION INCONNUE',1,OPTION)
        CALL UTFINM()
      END IF

      IF (OPTION.EQ.'VARI_ELNO_ELGA  ') THEN
        CALL EXISD('CHAM_ELEM_S',COMPOR,IRET)
        IF (IRET.EQ.0) CALL CESVAR(CARELE,COMPOR,LIGRMO,COMPOR)
        CALL COPISD('CHAM_ELEM_S','V',COMPOR,LCHOUT(1))
      END IF

      CALL CALCUL('S',OPTION,LIGRMO,NBC,LCHIN,LPAIN,1,LCHOUT,LPAOUT,'G')
      CALL DETRSD('CHAM_ELEM_S',LCHOUT(1))

   10 CONTINUE
C FIN ------------------------------------------------------------------
      CALL JEDEMA()
      END
