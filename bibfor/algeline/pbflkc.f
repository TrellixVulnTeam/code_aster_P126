      SUBROUTINE PBFLKC(UMOY,RUG,RHOF,HMOY,RMOY,LONG,CF0,MCF0,ICOQ,IMOD,
     &                  NBM,RKIP,TCOEF,S1,S2,KI,LAMBDA,KCALCU,PASSAG)
      IMPLICIT REAL*8 (A-H,O-Z)
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGELINE  DATE 21/11/97   AUTEUR D6BHHJP J.P.LEFEBVRE 
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
C COUPLAGE FLUIDELASTIQUE, CONFIGURATIONS DU TYPE "COQUE_COAX"
C RESOLUTION DU PROBLEME FLUIDE INSTATIONNAIRE : INITIALISATION DE
C KCALCU(3,4) DANS LE CAS OU UMOY <> 0
C APPELANT : PBFLUI
C-----------------------------------------------------------------------
C  IN : UMOY   : VITESSE DE L'ECOULEMENT MOYEN
C  IN : RUG    : RUGOSITE ABSOLUE DE PAROI DES COQUES
C  IN : RHOF   : MASSE VOLUMIQUE DU FLUIDE
C  IN : HMOY   : JEU ANNULAIRE MOYEN
C  IN : RMOY   : RAYON MOYEN
C  IN : LONG   : LONGUEUR DU DOMAINE DE RECOUVREMENT DES DEUX COQUES
C  IN : CF0    : COEFFICIENT DE FROTTEMENT VISQUEUX
C  IN : MCF0   : EXPOSANT VIS-A-VIS DU NOMBRE DE REYNOLDS
C  IN : ICOQ   : INDICE CARACTERISANT LA COQUE SUR LAQUELLE ON TRAVAILLE
C                ICOQ=1 COQUE INTERNE  ICOQ=2 COQUE EXTERNE
C  IN : IMOD   : INDICE DU MODE CONSIDERE
C  IN : NBM    : NOMBRE DE MODES PRIS EN COMPTE POUR LE COUPLAGE
C  IN : RKIP   : ORDRE DE COQUE DU MODE CONSIDERE, PONDERE PAR LA VALEUR
C                MOYENNE DU PROFIL DE PRESSION
C  IN : TCOEF  : TABLEAU DES COEFFICIENTS DES DEFORMEES AXIALES
C  IN : S1     : PARTIE REELLE     DE LA FREQUENCE COMPLEXE
C  IN : S2     : PARTIE IMAGINAIRE DE LA FREQUENCE COMPLEXE
C  IN : KI     : TABLEAU DE TRAVAIL
C  IN : LAMBDA : VALEURS PROPRES DE L'OPERATEUR DIFFERENTIEL
C OUT : KCALCU : MATRICE RECTANGULAIRE A COEFFICIENTS CONSTANTS
C                PERMETTANT DE CALCULER UNE SOLUTION PARTICULIERE DU
C                PROBLEME FLUIDE INSTATIONNAIRE, LORSQUE UMOY <> 0
C OUT : PASSAG : MATRICE DONT LES COLONNES SONT LES VECTEURS PROPRES DE
C                L'OPERATEUR DIFFERENTIEL
C-----------------------------------------------------------------------
C
      REAL*8       UMOY,RUG,RHOF,HMOY,RMOY,LONG,CF0,MCF0
      INTEGER      ICOQ,IMOD,NBM
      REAL*8       RKIP,TCOEF(10,NBM),S1,S2
      COMPLEX*16   KI(4,3),LAMBDA(3),KCALCU(3,4),PASSAG(3,3)
C
      REAL*8       LN
      COMPLEX*16   C1,C2,C3,C4,D1,D2,D3,D4,E1,E2,E3,E4,F1,F2,F3,F4
      COMPLEX*16   G1,G2,G3,G4,Q11,Q12,Q13,S,P1,P2,P3,P4,P5,T,U,V,J
C
C-----------------------------------------------------------------------
C
      ITAB = 0
      POIDS = -1.D0
      IF (ICOQ.EQ.2) THEN
        ITAB = 5
        POIDS = 1.D0
      ENDIF
      LN = TCOEF(1+ITAB,IMOD)
      A1 = TCOEF(2+ITAB,IMOD) * POIDS
      A2 = TCOEF(3+ITAB,IMOD) * POIDS
      A3 = TCOEF(4+ITAB,IMOD) * POIDS
      A4 = TCOEF(5+ITAB,IMOD) * POIDS
      B1 = TCOEF(2+ITAB,IMOD) / 2.D0
      B2 = TCOEF(3+ITAB,IMOD) / 2.D0
      B3 = TCOEF(4+ITAB,IMOD) / 2.D0
      B4 = TCOEF(5+ITAB,IMOD) / 2.D0
C
      S = DCMPLX(S1,S2)
      J = DCMPLX(0.D0,1.D0)
