      SUBROUTINE NMCH6P(MEASSE)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 15/04/2013   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2013  EDF R&D                  WWW.CODE-ASTER.ORG
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
      CHARACTER*19 MEASSE(*)
C
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (INITIALISATION)
C
C CREATION DES VARIABLES CHAPEAUX - MEASSE
C
C ----------------------------------------------------------------------
C
C
C OUT MEASSE : VARIABLE CHAPEAU POUR NOM DES MATR_ASSE
C
C ----------------------------------------------------------------------
C
      CHARACTER*19 MASSE ,AMORT ,RIGID ,SSTRU
C
      DATA AMORT ,MASSE     /'&&NMCH6P.AMORT','&&NMCH6P.MASSE'/
      DATA RIGID ,SSTRU     /'&&NMCH6P.RIGID','&&NMCH6P.SSRASS'/
C
C ----------------------------------------------------------------------
C
      CALL NMCHA0('MEASSE','ALLINI',' ',MEASSE)
      CALL NMCHA0('MEASSE','MERIGI',RIGID ,MEASSE)
      CALL NMCHA0('MEASSE','MEMASS',MASSE ,MEASSE)
      CALL NMCHA0('MEASSE','MEAMOR',AMORT ,MEASSE)
      CALL NMCHA0('MEASSE','MESSTR',SSTRU ,MEASSE)
C
      END
