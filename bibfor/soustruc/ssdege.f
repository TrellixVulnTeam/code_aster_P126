      SUBROUTINE SSDEGE(NOMU)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF SOUSTRUC  DATE 22/10/2007   AUTEUR PELLET J.PELLET 
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
C     ARGUMENTS:
C     ----------
      CHARACTER*8 NOMU
C ----------------------------------------------------------------------
C     BUT:
C        - TRAITER LES MOTS CLEFS "DEFINITION" ET "EXTERIEUR"
C          DE LA COMMANDE MACR_ELEM_STAT.
C        - CREER LES OBJETS .REFM .LICA .LICH .VARM .DESM .LINO
C
C     IN:
C        NOMU : NOM DU MACR_ELEM_STAT QUE L'ON DEFINIT.
C
C ---------------- COMMUNS NORMALISES  JEVEUX  -------------------------
      COMMON /IVARJE/ZI(1)
      COMMON /RVARJE/ZR(1)
      COMMON /CVARJE/ZC(1)
      COMMON /LVARJE/ZL(1)
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      CHARACTER*8  KBI81,KBI82,NOMA,NOMO,NOMGD,KBID,PROMES
      LOGICAL LOK,LMESS
      INTEGER ZI
      REAL*8 ZR,TIME ,JEVTBL
      COMPLEX*16 ZC
      LOGICAL ZL
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16,PHENO
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32,JEXNUM,JEXNOM
      CHARACTER*80 ZK80
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL GETVID('DEFINITION','CHAR_MACR_ELEM',1,1,0,KBI81,N1)
      NCHAR=-N1
C
      CALL WKVECT(NOMU//'.REFM','G V K8',9+NCHAR,IAREFM)
C
C     -- RECUPERARTION DES NOMS DES REFERENCES:
C     -----------------------------------------
      CALL GETVID('DEFINITION','MODELE',1,1,1,NOMO,N1)
C
      CALL DISMOI('F','NOM_MAILLA',NOMO,'MODELE',IBI,NOMA,IER)
      CALL DISMOI('F','PHENOMENE',NOMO,'MODELE',IBI,PHENO,IER)
      CALL DISMOI('F','NOM_GD',PHENO,'PHENOMENE',IBI,NOMGD,IER)
      CALL DISMOI('F','NB_EC',NOMGD,'GRANDEUR',NBEC,KBID,IER)
C
      ZK8(IAREFM-1+1)= NOMO
      ZK8(IAREFM-1+2)= NOMA
      CALL GETVID('DEFINITION','CHAM_MATER',1,1,1,KBI81,N1)
      IF (N1.NE.0) ZK8(IAREFM-1+3)=KBI81
      CALL GETVID('DEFINITION','CARA_ELEM',1,1,1,KBI81,N1)
      IF (N1.NE.0) ZK8(IAREFM-1+4)=KBI81
C
      ZK8(IAREFM-1+6)= 'NON_RIGI'
      ZK8(IAREFM-1+7)= 'NON_MASS'
      ZK8(IAREFM-1+8)= 'NON_AMOR'

      CALL GETVID('DEFINITION','PROJ_MESU',1,1,1,PROMES,IER)
      IF (IER.EQ.0) THEN
        ZK8(IAREFM-1+9)= ' '
      ELSE
        ZK8(IAREFM-1+9)= PROMES
      ENDIF
C
C     -- RECUPERARTION DU NOM DES CHARGES CINEMATIQUES:
C     -------------------------------------------------
      IF (NCHAR.GT.0) THEN
         CALL GETVID('DEFINITION','CHAR_MACR_ELEM',1,1,
     &                     NCHAR,ZK8(IAREFM-1+9+1),N1)
      END IF
C
C     -- CREATION DES OBJETS .LICA ET .LICH:
C     --------------------------------------
      CALL GETVIS('DEFINITION','NMAX_CAS',1,1,1,NBC,N1)
      NBC= MAX(NBC,1)
      CALL JECREC(NOMU//'.LICA','G V R','NO','DISPERSE','CONSTANT',NBC)
      CALL JECREC(NOMU//'.LICH','G V K8','NO','CONTIG','CONSTANT',NBC)
      CALL GETVIS('DEFINITION','NMAX_CHAR',1,1,1,NCH,N1)
      CALL JEECRA(NOMU//'.LICH','LONMAX',NCH,KBID)
C
C
C     -- CREATION DE L'OBJET .VARM:
C     ------------------------------
      CALL GETVR8('DEFINITION','INST',1,1,1,TIME,N1)
      CALL WKVECT(NOMU//'.VARM','G V R',2,JVARM)
      ZR(JVARM-1+1)=JEVTBL()
      ZR(JVARM-1+2)=TIME
C
C
C     -- CREATION DE L'OBJET .DESM:
C     ------------------------------
      CALL WKVECT(NOMU//'.DESM','G V I',10,JDESM)
C
C
C     -- CREATION ET REMPLISSAGE DE L'OBJET .EXTERN  (VOLATILE)
C        (QUI CONTIENT UNE LISTE PROVISOIRE DES NOEUDS EXTERNES)
C     -----------------------------------------------------------
      CALL SSDEU1('NOMBRE',NOMA,NBNOTO,IBID)
      CALL WKVECT(NOMU//'.EXTERN','V V I',NBNOTO,IAEXTE)
      CALL SSDEU1('LISTE',NOMA,NBNOTO,ZI(IAEXTE))
C
C
C     -- ON MET "A ZERO" LES NOEUDS EXTERNES QUI NE PORTENT
C        AUCUN DDL POUR LE MODELE.
C     --------------------------------------------------------
      CALL JEVEUO(NOMO//'.MODELE    .PRNM','L',IAPRNM)
      LMESS=.FALSE.
      DO 11, II=1,NBNOTO
         INO=ZI(IAEXTE-1+II)
         DO 12, IEC=1,NBEC
            IF (ZI(IAPRNM-1+NBEC*(INO-1)+IEC).NE.0) GO TO 11
            ZI(IAEXTE-1+II)=0
            LMESS=.TRUE.
 12      CONTINUE
 11   CONTINUE
      IF (LMESS) THEN
         CALL U2MESS('A','SOUSTRUC_41')
      END IF
C
C
C     -- ELIMINATION DES NOEUDS EXTERNES EN DOUBLE :
C     ----------------------------------------------
      CALL SSDEU2(NBNOTO,ZI(IAEXTE),NVALAP)
      IF (NVALAP.NE.NBNOTO) THEN
         CALL U2MESS('A','SOUSTRUC_42')
      END IF
C
C
C     -- CREATION DE L'OBJET .LINO ET RECOPIE DE .EXTERN:
C     ---------------------------------------------------
      CALL WKVECT(NOMU//'.LINO','G V I',NVALAP,IALINO)
      DO 21 , II= 1,NVALAP
         ZI(IALINO-1+II)= ZI(IAEXTE-1+II)
 21   CONTINUE
      CALL JEECRA(NOMU//'.LINO','LONUTI',NVALAP,KBID)
C
C
C     -- MISE A JOUR DE .DESM :
C     -------------------------
      ZI(JDESM-1+2)=NVALAP
      ZI(JDESM-1+6)=NCHAR
C
C
 9999 CONTINUE
      CALL JEDETR(NOMU//'.EXTERN')
      CALL JEDEMA()
      END
