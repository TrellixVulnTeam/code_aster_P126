      SUBROUTINE NMCESE(MODELE,NUMEDD,MATE  ,CARELE,COMREF,
     &                  COMPOR,LISCHA,CARCRI,FONACT,SDSTAT,
     &                  DEFICO,ITERAT,SDNUME,SDPILO,VALINC,
     &                  SOLALG,VEELEM,VEASSE,SDTIME,OFFSET,
     &                  TYPSEL,SDDISC,LICITE,RHO   ,ETA   ,
     &                  ETAF  ,CRITER,LDCCVG,PILCVG,MATASS)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 10/04/2012   AUTEUR KAZYMYRE K.KAZYMYRENKO 
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
C TOLE CRP_21
C
      IMPLICIT NONE
      INTEGER       FONACT(*)
      INTEGER       ITERAT
      REAL*8        RHO, OFFSET,ETA(2)
      CHARACTER*19  LISCHA,SDNUME,SDPILO,SDDISC,MATASS
      CHARACTER*24  MODELE,NUMEDD,MATE  ,CARELE,COMREF,COMPOR
      CHARACTER*24  CARCRI,DEFICO
      CHARACTER*19  VEELEM(*),VEASSE(*)
      CHARACTER*19  SOLALG(*),VALINC(*)
      CHARACTER*24  TYPSEL,SDTIME,SDSTAT
      INTEGER       LICITE(2)
      INTEGER       LDCCVG,PILCVG
      REAL*8        ETAF,CRITER
C
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (ALGORITHME - PILOTAGE)
C
C SELECTION DU PARAMETRE DE PILOTAGE ENTRE DEUX SOLUTIONS
C
C ----------------------------------------------------------------------
C
C
C IN  MODELE : MODELE
C IN  NUMEDD : NUME_DDL
C IN  MATE   : CHAMP MATERIAU
C IN  CARELE : CARACTERISTIQUES DES ELEMENTS DE STRUCTURE
C IN  COMREF : VARI_COM DE REFERENCE
C IN  COMPOR : COMPORTEMENT
C IN  LISCHA : LISTE DES CHARGES
C IN  SDPILO : SD PILOTAGE
C IN  SDSTAT : SD STATISTIQUES
C IN  SDNUME : SD NUMEROTATION
C IN  CARCRI : PARAMETRES DES METHODES D'INTEGRATION LOCALES
C IN  FONACT : FONCTIONNALITES ACTIVEES
C IN  DEFICO : SD DEFINITION CONTACT
C IN  VALINC : VARIABLE CHAPEAU POUR INCREMENTS VARIABLES
C IN  SOLALG : VARIABLE CHAPEAU POUR INCREMENTS SOLUTIONS
C IN  ITERAT : NUMERO D'ITERATION DE NEWTON
C IN  VEELEM : VARIABLE CHAPEAU POUR NOM DES VECT_ELEM
C IN  VEASSE : VARIABLE CHAPEAU POUR NOM DES VECT_ASSE
C IN  OFFSET : DECALAGE DE ETA_PILOTAGE EN FONCTION DE RHO
C IN  TYPSEL : TYPE DE SELECTION PILOTAGE
C                'ANGL_INCR_DEPL'
C                'NORM_INCR_DEPL'
C                'RESIDU'
C IN  SDDISC : SD DISCRETISATION
C IN  SDTIME : SD TIMER
C IN  LICITE : CODE RETOUR PILOTAGE DES DEUX PARAMETRES DE PILOTAGE
C IN  RHO    : PARAMETRE DE RECHERCHE_LINEAIRE
C IN  ETA    : LES DEUX PARAMETRES DE PILOTAGE
C OUT ETAF   : PARAMETRE DE PILOTAGE FINALEMENT CHOISI
C OUT CRITER : VALEUR DU CRITERE DE COMPARAISON
C                ANGL_INCR_DEPL
C                NORM_INCR_DEPL
C                RESIDU
C OUT LDCCVG : CODE RETOUR DE L'INTEGRATION DU COMPORTEMENT
C                -1 : PAS D'INTEGRATION DU COMPORTEMENT
C                 0 : CAS DU FONCTIONNEMENT NORMAL
C                 1 : ECHEC DE L'INTEGRATION DE LA LDC
C                 3 : SIZZ PAS NUL POUR C_PLAN DEBORST
C I/O PILCVG : CODE DE CONVERGENCE POUR LE PILOTAGE
C                -1 : PAS DE CALCUL DU PILOTAGE
C                 0 : CAS DU FONCTIONNEMENT NORMAL
C                 1 : PAS DE SOLUTION
C                 2 : BORNE ATTEINTE -> FIN DU CALCUL
C IN  MATASS : SD MATRICE ASSEMBLEE
C
C -------------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ----------------
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
C -------------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ----------------
C
      INTEGER       LDCCV(2),IERM,INDIC,JPLIR,JPLTK,SEL
      REAL*8        F(2),R8BID
      CHARACTER*8   CHOIX,TXT
      CHARACTER*19  DEPOLD,DEPDEL,DEPPR1,DEPPR2
      CHARACTER*24  TYPPIL
      INTEGER       IFM,NIV,IB,IBID
      LOGICAL       SWLOUN,ISXFE
      LOGICAL       SWITCH,MIXTE,NMRCYC
      REAL*8        MIINCR,MIRESI,CONTRA,PRECYC,FNID(2)
      PARAMETER     (CONTRA=0.1D0,PRECYC=5.D-2)
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFDBG('PILOTAGE',IFM,NIV)
C
C --- LE CALCUL DE PILOTAGE A FORCEMENT ETE REALISE
C
      CALL ASSERT(PILCVG.GE.0)
