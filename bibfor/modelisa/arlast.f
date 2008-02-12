      SUBROUTINE ARLAST(MAIL  ,NOMARL,TYPMAI,QUADRA,NOMC  ,
     &                  NOM1  ,NOM2  ,CINE1 ,CINE2 ,NORM  ,
     &                  TANG  ,LCARA ,NDIM  ,
     &                  MARLEL,MODARL,TABCPL)
C     
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 12/02/2008   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2008  EDF R&D                  WWW.CODE-ASTER.ORG
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
C TOLE CRP_20
C
      IMPLICIT NONE
      CHARACTER*16 TYPMAI
      CHARACTER*8  MAIL
      CHARACTER*8  NOMARL      
      CHARACTER*10 NOM1,NOM2,NOMC
      CHARACTER*10 NORM,TANG     
      CHARACTER*8  CINE1,CINE2      
      REAL*8       LCARA   
      CHARACTER*10 QUADRA
      INTEGER      NDIM      
      CHARACTER*8  MARLEL,MODARL   
      CHARACTER*24 TABCPL
C      
C ----------------------------------------------------------------------
C
C ROUTINE ARLEQUIN
C
C ASSEMBLAGE DANS LES MATRICES ARLEQUIN MORSES
C
C ----------------------------------------------------------------------
C
C
C IN  MAIL   : NOM DU MAILLAGE
C IN  NOMARL : NOM DE LA SD PRINCIPALE ARLEQUIN
C IN  NOM1   : NOM DE LA SD DE STOCKAGE PREMIER GROUPE 
C IN  NOM2   : NOM DE LA SD DE STOCKAGE SECOND GROUPE
C IN  NORM   : NOM DE LA SD POUR STOCKAGE DES NORMALES
C IN  TANG   : NOM DE L'OBJET TANGENTES LISSEES
C IN  TYPMAI : SD CONTENANT NOM DES TYPES ELEMENTS (&&CATA.NOMTM)
C IN  LCARA  : LONGUEUR CARACTERISTIQUE POUR TERME DE COUPLAGE (PONDERA
C              TION DES TERMES DE COUPLAGE)
C IN  NOMC   : NOM DE LA SD POUR LES MAILLES DE COLLAGE
C IN  QUADRA : SD DES QUADRATURES A CALCULER
C IN  CINE1  : CINEMATIQUE DU PREMIER GROUPE
C IN  CINE2  : CINEMATIQUE DU SECOND GROUPE
C IN  NDIM   : NDIMNSION DE L'ESPACE GLOBAL (2 OU 3)
C
C
C SD DE SORTIE
C NOM*.MORSE.VALE : VECTEUR DE VALEUR DE LA MATRICE ARLEQUIN MORSE
C
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
C
      CHARACTER*32       JEXNUM,JEXATR
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
C      
C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------
C
      INTEGER       NNM
      PARAMETER     (NNM = 27)
C      
      CHARACTER*24  NOMCOL
      CHARACTER*16  NOMMO1,NOMMO2
      CHARACTER*8   K8BID,NOMMA1,NOMMA2
      INTEGER       NMA
      INTEGER       JCOLM,JNORM,JTANG
      INTEGER       IMA1,IMA2,NUMMA1,NUMMA2
      INTEGER       NC,NN1,NN2
      INTEGER       IAS
      INTEGER       IMA
      INTEGER       IJ1(NNM*NNM),IJ2(NNM*NNM)
      REAL*8        NO1(3*NNM),NO2(3*NNM) 
      INTEGER       JCOOR,JCONX,JCUMU
      INTEGER       IRET
      INTEGER       JCINO
      INTEGER       JMINO1,JMCUM1,JMVAL1
      INTEGER       JMINO2,JMCUM2,JMVAL2        
      INTEGER       JQMAMA
      INTEGER       IFM,NIV
      INTEGER       ICPL,IALIEL,ILLIEL,IAUX1
      CHARACTER*19  LIGRMO,ARLMT1,ARLMT2
      INTEGER       IGREL,IEL,JTABCP,IMATU1,IMATU2
      INTEGER       NBGREL,NBELEM,NBELGR,IDEB,NNOMAX
      REAL*8        R8BID
C      
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFDBG('ARLEQUIN',IFM,NIV) 
C
      IF (NDIM.EQ.2) THEN
        NNOMAX = 8
      ELSEIF (NDIM.EQ.3) THEN
        NNOMAX = 27
      ENDIF
C
C --- INITIALISATION COLLAGE
C      
      NOMCOL = NOMC(1:10)//'.MAILLE'
      CALL JEVEUO(NOMCOL(1:24),'E',JCOLM)
      CALL JELIRA(NOMCOL(1:24),'LONMAX',NMA,K8BID)
      DO 10 IMA = 1, NMA
        ZL(JCOLM-1+IMA) = .FALSE.
 10   CONTINUE
C
C --- NUMERO D'ASSEMBLAGE
C
      IAS = 0
      IF (CINE1.EQ.'COQUE   ') IAS = IOR(IAS,1)
      IF (CINE2.EQ.'COQUE   ') IAS = IOR(IAS,2)
