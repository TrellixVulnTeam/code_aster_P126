      SUBROUTINE  XKEL3D(ELREFP,NDIM,COORSE,IGEOM,HE,DDLH,DDLC,NFE,
     &                   BASLOC,NNOP,NPG,TYPMOD,OPTION,IMATE,COMPOR,
     &                   LGPG,CRIT,T,HYDR,SECH,TREF,DEPL,
     &                   SIG,VI,MATUU,VECTU,CODRET)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 24/10/2005   AUTEUR GENIAUT S.GENIAUT 
C ======================================================================
C COPYRIGHT (C) 1991 - 2005  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE VABHHTS J.PELLET
C TOLE CRP_21
C
      IMPLICIT NONE
C
      INTEGER       NDIM,IGEOM,IMATE,LGPG,CODRET,NNOP,NPG,DDLH,DDLC,NFE
      CHARACTER*8   ELREFP,TYPMOD(*)
      CHARACTER*16  OPTION,COMPOR(4)
      CHARACTER*24  COORSE
      REAL*8        BASLOC(9*NNOP),CRIT(3),T(NNOP),TREF,HE,HYDR(NNOP)
      REAL*8        SECH(NNOP),DEPL(NDIM+DDLH+NDIM*NFE+DDLC,NNOP)
      REAL*8        VI(LGPG,NPG),SIG(6,NPG),MATUU(*)
      REAL*8        VECTU(NDIM+DDLH+NDIM*NFE+DDLC,NNOP)
         
C.......................................................................
C
C     BUT:  CALCUL  DES OPTIONS RIGI_MECA_TANG, RAPH_MECA ET FULL_MECA
C           EN HYPER-ELASTICITE AVEC X-FEM
C.......................................................................

C IN  ELREFP  : �L�MENT DE R�F�RENCE PARENT
C IN  NDIM    : DIMENSION DE L'ESPACE
C IN  COORSE  : COORDONN�ES DES SOMMETS DU SOUS-�L�MENT
C IN  IGEOM   : COORDONN�ES DES NOEUDS DE L'�L�MENT PARENT
C IN  HE      : VALEUR DE LA FONCTION HEAVISIDE SUR LE SOUS-�LT
C IN  DDLH    : NOMBRE DE DDL HEAVYSIDE (PAR NOEUD)
C IN  DDLC    : NOMBRE DE DDL DE CONTACT (PAR NOEUD)
C IN  NFE     : NOMBRE DE FONCTIONS SINGULI�RES D'ENRICHISSEMENT
C IN  BASLOC  : BASE LOCALE AU FOND DE FISSURE AUX NOEUDS
C IN  NNOP    : NOMBRE DE NOEUDS DE L'ELEMENT PARENT
C IN  NPG     : NOMBRE DE POINTS DE GAUSS DU SOUS-�L�MENT
C IN  TYPMOD  : TYPE DE MODELISATION
C IN  OPTION  : OPTION DE CALCUL
C IN  IMATE   : MATERIAU CODE
C IN  COMPOR  : COMPORTEMENT
C IN  LGPG    : "LONGUEUR" DES VARIABLES INTERNES POUR 1 POINT DE GAUSS
C               CETTE LONGUEUR EST UN MAJORANT DU NBRE REEL DE VAR. INT.
C IN  CRIT    : CRITERES DE CONVERGENCE LOCAUX
C IN  T       : TEMPERATURE AUX NOEUDS
C IN  HYDR    : HYDRATATION AUX POINTS DE GAUSS
C IN  SECH    : SECHAGE AUX NOEUDS
C IN  TREF    : TEMPERATURE DE REFERENCE
C IN  DEPL    : DEPLACEMENT A PARTIR DE LA CONF DE REF
C OUT SIG     : CONTRAINTES DE CAUCHY (RAPH_MECA ET FULL_MECA)
C OUT VI      : VARIABLES INTERNES    (RAPH_MECA ET FULL_MECA)
C OUT MATUU   : MATRICE DE RIGIDITE PROFIL (RIGI_MECA_TANG ET FULL_MECA)
C OUT VECTU   : FORCES NODALES (RAPH_MECA ET FULL_MECA)
C......................................................................
C
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
      INTEGER  ZI
      COMMON  / IVARJE / ZI(1)
      REAL*8             ZR
      COMMON  / RVARJE / ZR(1)
      COMPLEX*16         ZC
      COMMON  / CVARJE / ZC(1)
      LOGICAL            ZL
      COMMON  / LVARJE / ZL(1)
      CHARACTER*8        ZK8
      CHARACTER*16                ZK16
      CHARACTER*24                          ZK24
      CHARACTER*32                                    ZK32
      CHARACTER*80                                              ZK80
      COMMON  / KVARJE / ZK8(1) , ZK16(1) , ZK24(1) , ZK32(1) , ZK80(1)
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------
C
      INTEGER  KPG,KK,N,I,M,J,J1,KL,PQ,KKD,INO,IG
      INTEGER  NNO,NNOS,NPGBIS,DDLT,DDLD,CPT,NDIMB
      INTEGER  JCOOPG,JDFD2,JGANO,JCOORS,IDFDE,IVF,IPOIDS
      LOGICAL  GRDEPL,GRROTA
      REAL*8   DSIDEP(6,6),F(3,3),EPS(6),R,SIGMA(6),FTF,DETF
      REAL*8   POIDS,TEMP,TMP1,TMP2,HYDRG,SECHG,FE(4),BASLOG(9)
      REAL*8   XG(NDIM),XE(NDIM),FF(NNOP),JAC,SIGP(6)
      REAL*8   RBID(4,3),RBID1(4),RBID2(4),RBID3(4),XYZ(NDIM)
      REAL*8   DFDI(NNOP,NDIM),PFF(6,NNOP,NNOP),DGDGL(4,3)
      REAL*8   DEF(6,NNOP,NDIM+DDLH+NDIM*NFE),GRAD(3,3)
