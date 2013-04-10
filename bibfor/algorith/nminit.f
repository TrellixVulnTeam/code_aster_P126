      SUBROUTINE NMINIT(RESULT,MODELE,NUMEDD,NUMFIX,MATE  ,
     &                  COMPOR,CARELE,PARMET,LISCHA,MAPREC,
     &                  SOLVEU,CARCRI,NUMINS,SDSTAT,SDDISC,
     &                  SDNUME,DEFICO,SDCRIT,COMREF,FONACT,
     &                  PARCON,PARCRI,METHOD,LISCH2,NOMA  ,
     &                  SDPILO,SDDYNA,SDIMPR,SDSUIV,SDOBSE,
     &                  SDTIME,SDERRO,SDPOST,SDIETO,SDENER,
     &                  SDCONV,SDCRIQ,DEFICU,RESOCU,RESOCO,
     &                  VALINC,SOLALG,MEASSE,VEELEM,MEELEM,
     &                  VEASSE,CODERE)
C
C MODIF ALGORITH  DATE 09/04/2013   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C            CONFIGURATION MANAGEMENT OF EDF VERSION
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C RESPONSABLE ABBAS M.ABBAS
C TOLE CRP_21
C
      IMPLICIT NONE
      INTEGER      FONACT(*)
      REAL*8       PARCON(*),PARCRI(*),PARMET(*)
      CHARACTER*16 METHOD(*)
      INTEGER      NUMINS
      CHARACTER*8  RESULT,NOMA
      CHARACTER*19 SOLVEU,SDNUME,SDDISC,SDCRIT,SDPILO,SDOBSE,SDENER
      CHARACTER*19 SDPOST
      CHARACTER*19 LISCHA,LISCH2,SDDYNA
      CHARACTER*19 MAPREC
      CHARACTER*24 MODELE,COMPOR,NUMEDD,NUMFIX
      CHARACTER*24 DEFICO,RESOCO
      CHARACTER*24 CARCRI
      CHARACTER*24 MATE,CARELE,CODERE
      CHARACTER*19 VEELEM(*),MEELEM(*)
      CHARACTER*19 VEASSE(*),MEASSE(*)
      CHARACTER*19 SOLALG(*),VALINC(*)
      CHARACTER*24 SDIMPR,SDTIME,SDERRO,SDIETO,SDSTAT,SDCONV
      CHARACTER*24 DEFICU,RESOCU,SDSUIV,SDCRIQ
      CHARACTER*24 COMREF
C
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (ALGORITHME)
C
C INITIALISATIONS
C
C ----------------------------------------------------------------------
C
C
C IN  RESULT : NOM DE LA SD RESULTAT
C IN  SDNUME : NOM DE LA SD NUMEROTATION
C OUT LISCH2 : NOM DE LA SD INFO CHARGE POUR STOCKAGE DANS LA SD
C              RESULTAT
C OUT FONACT : FONCTIONNALITES ACTIVEES (VOIR NMFONC)
C OUT NUMEDD : NUME_DDL (VARIABLE AU COURS DU CALCUL)
C OUT NUMFIX : NUME_DDL (FIXE AU COURS DU CALCUL)
C
C ----------------------------------------------------------------------
C
      INTEGER      IRET,IBID
      REAL*8       R8BID3(3)
      REAL*8       DIINST,INSTIN
      CHARACTER*19 COMMOI
      CHARACTER*2  CODRET
      LOGICAL      LACC0,LPILO,LMPAS,LSSTF,LERRT,LRELI,LVISS
      LOGICAL      ISFONC,NDYNLO
      LOGICAL      LCONT,LUNIL
      INTEGER      IFM,NIV
      CHARACTER*19 LIGRCF,LIGRXF
      CHARACTER*8  NOMO
C
C ----------------------------------------------------------------------
C
      CALL INFDBG('MECA_NON_LINE',IFM,NIV)
C
C --- AFFICHAGE
C
      IF (NIV.GE.2) THEN
        WRITE (IFM,*) '<MECANONLINE> INITIALISATION DU CALCUL'
      ENDIF
C
C --- INITIALISATIONS
C
      CALL DISMOI('F','NOM_MAILLA',MODELE,'MODELE',IBID,NOMA,IRET)
      NOMO   = MODELE(1:8)
      LACC0  = .FALSE.
      LUNIL  = .FALSE.
      LCONT  = .FALSE.
C
C --- CREATION DE LA STRUCTURE DE DONNEE GESTION DU TEMPS
C
      CALL NMCRTI(SDTIME)
C
C --- CREATION DE LA STRUCTURE DE DONNEE STATISTIQUES
C
      CALL NMCRST(SDSTAT)
