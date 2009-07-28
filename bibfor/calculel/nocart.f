      SUBROUTINE NOCART(CHINZ,CODE,GROUPZ,MODEZ,NMA,LIMANO,LIMANU,
     &                  NMLIGZ, NCMP)
      IMPLICIT REAL*8 (A-H,O-Z)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 27/07/2009   AUTEUR LEFEBVRE J-P.LEFEBVRE 
C ======================================================================
C COPYRIGHT (C) 1991 - 2005  EDF R&D                  WWW.CODE-ASTER.ORG
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
      INTEGER CODE,NMA,NCMP,LIMANU(*)
      CHARACTER*3 MODE
      CHARACTER*8 GROUPE
      CHARACTER*(*) LIMANO(*)
      CHARACTER*8 LIMANZ
      CHARACTER*19 CHIN,NOMLIG
      CHARACTER*(*) CHINZ, NMLIGZ, GROUPZ, MODEZ
C ----------------------------------------------------------------------
C     ENTREES:
C     CHINZ : NOM DE LA CARTE A ENRICHIR
C     CODE : 1: 'TOUT' LES MAILLES DU MAILLAGE.
C           -1: 'TOUT' LES MAILLES SUPPL. D'1 LIGREL.
C            2: 1 GROUPE NOMME DE MAILLES DU MAILLAGE.
C            3: 1 LISTE TARDIVE DE MAILLES DU MAILLAGE.
C           -3: 1 LISTE TARDIVE DE MAILLES TARDIVES D'1 LIGREL.
C     GROUPZ : NOM D' 1 GROUPE DE MAILLES DU MAILLAGE
C              ( UNIQUEMENT SI CODE= 2)
C     MODEZ : 'NOM' OU 'NUM' :
C             SI 'NOM' ON UTILISE LA LISTE LIMANO (NOMS DES MAILLES)
C                 ( UNIQUEMENT SI CODE= 3)
C             SI 'NUM' ON UTILISE LA LISTE LIMANU (NUMERO DES MAILLES)
C                 ( UNIQUEMENT SI CODE= 3 OU -3)
C     NMA  : NOMBRE DE MAILLES DANS LIMANO OU LIMANU
C                 ( UNIQUEMENT SI CODE= 3 OU -3)
C     LIMANO : NOMS DES MAILLES DU GROUPE_TARDIF (CODE=3)
C     LIMANU : NUMEROS DES MAILLES DU GROUPE_TARDIF (CODE=3 OU -3)
C     NMLIGZ : NOM DU LIGREL OU SONT EVENTUELLEMENT DEFINIES LES MAILLES
C         TARDIVES QUE L'ON VEUT AFFECTER.
C         NOMLIG EST NON_BLANC UNIQUEMENT SI CODE=-3 OU CODE=-1
C     NCMP : NOMBRE DE COMPOSANTES DECRITES
C            DANS CHIN.NCMP ET CHIN.VALV
C            -- REMARQUE : ON PEUT SUR-DIMENSIONNER NCMP A CONDITION
C                          QUE LA LISTE DES NOMS DE CMPS CONTIENNE DES
C                          "BLANCS". LES CMPS REELLEMENT NOTEES SONT
C                          LES COMPOSANTES NON-BLANCHES.
C
C     SORTIES:
C     ON ENRICHIT LE CONTENU DE LA CARTE CHIN
C
C ----------------------------------------------------------------------
C
C     FONCTIONS EXTERNES:
C     -------------------
      INTEGER NBEC
      CHARACTER*8 SCALAI
C---------------- COMMUNS NORMALISES  JEVEUX  --------------------------
      CHARACTER*32 JEXNUM,JEXNOM,JEXATR
      COMMON /IVARJE/ZI(1)
      COMMON /RVARJE/ZR(1)
      COMMON /CVARJE/ZC(1)
      COMMON /LVARJE/ZL(1)
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      INTEGER ZI
      REAL*8 ZR
      COMPLEX*16 ZC
      LOGICAL ZL
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
C-----------------------------------------------------------------------
      INTEGER NEC,NEDIT,NGDMX,IADDG,GR,DIM,I,NUMERO,GD
      INTEGER JDESC,JLIMA,LDIM
      CHARACTER*8 SCAL,MA,KBID,BASE
      INTEGER NOMA,NOLI
      CHARACTER*24 CLIMA, TRAV
      LOGICAL LAGGR
C-----------------------------------------------------------------------
C
      CALL JEMARQ()
      CHIN   = CHINZ
      NOMLIG = NMLIGZ
      GROUPE = GROUPZ
      MODE   = MODEZ
      LAGGR=.FALSE.
