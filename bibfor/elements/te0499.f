      SUBROUTINE TE0499 ( OPTION , NOMTE )
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 04/04/2002   AUTEUR VABHHTS J.PELLET 
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
      CHARACTER*16        OPTION , NOMTE
C ......................................................................
C
C     BUT: CALCUL DES VECTEURS ELEMENTAIRES EN MECANIQUE
C          CORRESPONDANT A UN CHARGEMENT PAR ONDE PLANE
C          SUR DES FACES D'ELEMENTS ISOPARAMETRIQUES 2D
C
C          OPTION : 'ONDE_PLAN'
C
C    - ARGUMENTS:
C        DONNEES:      OPTION       -->  OPTION DE CALCUL
C                      NOMTE        -->  NOM DU TYPE ELEMENT
C ......................................................................
C
      CHARACTER*24       CARAC,FF
      CHARACTER*8        NOMRES(3),ELREFE
      CHARACTER*2        CODRET(3)
      CHARACTER*1        TYPE
      REAL*8             POIDS,NX,NY,VALRES(3),E,NU,LAMBDA,MU,CP,CS
      REAL*8             RHO,TAUX,TAUY,NUX,NUY,SCAL
      REAL*8             SIGMA(2,2),EPSI(2,2),GRAD(2,2)
      REAL*8             XGG(3),YGG(3),VONDN(2),VONDT(2)
      REAL*8             TAONDX,TAONDY,NORX,NORY,DIRX,DIRY,CELE
      REAL*8             TRACE,PARAM,DIST,NORM,JAC
      INTEGER            NNO,KP,NPG,ICARAC,IFF,IPOIDS,IVF,IDFDE,IGEOM
      INTEGER            IVECTU,K,I,MATER
C
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
      INTEGER            ZI
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
      CALL ELREF1(ELREFE)

      CARAC='&INEL.'//ELREFE//'.CARAC'
      CALL JEVETE(CARAC,'L',ICARAC)
      NNO=ZI(ICARAC)
      NPG=ZI(ICARAC+2)
C
      FF   ='&INEL.'//ELREFE//'.FF'
      CALL JEVETE(FF,'L',IFF)
      IPOIDS=IFF
      IVF   =IPOIDS+NPG
      IDFDE =IVF   +NPG*NNO
C
      CALL JEVECH ( 'PGEOMER', 'L', IGEOM )
      CALL JEVECH ( 'PMATERC', 'L', IMATE )
      CALL JEVECH ( 'PONDPLA', 'L', IONDE )
      CALL JEVECH ( 'PTEMPSR', 'L', JINST )
      CALL JEVECH  ('PVECTUR', 'E', IVECTU)
C
      DO 20 I = 1 , 2*NNO
         ZR(IVECTU+I-1) = 0.0D0
 20   CONTINUE
C
C     --- INITIALISATION DE SIGMA
C
      DO 21 I = 1,2
         DO 22 J = 1,2
            SIGMA(I,J) = 0.D0
22       CONTINUE
21    CONTINUE
C
      MATER=ZI(IMATE)
      NOMRES(1)='E'
      NOMRES(2)='NU'
      NOMRES(3)='RHO'
      CALL RCVALA(MATER,'ELAS',0,' ',R8B,3,NOMRES,VALRES,CODRET,'FM')
      E = VALRES(1)
      IF (E.LT.1.D-1) GOTO 200
      NU = VALRES(2)
      RHO = VALRES(3)

      LAMBDA = E*NU/(1.D0+NU)/(1.D0-2.D0*NU)
      MU = E/2.D0/(1.D0+NU)

      CP = SQRT((LAMBDA+2.D0*MU)/RHO)
      CS = SQRT(MU/RHO)
C
C     --- CARACTERISTIQUES DE L'ONDE PLANE
C
      CALL FOINTE('FM',ZK24(IONDE),1,'X',1.D0,DIRX,IER)
      CALL FOINTE('FM',ZK24(IONDE+1),1,'X',1.D0,DIRY,IER)
      CALL FOINTE('FM',ZK24(IONDE+3),1,'X',1.D0,TYPER,IER)
      IF (TYPER.EQ.0.D0) TYPE = 'P'
      IF (TYPER.EQ.1.D0) TYPE = 'S'
      CALL FOINTE('FM',ZK24(IONDE+5),1,'X',1.D0,DIST,IER)
C
C     --- CALCUL DU VECTEUR DIRECTEUR UNITAIRE DE L'ONDE PLANE
C
      NORM = SQRT(DIRX**2+DIRY**2)
      DIRX = DIRX/NORM
      DIRY = DIRY/NORM

C     COORDONNEES DES POINTS DE GAUSS SUR L'ELEMENT REEL

      DO 295 I = 1,NPG
         XGG(I) = 0.D0
         YGG(I) = 0.D0
295   CONTINUE

      DO 300 IPG = 1,NPG
         LDEC = (IPG-1)*NNO
         DO 305 I = 1,NNO
            II = 2*I-1
            XGG(IPG) = XGG(IPG) + ZR(IGEOM+II-1)*ZR(IVF+LDEC+I-1)
            YGG(IPG) = YGG(IPG) + ZR(IGEOM+II  )*ZR(IVF+LDEC+I-1)
 305      CONTINUE
300   CONTINUE

C     CALCUL DU REPERE ASSOCIE A L'ONDE
      NORX = -DIRY
      NORY = DIRX

      IF (TYPE.EQ.'P') THEN
         CELE = CP
      ELSE
         CELE = CS
      ENDIF
