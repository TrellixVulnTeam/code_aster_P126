      SUBROUTINE LCROFS (Y, DP, S, DS)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 10/10/2001   AUTEUR ADBHHVV V.CANO 
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
C RESPONSABLE ADBHHVV V.CANO
      IMPLICIT NONE
      REAL*8             Y, DP, S, DS

C *******************************************************
C *     INTEGRATION DE LA LOI DE ROUSSELIER LOCAL       *
C * CALCUL DE DP DE LA FONCTION S(Y) ET DE SA DERIVEE   *
C *******************************************************

C IN  Y       : PARAMETRE Y = K*X/SIG1
C OUT DP      : INCREMENT DE DEFORMATION PLASTIQUE CUMULEE 
C                 DP = Y*SIG1*EXP(Y)/(FONC*K)
C OUT S       : VALEUR DE LA FONCTION S(Y)=-SIG1*FONC*EXP(-Y)+R 
C OUT DS      : DERIVEE DS / DY

      INTEGER ITEMAX, JPROLP, JVALEP, NBVALP
      REAL*8  YOUNG,NU,MU,K,SIGY,ALPHA
      REAL*8  SIG1,D,F0,FCR,ACCE
      REAL*8  FONC,EQETR,PM,RPM,PREC
      COMMON /LCROU/ YOUNG,NU,MU,K,SIGY,ALPHA,
     &               SIG1,D,F0,FCR,ACCE,
     &               FONC,EQETR,PM,RPM,PREC,
     &               ITEMAX, JPROLP, JVALEP, NBVALP
      
      REAL*8 RP,PENTE,R8BID,AIRE
      
      DP=Y*EXP(Y)*SIG1/(FONC*K)
           
      CALL RCFONC('V','TRACTION',JPROLP,JVALEP,NBVALP,R8BID,
     &            R8BID,R8BID,PM+DP,RP,PENTE,AIRE,R8BID,R8BID)

      S  = -SIG1*FONC*EXP(-Y) + RP     
      DS =  SIG1*FONC*EXP(-Y) + PENTE*SIG1*(1+Y)*EXP(Y)/(K*FONC)

      END 
