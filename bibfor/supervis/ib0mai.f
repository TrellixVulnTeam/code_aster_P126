      SUBROUTINE IB0MAI ( CMDUSR , IER )
      IMPLICIT REAL*8 (A-H,O-Z)
      CHARACTER*(*)       CMDUSR
      INTEGER                      IER
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF SUPERVIS  DATE 10/12/2001   AUTEUR VABHHTS J.PELLET 
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
C     MAIN  D'ANALYSE DE LA COMMANDE DE DEMARRAGE
C     ------------------------------------------------------------------
C IN  CMDUSR NOM INTERNE DE L'UNITE DES COMMANDES UTILISATEURS
C OUT IER  CODE RETOUR
C      1   PROCEDURE "DEBUT" ET "POURSUITE" NON TROUVEES
C      2   ERREUR(S) DANS LA COMMANDE  "DEBUT" OU "POURSUITE"
C      0   SINON
C     ------------------------------------------------------------------
      CHARACTER*16 NOMCMD(2)
      CHARACTER*8  NOMF
      INTEGER      LG(2), UNMEGA, IADZON
      LOGICAL      LERMEM
      LOGICAL      LMEMEX
C      DATA         NOMCMD / 'DEBUT ' ,'POURSUITE' /
C      DATA         LG     /    5     ,     9      /
C     ------------------------------------------------------------------
C
C     --- MEMOIRE POUR LE GESTIONNAIRE D'OBJET ---
      UNMEGA = 1 024 * 1 024
      IADZON = 0
      LMO  = 0
C     RESTRICTION POUR UNE TAILLE MEMOIRE JEVEUX EXACTE
      LOIS = LOISEM()
      LERMEM = .FALSE.
      FNTMEM = -1.0D0

      MEMDEM = MEMJVX ( FNTMEM )
      IF ( MEMDEM .GT. 0 ) THEN
         FNTMEM = MEMDEM * 1.0D0/ UNMEGA
         WRITE(6,'(1X,A,I14,A,F12.3,A)') 'MEMOIRE IMPOSEE POUR JEVEUX: '
     +          ,MEMDEM*LOIS,' OCTETS (',FNTMEM*LOIS,' MEGAOCTETS)'
         IMEMO  = MEMDIS (MEMDEM, IADZON, LMO, 0)
         WRITE(6,'(1X,A,I14,A)') 'MEMOIRE DONNEE PAR "MEMDIS": ',
     +             IMEMO*LOIS,' OCTETS'
         IF ( MEMDEM .LE. IMEMO ) THEN
            IMEMO = MEMDEM
         ELSE
            LERMEM = .TRUE.
         ENDIF
      ELSE
         MAXMEM = MEMJOB() * UNMEGA
         IMEMO  = MEMDIS( MAXMEM, IADZON, LMO, 1)
         WRITE(6,'(1X,A,I12,A,I6,A)') 'MEMOIRE DONNEE PAR "MEMDIS": ',
     +         IMEMO*LOIS,' OCTETS (MAX POUR LE JOB=',
     +         (MAXMEM*LOIS)/UNMEGA,' MEGAOCTETS)'
         IF (.NOT. LMEMEX(0)) THEN
            IMEMO  =  MAX ( INT(0.75D0 * IMEMO)  , IMEMO - UNMEGA )
         ENDIF
      ENDIF
      FNTMEM = IMEMO * 1.0D0 / UNMEGA
      WRITE(6,'(1X,A,I12,A,F12.3,A)') 'MEMOIRE PRISE              : ',
     +      IMEMO*LOIS,' OCTETS (',FNTMEM*LOIS,' MEGAOCTETS)'
C
C     --- OUVERTURE DE GESTIONNAIRE D'OBJET ---
      INTDBG = -1
      IF (ISDBGJ(INTDBG) .EQ. 1) THEN
         IDEBUG = 1
      ELSE
         IDEBUG = 0
      ENDIF
      CALL JEDEBU(4,IMEMO,IADZON,LMO,'MESSAGE','VIGILE',IDEBUG )
C
C     --- ALLOCATION D'UNE BASE DE DONNEES DUMMY ---
      NOMF = 'LDUMMY'
      CALL JEINIF( 'DUMMY','DETRUIT',NOMF,'L', 250 , 100, 1 000 )
C
C-----------------AY------------------------
      CALL DEFUFI(6,'MESSAGE')
      CALL DEFUFI(9,'ERREUR')
      CALL UTINIT(2, 80, 1)
C-----------------AY------------------------

      IF ( LERMEM ) THEN
          CALL UTMESS ( 'F' , 'SUPERVISEUR' ,
     +             'IMPOSSIBLE D''ALLOUER LA MEMOIRE JEVEUX DEMANDEE')
      ENDIF
C        ---
      IF (IDEBUG .EQ. 1) THEN
         CALL UTMESS('I','SUPERVISEUR',
     +                  'EXECUTION DE JEVEUX EN MODE DEBUG')
      ENDIF
      END
