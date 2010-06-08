      SUBROUTINE  MATTHM(NDIM,AXI,NNO1,NNO2,DIMUEL,DIMDEF,IU,IP,IPF,
     >                  IQ,YAP1,YAP2,YATE,ADDEP1,ADDEP2,ADDLH1,
     >                  VFF1,VFF2,DFFR2,WREF,GEOM,ANG,WI,Q)

      
C ======================================================================
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 20/04/2010   AUTEUR JAUBERT A.JAUBERT 
C ======================================================================
C COPYRIGHT (C) 1991 - 2010  EDF R&D                  WWW.CODE-ASTER.ORG
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
C ======================================================================
C TOLE CRP_21
C ======================================================================
C
C =====================================================================
C.......................................................................
C
C     BUT:  CALCUL DE LA MATRICE DE PASSAGE DES DDL A LA DEFORMATION 
C           GENERALISEES
C.......................................................................
C =====================================================================
C IN NDIM    : DIMENSION DE L'ESPACE
C IN AXI     : .TRUE. SI AXISYMETRIE
C IN NNO1    : NOMBRE DE NOEUDS DE LA FAMILLE 1
C IN NNO2    : NOMBRE DE NOEUDS DE LA FAMILLE 2
C IN DIMUEL  : NOMBRE DE DDL
C IN DIMDEF  : DIMENSION DU VECTEUR DEFORMATIONS GENERALISEES
C IN IU      : DECALAGE D'INDICE POUR ACCEDER AUX DDL DE DEPLACEMENT
C IN IP      : DECALAGE D'INDICE POUR ACCEDER AUX DDL DE PRESSION MILIEU
C IN IPF     : DECALAGE D'INDICE POUR ACCEDER AUX DDL DE PRESSION FACES
C IN IQ      : DECALAGE D'INDICE POUR ACCEDER AUX DDL DE LAGRANGE HYDRO
C IN YAP1    : SI=1 : EQUATION SUR LA PRESSION 1
C IN YAP2    : SI=1 : EQUATION SUR LA PRESSION 2
C IN YATE    : SI=1 : EQUATION SUR LA TEMPERATURE
C IN ADDEP1  : ADRESSE DES DEFORMATIONS PRESSION 1
C IN ADDEP2  : ADRESSE DES DEFORMATIONS PRESSION 2
C IN ADDLH1  : ADRESSE DES DEFORMATIONS LAGRANGE PRESSION 1
C IN VFF1    : VALEUR DES FONCTIONS DE FORME (FAMILLE 1)
C IN VFF2    : VALEUR DES FONCTIONS DE FORME (FAMILLE 2)
C IN DFFR2   : DERIVEES DES FONCTIONS DE FORME (FAMILLE 2)
C IN WREF    : POIDS DE REFERENCE DU POINT D'INTEGRATION
C IN GEOM    : COORDONNEES DES NOEUDS (FAMILLE 1)
C IN ANG     : ANGLES D'EULER NODAUX (FAMILLE 1)
C =====================================================================
C OUT WI     : POIDS REEL DU POINT D'INTEGRATION
C OUT Q      : MATRICE DE PASSAGE DDL -> DEFORMATIONS GENERALISEES
C......................................................................
C

      IMPLICIT NONE
      
C - VARIABLES ENTREE
      INTEGER NDIM,NNO1,NNO2,DIMUEL,DIMDEF,YAP1,YAP2,YATE
      INTEGER IU(3,18),IP(2,9),IPF(2,2,9),IQ(2,2,9)
      INTEGER ADDEP1,ADDEP2,ADDLH1
      REAL*8  VFF1(NNO1),VFF2(NNO2),DFFR2(NDIM-1,NNO2)
      REAL*8  WREF,GEOM(NDIM,NNO2),ANG(24)
      LOGICAL AXI

C - VARIABLES SORTIE

      REAL*8 Q(DIMDEF,DIMUEL),WI

C - VARIABLES LOCALES
      INTEGER I,J,N,KJ,F
      REAL*8 B(3,3,2*NNO1),COUR,JACP,SINA,COSA,DFDX(NNO2)

C ======================================================================
C --- INITIALISATION ----------------------------------------------
C ======================================================================
          DO 108 I=1,DIMDEF
            DO 109 J=1,DIMUEL
               Q(I,J)=0.D0
 109        CONTINUE
 108     CONTINUE   

C ======================================================================
C --- CALCUL DE Q ET WI ----------------------------------------------
C ======================================================================

C - CALCUL DES DERIVEES DES FONCTIONS DE FORME / ABSCISSE CURVILIGNE

        CALL DFDM1D(NNO2,WI,DFFR2,GEOM,DFDX,COUR,JACP,COSA,SINA)

C - CALCUL DE LA MATRICE DE PASSAGE U GLOBAL -> SAUT DE U LOCAL 

      CALL EICINE(NDIM,AXI,NNO1,NNO2,VFF1,VFF2,WREF,DFFR2,GEOM,ANG,WI,B)


      DO 10 I=1,NDIM
        DO 11 J=1,NDIM
          DO 12 N=1,2*NNO1 
            KJ=IU(J,N)
            Q(I,KJ) = B(I,J,N)  
 12       CONTINUE 
 11     CONTINUE 
 10   CONTINUE


     
C - LIGNES PRESS1

      IF (YAP1 .EQ. 1) THEN
        DO 30 N=1,NNO2
          Q(ADDEP1,IP(1,N)) = VFF2(N)
            DO 31 I=1,NDIM-1 
              Q(ADDEP1+I,IP(1,N)) = DFDX(N) 
 31         CONTINUE  
          DO 32 F=1,2
            Q(ADDLH1+F-1,IPF(1,F,N)) = VFF2(N)
            Q(ADDLH1+F+1,IQ(1,F,1)) = 1
 32       CONTINUE
 30     CONTINUE
      END IF


      END
