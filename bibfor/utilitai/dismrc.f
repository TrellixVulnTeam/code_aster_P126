      SUBROUTINE DISMRC(CODMES,QUESTI,NOMOBZ,REPI,REPK,IERD)
      IMPLICIT REAL*8 (A-H,O-Z)
      INTEGER                               REPI,     IERD
      CHARACTER*(*)     CODMES,QUESTI,REPK
      CHARACTER*19 NOMOB
      CHARACTER*(*) NOMOBZ
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 06/12/2000   AUTEUR VABHHTS J.PELLET 
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
C IN  : CODMES : CODE DES MESSAGES A EMETTRE : 'F', 'A', ...
C IN  : QUESTI : TEXTE PRECISANT LA QUESTION POSEE
C IN  : NOMOBZ : NOM D'UN OBJET DE TYPE RESU_COMPO (K19)
C OUT : REPI   : REPONSE ( SI ENTIERE )
C OUT : REPK   : REPONSE ( SI CHAINE DE CARACTERES )
C OUT : IERD   : CODE RETOUR (0--> OK, 1 --> PB)
C ----------------------------------------------------------------------
C --------------- COMMUNS NORMALISES  JEVEUX  --------------------------
      CHARACTER*32   JEXNUM, JEXNOM, JEXATR, JEXR8
      INTEGER        ZI
      COMMON /IVARJE/ZI(1)
      REAL*8         ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16     ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL        ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8    ZK8
      CHARACTER*16          ZK16
      CHARACTER*24                  ZK24
      CHARACTER*32                          ZK32
      CHARACTER*80                                  ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C --------------- FIN COMMUNS NORMALISES  JEVEUX  --------------------
      CHARACTER*16 QUES2
      CHARACTER*1 KBID
      NOMOB = NOMOBZ
C ----------------------------------------------------------------------
      IERD = 0
C
      IF (QUESTI.EQ.'NB_CHAMP_MAX') THEN
         CALL JELIRA(JEXNUM(NOMOB//'.TACH',1),'LONMAX',REPI,KBID)
      ELSE IF (QUESTI.EQ.'NB_CHAMP_UTI') THEN
         CALL JELIRA(NOMOB//'.ORDR','LONUTI',REPI,KBID)
      ELSE
         QUES2 = QUESTI
         CALL UTMESS(CODMES,'DISMRC','LA QUESTION : "'//QUES2//
     +               '" EST INCONNUE')
         IERD = 1
      ENDIF
C
      END
