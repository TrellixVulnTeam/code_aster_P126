      SUBROUTINE MERESO ( NRORES, NBPASE, INPSCO,
     >                    MODELE, MATE, CARELE, FOMULT, LISCHA,
     >                    ITPS, PARTPS,
     >                    NUMEDD, VECASS,
     >                    ASSMAT, SOLVEU, MATASS, MAPREC,
     >                    BASE, TPS1, TPS2, TPS3 )
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 14/03/2006   AUTEUR MABBAS M.ABBAS 
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
C ----------------------------------------------------------------------
C     MECANIQUE STATIQUE - RESOLUTION
C     * *                  ****
C ----------------------------------------------------------------------
C     BUT:  FAIRE UN CALCUL DE MECANIQUE STATIQUE : K(T)*U = F(T)
C           A UN INSTANT DONNE
C ----------------------------------------------------------------------
C IN  NRORES  : NUMERO DE LA RESOLUTION
C               0 : CALCUL STANDARD
C               >0 : CALCUL DE LA DERIVEE NUMERO NRORES
C IN  NBPASE  : NOMBRE DE PARAMETRES SENSIBLES
C IN  INPSCO  : STRUCTURE CONTENANT LA LISTE DES NOMS
C IN  MODELE  : NOM DU MODELE
C IN  MATE    : NOM DU MATERIAU
C IN  CARELE  : NOM D'1 CARAC_ELEM
C IN  FOMULT  : LISTE DES FONCTIONS MULTIPLICATRICES
C IN  LISCHA  : INFORMATION SUR LES CHARGEMENTS
C IN  ITPS    : NUMERO DU PAS DE TEMPS
C IN  PARTPS  : PARAMETRES TEMPORELS
C IN  NUMEDD  : PROFIL DE LA MATRICE
C IN  VECASS  : SECOND MEMBRE ASSEMBLE
C IN  ASSMAT  : BOOLEEN POUR LE CALCUL DE LA MATRICE
C IN  SOLVEU  : METHODE DE RESOLUTION 'LDLT' OU 'GCPC'
C IN/OUT  MAPREC  : MATRICE PRECONDITIONNEE
C IN  BASE    : BASE DE TRAVAIL
C IN/OUT TPS1,2,3 : TEMPS DE CALCUL
C   -------------------------------------------------------------------
C     ASTER INFORMATIONS:
C       30/01/04 (OB): MODIF CRITER POUR SOLVEUR FETI.
C-----------------------------------------------------------------------
C
      IMPLICIT NONE

C 0.1. ==> ARGUMENTS

      INTEGER NRORES, NBPASE, ITPS
      LOGICAL ASSMAT
      CHARACTER*1 BASE
      CHARACTER*19 LISCHA, SOLVEU
      CHARACTER*19 VECASS
      CHARACTER*19 MATASS, MAPREC
      CHARACTER*24 MODELE, CARELE, FOMULT
      CHARACTER*24 NUMEDD
      CHARACTER*(*) INPSCO
      CHARACTER*(*) MATE

      REAL*8 PARTPS(*)
      REAL*8 TPS1(4), TPS2(4), TPS3(4)

C 0.2. ==> COMMUNS

C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER            ZI
      COMMON  / IVARJE / ZI(1)
      REAL*8             ZR
      COMMON  / RVARJE / ZR(1)
      COMPLEX*16         ZC
      COMMON  / CVARJE / ZC(1)
      LOGICAL            ZL
      COMMON  / LVARJE / ZL(1)
      CHARACTER*8        ZK8
      CHARACTER*16               ZK16
      CHARACTER*24                        ZK24
      CHARACTER*32                                 ZK32
      CHARACTER*80                                          ZK80
      COMMON  / KVARJE / ZK8(1), ZK16(1), ZK24(1), ZK32(1), ZK80(1)
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------

