      SUBROUTINE NMSTAT(PHASEZ,FONACT,SDTIME,SDDYNA,NUMINS,
     &                  DEFICO,RESOCO)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 21/12/2010   AUTEUR ABBAS M.ABBAS 
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
C RESPONSABLE ABBAS M.ABBAS
C
      IMPLICIT NONE
      CHARACTER*(*) PHASEZ
      CHARACTER*24  SDTIME,RESOCO,DEFICO
      CHARACTER*19  SDDYNA
      INTEGER       FONACT(*)
      INTEGER       NUMINS
C
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (ALGORITHME)
C
C AFFICHAGE DE STATISTIQUES DIVERSES
C
C ----------------------------------------------------------------------
C
C
C IN  PHASE  : TYPE DE STATISTIQUES
C               'PAS' - PAS DE TEMPS COURANT
C               'FIN' - STATISTIQUES FINALES
C IN  SDTIME : SD TIME
C IN  SDDYNA : SD DYNAMIQUE
C IN  RESOCO : SD RESOLUTION DU CONTACT
C IN  FONACT : FONCTIONNALITES ACTIVES
C
C -------------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ----------------
C
      INTEGER ZI
      COMMON /IVARJE/ ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C
C -------------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ----------------
C
      LOGICAL      ISFONC,LCTCD,LALLV,LCONT,LELTC
      LOGICAL      LBID,CFDISL,LCTCG
      INTEGER      IBID
      REAL*8       R8BID
      REAL*8       TPSCOG,TPSCOA,TPSCTC
      INTEGER      CTCCIT,CTCCLA,CTCCLF,CTCGEO,ITERAT,CTCFRO
      REAL*8       TPSPAS,TPSARC,TPSRST
      REAL*8       TPSFCS,TPSFCN,TPSINT,TPSRES
      INTEGER      NBRFCS,NBRFCN,NBRINT,NBRRES
      REAL*8       VALR(15)
      INTEGER      VALI(15)
      CHARACTER*3  PHASE
      LOGICAL      NDYNLO,LEXPL,LIMPL
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- FONCTIONNALITES ACTIVES
C
      LCONT  = ISFONC(FONACT,'CONTACT')
      LCTCD  = ISFONC(FONACT,'CONT_DISCRET')
      LELTC  = ISFONC(FONACT,'ELT_CONTACT')
      LEXPL  = NDYNLO(SDDYNA,'EXPLICITE')
      LIMPL  = NDYNLO(SDDYNA,'IMPLICITE')
      TPSCOA = 0.D0
      TPSCOG = 0.D0
      TPSARC = 0.D0
      TPSCTC = 0.D0
      CTCCIT = 0
      CTCCLA = 0
      CTCCLF = 0
      CTCGEO = 0
      CTCFRO = 0
      PHASE  = PHASEZ
C
C --- TEMPS PASSES DANS MECA_NON_LINE
C
      CALL NMTIME('VAL','PAS',SDTIME,LBID  ,TPSPAS)
      CALL NMTIME('VAL','ARC',SDTIME,LBID  ,TPSARC)
      CALL NMTIME('IFR','FCS',SDTIME,LBID  ,TPSFCS)
      CALL NMTIME('IFR','FCN',SDTIME,LBID  ,TPSFCN)
      CALL NMTIME('IFR','INT',SDTIME,LBID  ,TPSINT)
      CALL NMTIME('IFR','RES',SDTIME,LBID  ,TPSRES)