C
C --- INITIALISATIONS
C
      CALL JEVEUO(SDPILO(1:19)//'.PLTK','L',JPLTK)
      TYPPIL   = ZK24(JPLTK)
      F(1)     = 0.D0
      F(2)     = 0.D0
      LDCCV(1) = -1
      LDCCV(2) = -1
      LDCCVG   = -1
C
C --- STRATEGIE MIXTE BASEE SUR LE CONTRASTE DES CRITERES DE CHOIX
C
      MIXTE  = TYPSEL.EQ.'MIXTE'
      SWITCH = .FALSE.
C
C --- VERIFICATION DE LA COMPATIBILITE
C
      IF (MIXTE) THEN
        CALL UTDIDT('L',SDDISC,'ECHE',0,'CHOIX_SOLU_PILO',
     &             R8BID,IBID,CHOIX)
        IF (CHOIX.EQ.'AUTRE') CALL U2MESS('F','MECANONLINE_62')
      END IF
C
C --- STRATEGIE BASEE SUR LES TECHNIQUES EVENT-DRIVEN 'AUTRE_PILOTAGE'
C
      SWLOUN = .FALSE.
C
C --- ETONNANT QUE X-FEM SE GLISSE A CE NIVEAU DU CODE (ET PLUS AVANT)
C
      CALL EXIXFE(MODELE,IERM)
      ISXFE = (IERM.EQ.1)
C
C --- DECOMPACTION VARIABLES CHAPEAUX
C
      CALL NMCHEX(SOLALG,'SOLALG','DEPPR1',DEPPR1)
      CALL NMCHEX(SOLALG,'SOLALG','DEPPR2',DEPPR2)
      CALL NMCHEX(SOLALG,'SOLALG','DEPOLD',DEPOLD)
      CALL NMCHEX(SOLALG,'SOLALG','DEPDEL',DEPDEL)
C
C --- SELECTION SELON LA METHODE CHOISIE: ANGL_INCR_DEPL
C
      IF (TYPSEL.EQ.'ANGL_INCR_DEPL') THEN

        IF (TYPPIL.EQ.'LONG_ARC' .OR. TYPPIL.EQ.'SAUT_LONG_ARC') THEN
          CALL JEVEUO(SDPILO(1:19)//'.PLIR','L',JPLIR)
          SWLOUN = ZR(JPLIR)*ZR(JPLIR-1+6).LT.0.D0
        ENDIF

        CALL NMCEAI(NUMEDD,DEPDEL,DEPPR1,DEPPR2,DEPOLD,
     &              SDPILO,RHO   ,ETA(1),ISXFE,F(1),INDIC)
        CALL NMCEAI(NUMEDD,DEPDEL,DEPPR1,DEPPR2,DEPOLD,
     &              SDPILO,RHO   ,ETA(2),ISXFE,F(2),INDIC)
        IF (INDIC.EQ.0) THEN
           CALL NMCENI(NUMEDD,DEPDEL,DEPPR1,DEPPR2,RHO,
     &              SDPILO,ETA(1),ISXFE,F(1) )
           CALL NMCENI(NUMEDD,DEPDEL,DEPPR1,DEPPR2,RHO,
     &              SDPILO,ETA(2),ISXFE,F(2) )
        ENDIF
        GOTO 5000
      ENDIF
C
C --- SELECTION SELON LA METHODE CHOISIE: NORM_INCR_DEPL OU MIXTE
C
      IF (TYPSEL.EQ.'NORM_INCR_DEPL'.OR.MIXTE) THEN
        CALL NMCENI(NUMEDD,DEPDEL,DEPPR1,DEPPR2,RHO,
     &              SDPILO,ETA(1),ISXFE,F(1) )
        CALL NMCENI(NUMEDD,DEPDEL,DEPPR1,DEPPR2,RHO,
     &              SDPILO,ETA(2),ISXFE,F(2) )
C
C ----- SI STRATEGIE MIXTE : EXAMEN DU CONTRASTE
C
        IF (MIXTE) THEN
          MIINCR = MIN(F(1),F(2))/MAX(F(1),F(2))
          IF (MIINCR.LE.CONTRA) GOTO 6000
C
C ------- ECHEC DU CONTRASTE: ON ENCHAINE PAR LA SELECTION RESIDU
C
          FNID(1) = F(1)
          FNID(2) = F(2)
        ELSE
          GOTO 5000
        ENDIF
      ENDIF
C
C --- SELECTION SELON LA METHODE CHOISIE: RESIDU OU MIXTE
C
      IF (TYPSEL.EQ.'RESIDU'.OR.MIXTE) THEN
        CALL NMCERE(MODELE,NUMEDD,MATE  ,CARELE,COMREF,
     &              COMPOR,LISCHA,CARCRI,FONACT,SDSTAT,
     &              DEFICO,ITERAT,SDNUME,VALINC,SOLALG,
     &              VEELEM,VEASSE,SDTIME,OFFSET,RHO   ,
     &              ETA(1),F(1)  ,LDCCV(1),MATASS)
        CALL NMCERE(MODELE,NUMEDD,MATE  ,CARELE,COMREF,
     &              COMPOR,LISCHA,CARCRI,FONACT,SDSTAT,
     &              DEFICO,ITERAT,SDNUME,VALINC,SOLALG,
     &              VEELEM,VEASSE,SDTIME,OFFSET,RHO   ,
     &              ETA(2),F(2)  ,LDCCV(2),MATASS)
C
C ----- SI STRATEGIE MIXTE : EXAMEN DU CONTRASTE
C
        IF (MIXTE) THEN
          IF (LDCCV(1).EQ.0 .AND. LDCCV(2).EQ.0) THEN
            MIRESI = MIN(F(1),F(2))/MAX(F(1),F(2))
            IF (MIRESI.LE.CONTRA) GOTO 6000
          ENDIF
        ELSE
          GOTO 5000
        ENDIF
      ENDIF
C
C --- STRATEGIE MIXTE: LES DEUX CONTRASTES SONT INSUFFISANTS
C --- ON REVIENT SUR NORM_INCR_DEPL ET ON TESTE LES CYCLES
C
      IF (MIXTE) THEN
        F(1)     = FNID(1)
        F(2)     = FNID(2)
        LDCCV(1) = 0
        LDCCV(2) = 0
        SWITCH   = NMRCYC(SDDISC,ITERAT,PRECYC)
        GOTO 6000
      ENDIF
C
 5000 CONTINUE
C
C --- PERMUTATION PAR EVENT DRIVEN (HORS STRATEGIE 'MIXTE')
C
      CALL UTDIDT('L',SDDISC,'ECHE',IB,'CHOIX_SOLU_PILO',
     &             R8BID,IBID,CHOIX)
      CALL ASSERT(CHOIX.EQ.'NATUREL'.OR.CHOIX.EQ.'AUTRE')
      IF(CHOIX.EQ.'AUTRE'.OR.SWLOUN) THEN
        SWITCH = .TRUE.
        TXT    = 'NATUREL'
        IF (CHOIX.EQ.'AUTRE') THEN
            CALL UTDIDT('E',SDDISC,'ECHE',IB,
     &                 'CHOIX_SOLU_PILO',R8BID,IBID,TXT)
        ENDIF
      ENDIF

 6000 CONTINUE
C
C --- RETOUR DE LA SELECTION AVEC EVENTUELLEMENT INTERVERSION
C
      SEL    = 2
      IF ((F(1).LE.F(2) .AND. .NOT.SWITCH) .OR.
     &    (F(1).GT.F(2) .AND. SWITCH)) SEL=1
      ETAF   = ETA(SEL)
      PILCVG = LICITE(SEL)
      LDCCVG = LDCCV(SEL)
      CRITER = F(SEL)
C
      CALL JEDEMA()
      END
