      SUBROUTINE TE0510(OPTION,NOMTE)
      IMPLICIT   NONE
      CHARACTER*16 OPTION,NOMTE

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 21/12/2010   AUTEUR MASSIN P.MASSIN 
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
C.......................................................................
C
C       CALCUL DES DONN�ES TOPOLOGIQUES CONCERNANT LES INTERSECTIONS
C              DES �L�MENTS ENRICHIS ET DU PLAN DE LA FISSURE
C
C
C  OPTION : 'TOPOFA' (X-FEM TOPOLOGIE DES FACETTES DE CONTACT)
C
C  ENTREES  ---> OPTION : OPTION DE CALCUL
C           ---> NOMTE  : NOM DU TYPE ELEMENT
C
C......................................................................
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX --------------------
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR ,DDOT
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

C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX --------------------

      CHARACTER*8   ELP,TYPMA
      CHARACTER*24  PINTER,AINTER
      INTEGER       IGEOM,JLSN,JLST,JGRLSN,JGRLST
      INTEGER       JOUT1,JOUT2,JOUT3,JOUT4,JOUT5,JOUT6,JOUT7
      INTEGER       JPTINT,JAINT,IADZI,IAZK24
      INTEGER       NINTER,NFACE,CFACE(5,3),IN,IA,NA,NB,AR(12,3),NBAR
      INTEGER       I,J,K,JJ,NLI,NNOP
      REAL*8        LONGAR,AL,ND(3),GRLT(3),TAU1(3),TAU2(3),NORME,PS
      REAL*8        NORM2,PTREE(3),PTREF(3),RBID,RBID6(6),RBID3(3,3)
      REAL*8        FF(20), DFDI(20,3)
      INTEGER       NDIM,IBID,NPTF,NBTOT,NFISS
      LOGICAL       LBID,ISMALI
      INTEGER       ZXAIN,XXMMVD
      CHARACTER*16  ENR
C......................................................................

      CALL JEMARQ()

      ZXAIN = XXMMVD('ZXAIN')
      CALL ELREF1(ELP)
      CALL ELREF4(ELP,'RIGI',NDIM,NNOP,IBID,IBID,IBID,IBID,IBID,IBID)
C
C     RECUPERATION DES ENTR�ES / SORTIE
      CALL JEVECH('PGEOMER','L',IGEOM)
      CALL JEVECH('PLSN','L',JLSN)
      CALL JEVECH('PLST','L',JLST)
      CALL JEVECH('PGRADLN','L',JGRLSN)
      CALL JEVECH('PGRADLT','L',JGRLST)

      CALL JEVECH('PPINTER','E',JOUT1)
      CALL JEVECH('PAINTER','E',JOUT2)
      CALL JEVECH('PCFACE' ,'E',JOUT3)
      CALL JEVECH('PLONCHA','E',JOUT4)
      CALL JEVECH('PBASECO','E',JOUT5)
      CALL JEVECH('PGESCLA','E',JOUT6)
      CALL JEVECH('PGMAITR','E',JOUT7)

      CALL TECAEL(IADZI,IAZK24)
      TYPMA=ZK24(IAZK24-1+3+ZI(IADZI-1+2)+3)
      CALL CONARE(TYPMA,AR,NBAR)
      CALL TEATTR(NOMTE,'S','XFEM',ENR,IBID)
      IF (ENR.EQ.'XH1'.OR.ENR.EQ.'XH2'.OR.
     &    ENR.EQ.'XH3'.OR.ENR.EQ.'XH4') THEN
        NFISS = 2
      ELSE
        NFISS = 1
      ENDIF

C ----------------------------------------------------------------------
C     RECHERCHE DES INTERSECTIONS ARETES-FISSURE
C     ET D�COUPAGE EN FACETTES

      PINTER='&&TE0510.PTINTER'
      AINTER='&&TE0510.ATINTER'

      IF (NFISS.EQ.1) THEN
        IF (.NOT.ISMALI(ELP) .AND. NDIM.LE.2) THEN
          CALL XCFAQ2(JLSN,JLST,JGRLSN,IGEOM,PINTER,NINTER,
     &                AINTER,NFACE,NPTF,CFACE,NBTOT)
        ELSE
          CALL XCFACE(ELP,ZR(JLSN),ZR(JLST),JGRLSN,IGEOM,ENR,
     &                PINTER,NINTER,AINTER,NFACE,NPTF,CFACE)
          NBTOT=NINTER
        ENDIF
        CALL JEVEUO(PINTER,'L',JPTINT)
        CALL JEVEUO(AINTER,'L',JAINT)
      ELSE