C
C --- COMPTEURS D'OPERATIONS
C
      CALL NMTIME('IFI','FCS',SDTIME,LBID  ,R8BID)
      NBRFCS = NINT(R8BID)
      CALL NMTIME('IFI','FCN',SDTIME,LBID  ,R8BID)
      NBRFCN = NINT(R8BID)
      CALL NMTIME('IFI','INT',SDTIME,LBID  ,R8BID)
      NBRINT = NINT(R8BID)
      CALL NMTIME('IFI','RES',SDTIME,LBID  ,R8BID)
      NBRRES = NINT(R8BID)
      CALL NMTIME('IFI','ITE',SDTIME,LBID  ,R8BID)
      ITERAT = NINT(R8BID)

      IF (LCTCD) THEN
        LALLV  = CFDISL(DEFICO,'ALL_VERIF')
        IF (.NOT.LALLV) THEN
          CALL CFITER(RESOCO,'L','TIMG',IBID  ,TPSCOG)
          CALL CFITER(RESOCO,'L','TIMA',IBID  ,TPSCOA)
          TPSCTC = TPSCOG + TPSCOA
          CALL MMBOUC(RESOCO,'GEOM','READ',CTCGEO)
          CALL CFITER(RESOCO,'L','CONC',CTCCIT,R8BID )
          CALL CFITER(RESOCO,'L','LIAC',CTCCLA,R8BID )
          CALL CFITER(RESOCO,'L','LIAF',CTCCLF,R8BID )
        ENDIF
      ELSEIF (LELTC) THEN
        LALLV  = CFDISL(DEFICO,'ALL_VERIF')
        IF (.NOT.LALLV) THEN
          CALL CFITER(RESOCO,'L','TIMG',IBID  ,TPSCOG)
          CALL CFITER(RESOCO,'L','TIMA',IBID  ,TPSCOA)
          TPSCTC = TPSCOG + TPSCOA
          LCTCG  = CFDISL(DEFICO,'GEOM_BOUCLE')
          IF (LCTCG) THEN
            CALL MMBOUC(RESOCO,'GEOM','READ',CTCGEO)
          ENDIF
          CALL CFITER(RESOCO,'L','FROT',CTCFRO,R8BID )
          CALL CFITER(RESOCO,'L','CONC',CTCCIT,R8BID )
        ENDIF
      ELSE
        TPSCTC = 0.D0
        CTCCIT = 0
      ENDIF

      IF (PHASE.EQ.'PAS') THEN
C
C --- SI DYNAMIQUE, ON RETIRE LA FACTORISATION POUR ACCE_INIT
C
        IF (LIMPL.AND.(NUMINS.EQ.2)) THEN
          IF (NBRFCN.NE.0) THEN
            TPSFCN = TPSFCN - TPSFCN/NBRFCN
            NBRFCN = NBRFCN - 1
          ENDIF
        ENDIF
C
C --- TEMPS RESTANT SUR PAS DE TEMPS
C
        TPSRST = TPSPAS-TPSFCN-TPSFCS-
     &           TPSINT-TPSRES-TPSCTC
C
C --- AFFICHAGE DES TEMPS
C
        VALR(1)  = TPSPAS
        VALR(2)  = TPSARC
        VALR(3)  = TPSFCS
        VALR(4)  = TPSFCN
        VALR(5)  = TPSINT
        VALR(6)  = TPSRES
        VALR(7)  = TPSCTC
        VALR(8)  = TPSPAS/ITERAT
        VALR(15) = TPSRST
C
        VALI(3) = NBRFCS
        VALI(4) = NBRFCN
        VALI(5) = NBRINT
        VALI(6) = NBRRES
        VALI(7) = CTCCIT
        VALI(8) = ITERAT
        IF (.NOT.LEXPL) THEN
          CALL NMIMPR('IMPR','TPS_PAS',' ',VALR,VALI)
        ENDIF
C
C --- STAT POUR CONTACT DISCRET
C
        IF (LCTCD) THEN
          LALLV  = CFDISL(DEFICO,'ALL_VERIF')
          IF (.NOT.LALLV) THEN
            VALR(1) = TPSCOG
            VALR(2) = TPSCOA
            VALI(1) = CTCCIT
            VALI(2) = CTCGEO
            VALI(3) = CTCCLA
            VALI(4) = CTCCLF
            CALL NMIMPR('IMPR','STAT_CTCD',' ',VALR,VALI)
            CALL NMTIME('SFR','CTG',SDTIME,LBID  ,TPSCOG)
            CALL NMTIME('SFR','CTA',SDTIME,LBID  ,TPSCOA)
            R8BID  = DBLE(CTCCIT)
            CALL NMTIME('SFI','CTA',SDTIME,LBID  ,R8BID )
            R8BID  = DBLE(CTCGEO)
            CALL NMTIME('SFI','CTG',SDTIME,LBID  ,R8BID )
            CALL MMBOUC(RESOCO,'GEOM','INIT',IBID)
          ENDIF
        ENDIF
