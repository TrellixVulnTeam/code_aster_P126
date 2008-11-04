      SUBROUTINE PEEINT(RESU, MODELE, NBOCC)
      IMPLICIT   NONE
      INTEGER           NBOCC
      CHARACTER*8       MODELE
      CHARACTER*19      RESU
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 03/11/2008   AUTEUR PELLET J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2006  EDF R&D                  WWW.CODE-ASTER.ORG
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
C
C     OPERATEUR   POST_ELEM
C     TRAITEMENT DU MOT CLE-FACTEUR "INTEGRALE"
C     ------------------------------------------------------------------
C
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER          ZI
      COMMON  /IVARJE/ ZI(1)
      REAL*8           ZR
      COMMON  /RVARJE/ ZR(1)
      COMPLEX*16       ZC
      COMMON  /CVARJE/ ZC(1)
      LOGICAL          ZL
      COMMON  /LVARJE/ ZL(1)
      CHARACTER*8      ZK8
      CHARACTER*16            ZK16
      CHARACTER*24                    ZK24
      CHARACTER*32                            ZK32
      CHARACTER*80                                    ZK80
      COMMON  /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      CHARACTER*32     JEXNOM, JEXNUM
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER IRET,NBCMP,NZERO,IBID,NBORDR,JORDR,IOCC,JNUMA,NBMA
      INTEGER JCMP,N1,NUMA,NR,NP,NC,IM,NI,NO,JNO,JIN,NUMO,NUIN,I,IORD
      INTEGER NBGMA,JGMA,NMA,JMA,IGM,NBPAR,NN,INUM,NLI,NLO,JNOS,JRAN
      PARAMETER(NZERO=0,NBPAR=4)
      REAL*8 RBID,PREC,VAL,INST
      COMPLEX*16 CBID
      CHARACTER*8 K8B,KBID,MAILLA, RESUCO,CRIT
      CHARACTER*4 TYCH
      CHARACTER*8 NOMGD,TOUT,GRPMA,MAILLE,TYPPAR(NBPAR)
      PARAMETER(TOUT='TOUT',GRPMA='GROUP_MA',MAILLE='MAILLE')
      CHARACTER*16 NOMPAR(NBPAR)
      CHARACTER*19 KNUM,CHAM,KINS,KRAN,LISINS
      CHARACTER*24 NOMCHA
      LOGICAL      EXIGEO,EXIORD,PREMS
      DATA NOMPAR/'CHAMP_GD','NUME_ORDRE','INST','VOL'/
      DATA TYPPAR/'K16','I','R','R'/
C     ------------------------------------------------------------------
C
      CALL JEMARQ ( )
C
C     --- CREATION DE LA TABLE
      CALL TBCRSD ( RESU, 'G' )
      CALL TBAJPA ( RESU,NBPAR,NOMPAR,TYPPAR )
C
C     --- RECUPERATION DU MAILLAGE ET DU NOMBRE DE MAILLES
      CALL DISMOI('F','NOM_MAILLA',MODELE,'MODELE',IBID,MAILLA,IRET)
      CALL DISMOI('F','NB_MA_MAILLA',MAILLA,'MAILLAGE',NBMA,K8B,IRET)


