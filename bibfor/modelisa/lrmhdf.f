      SUBROUTINE LRMHDF ( NOMAMD,
     >                    NOMU,NOMMAI,NOMNOE,COOVAL,COODSC,COOREF,
     >                    GRPNOE,GRPMAI,CONNEX,TITRE,TYPMAI,ADAPMA,
     >                    IFM,NROFIC,NIVINF,INFMED,
     >                    NBNOEU, NBMAIL, NBCOOR )
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 16/10/2002   AUTEUR GNICOLAS G.NICOLAS 
C RESPONSABLE GNICOLAS G.NICOLAS
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
C     LECTURE DU MAILLAGE - FORMAT MED
C     -    -     -                 ---
C-----------------------------------------------------------------------
C     ENTREES :
C        NOMAMD : NOM MED DU MAILLAGE A LIRE
C                 SI ' ' : ON LIT LE PREMIER MAILLAGE DU FICHIER 
C        NOMU   : NOM ASTER SOUS LEQUEL LE MAILLAGE SERA STOCKE
C ...
C     SORTIES:
C        NBNOEU : NOMBRE DE NOEUDS
C ...
C     ------------------------------------------------------------------
C
      IMPLICIT NONE
C
C 0.1. ==> ARGUMENTS
C
C     IN
C
      INTEGER IFM, NIVINF
      INTEGER NROFIC, INFMED
      CHARACTER*32 NOMAMD
      CHARACTER*24 COOVAL, COODSC, COOREF, GRPNOE, GRPMAI, CONNEX
      CHARACTER*24 TITRE,  NOMMAI, NOMNOE, TYPMAI 
      CHARACTER*24 ADAPMA
      CHARACTER*8 NOMU 
C
C     OUT
C
      INTEGER NBNOEU, NBMAIL, NBCOOR
C
C 0.2. ==> COMMUNS
C
C 0.3. ==> VARIABLES LOCALES
C
      CHARACTER*6 NOMPRO
      PARAMETER ( NOMPRO = 'LRMHDF' )
C
      INTEGER NTYMAX
      PARAMETER (NTYMAX = 28)
      INTEGER EDLECT
      PARAMETER (EDLECT=0)
C
      INTEGER NMATYP(NTYMAX), NITTYP(NTYMAX)
      INTEGER NNOTYP(NTYMAX), TYPGEO(NTYMAX)
      INTEGER RENUMD(NTYMAX)
      INTEGER NBTYP
      INTEGER NDIM, FID, CODRET
      INTEGER NBNOMA
      INTEGER NBLTIT, NBGRNO, NBGRMA
C
      CHARACTER*6 SAUX06
      CHARACTER*8 NOMTYP(NTYMAX)
      CHARACTER*8 SAUX08
      CHARACTER*200 NOFIMD
      CHARACTER*200 DESCFI
C
      LOGICAL EXISTM
C
C     ------------------------------------------------------------------
      CALL JEMARQ ( )
C
C====
C 1. PREALABLES
C====
C
      IF ( NIVINF.GT.1 ) THEN
        CALL UTFLSH (CODRET)
        WRITE (IFM,1001) 'DEBUT DE '//NOMPRO
      ENDIF
 1001 FORMAT(/,10('='),A,10('='),/)
C
C 1.1. ==> NOM DU FICHIER MED
C
      CALL CODENT ( NROFIC, 'G', SAUX08 )
      NOFIMD = 'fort.'//SAUX08
      IF ( NIVINF.GT.1 ) THEN
        WRITE (IFM,*) NOMPRO, ' : NOM DU FICHIER MED : ', NOFIMD
      ENDIF
C
C 1.2. ==> VERIFICATION DE LA BONNE VERSION DU FICHIER MED
C
      CALL EFFOCO ( NOFIMD, CODRET )
      IF ( CODRET.NE.0 ) THEN
        CALL UTDEBM ( 'A', NOMPRO, 'FICHIER ' )
        CALL UTIMPK ( 'S', 'MED : ', 1, NOFIMD )
        CALL UTIMPK ( 'L', 'MAILLAGE : ', 1, NOMAMD )
        CALL UTIMPI ( 'L', 'ERREUR EFFOCO NUMERO ', 1, CODRET )
        CALL UTFINM ()
        CALL UTMESS ( 'F', NOMPRO, 'SOIT LE FICHIER N''EXISTE PAS,'//
     >             ' SOIT C''EST UNE MAUVAISE VERSION DE MED.' )
      ENDIF
C
C 1.3. ==> VERIFICATION DE L'EXISTENCE DU MAILLAGE A LIRE
C
C 1.3.1. ==> C'EST LE PREMIER MAILLAGE DU FICHIER
C            ON RECUPERE SON NOM ET SA DIMENSION.
C
      IF ( NOMAMD.EQ.' ' ) THEN