C
C --- LECTURE DONNEES MAILLAGE
C
      CALL JEVEUO(MAIL(1:8)//'.COORDO    .VALE','L',JCOOR)
      CALL JEVEUO(MAIL(1:8)//'.CONNEX','L',JCONX)
      CALL JEVEUO(JEXATR(MAIL(1:8)//'.CONNEX','LONCUM'),'L',JCUMU)
C
C --- LECTURE DONNEES NORMALES ET TANGENTES
C  
      IF (IAS.NE.0) THEN
        CALL JEVEUO(NORM,'L',JNORM)
        CALL JEVEUO(TANG,'L',JTANG)
      ELSE
        JNORM = JCOOR
      ENDIF                 
C
C --- LECTURE DONNEES QUADRATURES
C 
      CALL JEVEUO(QUADRA(1:10)//'.MAMA'  ,'L',JQMAMA)
C
C --- LECTURE DONNEES ZONE COLLAGE
C 
      CALL JEVEUO(NOMC(1:10)//'.INO','L',JCINO)
      CALL JELIRA(NOMC(1:10)//'.INO','LONMAX',NC,K8BID)
C
C --- LECTURE DONNEES MATRICES MORSES
C
      NOMMO1 = NOM1(1:10)//'.MORSE'
      CALL JEVEUO(NOMMO1(1:16)//'.INO','L',JMINO1)
      CALL JEVEUO(JEXATR(NOMMO1(1:16)//'.INO','LONCUM'),'L',JMCUM1)  
      CALL JEVEUO(NOMMO1(1:16)//'.VALE','E',JMVAL1)
C
      NOMMO2 = NOM2(1:10)//'.MORSE'
      CALL JEVEUO(NOMMO2(1:16)//'.INO','L',JMINO2)
      CALL JEVEUO(JEXATR(NOMMO2(1:16)//'.INO','LONCUM'),'L',JMCUM2)
      CALL JEVEUO(NOMMO2(1:16)//'.VALE','E',JMVAL2)     
C
C --- ACCES AU LIGREL
C
      LIGRMO = MODARL(1:8)//'.MODELE'       
      CALL JEVEUO(LIGRMO//'.LIEL','L',IALIEL)
      CALL JEVEUO(JEXATR(LIGRMO//'.LIEL','LONCUM'),'L',ILLIEL)
      CALL JEVEUO(TABCPL,'L',JTABCP)     
C
C --- BOUCLE SUR LE GREL
C
      DO 210 IGREL = 1,NBGREL(LIGRMO)
        NBELGR = NBELEM(LIGRMO,IGREL)
        IAUX1  = IALIEL-1+ZI(ILLIEL-1+IGREL)-1
C
C ----- BOUCLE SUR LES ELEMENTS
C
        DO 220 IEL = 1,NBELGR
          IMA  = ZI(IAUX1+IEL)
C
C ------- ACCES AU COUPLE DES MAILLES
C
          ICPL = ZI(JTABCP-1+IMA)
          IMA1 = ZI(JQMAMA + 2*(ICPL-1))
          IMA2 = ZI(JQMAMA + 2*(ICPL-1)+1)

          CALL ARLGRC(MAIL     ,TYPMAI   ,NOM1     ,NDIM  ,IMA1 ,
     &                ZI(JCONX),ZI(JCUMU),ZR(JCOOR),ZR(JNORM),
     &                NUMMA1   ,NOMMA1   ,K8BID    ,R8BID    ,
     &                NN1      ,NO1)                    
C
          CALL ARLGRC(MAIL     ,TYPMAI   ,NOM2     ,NDIM  ,IMA2 ,
     &                ZI(JCONX),ZI(JCUMU),ZR(JCOOR),ZR(JNORM),
     &                NUMMA2   ,NOMMA2   ,K8BID    ,R8BID    ,
     &                NN2      ,NO2)                    
C
C ------- POUR LES COEFS DE PONDERATION
C
          ZL(JCOLM+NUMMA1-1) = .TRUE.
          ZL(JCOLM+NUMMA2-1) = .TRUE.
C
C ------- CALCUL DES POINTEURS VERS LA MATRICE MORSE
C
          CALL ARLAS0(NUMMA1   ,NUMMA1  ,ZI(JCONX) ,ZI(JCUMU),
     &                ZI(JCINO),NC    ,ZI(JMINO1) ,ZI(JMCUM1),
     &                IJ1)
          CALL ARLAS0(NUMMA1  ,NUMMA2  ,ZI(JCONX) ,ZI(JCUMU),
     &                ZI(JCINO),NC    ,ZI(JMINO2) ,ZI(JMCUM2),
     &                IJ2)
C
C ------- ACCES AUX MATRICES DE COUPLAGE ELEMENTAIRES 
C
          IDEB = (IEL-1)*NNOMAX*NDIM*NNOMAX*NDIM
          ARLMT1 = MARLEL(1:8)//'.ARLMT1'          
          CALL JEVEUO(JEXNUM(ARLMT1(1:19)//'.RESL',IGREL),'L',IMATU1)
          ARLMT2 = MARLEL(1:8)//'.ARLMT2'
          CALL JEVEUO(JEXNUM(ARLMT2(1:19)//'.RESL',IGREL),'L',IMATU2)
C
C ------- AJOUTER A LA MATRICE DE MORSE
C
          CALL ARLAS9(NDIM,NN1,NN1,IJ1,IDEB,IMATU1,ZR(JMVAL1)) 
          CALL ARLAS9(NDIM,NN1,NN2,IJ2,IDEB,IMATU2,ZR(JMVAL2))          
  220   CONTINUE           
  210 CONTINUE            
C
      IRET = 0
C
      IF (IRET.NE.0) THEN
        WRITE(6,*) '   <F> POUR LE COUPLE ',NUMMA1,NUMMA2
        CALL ASSERT(.FALSE.)
      ENDIF
C
C --- MENAGE
C
      CALL DETRSD(' ',MODARL)
      CALL DETRSD(' ',MARLEL)
      CALL DETRSD(' ',TABCPL)
      
      CALL JEDEMA()

      END
