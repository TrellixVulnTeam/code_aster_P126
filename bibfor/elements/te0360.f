      SUBROUTINE TE0360 ( OPTION , NOMTE )
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
C----------------------------------------------------------------------
C    - FONCTION REALISEE:  CALCUL DES OPTIONS CONTACT-FROTTEMENT
C                          ELEMENTS 3D
C    - ARGUMENTS:
C        DONNEES:      OPTION       -->  OPTION DE CALCUL
C                      NOMTE        -->  NOM DU TYPE ELEMENT
C----------------------------------------------------------------------
      IMPLICIT REAL*8 (A-H,O-Z)
      CHARACTER*16        OPTION , NOMTE
      CHARACTER*8        ELREFE,NOMRES(3),NOMPAR
      CHARACTER*2        CODRET(3)
      CHARACTER*16       PHEN
      CHARACTER*24       CARAC,FF
      INTEGER            NBRES,NBPAR ,ISIGT,ISIGN,IVARIM,IDEPLM,IDEPLP
      REAL*8             SG(36),SIGP(36),VFFAUX(16),VALPAR
      REAL*8             DFDL(3,16),POIDS,VALRES(3)
      REAL*8             NU(48),NOR(3),EN,MU,ET
      REAL*8             MTOT(48,48),VECTOT(48),MCOMPO(4,4),COEF
      INTEGER            NNO,KP,NPG1,IMATUU,IVECTU,NDDL
      INTEGER            ICARAC,IFF,IPOIDS,IVF,IDFDE,IGEOM,JCRET
      LOGICAL            SIGNO,ADHER
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX --------------------
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
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX --------------------
C
C---------- DECLARATION DES ELREFE -------------------------------------
C
      CALL ELREF1(ELREFE)
C
C----------------------------------------------------------------------
C
C --- FONCTIONS DE FORMES ET POINTS DE GAUSS
C
      CARAC = '&INEL.'//ELREFE//'.CARACON'
      CALL JEVETE(CARAC,'L',ICARAC)
      NDIM  = ZI(ICARAC)
      NNO   = ZI(ICARAC+1)
C     NBFPG = ZI(ICARAC+2)
      NPG1  = ZI(ICARAC+3)
      FF    = '&INEL.'//ELREFE//'.FORMESF'
      CALL JEVETE(FF,'L',IFF)
      IPOIDS = IFF + (NDIM+1)*NNO*NNO
      IVF    = IPOIDS + NPG1
      IDFDE  = IVF    + NPG1*NNO
C
C     PARAMETRES EN ENTREE
C
      CALL JEVECH('PGEOMER','L',IGEOM)
      CALL JEVECH('PMATERC','L',IMATE)
      CALL JEVECH('PVARIMR','L',IVARIM)
      CALL JEVECH('PDEPLMR','L',IDEPLM)
      CALL JEVECH('PDEPLPR','L',IDEPLP)
      CALL JEVECH('PCOMPOR','L',ICOMPO)
      IF ( ZK16(ICOMPO+3) .EQ. 'COMP_ELAS' ) THEN
         CALL UTMESS('F','TE0360','COMP_ELAS NON VALIDE')
      ENDIF
C
C     PARAMETRES EN SORTIE
C
      IF( OPTION(1:16) .EQ. 'RIGI_MECA_TANG'.OR.
     &    OPTION(1:9)  .EQ. 'FULL_MECA'         ) THEN
          CALL JEVECH('PMATUUR','E',IMATUU)
      ENDIF
      IF( OPTION(1:9) .EQ. 'RAPH_MECA'.OR.
     &    OPTION(1:9) .EQ. 'FULL_MECA'    ) THEN
        CALL JEVECH('PVECTUR','E',IVECTU)
        CALL JEVECH('PCONTPR','E',ICONTP)
        CALL JEVECH('PVARIPR','E',IVARIP)
      ENDIF
C
C     APPEL A COHELP
C
      CALL COHELP(IDUMMY)
