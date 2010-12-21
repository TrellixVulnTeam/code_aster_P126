      SUBROUTINE XTDEPM(NDIM  ,JNNM,JNNE,NDEPLE,
     &                  NSINGE,NSINGM,FFE   ,FFM   ,JDEPDE,
     &                  RRE   ,RRM ,JDDLE,JDDLM,
     &                  DDEPLE,DDEPLM)
C
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
C RESPONSABLE ABBAS M.ABBAS
C
      IMPLICIT NONE
      INTEGER NDIM,JNNM(3),JNNE(3)
      INTEGER NSINGE,NSINGM
      REAL*8  RRE,RRM
      INTEGER JDEPDE,NDEPLE,JDDLE(2),JDDLM(2)
      REAL*8  FFM(9),FFE(9)
      REAL*8  DDEPLE(3),DDEPLM(3)
C      
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODE XFEMGG - UTILITAIRE)
C
C CALCUL DES INCREMENTS - DEPLACEMENTS
C
C ----------------------------------------------------------------------
C
C
C IN  NDIM   : DIMENSION DU PROBLEME
C IN  NNE    : NOMBRE DE NOEUDS DE LA MAILLE ESCLAVE
C IN  NNM    : NOMBRE DE NOEUDS DE LA MAILLE MAITRE
C IN  NNES   : NOMBRE DE NOEUDS SOMMETS DE LA MAILLE ESCLAVE
C IN  NSINGE : NOMBRE DE FONCTIONS SINGULIERE ESCLAVES
C IN  NSINGM : NOMBRE DE FONCTIONS SINGULIERE MAIT RES
C IN  DDLES : NOMBRE DE DDLS D'UN NOEUD SOMMET ESCLAVE
C IN  RRE    : SQRT LSN PT ESCLAVE
C IN  RRM    : SQRT LSN PT MAITRE
C IN  JDEPDE : POINTEUR JEVEUX POUR DEPDEL
C IN  FFE    : FONCTIONS DE FORMES ESCLAVE
C IN  FFM    : FONCTIONS DE FORMES MAITRE
C OUT DDEPLE : INCREMENT DEPDEL DU DEPL. DU POINT DE CONTACT
C OUT DDEPLM : INCREMENT DEPDEL DU DEPL. DU PROJETE DU POINT DE CONTACT
C
C -------------- DEBUT DECLARATIONS NORMALISEES JEVEUX -----------------
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
C ---------------- FIN DECLARATIONS NORMALISEES JEVEUX -----------------
C
      INTEGER IDIM,INOE,INOM,ISINGM,ISINGE,PL,IN,JN,NDDLE
      INTEGER NNES,NNEM,NNM,NNMS,DDLES,DDLEM,DDLMS,DDLMM
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- INITIALISATIONS
C
      NNES=JNNE(2)
      NNEM=JNNE(3)
      NNM=JNNM(1)
      NNMS=JNNM(2)
      DDLES=JDDLE(1)
      DDLEM=JDDLE(2)
      DDLMS=JDDLM(1)
      DDLMM=JDDLM(2)
      NDDLE = DDLES*NNES+DDLEM*NNEM
C
      CALL VECINI(3,0.D0,DDEPLM)
      CALL VECINI(3,0.D0,DDEPLE)    

C
      DO 200 IDIM = 1,NDIM
        DO 210 INOE = 1,NDEPLE
          IF (NNM.NE.0) THEN
            CALL INDENT(INOE,DDLES,DDLEM,NNES,IN)
            PL           = IN + IDIM
            DDEPLE(IDIM) = DDEPLE(IDIM)+
     &                     FFE(INOE)*(ZR(JDEPDE-1+PL)-
     &                                ZR(JDEPDE-1+PL+NDIM))
          ENDIF
          DO 215 ISINGE = 1,NSINGE
            CALL INDENT(INOE+1,DDLES,DDLEM,NNES,IN)
            PL           = IN -2*NDIM+IDIM
            DDEPLE(IDIM) = DDEPLE(IDIM) - 
     &                     RRE*FFE(INOE)*ZR(JDEPDE-1+PL)
 215      CONTINUE
 210    CONTINUE
 200  CONTINUE     
C
      DO 201 IDIM = 1,NDIM
        DO 220 INOM = 1,NNM
          CALL INDENT(INOM,DDLMS,DDLMM,NNMS,JN)
          PL = NDDLE + JN + IDIM
          DDEPLM(IDIM) = DDEPLM(IDIM)+
     &                   FFM(INOM)*(ZR(JDEPDE-1+PL)+
     &                              ZR(JDEPDE-1+PL+NDIM))
          DO 225 ISINGM = 1,NSINGM
            DDEPLM(IDIM) = DDEPLM(IDIM) + 
     &                     RRM*FFM(INOM)*ZR(JDEPDE-1+PL+2*NDIM)
 225      CONTINUE
 220    CONTINUE     
 201  CONTINUE    
C
      CALL JEDEMA()
C
      END
