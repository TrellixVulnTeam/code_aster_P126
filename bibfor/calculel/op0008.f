      SUBROUTINE OP0008()
      IMPLICIT NONE
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 20/12/2010   AUTEUR PELLET J.PELLET 
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C ......................................................................
C     COMMANDE:  CALC_VECT_ELEM

C ......................................................................
C ----- DEBUT --- COMMUNS NORMALISES  JEVEUX  --------------------------
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
C------------FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
      LOGICAL FNOEVO
      INTEGER NBCHME,IBID,ICH,ICHA,IED,IERD,JLMAT,JLVF,NCHA,NH
      INTEGER NBSS,N1,N3,N4,N5,N6,N7,N9,IAD,IRESU,JRELR,IEXI,NBRESU
      REAL*8 TIME,TPS(6),PARTPS(3),VCMPTH(3)
      COMPLEX*16 CBID
      LOGICAL EXITIM
      CHARACTER*8 MATEZ,MODELE,CHA,CARA,KBID,K8BID,KMPIC
      CHARACTER*8 NOMCMP(6),MO1,TYCH,MATERI,NCMPTH(3),K8B
      CHARACTER*16 TYPE,OPER,SUROPT,TYPCO
      CHARACTER*19 VRESUL,MATEL,RESUEL
      CHARACTER*24 TIME2,CHAM,VFONO,VAFONO,VMATEL,CH24,MATE
      DATA NOMCMP/'INST    ','DELTAT  ','THETA   ','KHI     ',
     &     'R       ','RHO     '/
      DATA NCMPTH/'TEMP','TEMP_INF','TEMP_SUP'/
      DATA VCMPTH/3*0.D0/
      DATA TPS/0,2*1.0D0,3*0/

      CALL JEMARQ()
      CALL INFMAJ()
      VFONO = ' '
      VAFONO = ' '

      CALL GETRES(MATEZ,TYPE,OPER)
      MATEL=MATEZ

      CALL GETVTX(' ','OPTION',0,1,1,SUROPT,N3)

