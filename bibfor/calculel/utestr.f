      SUBROUTINE UTESTR(CHAM19, NONOEU, NOCMP, NBREF, TBTXT,
     &                  REFI, REFR, REFC, TYPRES, EPSI,
     +                  CRIT, IFIC, LLAB, SSIGNE)
      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      CHARACTER*19  CHAM19
      CHARACTER*17  NONOEU
      CHARACTER*8   NOCMP
      INTEGER       NBREF, REFI(NBREF), IFIC
      REAL*8        REFR(NBREF), EPSI
      COMPLEX*16    REFC(NBREF)
      CHARACTER*16  TBTXT(2)
      CHARACTER*1   TYPRES
      CHARACTER*(*) CRIT, SSIGNE
      LOGICAL       LLAB
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 10/10/2012   AUTEUR COURTOIS M.COURTOIS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
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
C     ENTREES:
C        CHAM19 : NOM DU CHAM_NO DONT ON DESIRE VERIFIER 1 COMPOSANTE
C        NONOEU : NOM DU NOEUD A TESTER
C        NOCMP  : NOM DU DDL A TESTER SUR LE NOEUD NONOEU
C        TBTXT  : (1)=REFERENCE, (2)=LEGENDE
C        NBREF  : NOMBRE DE VALEURS DE REFERENCE
C        REFR   : VALEUR REELLE ATTENDUE SUR LE DDL DU NOEUD
C        REFC   : VALEUR COMPLEXE ATTENDUE SUR LE DDL DU NOEUD
C        CRIT   : 'RELATIF' OU 'ABSOLU'(PRECISION RELATIVE OU ABSOLUE).
C        EPSI   : PRECISION ESPEREE
C        IFIC   : NUMERO LOGIQUE DU FICHIER DE SORTIE
C        LLAB   : AFFICHAGE DES LABELS
C     SORTIES:
C      LISTING ...
C ----------------------------------------------------------------------
C     FONCTIONS EXTERNES:
      LOGICAL    EXISDG
      INTEGER    NBEC
C     VARIABLES LOCALES:
      CHARACTER*8  NOGD
      CHARACTER*1  TYPE
      INTEGER      GD, IADG, VALI
      REAL*8       VALR
      COMPLEX*16   VALC
      CHARACTER*4  TESTOK
      CHARACTER*8  NOMMA
      CHARACTER*19 PRCHNO,VALK(3)
      CHARACTER*24 NOLILI
      CHARACTER*1 K1BID
C
C
C-----------------------------------------------------------------------
      INTEGER IADESC ,IANCMP ,IANUEQ ,IAPRNO ,IAREFE ,IAVALE ,IBID
      INTEGER ICMP ,IDECAL ,IERD ,IICMP ,INO ,IVAL ,NCMP
      INTEGER NCMPMX ,NEC ,NUM, INDIK8
C-----------------------------------------------------------------------
      CALL JEMARQ()
      TESTOK = 'NOOK'
C
      CALL DISMOI('F','NOM_GD',CHAM19,'CHAM_NO',IBID,NOGD,IERD)