C
      INTEGER INDI(6),INDJ(6),IADZI,IAZK24
      REAL*8  RIND(6),RAC2
      DATA    INDI / 1 , 2 , 3 , 1 , 1 , 2 /
      DATA    INDJ / 1 , 2 , 3 , 2 , 3 , 3 /
      DATA    RIND / 0.5D0,0.5D0,0.5D0,0.70710678118655D0,
     &               0.70710678118655D0,0.70710678118655D0 /
      DATA    RAC2 / 1.4142135623731D0 /
C--------------------------------------------------------------------
C
      CALL TECAEL(IADZI,IAZK24)
C      WRITE(6,*)'NUM NOP'
      DO 333 I=1,NNOP
C        WRITE(6,*)' ',ZI(IADZI-1+2+I)
 333  CONTINUE

C     ATTENTION, DEPL ET VECTU SONT ICI DIMENSIONN�S DE TELLE SORTE 
C     QU'ILS NE PRENNENT PAS EN COMPTE LES DDL SUR LES NOEUDS MILIEU

C     NOMBRE DE DDL DE DEPLACEMENT � CHAQUE NOEUD SOMMET 
      DDLD=NDIM+DDLH+NDIM*NFE

C     NOMBRE DE DDL TOTAL (DEPL+CONTACT) � CHAQUE NOEUD SOMMET
      DDLT=DDLD+DDLC
      
      GRDEPL  = COMPOR(3)(1:8) .EQ. 'GREEN   '
      GRROTA  = COMPOR(3)(1:8) .EQ. 'GREEN_GR'
