      SUBROUTINE IRCMEC ( IDFIMD, NOMAMD,
     >                    NOCHMD, NOMPRF,
     >                    NUMPT, INSTAN, UNIINS, NUMORD,
     >                    NTVALE,
     >                    NCMPVE, NBENTY, NBREPG, NVALEC,
     >                    TYPENT, TYPGEO,
     >                    CODRET )
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF PREPOST  DATE 16/10/2002   AUTEUR GNICOLAS G.NICOLAS 
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.      
C ======================================================================
C RESPONSABLE GNICOLAS G.NICOLAS
C_______________________________________________________________________
C     ECRITURE D'UN CHAMP -  FORMAT MED - ECRITURE
C        -  -       -               -     --
C_______________________________________________________________________
C     ENTREES :
C       IDFIMD : IDENTIFIANT DU FICHIER MED
C       NOMAMD : NOM DU MAILLAGE MED
C       NOCHMD : NOM MED DU CHAMP A ECRIRE
C       NOMPRF : NOM MED DU PROFIL ASSOCIE AU CHAMP
C       NUMPT  : NUMERO DE PAS DE TEMPS
C       INSTAN : VALEUR DE L'INSTANT A ARCHIVER
C       UNIINS : UNITE DE L'INSTANT A ARCHIVER
C       NUMORD : NUMERO D'ORDRE DU CHAMP
C       NTVALE : SD DES VALEURS EN MODE ENTRELACE
C       NCMPVE : NOMBRE DE COMPOSANTES VALIDES EN ECRITURE
C       NBENTY : NOMBRE D'ENTITES DU TYPE CONSIDERE
C       NBREPG : NOMBRE DE POINTS DE GAUSS
C       NVALEC : NOMBRE DE VALEURS A ECRIRE EFFECTIVEMENT
C       TYPENT : TYPE D'ENTITE MED DU CHAMP A ECRIRE
C       TYPGEO : TYPE GEOMETRIQUE MED DU CHAMP A ECRIRE
C     SORTIES:
C       CODRET : CODE DE RETOUR (0 : PAS DE PB, NON NUL SI PB)
C_______________________________________________________________________
C
      IMPLICIT NONE
C
C 0.1. ==> ARGUMENTS
C
      CHARACTER*8 UNIINS
      CHARACTER*32 NOCHMD, NOMPRF
      CHARACTER*(*) NTVALE
      CHARACTER*(*) NOMAMD
C
      INTEGER IDFIMD 
      INTEGER NUMPT, NUMORD
      INTEGER NCMPVE, NBENTY, NBREPG, NVALEC
      INTEGER TYPENT, TYPGEO
C
      REAL*8 INSTAN
C
      INTEGER CODRET
C
C 0.2. ==> COMMUNS
C
C --------------- COMMUNS NORMALISES  JEVEUX  --------------------------
      REAL*8       ZR
      COMMON /RVARJE/ZR(1)
C     -----  FIN  COMMUNS NORMALISES  JEVEUX --------------------------
C
C 0.3. ==> VARIABLES LOCALES
C
      CHARACTER*6 NOMPRO
      PARAMETER ( NOMPRO = 'IRCMEC' )
C
      CHARACTER*32 EDNOPF
C                         12345678901234567890123456789012
      PARAMETER ( EDNOPF='                                ' )
      INTEGER EDECRI
      PARAMETER (EDECRI=1)
      INTEGER EDFUIN
      PARAMETER (EDFUIN=0)
      INTEGER EDALL
      PARAMETER (EDALL=0)
      INTEGER EDNOPT
      PARAMETER (EDNOPT=-1)
      INTEGER EDNOPG
      PARAMETER (EDNOPG=1)
C
      INTEGER ADVALE
      INTEGER IFM, NIVINF
      INTEGER IAUX
C
      CHARACTER*8 SAUX08
      CHARACTER*14 SAUX14
      CHARACTER*35 SAUX35
C
C====
C 1. PREALABLES
C====
C
C 1.1. ==> RECUPERATION DU NIVEAU D'IMPRESSION
C
      CALL INFMAJ
      CALL INFNIV ( IFM, NIVINF )
C
C 1.2. ==> ADRESSE
C
      CALL JEVEUO ( NTVALE, 'L', ADVALE )
