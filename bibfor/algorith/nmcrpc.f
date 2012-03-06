      SUBROUTINE NMCRPC(RESULT)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 05/03/2012   AUTEUR IDOUX L.IDOUX 
C ======================================================================
C COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
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
      CHARACTER*8  RESULT
C
C ----------------------------------------------------------------------
C
C ROUTINE *_NON_LINE (STRUCTURES DE DONNES)
C
C CREATION DE LA TABLE DES PARAMETRES CALCULES
C
C ----------------------------------------------------------------------
C
C IN  RESULT : NOM SD RESULTAT
C
      INTEGER      IFM,NIV,IRET
      INTEGER      NBPAR
      PARAMETER   (NBPAR=7)
      CHARACTER*2  TYPPAR(NBPAR)
      CHARACTER*10 NOMPAR(NBPAR)
      CHARACTER*19 TABLPC
      DATA         NOMPAR / 'INST'      ,'TRAV_EXT  ','ENER_CIN'  ,
     &                      'ENER_TOT'  ,'TRAV_AMOR ','TRAV_LIAI' ,
     &                      'DISS_SCH'/
      DATA         TYPPAR / 'R' ,'R' ,'R' ,'R' ,'R' ,'R' ,'R'/
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFDBG('MECA_NON_LINE',IFM,NIV)
C
C --- CREATION DE LA LISTE DE TABLES SI ELLE N'EXISTE PAS
C 
      CALL JEEXIN(RESULT//'           .LTNT',IRET)
      IF (IRET.EQ.0) THEN 
        CALL LTCRSD(RESULT,'G')
      ENDIF
C
C --- RECUPERATION DU NOM DE LA TABLE CORRESPONDANT
C     AUX PARAMETRE CALCULES
C
      TABLPC = ' ' 
      CALL LTNOTB(RESULT,'PARA_CALC',TABLPC)

      CALL EXISD('TABLE',TABLPC,IRET)

C     LA TABLE PARA_CALC N'EXISTE PAS
C     (ATTENTION, SE BASER SUR REUSE NE MARCHE PAS TOUJOURS)
      IF (IRET.EQ.0) THEN

C       CREATION DE LA TABLE VIDE    
        CALL TBCRSD(TABLPC,'G')

C       ON AJOUTE DES PARAMETRES A LA TABLE
        CALL TBAJPA(TABLPC, NBPAR, NOMPAR, TYPPAR )
        
      ENDIF

      CALL JEDEMA()

      END