C     --- RECUPERATION DU RESULTAT ET DU NUMERO D'ORDRE
      CALL GETVID ( ' ', 'RESULTAT' , 1,1,1, RESUCO, NR )
      CALL GETVR8 ( ' ', 'PRECISION', 1,1,1, PREC  , NP )
      CALL GETVTX ( ' ', 'CRITERE'  , 1,1,1, CRIT  , NC )
      CALL GETVR8 ( ' ', 'INST'      ,1,1,0, RBID,   NI)
      CALL GETVIS ( ' ', 'NUME_ORDRE',1,1,0, IBID,   NO)
      CALL GETVID ( ' ', 'LIST_INST' ,1,1,0, KBID,   NLI)
      CALL GETVID ( ' ', 'LIST_ORDRE',1,1,0, KBID,   NLO)

      KNUM = '&&PEEINT.NUME_ORDRE'
      KINS = '&&PEEINT.INST'
      EXIORD=.FALSE.
      IF(NO.NE.0)THEN
         EXIORD=.TRUE.
         NBORDR=-NO
         CALL WKVECT(KNUM,'V V I',NBORDR,JNO)
         CALL GETVIS ( ' ', 'NUME_ORDRE',1,1,NBORDR,ZI(JNO),IRET)
      ENDIF

      IF(NI.NE.0)THEN
         NBORDR=-NI
         CALL WKVECT(KINS,'V V R',NBORDR,JIN)
         CALL GETVR8 ( ' ', 'INST',1,1,NBORDR,ZR(JIN),IRET)
      ENDIF

      IF(NLI.NE.0)THEN
         CALL GETVID ( ' ', 'LIST_INST'  ,1,1,1,LISINS,IRET)
         CALL JEVEUO(LISINS // '.VALE', 'L', JIN)
         CALL JELIRA(LISINS // '.VALE', 'LONMAX', NBORDR, KBID)
      ENDIF

      IF(NLO.NE.0)THEN
         EXIORD=.TRUE.
         CALL GETVID ( ' ', 'LIST_ORDRE'  ,1,1,1,LISINS,IRET)
         CALL JEVEUO(LISINS // '.VALE', 'L', JNO)
         CALL JELIRA(LISINS // '.VALE', 'LONMAX', NBORDR, KBID)
      ENDIF

      NN=NLO+NLI+NO+NI
      IF(NN.EQ.0)THEN
        EXIORD=.TRUE.
        CALL RSUTNU ( RESUCO,' ',0,KNUM,NBORDR,PREC,CRIT,IRET)
        CALL JEVEUO ( KNUM, 'L', JNO )
      ENDIF


C     --- ON PARCOURT LES OCCURENCES DU MOT CLE 'INTEGRALE':
C     =====================================================

      DO 10 IOCC = 1 , NBOCC


C     --- BOUCLE SUR LES NUMEROS D'ORDRE:
C     ===================================

      DO 5 INUM=1,NBORDR

C         --- NUME_ORDRE, INST ---
          IF(EXIORD)THEN
            NUMO=ZI(JNO+INUM-1)
            CALL RSADPA ( RESUCO,'L',1,'INST',NUMO,0,JIN,KBID)
            INST=ZR(JIN)
          ELSE
            INST=ZR(JIN+INUM-1)
            CALL RSORAC(RESUCO,'INST',0,ZR(JIN+INUM-1),KBID,
     >                   CBID,PREC,CRIT,NUMO,NBORDR,IRET)
          ENDIF

C         --- CHAMP DU POST-TRAITEMENT
          CALL GETVTX('INTEGRALE','NOM_CHAM',IOCC,1,1,NOMCHA,IRET)
          CALL RSEXCH(RESUCO,NOMCHA,NUMO,CHAM,IRET)

          CALL DISMOI('A','TYPE_CHAMP',CHAM,'CHAMP',IBID,TYCH,IRET)
          IF (TYCH(1:2).NE.'EL') CALL U2MESS('F','UTILITAI7_10')

          CALL DISMOI('A','NOM_GD',CHAM,'CHAMP',IBID,NOMGD,IRET)
          IF(NOMGD(6:6).EQ.'C')GOTO 10

C         --- COMPOSANTES DU POST-TRAITEMENT
          CALL GETVTX('INTEGRALE','NOM_CMP',IOCC,1,NZERO,K8B,NBCMP)
          NBCMP=-NBCMP
          CALL WKVECT('&&PEEINT.CMP','V V K8',NBCMP,JCMP)
          CALL GETVTX('INTEGRALE','NOM_CMP',IOCC,1,NBCMP,ZK8(JCMP),IRET)
C
C         --- CALCUL ET STOCKAGE DES MOYENNE : MOT-CLE 'TOUT'
          CALL GETVTX('INTEGRALE','TOUT',IOCC,1,NZERO,K8B,IRET)
          IF(IRET.NE.0)THEN
          CALL  PEECAL(TYCH,RESU,NOMCHA,TOUT,TOUT,MODELE,
     &                 CHAM,NBCMP,ZK8(JCMP),NUMO,INST,IOCC)
          ENDIF

C         --- CALCUL ET STOCKAGE DES MOYENNES : MOT-CLE 'GROUP_MA'
          CALL GETVID('INTEGRALE','GROUP_MA',IOCC,1,NZERO,K8B,N1)
          IF(N1.NE.0)THEN
            NBGMA=-N1
            CALL WKVECT('&&PEEINT_GMA','V V K8',NBGMA,JGMA)
            CALL GETVID('INTEGRALE','GROUP_MA',IOCC,1,NBGMA,
     &                   ZK8(JGMA),N1)
            DO 20 IGM=1,NBGMA
              CALL JELIRA(JEXNOM(MAILLA//'.GROUPEMA',ZK8(JGMA+IGM-1)),
     &                    'LONMAX',NMA,K8B)
              CALL JEVEUO(JEXNOM(MAILLA//'.GROUPEMA',ZK8(JGMA+IGM-1)),
     &                    'L',JNUMA)
              CALL  PEECAL(TYCH,RESU,NOMCHA,GRPMA,ZK8(JGMA+IGM-1),
     &                     MODELE,CHAM,NBCMP,ZK8(JCMP),NUMO,INST,IOCC)
 20         CONTINUE
            CALL JEDETR('&&PEEINT_GMA')
          ENDIF

C         --- CALCUL ET STOCKAGE DES MOYENNES : MOT-CLE 'MAILLE'
          CALL GETVID('INTEGRALE','MAILLE',IOCC,1,NZERO,K8B,N1)
          IF(N1.NE.0)THEN
            NMA=-N1
            CALL WKVECT('&&PEEINT_MAIL','V V K8',NMA,JMA)
            CALL GETVID('INTEGRALE','MAILLE',IOCC,1,NMA,
     &                   ZK8(JMA),N1)
            DO 30 IM=1,NMA
              CALL JENONU(JEXNOM(MAILLA//'.NOMMAI',ZK8(JMA+IM-1)),NUMA)
              CALL  PEECAL(TYCH,RESU,NOMCHA,MAILLE,ZK8(JMA+IM-1),MODELE,
     &                     CHAM,NBCMP,ZK8(JCMP),NUMO,INST,IOCC)
 30         CONTINUE
            CALL JEDETR('&&PEEINT_MAIL')
          ENDIF

          CALL JEDETR('&&PEEINT.CMP')

 5        CONTINUE

 10       CONTINUE

          CALL JEDEMA()

          END
