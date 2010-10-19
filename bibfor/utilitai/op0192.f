      SUBROUTINE OP0192()
C_____________________________________________________________________
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 19/10/2010   AUTEUR COURTOIS M.COURTOIS 
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
C                   LIRE_CHAMP
C_____________________________________________________________________
C
      IMPLICIT NONE
C
C 0.1. ==> ARGUMENTS
C
C
C 0.2. ==> COMMUNS
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX --------------------------
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      LOGICAL ZL
      COMMON /LVARJE/ZL(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C     -----  FIN  COMMUNS NORMALISES  JEVEUX --------------------------
C
C 0.3. ==> VARIABLES LOCALES
C
      CHARACTER*6 NOMPRO
      PARAMETER ( NOMPRO = 'OP0192' )
C
      INTEGER EDNONO
      PARAMETER (EDNONO=-1)
      INTEGER EDNOPT
      PARAMETER (EDNOPT=-1)
C
      CHARACTER*7 LCMPVA
      PARAMETER ( LCMPVA = 'NOM_CMP' )
      CHARACTER*11 LCMPVM
      PARAMETER ( LCMPVM = 'NOM_CMP_MED' )
C
      INTEGER IAUX, JAUX, IRET
      INTEGER IINST, IDFIMD
      INTEGER UNITE, IMAJ, IMIN, IREL
      INTEGER CODRET, IVER, TYPENT
      INTEGER NUMPT, NUMORD
      INTEGER NBCMPV, JCMPVA, JCMPVM
      INTEGER NBMA,JNBPGM,JNBPMM
      INTEGER EDNOEU
      PARAMETER (EDNOEU=3)
      INTEGER EDMAIL
      PARAMETER (EDMAIL=0)
      INTEGER EDNOMA
      PARAMETER (EDNOMA=4)
      INTEGER EDLECT
      PARAMETER (EDLECT=0)
C
      REAL*8 INST
      REAL*8 PREC
C
      CHARACTER*1 SAUX01
      CHARACTER*8 CHANOM, NOMAAS, NOMO, NOMGD
      CHARACTER*19 CHATMP,LIGREL
      CHARACTER*8 TYPECH, PARAM
      CHARACTER*8 CRIT,SAUX08,K8B
      CHARACTER*3 PROLZ
      CHARACTER*16 NOMCMD, FORMAT, TYCH
      CHARACTER*24 OPTION
      CHARACTER*32 NOCHMD, NOMAMD
      CHARACTER*72 REP
      CHARACTER*200 NOFIMD
      CHARACTER*255 KFIC
C
      CHARACTER*24 NCMPVA, NCMPVM
      CHARACTER*24 VALK(2)
C
C DEB ------------------------------------------------------------------
C====
C 1. PREALABLES
C====
C
      CALL JEMARQ()
C
C 1.1. ==> RECUPERATION DU NIVEAU D'IMPRESSION
C
      CALL INFMAJ
C
C====
C 2. DETERMINATION DES OPTIONS DE LA COMMANDE :
C====
C
C 2.1. ==> FORMAT DU FICHIER
C
      CALL GETVTX ( ' ', 'FORMAT', 0, 1, 1, FORMAT, IAUX )
C
      IF ( FORMAT.EQ.'MED' ) THEN
        CALL GETVTX ( ' ', 'NOM_MED', 0, 1, 1, NOCHMD, IAUX )
        IF ( IAUX.EQ.0 ) THEN
          CALL U2MESS('F','MED_96')
        ENDIF
      ELSE
        CALL U2MESK('F','UTILITAI3_17',1,FORMAT)
      ENDIF
C
C 2.2. ==> TYPE DE CHAMP A LIRE
C
      CALL GETVTX ( ' ', 'TYPE_CHAM', 0, 1, 1, TYCH, IAUX )
      CALL GETRES ( CHANOM, TYPECH, NOMCMD )
      NOMGD = TYCH(6:13)
      IF (TYCH(1:11).EQ.'ELGA_SIEF_R') THEN
         OPTION = 'RAPH_MECA'
         PARAM  = 'PCONTPR'
      ELSE IF (TYCH(1:11).EQ.'ELGA_EPSI_R') THEN
         OPTION = 'EPSI_ELGA_DEPL'
         PARAM  = 'PDEFORR'
      ELSE IF (TYCH(1:11).EQ.'ELGA_VARI_R') THEN
         OPTION = 'RAPH_MECA'
         PARAM  = 'PVARIPR'
C       ELSE IF (TYCH(1:9).EQ.'ELGA_EQUI_R') THEN
C          OPTION = 'EQUI_ELGA_SIGM'
C          PARAM  = 'PCONTEQ'
      ELSE IF (TYCH(1:4).EQ.'ELGA') THEN
C        AUTRES CHAMPS ELGA : NON PREVU
         CALL U2MESK('F','UTILITAI2_94',1,TYCH)
      ELSE
C        CHAMPS ELNO OU AUTRES :
         OPTION=' '
         PARAM=' '
      ENDIF
C
C - -  VERIFICATIONS - -
C
      IF(TYCH(1:2).EQ.'EL')THEN
         CALL GETVID ( ' ', 'MODELE', 0, 1, 1, NOMO, IAUX )
         CALL LRVEMO(NOMO)
      ENDIF
C
C 2.3. ==> NOM DES COMPOSANTES VOULUES
C
      NCMPVA = '&&'//NOMPRO//'.'//LCMPVA
      NCMPVM = '&&'//NOMPRO//'.'//LCMPVM
C
      CALL GETVTX(' ','NOM_CMP_IDEM',0,1,1, REP, IAUX )
C
C 2.3.1. ==> C'EST PAR IDENTITE DE NOMS
C
      IF ( IAUX.NE.0 ) THEN
C
        IF ( REP.EQ.'OUI' ) THEN
          NBCMPV = 0
        ELSE
          CALL U2MESK('F','UTILITAI3_18',1,REP)
        ENDIF
C
      ELSE
C
C 2.3.2. ==> C'EST PAR ASSOCIATION DE LISTE
C
        CALL GETVTX(' ',LCMPVA,0,1,0,REP,IAUX)
        IF ( IAUX.LT.0 ) THEN
          NBCMPV = -IAUX
        ENDIF
C
        CALL GETVTX(' ',LCMPVM,0,1,0,REP,IAUX)
        IF ( -IAUX.NE.NBCMPV ) THEN
           VALK(1) = LCMPVA
           VALK(2) = LCMPVM
           CALL U2MESK('F','UTILITAI2_95', 2 ,VALK)
        ENDIF
C
        IF ( NBCMPV.GT.0 ) THEN
          CALL WKVECT(NCMPVA ,'V V K8',NBCMPV,JCMPVA )
          CALL GETVTX(' ',LCMPVA,0,1,NBCMPV,ZK8(JCMPVA),IAUX)
          CALL WKVECT(NCMPVM,'V V K16',NBCMPV,JCMPVM)
          CALL GETVTX(' ',LCMPVM,0,1,NBCMPV,ZK16(JCMPVM),IAUX)
        ENDIF
C
      ENDIF
C
C 2.4a ==> PROLONGEMENT PAR ZERO OU NOT A NUMBER
C
      CALL GETVTX(' ', 'PROL_ZERO', 0, 1, 1, PROLZ, IAUX)
      IF (PROLZ .NE. 'OUI') THEN
         PROLZ = 'NAN'
      ENDIF
C
C 2.4b ==> UNITE LOGIQUE LIE AU FICHIER
C
      CALL GETVIS ( ' ', 'UNITE', 0, 1, 1, UNITE, IAUX )
C
C 2.5. ==> NOM DU MODELE, NOM DU MAILLAGE ASTER ASSOCIE
C
      CALL GETVID ( ' ', 'MODELE', 0, 1, 1, NOMO, IAUX )
      IF(IAUX.NE.0)THEN
        LIGREL = NOMO//'.MODELE'
      ELSE
C                 1234567890123456789
        LIGREL = '                   '
      ENDIF

      CALL GETVID ( ' ', 'MAILLAGE', 0, 1, 1, NOMAAS, IAUX )
      IF ( IAUX.EQ.0 ) THEN
        CALL DISMOI ( 'F', 'NOM_MAILLA', NOMO, 'MODELE',
     &                IAUX, NOMAAS, CODRET )
        IF ( CODRET.NE.0 ) THEN
          CALL U2MESS('F','UTILITAI3_19')
        ENDIF
      ENDIF
C
C 2.6. ==> NOM DU MAILLAGE MED ASSOCIE
C
      CALL GETVTX ( ' ', 'NOM_MAIL_MED', 0, 1, 1, NOMAMD, IAUX )
C
      IF ( IAUX.EQ.0 ) THEN
        NOMAMD = ' '
      ENDIF
C
C 2.7. CARACTERISTIQUES TEMPORELLES
C 2.7.1. ==> NUMERO D'ORDRE EVENTUEL
C
      CALL GETVIS ( ' ', 'NUME_ORDRE', 0, 1, 1, NUMORD, IAUX )
      IF ( IAUX.EQ.0 ) THEN
        NUMORD = EDNONO
      ENDIF
C
C 2.7.2. ==> NUMERO DE PAS DE TEMPS EVENTUEL
C
      CALL GETVIS ( ' ', 'NUME_PT', 0, 1, 1, NUMPT, JAUX )
      IF ( JAUX.EQ.0 ) THEN
        NUMPT = EDNOPT
      ENDIF
C
C 2.7.3. ==> SI NI NUMERO D'ORDRE, NI NUMERO DE PAS DE TEMPS, IL Y A
C            PEUT-ETRE UNE VALEUR D'INSTANT
C
      IF ( IAUX.EQ.0 .AND. JAUX.EQ.0 ) THEN
C
        CALL GETVR8 ( ' ', 'INST', 1,1,1, INST, IINST )
C
        IF ( IINST.NE.0 ) THEN
          CALL GETVR8 ( ' ', 'PRECISION', 1,1,1, PREC, IAUX )
          CALL GETVTX ( ' ', 'CRITERE'  , 1,1,1, CRIT, IAUX )
        ENDIF
C
      ELSE
        IINST = 0
      ENDIF
C
C====
C 3. APPEL DE LA LECTURE AU FORMAT MED
C====
C
       IF(TYCH(1:4).EQ.'ELGA')THEN
         CALL DISMOI('F','NB_MA_MAILLA',NOMAAS,'MAILLAGE',
     &                                            NBMA,K8B,IRET)
         CALL WKVECT('&&OP0150_NBPG_MAILLE','V V I',NBMA,JNBPGM)
         CALL WKVECT('&&OP0150_NBPG_MED','V V I',NBMA,JNBPMM)
      ENDIF

      IF ( FORMAT.EQ.'MED' ) THEN
C
        CHATMP = '&&OP0192.TEMPOR'
        IF(TYCH(1:4).EQ.'NOEU')THEN
           TYPENT=EDNOEU
        ELSEIF(TYCH(1:4).EQ.'ELNO')THEN

C          DETERMINATION DU TYPE D'ENTITE CAR SELON LA VERSION MED,
C               TYPENT =4 ('MED_NOEUD_MAILLE') OU
C                      =0 ('MED_MAILLE' POUR LES VERSIONS ANTERIEURES)
C          NOM DU FICHIER MED
           CALL ULISOG(UNITE, KFIC, SAUX01)
           IF ( KFIC(1:1).EQ.' ' ) THEN
             CALL CODENT ( UNITE, 'G', SAUX08 )
             NOFIMD = 'fort.'//SAUX08
           ELSE
             NOFIMD = KFIC(1:200)
           ENDIF
           CALL MFOUVR ( IDFIMD, NOFIMD, EDLECT, IRET )
           CALL MFVELI ( IDFIMD, IMAJ, IMIN, IREL, IRET)
           CALL MFFERM ( IDFIMD, IRET )
C          ON VERIFIE LA VERSION DU FICHIER A LA VERSION 2.3.3
           TYPENT=EDNOMA
           IVER= IMAJ*100 + IMIN*10 + IREL
           IF(IVER.LT.233)THEN
               TYPENT=EDMAIL
               CALL U2MESK('A','MED_53',1,NOCHMD)
           ELSE
               TYPENT=EDNOMA
           ENDIF
        ELSE
           TYPENT=EDMAIL
        ENDIF

        CALL LRCHME ( CHATMP, NOCHMD, NOMAMD,
     &                NOMAAS, TYCH(1:8), NOMGD, TYPENT,
     &                NBCMPV, NCMPVA, NCMPVM, PROLZ,
     &                IINST, NUMPT, NUMORD, INST, CRIT, PREC,
     &                UNITE, LIGREL, OPTION, PARAM, 
     &                ZI(JNBPGM),ZI(JNBPMM),CODRET )
C
        CALL COPISD('CHAMP_GD','G',CHATMP,CHANOM)
        IF (TYCH(1:2).EQ.'NO') THEN
            CALL DETRSD('CHAM_NO',CHATMP)
        ELSE
            CALL DETRSD('CHAM_ELEM',CHATMP)
        ENDIF
C
      ENDIF
C
C====
C 4. LA FIN
C====
C
      CALL JEDEMA()
C FIN ------------------------------------------------------------------
      END
