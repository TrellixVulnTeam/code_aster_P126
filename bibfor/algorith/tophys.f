      SUBROUTINE TOPHYS(ICHO,IA,DPLMOD,NBCHOC,NBMODE,XGENE,UX,UY,UZ)
      IMPLICIT REAL*8 (A-H,O-Z)
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 20/11/95   AUTEUR ACBHHMV C.VARE 
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
C-----------------------------------------------------------------------
C    CONVERTIT EN BASE PHYSIQUE POUR DES DDLS GENERALISES DONNES
C
C    ICHO      IN    INDICE CARACTERISANT LA NON-LINEARITE
C    IA        IN    INDICE = 0 => TRAITEMENT DU NOEUD_1
C                           = 3 => TRAITEMENT DU NOEUD_2
C    DPLMOD    IN    VECTEUR DES DEPL MODAUX AUX NOEUDS DE CHOC
C    NBCHOC    IN    NOMBRE DE CHOCS
C    NBMODE    IN    NB DE MODES NORMAUX CONSIDERES
C    XGENE     IN    VECTEUR DES COORDONNEES GENERALISEES
C    UX,Y,Z    OUT   VALEURS DES DDLS CORRESPONDANTS
C-----------------------------------------------------------------------
C
      INTEGER  ICHO,IA,NBMODE,NBCHOC
      REAL*8   XGENE(NBMODE),DPLMOD(NBCHOC,NBMODE,*),UX,UY,UZ
C
      UX=0.0D0
      UY=0.0D0
      UZ=0.0D0
C
      DO 10 I=1,NBMODE
        UX = UX + DPLMOD(ICHO,I,1+IA)*XGENE(I)
        UY = UY + DPLMOD(ICHO,I,2+IA)*XGENE(I)
        UZ = UZ + DPLMOD(ICHO,I,3+IA)*XGENE(I)
10    CONTINUE
C
9999  CONTINUE
C
      END
