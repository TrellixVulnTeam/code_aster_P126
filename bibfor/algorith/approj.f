      SUBROUTINE APPROJ(SDAPPA,POSNOM,DIRAPP,DIR   ,ITEMAX,
     &                  EPSMAX,TOLEOU,COORPT,POSMAM,IPROJM,
     &                  KSI1M ,KSI2M ,TAU1M ,TAU2M ,DISTM ,
     &                  VECPMM)
C     
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 09/05/2012   AUTEUR DESOZA T.DESOZA 
C ======================================================================
C COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
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
      IMPLICIT     NONE
      CHARACTER*19 SDAPPA
      INTEGER      POSNOM
      INTEGER      ITEMAX
      LOGICAL      DIRAPP
      REAL*8       EPSMAX,TOLEOU      
      REAL*8       DIR(3),COORPT(3)
      REAL*8       TAU1M(3),TAU2M(3),VECPMM(3)
      REAL*8       KSI1M,KSI2M,DISTM
      INTEGER      IPROJM,POSMAM   
C
C ----------------------------------------------------------------------
C
C ROUTINE APPARIEMENT (ALGO)
C
C PROJECTION DU POINT SUR LES MAILLES 
C
C ----------------------------------------------------------------------
C
C
C IN  SDAPPA : NOM DE LA SD APPARIEMENT
C IN  POSNOM : POSITION DU NOEUD MAITRE LE PLUS PROCHE
C IN  ITEMAX : NOMBRE MAXI D'ITERATIONS DE NEWTON POUR LA PROJECTION
C IN  EPSMAX : RESIDU POUR CONVERGENCE DE NEWTON POUR LA PROJECTION
C IN  TOLEOU : TOLERANCE POUR PROJECTION HORE MAILLE
C IN  DIRAPP : VAUT .TRUE. SI APPARIEMENT DANS UNE DIRECTION DE
C              RECHERCHE DONNEE (PAR DIR)
C IN  DIR    : DIRECTION DE RECHERCHE
C IN  COORPT : COORDONNEES DU POINT A PROJETER SUR LA MAILLE
C OUT POSMAM : POSITION DE LA MAILLE MAITRE APPARIEE
C OUT IPROJM : VAUT 0 SI POINT PROJETE DANS LA MAILLE
C                   1 SI POINT PROJETE DANS LA ZONE DEFINIE PAR TOLEOU
C                   2 SI POINT PROJETE EN DEHORS (EXCLUS)
C OUT KSI1M  : COORD. PARAMETRIQUE DE LA PROJECTION
C OUT KSI2M  : COORD. PARAMETRIQUE DE LA PROJECTION
C OUT TAU1M  : VALEUR DE LA PREMIERE TANGENTE AU POINT PROJETE
C OUT TAU2M  : VALEUR DE LA SECONDE TANGENTE AU POINT PROJETE
C OUT VECPMM : VECTEUR POINT DE CONTACT -> SON PROJETE SUR MAILLE
C OUT DISTM  : DISTANCE POINT - PROJECTION (NORME DE VECPMM)
C
C -------------- DEBUT DECLARATIONS NORMALISEES JEVEUX -----------------
C
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
C ---------------- FIN DECLARATIONS NORMALISEES JEVEUX -----------------
C
      CHARACTER*8  ALIASM,NOMMAL
      INTEGER      NDIM,NIVERR,NNOSDM,NMANOM
      REAL*8       COORMM(27),VECPML(3)
      REAL*8       TAU1L(3),TAU2L(3)      
      REAL*8       KSI1L,KSI2L,DISTL
      REAL*8       R8GAEM
      INTEGER      IPROJL,IMAM,POSMAL,NUMMAL
      INTEGER      JDECIV
      LOGICAL      LPOINT         
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- INITIALISATIONS
C
      DISTM     = R8GAEM()
      KSI1M     = R8GAEM()
      KSI2M     = R8GAEM()
      TAU1M(1)  = 0.D0
      TAU1M(2)  = 0.D0
      TAU1M(3)  = 0.D0
      TAU2M(1)  = 0.D0
      TAU2M(2)  = 0.D0
      TAU2M(3)  = 0.D0
      VECPMM(1) = 0.D0
      VECPMM(2) = 0.D0
      VECPMM(3) = 0.D0      
      POSMAM    = 0
      NMANOM    = 0
      IPROJM    = -1
C
C --- POINT EXCLU PAR SANS_*
C           
      CALL ASSERT(POSNOM.NE.0)
C
C --- NOMBRE DE MAILLES ATTACHEES AU NOEUD MAITRE LE PLUS PROCHE
C   
      CALL APNINV(SDAPPA,POSNOM,'NMANOM',NMANOM)
C
C --- DECALAGE POUR CONNECTIVITE INVERSE
C
      CALL APNINV(SDAPPA,POSNOM,'JDECIV',JDECIV)
C
C --- BOUCLE SUR LES MAILLES MAITRES 
C
      DO 10 IMAM = 1,NMANOM
C
C ----- POSITION DE LA MAILLE ATTACHEE
C
        CALL APATTA(SDAPPA,JDECIV,IMAM  ,POSMAL)
C
C ----- NUMERO ABSOLU DE LA MAILLE ATTACHEE
C
        CALL APNUMM(SDAPPA,POSMAL,NUMMAL)  
C
C ----- NOMBRE DE NOEUDS DE LA MAILLE
C
        CALL APNNDM(SDAPPA,POSMAL,NNOSDM)
C
C ----- CARACTERISTIQUES DE LA MAILLE MAITRE
C
        CALL APTYPM(SDAPPA,NUMMAL,NDIM  ,NNOSDM,ALIASM,
     &              NOMMAL)
C
C ----- CORDONNNEES DE LA MAILLE MAITRE
C
        CALL APCOMA(SDAPPA,NUMMAL,COORMM)
C
C ----- MAILLE MAITRE DE TYPE POI1 INTERDITE
C
        LPOINT = ALIASM.EQ.'PO1'       
        IF (LPOINT) THEN
          CALL U2MESK('F','APPARIEMENT_36',1,NOMMAL)    
        ENDIF          
C
C ----- CALCUL DE LA PROJECTION DU POINT SUR LA MAILLE MAITRE
C
        CALL MMPROJ(ALIASM,NNOSDM,NDIM  ,COORMM,COORPT,
     &              ITEMAX,EPSMAX,TOLEOU,DIRAPP,DIR   ,
     &              KSI1L ,KSI2L ,TAU1L ,TAU2L ,IPROJL,
     &              NIVERR)
C  
C ----- GESTION DES ERREURS LORS DU NEWTON LOCAL POUR LA PROJECTION
C   
        IF (NIVERR.EQ.1) THEN   
          CALL U2MESG('F','APPARIEMENT_13',1,NOMMAL,0,0,3,COORPT) 
        ENDIF      
C
C ----- CALCUL DE LA DISTANCE
C
        CALL APDIST(ALIASM,COORMM,NNOSDM,KSI1L ,KSI2L ,
     &              COORPT,DISTL ,VECPML)
C
C ----- CHOIX DE L'APPARIEMENT SUIVANT LE RESULTAT DE LA PROJECTION
C
        CALL APCHOI(DISTL ,DISTM ,POSMAL,POSMAM,TAU1L ,
     &              TAU1M ,TAU2L ,TAU2M ,KSI1L ,KSI1M ,
     &              KSI2L ,KSI2M ,IPROJL,IPROJM,VECPML,
     &              VECPMM)
C            
   10 CONTINUE
C
      CALL JEDEMA()
C 
      END
