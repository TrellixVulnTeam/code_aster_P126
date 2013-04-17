      SUBROUTINE NMDEPL(MODELE,NUMEDD,MATE  ,CARELE,COMREF,
     &                  COMPOR,LISCHA,FONACT,SDSTAT,PARMET,
     &                  CARCRI,NOMA  ,METHOD,NUMINS,ITERAT,
     &                  SOLVEU,MATASS,SDDISC,SDDYNA,SDNUME,
     &                  SDPILO,SDTIME,SDERRO,DEFICO,RESOCO,
     &                  DEFICU,RESOCU,VALINC,SOLALG,VEELEM,
     &                  VEASSE,ETA   ,CONV  ,LERRIT)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 15/04/2013   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2013  EDF R&D                  WWW.CODE-ASTER.ORG
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
      INCLUDE 'jeveux.h'
      INTEGER      FONACT(*)
      INTEGER      ITERAT,NUMINS
      REAL*8       PARMET(*),CONV(*),ETA
      CHARACTER*8  NOMA
      CHARACTER*16 METHOD(*)
      CHARACTER*19 SDDISC,SDNUME,SDDYNA,SDPILO
      CHARACTER*19 LISCHA,MATASS,SOLVEU
      CHARACTER*24 MODELE,NUMEDD,MATE,CARELE,COMREF,COMPOR
      CHARACTER*24 CARCRI,SDTIME,SDERRO,SDSTAT
      CHARACTER*19 VEELEM(*),VEASSE(*)
      CHARACTER*19 SOLALG(*),VALINC(*)
      CHARACTER*24 DEFICO,DEFICU,RESOCU,RESOCO
      LOGICAL      LERRIT
C
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (ALGORITHME)
C
C CALCUL DE L'INCREMENT DE DEPLACEMENT A PARTIR DE(S) DIRECTION(S)
C DE DESCENTE
C PRISE EN COMPTE DU PILOTAGE ET DE LA RECHERCHE LINEAIRE
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
C IN  FONACT : FONCTIONNALITES ACTIVEES
C IN  SDTIME : SD TIMER
C IN  SDSTAT : SD STATISTIQUES
C IN  PARMET : PARAMETRES DES METHODES DE RESOLUTION
C IN  CARCRI : PARAMETRES DES METHODES D'INTEGRATION LOCALES
C IN  NOMA   : NOM DU MAILLAGE
C IN  METHOD : INFORMATIONS SUR LES METHODES DE RESOLUTION
C IN  ITERAT : NUMERO D'ITERATION DE NEWTON
C IN  NUMINS : NUMERO D'INSTANT
C IN  MATASS : NOM DE LA MATRICE DU PREMIER MEMBRE ASSEMBLEE
C IN  SOLVEU : NOM DU SOLVEUR
C IN  SDNUME : SD NUMEROTATION
C IN  SDDISC : SD DISCRETISATION
C IN  SDDYNA : SD DYNAMIQUE
C IN  SDPILO : SD PILOTAGE
C IN  SDERRO : SD GESTION DES ERREURS
C IN  DEFICO : SD DEFINITION CONTACT
C IN  RESOCO : SD RESOLUTION CONTACT
C IN  DEFICU : SD DEFINITION LIAISON_UNILATERALE
C IN  RESOCU : SD RESOLUTION LIAISON_UNILATERALE
C IN  VALINC : VARIABLE CHAPEAU POUR INCREMENTS VARIABLES
C IN  SOLALG : VARIABLE CHAPEAU POUR INCREMENTS SOLUTIONS
C IN  VEELEM : VARIABLE CHAPEAU POUR NOM DES VECT_ELEM
C IN  VEASSE : VARIABLE CHAPEAU POUR NOM DES VECT_ASSE
C I/O CONV   : INFORMATIONS SUR LA CONVERGENCE DU CALCUL
C I/O ETA    : PARAMETRE DE PILOTAGE
C OUT LERRIT : .TRUE. SI ERREUR PENDANT L'ITERATION
C
C
C
C
      REAL*8       ETAN,OFFSET,RHO
      REAL*8       DIINST,INSTAM,INSTAP,DELTAT,RESIGR
      LOGICAL      ISFONC,LPILO,LRELI,LCTCD,LUNIL
      CHARACTER*19 CNFEXT
      INTEGER      CTCCVG,LDCCVG,PILCVG
      INTEGER      IFM,NIV
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFDBG('MECA_NON_LINE',IFM,NIV)
C
C --- AFFICHAGE
C
      IF (NIV.GE.2) THEN
        WRITE (IFM,*) '<MECANONLINE> CORRECTION INCR. DEPL.'
      ENDIF
C
C --- INITIALISATIONS CODES RETOURS
C
      LDCCVG = -1
      CTCCVG = -1
      PILCVG = -1
C
C --- FONCTIONNALITES ACTIVEES
C
      LPILO  = ISFONC(FONACT,'PILOTAGE')
      LRELI  = ISFONC(FONACT,'RECH_LINE')
      LUNIL  = ISFONC(FONACT,'LIAISON_UNILATER')
      LCTCD  = ISFONC(FONACT,'CONT_DISCRET')
