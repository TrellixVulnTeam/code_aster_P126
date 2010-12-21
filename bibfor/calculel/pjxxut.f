      SUBROUTINE PJXXUT(DIM,MOCLE,MOA1,MOA2,NBMA1,LIMA1,NBNO2,LINO2,MA1,
     &                  MA2,NBTMX,NBTM,NUTM,ELRF)
      IMPLICIT NONE
      CHARACTER*2 DIM
      CHARACTER*8 MOA1,MOA2,MA1,MA2
      CHARACTER*(*) MOCLE
      INTEGER NBMA1,LIMA1(*),NBNO2,LINO2(*),NBTMX,NBTM,NUTM(NBTMX)
      CHARACTER*8 ELRF(NBTMX)
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 20/12/2010   AUTEUR PELLET J.PELLET 
C TOLE CRS_1404
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
C RESPONSABLE PELLET J.PELLET
C ======================================================================
C BUT :
C   PREPARER LA LISTE DES MAILLES ET LES LISTES DE NOEUDS
C   UTILES A LA PROJECTION:

C   CETTE ROUTINE PRODUIT LES OBJETS SUIVANTS :
C    '&&PJXXCO.LIMA1' : NUMEROS DES MAILLES UTILES DE MOA1
C    '&&PJXXCO.LINO1' : NUMEROS DES NOEUDS UTILES DE MOA1
C    '&&PJXXCO.LINO2' : NUMEROS DES NOEUDS UTILES DE MOA2

C   M1 EST LE NOM DU MAILLAGE (OU DU MODELE) INITIAL
C   M2 EST LE NOM DU MAILLAGE (OU DU MODELE) FINAL

C   LES MAILLES UTILES DE MOA1 SONT CELLES QUI :
C      - SONT D'UN TYPE COHERENT AVEC DIM :
C             PAR EXEMPLE : '2D' -> TRIA/QUAD
C      - SONT PORTEUSES D'ELEMENTS FINIS (SI M1 EST UN MODELE)
C      - SONT INCLUSES DANS LIMA1 (SI MOCLE='PARTIE')

C   LES NOEUDS UTILES DE MOA1 SONT CEUX QUI SONT PORTES PAR LES
C   MAILLES UTILES DE MOA1

C   LES NOEUD UTILES DE MOA2 SONT CEUX QUI :
C      - SONT PORTES PAR LES MAILLES SUPPORTANT LES ELEMENTS FINIS
C        (SI M1 EST UN MODELE)
C      - SONT INCLUS DANS LINO2 (SI MOCLE='PARTIE')

C  SI MOCLE='TOUT' :
C     - ON NE SE SERT PAS DE NBMA1,LIMA1,NBNO2,LINO2

C-----------------------------------------------------------------------
C  IN        DIM    K2:  /'1D'  /'2D'  /'3D'
C  IN        MOCLE  K*:  /'TOUT'  /'PARTIE'

C  IN/JXIN   MOA1    K8  : NOM DU MAILLAGE (OU MODELE) INITIAL
C  IN/JXIN   MOA2    K8  : NOM DU MAILLAGE (OU MODELE) SUR LEQUEL ON
C                          VEUT PROJETER

C  IN        NBMA1    I   : NOMBRE DE MAILLES DE LIMA1
C  IN        LIMA1(*) I   : LISTE DE NUMEROS DE MAILLES (DE MOA1)
C  IN        NBNO2    I   : NOMBRE DE NOEUDS DE LINO2
C  IN        LINO2(*) I   : LISTE DE NUMEROS DE NOEUDS (DE MOA2)
C  OUT       MA1      K8  : NOM DU MAILLAGE ASSOCIE A MOA1
C  OUT       MA2      K8  : NOM DU MAILLAGE ASSOCIE A MOA2
C  IN        NBTMX    I   : DIMENSION DU TABLEAU NUTM
C  OUT       NBTM     I   : NOMBRE DE TYPE_MAILLE POUR DIM
C  OUT       NUTM(*)  I   : NUMEROS DES TYPE_MAILLE POUR DIM
C  OUT       ELRF(*)  K8  : ELREFES DES TYPE_MAILLE POUR DIM
C ----------------------------------------------------------------------
C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------
      CHARACTER*32 JEXNUM,JEXNOM,JEXR8,JEXATR
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

