      SUBROUTINE UTIDEA ( NOM , ITYPE )
      IMPLICIT REAL*8 (A-H,O-Z)
      INTEGER                      ITYPE
      CHARACTER*(*)       NOM 
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 01/12/2000   AUTEUR JMBHH01 J.M.PROIX 
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
C     CORRESPONDANCE NOM DE MAILLE "ASTER" AVEC NUMERO "IDEAS"
C     ------------------------------------------------------------------
      CHARACTER*8  NOMMAI
C     ------------------------------------------------------------------
C
      ITYPE = 0
      NOMMAI = NOM
      IF(      NOMMAI .EQ. 'POI1'    ) THEN
        ITYPE = 161
      ELSEIF ( NOMMAI .EQ. 'SEG2'    ) THEN
        ITYPE = 21
      ELSEIF ( NOMMAI .EQ. 'SEG3'    ) THEN
        ITYPE = 24 
      ELSEIF ( NOMMAI .EQ. 'SEG4'    ) THEN
        ITYPE = 21 
      ELSEIF ( NOMMAI .EQ. 'TRIA3'   ) THEN
        ITYPE = 74
      ELSEIF ( NOMMAI .EQ. 'TRIA6'   ) THEN
        ITYPE = 72
      ELSEIF ( NOMMAI .EQ. 'TRIA7'   ) THEN
C        CALL UTMESS('A','UTIDEA','TRIA7 ELEMENT INEXISTANT DANS'
C     +            //' IDEAS, CONVERTI EN TRIA6')
        ITYPE = 72
      ELSEIF ( NOMMAI .EQ. 'TRIA9'   ) THEN
        ITYPE = 73
      ELSEIF ( NOMMAI .EQ. 'QUAD4'   ) THEN
        ITYPE = 71
      ELSEIF ( NOMMAI .EQ. 'QUAD8'   ) THEN
        ITYPE = 75
      ELSEIF ( NOMMAI .EQ. 'QUAD9'   ) THEN
C        CALL UTMESS('A','UTIDEA','QUAD9 ELEMENT INEXISTANT DANS'
C     +            //' IDEAS, CONVERTI EN QUA8')
        ITYPE = 75
      ELSEIF ( NOMMAI .EQ. 'QUAD12'  ) THEN
        ITYPE = 76
      ELSEIF ( NOMMAI .EQ. 'TETRA4'  ) THEN
        ITYPE = 111
      ELSEIF ( NOMMAI .EQ. 'TETRA10' ) THEN
        ITYPE = 118
      ELSEIF ( NOMMAI .EQ. 'PENTA6'  ) THEN
        ITYPE = 112
      ELSEIF ( NOMMAI .EQ. 'PENTA15' ) THEN
        ITYPE = 113
      ELSEIF ( NOMMAI .EQ. 'HEXA8'   ) THEN
        ITYPE = 115
      ELSEIF ( NOMMAI .EQ. 'HEXA20'  ) THEN
        ITYPE = 116
      ELSEIF ( NOMMAI .EQ. 'HEXA27'  ) THEN
        ITYPE = 6000
      ENDIF
C
      END