C
      CALL JEVEUO(CHAM19//'.REFE','L',IAREFE)
      NOMMA = ZK24(IAREFE-1+1)(1:8)
      PRCHNO = ZK24(IAREFE-1+2)(1:19)
C
      CALL JELIRA(CHAM19//'.VALE','TYPE',IBID,TYPE)
      IF ( TYPE.NE.TYPRES ) THEN
         VALK(1) = CHAM19
         VALK(2) = TYPE
         VALK(3) = TYPRES
         CALL U2MESK('F','CALCULEL6_89', 3 ,VALK)
      ELSEIF (TYPE.NE.'R' .AND. TYPE.NE.'C') THEN
         VALK(1) = TYPE
         CALL U2MESK('F','CALCULEL6_90', 1 ,VALK)
      END IF
      CALL JEVEUO(CHAM19//'.VALE','L',IAVALE)
C
      CALL JEVEUO(CHAM19//'.DESC','L',IADESC)
      GD  = ZI(IADESC-1+1)
      NUM = ZI(IADESC-1+2)
      NEC = NBEC(GD)
C
C     -- ON RECHERCHE LE NUMERO CORRESPONDANT A NOCMP:
      CALL JELIRA(JEXNUM('&CATA.GD.NOMCMP',GD),'LONMAX',NCMPMX,K1BID)
      CALL JEVEUO(JEXNUM('&CATA.GD.NOMCMP',GD),'L',IANCMP)
      ICMP = INDIK8(ZK8(IANCMP),NOCMP,1,NCMPMX)
      IF (ICMP.EQ.0) THEN
         VALK(1) = NOCMP
         VALK(2) = NOGD
         CALL U2MESK('F','CALCULEL6_91', 2 ,VALK)
      END IF
C
C        -- RECUPERATION DU NUMERO DU NOEUD:
          CALL JENONU(JEXNOM(NOMMA//'.NOMNOE',NONOEU(1:8)),INO)
          IF (INO.EQ.0) THEN
              VALK(1) =NONOEU(1:8)
              CALL U2MESK('F','CALCULEL6_92', 1 ,VALK)
          END IF
C
C     --SI LE CHAMP EST A REPRESENTATION CONSTANTE:
C
      IF (NUM.LT.0) THEN
          NCMP = -NUM
C
C        -- ON COMPTE LES CMP PRESENTES SUR LE NOEUD AVANT ICMP: (+1)
          IDECAL = 0
          DO 2 IICMP = 1,ICMP
              IF (EXISDG(ZI(IADESC+2),IICMP))   IDECAL = IDECAL + 1
    2     CONTINUE
C
          IF (EXISDG(ZI(IADESC+2),ICMP)) THEN
              IF (TYPE .EQ. 'R' ) THEN
                  VALR = ZR(IAVALE-1+(INO-1)*NCMP+IDECAL)
              ELSEIF (TYPE .EQ. 'I' ) THEN
                  VALI = ZI(IAVALE-1+(INO-1)*NCMP+IDECAL)
              ELSEIF (TYPE .EQ. 'C' ) THEN
                  VALC = ZC(IAVALE-1+(INO-1)*NCMP+IDECAL)
              ENDIF
              CALL UTITES(TBTXT(1), TBTXT(2), TYPE, NBREF, REFI,
     +                    REFR, REFC, VALI, VALR, VALC,
     +                    EPSI, CRIT, IFIC, LLAB, SSIGNE)
          ELSE
              CALL U2MESS('F','CALCULEL6_93')
          END IF
      ELSE
C        --SI LE CHAMP EST DECRIT PAR 1 "PRNO":
C
          CALL JENUNO(JEXNUM(PRCHNO//'.LILI',1),NOLILI)
          CALL JELIRA(JEXNUM(PRCHNO//'.PRNO',1),'LONMAX',
     +                IBID,K1BID)
          IF (IBID.EQ.0) THEN
              WRITE (IFIC,*) TESTOK,' : 2'
              GO TO 9999
          END IF
          CALL JEVEUO(JEXNUM(PRCHNO//'.PRNO',1),'L',IAPRNO)
          CALL JEVEUO(PRCHNO//'.NUEQ','L',IANUEQ)
C
C        IVAL : ADRESSE DU DEBUT DU NOEUD INO DANS .NUEQ
C        NCMP : NOMBRE DE COMPOSANTES PRESENTES SUR LE NOEUD
C        IADG : DEBUT DU DESCRIPTEUR GRANDEUR DU NOEUD INO
          IVAL = ZI(IAPRNO-1+ (INO-1)* (NEC+2)+1)
          NCMP = ZI(IAPRNO-1+ (INO-1)* (NEC+2)+2)
          IADG = IAPRNO - 1 + (INO-1)* (NEC+2) + 3
          IF (NCMP.EQ.0) THEN
              WRITE (IFIC,*) TESTOK,' : 3'
              GO TO 9999
          END IF
C
C        -- ON COMPTE LES CMP PRESENTES SUR LE NOEUD AVANT ICMP:
          IDECAL = 0
          DO 1,IICMP = 1,ICMP
              IF (EXISDG(ZI(IADG),IICMP))   IDECAL = IDECAL + 1
    1     CONTINUE
C
          IF (EXISDG(ZI(IADG),ICMP)) THEN
              IF (TYPE .EQ. 'R' ) THEN
                  VALR = ZR(IAVALE-1+ZI(IANUEQ-1+IVAL-1+IDECAL))
              ELSEIF (TYPE .EQ. 'I' ) THEN
                  VALI = ZI(IAVALE-1+ZI(IANUEQ-1+IVAL-1+IDECAL))
              ELSEIF (TYPE .EQ. 'C' ) THEN
                  VALC = ZC(IAVALE-1+ZI(IANUEQ-1+IVAL-1+IDECAL))
              ENDIF
              CALL UTITES(TBTXT(1), TBTXT(2), TYPE, NBREF, REFI,
     +                    REFR, REFC, VALI, VALR, VALC,
     +                    EPSI, CRIT, IFIC, LLAB, SSIGNE)
          ELSE
              CALL U2MESS('F','CALCULEL6_93')
          END IF
      END IF
 9999 CONTINUE
      CALL JEDEMA()
      END
