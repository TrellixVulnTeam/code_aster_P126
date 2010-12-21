      SUBROUTINE XENRCH(NOMO,NOMA  ,CNSLT ,CNSLN ,CNSLJ ,CNSEN ,CNSENR,
     &                 NDIM,FISS  ,LISMAE,LISNOE)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 21/12/2010   AUTEUR MASSIN P.MASSIN 
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
C RESPONSABLE GENIAUT S.GENIAUT
C
      IMPLICIT NONE
      INTEGER       NDIM
      CHARACTER*8   NOMA,FISS,NOMO
      CHARACTER*19  CNSLT,CNSLN,CNSLJ
      CHARACTER*19  CNSEN,CNSENR
      CHARACTER*24  LISMAE,LISNOE
C
C ----------------------------------------------------------------------
C
C ROUTINE XFEM (PREPARATION)
C
C CALCUL DE L'ENRICHISSEMENT ET DES POINTS DU FOND DE FISSURE - 2D/3D
C
C ----------------------------------------------------------------------
C
C
C I/O FISS   : NOM DE LA FISSURE
C IN  NOMO   : NOM DU MODELE
C IN  NOMA   : NOM DU MAILLAGE
C IN  LISMAE : NOM DE LA LISTE DES MAILLES ENRICHIES
C IN  LISNOE : NOM DE LA LISTE DES NOEUDS DE GROUP_ENRI
C IN  CNSLT  : LEVEL-SET TANGENTE (TRACE DE LA FISSURE)
C IN  CNSLN  : LEVEL-SET NORMALE  (PLAN DE LA FISSURE)
C IN  CNSLJ  : LEVEL-SET JONCTION
C OUT CNSEN  : CHAM_NO SIMPLE POUR LE STATUT DES NOEUDS
C OUT CNSENR : CHAM_NO SIMPLE REEL POUR VISUALISATION
C
C -------------- DEBUT DECLARATIONS NORMALISEES JEVEUX -----------------
C
      CHARACTER*32  JEXATR,JEXNUM
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
C ---------------- FIN DECLARATIONS NORMALISEES JEVEUX -----------------
C
      INTEGER       NXMAFI,NXPTFF
C
      INTEGER       IRET,NBNO,INO,IMAE,NMAFON,JFON,NFON
      INTEGER       JCOOR,JSTANO,JABSC
      INTEGER       JENSV,JENSL,NBMA
      INTEGER       JENSVR,JENSLR,JCARAF
      INTEGER       I,NMAFIS,IBID
      INTEGER       JMAFIS,JMAFON,K,JBAS,JMAEN1,JMAEN2,JMAEN3
      INTEGER       NBFOND,JFISAR,JFISDE,JBORD,NPTBOR,NUFI
      INTEGER       IFM,NIV
      INTEGER       NMAEN1,NMAEN2,NMAEN3,NCOUCH
      CHARACTER*8   K8BID
      CHARACTER*12  K12
      CHARACTER*16  TYPDIS
      CHARACTER*19  CNXINV
      CHARACTER*24  MAFIS,STANO,XCARFO
      REAL*8        M(3),P(3),Q(4),PADIST
      REAL*8        PFI(3),VOR(3),ORI(3),RAYON
      LOGICAL       AUTO
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFDBG('XFEM',IFM,NIV)
C
C --- ACCES AU MAILLAGE
C
      CALL JEVEUO(NOMA//'.COORDO    .VALE','L',JCOOR)
      CALL DISMOI('F','NB_NO_MAILLA',NOMA,'MAILLAGE',NBNO,K8BID,IRET)
      CALL DISMOI('F','NB_MA_MAILLA',NOMA,'MAILLAGE',NBMA,K8BID,IRET)

C     NOMBRE MAX DE MAILLES TRAVERSEES PAR LA FISSURE
      NXMAFI = NBMA

C     CONNECTIVITE INVERSEE
      CNXINV = '&&XENRCH.CNCINV'
      CALL CNCINV (NOMA,IBID,0,'V',CNXINV)
C
      CALL DISMOI('F','TYPE_DISCONTINUITE',FISS,'FISS_XFEM',
     &                                                 IBID,TYPDIS,IRET)
C
C --- RECUPERATION INFORMATIONS SUR LE FOND DE FISSURE
      RAYON  = 0.D0
      NCOUCH = 0
      IF (TYPDIS.EQ.'FISSURE') THEN
        XCARFO = FISS(1:8)//'.CARAFOND'
        CALL JEVEUO(XCARFO,'L',JCARAF)
        RAYON   = ZR(JCARAF)
        NCOUCH  = NINT(ZR(JCARAF+1))
        IF (NDIM.EQ.3) THEN
          VOR(1) = ZR(JCARAF+2)
          VOR(2) = ZR(JCARAF+3)
          VOR(3) = ZR(JCARAF+4)
          ORI(1) = ZR(JCARAF+5)
          ORI(2) = ZR(JCARAF+6)
          ORI(3) = ZR(JCARAF+7)
          PFI(1) = ZR(JCARAF+8)
          PFI(2) = ZR(JCARAF+9)
          PFI(3) = ZR(JCARAF+10)
          AUTO   = (NINT(ZR(JCARAF+11)).EQ.1)
        ENDIF
      ENDIF
C
C     VOIR ALGORITHME D�TAILL� DANS BOOK II (16/12/03)
C
C-------------------------------------------------------------------
C    1) ON RESTREINT LA ZONE D'ENRICHISSEMENT AUTOUR DE LA FISSURE
C-------------------------------------------------------------------

      IF (NIV.GE.3)
     &    WRITE(IFM,*)'1) RESTRICTION DE LA ZONE D ENRICHISSEMENT'

      MAFIS='&&XENRCH.MAFIS'
      CALL WKVECT(MAFIS,'V V I',NXMAFI,JMAFIS)
