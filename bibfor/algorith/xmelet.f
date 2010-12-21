      SUBROUTINE XMELET(NOMTE , TYPMAI , TYPMAE ,TYPMAM ,TYPMAC  ,
     &                  NDIM  , NDDL   , JNNE   , JNNM  , 
     &                  NNC   , JDDLE  , JDDLM  ,
     &                  NCONTA, NDEPLE , NSINGE, NSINGM)
     
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
C
      IMPLICIT NONE
      CHARACTER*16 NOMTE   
      CHARACTER*8  TYPMAI,TYPMAE,TYPMAM,TYPMAC
      INTEGER      NDIM,NDDL,NNC
      INTEGER      NSINGE,NSINGM,NCONTA
      INTEGER      JNNE(3), JNNM(3),NDEPLE
      INTEGER      JDDLE(2),JDDLM(2)
C      
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODE XFEMGG - CALCUL ELEM.)
C
C RETOURNE QUELQUES INFOS SUR LES ELEMENTS DE CONTACT FORMES ENTRE
C DEUX ELEMENTS  X-FEM
C
C ----------------------------------------------------------------------
C ROUTINE SPECIFIQUE A L'APPROCHE <<GRANDS GLISSEMENTS AVEC XFEM>>,
C TRAVAIL EFFECTUE EN COLLABORATION AVEC I.F.P.
C ----------------------------------------------------------------------
C
C
C IN  NOMTE  : NOM DU TE DE L'ELEMENT DE CONTACT EN JEU
C OUT TYPMAI : NOM DE LA MAILLE ESCLAVE D'ORIGINE
C OUT TYPMAE : NOM DE LA MAILLE ESCLAVE
C OUT TYPMAM : NOM DE LA MAILLE MAITRE
C OUT TYPMAC : NOM DE LA MAILLE DE CONTACT
C OUT NDIM   : DIMENSION DE LA MAILLE DE CONTACT
C OUT NDDL   : NOMBRE TOTAL DE DEGRES DE LIBERTE DE LA MAILLE DE CONTACT
C OUT JNNE   : MAILLE ESCL : (1) NB NDS
C                            (2) NB NDS SOMMETS
C                            (3) NB NDS MILIEU
C OUT JNNM   : MAILLE MAIT : (1) NB NDS
C                            (2) NB NDS SOMMETS
C                            (3) NB NDS MILIEU
C OUT NNC    : NOMBRE DE NOEUDS DE LA MAILLE DE CONTACT
C OUT JDDLE  : MAILLE ESCL : (1) DDLS D'UN NOEUD SOMMET
C                            (2) DDLS D'UN NOEUD MILIEU
C OUT JDDLM  : MAILLE MAIT : (1) DDLS D'UN NOEUD SOMMET
C                            (2) DDLS D'UN NOEUD MILIEU
C OUT NCONTA : TYPE DE CONTACT (1=P1P1, 2=P1P1A, 3=P2P1)
C OUT NDEPLE : NOMBRE DE NOEUDS ESCL POSSEDANT DES DDLS DE DEPLACEMENT
C OUT NSINGE : NOMBRE DE FONCTIONS SINGULIERE ESCLAVES
C OUT NSINGM : NOMBRE DE FONCTIONS SINGULIERE MAITRES
C
C ----------------------------------------------------------------------
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
      CHARACTER*16             ZK16
      CHARACTER*24                      ZK24
      CHARACTER*32                               ZK32
      CHARACTER*80                                        ZK80
      COMMON  /KVARJE/ ZK8(1), ZK16(1), ZK24(1), ZK32(1), ZK80(1)
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------


      CHARACTER*8 ELREFP, ENRE, ENRM, TYPMA
      CHARACTER*8 LIELRF(10)
      INTEGER     NTROU, ILIE, NDIMD, NNOD, NNOSD, IBID , IER, I
      INTEGER     IADZI,IAZK24
      LOGICAL     ISMALI
      INTEGER     EN1,EN2,EN3,EN4,EN5,EN6
      REAL*8      X(27),VOL
      CHARACTER*8 FAPG(20)
C
C ----------------------------------------------------------------------
C
      CALL ELREF1(ELREFP)
      IF (ELREFP .EQ. 'HE8') TYPMAI = 'HEXA8'
      IF (ELREFP .EQ. 'PE6') TYPMAI = 'PENTA6'
      IF (ELREFP .EQ. 'TE4') TYPMAI = 'TETRA4'
      IF (ELREFP .EQ. 'QU4') TYPMAI = 'QUAD4'
      IF (ELREFP .EQ. 'QU8') TYPMAI = 'QUAD8'
      IF (ELREFP .EQ. 'TR3') TYPMAI = 'TRIA3'
      IF (ELREFP .EQ. 'TR6') TYPMAI = 'TRIA6'
C     
      CALL TEATTR (NOMTE,'S','XFEM_E',ENRE,IER)
      CALL TEATTR (NOMTE,'S','XFEM_M',ENRM,IER)
C
      DO 11 I= 1,3
        JNNE(I)=0
        JNNM(I)=0
 11   CONTINUE
