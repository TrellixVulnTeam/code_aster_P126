      SUBROUTINE GMA110(NBGR,EXCLU,NBGRUT,MAILLA,NOMSST,NBTGRM,NOMRES,
     &                  NBINCR,TABSGR,TABSST,TABGMA,TABNOM)
      IMPLICIT REAL*8 (A-H,O-Z)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 19/10/2010   AUTEUR DELMAS J.DELMAS 
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
C***********************************************************************
C  BUT : < MAILLAGE SQUELETTE SOUS-STRUCTURATION CLASSIQUE >
C
C  TRAITEMENT DES GROUPES DE MAILLES :  ON CREE DES GROUPES DANS LE
C  SQUELETTE A PARTIR DES GOUPES EXISTANTS DANS LA SOUS-STRUCTURE
C
C-----------------------------------------------------------------------
C
C NBGR    /I/ : NOMBRE DE GROUPES DE MAILLES DES SOUS-STRUCTURES
C EXCLU   /I/ : INDIQUE SI ON NE PREND QUE LES GROUPES DE L'UTILISATEUR
C NBGRUT  /I/ : NOMBRE DE GROUPES DONNES PAR L'UTILISATEUR
C MAILLA  /I/ : NOM DU MAILLAGE
C NOMSST  /I/ : NOM DE LA SOUS-STRUCTURE COURANTE
C NBTGRM  /I&O/ : NOMBRE DE GROUPES PRIS EN COMPTE DANS LE SQUELETTE
C NOMRES  /I/ : NOM K8 DU MAILLAGE A CREER
C NBINCR  /I/ : DECALAGE DES NUMERO DE MAILLES DE LA SOUS-STRUCTURE
C TABSGR  /I/ : NOMS DES GROUPES DE LA SOUS-STRUCTURE
C TABSST  /I/ : NOMS DES SOUS-STRUCTURES DONNES PAR L'UTILIATEUR
C TABGMA  /I/ : NOMS DES GROUPES DONNES PAR L'UTILISATEUR
C TABNOM  /I/ : NOMS DES GROUPES DANS LE SQUELETTE
C
C EXEMPLE : LE GROUPE TABGMA(I) DE LA SOUS-STRUCTURE TABSST(I)
C           RECEVRA LE NOM TABNOM(I) DANS LE SQUELETTE
C
C-------- DEBUT COMMUNS NORMALISES  JEVEUX  ----------------------------
C
      INTEGER          ZI
      COMMON  /IVARJE/ ZI(1)
      REAL*8           ZR
      COMMON  /RVARJE/ ZR(1)
      COMPLEX*16       ZC
      COMMON  /CVARJE/ ZC(1)
      LOGICAL          ZL
      COMMON  /LVARJE/ ZL(1)
      CHARACTER*8      ZK8
      CHARACTER*16              ZK16
      CHARACTER*24                        ZK24
      CHARACTER*32                                  ZK32
      CHARACTER*80                                            ZK80
      COMMON  /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C
      CHARACTER*32 JEXNOM,JEXNUM
C
C----------  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
C
      CHARACTER*24 VALK(4)
      CHARACTER*8  NOMSST,NOMRES,MAILLA
      CHARACTER*8  TABSGR(*),TABSST(*),TABGMA(*),TABNOM(*)
      CHARACTER*8  K8BID,NOMGR,NOMUT,EXCLU
C
C-----------------------------------------------------------------------
C
      CALL JEMARQ()
C
      NGFIND = 0
      DO 40 IGR = 1,NBGR
         NOMGR = TABSGR(IGR)
         NOMUT = ' '
