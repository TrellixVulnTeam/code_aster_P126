      SUBROUTINE DISMIC(CODMES,QUESTI,NOMOBZ,REPI,REPKZ,IERD)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 03/05/2000   AUTEUR CIBHHLV L.VIVAN 
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
      IMPLICIT REAL*8 (A-H,O-Z)
C     --     DISMOI(INCONNU)
C     ARGUMENTS:
C     ----------
      INTEGER REPI,IERD
      CHARACTER*19 NOMOB
      CHARACTER*(*) QUESTI,CODMES
      CHARACTER*24  REPK
      CHARACTER*(*) NOMOBZ,REPKZ
C ----------------------------------------------------------------------
C    IN:
C       CODMES : CODE DES MESSAGES A EMETTRE : 'F', 'A', ...
C       QUESTI : TEXTE PRECISANT LA QUESTION POSEE
C       NOMOBZ : NOM D'UN OBJET DE TYPE "INCONNU"(K19)
C    OUT:
C       REPI   : REPONSE ( SI ENTIERE )
C       REPKZ  : REPONSE ( SI CHAINE DE CARACTERES )
C       IERD   : CODE RETOUR (0--> OK, 1 --> PB)
C
C ----------------------------------------------------------------------
C     VARIABLES LOCALES:
C     ------------------
C---------------- COMMUNS NORMALISES  JEVEUX  --------------------------
      CHARACTER*32 JEXNUM,JEXNOM,JEXATR,JEXR8
      COMMON /IVARJE/ZI(1)
      COMMON /RVARJE/ZR(1)
      COMMON /CVARJE/ZC(1)
      COMMON /LVARJE/ZL(1)
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      INTEGER ZI
      REAL*8 ZR
      COMPLEX*16 ZC
      LOGICAL ZL
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
C---------------- FIN COMMUNS NORMALISES  JEVEUX  --------------------
      CHARACTER*4 DOCU
C
C
      CALL JEMARQ()
      NOMOB = NOMOBZ
      REPK  = 'INCONNU'
C
      IF ( QUESTI(1:8) .EQ. 'RESULTAT' ) THEN
         CALL JEEXIN(NOMOB//'.NOVA',IRE3)
         CALL JEEXIN(NOMOB//'.DESC',IRE4)
         CALL JEEXIN(NOMOB//'.ORDR',IRE5)
         CALL JEEXIN(NOMOB//'.TAVA',IRE6)
         CALL JEEXIN(NOMOB//'.TACH',IRE7)
         IF (IRE3.GT.0 .AND. IRE4.GT.0 .AND. IRE5.GT.0 .AND.
     +                       IRE6.GT.0 .AND. IRE7.GT.0 ) THEN
           REPK = 'OUI'
           GO TO 9999
         ENDIF
C
      ELSEIF ( QUESTI(1:5) .EQ. 'TABLE' ) THEN
         CALL JEEXIN(NOMOB//'.TBBA',IRE3)
         CALL JEEXIN(NOMOB//'.TBNP',IRE4)
         CALL JEEXIN(NOMOB//'.TBLP',IRE5)
         IF (IRE3.GT.0 .AND. IRE4.GT.0 .AND. IRE5.GT.0 ) THEN
           REPK = 'OUI'
           GO TO 9999
         ENDIF
C
      ELSEIF ( QUESTI(1:7) .EQ. 'CHAM_NO' ) THEN
         CALL JEEXIN ( NOMOB//'.DESC', IRET )
         IF ( IRET .GT.0 ) THEN
            CALL JELIRA(NOMOB//'.DESC','DOCU',IBID,DOCU)
            IF ( DOCU .EQ. 'CHNO' ) THEN
               REPK = 'OUI'
               GO TO 9999
            ENDIF
         ENDIF
C
      ELSEIF ( QUESTI(1:9) .EQ. 'CHAM_ELEM' ) THEN
         CALL JEEXIN ( NOMOB//'.CELD', IRET )
         IF ( IRET .GT.0 ) THEN
            REPK = 'OUI'
            GO TO 9999
         ENDIF
C
      ELSEIF  (QUESTI(1:4).EQ.'TYPE') THEN
         CALL JEEXIN(NOMOB//'.TYPE',IRE1)
         CALL JEEXIN(NOMOB//'.NOPA',IRE2)
         CALL JEEXIN(NOMOB//'.NOVA',IRE3)
         IF (IRE1.GT.0 .AND. IRE2.GT.0 .AND. IRE3.GT.0) THEN
            REPK = 'TABLE'
            GO TO 9999
         END IF

         CALL JEEXIN(NOMOB//'.DESC',IRE1)
         IF ( IRE1 .GT. 0 ) THEN
             CALL JELIRA(NOMOB//'.DESC','DOCU',IBID,DOCU)
             IF (DOCU.EQ.'CHNO') THEN
               REPK = 'CHAM_NO'
               GO TO 9999
             ELSE
               CALL RSDOCU ( DOCU, REPK, IRET )
               IF ( IRET .NE. 0 ) THEN
                  REPK = QUESTI
                  CALL UTMESS(CODMES,'DISMIC',
     +                  'LA QUESTION : "'//REPK//'" EST INCONNUE')
                  IERD=1
               ENDIF
               GO TO 9999
             ENDIF
         ENDIF

         CALL JEEXIN(NOMOB//'.CELD',IRE1)
         IF (IRE1.GT.0) THEN
            REPK='CHAM_ELEM'
            GO TO 9999
         ENDIF

         CALL JEEXIN(NOMOB//'.PROL',IRE1)
         IF (IRE1.GT.0) THEN
           CALL JEVEUO(NOMOB//'.PROL','L',JPRO)
           IF ( ZK8(JPRO).EQ.'CONSTANTE' .OR. ZK8(JPRO).EQ.'FONCTION'
     +     .OR. ZK8(JPRO).EQ.'NAPPE'.OR. ZK8(JPRO).EQ.'FONCT_C' ) THEN
              REPK='FONCTION'
              GO TO 9999
           ENDIF
         ENDIF

      ELSE
         REPK = QUESTI
         CALL UTMESS(CODMES,'DISMIC',
     +                  'LA QUESTION : "'//REPK//'" EST INCONNUE')
         IERD=1
         GO TO 9999
      END IF
C
 9999 CONTINUE
      REPKZ = REPK
      CALL JEDEMA()
      END
