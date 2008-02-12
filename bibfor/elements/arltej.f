      SUBROUTINE ARLTEJ(NNO   ,NDIM  ,COORD ,DFF   ,
     &                  INVJAC)
C 
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 12/02/2008   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2008  EDF R&D                  WWW.CODE-ASTER.ORG
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
      INTEGER    NNO,NDIM
      REAL*8     DFF(3,NNO)
      REAL*8     INVJAC(NDIM,NDIM)
      REAL*8     COORD(NDIM*NNO)      
C
C ----------------------------------------------------------------------
C
C CALCUL DES MATRICES DE COUPLAGE ARLEQUIN
C OPTION ARLQ_COUPL
C 
C 
C CALCUL DU JACOBIEN ET DE SON INVERSE DE LA TRANSFO 
C
C ----------------------------------------------------------------------
C
C
C IN  NDIM   : DIMENSION DE L'ESPACE
C IN  NNO    : NOMBRE DE NOEUDS DE LA MAILLE  
C IN  COORD  : COORD. NOEUDS DE LA MAILLE 
C OUT INVJAC : INVERSE DU JACOBIEN DE LA TRANSFORMATION
C
C ----------------------------------------------------------------------
C
      INTEGER       IDIM,JDIM,INO
      REAL*8        TEMP(3,3),JACOBI(3,3)
C
C ----------------------------------------------------------------------
C
      IF ((NDIM.LT.2).OR.(NDIM.GT.3)) THEN
        CALL ASSERT(.FALSE.)
      ENDIF  
C
C --- JACOBIENNE 
C
      CALL MATINI(3,3,0.D0,JACOBI)
      DO 100 IDIM = 1,NDIM
        DO 110 JDIM = 1,NDIM
          DO 120 INO  = 1,NNO
            JACOBI(IDIM,JDIM) = JACOBI(IDIM,JDIM) + 
     &                          COORD(NDIM*(INO-1)+IDIM)*DFF(JDIM,INO) 
 120      CONTINUE
 110    CONTINUE
 100  CONTINUE   
      IF (NDIM .EQ. 2) THEN
        JACOBI(3,3) = 1.D0
      ENDIF    
C
C --- INVERSE DE LA JACOBIENNE 
C      
      CALL MATINV(3,JACOBI,TEMP) 
C      
      DO 200 IDIM=1,NDIM
        DO 210 JDIM=1,NDIM
          INVJAC(IDIM,JDIM) = TEMP(IDIM,JDIM)
 210    CONTINUE
 200  CONTINUE
C
      END