C
      IF ( GRROTA ) THEN
        CALL UTMESS ('F','XKEL3D','ELEMENTS ISOPARAMETRIQUES 3D NON'
     &              //' DISPONIBLES EN GRANDES ROTATIONS')
      ENDIF
C      
C     ADRESSE DES COORD DU SOUS ELT EN QUESTION
      CALL JEVEUO(COORSE,'L',JCOORS)
C
C       TE4-'XINT' : SCH�MAS � 15 POINTS        
      CALL ELREF5('TE4','XINT',NDIMB,NNO,NNOS,NPGBIS,IPOIDS,JCOOPG,IVF,
     &                  IDFDE,JDFD2,JGANO)

      CALL ASSERT(NPG.EQ.NPGBIS.AND.NDIM.EQ.NDIMB)

C-----------------------------------------------------------------------
C     BOUCLE SUR LES POINTS DE GAUSS DU SOUS-T�TRA
      DO 100 KPG=1,NPG

C       COORDONN�ES DU PT DE GAUSS DANS LE REP�RE R�EL : XG 
        CALL LCINVN(NDIM,0.D0,XG)
        DO 110 I=1,NDIM
          DO 111 N=1,NNO
            XG(I)=XG(I)+ZR(IVF-1+NNO*(KPG-1)+N)*ZR(JCOORS-1+3*(N-1)+I)
 111      CONTINUE
 110    CONTINUE

C             JUSTE POUR CALCULER LES FF
        CALL REEREF(ELREFP,NNOP,IGEOM,XG,DEPL,GRDEPL,NDIM,HE,DDLH,NFE,
     &              DDLT,FE,DGDGL,'NON',XE,FF,DFDI,F,EPS,GRAD)

        IF (NFE.GT.0) THEN
C         BASE LOCALE AU POINT DE GAUSS
          CALL LCINVN(9,0.D0,BASLOG)
          DO 113 INO=1,NNOP
            DO 114 I=1,9 
              BASLOG(I) = BASLOG(I) + BASLOC(9*(INO-1)+I) * FF(INO)
 114        CONTINUE 
 113      CONTINUE
C
C         FONCTION D'ENRICHISSEMENT AU POINT DE GAUSS ET LEURS D�RIV�ES
          CALL XCALFE(XG,BASLOG,FE,DGDGL)
C         WRITE(6,*)'DGDGL AU POINT',((DGDGL(I,J),J=1,3),I=1,4)
        ENDIF        
C
C       COORDONN�ES DU POINT DE GAUSS DANS L'�L�MENT DE R�F PARENT : XE
C       ET CALCUL DE FF, DFDI, ET EPS
        CALL REEREF(ELREFP,NNOP,IGEOM,XG,DEPL,GRDEPL,NDIM,HE,DDLH,NFE,
     &              DDLT,FE,DGDGL,'OUI',XE,FF,DFDI,F,EPS,GRAD)
       
C 
C - CALCUL DE LA TEMPERATURE AU POINT DE GAUSS PARENT 
C              (C NIMP POUR L'HYDRG!)
        TEMP = 0.D0
        HYDRG = HYDR(KPG)
        SECHG = 0.D0
        DO 112 N=1,NNOP
          TEMP = TEMP + T(N)*FF(NNOP)
          SECHG = SECHG + SECH(N)*FF(NNOP)
 112    CONTINUE
C
C       CALCUL DES PRODUITS SYMETR. DE F PAR N,
        DO 120 N=1,NNOP
          CPT=0
C         FONCTIONS DE FORME CLASSIQUES
          DO 121 I=1,NDIM
            CPT=CPT+1
            DEF(1,N,I) =  F(I,1)*DFDI(N,1)
            DEF(2,N,I) =  F(I,2)*DFDI(N,2)
            DEF(3,N,I) =  F(I,3)*DFDI(N,3)
            DEF(4,N,I) = (F(I,1)*DFDI(N,2) + F(I,2)*DFDI(N,1))/RAC2
            DEF(5,N,I) = (F(I,1)*DFDI(N,3) + F(I,3)*DFDI(N,1))/RAC2
            DEF(6,N,I) = (F(I,2)*DFDI(N,3) + F(I,3)*DFDI(N,2))/RAC2
 121      CONTINUE
C         ENRICHISSEMENT PAR HEAVYSIDE
          DO 122 I=1,DDLH
            CPT=CPT+1
            DO 123 M=1,6
              DEF(M,N,CPT) =  DEF(M,N,I) * HE       
 123        CONTINUE
 122      CONTINUE
C         ENRICHISSEMENT PAR LES NFE FONTIONS SINGULI�RES
          DO 124 IG=1,NFE
            DO 125 I=1,3
              CPT=CPT+1
              DEF(1,N,CPT) =  F(I,1) *
     &             (DFDI(N,1) * FE(IG) + FF(N)*DGDGL(IG,1))
    
              DEF(2,N,CPT) =  F(I,2) *
     &             (DFDI(N,2) * FE(IG) + FF(N)*DGDGL(IG,2))
     
              DEF(3,N,CPT) =  F(I,3) *
     &             (DFDI(N,3) * FE(IG) + FF(N)*DGDGL(IG,3))
     
              DEF(4,N,CPT) = 
     &         ( F(I,1)* (DFDI(N,2)*FE(IG)+FF(N)*DGDGL(IG,2)) 
     &         + F(I,2)* (DFDI(N,1)*FE(IG)+FF(N)*DGDGL(IG,1)) )/RAC2
              
              DEF(5,N,CPT) =  
     &         ( F(I,1)* (DFDI(N,3)*FE(IG)+FF(N)*DGDGL(IG,3)) 
     &         + F(I,3)* (DFDI(N,1)*FE(IG)+FF(N)*DGDGL(IG,1)) )/RAC2
     
              DEF(6,N,CPT) =  
     &         ( F(I,3)* (DFDI(N,2)*FE(IG)+FF(N)*DGDGL(IG,2)) 
     &         + F(I,2)* (DFDI(N,3)*FE(IG)+FF(N)*DGDGL(IG,3)) )/RAC2
     
 125         CONTINUE
 124       CONTINUE
 
        CALL ASSERT(CPT.EQ.DDLD) 
 
 120    CONTINUE
C
C       POUR CALCULER LE JACOBIEN DE LA TRANSFO SSTET->SSTET REF
C       ON ENVOIE DFDM3D AVEC LES COORD DU SS-ELT  
        CALL DFDM3D(NNO,KPG,IPOIDS,IDFDE,ZR(JCOORS),
     &                                   RBID1,RBID2,RBID3,JAC)
C
C      CALCUL DES PRODUITS DE FONCTIONS DE FORMES (ET DERIVEES)
        IF ( (OPTION(1:10) .EQ. 'RIGI_MECA_'
     &  .OR.  OPTION(1: 9) .EQ. 'FULL_MECA'    ) .AND. GRDEPL) THEN
          DO 126 N=1,NNOP
            DO 127 M=1,N
              PFF(1,N,M) =  DFDI(N,1)*DFDI(M,1)
              PFF(2,N,M) =  DFDI(N,2)*DFDI(M,2)
              PFF(3,N,M) =  DFDI(N,3)*DFDI(M,3)
              PFF(4,N,M) =(DFDI(N,1)*DFDI(M,2)+DFDI(N,2)*DFDI(M,1))/RAC2
              PFF(5,N,M) =(DFDI(N,1)*DFDI(M,3)+DFDI(N,3)*DFDI(M,1))/RAC2
              PFF(6,N,M) =(DFDI(N,2)*DFDI(M,3)+DFDI(N,3)*DFDI(M,2))/RAC2
 127        CONTINUE
 126      CONTINUE
        ENDIF


C           WRITE(6,*)'EPS XZ',EPS(5)
C
C - LOI DE COMPORTEMENT : CALCUL DE S(E) ET DS/DE � PARTIR DE EPS
C                       {XX YY ZZ SQRT(2)*XY SQRT(2)*XZ SQRT(2)*YZ}
        CALL NMCPEL(3,TYPMOD,IMATE,COMPOR,CRIT,TEMP,TREF,HYDRG,
     &              SECHG,OPTION,EPS,SIGMA,VI(1,KPG),DSIDEP,CODRET)

C           WRITE(6,*)'HE ET SIGZZ',HE,SIGMA(3)
C         WRITE(6,*)'SIG',SIGMA(1),SIGMA(2),SIGMA(3)
C         WRITE(6,*)'SIG',SIGMA(4),SIGMA(5),SIGMA(6)

C - CALCUL DE LA MATRICE DE RIGIDITE
C
        IF ( OPTION(1:10) .EQ. 'RIGI_MECA_'
     &  .OR. OPTION(1: 9) .EQ. 'FULL_MECA'    ) THEN
C
          DO 130 N=1,NNOP
            DO 131 I=1,DDLD
              KKD = (DDLT*(N-1)+I-1) * (DDLT*(N-1)+I) /2
              DO 151,KL=1,6
                SIGP(KL)=0.D0
                SIGP(KL)=SIGP(KL)+DEF(1,N,I)*DSIDEP(1,KL)
                SIGP(KL)=SIGP(KL)+DEF(2,N,I)*DSIDEP(2,KL)
                SIGP(KL)=SIGP(KL)+DEF(3,N,I)*DSIDEP(3,KL)
                SIGP(KL)=SIGP(KL)+DEF(4,N,I)*DSIDEP(4,KL)
                SIGP(KL)=SIGP(KL)+DEF(5,N,I)*DSIDEP(5,KL)
                SIGP(KL)=SIGP(KL)+DEF(6,N,I)*DSIDEP(6,KL)
151           CONTINUE
              DO 140 J=1,DDLD
                DO 141 M=1,N
                  IF (M.EQ.N) THEN
                    J1 = I
                  ELSE
                    J1 = DDLD
                  ENDIF
C
C                 RIGIDITE GEOMETRIQUE
                  TMP1 = 0.D0
                  IF (GRDEPL .AND. I.EQ.J) THEN
                    TMP1 = 0.D0
                    TMP1 = TMP1+PFF(1,N,M)*SIGMA(1)
                    TMP1 = TMP1+PFF(2,N,M)*SIGMA(2)
                    TMP1 = TMP1+PFF(3,N,M)*SIGMA(3)
                    TMP1 = TMP1+PFF(4,N,M)*SIGMA(4)
                    TMP1 = TMP1+PFF(5,N,M)*SIGMA(5)
                    TMP1 = TMP1+PFF(6,N,M)*SIGMA(6)
                  ENDIF
C
C                 RIGIDITE ELASTIQUE
                  TMP2=0.D0
                  TMP2=TMP2+SIGP(1)*DEF(1,M,J)
                  TMP2=TMP2+SIGP(2)*DEF(2,M,J)
                  TMP2=TMP2+SIGP(3)*DEF(3,M,J)
                  TMP2=TMP2+SIGP(4)*DEF(4,M,J)
                  TMP2=TMP2+SIGP(5)*DEF(5,M,J)
                  TMP2=TMP2+SIGP(6)*DEF(6,M,J)
C                 STOCKAGE EN TENANT COMPTE DE LA SYMETRIE
                  IF (J.LE.J1) THEN
                     KK = KKD + DDLT*(M-1)+J
                     MATUU(KK) = MATUU(KK) + (TMP1+TMP2)*JAC
                  END IF
C
 141            CONTINUE
 140          CONTINUE
 131        CONTINUE
 130      CONTINUE
        ENDIF
C
       
C - CALCUL DE LA FORCE INTERIEURE ET DES CONTRAINTES DE CAUCHY
C
        IF(OPTION(1:9).EQ.'FULL_MECA'.OR.
     &     OPTION(1:9).EQ.'RAPH_MECA') THEN
C
          DO 180 N=1,NNOP
            DO 181 I=1,DDLD
              DO 182 KL=1,6
                VECTU(I,N)=VECTU(I,N)+DEF(KL,N,I)*SIGMA(KL)*JAC
 182          CONTINUE 
 181        CONTINUE
 180      CONTINUE
C
          IF (GRDEPL) THEN
C          CONVERSION LAGRANGE -> CAUCHY
            DETF = F(3,3)*(F(1,1)*F(2,2)-F(1,2)*F(2,1))
     &           - F(2,3)*(F(1,1)*F(3,2)-F(3,1)*F(1,2))
     &           + F(1,3)*(F(2,1)*F(3,2)-F(3,1)*F(2,2))
            DO 190 PQ = 1,6
              SIG(PQ,KPG) = 0.D0
              DO 200 KL = 1,6
                FTF = (F(INDI(PQ),INDI(KL))*F(INDJ(PQ),INDJ(KL)) +
     &              F(INDI(PQ),INDJ(KL))*F(INDJ(PQ),INDI(KL)))*RIND(KL)
                SIG(PQ,KPG) =  SIG(PQ,KPG)+ FTF*SIGMA(KL)
 200          CONTINUE
              SIG(PQ,KPG) = SIG(PQ,KPG)/DETF
 190        CONTINUE
          ELSE
C          SIMPLE CORRECTION DES CONTRAINTES
            DO 210 KL=1,3
              SIG(KL,KPG) = SIGMA(KL)
 210        CONTINUE
            DO 820 KL=4,6
              SIG(KL,KPG) = SIGMA(KL)/RAC2
 820        CONTINUE
          ENDIF
        ENDIF

 100  CONTINUE
 
      END
