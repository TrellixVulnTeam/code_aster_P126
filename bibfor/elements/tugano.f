      SUBROUTINE TUGANO(MAT,NLIG,NCOL,NNOS,NNO,NPG,VPG,VNO)
      IMPLICIT NONE

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 27/04/2001   AUTEUR JMBHH01 J.M.PROIX 
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
C
C BUT :  PASSAGE GAUSS NOEUDS POUR LES ELEMENTS TUYAU A 3 ET 4 NOEUDS
C
C IN  VPG   : VALEURS AU POINTS DE GAUSS
C IN  NNO   : NOMBRE DE NOEUDS (3 OU 4)
C IN  NPG   : POINTS DE GAUSS
C IN  MAT   : MATRICE DE PASSAGE GAUSS - NOEUDS

C OUT VNO   : VALEURS AUX NOEUDS

      INTEGER NNO,NPG,I,KP,NNOS,NLIG,NCOL
      REAL*8 VPG(NPG),VNO(NNO),MAT(NLIG,NCOL)

      IF (NCOL.NE.NPG) THEN
         CALL UTMESS('F','TUGANO','NPG DIFFERENT DE NCOL')
      ELSEIF ((NLIG.NE.NNOS).AND.(NLIG.NE.NNO)) THEN
         CALL UTMESS('F','TUGANO','NLIG DIFFERENT DE NNO')
      ENDIF

      DO 21 I=1,NLIG
         VNO(I) = 0.D0
         DO 22 KP=1,NPG
            VNO(I) = VNO(I) + MAT(I,KP) * VPG(KP)
22       CONTINUE
21    CONTINUE

C      NOEUDS MILIEUX

      IF (NLIG.NE.NNO) THEN
         IF (NNO.EQ.3) THEN
            VNO(3)=(VNO(2)+VNO(1))*0.5D0
         ELSEIF (NNO.EQ.4) THEN
             VNO(3)=VNO(1)+(VNO(2)-VNO(1))/3.D0
             VNO(4)=VNO(1)+2.D0*(VNO(2)-VNO(1))/3.D0
         ENDIF
      ENDIF
      END
