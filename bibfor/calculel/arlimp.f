      SUBROUTINE ARLIMP(UNIT,TYPESZ,NOMSZ)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 12/02/2008   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2007  EDF R&D                  WWW.CODE-ASTER.ORG
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
      IMPLICIT NONE
      CHARACTER*(*) TYPESZ
      CHARACTER*(*) NOMSZ
      INTEGER       UNIT
C      
C ----------------------------------------------------------------------
C
C ROUTINE ARLEQUIN
C
C IMPRESSION DES SD SPECIFIQUES A ARLEQUIN
C
C ----------------------------------------------------------------------
C
C
C IN  UNIT   : UNITE D'IMPRESSION 
C IN  NOMSD  : NOM DE LA STRUCTURE DE DONNEES
C IN  TYPESD : NOM DU TYPE SD
C  
C TYPESD - BOITE      : BOITES D'APPARIEMENT
C   NOMSD EST UNE CHAINE K10 CONTENANT LE NOM DU GROUPE DE MAILLE DANS 
C   ARLEQUIN
C TYPESD - ARBRE      : ARBRE DE PARTITION BINAIRE
C   NOMSD EST UNE CHAINE K10 CONTENANT LE NOM DU GROUPE DE MAILLE DANS 
C   ARLEQUIN
C TYPESD - PONDERATION: VECTEUR DE PONDERATION DES MAILLES
C   NOMSD EST UNE CHAINE K24 CONTENANT LE NOM DE LA SD PRINCIPALE
C   ARLEQUIN
C
C
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
C
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
C      
C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------
C
      CHARACTER*24 TYPESD,NOMSD,NOMPOI
      INTEGER      JPP
C      
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
      TYPESD = TYPESZ
      NOMSD  = NOMSZ           
C      
      IF (TYPESD(1:5).EQ.'BOITE') THEN
        CALL BOITIM(UNIT,NOMSD(1:10)//'.BOITE',
     &              NOMSD(1:10)//'.GROUPEMA')       
      ELSEIF (TYPESD(1:5).EQ.'ARBRE') THEN
        CALL ARBRIM(UNIT,NOMSD(1:10)//'.ARBRE') 
      ELSEIF (TYPESD(1:11).EQ.'PONDERATION') THEN  
        CALL JEVEUO(NOMSD(1:8)//'.POIDS','L',JPP)
        NOMPOI = ZK24(JPP)   
        CALL PONDIM(UNIT,NOMPOI)              
      ELSE
        WRITE(UNIT,*) '<ARLEQUIN> SD INCONNUE (VOIR ARLIMP)'   
      ENDIF
C
 999  CONTINUE      
C
      CALL JEDEMA()
      END