C
      DO 12 I= 1,2
        JDDLE(I)=0
        JDDLM(I)=0
 12   CONTINUE
C
C
C --- NOMBRE DE FONCTIONS SINGULIERES    
C
      IF (ENRE.EQ.'H') THEN
        NSINGE = 0
      ELSEIF ((ENRE.EQ.'C').OR.(ENRE.EQ.'T')) THEN
        NSINGE = 1
      ELSE
        CALL U2MESK('F','DVP_4',1,NOMTE)
      ENDIF
C       
      IF (ENRM.EQ.'C') THEN
        NSINGM = 1
      ELSEIF ((ENRM.EQ.'H').OR.(ENRM.EQ.'T')) THEN
        NSINGM = 0
      ELSE
        CALL U2MESK('F','DVP_4',1,NOMTE)
      ENDIF
C
      CALL ELREF2(NOMTE,10,LIELRF,NTROU)
C
      DO 190 ILIE = 1, NTROU
        CALL ELREF4(LIELRF(ILIE),'NOEU',NDIMD,NNOD,NNOSD,IBID,
     &               IBID,IBID,IBID,IBID)
        IF ( ILIE.EQ.1 ) THEN
         NDIM = NDIMD
         JNNE(1)= NNOD
         JNNE(2)= NNOSD
         JNNE(3)= NNOD - NNOSD
         TYPMAE = LIELRF(ILIE)
        ENDIF
C
        IF ( ILIE.EQ.2 .AND. NTROU.EQ.3 ) THEN
         JNNM(1) = NNOD
         JNNM(2) = NNOSD
         JNNM(3) = NNOD - NNOSD
         TYPMAM  = LIELRF(ILIE)
        ENDIF
C
        IF ( ILIE.EQ.2 .AND. NTROU.EQ.2 ) THEN 
         JNNM(1)  = JNNE(1)
         TYPMAM = TYPMAE
         NNC  = NNOD
         TYPMAC = LIELRF(ILIE)
         JNNM(1)= JNNE(1)
         JNNM(2)= JNNE(2)
         JNNM(3)= JNNE(3)
        ENDIF
C
        IF ( ILIE.EQ.3 .AND. NTROU.EQ.3 ) THEN
         NNC  = NNOD
         TYPMAC = LIELRF(ILIE)
        ENDIF
 190  CONTINUE
C
      CALL TECAEL(IADZI,IAZK24)
      TYPMA=ZK24(IAZK24-1+3+ZI(IADZI-1+2)+3)
      IF (TYPMA(1:2).EQ.TYPMA(4:5)) THEN
        TYPMAE = TYPMAM
      ENDIF
C
      IF (ENRE.EQ.'T') THEN
        JNNM(1)  = 0
        JNNM(2)  = 0
        TYPMAM = '  '
      ENDIF     
C
C --- RECUPERATION DU TYPE DE CONTACT
C
      NCONTA=0
      IF (ISMALI(TYPMAI)) THEN
        NCONTA=1
      ELSE
        IF(ISMALI(TYPMAM)) THEN
          NCONTA=2
        ELSE
          NCONTA=3
        ENDIF
      ENDIF
C
C --- NOMBRE DE DDLS D'UN NOEUD SOMMET ESCLAVE    
C
      IF (ENRE.EQ.'T') THEN
        JDDLE(1)  = 2*NDIM
      ELSE
        JDDLE(1)  = NDIM *(3+NSINGE)
      ENDIF
C
C --- NOMBRE DE DDLS D'UN NOEUD MILIEU ESCLAVE    
C
      IF (NCONTA.EQ.2) THEN
        JDDLE(2)  = NDIM
      ELSEIF (NCONTA.EQ.3) THEN
        JDDLE(2)  = NDIM*2
      ENDIF
C
C --- NOMBRE DE DDLS D'UN NOEUD MAITRE    
C
      IF (ENRE.EQ.'T') THEN
        JDDLM(1)  = 0
        JDDLM(2)  = 0
      ELSE
        JDDLM(1)  = NDIM *(2+NSINGM)
        IF (.NOT.ISMALI(TYPMAM)) JDDLM(2)  = JDDLM(1)
      ENDIF
C
C --- CALCUL DU NOMBRE TOTAL DE DDL
C
      IF (ENRE.EQ.'T') THEN
        NDDL   = JDDLE(1)*JNNE(1)
      ELSE
C        IF (LMALIN) THEN
C          NDDL = NDIM * (NNE*(3+NSINGE) + NNM*(2+NSINGM))
C        ELSE
C          NDDL = NDIM * (NNE + 4*NNM)
C        ENDIF
      NDDL=0
        DO 13 I=1,2
          NDDL = NDDL + JNNE(I+1)*JDDLE(I) + JNNM(I+1)*JDDLM(I)
 13     CONTINUE
      ENDIF
C
      IF (NCONTA.EQ.1 .OR. NCONTA.EQ.3) THEN
        NDEPLE = JNNE(1)
      ELSEIF (NCONTA.EQ.2) THEN
        NDEPLE = JNNE(2)
      ELSE
      CALL ASSERT(.FALSE.)
      ENDIF
C
      END
