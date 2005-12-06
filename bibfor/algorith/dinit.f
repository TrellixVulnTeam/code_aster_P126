      SUBROUTINE DINIT (NEQ,V0VIT,V0ACC,A0VIT,A0ACC,ALPHA,DELTA,INSTAM,
     &                 INSTAP,COEVIT,COEACC,DEPPLU,POUGD,DEPENT,VITENT,
     &                 ACCENT,MULTIA,NBMODS,NBPASE,INPSCO,THETA,
     &                 IALGO,CMD,DEFICO,DECOL,VITMOI,ACCMOI,DEPDEL)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 12/04/2005   AUTEUR PBADEL P.BADEL 
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
C RESPONSABLE PBADEL P.BADEL
C TOLE CRP_21
      IMPLICIT     NONE
      LOGICAL      DECOL      
      INTEGER      NEQ, NBMODS, IFORM, IALGO
      INTEGER      NBPASE
      REAL*8       V0VIT,  V0ACC,  A0VIT, ALPHA, DELTA, INSTAM, INSTAP
      REAL*8       COEVIT, COEACC, A0ACC, THETA
      CHARACTER*13 INPSCO
      CHARACTER*16 CMD
      CHARACTER*24 DEPPLU, DEPENT, VITENT, ACCENT,VITMOI,ACCMOI,DEPDEL
      CHARACTER*24 MULTIA(8), POUGD(8),DEFICO
C ----------------------------------------------------------------------
C -- INITIALISATIONS EN DYNAMIQUE
C ----------------------------------------------------------------------
C       IN  NEQ    : NOMBRE D'EQUATIONS
C       IN  V0VIT  : PARAMETRE METHODE INTEGRATION 
C       IN  V0ACC  : PARAMETRE METHODE INTEGRATION 
C       IN  A0VIT  : PARAMETRE METHODE INTEGRATION 
C       IN  A0ACC  : PARAMETRE METHODE INTEGRATION 
C       IN  ALPHA  : PARAMETRE METHODE INTEGRATION 
C       IN  DELTA  : PARAMETRE METHODE INTEGRATION 
C       IN  INSTAM : TEMPS INSTANT MOINS
C       IN  INSTAP : TEMPS INSTANT PLUS
C       IN  COEVIT : PARAMETRE INTEGRATION (METHODE + PAS DE TEMPS)
C       IN  COEACC : PARAMETRE INTEGRATION (METHODE + PAS DE TEMPS)
C IN/JXOUT  DEPPLU : DEPLACEMENT INSTANT PLUS
C IN/JXOUT  POUGD  : CHAPEAU POUTRE GRANDES ROTATIONS
C IN/JXOUT  DEPENT : CHAMP MULTIAPPUI
C IN/JXOUT  VITENT : CHAMP MULTIAPPUI
C IN/JXOUT  ACCENT : CHAMP MULTIAPPUI
C IN/JXOUT  MULTIA : INFOS MULTIAPPUI
C       IN  NBMODS : NOMBRE MODES STATIQUES (MODELISATION MULTIAPPUI?)
C       IN  NBPASE : NOMBRE PARAMETRES SENSIBLES
C       IN  INPSCO : SD CONTENANT LISTE DES NOMS POUR SENSIBILITE
C       IN  THETA  : PARAMETRE METHODE INTEGRATION
C       IN  IALGO  : ALGORITHME D'INTEGRATION EN TEMPS
C                       CF DETAILS NDLECT
C       IN  CMD    : COMMANDE EN COURS 
C                      'DYNA_NON_LINE'
C                      'DYNA_TRAN_EXPLI'
C       IN  DEFICO : SD DEFINITION DU CONTACT
C       IN  DECOL  : ?
C       IN  VITMOI : VITESSE INSTANT MOINS
C       IN  ACCMOI : ACCELERATION INSTANT MOINS
C      OUT  DEPDEL : INCREMENT DEPLACEMENT (PREDICTEUR) EN EXPLICITE
C ----------------------------------------------------------------------
      
C -------------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ----------------
C
      CHARACTER*32       JEXNUM
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
C -------------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ----------------


      CHARACTER*24  VITPLU,ACCPLU,DEPKM1,VITKM1,ACCKM1,ROMKM1
      CHARACTER*24  ROMK,MAESCL,ECPDON
      CHARACTER*24  FONDEP,FONVIT,FONACC,MULTAP,PSIDEL, K24BLA
      INTEGER       NRPASE, IAUX, JAUX, IECPCO, JECPD, JVITM, JACCM
      INTEGER       JVITP,JACCP,JDEPKM,JVITKM,JACCKM,JROMKM,JROMK
      INTEGER       I,J,IE,JDEPP,JDEPEN,JVITEN,JACCEN,JNODEP,JDEPDE
      INTEGER       JNOVIT,JNOACC,JMLTAP,JPSDEL,NBEXCI,IER
      REAL*8        PAS,V0ACC1,A0VIT1,COEF1,COEF2,COEF3,TETA
      REAL*8        COEVI2,COEAC2