C
C --- SAISIE ET VERIFICATION DE LA COHERENCE DU CHARGEMENT CONTACT
C
      CALL NMDOCT(LISCHA,DEFICO,DEFICU,LCONT ,LUNIL ,
     &            LIGRCF,LIGRXF)
C
C --- CREATION DE LA NUMEROTATION ET PROFIL DE LA MATRICE
C
      CALL NMNUME(MODELE,RESULT,LISCHA,LCONT ,DEFICO,
     &            COMPOR,SOLVEU,NUMEDD,SDNUME)
C
C --- CREATION DE VARIABLES "CHAPEAU" POUR STOCKER LES NOMS
C
      CALL NMCHAP(VALINC,SOLALG,MEELEM,VEELEM,VEASSE,
     &            MEASSE)
C
C --- FONCTIONNALITES ACTIVEES
C
      CALL NMFONC(PARCRI,PARMET,METHOD,SOLVEU,MODELE,
     &            DEFICO,LISCHA,LCONT ,LUNIL ,SDNUME,
     &            SDDYNA,SDCRIQ,MATE  ,COMPOR,RESULT,
     &            FONACT)
      LPILO  = ISFONC(FONACT,'PILOTAGE'  )
      LMPAS  = NDYNLO(SDDYNA,'MULTI_PAS' )
      LSSTF  = ISFONC(FONACT,'SOUS_STRUC')
      LERRT  = ISFONC(FONACT,'ERRE_TEMPS_THM')
      LRELI  = ISFONC(FONACT,'RECH_LINE' )
      LVISS  = NDYNLO(SDDYNA,'VECT_ISS'  )
C
C --- CREATION DE LA STRUCTURE DE DONNEE RESULTAT DU CONTACT
C
      IF (LCONT) THEN
        CALL CFMXSD(NOMA  ,NOMO  ,NUMEDD,FONACT,SDDYNA,
     &              DEFICO,RESOCO,LIGRCF,LIGRXF)
      ENDIF
C
C --- CREATION DE LA STRUCTURE DE LIAISON_UNILATERALE
C
      IF (LUNIL) THEN
        CALL CUCRSD(NOMA  ,NUMEDD,DEFICU,RESOCU)
      ENDIF
C
C --- CREATION DES VECTEURS D'INCONNUS
C
      CALL NMCRCH(NUMEDD,FONACT,SDDYNA,DEFICO,VALINC,
     &            SOLALG,VEASSE)
C
C --- CONSTRUCTION DU CHAM_NO ASSOCIE AU PILOTAGE
C
      IF (LPILO) THEN
        CALL NMDOPI(MODELE,NUMEDD,METHOD,LRELI ,SDPILO)
      ENDIF
C
C --- DUPLICATION NUME_DDL POUR CREER UN DUME_DDL FIXE
C
      CALL NMPRO2(FONACT,NUMEDD,NUMFIX)
C
C --- CONSTRUCTION DU CHAM_ELEM_S ASSOCIE AU COMPORTEMENT
C
      CALL NMDOCO(MODELE,CARELE,COMPOR)
C
C --- CREATION DE LA SD IN ET OUT
C
      CALL NMETCR(MODELE,COMPOR,FONACT,SDDYNA,SDPOST,
     &            DEFICO,RESOCO,SDIETO,CARELE)
C
C --- LECTURE ETAT_INIT
C
      CALL NMDOET(MODELE,COMPOR,FONACT,NUMEDD,SDPILO,
     &            SDDYNA,SDCRIQ,SDIETO,SOLALG,LACC0 ,
     &            INSTIN)
C
C --- CREATION SD DISCRETISATION, ARCHIVAGE ET OBSERVATION
C
      CALL DIINIT(NOMA  ,NOMO  ,RESULT,MATE  ,CARELE,
     &            FONACT,SDDYNA,PARCRI,INSTIN,SDIETO,
     &            SOLVEU,DEFICO,SDDISC,SDOBSE,SDSUIV)
C
C --- CREATION DU CHAMP DES VARIABLES DE COMMANDE DE REFERENCE
C
      CALL NMVCRE(MODELE,MATE  ,CARELE,COMREF)
C
C --- PRE-CALCUL DES MATR_ELEM CONSTANTES AU COURS DU CALCUL
C
      CALL NMINMC(FONACT,LISCHA,SDDYNA,MODELE,COMPOR,
     &            SOLVEU,NUMEDD,NUMFIX,DEFICO,RESOCO,
     &            CARCRI,SOLALG,VALINC,MATE  ,CARELE,
     &            SDDISC,SDSTAT,SDTIME,COMREF,MEELEM,
     &            MEASSE,VEELEM,CODERE)