C
      CALL JEVEUO(CHIN//'.NOMA','L',NOMA)
      MA = ZK8(NOMA-1+1)
C
      CALL JEVEUO(CHIN//'.DESC','E',JDESC)
      GD = ZI(JDESC-1+1)
      NEC = NBEC(GD)
      NGDMX = ZI(JDESC-1+2)
      NEDIT = ZI(JDESC-1+3) + 1


C     -- FAUT-IL AGRANDIR LA CARTE ?
C     -------------------------------
      IF (NEDIT.GT.NGDMX) THEN
         LAGGR=.TRUE.
         NGDMX=2*NGDMX
         CALL AGCART(NGDMX, CHIN)
         CALL JEVEUO(CHIN//'.DESC','E',JDESC)
      END IF

      ZI(JDESC-1+3) = NEDIT

      CALL JEVEUO(CHIN//'.NOLI','E',NOLI)
      IF ((CODE.EQ.-1) .OR. (CODE.EQ.-3)) THEN
         CALL ASSERT(NOMLIG(1:8).NE.' ')
         ZK24(NOLI-1+NEDIT) = NOMLIG
      END IF

C     APPEL A EDITGD QUI REMPLIT .VALE ET MET A JOUR  LE DESC_GRANDEUR
      IADDG = 3 + 2*NGDMX + (NEDIT-1)*NEC + 1
      CALL EDITGD(CHIN,NCMP,GD,NEDIT,ZI(JDESC-1+IADDG))


C     MISE A JOUR DE DESC :
C     ----------------------
      ZI(JDESC-1+3+2*NEDIT-1) = CODE
      DIM = 0
      IF (ABS(CODE).EQ.1) THEN
C        -- ON NOTE LE NUMERO D'ENTITE CONVENTIONNEL RELATIF
C        -- A "TOUT":   9999
         ZI(JDESC-1+3+2*NEDIT) = 9999
      ELSE IF (CODE.EQ.2) THEN
         CALL JENONU(JEXNOM(MA//'.GROUPEMA',GROUPE),GR)
         ZI(JDESC-1+3+2*NEDIT) = GR
      ELSE IF (ABS(CODE).EQ.3) THEN
         ZI(JDESC-1+3+2*NEDIT) = NEDIT
         DIM = NMA
      ELSE
         CALL ASSERT(.FALSE.)
      END IF



C     MISE A JOUR DE LIMA :
C     ----------------------
C     RECOPIE DANS LIMA DES NUMEROS DE MAILLES DU GROUPE TARDIF:

C     -- FAUT-IL AGRANDIR .LIMA ?
      CALL JELIRA(CHIN//'.LIMA','LONT',LONTAV,KBID)
      CALL JEVEUO(JEXATR(CHIN//'.LIMA','LONCUM'),'L',ILLIMA)
      LONTAP=ZI(ILLIMA-1+NEDIT)+MAX(DIM,1)
      IF (LONTAP.GT.LONTAV) THEN
         LAGGR=.TRUE.
         LONTAP=MAX(2*LONTAV,LONTAP)
      ENDIF
      IF (LAGGR) THEN
        CLIMA=CHIN//'.LIMA'
        TRAV=CHIN//'.TRAV'
        CALL JEDUPO(CLIMA,'V',TRAV,.FALSE.)
        CALL JELIRA(CLIMA,'CLAS',IBID,BASE)
        CALL JEDETR(CHIN//'.LIMA')
        CALL JEAGCO(TRAV, CLIMA, NGDMX,LONTAP,BASE)
        CALL JEDETR(TRAV)
      ENDIF

      CALL JECROC(JEXNUM(CHIN//'.LIMA',NEDIT))
      LDIM = MAX(DIM,1)
      CALL JEECRA(JEXNUM(CHIN//'.LIMA',NEDIT),'LONMAX',LDIM,' ')
      CALL JEVEUO(JEXNUM(CHIN//'.LIMA',NEDIT),'E',JLIMA)
      DO 100 I = 1,DIM
         IF (MODE.EQ.'NUM') THEN
C             MAILLES NUMEROTEES ( DU MAILLAGE (>0) OU TARDIVES(<0) )
            ZI(JLIMA-1+I) = LIMANU(I)
         ELSE IF (MODE.EQ.'NOM') THEN
C             MAILLES NOMMEES DU MAILLAGE
            LIMANZ = LIMANO(I)
            CALL JENONU(JEXNOM(MA//'.NOMMAI',LIMANZ),NUMERO)
            ZI(JLIMA-1+I) = NUMERO
         ELSE
            CALL ASSERT(.FALSE.)
         END IF
  100 CONTINUE

      CALL JEDEMA()
      END
