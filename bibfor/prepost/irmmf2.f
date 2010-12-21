      SUBROUTINE IRMMF2 ( FID, NOMAMD,
     &                    TYPENT, NBRENT, NBGROU, NOMGEN,
     &                    NBEC, NOMAST, PREFIX,
     &                    TYPGEO, NOMTYP, NMATYP,
     &                    NUFAEN, NUFACR, NOGRFA, NOFAEX, TABAUX,
     &                    INFMED, NIVINF, IFM )
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF PREPOST  DATE 21/12/2010   AUTEUR MASSIN P.MASSIN 
C ======================================================================
C COPYRIGHT (C) 1991 - 2010  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE GNICOLAS G.NICOLAS
C-----------------------------------------------------------------------
C     ECRITURE DU MAILLAGE - FORMAT MED - LES FAMILLES - 2
C        -  -     -                 -         -          -
C-----------------------------------------------------------------------
C     L'ENSEMBLE DES FAMILLES EST L'INTERSECTION DE L'ENSEMBLE
C     DES GROUPES : UN NOEUD/MAILLE APPARAIT AU PLUS DANS 1 FAMILLE
C     TABLE  NUMEROS DES FAMILLES POUR LES NOEUDS  <-> TABLE  DES COO
C     TABLES NUMEROS DES FAMILLES POUR MAILLE/TYPE <-> TABLES DES CNX
C     PAR CONVENTION, LES FAMILLES DE NOEUDS SONT NUMEROTEES >0 ET LES
C     FAMILLES DE MAILLES SONT NUMEROTEES <0. LA FAMILLE NULLE EST
C     DESTINEE AUX NOEUDS / ELEMENTS SANS FAMILLE.
C ENTREES :
C   FID    : IDENTIFIANT DU FICHIER MED
C   NOMAMD : NOM DU MAILLAGE MED
C   TYPENT : TYPE D'ENTITES : 0, POUR DES NOEUDS, 1 POUR DES MAILLES
C   NBRENT : NOMBRE D'ENTITES A TRAITER
C   NBGROU : NOMBRE DE GROUPES D'ENTITES
C   NOMGEN : VECTEUR NOMS DES GROUPES D'ENTITES
C   NBEC   : NOMBRE D'ENTIERS CODES
C   NOMAST : NOM DU MAILLAGE ASTER
C   PREFIX : PREFIXE POUR LES TABLEAUX DES RENUMEROTATIONS
C   TYPGEO : TYPE MED POUR CHAQUE MAILLE
C   NOMTYP : NOM DES TYPES POUR CHAQUE MAILLE
C   NMATYP : NOMBRE DE MAILLES PAR TYPE
C TABLEAUX DE TRAVAIL
C   NUFAEN : NUMERO DE FAMILLE POUR CHAQUE ENTITE
C            PAR DEFAUT, L'ALLOCATION AVEC JEVEUX A TOUT MIS A 0. CELA
C            SIGNIFIE QUE LES ENTITES APPARTIENNENT A LA FAMILLE NULLE.
C   NUFACR : NUMERO DE FAMILLES CREES. AU MAXIMUM, AUTANT QUE D'ENTITES
C   NOGRFA : NOM DES GROUPES ASSOCIES A CHAQUE FAMILLE.
C   NOFAEX = NOMS DES FAMILLES DEJA CREEES
C   TABAUX : PRESENCE D UNE ENTITE DANS UN GROUPE
C DIVERS
C   INFMED : NIVEAU DES INFORMATIONS SPECIFIQUES A MED A IMPRIMER
C   NIVINF : NIVEAU DES INFORMATIONS GENERALES
C   IFM    : UNITE LOGIQUE DU FICHIER DE MESSAGE
C-----------------------------------------------------------------------
C
      IMPLICIT NONE
C
C 0.1. ==> ARGUMENTS
C
      INTEGER FID
      INTEGER TYPGEO(*), NMATYP(*)
      INTEGER TYPENT, NBRENT, NBGROU
      INTEGER NBEC
      INTEGER NUFAEN(NBRENT), NUFACR(NBRENT), TABAUX(*)
      INTEGER INFMED
      INTEGER IFM, NIVINF
C
      CHARACTER*6 PREFIX
      CHARACTER*8 NOMAST, NOMGEN(*)
      CHARACTER*8 NOMTYP(*)
      CHARACTER*32 NOFAEX(*)
      CHARACTER*80 NOGRFA(NBGROU)
      CHARACTER*(*) NOMAMD
