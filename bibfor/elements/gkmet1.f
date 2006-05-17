      SUBROUTINE GKMET1(NDEG,NNOFF,CHFOND,IADRGK,IADGKS,IADGKI,ABSCUR)
      IMPLICIT REAL*8 (A-H,O-Z)
      
      INTEGER         NDEG,NNOFF,IADRGK,IADGKS,IADGKI
      CHARACTER*24    CHFOND,ABSCUR
      
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 16/05/2006   AUTEUR GALENNE E.GALENNE 
C ======================================================================
C COPYRIGHT (C) 1991 - 2004  EDF R&D                  WWW.CODE-ASTER.ORG
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
C
C ......................................................................
C      METHODE THETA-LEGENDRE ET G-LEGENDRE POUR LE CALCUL DE G(S)
C      K1(S) K2(S) et K3(S) DANS LE CADRE X-FEM
C
C ENTREE
C
C   NDEG     --> NOMBRE+1 PREMIERS CHAMPS THETA CHOISIS   
C   NNOFF    --> NOMBRE DE POINTS DU FOND DE FISSURE
C   CHFOND   --> COORDS DES POINTS DU FOND DE FISSURE
C   IADRGK    --> ADRESSE DE VALEURS DE GKTHI
C                 (G, K1, K2, K3 POUR LES CHAMPS THETAI)
C
C SORTIE
C
C   IADGKS      --> ADRESSE DE VALEURS DE GKS 
C                   (VALEUR DE G(S), K1(S), K2(S), K3(S), BETA(S))
C   IADGKI      --> ADRESSE DE VALEURS DE GKTHI
C                  (G, K1, K2, K3 POUR LES CHAMPS THETAI)
C   ABSCUR     --> VALEURS DES ABSCISSES CURVILIGNES S
C ......................................................................
C
      INTEGER         IADRT3,I,J,K,IFON,IADABS
      REAL*8          XL,SOM(4),GKTHI(5),LEGS
C
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
C
      CHARACTER*32 JEXNUM,JEXNOM,JEXR8,JEXATR
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24CM
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24CM(1),ZK32(1),ZK80(1)
C
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------

      CALL JEMARQ()      

C    VALEURS DU POLYNOME DE LEGENDRE  POUR LES NOEUDS DU FOND DE FISSURE
C
      CALL WKVECT('&&METHO1.THETA','V V R8',(NDEG+1)*NNOFF,IADRT3)     
      CALL JEVEUO(CHFOND,'L',IFON)

      CALL JEVEUO(ABSCUR,'E',IADABS)
      DO 10 I=1,NNOFF
        ZR(IADABS-1+(I-1)+1)=ZR(IFON-1+4*(I-1)+4)
10    CONTINUE
      XL=ZR(IADABS-1+(NNOFF-1)+1)

      CALL GLEGEN(NDEG,NNOFF,XL,ABSCUR,ZR(IADRT3))
C
C     VALEURS DE G(S), K1(S), K2(S), K3(S), BETA(S)
C
      DO 20 I=1,NNOFF
        DO 21 K=1,4
          SOM(K) = 0.D0
 21     CONTINUE
        DO 22 J=1,NDEG+1
          LEGS=ZR(IADRT3-1+(J-1)*NNOFF+I)
          DO 23 K=1,4
            GKTHI(K)=ZR(IADRGK-1+(J-1)*5+K)  
            SOM(K) = SOM(K) + GKTHI(K)*LEGS
 23       CONTINUE
 22     CONTINUE
        DO 24 K=1,4
          ZR(IADGKS-1+(I-1)*5+K) = SOM(K)
 24     CONTINUE
        IF (ZR(IADGKS-1+(I-1)*5+2).NE.0.D0)  ZR(IADGKS-1+(I-1)*5+5)= 
     &     2.0D0*ATAN2(0.25D0*(ZR(IADGKS-1+(I-1)*5+1)/ZR(IADGKS-1+(I-1)
     &     *5+1)-SIGN(1.0D0,ZR(IADGKS-1+(I-1)*5+2))*SQRT((ZR(IADGKS-1+
     &     (I-1)*5+1)/ZR(IADGKS-1+(I-1)*5+2))**2.0D0+8.0D0)),1.0D0)

 20   CONTINUE

C     VALEURS DE GI, K1I, K2I, K3I (ON RECOPIE SIMPLEMENT GKTHI)
      DO 30 I=1,NNOFF*5
        ZR(IADGKI-1+I)=ZR(IADRGK-1+I)
 30   CONTINUE

      CALL JEDETR('&&METHO1.THETA')  
      CALL JEDETR('&&GKMET1.TEMP     .ABSCU')    
      CALL DETRSD('CHAMP_GD','&&GMETH1.G2        ')     
C
      CALL JEDEMA()
      END
