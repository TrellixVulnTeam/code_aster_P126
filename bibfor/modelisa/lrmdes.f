      SUBROUTINE LRMDES ( FID,
     >                    NBLTIT, DESCFI, TITRE )
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 25/01/2002   AUTEUR GNICOLAS G.NICOLAS 
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
C-----------------------------------------------------------------------
C     LECTURE FORMAT MED - LA DESCRIPTION
C     -    -         -        ---
C-----------------------------------------------------------------------
C     LECTURE DU FICHIER MAILLAGE AU FORMAT MED   
C               PHASE 0 : LA DESCRIPTION
C     ENTREES :
C       FID    : IDENTIFIANT DU FICHIER MED
C       NOMAMD : NOM MED DU MAILLAGE A LIRE
C     SORTIES:
C       NBLTIT : NOMBRE DE LIGNES DU TITRE
C       DESCFI : DESCRIPTION DU FICHIER
C       TITRE  : TITRE DU MAILLAGE
C-----------------------------------------------------------------------
C
      IMPLICIT NONE
C
C 0.1. ==> ARGUMENTS
C
      INTEGER FID 
      INTEGER NBLTIT
C
      CHARACTER*(*) DESCFI, TITRE
C
C 0.2. ==> COMMUNS
C
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
      CHARACTER*16                ZK16
      CHARACTER*24                          ZK24
      CHARACTER*32                                    ZK32
      CHARACTER*80                                              ZK80
      COMMON  / KVARJE / ZK8(1) , ZK16(1) , ZK24(1) , ZK32(1) , ZK80(1)
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
C
C 0.3. ==> VARIABLES LOCALES
C
      CHARACTER*6 NOMPRO
      PARAMETER ( NOMPRO = 'LRMDES' )
C
      INTEGER CODRET
      INTEGER IAUX, JAUX
      INTEGER JTITRE
      INTEGER LGDESC
C
      CHARACTER*8 SAUX08
      CHARACTER*80 DAT
C
C     ------------------------------------------------------------------
      CALL JEMARQ ( )
C
C====
C 1. LECTURE DE LA DESCRIPTION EVENTUELLE DU FICHIER
C====
C
      CALL EFLFDE ( FID, LGDESC, CODRET )
      IF ( CODRET.NE.0 ) THEN
        CALL CODENT ( CODRET,'G',SAUX08 )
        CALL UTMESS ('F',NOMPRO,'MED: ERREUR EFLFDE NUMERO '//SAUX08)
      ENDIF
C
      IF ( LGDESC.NE.0 ) THEN
        IAUX = 2
        CALL EFFIEN ( FID, IAUX, DESCFI, CODRET )
        IF ( CODRET.NE.0 ) THEN
          CALL CODENT ( CODRET,'G',SAUX08 )
          CALL UTMESS ('A',NOMPRO,'MED: ERREUR EFFIEN NUMERO '//SAUX08)
          CALL UTMESS ( 'F', NOMPRO,
     >                   'PROBLEME A LA LECTURE DE LA DESCRIPTION' )
        ENDIF
      ENDIF
C
C====
C 2. OBJET TITRE 
C    ON Y MET LA DESCRIPTION SI ELLE EXISTE, LA DATE SINON.
C====
C
      IF ( LGDESC.NE.0 ) THEN
        IAUX = MOD(LGDESC,80)
        NBLTIT = (LGDESC-IAUX)/80
        IF ( IAUX.NE.0 ) THEN
          NBLTIT = NBLTIT + 1
        ENDIF
      ELSE
        NBLTIT = 1
      ENDIF
C
      CALL WKVECT ( TITRE, 'G V K80', NBLTIT, JTITRE )
C
      IF ( LGDESC.NE.0 ) THEN
        IF ( IAUX.EQ.0 ) THEN
          DO 20 , JAUX = 1 , NBLTIT
            ZK80(JTITRE+JAUX-1) = DESCFI(80*(JAUX-1)+1:80*JAUX)
   20     CONTINUE
        ELSE
          DO 21 , JAUX = 1 , NBLTIT-1
            ZK80(JTITRE+JAUX-1) = DESCFI(80*(JAUX-1)+1:80*JAUX)
   21     CONTINUE
          ZK80(JTITRE+NBLTIT-1) = DESCFI(80*(NBLTIT-1):LGDESC)
        ENDIF
      ELSE
        CALL ENLIRD(DAT)
        ZK80(JTITRE) = DAT
      ENDIF
C
C====
C 3. LA FIN
C====
C
      CALL JEDEMA ( )
C
      END
