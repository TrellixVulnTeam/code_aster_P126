       SUBROUTINE VDXSIG(NOMTE,OPTION,XI,NB1,NPGSR,SIGTOT,SIGMPG,EFFGT)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 30/01/2002   AUTEUR VABHHTS J.TESELET 
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
      IMPLICIT REAL*8 (A-H,O-Z)
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
      CHARACTER*32       JEXNUM , JEXNOM , JEXR8 , JEXATR
      INTEGER            ZI
      COMMON  / IVARJE / ZI(1)
      REAL*8             ZR
      COMMON  / RVARJE / ZR(1)
      COMPLEX*16         ZC
      COMMON  / CVARJE / ZC(1)
      LOGICAL            ZL
      COMMON  / LVARJE / ZL(1)
      CHARACTER*8        ZK8,NOMPU(2)
      CHARACTER*16                ZK16
      CHARACTER*24                          ZK24
      CHARACTER*32                                    ZK32
      CHARACTER*80                                              ZK80
      COMMON  / KVARJE / ZK8(1) , ZK16(1) , ZK24(1) , ZK32(1) , ZK80(1)
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX --------------------
      CHARACTER*2  CODRET(26)
      CHARACTER*16 NOMTE,OPTION
      CHARACTER*8 NOMRES(26), NOMPAR
      CHARACTER*10 PHENOM
      INTEGER NB1,NB2,NDDLE,NPGE,NPGSR,NPGSN,ITAB(8)
      REAL*8 XI(3,9),VALPU(2)
      REAL*8 VECTA(9,2,3),VECTN(9,3),VECTPT(9,2,3)
      REAL*8 VECTG(2,3),VECTT(3,3)
      REAL*8 HSFM(3,9),HSS(2,9),HSJ1M(3,9),HSJ1S(2,9)
      REAL*8 BTDM(4,3,42),BTDS(4,2,42)
      REAL*8 HSF(3,9),HSJ1FX(3,9),WGT
      REAL*8 BTDF(3,42),BTILD(5,42),VALRES(26)
      REAL*8 EPAIS
      REAL*8 DEPL(42),ROTF(9),SIGMPG(108)
      REAL*8 EPSILN(6,18),SIGMA(6,18),SIGTOT(6,9),EFFGT(8,9)
      REAL*8 TMOY(9),TINF(9),TSUP(9),TEMPGA(18),FORTHI(1)
      REAL*8 YOUNG,NU,ALPHA
      REAL*8 EPSI(5)
      PARAMETER (NPGE=2)
      REAL*8 EPSVAL(NPGE),KSI3S2,KSI3,COEVAL(NPGE)
      DATA EPSVAL / -0.577350269189626D0,  0.577350269189626D0 /
C
      ZERO = 0.0D0
      RAC2 = SQRT(2.D0)