C --- PAS D'ELEMENTS DOUBLES COUP�ES POUR L'INSTANT
        NINTER= 0
        NBTOT = 0
        NFACE = 0
        NPTF  = 0
      ENDIF

C     ARCHIVAGE DE PINTER, AINTER, GESCLA, GMAITR ET BASECO

      DO 110 I=1,NBTOT
        DO 111 J=1,NDIM
          PTREE(J)=ZR(JPTINT-1+NDIM*(I-1)+J)
          ZR(JOUT6-1+NDIM*(I-1)+J)=PTREE(J)
          ZR(JOUT7-1+NDIM*(I-1)+J)=PTREE(J)
 111    CONTINUE
C    ON TRANFORME LES COORDONN�ES R�ELES EN COORD. DANS L'�L�MENT DE REF
       CALL REEREF(ELP,NNOP,IBID,IGEOM,PTREE,IBID,LBID,NDIM,
     &      RBID,IBID,IBID,IBID,IBID,IBID,IBID,RBID,RBID3,'NON',
     &      PTREF,FF,DFDI,RBID3,RBID6,RBID3)

        DO 112 JJ=1,NDIM
          ZR(JOUT1-1+NDIM*(I-1)+JJ)=PTREF(JJ)
 112    CONTINUE
        DO 113 J=1,ZXAIN
          ZR(JOUT2-1+ZXAIN*(I-1)+J)=ZR(JAINT-1+ZXAIN*(I-1)+J)
 113    CONTINUE

C     CALCUL DE LA BASE COVARIANTE AUX POINTS D'INTERSECTION
C     ND EST LA NORMALE � LA SURFACE : GRAD(LSN)
C     TAU1 EST LE PROJET� DE GRAD(LST) SUR LA SURFACE
C     TAU2 EST LE PRODUIT VECTORIEL : ND ^ TAU1

C       INITIALISATION TAU1 POUR CAS 2D
        TAU1(3)=0.D0
        CALL VECINI(3,0.D0,ND)
        CALL VECINI(3,0.D0,GRLT)

        DO 114 J=1,NDIM
          DO 115 K=1,NNOP
            ND(J)  = ND(J) + FF(K)*ZR(JGRLSN-1+NDIM*(K-1)+J)
            GRLT(J)= GRLT(J) + FF(K)*ZR(JGRLST-1+NDIM*(K-1)+J)
 115      CONTINUE
 114    CONTINUE

        CALL NORMEV(ND,NORME)
        PS=DDOT(NDIM,GRLT,1,ND,1)
        DO 116 J=1,NDIM
          TAU1(J)=GRLT(J)-PS*ND(J)
 116    CONTINUE

        CALL NORMEV(TAU1,NORME)

        IF (NORME.LT.1.D-12) THEN
C         ESSAI AVEC LE PROJETE DE OX
          TAU1(1)=1.D0-ND(1)*ND(1)
          TAU1(2)=0.D0-ND(1)*ND(2)
          IF (NDIM .EQ. 3) TAU1(3)=0.D0-ND(1)*ND(3)
          CALL NORMEV(TAU1,NORM2)
          IF (NORM2.LT.1.D-12) THEN
C           ESSAI AVEC LE PROJETE DE OY
            TAU1(1)=0.D0-ND(2)*ND(1)
            TAU1(2)=1.D0-ND(2)*ND(2)
            IF (NDIM .EQ. 3) TAU1(3)=0.D0-ND(2)*ND(3)
            CALL NORMEV(TAU1,NORM2)
          ENDIF
          CALL ASSERT(NORM2.GT.1.D-12)
        ENDIF
        IF (NDIM .EQ. 3) THEN
         CALL PROVEC(ND,TAU1,TAU2)
        ENDIF
C
        DO 117 J=1,NDIM
          ZR(JOUT5-1+NDIM*NDIM*(I-1)+J)  =ND(J)
          ZR(JOUT5-1+NDIM*NDIM*(I-1)+J+NDIM)=TAU1(J)
          IF (NDIM .EQ. 3)
     &    ZR(JOUT5-1+NDIM*NDIM*(I-1)+J+2*NDIM)=TAU2(J)
 117    CONTINUE
 110  CONTINUE

C     ARCHIVAGE DE CFACE
      DO 120 I=1,NFACE        
        DO 121 J=1,NPTF
          ZI(JOUT3-1+NPTF*(I-1)+J)=CFACE(I,J)
 121    CONTINUE
 120  CONTINUE

C     ARCHIVAGE DE LONCHAM
      ZI(JOUT4-1+1)=NINTER
      ZI(JOUT4-1+2)=NFACE
      ZI(JOUT4-1+3)=NPTF

      CALL JEDETR(PINTER)
      CALL JEDETR(AINTER)

      CALL JEDEMA()
      END
