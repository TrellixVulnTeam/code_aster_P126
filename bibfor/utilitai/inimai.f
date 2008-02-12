       SUBROUTINE INIMAI(MAIL  ,BASE  ,DIME  ,TITRZ ,NBNO  ,
     &                   NBMA  ,NBNOMA)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 12/02/2008   AUTEUR ABBAS M.ABBAS 
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
C
      IMPLICIT NONE
      CHARACTER*8   MAIL   
      CHARACTER*1   BASE
      INTEGER       DIME
      CHARACTER*(*) TITRZ      
      INTEGER       NBMA,NBNO,NBNOMA
C
C ----------------------------------------------------------------------
C
C UTILITAIRE - SD MAILLAGE
C PREPARE LES OBJETS DE BASE DE LA SD MAILLAGE
C
C ----------------------------------------------------------------------
C
C
C IN  MAIL   : NOM DU MAILLAGE 
C IN  BASE   : BASE DE CREATION 'G' OU 'V'
C IN  DIME   : DIMENSION DE L'ESPACE (2 OU 3)
C IN  TITRE  : TITRE DU MAILLAGE
C IN  NBNO   : NOMBRE DE NOEUDS DU MAILLAGE
C IN  NBMA   : NOMBRE DE MAILLES DU MAILLAGE
C IN  NBNOMA : LONGUEUR DU VECTEUR CONNECTIVITE DES MAILLES
C
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
C
      CHARACTER*32       JEXNOM
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
      CHARACTER*24 MAIDIM,MAITIT,ADAPMA,COOREF,COOVAL,COODSC
      INTEGER      JDIME ,JTITR ,JADAP ,JREFE ,JCOOR ,JCODS
      CHARACTER*24 TYPMAI
      INTEGER      JTYPM
      CHARACTER*24 NOMNOE,NOMMAI,CONNEX
      INTEGER      NTGEO 
      CHARACTER*80 TITRE           
C      
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- NOM DES OBJETS JEVEUX
C
      TITRE  = TITRZ
      MAIDIM = MAIL(1:8)//'.DIME'
      ADAPMA = MAIL(1:8)//'.ADAPTATION     '
      MAITIT = MAIL(1:8)//'           .TITR'        
      COOREF = MAIL(1:8)//'.COORDO    .REFE' 
      COOVAL = MAIL(1:8)//'.COORDO    .VALE'
      COODSC = MAIL(1:8)//'.COORDO    .DESC'              
      NOMNOE = MAIL(1:8)//'.NOMNOE         '                    
      NOMMAI = MAIL(1:8)//'.NOMMAI         '
      TYPMAI = MAIL(1:8)//'.TYPMAIL        '        
      CONNEX = MAIL(1:8)//'.CONNEX         '
C
C --- VERIFICATIONS
C
      IF ((DIME.LT.2).OR.(DIME.GT.3)) THEN
        CALL ASSERT(.FALSE.)
      ENDIF
C
      IF ((NBMA.LE.0).OR.(NBNO.LE.0).OR.(NBNOMA.LE.0)) THEN
        CALL ASSERT(.FALSE.)
      ENDIF     
C
C --- RECUPERATION DU NUMERO IDENTIFIANT LE TYPE DE CHAM_NO GEOMETRIE
C
      CALL JENONU(JEXNOM('&CATA.GD.NOMGD','GEOM_R'),NTGEO)       
C
C --- DIMENSIONS
C          
      CALL WKVECT(MAIDIM,BASE//' V I'  ,6,JDIME)
      ZI(JDIME - 1 + 1) = NBNO
      ZI(JDIME - 1 + 2) = 0
      ZI(JDIME - 1 + 3) = NBMA
      ZI(JDIME - 1 + 4) = 0
      ZI(JDIME - 1 + 5) = 0
      ZI(JDIME - 1 + 6) = DIME
C
C --- TITRE
C      
      CALL WKVECT(MAITIT,BASE//' V K80',1,JTITR)
      ZK80(JTITR) = TITRE
C
C --- INFORMATION SUR L'ADAPTATION DE MAILLAGE
C
      CALL WKVECT(ADAPMA,BASE//' V I',1,JADAP)
      ZI(JADAP)   =  0      
C
C --- CHAM_NO DES COORDONNEES DES NOEUDS
C
      CALL WKVECT(COOREF,BASE//' V K24',2,JREFE)
      ZK24(JREFE  ) = MAIL
      ZK24(JREFE+1) = ' '
C      
      CALL WKVECT(COOVAL,BASE//' V R',3*NBNO,JCOOR) 
C      
      CALL JECREO(COODSC,BASE//' V I')
      CALL JEECRA(COODSC,'LONMAX',3,' ')
      CALL JEECRA(COODSC,'DOCU',0,'CHNO')
      CALL JEVEUO(COODSC,'E',JCODS)
      ZI(JCODS)   =  NTGEO
      ZI(JCODS+1) = -3
      ZI(JCODS+2) = 14      
C
C --- NOMS DES NOEUDS
C
      CALL JECREO(NOMNOE,BASE//' N K8')
      CALL JEECRA(NOMNOE,'NOMMAX',NBNO,' ')    
C
C --- TYPE DES MAILLES
C
      CALL WKVECT(TYPMAI,BASE//' V I',NBMA,JTYPM)
C
C --- NOM DES MAILLES
C   
      CALL JECREO(NOMMAI,BASE//' N K8')
      CALL JEECRA(NOMMAI,'NOMMAX',NBMA,' ') 
C  
C --- CONNECTIVITES DES MAILLES
C       
      CALL JECREC(CONNEX,BASE//' V I','NU','CONTIG','VARIABLE',NBMA)
      CALL JEECRA(CONNEX,'LONT',NBNOMA,' ') 
C
      CALL JEDEMA()
C
      END
