      SUBROUTINE IRGMPV ( IFI, LRESU, NOMCON, CHAMSY, NBORDR, PARA,  
     +                    NOCMP, NBPOI, NBSEG, NBTRI, NBTET,
     +                    SCAL, VECT, TENS )
      IMPLICIT NONE
C
      INTEGER        NBPOI, NBSEG, NBTRI, NBTET, IFI, NBORDR, LCH,ICH
      REAL*8         PARA(*)
      LOGICAL        LRESU, SCAL, VECT, TENS
      CHARACTER*8    NOCMP
      CHARACTER*(*)  NOMCON, CHAMSY
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF PREPOST  DATE 23/09/2002   AUTEUR DURAND C.DURAND 
C ======================================================================
C COPYRIGHT (C) 1991 - 2002  EDF R&D                  WWW.CODE-ASTER.ORG
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
C
C     BUT :   ECRITURE D'UN RESULTAT AU FORMAT GMSH
C
C     ------------------------------------------------------------------
      INTEGER      IOR,I,LXLGUT
      CHARACTER*19 K19B
      CHARACTER*36 K36B
C     ------------------------------------------------------------------
C
      WRITE(IFI,1000) '$View'
C
C     ECRITURE DE LIGNE 1 (VIEW_NAME NB_TIME_STEPS)
C
      IF ( LRESU ) THEN 
         LCH = LXLGUT(NOMCON)
         K36B(1:LCH) = NOMCON(1:LCH)
         ICH=LCH+1
         K36B(ICH:ICH) = '_'
         LCH=LXLGUT(CHAMSY)
         K36B(ICH+1:ICH+LCH) = CHAMSY(1:LCH)
         ICH=ICH+LCH+1
         K36B(ICH:ICH) = '_'
         LCH=LXLGUT(NOCMP)
         K36B(ICH+1:ICH+LCH) = NOCMP(1:LCH)
         K36B(ICH+LCH+1:ICH+LCH+1) = ' '
         WRITE(IFI,1020) K36B(1:ICH+LCH+1), NBORDR   
      ELSE
         LCH = LXLGUT(NOMCON)
         K19B(1:LCH) = NOMCON(1:LCH)
         ICH=LCH+1
         K36B(ICH:ICH) = '_'
         LCH=LXLGUT(NOCMP)
         K19B(ICH+1:ICH+LCH) = NOCMP(1:LCH)
         K36B(ICH+LCH+1:ICH+LCH+1) = ' '
         WRITE(IFI,1022) K19B(1:ICH+LCH+1), NBORDR
      ENDIF
C
C     ECRITURE DE LA LIGNE 2 A 4 (nb elt par de type de maille)
C
      IF ( SCAL ) THEN 
         WRITE(IFI,1030) NBPOI, 0, 0
         WRITE(IFI,1030) NBSEG, 0, 0
         WRITE(IFI,1030) NBTRI, 0, 0
         WRITE(IFI,1030) NBTET, 0, 0
      ELSEIF ( VECT ) THEN 
         WRITE(IFI,1030) 0, NBPOI, 0
         WRITE(IFI,1030) 0, NBSEG, 0
         WRITE(IFI,1030) 0, NBTRI, 0
         WRITE(IFI,1030) 0, NBTET, 0
      ELSEIF ( TENS ) THEN 
         WRITE(IFI,1030) 0, 0, NBPOI
         WRITE(IFI,1030) 0, 0, NBSEG
         WRITE(IFI,1030) 0, 0, NBTRI
         WRITE(IFI,1030) 0, 0, NBTET
      ELSE
      ENDIF
C
C     ECRITURE DE LA LIGNE 5 (time_step_values)
C
      WRITE(IFI,1040) (PARA(IOR), IOR=1,NBORDR)
C
 1000 FORMAT(A5)
 1020 FORMAT(A,1X,I4)
 1022 FORMAT(A,1X,I4)
 1030 FORMAT(3(I6,1X))
 1040 FORMAT(1P,10(E15.8,1X))
C
      END
