      SUBROUTINE ADHC02 ( NBOPT, TABENT, TABREE, TABCAR, LGCAR )
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 25/01/2002   AUTEUR GNICOLAS G.NICOLAS 
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
C     ------------------------------------------------------------------
C      ADAPTATION PAR HOMARD - DECODAGE DE LA COMMANDE - PHASE 02
C      --             -                       -                --
C      ECRITURE DU FICHIER DE DONNEES POUR L'INFORMATION
C     ------------------------------------------------------------------
C
      IMPLICIT NONE
C
C 0.1. ==> ARGUMENTS
C
      INTEGER NBOPT
      INTEGER TABENT(NBOPT), LGCAR(NBOPT)
C
      REAL*8 TABREE(NBOPT)
C
      CHARACTER*(*) TABCAR(NBOPT)
C
C 0.2. ==> VARIABLES LOCALES
C
      CHARACTER*6 NOMPRO
      PARAMETER ( NOMPRO = 'ADHC02' )
C
      CHARACTER*4 FICLOC
      PARAMETER ( FICLOC = 'DONN' )
C
      INTEGER IAUX, JAUX, KAUX
      INTEGER CODRET
      INTEGER NUFIHO
      INTEGER MODHOM
      INTEGER NIVINF, IFM
      INTEGER LREPHC
C
      CHARACTER*72 REPHC
      CHARACTER*100 FIHO
      CHARACTER*100 LIGBLA, LIGNE
C
C     ------------------------------------------------------------------
C
      MODHOM = TABENT(2)
C
      IF ( MODHOM.EQ.2 ) THEN
C
C     ------------------------------------------------------------------
C====
C 1. RECUPERATION DES ARGUMENTS
C====
C
      CODRET = 0
C
C 1.1. ==> ENTIERS
C
      NUFIHO = TABENT(1)
      IFM    = TABENT(29)
      NIVINF = TABENT(30)
C
C 1.2. ==> CARACTERES
C
      LREPHC = LGCAR(29)
      IF ( LREPHC.GT.0 ) THEN
        REPHC(1:LREPHC) = TABCAR(29)(1:LREPHC)
      ENDIF
C
C 1.3. ==> REELS
C
C====
C 2. MISE EN FORME
C====
C
C====
C 3. ECRITURE DU FICHIER, LIGNE APRES LIGNE
C====
C
C 3.1. ==> OUVERTURE DU FICHIER
C
      FIHO(1:LREPHC) = REPHC(1:LREPHC)
      FIHO(LREPHC+1:LREPHC+1) = '/'
      JAUX = LREPHC+1+LEN(FICLOC)
      FIHO(LREPHC+2:JAUX) = FICLOC
      JAUX = JAUX + 1
      KAUX = LEN(FIHO)
      DO 31 , IAUX = JAUX , KAUX
        FIHO(IAUX:IAUX) = ' '
 31   CONTINUE
C
      IF ( NIVINF.GE.2 ) THEN
        WRITE(IFM,*) 'FICHIER DE DONNEES POUR HOMARD EN INFORMATION :'
        WRITE(IFM,*) FIHO(1:KAUX)
      ENDIF
C
      OPEN ( UNIT=NUFIHO, FILE=FIHO, ERR=311 )
      GOTO 312
C
 311  CONTINUE
      CALL UTMESS
     > ('E',NOMPRO,'ERREUR A L OUVERTURE DU FICHIER DE DONNEES')
      WRITE(IFM,*) FIHO(1:KAUX)
      CODRET = CODRET + 1
C
 312  CONTINUE
C
C 3.2. ==> LIGNE BLANCHE
C
      JAUX = LEN(LIGBLA)
      DO 32 , IAUX = 1 , JAUX
        LIGBLA(IAUX:IAUX) = ' '
 32   CONTINUE
C
C 3.2. ==> PAS GRAND-CHOSE POUR LE MOMENT
C
      LIGNE = LIGBLA
      LIGNE(1:1) = '0'
      WRITE (NUFIHO,30000) LIGNE
      WRITE (NUFIHO,30000) LIGNE
C
      LIGNE(1:1) = 'q'
      WRITE (NUFIHO,30000) LIGNE
C
C 3.7. ==> FERMETURE DU FICHIER
C
      IF ( CODRET.EQ.0 ) THEN
        CLOSE ( NUFIHO ) 
      ENDIF
C
30000 FORMAT (A100)
C
C====
C 4. ARRET SI PROBLEME
C====
C
      IF ( CODRET.NE.0 ) THEN
        CALL UTMESS
     > ('F',NOMPRO,'ERREURS CONSTATEES POUR IMPR_FICO_HOMA')
      ENDIF
C
C     ------------------------------------------------------------------
C
      ENDIF
C
C     ------------------------------------------------------------------
C
      END
