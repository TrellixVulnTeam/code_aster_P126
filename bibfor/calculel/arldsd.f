      SUBROUTINE ARLDSD(TYPESZ,NOMGRZ)
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
      CHARACTER*(*) NOMGRZ
C      
C ----------------------------------------------------------------------
C
C ROUTINE ARLEQUIN
C
C DESTRUCTION D'UNE SD ATTACHEES A UNE STRUCTURE
C
C ----------------------------------------------------------------------
C
C IN  TYPESD : NOM DU TYPE SD
C IN  NOMGRP : NOM DE LA STRUCTURE DE DONNEES
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
      CHARACTER*24 TYPESD
      CHARACTER*10 NOMGRP,QUADRA
      CHARACTER*16 NOMBOI,NOMARB,NOMMOR
      CHARACTER*24 NOMGMA,NOMGRM,NOMINV,NOMGRA
C      
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
      TYPESD = TYPESZ
      NOMGRP = NOMGRZ
C
      IF (TYPESD(1:5).EQ.'BOITE') THEN
        NOMBOI = NOMGRP(1:10)//'.BOITE'  
        CALL BOITDS(NOMBOI) 
      ELSEIF (TYPESD(1:5).EQ.'ARBRE') THEN
        NOMARB = NOMGRP(1:10)//'.ARBRE'   
        CALL ARBRDS(NOMARB)   
      ELSEIF (TYPESD(1:8).EQ.'GROUPEMA') THEN
        NOMGMA = NOMGRP(1:10)//'.GROUPEMA'  
        CALL JEDETR(NOMGMA) 
      ELSEIF (TYPESD(1:6).EQ.'GRMAMA') THEN
        NOMGRM = NOMGRP(1:10)//'.GRMAMA'  
        CALL JEDETR(NOMGRM)
      ELSEIF (TYPESD(1:6).EQ.'CNCINV') THEN
        NOMINV = NOMGRP(1:10)//'.CNCINV'  
        CALL JEDETR(NOMINV)  
      ELSEIF (TYPESD(1:11).EQ.'QUADRATURES') THEN
        QUADRA = NOMGRP(1:10) 
        CALL JEDETR(QUADRA(1:10)//'.LIMAMA')
        CALL JEDETR(QUADRA(1:10)//'.MAMA')
        CALL JEDETR(QUADRA(1:10)//'.MAFA')        
        CALL JEDETR(QUADRA(1:10)//'.NUMERO')
        CALL JEDETR(QUADRA(1:10)//'.TYPEMA') 
        CALL JEDETR(QUADRA(1:10)//'.DIME')                     
      ELSEIF (TYPESD(1:5).EQ.'MORSE') THEN
        NOMMOR = NOMGRP(1:10)//'.MORSE'  
        CALL JEDETR(NOMMOR(1:16)//'.DIME')
        CALL JEDETR(NOMMOR(1:16)//'.INO')
        CALL JEDETR(NOMMOR(1:16)//'.VALE')  
      ELSEIF (TYPESD(1:6).EQ.'GRAPHE') THEN
        NOMGRA = NOMGRP(1:8)//'.GRAPH'    
        CALL JEDETR(NOMGRA)  
      ELSEIF (TYPESD(1:7).EQ.'COLLAGE') THEN 
        CALL JEDETR(NOMGRP(1:10)//'.MAILLE')
        CALL JEDETR(NOMGRP(1:10)//'.INO')   
      ELSEIF (TYPESD(1:8).EQ.'ARLEQUIN') THEN 
        CALL JEDETR(NOMGRP(1:8)//'.TRAVR')
        CALL JEDETR(NOMGRP(1:8)//'.TRAVI')
        CALL JEDETR(NOMGRP(1:8)//'.TRAVL')
        CALL JEDETR(NOMGRP(1:8)//'.INFOI')  
        CALL JEDETR(NOMGRP(1:8)//'.INFOR')
      ELSE
        CALL ASSERT(.FALSE.)
      ENDIF    
C
      CALL JEDEMA()
      END