C     - ON VERIFIE LE NOM DU MODELE:
C     -------------------------------
      MODELE = ' '
      CALL GETVID(' ','MODELE',0,1,1,MODELE,N1)
      CALL GETVID(' ','CHARGE',0,1,0,CHA,NCHA)


      IF (NCHA.LT.0) THEN
        NCHA = -NCHA
        CALL JECREO(MATEL(1:8)//'.CHARGES','V V K8')
        N3=MAX(1,NCHA)
        CALL JEECRA(MATEL(1:8)//'.CHARGES','LONMAX',N3,' ')
        CALL JEVEUO(MATEL(1:8)//'.CHARGES','E',ICHA)
        CALL GETVID(' ','CHARGE',0,1,NCHA,ZK8(ICHA),IBID)

        CALL DISMOI('F','NOM_MODELE',ZK8(ICHA),'CHARGE',IBID,MO1,IED)
        IF ((N1.EQ.1) .AND. (MODELE.NE.MO1)) CALL U2MESS('F','CALCULEL3_
     &88')

        MODELE = MO1
        DO 10,ICH = 1,NCHA
          CALL DISMOI('F','NOM_MODELE',ZK8(ICHA-1+ICH),'CHARGE',IBID,
     &                K8BID,IED)
          IF (K8BID.NE.MODELE) THEN
            CALL U2MESS('F','CALCULEL3_89')
          END IF
   10   CONTINUE
      END IF

      IF (SUROPT.EQ.'FORC_NODA') THEN
        CALL GETVID(' ','SIEF_ELGA',0,1,1,CHAM,N6)
        IF(N6.NE.0)THEN
          CALL CHPVER('F',CHAM(1:19),'ELGA','SIEF_R',IERD)
        ENDIF
      END IF

      IF (SUROPT.NE.'FORC_NODA') THEN
        CALL DISMOI('F','NB_SS_ACTI',MODELE,'MODELE',NBSS,KBID,IED)
      ELSE
        NBSS = 0
      END IF


      CARA = ' '
      MATERI = ' '
      CALL GETVID(' ','CARA_ELEM',0,1,1,CARA,N5)
      CALL GETVID(' ','CHAM_MATER',0,1,1,MATERI,N4)
      IF (N4.NE.0) THEN
        CALL RCMFMC(MATERI,MATE)
      ELSE
        MATE = ' '
      END IF

      CALL GETVR8(' ','INST',0,1,1,TIME,N7)
      EXITIM = .FALSE.
      IF (N7.EQ.1) EXITIM = .TRUE.
      CALL GETVIS(' ','MODE_FOURIER',0,1,1,NH,N9)
      IF (N9.EQ.0) NH = 0

C     -- VERIFICATION DES CHARGES:
      IF ((SUROPT.EQ.'CHAR_MECA') .OR.
     &    (SUROPT.EQ.'CHAR_MECA_LAGR')) THEN
        DO 20,ICH = 1,NCHA
          CALL DISMOI('F','TYPE_CHARGE',ZK8(ICHA-1+ICH),'CHARGE',IBID,
     &                K8BID,IED)
          IF (K8BID(1:5).NE.'MECA_') THEN
            CALL U2MESS('F','CALCULEL3_91')
          END IF
   20   CONTINUE
      END IF

      IF ((SUROPT.EQ.'CHAR_THER')) THEN
        DO 30,ICH = 1,NCHA
          CALL DISMOI('F','TYPE_CHARGE',ZK8(ICHA-1+ICH),'CHARGE',IBID,
     &                K8BID,IED)
          IF (K8BID(1:5).NE.'THER_')  CALL U2MESS('F','CALCULEL3_92')
   30   CONTINUE
      END IF

      IF ((SUROPT.EQ.'CHAR_ACOU')) THEN
        DO 40,ICH = 1,NCHA
          CALL DISMOI('F','TYPE_CHARGE',ZK8(ICHA-1+ICH),'CHARGE',IBID,
     &                K8BID,IED)
          IF (K8BID(1:5).NE.'ACOU_')  CALL U2MESS('F','CALCULEL3_93')
   40   CONTINUE
      END IF

      IF ((SUROPT.EQ.'FORC_NODA')) THEN
        CALL DISMOI('F','TYPE_CHAMP',CHAM,'CHAMP',IBID,TYCH,IERD)
        IF (TYCH(1:4).NE.'ELGA') CALL U2MESS('F','CALCULEL3_94')
      END IF



      IF (SUROPT.EQ.'CHAR_MECA') THEN
C     ----------------------------------
C        -- TRAITEMENT DES ELEMENTS FINIS CLASSIQUES (.RELR)
C           (ET CREATION DE L'OBJET .RERR).
        CALL ME2MME(MODELE,NCHA,ZK8(ICHA),MATE,CARA,EXITIM,TIME,MATEL,
     &              NH,'G')

C        -- TRAITEMENT DES SOUS-STRUCTURES EVENTUELLES. (.RELC):
        CALL SS2MME(MODELE,'SOUS_STRUC',MATEL,'G')


      ELSE IF (SUROPT.EQ.'CHAR_THER') THEN
C     ----------------------------------
        TPS(1) = TIME
        TIME2 = '&TIME'
        CALL MECACT('V',TIME2,'MODELE',MODELE//'.MODELE','INST_R  ',6,
     &              NOMCMP,IBID,TPS,CBID,KBID)
        CALL MECACT('V','&&OP0008.PTEMPER','MODELE',MODELE//'.MODELE',
     &              'TEMP_R  ',3,NCMPTH,IBID,VCMPTH,CBID,KBID)
        CALL ME2MTH(MODELE,NCHA,ZK8(ICHA),MATE,CARA,TIME2,
     &              '&&OP0008.PTEMPER',MATEL)
      ELSE IF (SUROPT.EQ.'CHAR_ACOU') THEN
        CALL ME2MAC(MODELE,NCHA,ZK8(ICHA),MATE,MATEL)


      ELSE IF (SUROPT.EQ.'FORC_NODA') THEN
C     ----------------------------------
C       - ON CHERCHE LE NOM DU MODELE A ATTACHER AU VECT_ELEM :
        CALL JEVEUO(CHAM(1:19)//'.CELK','L',IAD)
        K8B = ZK24(IAD)
        CALL GETTCO(K8B,TYPCO)
        IF (TYPCO(1:14).EQ.'MODELE_SDASTER') THEN
          MODELE = K8B
        ELSE
          CALL GETVID(' ','MODELE',0,1,1,MODELE,N1)
          IF (N1.EQ.0) CALL U2MESS('F','CALCULEL3_95')
        END IF

        PARTPS(1) = 0.D0
        PARTPS(2) = 0.D0
        PARTPS(3) = 0.D0
        CH24 = ' '
        FNOEVO=.FALSE.
        CALL VEFNME(MODELE,CHAM,CARA,' ',' ',VFONO,MATE,' ',NH,FNOEVO,
     &              PARTPS,' ',CH24,' ',' ',SUROPT)
        CALL JEVEUO(VFONO,'L',JLVF)
        VAFONO = ZK24(JLVF)
        CALL JELIRA(VFONO,'LONUTI',NBCHME,K8BID)
        VMATEL = MATEL//'.RELR'
        CALL MEMARE('G',MATEL,MODELE,MATE,CARA,'CHAR_MECA')
        CALL WKVECT(VMATEL,'G V K24',NBCHME,JLMAT)
        VRESUL = MATEL(1:8)//'.VE001     '
        ZK24(JLMAT) = VRESUL
        CALL COPISD('CHAMP','G',VAFONO(1:19),VRESUL)
      END IF



C     -- SI MATEL N'EST PAS MPI_COMPLET, ON LE COMPLETE :
C     ----------------------------------------------------
      CALL JELIRA(MATEL//'.RELR','LONMAX ',NBRESU,KBID)
      CALL JEVEUO(MATEL//'.RELR','L',JRELR)
      DO 101 IRESU=1,NBRESU
        RESUEL=ZK24(JRELR+IRESU-1)
        CALL JEEXIN(RESUEL//'.RESL',IEXI)
        IF (IEXI.EQ.0) GOTO 101
        CALL DISMOI('F','MPI_COMPLET',RESUEL,'RESUELEM',IBID,KMPIC,
     &            IBID)
        CALL ASSERT((KMPIC.EQ.'OUI').OR.(KMPIC.EQ.'NON'))
        IF (KMPIC.EQ.'NON')  CALL SDMPIC('RESUELEM',RESUEL)
101   CONTINUE




      CALL JEDEMA()
      END