C
      P1 = DCMPLX(LN/(LONG*HMOY))
      P2 = S/(UMOY*HMOY)
      P3 = DCMPLX(LN/(LONG*RMOY))
      P4 = S/(UMOY*RMOY)
      P5 = (DCMPLX(CF0/HMOY) + S/UMOY)/HMOY
C
      C1 = P1*A2+P2*A1+P3*B2+P4*B1
      C2 = -1.D0*P1*A1+P2*A2-P3*B1+P4*B2
      C3 = P1*A4+P2*A3+P3*B4+P4*B3
      C4 = P1*A3+P2*A4+P3*B3+P4*B4
C
      D1 = P1*A2+P5*A1+P3*B2+P4*B1
      D2 = -1.D0*P1*A1+P5*A2-P3*B1+P4*B2
      D3 = P1*A4+P5*A3+P3*B4+P4*B3
      D4 = P1*A3+P5*A4+P3*B3+P4*B4
C
      U = 0.5D0*((RKIP/RMOY)**2)
     &    * (S + DCMPLX((CF0/HMOY)*(MCF0+2.D0)*UMOY))
      V = -0.5D0*((RKIP/RMOY)**2)*DCMPLX(UMOY)
C
      E1 = (U * (J*C2-C1)) + V*LAMBDA(1)*(D1-J*D2)
      E2 = (U * (-1.D0*J*C2-C1)) + V*LAMBDA(1)*(D1+J*D2)
      E3 = (-1.D0 * U * (C3+C4)) + V*LAMBDA(1)*(D3+D4)
      E4 = (U * (C4-C3)) + V*LAMBDA(1)*(D3-D4)
C
      F1 = (U * (J*C2-C1)) + V*LAMBDA(2)*(D1-J*D2)
      F2 = (U * (-1.D0*J*C2-C1)) + V*LAMBDA(2)*(D1+J*D2)
      F3 = (-1.D0 * U * (C3+C4)) + V*LAMBDA(2)*(D3+D4)
      F4 = (U * (C4-C3)) + V*LAMBDA(2)*(D3-D4)
C
      G1 = (U * (J*C2-C1)) + V*LAMBDA(3)*(D1-J*D2)
      G2 = (U * (-1.D0*J*C2-C1)) + V*LAMBDA(3)*(D1+J*D2)
      G3 = (-1.D0 * U * (C3+C4)) + V*LAMBDA(3)*(D3+D4)
      G4 = (U * (C4-C3)) + V*LAMBDA(3)*(D3-D4)
C
      T = -1.D0*(S/UMOY+DCMPLX(CF0/HMOY))
      U = 3.D0*((RKIP/RMOY)**2)
     &    * (S/UMOY + DCMPLX((CF0/HMOY)*(MCF0+2.D0)))
      V = DCMPLX(2.D0*((RKIP/RMOY)**2))
C
      Q11 = (U + LAMBDA(1)*(T*LAMBDA(1)+V))**(-1.D0)
      Q12 = (U + LAMBDA(2)*(T*LAMBDA(2)+V))**(-1.D0)
      Q13 = (U + LAMBDA(3)*(T*LAMBDA(3)+V))**(-1.D0)
C
      W = LN/LONG
C
      KI(1,1) = Q11*E1/(J*W-LAMBDA(1))
      KI(1,2) = Q12*F1/(J*W-LAMBDA(2))
      KI(1,3) = Q13*G1/(J*W-LAMBDA(3))
      KI(2,1) = -1.D0*Q11*E2/(J*W+LAMBDA(1))
      KI(2,2) = -1.D0*Q12*F2/(J*W+LAMBDA(2))
      KI(2,3) = -1.D0*Q13*G2/(J*W+LAMBDA(3))
      KI(3,1) = Q11*E3/(DCMPLX(W)-LAMBDA(1))
      KI(3,2) = Q12*F3/(DCMPLX(W)-LAMBDA(2))
      KI(3,3) = Q13*G3/(DCMPLX(W)-LAMBDA(3))
      KI(4,1) = -1.D0*Q11*E4/(DCMPLX(W)+LAMBDA(1))
      KI(4,2) = -1.D0*Q12*F4/(DCMPLX(W)+LAMBDA(2))
      KI(4,3) = -1.D0*Q13*G4/(DCMPLX(W)+LAMBDA(3))
C
      DO 10 M2 =1,3
        PASSAG(1,M2) = DCMPLX(1.D0,0.D0)
        PASSAG(2,M2) = -1.D0 * LAMBDA(M2) * RMOY
        PASSAG(3,M2) = -1.D0 * LAMBDA(M2) * (LAMBDA(M2)-T)
     &                       * (RMOY*RMOY*RHOF*UMOY)
  10  CONTINUE
C
      DO 20 M2 =1,4
        DO 21 M1 =1,3
          KCALCU(M1,M2) = PASSAG(M1,1)*KI(M2,1)+PASSAG(M1,2)*KI(M2,2)
          KCALCU(M1,M2) = KCALCU(M1,M2) + PASSAG(M1,3)*KI(M2,3)
  21    CONTINUE
  20  CONTINUE
C
      END
