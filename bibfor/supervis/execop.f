      SUBROUTINE EXECOP( ICMD  , ICOND , IERTOT, IER , IFIN  )
      IMPLICIT REAL*8 (A-H,O-Z)
      INTEGER            ICMD  , ICOND , IERTOT, IER , IFIN
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF SUPERVIS  DATE 14/05/2002   AUTEUR DURAND C.DURAND 
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
C     EXECUTION DE LA COMMANDE NUMERO : ICMD
C     ------------------------------------------------------------------
C IN  ICMD   : IS : NUMERO D'ORDRE DE LA COMMANDE A EXECUTER
C IN  ICOND  : IS : CONDITIONS DE FONCTIONNEMENT DES OPERATEURS
C           0  EXECUTION DE L'OPERATEURS
C           1  VERIFICATION SUPPLEMENTAIRES
C IN  IERTOT : IS : NOMBRE D'ERREURS TOTALES DEJA RENCONTREES
C     IER  IS : NOMBRE D'ERREURS RENCONTREES DANS LA COMMANDE COURANTE
C OUT IFIN   : IS : INDICATEUR D'EXECUTION DE LA COMMANDE FIN
C           0  EXECUTION D'UN OPERATEUR AUTRE QUE FIN
C           1  EXECUTION DE L'OPERATEUR FIN
C     ------------------------------------------------------------------
C     COMMON POUR LE NIVEAU D'"INFO"
      INTEGER         NIVUTI,NIVPGM,UNITE
      COMMON /INF001/ NIVUTI,NIVPGM,UNITE

C     COMMON POUR LA DETECTION D'UNE SORTIE EN ERREUR SI PAS PAR_LOT
      INTEGER     IERLOT
      COMMON  /CERRLO/ IERLOT

      INTEGER     IMPR(3) , NUOPER
      REAL*8      XTT
      CHARACTER*6  NOMMAR
      CHARACTER*8  CMDUSR
      INTEGER     ISTAT
C     ------------------------------------------------------------------

C     --- CHARGEMENT POUR LES FONCTIONS GET ET IMPRESSION EVENTUELLE ---
      IF ( ICOND .EQ. 1 ) THEN
C        --- VERIFICATION SUPPLEMENTAIRES ---
         IMPR(1) = 0
         IMPR(2) = 0
         IMPR(3) = 0
      ELSEIF (ICOND.EQ.0) THEN
C        --- EXECUTION ---
         IMPR(1) = IUNIFI('MESSAGE')
         IMPR(2) = IUNIFI('&SYSCODE')
         IMPR(3) = IUNIFI('&SYSSTAT')
      ENDIF

      CALL GCECDU( IMPR , ICMD , NUOPER )
      ISTAT = 1
      CALL EXSTAT( ISTAT , ICOND , XTT )

      NOMMAR = 'OP'
      CALL CODENT(NUOPER,'D0',NOMMAR )
      CALL FIRMPQ('LONUTI',ICSTE)

      IER = 0
      IF ( NUOPER.EQ.9999 ) THEN
         IF (IERLOT .NE. 0) THEN
            IERTOT = IERLOT
            CALL GCECCO( 'SUPERVISEUR', 0, 'I', ' ' )
            CALL UTMESS('F','SUPERVISEUR',
     +                           'ARRET SUR ERREUR(S) UTILISATEUR')
         ENDIF
      CALL OP9999( ICOND , IERTOT , IFIN )
      ENDIF

C     -- ON NOTE LA MARQUE AVANT D'APPELER LA PROCHAINE COMMANDE :
      CALL JEVEMA(IMAAV)

C     -- ON REMET A "ZERO" LES COMMONS UTILISES PAR FOINT2 :
      CALL FOINT0()

C     -- ON REMET A "ZERO" LE COMMON UTILISE PAR UTDEBM :
      CALL UTDEB0()

C     -- ON MET A JOUR LE COMMON INF001 :
      NIVUTI = 1
      NIVPGM = 1
      UNITE  = IUNIFI('MESSAGE')

      IF ( NUOPER .LT. 0 ) THEN
        CALL OPSEXE(ICMD,ICOND,ABS(NUOPER),CMDUSR,IER)
      ELSEIF (( NUOPER.LT. 100 ).AND.(ICOND.EQ.0)) THEN
        CALL EX0000(NUOPER,IER)
      ELSEIF (( NUOPER.LT. 200 ).AND.(ICOND.EQ.0)) THEN
        CALL EX0100(NUOPER,IER)
      ELSEIF (( NUOPER.NE.9999 ).AND.(ICOND.EQ.0))  THEN
        IER = 1
        CALL UTDEBM('E','EXECUTION DES COMMANDES (ERREUR 03)',
     +      'LA COMMANDE A UN NUMERO NON APPELABLE DANS CETTE VERSION.')
        CALL UTIMPI('L','LE NUMERO ERRONE EST ',1,NUOPER)
        CALL UTFINM( )
C
      ENDIF

C     -- CONTROLE DE L'APPARIEMMENT DES JEMARQ/JEDEMA
      CALL JEVEMA(IMAAP)
      IF (IMAAV.NE.IMAAP) CALL UTMESS('F','EXECOP',
     +   'ERREUR PROGRAMMEUR : JEMARQ/JEDEMA NON APPARIES.')

C     --LIBERATION DES OBJETS RANENES EN MEMOIRE PAR JEVEUT :
      CALL JELIBZ ( 'G' )

      CALL FIRMPQ('NEW_LONUTI',ICSTE)
      IF ( IER .NE. 0 ) THEN
         IF ( ICOND .EQ. 1 ) THEN
            CALL UTDEBM('I','SUPERVISEUR', 'LES MESSAGES D''ERREURS '//
     +                       'PRECEDENT CONCERNE LA COMMANDE : ')
            IMPR(1) = IUNIFI('MESSAGE')
            IMPR(2) = 0
            IMPR(3) = 0
            CALL GCECDU( IMPR , ICMD , NUOPER )
         ENDIF
      ENDIF
      ISTAT = 2
      CALL EXSTAT( ISTAT , ICOND , XTT )
      IF (ICOND .EQ. 0) THEN
C        CALL JEDETV()
      ENDIF
      END