C     --- RECHERCHE DES NOMS DANS NOM_GROUP_MA ---
         IGRUT = 0
  10     CONTINUE
         IGRUT = IGRUT + 1
         IF (IGRUT .LE. NBGRUT) THEN
            IF (TABSST(IGRUT) .NE. NOMSST) GOTO 10
            IF (TABGMA(IGRUT) .NE. NOMGR) GOTO 10
            NGFIND = NGFIND + 1
            NOMUT = TABNOM(IGRUT)
         ENDIF
         IF (EXCLU.EQ.'OUI' .AND. NOMUT.EQ.' ') GOTO 40
         CALL JEVEUO(JEXNOM(MAILLA//'.GROUPEMA',NOMGR),'L',ILSTMA)
         CALL JELIRA(JEXNOM(MAILLA//'.GROUPEMA',NOMGR),
     &               'LONMAX',NBGRMA,K8BID)
         IF (NOMUT .EQ. ' ') THEN
            LENG1 = LXLGUT(NOMSST)
            LENG2 = LXLGUT(NOMGR)
            IF (LENG1+LENG2 .GT. 8) THEN
               VALK (1) = NOMGR
               VALK (2) = NOMSST
               CALL U2MESG('A', 'SOUSTRUC2_10',2,VALK,0,0,0,0.D0)
            ENDIF
            LENG2 = MIN(8-LENG1,LENG2)
            IF (LENG2.GT.0) THEN
               NOMUT=NOMSST(1:LENG1)//NOMGR(1:LENG2)
            ELSE
               NOMUT=NOMSST(1:LENG1)
            ENDIF
         ENDIF
         DO 20 IGROLD=1,NBTGRM
            CALL JENUNO(JEXNUM(NOMRES//'.GROUPEMA',IGROLD),K8BID)
            IF (NOMUT .EQ. K8BID) THEN
                  VALK (1) = NOMUT
                  VALK (2) = NOMSST
                  VALK (3) = NOMGR
                  VALK (4) = K8BID
               CALL U2MESG('F', 'ALGORITH13_26',4,VALK,0,0,0,0.D0)
            ENDIF
  20     CONTINUE
         CALL JECROC(JEXNOM(NOMRES//'.GROUPEMA',NOMUT))
         CALL JEECRA(JEXNOM(NOMRES//'.GROUPEMA',NOMUT),'LONMAX',
     &        MAX(1,NBGRMA),K8BID)
         CALL JEECRA(JEXNOM(NOMRES//'.GROUPEMA',NOMUT),'LONUTI',
     &               NBGRMA,K8BID)
         CALL JEVEUO(JEXNOM(NOMRES//'.GROUPEMA',NOMUT),'E',ILSTNO)
         NBTGRM = NBTGRM+1
         DO 30 IMA = 1,NBGRMA
            ZI(ILSTNO-1+IMA) = ZI(ILSTMA-1+IMA) + NBINCR
  30     CONTINUE
  40  CONTINUE
C
C --- ON VERIFIE SI LES GROUPES UTILISATEURS ONT TOUS ETE TROUVE
C
      NSFIND = 0
      DO 50 IGRUT =1,NBGRUT
         IF (TABSST(IGRUT) .EQ. NOMSST) NSFIND = NSFIND + 1
   50 CONTINUE
C
      IF (NSFIND .GT. NGFIND) THEN
C --- CERTAINS GROUPES N'ONT PAS ETE TROUVE
         DO 70 IGRUT =1,NBGRUT
            NOMUT = TABGMA(IGRUT)
            IF (TABSST(IGRUT) .EQ. NOMSST) THEN
               IGR = 1
 60            CONTINUE
               IF (IGR.LE.NBGR) THEN
                  IF (TABSGR(IGR) .NE. NOMUT) THEN
                     IGR = IGR + 1
                     GOTO 60
                  ENDIF
               ENDIF
               IF (IGR.GT.NBGR) THEN
                  VALK (1) = NOMUT
                  VALK (2) = K8BID
                  VALK (3) = NOMSST
                  CALL U2MESG('F', 'ALGORITH13_27',3,VALK,0,0,0,0.D0)
               ENDIF
            ENDIF
 70      CONTINUE
      ENDIF
C
      CALL JEDEMA()
      END
