      SUBROUTINE TE0544 ( OPTION , NOMTE )
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 26/06/2002   AUTEUR SMICHEL S.MICHEL-PONNELLE 
C ======================================================================
C COPYRIGHT (C) 1991 - 2002  EDF R&D                  WWW.CODE-ASTER.ORG
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
C
      IMPLICIT NONE
      CHARACTER*16        OPTION , NOMTE
C ......................................................................
C    - FONCTION REALISEE:  CALCUL DES COEFFICIENTS A0 ET A1
C                          POUR LE PILOTAGE PAR CRITERE ELASTIQUE
C                          POUR LES ELEMENTS A VARIABLES DELOCALISEES
C    - ARGUMENTS:
C        DONNEES:      OPTION       -->  OPTION DE CALCUL
C                      NOMTE        -->  NOM DU TYPE ELEMENT
C ......................................................................
C
      CHARACTER*8  TYPMOD(2),ELREFE, ELREF2
      CHARACTER*16 COMPOR
      CHARACTER*24 CARAC,FF,TRAV
C
      INTEGER      NDIM, NNO, NPG1,I,IMATUU,ITRAV,LGPG, JTAB(7)
      INTEGER      ICARAC,IFF,IPOIDS,IVF,IDFDE,IDFDN,IDFDK,IGEOM,IMATE
      INTEGER      ICONTM,IVARIM, ICOPIL, IBORNE, IBID,ICTAU
      INTEGER      IDEPLM, IDDEPL, IDEPL0, IDEPL1, ICOMPO, ITYPE
      REAL*8       DFDI(2187),ELGEOM(10,27)
C
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
      CHARACTER*8        ZK8
      CHARACTER*16                ZK16
      CHARACTER*24                          ZK24
      CHARACTER*32                                    ZK32
      CHARACTER*80                                              ZK80
      COMMON  / KVARJE / ZK8(1) , ZK16(1) , ZK24(1) , ZK32(1) , ZK80(1)
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------


C - TYPE DE MODELISATION
      TYPMOD(2)='GRADEPSI'

      IF      ( NOMTE(1:5) .EQ. 'MECA_' ) THEN
        TYPMOD (1) = '3D'
      ELSE IF ( NOMTE(3:4) .EQ. 'AX' ) THEN
         TYPMOD(1) = 'AXIS'
      ELSE IF ( NOMTE(1:5) .EQ. 'MGCA_' ) THEN
         TYPMOD(1) = '3D'
      ELSE IF ( NOMTE(3:4) .EQ. 'CP' ) THEN
         TYPMOD(1) = 'C_PLAN'
      ELSE IF ( NOMTE(3:4) .EQ. 'DP' ) THEN
         TYPMOD(1) = 'D_PLAN'
      ELSE
         CALL UTMESS('F','TE0544','NOM D''ELEMENT ILLICITE')
      ENDIF

      CALL ELREF1(ELREFE)
      IF ( ELREFE.EQ.'TETRI10 ') THEN
        ELREF2 = 'TETRI4  '
      ELSEIF ( ELREFE.EQ.'HEXI20  ') THEN
        ELREF2 = 'HEXI8   '
      ELSEIF ( ELREFE.EQ.'TRII6   ') THEN
        ELREF2 = 'TRII3   '
      ELSEIF ( ELREFE.EQ.'QUAI8   ') THEN
        ELREF2 = 'QUAI4   '
      ELSE 
        CALL UTMESS('F','TE0544','ELEMENT ILLICITE')
      ENDIF      
C - FONCTIONS DE FORMES ET POINTS DE GAUSS
C - ON LES VEUT POUR LES DEFO GENERALISEES (D'OU LES ALIAS)

      IF (TYPMOD(1).EQ.'3D') THEN
        CARAC = '&INEL.'//ELREF2//'.CARACTE'
        CALL JEVETE(CARAC,'L',ICARAC)
        NDIM = 3
        NNO  = ZI(ICARAC+1)
        NPG1 = ZI(ICARAC+3)
        FF = '&INEL.'//ELREF2//'.FFORMES'
        CALL JEVETE(FF,'L',IFF)
        IPOIDS = IFF + (NDIM+1)*NNO*NNO
        IVF = IPOIDS + NPG1
        IDFDE = IVF + NPG1*NNO
        IDFDN = IDFDE + 1
        IDFDK = IDFDN + 1
      ELSE
        CARAC='&INEL.'//ELREF2//'.CARAC'
        CALL JEVETE(CARAC,'L',ICARAC)
        NDIM = 2
        NNO = ZI(ICARAC)
        NPG1 = ZI(ICARAC+2)
        FF   ='&INEL.'//ELREF2//'.FF'
        CALL JEVETE(FF,'L',IFF)
        IPOIDS=IFF
        IVF   =IPOIDS+NPG1
        IDFDE =IVF   +NPG1*NNO
        IDFDK =IDFDE +NPG1*NNO
        IDFDN = IDFDK
      END IF

      IF (NNO .GT.27) CALL UTMESS('F','TE0544','DFDI MAL DIMENSIONNEE')
      IF (NPG1.GT.27) CALL UTMESS('F','TE0544','DFDI MAL DIMENSIONNEE')



C - PARAMETRES EN ENTREE

      CALL JEVECH('PGEOMER','L',IGEOM)
      CALL JEVECH('PMATERC','L',IMATE)
      CALL JEVECH('PCOMPOR','L',ICOMPO)
      CALL JEVECH('PDEPLMR','L',IDEPLM)
      CALL JEVECH('PCONTMR','L',ICONTM)
      CALL JEVECH('PVARIMR','L',IVARIM)
      CALL JEVECH('PDDEPLR','L',IDDEPL)
      CALL JEVECH('PDEPL0R','L',IDEPL0)
      CALL JEVECH('PDEPL1R','L',IDEPL1)
      CALL JEVECH('PTYPEPI','L',ITYPE)

      COMPOR=ZK16(ICOMPO)
      CALL JEVECH('PCDTAU','L',ICTAU)
      CALL JEVECH('PBORNPI','L',IBORNE)


C -- NOMBRE DE VARIABLES INTERNES

      CALL TECACH(.TRUE.,.TRUE.,'PVARIMR',7,JTAB)
      LGPG = MAX(JTAB(6),1)*JTAB(7)

C - CALCUL DES ELEMENTS GEOMETRIQUES SPECIFIQUES LOIS DE COMPORTEMENT

      IF (COMPOR.EQ.'BETON_DOUBLE_DP') THEN
        CALL LCEGEO(NNO,NPG1,ZR(IPOIDS),ZR(IVF),ZR(IDFDE),ZR(IDFDN),
     &            ZR(IDFDK),ZR(IGEOM),TYPMOD,OPTION,
     &            ZI(IMATE), ZK16(ICOMPO),LGPG,ELGEOM)
      END IF

C PARAMETRES EN SORTIE

      CALL JEVECH('PCOPILO','E',ICOPIL)


      CALL PIPEPE(ZK16(ITYPE), NDIM, NNO, NPG1, ZR(IPOIDS), ZR(IVF),
     &            ZR(IDFDE), ZR(IDFDN), ZR(IDFDK), ZR(IGEOM),
     &            TYPMOD, ZI(IMATE), ZK16(ICOMPO), LGPG,
     &            ZR(IDEPLM), ZR(ICONTM), ZR(IVARIM),
     &            ZR(IDDEPL),ZR(IDEPL0),ZR(IDEPL1),ZR(ICOPIL),
     &            DFDI,ELGEOM,IBORNE,ICTAU)

      END
