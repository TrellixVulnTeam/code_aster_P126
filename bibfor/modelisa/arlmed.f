      SUBROUTINE ARLMED(MOTCLE,IOCC  ,GRFIN ,GRMED)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 12/02/2008   AUTEUR ABBAS M.ABBAS 
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
      CHARACTER*16 MOTCLE
      INTEGER      IOCC      
      INTEGER      GRMED,GRFIN
C      
C ----------------------------------------------------------------------
C
C ROUTINE ARLEQUIN
C
C CHOIX DU MEDIATEUR
C
C ----------------------------------------------------------------------
C
C IN  MOTCLE : MOT-CLEF FACTEUR POUR ARLEQUIN
C IN  IOCC   : OCCURRENCE DU MOT CLEF-FACTEUR ARLEQUIN
C IN  GRFIN  : 1 SI MAILLAGE 1 PLUS FIN QUE MAILLAGE 2
C              2 DANS LE CAS CONTRAIRE
C OUT GRMED  : GROUPE DE MAILLES SERVANT DE MEDIATEUR (1 OU 2)
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
      INTEGER      IRET,GRGRO
      INTEGER      IFM,NIV  
      CHARACTER*16 COLLE     
C      
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFNIV(IFM,NIV)  
C
C --- GROUPE AU MAILLAGE GROSSIER
C
      GRGRO = 3 - GRFIN          
C
C --- CHOIX DU MEDIATEUR
C
      CALL GETVTX(MOTCLE,'COLLAGE',IOCC,1,1,COLLE,IRET)
      IF (COLLE(1:10).EQ.'GROUP_MA_1') THEN
        GRMED = 1
      ELSEIF (COLLE(1:10).EQ.'GROUP_MA_2') THEN
        GRMED = 2
      ELSE 
        IF (COLLE(1:8).EQ.'GROSSIER') THEN
          GRMED = GRGRO
        ELSE
          GRMED = GRFIN
        ENDIF
      ENDIF
C
      IF (NIV.GE.2) THEN
        WRITE(IFM,*) '<ARLEQUIN> GROUPE DE ZONE MEDIATRICE: ',GRMED
      ENDIF      
C
      CALL JEDEMA()
      END