C
C --- INSTANT INITIAL
C
      NUMINS = 0
      INSTIN = DIINST(SDDISC,NUMINS)
C
C --- EXTRACTION VARIABLES DE COMMANDES AU TEMPS T-
C
      CALL NMCHEX(VALINC,'VALINC','COMMOI',COMMOI)
      CALL NMVCLE(MODELE,MATE  ,CARELE,LISCHA,INSTIN,
     &            COMMOI,CODRET)
C
C --- CALCUL ET ASSEMBLAGE DES VECT_ELEM CONSTANTS AU COURS DU CALCUL
C
      CALL NMINVC(MODELE,MATE  ,CARELE,COMPOR,CARCRI,
     &            SDTIME,SDDISC,SDDYNA,VALINC,SOLALG,
     &            LISCHA,COMREF,RESOCO,RESOCU,NUMEDD,
     &            FONACT,PARCON,VEELEM,VEASSE,MEASSE)
C
C --- CREATION DE LA SD POUR ARCHIVAGE DES INFORMATIONS DE CONVERGENCE
C
      CALL NMCRCV(SDCRIT)
C
C --- INITIALISATION CALCUL PAR SOUS-STRUCTURATION
C
      IF (LSSTF) THEN
        CALL NMLSSV('INIT',LISCHA,IBID  )
      ENDIF
C
C --- CREATION DE LA SD EXCIT_SOL
C
      IF (LVISS) CALL NMEXSO(NOMA  ,RESULT,SDDYNA,NUMEDD)
C
C --- CALCUL DE L'ACCELERATION INITIALE
C
      IF (LACC0) THEN
        CALL NMCHAR('ACCI',' ',
     &              MODELE,NUMEDD,MATE  ,CARELE,COMPOR,
     &              LISCHA,CARCRI,NUMINS,SDTIME,SDDISC,
     &              PARCON,FONACT,RESOCO,RESOCU,COMREF,
     &              VALINC,SOLALG,VEELEM,MEASSE,VEASSE,
     &              SDDYNA)
        CALL ACCEL0(MODELE,NUMEDD,NUMFIX,FONACT,LISCHA,
     &              DEFICO,RESOCO,MAPREC,SOLVEU,VALINC,
     &              SDDYNA,SDSTAT,SDTIME,MEELEM,MEASSE,
     &              VEELEM,VEASSE,SOLALG)
      ENDIF
C
C --- CREATION DE LA SD CONVERGENCE
C
      CALL NMCRCG(FONACT,SDCONV)
C
C --- INITIALISATION DE LA SD AFFICHAGE
C
      CALL NMINIM(SDSUIV,SDIMPR)
C
C --- PRE-CALCUL DES MATR_ASSE CONSTANTES AU COURS DU CALCUL
C
      CALL NMINMA(FONACT,LISCHA,SDDYNA,SOLVEU,NUMEDD,
     &            NUMFIX,MEELEM,MEASSE)
C
C --- OBSERVATION INITIALE
C
      CALL NMOBSV(NOMA  ,SDDISC,SDIETO,SDOBSE,NUMINS)
C
C --- CREATION DE LA SD EVOL_NOLI
C
      CALL NMNOLI(RESULT,SDDISC,SDERRO,CARCRI,SDIMPR,
     &            SDCRIT,FONACT,SDDYNA,SDPOST,MODELE,
     &            MATE  ,CARELE,LISCH2,SDPILO,SDTIME,
     &            SDENER,SDIETO,SDCRIQ)
C
CNS   ICI ON UTILISE LISCPY A LA PLACE DE COPISD POUR
CNS   RESPECTER L'ESPRIT DE COPISD QUI NE SERT QU'A
CNS   RECOPIER DE SD SANS FILTRER
C
      CALL LISCPY(LISCHA,LISCH2,'G')
C
C --- CREATION DE LA TABLE DES GRANDEURS
C
      IF (LERRT) THEN
        CALL CETULE(MODELE,R8BID3,IRET  )
      ENDIF
C
C --- CALCUL DU SECOND MEMBRE INITIAL POUR MULTI-PAS
C
      IF (LMPAS) THEN
        CALL NMIHHT(MODELE,NUMEDD,MATE  ,COMPOR,CARELE,
     &              LISCHA,CARCRI,COMREF,FONACT,SDSTAT,
     &              SDDYNA,SDTIME,SDNUME,DEFICO,RESOCO,
     &              RESOCU,VALINC,SDDISC,PARCON,SOLALG,
     &              VEASSE)
      ENDIF
C
C --- INITIALISATIONS TIMERS ET STATISTIQUES
C
      CALL NMRINI(SDTIME,SDSTAT,'T')
C
      END