C
C 1.3. ==> INFORMATION
C
      IF ( NIVINF.GT.1 ) THEN
        WRITE (IFM,13001) NOMPRO, NBREPG, TYPENT, TYPGEO
        DO 13 , IAUX = 1 , NCMPVE
          WRITE (IFM,13002)
     >    '. PREMIERE ET DERNIERE VALEURS A ECRIRE POUR LA COMPOSANTE',
     >    IAUX, ' : ',ZR(ADVALE+IAUX-1),
     >    ZR(ADVALE+(NVALEC*NBREPG-1)*NCMPVE+IAUX-1)
   13   CONTINUE
      ENDIF
13001 FORMAT(A6,' : ',/
     >       '. NBREPG =',I4,', TYPENT =',I4,', TYPGEO =',I4)
13002 FORMAT(A,I3,A3,5G16.6)
C
C====
C 2. ECRITURE DES VALEURS
C    LE TABLEAU DE VALEURS EST UTILISE AINSI :
C        TV(NCMPVE,NBSP,NBPG,NVALEC)
C    TV(1,1,1,1), TV(2,1,1,1), ..., TV(NCMPVE,1,1,1),
C    TV(1,2,1,1), TV(2,2,1,1), ..., TV(NCMPVE,2,1,1), 
C            ...     ...     ...
C    TV(1,NBSP,NBPG,NVALEC), TV(2,NBSP,NBPG,NVALEC), ... ,
C                                      TV(NCMPVE,NBSP,NBPG,NVALEC)
C    C'EST CE QUE MED APPELLE LE MODE ENTRELACE
C    REMARQUE : LE 6-EME ARGUMENT DE EFCHRE EST LE NOMBRE DE VALEURS
C               C'EST LE PRODUIT DU NOMBRE TOTAL D'ENTITES DU TYPE EN
C               COURS PAR LE PRODUIT DES NOMBRES DE POINTS DE GAUSS
C               ET DE SOUS-POINT.
C               ATTENTION, CE N'EST DONC PAS LE NOMBRE DE VALEURS
C               REELLEMENT ECRITES MAIS PLUTOT LE NOMBRE MAXIMUM QU'ON
C               POURRAIT ECRIRE.
C====
CGN      PRINT *,'TABLEAU REELLEMENT ECRIT'
CGN      PRINT 1789,(ZR(IAUX),
CGN     >  IAUX=ADVALE,ADVALE+NVALEC*NBREPG*NCMPVE-1)
CGN 1789  FORMAT(10G12.5)
C
C               12345678901235
      SAUX14 = '. ECRITURE DES'
C               12345678901234567890123456789012345
      SAUX35 = ' VALEURS POUR LE NUMERO D''ORDRE : '
      WRITE (IFM,20001) SAUX14, NCMPVE, NBENTY, SAUX35, NUMORD
      IF ( NUMPT.NE.EDNOPT ) THEN
        WRITE (IFM,20002) NUMPT, INSTAN
      ENDIF
      IF ( NOMPRF.EQ.EDNOPF ) THEN
        WRITE (IFM,20003)
      ELSE
        WRITE (IFM,20004) NOMPRF
      ENDIF
C
20001 FORMAT(A14,I3,' * ',I8,A35,I5)
20002 FORMAT(5X,'( PAS DE TEMPS NUMERO :',I5,', T = ',G13.5,' )')
20003 FORMAT(2X,'PAS DE PROFIL')
20004 FORMAT(2X,'NOM DU PROFIL : ',A)
C
      IF ( NBREPG.EQ.EDNOPG ) THEN
        IAUX = NBENTY
      ELSE
        IAUX = NBENTY*NBREPG
      ENDIF
      CALL EFCHRE ( IDFIMD, NOMAMD, NOCHMD, ZR(ADVALE),
     >              EDFUIN, IAUX, NBREPG, EDALL, NOMPRF, EDECRI,
     >              TYPENT, TYPGEO,
     >              NUMPT, UNIINS, INSTAN, NUMORD,
     >              CODRET )
C
      IF ( CODRET.NE.0 ) THEN
        CALL CODENT ( CODRET,'G',SAUX08 )
        CALL UTMESS ('F',NOMPRO,'MED: ERREUR EFCHRE NUMERO '//SAUX08)
      ENDIF
C
      END