C
C --- STAT POUR CONTACT CONTINU
C
        IF (LELTC) THEN
          LALLV  = CFDISL(DEFICO,'ALL_VERIF')
          IF (.NOT.LALLV) THEN
            VALR(1) = TPSCOG
            VALR(2) = TPSCOA
            VALI(1) = CTCCIT
            VALI(2) = CTCFRO
            VALI(3) = CTCGEO
            CALL NMIMPR('IMPR','STAT_CTCC',' ',VALR,VALI)
            CALL NMTIME('SFR','CTG',SDTIME,LBID  ,TPSCOG)
            CALL NMTIME('SFR','CTA',SDTIME,LBID  ,TPSCOA)
            R8BID  = DBLE(CTCCIT)
            CALL NMTIME('SFI','CTA',SDTIME,LBID  ,R8BID )
            R8BID  = DBLE(CTCGEO)
            CALL NMTIME('SFI','CTG',SDTIME,LBID  ,R8BID )
            R8BID  = DBLE(CTCFRO)
            CALL NMTIME('SFI','CTF',SDTIME,LBID  ,R8BID )
            CALL MMBOUC(RESOCO,'GEOM','INIT',IBID)
          ENDIF
        ENDIF
C
C --- PREPARATION STAT POUR TOUT LE STAT_NON_LINE
C
        CALL NMTIME('STAT',' ',SDTIME,LBID  ,R8BID)
C
C --- AFFICHAGE STAT POUR TOUT LE STAT_NON_LIN
C
      ELSEIF (PHASE.EQ.'FIN') THEN
        CALL NMTIME('IFI','CU1',SDTIME,LBID  ,R8BID)
        VALI(1) = NINT(R8BID)
        CALL NMTIME('IFI','CU2',SDTIME,LBID  ,R8BID)
        VALI(2) = NINT(R8BID)
        CALL NMTIME('IFI','CU3',SDTIME,LBID  ,R8BID)
        VALI(3) = NINT(R8BID)
        CALL NMTIME('IFI','CU4',SDTIME,LBID  ,R8BID)
        VALI(4) = NINT(R8BID)
        CALL NMTIME('IFI','CU5',SDTIME,LBID  ,R8BID)
        VALI(5) = NINT(R8BID)
        CALL NMTIME('IFI','CU6',SDTIME,LBID  ,R8BID)
        VALI(6) = NINT(R8BID)
        CALL NMTIME('IFI','CU7',SDTIME,LBID  ,R8BID)
        VALI(7) = NINT(R8BID)
        CALL NMTIME('IFI','CU8',SDTIME,LBID  ,R8BID)
        VALI(8) = NINT(R8BID)
        CALL NMTIME('IFI','CU9',SDTIME,LBID  ,R8BID)
        VALI(9) = NINT(R8BID)
        CALL NMTIME('IFI','C10',SDTIME,LBID  ,R8BID)
        VALI(10) = NINT(R8BID)
        CALL NMTIME('IFI','C11',SDTIME,LBID  ,R8BID)
        VALI(11) = NINT(R8BID)

        CALL NMTIME('IFR','CU1',SDTIME,LBID  ,R8BID)
        VALR(1) = R8BID
        CALL NMTIME('IFR','CU2',SDTIME,LBID  ,R8BID)
        VALR(2) = R8BID
        CALL NMTIME('IFR','CU3',SDTIME,LBID  ,R8BID)
        VALR(3) = R8BID
        CALL NMTIME('IFR','CU4',SDTIME,LBID  ,R8BID)
        VALR(4) = R8BID
        CALL NMTIME('IFR','CU5',SDTIME,LBID  ,R8BID)
        VALR(5) = R8BID
        CALL NMTIME('IFR','CU6',SDTIME,LBID  ,R8BID)
        VALR(6) = R8BID

        CALL NMIMPR('IMPR','TPS_FIN',' ',VALR,VALI)
      ELSE
        CALL ASSERT(.FALSE.)
      ENDIF
C
C --- REINITIALISATION STAT
C
      CALL NMTIME('INIT','STA',SDTIME,LBID  ,R8BID)
C
C --- REINITIALISATION POUR CONTACT
C
      IF (LCONT) THEN
        CALL CFITER(RESOCO,'I','    ',IBID,R8BID )
      ENDIF
C
      CALL JEDEMA()
      END