C
C     RECUPERATION DU MATERIAU DE L ELEMENT DE CONTACT
C
      PHEN='CONTACT'
      NBPAR=0
      VALPAR=0.0D0
      NOMPAR=' '
      NBRES=3
      NOMRES(1) = 'COULOMB'
      NOMRES(2) = 'E_N'
      NOMRES(3) = 'E_T'
      CALL RCVALA ( ZI(IMATE),PHEN,NBPAR,NOMPAR,VALPAR,
     *                             NBRES,NOMRES,VALRES,CODRET,'FM')
      MU = VALRES(1)
      EN = VALRES(2)
      ET = VALRES(3)
C
      NDDL=NDIM*NNO
      DO 10 ILIG=1,NDDL
        VECTOT(ILIG)=0.0D0
        DO 10 ICOL=1,NDDL
          MTOT(ILIG,ICOL)=0.0D0
10    CONTINUE
C
      INDSI=NPG1*(NDIM+1)
      CALL R8COPY(INDSI,ZR(IVARIM),1,SG,1)
      DO 700 IDDL=1,NDDL
          NU(IDDL)=ZR(IDEPLM+IDDL-1)+ZR(IDEPLP+IDDL-1)
700   CONTINUE
C
      DO 101 KP=1,NPG1
        INA   = (KP-1)*NNO
        K     = NDIM*INA
        IDIFF = IVF+INA
        ISIGN = 1+(KP-1)*(NDIM+1)
        ISIGT = ISIGN+1
        ISG   = 2+(KP-1)*(NDIM+1)
C
        CALL CODFDM ( NNO,ZR(IDIFF),VFFAUX,ZR(IPOIDS+KP-1),
     &  ZR(IDFDE+K),DFDL,POIDS,NDIM )

        CALL COBLOC(NNO,DFDL,ZR(IGEOM),NU,NOR,NDIM)

        CALL COCOMP(POIDS,VFFAUX,NOR,ZR(IGEOM),NU,NNO,NDDL,
     &  ZR(IDEPLP),SG(ISG),EN,ET,MU,SIGP(ISIGT),
     &  SIGP(ISIGN),ADHER,COEF,MCOMPO,DFDL,SIGNO,NDIM)

        SG(ISG-1)=SIGP(ISIGN)
          IF( OPTION(1:16) .EQ. 'RIGI_MECA_TANG' .OR.
     &        OPTION(1:9)  .EQ. 'FULL_MECA') THEN
              CALL COCMAT(NOR,VFFAUX,NNO,NDDL,MCOMPO,MTOT,COEF,NDIM)
          ENDIF
          IF( OPTION(1:9) .EQ. 'RAPH_MECA' .OR.
     &        OPTION(1:9) .EQ. 'FULL_MECA' ) THEN
              CALL COCVEC(NOR,VFFAUX,NNO,NDDL,SIGP(ISIGN),
     &                                    SIGP(ISIGT),VECTOT,COEF,NDIM)
         ENDIF
C
101   CONTINUE
C
      IF( OPTION(1:16) .EQ. 'RIGI_MECA_TANG' .OR.
     &    OPTION(1: 9) .EQ. 'FULL_MECA'          ) THEN
C
C      STOCKAGE DE LA MATRICE TANGENTE SOUS FORME SYMETRIQUE
C
       IGEN=0
       DO 20 I=1,NDDL
          DO 20 J=1,I
             IGEN=IGEN+1
             ZR(IMATUU+IGEN-1)=MTOT(I,J)
20     CONTINUE
      ENDIF
C
      IF( OPTION(1:9) .EQ. 'RAPH_MECA' .OR.
     &    OPTION(1:9) .EQ. 'FULL_MECA'     ) THEN
          CALL R8COPY(NDDL ,VECTOT,1,ZR(IVECTU),1)
          CALL R8COPY(INDSI,SG    ,1,ZR(IVARIP),1)
          CALL R8COPY(INDSI,SIGP  ,1,ZR(ICONTP),1)
C
          CALL JEVECH ( 'PCODRET', 'E', JCRET )
          ZI(JCRET) = 0
      ENDIF
C
      END
