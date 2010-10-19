      SUBROUTINE LRCMPR ( IDFIMD, NOMPRF,
     &                    NTPROA, LGPROA,
     &                    CODRET )
C_____________________________________________________________________
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF PREPOST  DATE 19/10/2010   AUTEUR COURTOIS M.COURTOIS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2002  EDF R&D                  WWW.CODE-ASTER.ORG
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
C ======================================================================
C     LECTURE D'UN CHAMP - FORMAT MED - PROFIL
C     -    -       -              -     --
C-----------------------------------------------------------------------
C      ENTREES:
C       IDFIMD : IDENTIFIANT DU FICHIER MED
C       NOMPRF : NOM MED DU PROFIL A LIRE
C      SORTIES:
C       NTPROA : TABLEAU QUI CONTIENT LE PROFIL ASTER
C       LGPROA : LONGUEUR DU PROFIL ASTER
C       CODRET : CODE DE RETOUR (0 : PAS DE PB, NON NUL SI PB)
C_____________________________________________________________________
C
      IMPLICIT NONE
C
C 0.1. ==> ARGUMENTS
C
      INTEGER IDFIMD
      INTEGER LGPROA
      INTEGER CODRET
C
      CHARACTER*32 NOMPRF
      CHARACTER*(*) NTPROA
C
C 0.2. ==> COMMUNS
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX --------------------------
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
C     -----  FIN  COMMUNS NORMALISES  JEVEUX --------------------------
C
C 0.3. ==> VARIABLES LOCALES
C
      CHARACTER*6 NOMPRO
      CHARACTER*8 SAUX08
      PARAMETER ( NOMPRO = 'LRCMPR' )
C
      INTEGER IFM, NIVINF
C
      INTEGER ADPROA, ADPROM
      INTEGER LGPROM
      INTEGER IAUX
C
      CHARACTER*24 NTPROM
C
C====
C 1. PREALABLES
C====
C
C 1.1. ==> RECUPERATION DU NIVEAU D'IMPRESSION
C
      CALL INFNIV ( IFM, NIVINF )
C
      IF ( NIVINF.GT.1 ) THEN
        WRITE (IFM,1001) 'DEBUT DE '//NOMPRO
      ENDIF
 1001 FORMAT(/,10('='),A,10('='),/)
C
C 1.2. ==> NOMS DES TABLEAUX DE TRAVAIL
C               12   345678   9012345678901234
      NTPROM = '&&'//NOMPRO//'.PROFIL_MED     '
C
C====
C 2. NOMBRE DE VALEURS LIEES AU PROFIL
C====
C
      CALL MFNPFL ( IDFIMD, NOMPRF, LGPROM, CODRET )
      IF ( CODRET.NE.0 ) THEN
        SAUX08='MFNPFL  '
        CALL U2MESG('F','DVP_97',1,SAUX08,1,CODRET,0,0.D0)
      ENDIF
C
      IF ( NIVINF.GT.1 ) THEN
        WRITE (IFM,4101) NOMPRF, LGPROM
      ENDIF
 4101 FORMAT('. LECTURE DU PROFIL : ',A,
     &     /,'... LONGUEUR : ',I8)
C
C====
C 3. LECTURE DES VALEURS DU PROFIL MED
C====
C
      CALL WKVECT ( NTPROM, 'V V I', LGPROM, ADPROM )
C
      CALL MFPFLL ( IDFIMD, ZI(ADPROM), LGPROM, NOMPRF, CODRET )
      IF ( CODRET.NE.0 ) THEN
        SAUX08='MFPFLL  '
        CALL U2MESG('F','DVP_97',1,SAUX08,1,CODRET,0,0.D0)
      ENDIF
C
      IF ( NIVINF.GT.1 ) THEN
        WRITE (IFM,4201) ZI(ADPROM),ZI(ADPROM+LGPROM-1)
      ENDIF
 4201 FORMAT('... 1ERE ET DERNIERE VALEURS : ',2I8)
C
C====
C 4. TRANSFERT EN UN PROFIL ASTER
C====
C          EN FAIT, DANS LE CAS DES NOEUDS, IL Y A IDENTITE ENTRE LES
C          DEUX CAR ON NE RENUMEROTE PAS LES NOEUDS (CF IRMMNO)
C
      LGPROA = LGPROM
      CALL WKVECT ( NTPROA, 'V V I', LGPROA, ADPROA )
C
      DO 41 , IAUX = 0 , LGPROM-1
        ZI(ADPROA+IAUX) = ZI(ADPROM+IAUX)
   41 CONTINUE
C
      CALL JEDETC('V','&&'//NOMPRO,1)
C
      IF ( NIVINF.GT.1 ) THEN
        WRITE (IFM,1001) 'FIN DE '//NOMPRO
      ENDIF
C
      END
