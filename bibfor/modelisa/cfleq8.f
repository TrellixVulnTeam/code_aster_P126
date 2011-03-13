      SUBROUTINE CFLEQ8(NOMA  ,DEFICO,NZOCO ,NSUCO ,NNOCO ,
     &                  NNOCO0,LISTNO,POINSN,NNOQUA)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 14/03/2011   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2011  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE ABBAS M.ABBAS
C
      IMPLICIT     NONE
      CHARACTER*8  NOMA
      INTEGER      NNOCO0,NSUCO,NNOCO,NZOCO
      CHARACTER*24 DEFICO
      CHARACTER*24 LISTNO
      CHARACTER*24 POINSN
      INTEGER      NNOQUA
C      
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODES MAILLEES - LECTURE DONNEES )
C
C CREATION D'UNE LISTE DES NOEUDS MILIEUX DES ARETES POUR LES MAILLES 
C QUADRATIQUES
C      
C ----------------------------------------------------------------------
C
C 
C IN  NOMA   : NOM DU MAILLAGE
C IN  DEFICO : NOM SD CONTACT DEFINITION
C IN  NZOCO  : NOMBRE TOTAL DE ZONES DE CONTACT
C IN  NSUCO  : NOMBRE TOTAL DE SURFACES DE CONTACT
C IN  NNOCO0 : NOMBRE DE NOEUDS INITIAL
C OUT POINSN : POINTEUR MISE A JOUR POUR PSURNO
C OUT LISTNO : LISTE DES NOEUDS RESTANTES (LONGUEUR NNOCO
C OUT NNOCO  : NOMBRE DE NOEUDS FINAL
C OUT NNOQUA : NOMBRE DE NOEUDS QUADRATIQUES
C
C -------------- DEBUT DECLARATIONS NORMALISEES JEVEUX -----------------
C
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C
C ---------------- FIN DECLARATIONS NORMALISEES JEVEUX -----------------
C
      CHARACTER*24 CONTNO
      INTEGER      JNOCO
      CHARACTER*24 INDINO
      INTEGER      JINDNO
      INTEGER      JNO
      INTEGER      INO,K
      INTEGER      ELIMNO
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()    
C 
C --- ACCES AUX STRUCTURES DE DONNEES DE CONTACT
C 
      CONTNO = DEFICO(1:16)//'.NOEUCO'     
      CALL JEVEUO(CONTNO,'L',JNOCO)          
C
C --- INITIALISATIONS
C 
      NNOQUA = 0
      ELIMNO = 0
      INDINO = '&&CFLEQ8.INDINO'                
C
C --- NOMBRE TOTAL DE NOEUDS QUADRATIQUES
C 
      CALL CFLEQA(NOMA  ,DEFICO,NZOCO ,NNOQUA)
C
C --- PAS DE QUAD8
C
      IF (NNOQUA.EQ.0) THEN
        GOTO 999
      ELSE
        CALL U2MESS('A','CONTACT_8')  
      ENDIF
C
C --- ECRITURE LISTE DES NOEUDS QUADRATIQUES
C
      CALL CFLEQB(NOMA  ,DEFICO,NZOCO ,NNOQUA)
C
C --- ELIMINATION DES NOEUDS MILIEUX DES ARETES DES QUAD8
C
      CALL CFLEQC(NOMA  ,DEFICO,NZOCO ,NNOCO ,NSUCO ,
     &            POINSN,INDINO,ELIMNO)
C
C --- RECOPIE DES NOEUDS NON ELIMINES DANS TABLEAU DE TRAVAIL
C     
      NNOCO  = NNOCO0 - ELIMNO
      CALL WKVECT(LISTNO,'V V I',NNOCO,JNO)
C
C --- TRAITEMENT DES NOEUDS MILIEUX DES ARETES DES QUAD8
C
      K = 0
      CALL JEVEUO(INDINO,'L',JINDNO)
      DO 120 INO = 1,NNOCO0
        IF (ZI(JINDNO+INO-1).EQ.0) THEN
          K = K + 1
          ZI(JNO+K-1) = ZI(JNOCO+INO-1)
        ENDIF
  120 CONTINUE
      CALL ASSERT(K.EQ.NNOCO)
C
  999 CONTINUE
C
C --- DESTRUCTION DU VECTEUR DE TRAVAIL TEMPORAIRE
C
      CALL JEDETR(INDINO)
C
      CALL JEDEMA()
      END