C
C    BOUCLE SUR LES POINTS DE GAUSS
C
      DO 101 KP=1,NPG
        K = (KP-1)*NNO

C
C        --- CALCUL DU CHARGEMENT PAR ONDE PLANE
C
         PARAM = DIRX*XGG(KP)+ DIRY*YGG(KP)
         PARAM = PARAM - CELE*ZR(JINST)+DIST
         IF (PARAM.LT.0.D0) THEN
            VALFON = 0.D0
         ELSE
            CALL FOINTE('FM',ZK24(IONDE+4),1,'X',PARAM,VALFON,IER)
         ENDIF

C        CALCUL DES CONTRAINTES ASSOCIEES A L'ONDE PLANE

C        CALCUL DU GRADIENT DU DEPLACEMENT
         IF (TYPE.EQ.'P') THEN
            GRAD(1,1) = DIRX*VALFON*DIRX
            GRAD(1,2) = DIRY*VALFON*DIRX

            GRAD(2,1) = DIRX*VALFON*DIRY
            GRAD(2,2) = DIRY*VALFON*DIRY
         ENDIF
         IF (TYPE.EQ.'S') THEN
            GRAD(1,1) = DIRX*VALFON*NORX
            GRAD(1,2) = DIRY*VALFON*NORX

            GRAD(2,1) = DIRX*VALFON*NORY
            GRAD(2,2) = DIRY*VALFON*NORY
         ENDIF

C        CALCUL DES DEFORMATIONS
         DO 201 INDIC1 = 1,2
            DO 202 INDIC2 = 1,2
               EPSI(INDIC1,INDIC2) = 5.D-1*(GRAD(INDIC1,INDIC2)
     &                                   + GRAD(INDIC2,INDIC1))
202         CONTINUE
201      CONTINUE

C        CALCUL DES CONTRAINTES
         TRACE = 0.D0
         DO 203 INDIC1 = 1,2
            TRACE = TRACE + EPSI(INDIC1,INDIC1)
203      CONTINUE
         DO 204 INDIC1 = 1,2
            DO 205 INDIC2 = 1,2
               IF (INDIC1.EQ.INDIC2) THEN
                  SIGMA(INDIC1,INDIC2) = LAMBDA*TRACE
     &                 +2*MU*EPSI(INDIC1,INDIC2)
               ELSE
                  SIGMA(INDIC1,INDIC2) = 2*MU
     &                 *EPSI(INDIC1,INDIC2)
               ENDIF
205         CONTINUE
204      CONTINUE

         CALL VFF2DN (NNO,ZR(IPOIDS+KP-1),ZR(IDFDE+K),ZR(IGEOM),NX,NY,
     &               POIDS)
C
         JAC = SQRT (NX*NX + NY*NY)
C
C        --- CALCUL DE LA NORMALE UNITAIRE ---
C
          NUX = NX / JAC
          NUY = NY / JAC
C
C        --- TEST DU SENS DE LA NORMALE PAR RAPPORT A LA DIRECTION
C            DE L'ONDE
C
          SCAL = NUX*DIRX + NUY*DIRY
          IF (SCAL.GT.0.D0) THEN
             COEDIR = 1.D0
          ELSE
             COEDIR = -1.D0
          ENDIF
C
C        --- CALCUL DE V.N ---
C
          VONDT(1) = 0.D0
          VONDT(2) = 0.D0

          IF (TYPE.EQ.'P') THEN
             VONDT(1) = -CELE*VALFON*DIRX
             VONDT(2) = -CELE*VALFON*DIRY
          ENDIF
          IF (TYPE.EQ.'S') THEN
             VONDT(1) = -CELE*VALFON*NORX
             VONDT(2) = -CELE*VALFON*NORY
          ENDIF

          SCAL  = NUX*VONDT(1) + NUY*VONDT(2)
C
C        --- CALCUL DE LA VITESSE NORMALE ET DE LA VITESSE TANGENCIELLE
C
          VONDN(1) = NUX*SCAL
          VONDN(2) = NUY*SCAL

          VONDT(1) = VONDT(1) - VONDN(1)
          VONDT(2) = VONDT(2) - VONDN(2)
C
C        --- CALCUL DU VECTEUR CONTRAINTE
C
          TAUX = - RHO*(CP*VONDN(1) + CS*VONDT(1))
          TAUY = - RHO*(CP*VONDN(2) + CS*VONDT(2))
C
C        --- CALCUL DU VECTEUR CONTRAINTE DU A UNE ONDE PLANE
C
          TAONDX = SIGMA(1,1)*NUX
          TAONDX = TAONDX + SIGMA(1,2)*NUY

          TAONDY = SIGMA(2,1)*NUX
          TAONDY = TAONDY + SIGMA(2,2)*NUY
C
C        --- CALCUL DU VECTEUR ELEMENTAIRE
C
          DO 130 I = 1,NNO
             II = 2*I-1
             ZR(IVECTU+II-1) = ZR(IVECTU+II-1) +
     &     (TAUX+COEDIR*TAONDX)*ZR(IVF+K+I-1)*POIDS*JAC
             ZR(IVECTU+II+1-1) = ZR(IVECTU+II+1-1) +
     &     (TAUY+COEDIR*TAONDY)*ZR(IVF+K+I-1)*POIDS*JAC
130       CONTINUE

101   CONTINUE

200   CONTINUE

      END