C
C 0.2. ==> COMMUNS
C
C     ----------- COMMUNS NORMALISES  JEVEUX  --------------------------
      COMMON /IVARJE/ZI(1)
      COMMON /RVARJE/ZR(1)
      COMMON /CVARJE/ZC(1)
      COMMON /LVARJE/ZL(1)
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      INTEGER ZI
      REAL*8 ZR
      COMPLEX*16 ZC
      LOGICAL ZL
      CHARACTER*8  ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32, JEXNUM
      CHARACTER*80 ZK80
C     -----  FIN  COMMUNS NORMALISES  JEVEUX --------------------------
C
C 0.3. ==> VARIABLES LOCALES
C
      CHARACTER*6 NOMPRO
      PARAMETER ( NOMPRO = 'IRMMF2' )
C
      INTEGER NTYMAX
      PARAMETER (NTYMAX = 56)
      INTEGER EDMAIL, EDNOEU
      PARAMETER (EDMAIL=0, EDNOEU=3)
      INTEGER TYGENO
      PARAMETER (TYGENO=0)
C
      INTEGER CODRET
      INTEGER IAUX, JAUX, KAUX
      INTEGER NUMFAM, NFAM
      INTEGER ITYP
      INTEGER NBEG, IGE, IENT, ENTFAM, NBGNOF, NATT
      INTEGER JGREN
      INTEGER TBAUX(1)
C
      CHARACTER*7 SAUX07
      CHARACTER*8 SAUX08
      CHARACTER*9 SAUX09
      CHARACTER*32  NOMFAM
      CHARACTER*200 K200
C      REAL*8 TPS1(4),TPS2(4),TPS3(4)
C
C====
C 1. PREALABLES
C====
C
      IF ( NIVINF.GE.2 ) THEN
C
        WRITE (IFM,1001) NOMPRO
 1001 FORMAT( 60('-'),/,'DEBUT DU PROGRAMME ',A)
C
      ENDIF
C
C     NATT = NOMBRE D'ATTRIBUTS DANS UNE FAMILLE : JAMAIS. ELLES NE SONT
C            DEFINIES QUE PAR LES GROUPES
      NATT = 0
C
C     NFAM = NUMERO DE LA DERNIERE FAMILLE ENREGISTREE (DE 0 A N>0)
C     FAMILLE 0 = ENTITES N'APPARTENANT A AUCUN GROUPE
      NFAM  = 0
C
C====
C 2. EN PRESENCE DE GROUPES, ON CREE DES FAMILLES
C====
C
      IF ( NBGROU.NE.0 ) THEN
C
        IF ( TYPENT.EQ.TYGENO ) THEN
          SAUX09 = '.GROUPENO'
        ELSE
          SAUX09 = '.GROUPEMA'
        ENDIF
C
C 2.1. ==> BUT DE L'ETAPE 2.1 : CONNAITRE POUR CHAQUE ENTITE SES GROUPES
C          D'APPARTENANCE
C
        DO 21 , IGE = 1 , NBGROU