C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------

      CHARACTER*8 KB,MO1,MO2
      CHARACTER*8 NOTM(NBTMX)

      INTEGER IBID,IE,NNO1,NNO2,NMA1,NMA2,I,K,J
      INTEGER IMA,NBNO,INO,NUNO,INO2,KK,IMA1
      INTEGER IALIM1,IAD,LONG,IALIN1,IACNX1,ILCNX1,IALIN2
      INTEGER IEXI

C DEB ------------------------------------------------------------------
      CALL JEMARQ()

C     MOA1 EST IL UN MODELE OU UN MAILLAGE ?
      CALL JEEXIN(MOA1//'.MODELE    .NBNO',IEXI)
      IF (IEXI.GT.0) THEN
        MO1=MOA1
        CALL DISMOI('F','NOM_MAILLA',MO1,'MODELE',IBID,MA1,IE)
      ELSE
        MO1=' '
        MA1=MOA1
      ENDIF

C     MOA2 EST IL UN MODELE OU UN MAILLAGE ?
      CALL JEEXIN(MOA2//'.MODELE    .NBNO',IEXI)
      IF (IEXI.GT.0) THEN
        MO2=MOA2
        CALL DISMOI('F','NOM_MAILLA',MO2,'MODELE',IBID,MA2,IE)
        CALL PJNOUT(MO2)
      ELSE
        MO2=' '
        MA2=MOA2
      ENDIF


      CALL DISMOI('F','NB_NO_MAILLA',MA1,'MAILLAGE',NNO1,KB,IE)
      CALL DISMOI('F','NB_NO_MAILLA',MA2,'MAILLAGE',NNO2,KB,IE)
      CALL DISMOI('F','NB_MA_MAILLA',MA1,'MAILLAGE',NMA1,KB,IE)
      CALL DISMOI('F','NB_MA_MAILLA',MA2,'MAILLAGE',NMA2,KB,IE)



C     1 : TYPE_MAILLES UTILES DE MOA1 :
C     ----------------------------------
      IF (DIM.EQ.'1D') THEN
        NBTM=3
        NOTM(1)='SEG2'
        NOTM(2)='SEG3'
        NOTM(3)='SEG4'

        ELRF(1)='SE2'
        ELRF(2)='SE3'
        ELRF(3)='SE4'
      ELSEIF (DIM.EQ.'2D') THEN
        NBTM=6
        NOTM(1)='TRIA3'
        NOTM(2)='TRIA6'
        NOTM(3)='TRIA7'
        NOTM(4)='QUAD4'
        NOTM(5)='QUAD8'
        NOTM(6)='QUAD9'

        ELRF(1)='TR3'
        ELRF(2)='TR6'
        ELRF(3)='TR7'
        ELRF(4)='QU4'
        ELRF(5)='QU8'
        ELRF(6)='QU9'
      ELSEIF (DIM.EQ.'3D') THEN
        NBTM=10
        NOTM(1)='TETRA4'
        NOTM(2)='TETRA10'
        NOTM(3)='PENTA6'
        NOTM(4)='PENTA15'
        NOTM(5)='PENTA18'
        NOTM(6)='HEXA8'
        NOTM(7)='HEXA20'
        NOTM(8)='HEXA27'
        NOTM(9)='PYRAM5'
        NOTM(10)='PYRAM13'

        ELRF(1)='TE4'
        ELRF(2)='T10'
        ELRF(3)='PE6'
        ELRF(4)='P15'
        ELRF(5)='P18'
        ELRF(6)='HE8'
        ELRF(7)='H20'
        ELRF(8)='H27'
        ELRF(9)='PY5'
        ELRF(10)='P13'
      ELSE
        CALL ASSERT(.FALSE.)
      ENDIF

      DO 10,K=1,NBTM
        CALL JENONU(JEXNOM('&CATA.TM.NOMTM',NOTM(K)),NUTM(K))
   10 CONTINUE



C     2 : MAILLES UTILES DE MOA1 :
C     ----------------------------
      CALL WKVECT('&&PJXXCO.LIMA1','V V I',NMA1,IALIM1)
      IF (MO1.NE.' ') THEN
        CALL JEVEUO(MO1//'.MAILLE','L',IAD)
        CALL JELIRA(MO1//'.MAILLE','LONMAX',LONG,KB)
        DO 20,I=1,LONG
          IF (ZI(IAD-1+I).NE.0)ZI(IALIM1-1+I)=1
   20   CONTINUE
      ELSE
        DO 30,I=1,NMA1
          ZI(IALIM1-1+I)=1
   30   CONTINUE
      ENDIF

      CALL JEVEUO(MA1//'.TYPMAIL','L',IAD)
      DO 50,J=1,NBTM
        DO 40,I=1,NMA1
          IF (ZI(IAD-1+I).EQ.NUTM(J))ZI(IALIM1-1+I)=ZI(IALIM1-1+I)+1
   40   CONTINUE
   50 CONTINUE

      DO 60,I=1,NMA1
        IF (ZI(IALIM1-1+I).EQ.1) THEN
          ZI(IALIM1-1+I)=0
        ELSEIF (ZI(IALIM1-1+I).EQ.2) THEN
          ZI(IALIM1-1+I)=1
        ELSEIF (ZI(IALIM1-1+I).GT.2) THEN
          CALL ASSERT(.FALSE.)
        ENDIF
   60 CONTINUE

      IF (MOCLE.EQ.'PARTIE') THEN
        DO 70,IMA1=1,NBMA1
          ZI(IALIM1-1+LIMA1(IMA1))=2*ZI(IALIM1-1+LIMA1(IMA1))
   70   CONTINUE
        DO 80,IMA1=1,NMA1
          ZI(IALIM1-1+IMA1)=ZI(IALIM1-1+IMA1)/2
   80   CONTINUE
      ENDIF


C     3 : NOEUDS UTILES DE MOA1 :
C     ---------------------------
      CALL WKVECT('&&PJXXCO.LINO1','V V I',NNO1,IALIN1)
      CALL JEVEUO(MA1//'.CONNEX','L',IACNX1)
      CALL JEVEUO(JEXATR(MA1//'.CONNEX','LONCUM'),'L',ILCNX1)
      DO 100,IMA=1,NMA1
        IF (ZI(IALIM1-1+IMA).EQ.0)GOTO 100
        NBNO=ZI(ILCNX1+IMA)-ZI(ILCNX1-1+IMA)
        DO 90,INO=1,NBNO
          NUNO=ZI(IACNX1+ZI(ILCNX1-1+IMA)-2+INO)
          ZI(IALIN1-1+NUNO)=1
   90   CONTINUE
  100 CONTINUE


C     4 : NOEUDS UTILES DE MOA2 :
C     ---------------------------
      CALL WKVECT('&&PJXXCO.LINO2','V V I',NNO2,IALIN2)

      IF (MO2.NE.' ') THEN
        CALL JEVEUO(MO2//'.NOEUD_UTIL','L',IAD)
        IF (MOCLE.EQ.'TOUT') THEN
          DO 110,INO=1,NNO2
            IF (ZI(IAD-1+INO).NE.0)ZI(IALIN2-1+INO)=1
  110     CONTINUE
        ELSEIF (MOCLE.EQ.'PARTIE') THEN
          DO 120,INO2=1,NBNO2
            IF (ZI(IAD-1+LINO2(INO2)).NE.0)ZI(IALIN2-1+LINO2(INO2))=1
  120     CONTINUE
        ENDIF
      ELSE
        IF (MOCLE.EQ.'TOUT') THEN
          DO 130,INO=1,NNO2
            ZI(IALIN2-1+INO)=1
  130     CONTINUE
        ELSEIF (MOCLE.EQ.'PARTIE') THEN
          DO 140,INO2=1,NBNO2
            ZI(IALIN2-1+LINO2(INO2))=1
  140     CONTINUE
        ENDIF
      ENDIF


C     ON ARRETE S'IL N'Y A PAS DE NOEUDS "2" :
C     ------------------------------------------------
      KK=0
      DO 150,K=1,NNO2
        IF (ZI(IALIN2-1+K).GT.0)KK=KK+1
  150 CONTINUE
      IF (KK.EQ.0) CALL U2MESS('F','CALCULEL4_54')

      CALL JEDEMA()
      END