C     ATTENTION, MAFIS EST LIMIT� � NXMAFI MAILLES

      CALL XMAFIS(NOMA,CNSLN,NXMAFI,MAFIS,NMAFIS,LISMAE)
      IF (NIV.GE.2) CALL U2MESI('I','XFEM_19',1,NMAFIS)
      IF (NIV.GE.3) THEN
        CALL U2MESS('I','XFEM_26')
        DO 110 IMAE=1,NMAFIS
          WRITE(IFM,*)' ',ZI(JMAFIS-1+IMAE)
 110    CONTINUE
      ENDIF

C--------------------------------------------------------------------
C    2�) ON ATTRIBUE LE STATUT DES NOEUDS DE GROUP_ENRI
C--------------------------------------------------------------------

      IF (NIV.GE.3)
     &   WRITE(IFM,*)'2) ATTRIBUTION DU STATUT DES NOEUDS DE GROUPENRI'

C     CREATION DU VECTEUR STATUT DES NOEUDS
      STANO='&&XENRCH.STANO'
      CALL WKVECT(STANO,'V V I',NBNO,JSTANO)

C     ON INITIALISE POUR TOUS LES NOEUDS DU MAILLAGE ENR � 0
      CALL JERAZO(STANO,NBNO,1)

C     CALCUL DU STATUT DES NOEUDS
      CALL XSTANO(NOMA,LISNOE,NMAFIS,JMAFIS,CNSLT,CNSLN,CNSLJ,
     &            RAYON,CNXINV,STANO)

C--------------------------------------------------------------------
C    3�) ON ATTRIBUE LE STATUT DES MAILLES DU MAILLAGE
C        (MAILLES PRINCIPALES ET MAILLES DE BORD)
C        ET ON CONSTRUIT LES MAILLES DE MAFOND (NB MAX = NMAFIS)
C        + MAJ DU STANO SI ENRICHISSEMENT A NB COUCHES
C--------------------------------------------------------------------

      IF (NIV.GE.3) WRITE(IFM,*)'3) ATTRIBUTION DU STATUT DES MAILLES'

      IF (NMAFIS.EQ.0) THEN
        CALL U2MESS('A','XFEM_57')
        NMAFON=0
        NMAEN1=0
        NMAEN2=0
        NMAEN3=0
        GOTO 333
      ENDIF

      CALL WKVECT('&&XENRCH.MAFOND','V V I',NMAFIS,JMAFON)
      CALL WKVECT('&&XENRCH.MAENR1','V V I',NBMA,JMAEN1)
      CALL WKVECT('&&XENRCH.MAENR2','V V I',NBMA,JMAEN2)
      CALL WKVECT('&&XENRCH.MAENR3','V V I',NBMA,JMAEN3)