C 0.3. ==> VARIABLES LOCALES

      CHARACTER*6 NOMPRO
      PARAMETER ( NOMPRO = 'MERESO' )
      INTEGER JCRI, JCRR, JCRK
      INTEGER JPARA, IAINST, ISLVK
      INTEGER IRET
      INTEGER IAUX, JAUX, JINF, NCHAR, NUMCHT
      INTEGER IFM, NIV
      INTEGER TYPESE
      CHARACTER*8 K8BID
      CHARACTER*8 NOPASE
      CHARACTER*19 CHDEPL, CHSOL
      CHARACTER*24 CNCHCI,INFOCH
      CHARACTER*24 CRITER
      CHARACTER*24 RESULT
      CHARACTER*24 VDEPL, VDEPLM, VDEPLP
      CHARACTER*24 VAPRIN, REPRIN
      CHARACTER*24 STYPSE

C DEB-------------------------------------------------------------------
C====
C 1. PREALABLES
C====

C-----RECUPERATION DU NIVEAU D'IMPRESSION

      CALL INFNIV(IFM,NIV)

C 1.2. ==> NOM DES STRUCTURES

C 1.2.1. ==> FIXES

      CALL JEVEUO(SOLVEU//'.SLVK','L',ISLVK)

C               12   345678   9012345678901234
      CHSOL  = '&&'//NOMPRO//'_SOLUTION  '
      IF (ZK24(ISLVK).EQ.'FETI') THEN
        CRITER = '&&'//NOMPRO//'_RESFET_FETI     '
      ELSE
        CRITER = '&&'//NOMPRO//'_RESGRA_GCPC     '       
      ENDIF     

C 1.2.2. ==> ASSOCIEES AUX DERIVATIONS
C               3. LE NOM DU RESULTAT
C               4. LA VARIABLE PRINCIPALE A L'INSTANT N
C               5. LA VARIABLE PRINCIPALE A L'INSTANT N-1
C               6. LA VARIABLE PRINCIPALE A L'INSTANT N+1

      IAUX = NRORES

      JAUX = 1
      CALL PSNSLE ( INPSCO, IAUX, JAUX, NOPASE )
      JAUX = 3
      CALL PSNSLE ( INPSCO, IAUX, JAUX, RESULT )
      JAUX = 4
      CALL PSNSLE ( INPSCO, IAUX, JAUX, VDEPL )
      JAUX = 5
      CALL PSNSLE ( INPSCO, IAUX, JAUX, VDEPLM )
      JAUX = 6
      CALL PSNSLE ( INPSCO, IAUX, JAUX, VDEPLP )

      IF  ( NRORES.GT.0 ) THEN
        IAUX = 0
        JAUX = 3
        CALL PSNSLE ( INPSCO, IAUX, JAUX, REPRIN )
        JAUX = 4
        CALL PSNSLE ( INPSCO, IAUX, JAUX, VAPRIN )
      ENDIF

C====
C 2. REPERAGE DU TYPE DE DERIVATION
C====

      IF ( NRORES.GT.0 ) THEN
        CALL METYSE ( NBPASE, INPSCO, NOPASE, TYPESE, STYPSE )
      ELSE
        TYPESE = 0
        STYPSE = ' '
      ENDIF

      IF (TYPESE.EQ.3) THEN

        INFOCH = LISCHA//'.INFC'
        CALL JEVEUO (INFOCH,'L',JINF)
        NCHAR = ZI(JINF)
        NUMCHT = ZI(JINF-1+2+2*NCHAR)

        IF (NUMCHT.GT.0) THEN
           CALL UTMESS('A','MERESO',
     &   'LA SENSIBILITE EN MECA NE FONCTIONNE PAS ENCORE'//
     &   ' AVEC UN CHARGEMENT THERMIQUE')
           GO TO 99
        ENDIF

      ENDIF

C====
C 3. MATRICE ET SECOND MEMBRE
C====

      CALL MEACMV ( MODELE, MATE, CARELE, FOMULT, LISCHA,
     >              ITPS, PARTPS,
     >              NUMEDD, ASSMAT, SOLVEU,
     >              VECASS, MATASS, MAPREC, CNCHCI,
     >              TYPESE, STYPSE, NOPASE, VAPRIN, REPRIN,
     >              BASE, TPS1, TPS2, TPS3 )

C====
C 4. RESOLUTION AVEC VECASS COMME SECOND MEMBRE
C====

      CALL RESOUD ( MATASS, MAPREC, VECASS, SOLVEU, CNCHCI,
     >              'V', CHSOL, CRITER)

C 5.1. ==> NETTOYAGE DU CHAMP CINEMATIQUE CNCHCI QUI EST RECREE A 
C          CHAQUE FOIS
      CALL DETRSD('CHAMP_GD',CNCHCI)

C====
C 5. SAUVEGARDE DE LA SOLUTION
C====

C 5.1. ==> SAUVEGARDE DU CHAMP SOLUTION CHSOL DANS VDEPL
      CALL COPISD ( 'CHAMP_GD','V',CHSOL(1:19),VDEPL(1:19) )

C 5.2. ==> DESTRUCTION DU CHAMP SOLUTION CHSOL

      CALL DETRSD ('CHAMP_GD',CHSOL)

C 5.3. ==> STOCKAGE DE LA SOLUTION, VDEPL, DANS LA STRUCTURE DE RESULTAT
C          EN TANT QUE CHAMP DE DEPLACEMENT A L'INSTANT COURANT
C
      WRITE (IFM,1000) 'DEPL', PARTPS(1), ITPS

      CALL RSEXCH(RESULT,'DEPL',ITPS,CHDEPL,IRET)
      IF ( IRET .LE. 100 ) THEN
C     NETTOYAGE DES SCORIES DE SD FETI, NORMALEMENT INUTILE, MAIS ON
C     NE SAIT JAMAIS !
        CALL ASSDE2(VDEPL)
        CALL COPISD('CHAMP_GD','G',VDEPL(1:19),CHDEPL(1:19))
        CALL RSNOCH(RESULT,'DEPL',ITPS,' ')
      ENDIF

C*** INST

      CALL RSADPA (RESULT, 'E', 1, 'INST', ITPS,0,IAINST,K8BID)
      ZR(IAINST) = PARTPS(1)

C*** METHODE, RENUM, ...

      CALL RSADPA (RESULT, 'E', 1, 'METHODE', ITPS,0,JPARA,K8BID)
      IF ( ZK24(ISLVK)(1:8) .EQ. 'MULT_FRO' ) THEN
         ZK16(JPARA) = 'MULT_FRONT'
      ELSE
         ZK16(JPARA) = ZK24(ISLVK)(1:16)
      ENDIF
      CALL RSADPA (RESULT, 'E', 1, 'RENUM', ITPS,0,JPARA,K8BID)
      ZK16(JPARA) = ZK24(ISLVK+3)(1:16)
      CALL RSADPA (RESULT, 'E', 1, 'STOCKAGE', ITPS,0,JPARA,K8BID)
      IF ( ZK24(ISLVK)(1:4) .EQ. 'LDLT' ) THEN
         ZK16(JPARA) = 'LIGN_CIEL'
      ELSE
         ZK16(JPARA) = 'MORSE'
      ENDIF

C*** LES CRITERES

      CALL JEEXIN ( CRITER(1:19)//'.CRTI', IRET )
      IF ( IRET .NE. 0 ) THEN
        CALL JEVEUO(CRITER(1:19)//'.CRTI','L',JCRI)
        CALL JEVEUO(CRITER(1:19)//'.CRTR','L',JCRR)
        CALL JEVEUO(CRITER(1:19)//'.CRDE','L',JCRK)
        CALL RSADPA (RESULT, 'E', 1, ZK16(JCRK), ITPS,0,JPARA,K8BID)
        ZI(JPARA) = ZI(JCRI)
      CALL RSADPA (RESULT, 'E', 1, ZK16(JCRK+1), ITPS,0,JPARA,K8BID)
        ZR(JPARA) = ZR(JCRR)
      ENDIF
      CALL UTTCPU(3, 'FIN', 4, TPS3)

 1000 FORMAT(1P,3X,'CHAMP STOCKE : ',A16,' INSTANT : ',1PE12.5,
     &         '  NUMERO D''ORDRE : ',I5)

   99 CONTINUE

      END