C
C --- INITIALISATIONS
C
      INSTAM = DIINST(SDDISC,NUMINS-1)
      INSTAP = DIINST(SDDISC,NUMINS)
      DELTAT = INSTAP - INSTAM
      ETAN   = ETA
      RHO    = 1.D0
      OFFSET = 0.D0
      ETA    = 0.D0
      RESIGR = CONV(3)
C
C --- CALCUL DE LA RESULTANTE DES EFFORTS EXTERIEURS
C
      CALL NMCHEX(VEASSE,'VEASSE','CNFEXT',CNFEXT)
      CALL NMFEXT(ETAN  ,FONACT,SDDYNA,VEASSE,CNFEXT)
C
C --- CONVERSION RESULTAT dU VENANT DE K.dU = F SUIVANT SCHEMAS
C
      CALL NMSOLU(SDDYNA,SOLALG)
C
C --- PAS DE RECHERCHE LINEAIRE (EN PARTICULIER SUITE A LA PREDICTION)
C
      IF (.NOT.LRELI .OR. ITERAT.EQ.0) THEN
        IF (LPILO) THEN
          CALL NMPICH(MODELE,NUMEDD,MATE  ,CARELE,COMREF,
     &                COMPOR,LISCHA,CARCRI,FONACT,SDSTAT,
     &                DEFICO,RESOCO,SDPILO,ITERAT,SDNUME,
     &                DELTAT,VALINC,SOLALG,VEELEM,VEASSE,
     &                SDTIME,SDDISC,ETA   ,RHO   ,OFFSET,
     &                LDCCVG,PILCVG,MATASS)
          CONV(1) = 0
          CONV(2) = 1.D0
        ENDIF
      ELSE
C
C --- RECHERCHE LINEAIRE
C
        IF (LPILO) THEN
          CALL NMREPL(MODELE,NUMEDD,MATE  ,CARELE,COMREF,
     &                COMPOR,LISCHA,PARMET,CARCRI,FONACT,
     &                ITERAT,SDSTAT,SDPILO,SDNUME,SDDYNA,
     &                METHOD,DEFICO,RESOCO,DELTAT,VALINC,
     &                SOLALG,VEELEM,VEASSE,SDTIME,SDDISC,
     &                ETAN  ,CONV  ,ETA   ,RHO   ,OFFSET,
     &                LDCCVG,PILCVG,MATASS)
        ELSE
          CALL NMRELI(MODELE,NUMEDD,MATE  ,CARELE,COMREF,
     &                COMPOR,LISCHA,CARCRI,FONACT,ITERAT,
     &                SDSTAT,SDNUME,SDDYNA,PARMET,METHOD,
     &                DEFICO,VALINC,SOLALG,VEELEM,VEASSE,
     &                SDTIME,CONV  ,LDCCVG)
        END IF
      END IF
C
C --- SI ERREUR PENDANT L'INTEGRATION OU LE PILOTAGE -> ON SORT DIRECT
C
      IF ((LDCCVG .EQ. 1).OR.(PILCVG .EQ. 1)) THEN
        GOTO 9999
      ENDIF
C
C --- AJUSTEMENT DE LA DIRECTION DE DESCENTE (AVEC ETA, RHO ET OFFSET)
C
      CALL NMPILD(NUMEDD,SDDYNA,SOLALG,LPILO ,LRELI ,
     &            ETA   ,ITERAT,RHO   ,OFFSET)
C
C --- MODIFICATIONS DEPLACEMENTS SI CONTACT DISCRET OU LIAISON_UNILA
C
      IF (LUNIL.OR.LCTCD) THEN
        CALL NMCOUN(NOMA  ,FONACT,SOLVEU,NUMEDD,MATASS,
     &              DEFICO,RESOCO,DEFICU,RESOCU,ITERAT,
     &              VALINC,SOLALG,VEASSE,INSTAP,RESIGR,
     &              SDTIME,SDSTAT,CTCCVG)
        IF (CTCCVG.EQ.0) THEN
          CALL NMSOLM(SDDYNA,SOLALG)
        ELSE
          GOTO 9999
        ENDIF
      ENDIF
C
C --- ACTUALISATION DES CHAMPS SOLUTIONS
C
      CALL NMMAJC(FONACT,SDDYNA,SDNUME,DELTAT,NUMEDD,
     &            VALINC,SOLALG)
C
 9999 CONTINUE
C
C --- TRANSFORMATION DES CODES RETOURS EN EVENEMENTS
C
      CALL NMCRET(SDERRO,'LDC',LDCCVG)
      CALL NMCRET(SDERRO,'PIL',PILCVG)
      CALL NMCRET(SDERRO,'CTC',CTCCVG)
C
C --- EVENEMENT ERREUR ACTIVE ?
C
      CALL NMLTEV(SDERRO,'ERRI','NEWT',LERRIT)
C
C --- IMPRESSION D'UN CHAMP POUR DEBUG
C
      CALL DBGCHA(VALINC,INSTAP,ITERAT)
C
      CALL JEDEMA()
      END