C     CALCUL EFFECTIF DU STATUT DES MAILLES (+MAJ STANO)
      CALL XSTAMA(NOMO,NOMA,NBMA,NMAFIS,JMAFIS,NCOUCH,LISNOE,
     &                  ZI(JSTANO),CNSLT,CNSLN,
     &                  JMAFON,JMAEN1,JMAEN2,JMAEN3,
     &                  NMAFON,NMAEN1,NMAEN2,NMAEN3 )

C     REPRISE SI NMAFIS=0
 333  CONTINUE

C     IMPRESSION DES MAILLES ENRICHIES
      CALL XSTAMI(NOMA,NMAFON,NMAEN1,NMAEN2,NMAEN3,
     &            JMAFON,JMAEN1,JMAEN2,JMAEN3)

C--------------------------------------------------------------------
C     3.5�) ENREGISTREMENT DES STATUT DES NOEUDS
C--------------------------------------------------------------------

C     RQ : ON NE PEUT PAS FAIRE CA AVANT CAR STANO EST MODIFIE
C     SI ON DEFINIT UN ENRICHISSEMENT GEOM A NB_COUCHES

C     ENREGISTREMENT DU CHAM_NO SIMPLE : STATUT DES NOEUDS
      CALL CNSCRE(NOMA,'NEUT_I',1,'X1','V',CNSEN)
      CALL JEVEUO(CNSEN//'.CNSV','E',JENSV)
      CALL JEVEUO(CNSEN//'.CNSL','E',JENSL)
      DO 210 INO=1,NBNO
        ZI(JENSV-1+(INO-1)+1)=ZI(JSTANO-1+(INO-1)+1)
        ZL(JENSL-1+(INO-1)+1)=.TRUE.
 210  CONTINUE

C     ENREGISTREMENT DU CHAM_NO SIMPLE REEL (POUR VISUALISATION)
      CALL CNSCRE(NOMA,'NEUT_R',1,'X1','V',CNSENR)
      CALL JEVEUO(CNSENR//'.CNSV','E',JENSVR)
      CALL JEVEUO(CNSENR//'.CNSL','E',JENSLR)
      DO 211 INO=1,NBNO
        ZR(JENSVR-1+(INO-1)+1)=ZI(JSTANO-1+(INO-1)+1)
        ZL(JENSLR-1+(INO-1)+1)=.TRUE.
 211  CONTINUE

C     POUR UNE INTERFACE, ON PASSE DIRECTEMENT A LA CREATION DE LA SD
      IF (TYPDIS.EQ.'INTERFACE') THEN
        CALL ASSERT(NMAEN2+NMAEN3.EQ.0)
        NFON = 0
        NBFOND = 0
        GOTO 800
      ENDIF

C--------------------------------------------------------------------
C    4�) RECHERCHES DES POINTS DE FONFIS (ALGO BOOK I 18/12/03)
C        ET REPERAGE DES POINTS DE BORD
C--------------------------------------------------------------------

      IF (NIV.GE.3) WRITE(IFM,*)'4) RECHERCHE DES POINTS DE FONFIS'

C     ON RAJOUTE +1 POUR LES CAS PARTICULIER OU TOUS LES ELTS
C     CONTIENNENT LE FOND DE FISSURE
      NXPTFF = NMAEN1 + NMAEN2 + NMAEN3 +1

      CALL WKVECT('&&XENRCH.FONFIS','V V R',4*NXPTFF,JFON)
      CALL WKVECT('&&XENRCH.BASFON','V V R',2*NDIM*NXPTFF,JBAS)
      CALL WKVECT('&&XENRCH.PTBORD','V V L',NXPTFF,JBORD)

      CALL XPTFON(NOMA,NDIM,NMAFON,CNSLT,CNSLN,CNXINV,JMAFON,NXPTFF,
     &            JFON,NFON,JBAS,JBORD,NPTBOR,FISS)
      CALL U2MESI('I','XFEM_33',1,NFON)

      IF (NFON.EQ.0) THEN
        CALL U2MESS('A','XFEM_58')
        IF (RAYON.GT.0.D0) CALL U2MESS('A','XFEM_59')
        CALL ASSERT(NMAEN2+NMAEN3.EQ.0)
        NBFOND = 0
C       ON PASSE DIRECTEMENT
        GOTO 800
      ENDIF

C--------------------------------------------------------------------
C    5�) ORIENTATION DES POINTS DE FONFIS (ALGO BOOK I 19/12/03)
C--------------------------------------------------------------------

C     SEULEMENT EN 3D
      IF (NDIM.EQ.3) THEN

        IF (NIV.GE.3) WRITE(IFM,*)'5) ORIENTATION DU FOND DE FISSURE'

        CALL XORIFF(NDIM,NFON,JFON,JBAS,JBORD,PFI,ORI,VOR,AUTO)

      ENDIF

C--------------------------------------------------------------------
C    6�) CALCUL DES FONDS MULTIPLES EVENTUELS
C--------------------------------------------------------------------

      IF (NIV.GE.3) WRITE(IFM,*)'6) CALCUL DES FONDS MULTIPLES'

      CALL WKVECT('&&XENRCH.FOMUDEP','V V I',NFON,JFISDE)
      CALL WKVECT('&&XENRCH.FOMUARR','V V I',NFON,JFISAR)

      IF (NDIM.EQ.3) THEN

        IF ((.NOT.ZL(JBORD)).AND.(NPTBOR.GT.0))
     &     CALL U2MESS('A','XFEM_60')
        NBFOND=1
        ZI(JFISDE-1+NBFOND)=1
        ZI(JFISAR-1+NBFOND)=1
C       BOUCLE SUR LES POINTS DU FOND DE FISSURE
        DO 600 I=2,NFON-1
          IF (ZL(JBORD+I-1)) THEN
C         LE POINT I EST UN POINT DE BORD
            IF (ZI(JFISDE-1+NBFOND).EQ.ZI(JFISAR-1+NBFOND).AND.
     &          ZI(JFISAR-1+NBFOND).NE.I) THEN
C             SI ON RECHERCHE LE POINT D'ARRIVE DE LA FISSURE NBFOND,
C             ET QUE LE POINT N'EST PAS DEJA REPERE EN DEPART DE LA
C             FISSURE NBFOND, ON A TROUVE LE POINT D'ARRIVEE DE LA
C             FISSURE NBFOND
              ZI(JFISAR-1+NBFOND)=I
              NBFOND=NBFOND+1
C             POINT SUIVANT EST POINT DE DEPART DE LA FISSURE SUIVANTE
              ZI(JFISDE-1+NBFOND)=I+1
              ZI(JFISAR-1+NBFOND)=I+1
            ENDIF
          ENDIF
600     CONTINUE
        ZI(JFISAR-1+NBFOND)=NFON

      ELSEIF (NDIM.EQ.2) THEN

        IF (NFON.GT.2) CALL U2MESS('F','XFEM_11')
C       EN 2D, CHAQUE POINT DE FOND DE FISSURE EST UN FOND A LUI SEUL
C       IL Y A DONC AUTANT DE FONDS MULTIPLES QUE DE POINTS (1 OU 2)
C       LES POINTS DE DEPART ET D'ARRIVEES SONT LES MEMES
        NBFOND=NFON
        DO 610 I=1,NFON
          ZI(JFISDE-1+I)=I
          ZI(JFISAR-1+I)=I
 610    CONTINUE

      ENDIF

      CALL U2MESI('I','XFEM_34',1,NBFOND)

C--------------------------------------------------------------------
C    7�) CALCUL DE L'ABSCISSE CURVILIGNE : S
C--------------------------------------------------------------------

      IF (NDIM.EQ.3) THEN

        IF (NIV.GE.3) WRITE(IFM,*)'6) CALCUL DES ABSCISSES CURVILIGNES'

        CALL WKVECT('&&XENRCH.ABSC','V V R',NFON,JABSC)

