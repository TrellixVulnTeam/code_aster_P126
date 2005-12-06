      SUBROUTINE DISMPM(CODMES,QUESTI,NOMOBZ,REPI,REPKZ,IERD)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 17/06/2003   AUTEUR VABHHTS J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2003  EDF R&D                  WWW.CODE-ASTER.ORG
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
      IMPLICIT NONE
C     --     DISMOI(PHEN_MODE)
C     ARGUMENTS:
C     ----------
      INTEGER REPI,IERD
      CHARACTER*(*) QUESTI,CODMES
      CHARACTER*24 REPK
      CHARACTER*32 NOMOB
      CHARACTER*(*) NOMOBZ,REPKZ
C ----------------------------------------------------------------------
C    IN:
C       CODMES : CODE DES MESSAGES A EMETTRE : 'F', 'A', ...
C       QUESTI : TEXTE PRECISANT LA QUESTION POSEE
C       NOMOBZ : NOM D'UN PHENMODE : (1:16)  : PHENOMENE
C                                    (17:32) : MODELISATION
C    OUT:
C       REPI   : REPONSE ( SI ENTIERE )
C       REPKZ  : REPONSE ( SI CHAINE DE CARACTERES )
C       IERD   : CODE RETOUR (0--> OK, 1 --> PB)

C ----------------------------------------------------------------------
C     VARIABLES LOCALES:
C     ------------------
      CHARACTER*8 K8BID
C---------------- COMMUNS NORMALISES  JEVEUX  --------------------------
      CHARACTER*32 JEXNUM,JEXNOM,JEXATR,JEXR8
      COMMON /IVARJE/ZI(1)
      COMMON /RVARJE/ZR(1)
      COMMON /CVARJE/ZC(1)
      COMMON /LVARJE/ZL(1)
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      INTEGER ZI,NBTM,JPHEN,IMODE
      REAL*8 ZR
      COMPLEX*16 ZC
      LOGICAL ZL
      CHARACTER*8 ZK8,KBID
      CHARACTER*16 ZK16,PHEN,MODE
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
C---------------- FIN COMMUNS NORMALISES  JEVEUX  --------------------
C DEB-------------------------------------------------------------------
      NOMOB = NOMOBZ
      PHEN=NOMOB(1:16)
      MODE=NOMOB(17:32)

      CALL JELIRA('&CATA.TM.NOMTM','NOMMAX',NBTM,KBID)
      CALL JENONU(JEXNOM('&CATA.'//PHEN(1:13)//'.MODL',MODE),IMODE)
      CALL ASSERT(IMODE.GT.0)
      CALL JEVEUO(JEXNUM('&CATA.'//PHEN,IMODE),'L',JPHEN)

      IF (QUESTI.EQ.'DIM_GEOM') THEN
          REPI=ZI(JPHEN-1+NBTM+2)
      ELSE IF (QUESTI.EQ.'DIM_TOPO') THEN
          REPI=ZI(JPHEN-1+NBTM+1)
      ELSE
        REPK = QUESTI
        CALL UTMESS(CODMES,'DISMPM','LA QUESTION : "'//REPK//
     &              '" EST INCONNUE')
        IERD = 1
        GO TO 10
      END IF

   10 CONTINUE
      REPKZ = REPK
      END