C
C     RECUPERATION DES OBJETS
C
      CALL JEVETE('&INEL.'//NOMTE(1:8)//'.DESI',' ', LZI )
      NB1  =ZI(LZI-1+1)
      NB2  =ZI(LZI-1+2)
      NPGSR=ZI(LZI-1+3)
      NPGSN=ZI(LZI-1+4)
C
      CALL JEVETE('&INEL.'//NOMTE(1:8)//'.DESR',' ', LZR )
C
      CALL JEVECH ('PCACOQU' , 'L' , JCARA)
      EPAIS = ZR(JCARA)
C
C     RECUPERATION DE LA TEMPERATURE DE REFERENCE
C
      CALL JEVECH('PTEREF','L',JTREF)
      TREF=ZR(JTREF)
C
      CALL VECTAN(NB1,NB2,XI,ZR(LZR),VECTA,VECTN,VECTPT)
C
      CALL JEVECH('PDEPLAR', 'L', JDEPG)
C
      CALL TRNDGL(NB2,VECTN,VECTPT,ZR(JDEPG),DEPL,ROTF)
C
C===============================================================
C     -- RECUPERATION DE LA TEMPERATURE :
C     -- SI LA TEMPERATURE EST CONNUE AUX NOEUDS :
      CALL TECAC2 ('ONN','PTEMPER',8,ITAB,IRET)
      ITEMP=ITAB(1)
      IF (ITEMP.GT.0) THEN
         DO 4 I=1,NB2
            CALL DXTPIF(ZR(ITEMP+3*(I-1)),ZL(ITAB(8)+3*(I-1)))
            TMOY(I)=ZR(ITEMP+3*(I-1)  )
            TINF(I)=ZR(ITEMP+3*(I-1)+1)
            TSUP(I)=ZR(ITEMP+3*(I-1)+2)
 4       CONTINUE
      ENDIF
C     -- SI LA TEMPERATURE EST UNE FONCTION DE 'INST' ET 'EPAIS'
      CALL TECACH(.TRUE.,.FALSE.,'PTEMPEF',1,ITEMP)
      IF (ITEMP.GT.0) THEN
         NOMPU(1)='INST'
         NOMPU(2)='EPAIS'
         CALL JEVECH ( 'PTEMPSR' ,'L', IBID )
         VALPU(1)= ZR(IBID)
C
         VALPU(2)= 0.D0
         CALL  FOINTE ('FM', ZK8(ITEMP), 2, NOMPU, VALPU, TMOY1, IER )
         VALPU(2)= -EPAIS/2.D0
         CALL  FOINTE ('FM', ZK8(ITEMP), 2, NOMPU, VALPU, TINF1, IER )
         VALPU(2)= +EPAIS/2.D0
         CALL  FOINTE ('FM', ZK8(ITEMP), 2, NOMPU, VALPU, TSUP1, IER )
         DO 5 I=1,NB2
            TMOY(I)=TMOY1
            TINF(I)=TINF1
            TSUP(I)=TSUP1
 5       CONTINUE
      ENDIF
C
C===============================================================
C
      KWGT=0
      KPGS=0
C
      DO 100 INTE=1,NPGE
C
C     CALCUL DE BTDMR, BTDSR : M=MEMBRANE , S=CISAILLEMENT , R=REDUIT
C
        KSI3S2=EPSVAL(INTE)/2.D0
C
        DO 150 INTSR=1,NPGSR
          CALL MAHSMS(0,NB1,XI,KSI3S2,INTSR,ZR(LZR),EPAIS,VECTN,
     &                                       VECTG,VECTT,HSFM,HSS)
C
          CALL HSJ1MS(XI,INTE,INTSR,ZR(LZR),EPAIS,VECTG,VECTT,HSFM,HSS,
     &                                                  HSJ1M,HSJ1S)
C
          CALL BTDMSR(NB1,NB2,XI,KSI3S2,INTSR,ZR(LZR),EPAIS,VECTPT,
     &                                       HSJ1M,HSJ1S,BTDM,BTDS)
 150    CONTINUE
C
        DO 200 INTSN=1,NPGSN
C
C     CALCUL DE BTDFN : F=FLEXION , N=NORMAL
C     ET DEFINITION DE WGT=PRODUIT DES POIDS ASSOCIES AUX PTS DE GAUSS
C                          (NORMAL) ET DU DETERMINANT DU JACOBIEN
C
          CALL MAHSF(1,NB1,XI,KSI3S2,INTSN,ZR(LZR),EPAIS,VECTN,
     &                                             VECTG,VECTT,HSF)
C
          CALL HSJ1F(XI,INTE,INTSN,ZR(LZR),EPAIS,VECTG,VECTT,HSF,
     &                                                  KWGT,HSJ1FX,WGT)
C
          CALL BTDFN(1,NB1,NB2,XI,KSI3S2,INTSN,ZR(LZR),EPAIS,VECTPT,
     &                                                      HSJ1FX,BTDF)
C
C     CALCUL DE BTDMN, BTDSN : M=MEMBRANE , S=CISAILLEMENT , N=NORMAL
C     ET
C     FORMATION DE BTILD
C
          CALL BTDMSN(1,NB1,XI,INTE,INTSN,NPGSR,ZR(LZR),BTDM,BTDF,BTDS,
     &                                                            BTILD)
C
C     APPEL DE MATRTH POUR RECUPERER INDITH AFIN DE SAVOIR SI
C     ALPHA EST DONNE C'EST A DIRE SI THERMIQUE
C
          CALL MATRTH(INTE,INTSN,NB2,YOUNG,NU,ALPHA,INDITH)
          IF (INDITH.EQ.0) THEN
            INDIC=0
            KSI3=EPSVAL(INTE)
            CALL BTLDTH(NB1,KSI3,INTSN,ZR(LZR),TREF,TMOY,TINF,TSUP,
     &                     BTILD,WGT,INDIC,YOUNG,NU,ALPHA,TEMPER,FORTHI)
            TEMPGA(KWGT)=TEMPER
          ENDIF
C
          CALL VDESGA(KWGT,INTE,INTSN,NB1,NB2,XI,DEPL,BTILD,INDITH,
     &                               ALPHA,TEMPGA,EPSILN,SIGMA,VECTT)
C
          KPGS = KPGS+1
          K1=6*(KPGS-1)
          DO 35 I=1,3
            SIGMPG(K1+I) = SIGMA(I,KPGS)
 35       CONTINUE
          SIGMPG(K1+4) = SIGMA(4,KPGS)/RAC2
          SIGMPG(K1+5) = SIGMA(5,KPGS)/RAC2
          SIGMPG(K1+6) = SIGMA(6,KPGS)/RAC2
C
 200    CONTINUE
 100  CONTINUE
C
      KWGT=0
      KPGS=0
      DO 101 INTE=1,NPGE
C
C     CALCUL DE BTDMR, BTDSR : M=MEMBRANE , S=CISAILLEMENT , R=REDUIT
C
      KSI3S2=EPSVAL(INTE)/2.D0
      DO 151 INTSR=1,NPGSR
        CALL MAHSMS(0,NB1,XI,KSI3S2,INTSR,ZR(LZR),EPAIS,VECTN,
     &                                       VECTG,VECTT,HSFM,HSS)
C
        CALL HSJ1MS(XI,INTE,INTSR,ZR(LZR),EPAIS,VECTG,VECTT,HSFM,HSS,
     &                                                  HSJ1M,HSJ1S)
C
        CALL BTDMSR(NB1,NB2,XI,KSI3S2,INTSR,ZR(LZR),EPAIS,VECTPT,
     &                                       HSJ1M,HSJ1S,BTDM,BTDS)
C
C       CALL BTDMSP(NB1,NB2,XI,INTE,INTSR,ZR(LZR),EPAIS,VECTPT,
C    &                                       HSJ1M,HSJ1S,BTDM,BTDS)
        CALL MAHSF(0,NB1,XI,KSI3S2,INTSR,ZR(LZR),EPAIS,VECTN,
     &                                             VECTG,VECTT,HSF)
C
        CALL HSJ1F(XI,INTE,INTSR,ZR(LZR),EPAIS,VECTG,VECTT,HSF,
     &                                                  KWGT,HSJ1FX,WGT)
C
        CALL BTDFN(0,NB1,NB2,XI,KSI3S2,INTSR,ZR(LZR),EPAIS,VECTPT,
     &                                                      HSJ1FX,BTDF)
C     CALL BTDFP(0,NB1,NB2,XI,INTE,INTSR,ZR(LZR),EPAIS,VECTPT,HSJ1FX,
C    &                                                             BTDF)
C
        CALL BTDMSN(0,NB1,XI,INTE,INTSR,NPGSR,ZR(LZR),BTDM,BTDF,BTDS,
     &                                                            BTILD)
C
C     CALL BTILDP(0,NB1,XI,INTE,INTSR,NPGSR,ZR(LZR),BTDM,BTDF,BTDS,
C    &                                                            BTILD)
C
C     APPEL DE MATRTH POUR RECUPERER INDITH AFIN DE SAVOIR SI
C     ALPHA EST DONNE C'EST A DIRE SI THERMIQUE
C
        CALL MATRTH(INTE,INTSR,NB2,YOUNG,NU,ALPHA,INDITH)
        IF (INDITH.EQ.0) THEN
          INDIC=0
          KSI3=EPSVAL(INTE)
          CALL BTLDTH(NB1,KSI3,INTSR,ZR(LZR),TREF,TMOY,TINF,TSUP,BTILD,
     &                         WGT,INDIC,YOUNG,NU,ALPHA,TEMPER,FORTHI)
          TEMPGA(KWGT)=TEMPER
        ENDIF
C
        CALL VDESGA(KWGT,INTE,INTSR,NB1,NB2,XI,DEPL,BTILD,INDITH,ALPHA,
     &                                       TEMPGA,EPSILN,SIGMA,VECTT)
C
 151  CONTINUE
 101  CONTINUE
C
      IF (OPTION(1:9).EQ.'EPSI_ELNO'.OR.
     &    OPTION(1:9).EQ.'SIGM_ELNO') THEN
C
        CALL JEVECH('PNUMCOR','L',JNUMCO)
        INIV=ZI(JNUMCO+1)
        CALL VDESND(NOMTE,OPTION,INIV,NB1,NPGE,NPGSR,ZR(LZR),EPSILN
     &                                                    ,SIGMA,SIGTOT)
C
      ELSE IF (OPTION(1:9).EQ.'EFGE_ELNO') THEN
C
        CALL VDEFGE(NOMTE,OPTION,NB1,NPGSR,ZR(LZR),EPAIS,SIGMA,EFFGT)
C
      ENDIF
C
C --- DETERMINATION DES REPERES  LOCAUX DE L'ELEMENT AUX POINTS
C --- D'INTEGRATION ET STOCKAGE DE CES REPERES DANS LE VECTEUR .DESR :
C     --------------------------------------------------------------
      K = 0
      DO 110 INTSR=1,NPGSR
        CALL VECTGT(0,NB1,XI,ZERO,INTSR,ZR(LZR),EPAIS,VECTN,VECTG,VECTT)
C
        DO 120 J = 1, 3
          DO 130 I = 1, 3
            K = K + 1
            ZR(LZR+2000+K-1) = VECTT(I,J)
 130      CONTINUE
 120    CONTINUE
 110  CONTINUE
C
      END