C       INITIALISATIONS
        I=1
        DO 700 K=1,3
          P(K)=ZR(JFON-1+4*(I-1)+K)
 700    CONTINUE
        ZR(JABSC-1+(I-1)+1)=0

C       CALCUL DE LA DISTANCE ENTRE CHAQUE POINT ET
C       CALCUL DE L'ABSCISSE CURVILIGNE EN SOMMANT CES DISTANCES
        NUFI=2
        DO 710 I=2,NFON
           DO 711 K=1,3
            M(K)=ZR(JFON-1+4*(I-1)+K)
 711      CONTINUE
          IF (ZI(JFISDE-1+NUFI).EQ.I) THEN
              ZR(JABSC-1+I)=0.D0
              NUFI=NUFI+1
          ELSE
              ZR(JABSC-1+(I-1)+1)=ZR(JABSC-1+(I-2)+1)+PADIST(3,M,P)
          ENDIF
          P(1)=M(1)
          P(2)=M(2)
          P(3)=M(3)
 710    CONTINUE

C       ON REMPLACE LES VALEURS DE THETA PAR CELLES DE S
        DO 720 I=1,NFON
          ZR(JFON-1+4*(I-1)+4)=ZR(JABSC-1+(I-1)+1)
 720    CONTINUE

      ENDIF