C
        CALL MDEXPM ( NOFIMD, NOMAMD, EXISTM, NDIM, CODRET )
        IF ( .NOT.EXISTM ) THEN
          CALL UTMESS ( 'F', NOMPRO, 'PAS DE MAILLAGE DANS '//NOFIMD )
        ENDIF
C
C 1.3.2. ==> C'EST UN MAILLAGE DESIGNE PAR UN NOM
C            ON RECUPERE SA DIMENSION.
C
      ELSE
C
        CALL MDEXMA ( NOFIMD, NOMAMD, EXISTM, NDIM, CODRET )
        IF ( .NOT.EXISTM ) THEN
          CALL UTMESS ( 'F', NOMPRO,
     >   'LE MAILLAGE '//NOMAMD//' EST INCONNU DANS '//NOFIMD )
        ENDIF
C
      ENDIF
C
      NBCOOR = NDIM
C
C====
C 2. DEMARRAGE
C====
C
C 2.1. ==> OUVERTURE FICHIER MED EN LECTURE
C
      CALL EFOUVR ( FID, NOFIMD, EDLECT, CODRET )
      IF ( CODRET.NE.0 ) THEN
        CALL UTDEBM ( 'A', NOMPRO, 'FICHIER ' )
        CALL UTIMPK ( 'S', 'MED : ', 1, NOFIMD )
        CALL UTIMPK ( 'L', 'MAILLAGE : ', 1, NOMAMD )
        CALL UTIMPI ( 'L', 'ERREUR EFOUVR NUMERO ', 1, CODRET )
        CALL UTFINM ()
        CALL UTMESS ( 'F', NOMPRO, 'PROBLEME A L OUVERTURE DU FICHIER' )
      ENDIF
C
C 2.2. ==> . RECUPERATION DES NB/NOMS/NBNO/NBITEM DES TYPES DE MAILLES
C            DANS CATALOGUE
C          . RECUPERATION DES TYPES GEOMETRIE CORRESPONDANT POUR MED
C          . VERIF COHERENCE AVEC LE CATALOGUE
C
      CALL LRMTYP ( NDIM, NBTYP, NOMTYP,
     >              NNOTYP, NITTYP, TYPGEO, RENUMD )
C
C====
C 3. DESCRIPTION
C====
C
      CALL LRMDES ( FID,
     >              NBLTIT, DESCFI, TITRE )
C
C====
C 4. DIMENSIONNEMENT
C====
C
      CALL LRMMDI ( FID, NOMAMD,
     >              TYPGEO, NOMTYP, NNOTYP,
     >              NMATYP,
     >              NBNOEU, NBMAIL, NBNOMA,
     >              DESCFI, ADAPMA )
C
C====
C 5. LES NOEUDS
C====
C
      CALL LRMMNO ( FID, NOMAMD, NDIM, NBNOEU,
     >              NOMU, NOMNOE, COOVAL, COODSC, COOREF )
C
C====
C 6. LES MAILLES
C====
C
      SAUX06 = NOMPRO
C
      CALL LRMMMA ( FID, NOMAMD, NDIM, NBMAIL, NBNOMA,
     >              NBTYP, TYPGEO, NOMTYP, NITTYP, NNOTYP, RENUMD,
     >              NMATYP,
     >              NOMMAI, CONNEX, TYPMAI,
     >              SAUX06,
     >              INFMED )
C
C====
C 7. LES FAMILLES
C====
C
      SAUX06 = NOMPRO
C
      CALL LRMMFA ( FID, NOMAMD,
     >              NBNOEU, NBMAIL,
     >              GRPNOE, GRPMAI, NBGRNO, NBGRMA,
     >              TYPGEO, NOMTYP, NMATYP,
     >              SAUX06,
     >              INFMED )
C
C====
C 8. LES EQUIVALENCES
C====
C
      CALL LRMMEQ ( FID, NOMAMD,
     >              INFMED )
C
C====
C 9. FIN
C====
C
C 9.1. ==> FERMETURE FICHIER
C
      CALL EFFERM ( FID, CODRET )
      IF ( CODRET.NE.0 ) THEN
        CALL UTDEBM ( 'A', NOMPRO, 'FICHIER ' )
        CALL UTIMPK ( 'S', 'MED : ', 1, NOFIMD )
        CALL UTIMPK ( 'L', 'MAILLAGE : ', 1, NOMAMD )
        CALL UTIMPI ( 'L', 'ERREUR EFFERM NUMERO ', 1, CODRET )
        CALL UTFINM ()
        CALL UTMESS ( 'F', NOMPRO, 'PROBLEME A LA FERMETURE DU FICHIER')
      ENDIF
C
C 9.2. ==> IMPRESSION DES OBJETS SUR LES FICHIERS RESULTAT ET MESSAGE
C
      CALL LRMIMP ( IFM, NIVINF, NDIM, NOMU, TITRE,
     >              GRPNOE, GRPMAI, NOMNOE, NOMMAI, CONNEX, COOVAL,
     >              NBLTIT, NBNOEU, NBMAIL, NBGRNO, NBGRMA,
     >              TYPMAI, NBTYP, NNOTYP, NOMTYP, NMATYP )
C
C 9.3. ==> MENAGE
C
      CALL JEDETC ('V','&&'//NOMPRO,1)
C
      CALL JEDEMA ( )
C
      IF ( NIVINF.GT.1 ) THEN
        WRITE (IFM,1001) 'FIN DE '//NOMPRO
        CALL UTFLSH (CODRET)
      ENDIF
C
      END