C
          CALL JEVEUO(JEXNUM(NOMAST//SAUX09,IGE),'L',JGREN)
          CALL JELIRA(JEXNUM(NOMAST//SAUX09,IGE),'LONMAX',NBEG,SAUX08)
C
          IF ( INFMED.GE.2 ) THEN
            IF ( TYPENT.EQ.TYGENO ) THEN
              SAUX07 = 'NOEUDS '
            ELSE
              SAUX07 = 'MAILLES'
            ENDIF
            WRITE (IFM,2001) NOMGEN(IGE), NBEG, SAUX07
          ENDIF
 2001 FORMAT( '. GROUPE ',A,' :',I12,1X,A)
C
C         POUR CHAQUE GROUPE, ON BOUCLE SUR LES ENTITES QU'IL CONTIENT.
C
          DO 211 , IAUX = 1 , NBEG
C
C           DEBUT VECTEUR ENTIER CODE POUR ENTITE IENT DANS JENTXG
            IENT = ZI(JGREN-1+IAUX)
C           ENREGISTREMENT APPARTENANCE DU ENTITE AU GROUPE
            CALL SETGFA (TABAUX(1+(IENT-1)*NBEC),IGE)
C           MISE A -1 DU NUM DE FAMILLE POUR CETTE ENTITE DANS NUFAEN
C           POUR INDIQUER QU'ELLE APPARTIENT AU MOINS A UN GROUPE
            NUFAEN(IENT) = 1
C
  211     CONTINUE
C
   21   CONTINUE
C
C 2.2. ==> BUT DE L'ETAPE 2.2 : FAIRE LA PARTITION EN FAMILLE ET NOTER :
C          . LE NUMERO DE LA 1ER ENTITE DE LA FAMILLE
C          . LE NUMERO DE FAMILLE DE CHAQUE ENTITE
C
C          ON BOUCLE SUR LES ENTITES APPARTENANT AU MOINS A UN GROUPE
C          ET ON LES RASSEMBLE PAR IDENTITE D'APPARTENANCE.
C          LES FAMILLES SONT NUMEROTEES DANS L'ORDRE D'APPARITION
C          ATTENTION : CET ALGORITHME A ETE OPTIMISE LE 6/9/2002
C                      ETRE PRUDENT DANS LES AMELIORATIONS FUTURES ...
C                      LES SITUATIONS PENALISANTES SONT CELLES-CI :
C                      QUELQUES DIZAINES DE MILLIERS D'ENTITES ET
C                      QUELQUES CENTAINES DE GROUPES
C                      EXEMPLE : ON EST PASSE D'UNE VINGTAINE D'HEURES
C                      A 3 MINUTES AVEC UN GROS MAILLAGE :
C                      . 426 817 NOEUDS EN 57 GROUPES ET
C                      . 418 514 MAILLES EN 8 629 GROUPES.
C
        DO 22 , IENT = 1 , NBRENT
C
          IF ( NUFAEN(IENT).NE.0 ) THEN
C
C         BOUCLE 221 : ON PARCOURT TOUTES LES FAMILLES DEJA VUES.
C         POUR CHACUNE D'ELLES, ON COMPARE LES GROUPES ASSOCIES ET LES
C         GROUPES DE L'ENTITE COURANTE :
C         MEME COMPOSITION DE GROUPES <==> MEMES ENTIERS CODES
C         . SI C'EST LA MEME COMPOSITION DE GROUPES, LA FAMILLE EST LA
C           MEME. ON DONNE DONC LE NUMERO DE FAMILLE L'ENTITE COURANTE.
C         . SI ON N'A TROUVE AUCUNE FAMILLE, C'EST QU'UNE NOUVELLE
C           FAMILLE VIENT D'APPARAITRE. ON STOCKE SES CARACTERISTIQUES.
C
            JAUX = NBEC*(IENT-1)
C
            DO 221 , NUMFAM = 1 , NFAM
C
              ENTFAM = NUFACR(NUMFAM)
C
              KAUX = NBEC*(ENTFAM-1)
C
              DO 222 , IAUX = 1 , NBEC
                IF ( TABAUX(JAUX+IAUX).NE.TABAUX(KAUX+IAUX) ) THEN
                  GOTO 221
                ENDIF
  222         CONTINUE
C
C             ON A TROUVE UNE FAMILLE AVEC LA MEME COMPOSITION :
C             . ON NOTE QUE LA FAMILLE EST LA MEME
C             . ON PASSE A L'ENTITE SUIVANTE
C
              NUFAEN(IENT) = NUFAEN(ENTFAM)
              GOTO 22
C
  221      CONTINUE
C
C           AUCUN ENTITE NE CORRESPONDAIT : ON CREE UNE NOUVELLE FAMILLE
            NFAM = NFAM + 1
C           ON MEMORISE CE NUMERO DE FAMILLE POUR L'ENTITE COURANTE
C           ATTENTION : LA CONVENTION MED VEUT QUE LE NUMERO SOIT
C           POSITIF POUR LES FAMILLES DE NOEUDS, NEGATIF POUR
C           LES MAILLES
            NUFAEN(IENT) = NFAM
            IF ( TYPENT.NE.TYGENO ) THEN
              NUFAEN(IENT) = -NUFAEN(IENT)
            ENDIF
C           ON INDIQUE OU SE TROUVE LA 1ERE REFERENCE A CETTE FAMILLE
C           DANS LE VECTEUR NUFACR POUR EVITER DE PERDRE SON TEMPS APRES
            NUFACR(NFAM) = IENT
C
          ENDIF
C
 22    CONTINUE
C
C 2.3. ==> BUT DE L'ETAPE 2.3 : CREATION DES FAMILLES D'ENTITES ET LES
C          ECRIRE DANS LE FICHIER
C
C          ON PARCOURT LES FAMILLES REPERTORIEES.
C          ON MEMORISE LES NOMS ET NUMEROS DES GROUPES QUI LA
C          CARACTERISENT. POUR CELA, ON SE BASE SUR LE PREMIER ENTITE
C          QUI EN FAIT PARTIE.
C
        DO 23 , IAUX = 1 , NFAM
C
C 2.3.1. ==> DETERMINATION DE LA FAMILLE : NOM, NOMS ET NUMEROS DES
C              GROUPES ASSOCIES
C
          NUMFAM = IAUX
          IF ( TYPENT.NE.TYGENO ) THEN
            NUMFAM = -NUMFAM
          ENDIF
C
C         NUMERO DE LA 1ERE ENTITE FAISANT REFERENCE A CETTE FAMILLE
          IENT = NUFACR(IAUX)
C
C         NB ET NOMS+NUMS DES GROUPES ASSOCIES A LA FAMILLE
          CALL NOMGFA ( NOMGEN, NBGROU, TABAUX(1+(IENT-1)*NBEC),
     &                  NOGRFA, NBGNOF )
C
C         NOM DE LA FAMILLE : ON LE CONSTRUIT A PARTIR DES NOMS
C         DE GROUPES
C
          JAUX = IAUX - 1
          CALL MDNOFA ( NUMFAM, NOGRFA, NBGNOF, JAUX, NOFAEX, NOMFAM )
C
C 2.3.2. ==> INFORMATION EVENTUELLE
C
          IF ( INFMED.GE.2 ) THEN
            JAUX = 0
            DO 232 , IENT = 1 , NBRENT
              IF ( NUFAEN(IENT).EQ.NUMFAM ) THEN
                JAUX = JAUX + 1
              ENDIF
  232       CONTINUE
            IF ( TYPENT.EQ.TYGENO ) THEN
              KAUX = 0
            ELSE
              KAUX = JAUX
              JAUX = 0
            ENDIF
            CALL DESGFA ( TYPENT+1, NUMFAM, NOMFAM,
     &                    NBGNOF, NOGRFA, NATT, TBAUX,
     &                    JAUX, KAUX,
     &                    IFM, CODRET )
          ENDIF
C
C 2.3.3. ==> ECRITURE DES CARACTERISTIQUES DE LA FAMILLE
C
          CALL MFFAMC ( FID, NOMAMD, NOMFAM, NUMFAM,
     &                  IAUX, IAUX, K200, NATT,
     &                  NOGRFA, NBGNOF, CODRET )
          IF ( CODRET.NE.0 ) THEN
            SAUX08='MFFAMC  '
            CALL U2MESG('F','DVP_97',1,SAUX08,1,CODRET,0,0.D0)
          ENDIF
C
 23    CONTINUE
C
      ENDIF
C
C====
C 3. ECRITURE DE LA TABLE DES NUMEROS DE FAMILLES DES ENTITES
C    CELA SE FAIT PAR TYPE. ON REUTILISE LES VECTEURS CONTENANT
C    LES NUMEROS D'ENTITES/TYPE
C====
C
C 3.1. ==> ECRITURE DANS LE CAS DES NOEUDS
C
      IF ( TYPENT.EQ.TYGENO ) THEN
C
        CALL MFFAME ( FID, NOMAMD, NUFAEN, NBRENT,
     &                EDNOEU, TYGENO, CODRET )
C
        IF ( CODRET.NE.0 ) THEN
          SAUX08='MFFAME  '
          CALL U2MESG('F','DVP_97',1,SAUX08,1,CODRET,0,0.D0)
        ENDIF
C
C 3.2. ==> ECRITURE DANS LE CAS DES MAILLES : IL FAUT PASSER PAR LA
C          RENUMEROTATION ASTER-MED
C
      ELSE
C
        DO 32 , ITYP = 1 , NTYMAX
C
          IF ( NMATYP(ITYP).NE.0 ) THEN
C
C           RECUPERATION DU TABLEAU DES RENUMEROTATIONS
C
            CALL JEVEUO('&&'//PREFIX//'.NUM.'//NOMTYP(ITYP),'L',KAUX)
C
C           CREATION VECTEUR NUMEROS DE FAMILLE POUR LES MAILLES / TYPE
C
            DO 321 , IAUX = 1 , NMATYP(ITYP)
              TABAUX(IAUX) = NUFAEN(ZI(KAUX-1+IAUX))
  321       CONTINUE
C
            CALL MFFAME ( FID, NOMAMD, TABAUX, NMATYP(ITYP),
     &                    EDMAIL, TYPGEO(ITYP), CODRET )
C
            IF ( CODRET.NE.0 ) THEN
              SAUX08='MFFAME  '
              CALL U2MESG('F','DVP_97',1,SAUX08,1,CODRET,0,0.D0)
            ENDIF
C
          ENDIF
C
   32   CONTINUE
C
      ENDIF
C
      IF ( NIVINF.GE.2 ) THEN
C
        WRITE (IFM,4001) NOMPRO
 4001 FORMAT(/,'FIN DU PROGRAMME ',A,/,60('-'))
C
      ENDIF
C
      END