C ----------------------------------------------------------------------
      CALL JEMARQ()
      
C FORMULATION CONTINUE EN DEPL OU EN VITE (CONTACT ECP)     
C MESSAGE D'ERREUR SI [DEPL & TETA_METHODE] OU 
C                     [VITE ET (NEWMARK OU HHT)]

      IF (CMD(1:13) .EQ. 'DYNA_NON_LINE') THEN
        MAESCL = DEFICO(1:16)//'.MAESCL'
        CALL JEEXIN(MAESCL, IECPCO)
        IF (IECPCO .NE. 0) THEN
          ECPDON = DEFICO(1:16)//'.ECPDON'
          CALL JEVEUO(ECPDON,'L',JECPD)
          IFORM = ZI(JECPD+6)
        ELSE
          IFORM=1
        ENDIF
      ELSEIF (CMD(1:4) .EQ. 'STAT') THEN
        IFORM =1        
      ENDIF      


      IF (((IFORM .EQ. 1) .AND. (IALGO .EQ. 3)) .OR. 
     & ((IFORM .EQ. 2) .AND. ((IALGO .EQ. 1) .OR. (IALGO .EQ. 2))))
     & CALL UTMESS('F', 'DINIT','UTILISER LA FORMULATION EN' 
     &            //' DEPLACEMENT AVEC NEWMARK (OU HHT) OU LA'   
     &            //' FORMULATION EN VITESSE AVEC TETA_METHODE' )
      

      IF (DECOL) THEN
       TETA=THETA
       ELSE
       TETA=1.D0
      ENDIF        
        
      PAS = INSTAP - INSTAM
      V0ACC1 = V0ACC*PAS
      A0VIT1 = A0VIT/PAS
      
      IF (IFORM .EQ. 1) THEN
       COEVIT = DELTA/ALPHA/PAS
       COEACC = 1.D0/ALPHA/PAS/PAS
      ELSE 
       COEVIT = 1.D0/TETA/PAS
       COEACC = 1.D0/TETA/PAS/PAS
      ENDIF

C -- EXTRACTION DES NOMS DES CHAMPS
      CALL DESAGG(POUGD, DEPKM1, VITKM1, ACCKM1, K24BLA,
     &            K24BLA, ROMKM1, ROMK , K24BLA)
      IF (NBMODS.NE.0) THEN
        CALL DESAGG(MULTIA, FONDEP, FONVIT, FONACC, MULTAP,
     &              PSIDEL, K24BLA, K24BLA, K24BLA)
      ENDIF

      DO 20 NRPASE = NBPASE,0,-1
        IAUX = NRPASE
        JAUX = 4
        CALL PSNSLE(INPSCO,IAUX,JAUX,DEPPLU)
        JAUX = 14
        CALL PSNSLE(INPSCO,IAUX,JAUX,VITPLU)
        JAUX = 16
        CALL PSNSLE(INPSCO,IAUX,JAUX,ACCPLU)
        JAUX = 18
        CALL PSNSLE(INPSCO,IAUX,JAUX,DEPENT)
        JAUX = 20
        CALL PSNSLE(INPSCO,IAUX,JAUX,VITENT)
        JAUX = 22
        CALL PSNSLE(INPSCO,IAUX,JAUX,ACCENT)

C -- INITIALISATION DES CHAMPS DYNAMIQUES        
        CALL JEVEUO(DEPPLU(1:19)//'.VALE','L',JDEPP )
        CALL JEVEUO(VITPLU(1:19)//'.VALE','E',JVITP )
        CALL JEVEUO(ACCPLU(1:19)//'.VALE','E',JACCP )
        CALL JEVEUO(DEPKM1(1:19)//'.VALE','E',JDEPKM)
        CALL JEVEUO(VITKM1(1:19)//'.VALE','E',JVITKM)
        CALL JEVEUO(ACCKM1(1:19)//'.VALE','E',JACCKM)
        CALL JEVEUO(ROMKM1(1:19)//'.VALE','E',JROMKM)
        CALL JEVEUO(ROMK(1:19)  //'.VALE','E',JROMK )
C        
        DO 10 I = 1,NEQ
          ZR(JDEPKM+I-1) = ZR(JDEPP+I-1)
          ZR(JVITKM+I-1) = ZR(JVITP+I-1)
          ZR(JACCKM+I-1) = ZR(JACCP+I-1)

          IF (IFORM .EQ. 1) THEN           
          ZR(JVITP+I-1)  = V0VIT*ZR(JVITKM+I-1) + V0ACC1*ZR(JACCKM+I-1)
          ZR(JACCP+I-1)  = A0VIT1*ZR(JVITKM+I-1) + A0ACC*ZR(JACCKM+I-1)
          ELSE
          ZR(JVITP+I-1)  = ZR(JVITKM+I-1)*(TETA-1)/TETA
          ZR(JACCP+I-1)  = -ZR(JVITKM+I-1)/(PAS*TETA)
          ENDIF       
        
          ZR(JROMKM+I-1) = 0.D0
          ZR(JROMK+I-1)  = 0.D0
10      CONTINUE


C -- INITIALISATION DES CHAMPS "MULTI-APPUIS"
        IF (NBMODS.NE.0) THEN
          CALL GETFAC('EXCIT',NBEXCI)
          CALL JEVEUO(DEPENT(1:19)//'.VALE','E',JDEPEN)
          CALL JEVEUO(VITENT(1:19)//'.VALE','E',JVITEN)
          CALL JEVEUO(ACCENT(1:19)//'.VALE','E',JACCEN)
          CALL JEVEUO(FONDEP,'L',JNODEP)
          CALL JEVEUO(FONVIT,'L',JNOVIT)
          CALL JEVEUO(FONACC,'L',JNOACC)
          CALL JEVEUO(MULTAP,'L',JMLTAP)
          CALL JEVEUO(PSIDEL,'L',JPSDEL)
          DO 710 IE = 1,NEQ
            ZR(JDEPEN+IE-1) = 0.D0
            ZR(JVITEN+IE-1) = 0.D0
            ZR(JACCEN+IE-1) = 0.D0
  710     CONTINUE
C CE QUI SUIT EST A MODIFIER LORSQUE L ON DERIVERA P/R A UN CHARGEMENT
C DE TYPE DIRICHLET
          IF (NRPASE.EQ.0) THEN
           DO 910 J = 1,NBEXCI
            IF (ZI(JMLTAP+J-1).EQ.1) THEN
             CALL FOINTE('F ',ZK8(JNODEP+J-1),1,'INST',INSTAP,COEF1,
     +                   IER)
             CALL FOINTE('F ',ZK8(JNOVIT+J-1),1,'INST',INSTAP,COEF2,
     +                   IER)
             CALL FOINTE('F ',ZK8(JNOACC+J-1),1,'INST',INSTAP,COEF3,
     +                   IER)
            ELSE
             COEF1 = 0.D0
             COEF2 = 0.D0
             COEF3 = 0.D0
            ENDIF
            DO 810 IE = 1,NEQ
             ZR(JDEPEN+IE-1) = ZR(JDEPEN+IE-1) +
     +                         ZR(JPSDEL+ (J-1)*NEQ+IE-1)*COEF1
             ZR(JVITEN+IE-1) = ZR(JVITEN+IE-1) +
     +                         ZR(JPSDEL+ (J-1)*NEQ+IE-1)*COEF2
             ZR(JACCEN+IE-1) = ZR(JACCEN+IE-1) +
     +                         ZR(JPSDEL+ (J-1)*NEQ+IE-1)*COEF3
  810       CONTINUE
  910      CONTINUE
          ENDIF
        ENDIF


20    CONTINUE

C -- SI DYNA_TRAN_EXPLI ON CALCULE LES PREDICTEURS
C               {DUn+1}=DT*{Vn}+DT*DT/2*{An}
C               {Un+1}={Un}+{DUn+1}
      IF (CMD.EQ.'DYNA_TRAN_EXPLI') THEN
        CALL JEVEUO(VITMOI(1:19)//'.VALE','L',JVITM)
        CALL JEVEUO(ACCMOI(1:19)//'.VALE','L',JACCM)
        CALL JEVEUO (DEPDEL(1:19)//'.VALE','E',JDEPDE)
        CALL JEVEUO (DEPPLU(1:19)//'.VALE','E',JDEPP )
        COEVI2 = PAS
        COEAC2 = COEVI2*COEVI2/2.D0
        DO 11 I = 1 , NEQ
           ZR(JDEPDE+I-1) = COEVI2*ZR(JVITM+I-1)+COEAC2*ZR(JACCM+I-1)
           ZR(JDEPP+I-1) = ZR(JDEPP+I-1)+ZR(JDEPDE+I-1)
 11     CONTINUE
      ENDIF
      CALL JEDEMA()

      END
