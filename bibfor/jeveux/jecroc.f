      SUBROUTINE JECROC ( NOMLU )
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF JEVEUX  DATE 27/03/2002   AUTEUR VABHHTS J.PELLET 
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
      CHARACTER *(*)      NOMLU
C     ------------------------------------------------------------------
      INTEGER          ICLAS ,ICLAOS , ICLACO , IDATOS , IDATCO , IDATOC
      COMMON /IATCJE/  ICLAS ,ICLAOS , ICLACO , IDATOS , IDATCO , IDATOC
C     ------------------------------------------------------------------
      CHARACTER *75    CMESS
      CHARACTER *32    NOML32
      INTEGER          ICRE , IRET , JCTAB, ITAB
      CHARACTER *8     NUME
      DATA             NUME  / '$$XNUM  '/
C DEB ------------------------------------------------------------------
C J#DEB
      L =  LEN(NOMLU)
      IF ( L .NE. 32 ) THEN
         CMESS = 'APPEL DE JECROC PAR JEXNOM/JEXNUM OBLIGATOIRE '
         CALL JVMESS ( 'S' , 'JECROC01' , CMESS )
      ENDIF
C
      ICRE = 3
      NOML32 = NOMLU
      CALL JJVERN ( NOML32 , ICRE , IRET )
C
      IF ( IRET .EQ. 0 ) THEN
         CMESS = 'NOM DE COLLECTION OU DE REPERTOIRE INEXISTANT'
         CALL JVMESS ( 'S' , 'JECROC02' , CMESS )
      ELSE
        IF ( IRET .EQ. 1 ) THEN
C         ----- OBJET DE TYPE REPERTOIRE
          IF ( NOMLU(25:32) .EQ. NUME  ) THEN
            CMESS = 'ACCES PAR JEXNUM INTERDIT'
            CALL JVMESS ( 'S' , 'JECROC03' , CMESS )
          ENDIF
          CALL JXVEUO ( 'E' , ITAB , 1 , JCTAB )
          CALL JJCROC ( '        ' , ICRE )
        ELSE IF ( IRET .EQ. 2 ) THEN
C         ----- REPERTOIRE DE COLLECTION --
          CALL JJALLC ( ICLACO , IDATCO , 'E' , IBACOL )
          CALL JJCROC ( NOMLU(25:32) , ICRE )
        ELSE
          CMESS = 'ERREUR DE PROGRAMMATION'
          CALL JVMESS ( 'S' , 'JECROC04' , CMESS )
        ENDIF
      ENDIF
C FIN ------------------------------------------------------------------
C J#FIN
      END