C     IMPRESSION DES POINTS DE FOND DE FISSURE (2D/3D)
      NUFI=1
      CALL U2MESS('I','XFEM_35')
      DO 799 I=1,NFON
        Q(1)=ZR(JFON-1+4*(I-1)+1)
        Q(2)=ZR(JFON-1+4*(I-1)+2)
        IF (NDIM.EQ.3) THEN
          Q(3)=ZR(JFON-1+4*(I-1)+3)
          Q(4)=ZR(JFON-1+4*(I-1)+4)
        ENDIF
        IF (ZI(JFISDE-1+NUFI).EQ.I) THEN
          CALL U2MESI('I','XFEM_36',1,NUFI)
          IF (NDIM.EQ.3) WRITE(IFM,797)
          IF (NDIM.EQ.2) WRITE(IFM,7970)
        ENDIF
        IF (NDIM.EQ.2) WRITE(IFM,798)(Q(K),K=1,2)
        IF (NDIM.EQ.3) WRITE(IFM,798)(Q(K),K=1,4)
        IF (ZI(JFISAR-1+NUFI).EQ.I)   NUFI=NUFI+1
 799  CONTINUE

 797  FORMAT(7X,'X',13X,'Y',13X,'Z',13X,'S')

 7970 FORMAT(7X,'X',13X,'Y')

 798  FORMAT(2X,4(E12.5,2X))


 800  CONTINUE
C
C --- CREATION DE LA SD
C
      CALL XLMAIL(NOMA  ,FISS  ,NMAEN1,NMAEN2,NMAEN3,
     &            JMAEN1,JMAEN2,JMAEN3,NFON,JFON,NBFOND,JBAS,
     &            JFISDE,JFISAR,NDIM)
C
C --- MENAGE
C
      CALL JEDETR(CNXINV)
      CALL JEDETR ('&&XENRCH.FONFIS')
      CALL JEDETR ('&&XENRCH.ABSC')
      CALL JEDETR ('&&XENRCH.MAFOND')
      CALL JEDETR ('&&XENRCH.MAENR1')
      CALL JEDETR ('&&XENRCH.MAENR2')
      CALL JEDETR ('&&XENRCH.MAENR3')
      CALL JEDETR ('&&XENRCH.PTBORD')
      CALL JEDETR ('&&XENRCH.FOMUDEP')
      CALL JEDETR ('&&XENRCH.FOMUARR')

      IF (NIV.GE.3) WRITE(IFM,*)'7) FIN DE XENRCH'

      CALL JEDEMA()
      END
