      SUBROUTINE TE0356(OPTION,NOMTE)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 04/07/2000   AUTEUR JMBHH01 J.M.PROIX 
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
C.......................................................................
C
C     BUT: CALCUL DES VECTEURS ELEMENTAIRES EN MECANIQUE
C          ELEMENTS ISOPARAMETRIQUES 3D METALLURGIQUES
C
C          OPTION : 'CHAR_MECA_TEMP_Z  '
C
C     ENTREES  ---> OPTION : OPTION DE CALCUL
C          ---> NOMTE  : NOM DU TYPE ELEMENT
C.......................................................................
C
      IMPLICIT REAL*8 (A-H,O-Z)
      PARAMETER         ( NBRES=6 )
      CHARACTER*8        ALIAS,NOMRES(NBRES)
      CHARACTER*2        CODRET(NBRES)
      CHARACTER*16       NOMTE,OPTION
      CHARACTER*24       CHVAL,CHCTE
      REAL*8             VALRES(NBRES),UNDEMI
      REAL*8             ZFBM,ZAUST,COEF1,COEF2,EPSTH
      REAL*8             DFDX(27),DFDY(27),DFDZ(27),TPG,COEF,POIDS,NZ
      INTEGER            IFF,IPOIDS,IVF,IDFDE,IDFDN,IDFDK,IGEOM,IMATE
      INTEGER            NNO,KP,NPG1,II,JJ,I,J,IVECTU,ITEMPE,JTAB(7)
      INTEGER            NBPG(10)
C
C
C
C---------------- COMMUNS NORMALISES  JEVEUX  --------------------------
      COMMON /IVARJE/ZI(1)
      COMMON /RVARJE/ZR(1)
      COMMON /CVARJE/ZC(1)
      COMMON /LVARJE/ZL(1)
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      INTEGER ZI
      REAL*8 ZR
      COMPLEX*16 ZC
      LOGICAL ZL
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
C------------FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
C
      ALIAS = NOMTE(6:13)
C
      CHCTE = '&INEL.'//ALIAS//'.CARACTE'
      CALL JEVETE(CHCTE,'L',JIN)
      NDIM = ZI(JIN+1-1)
      NNO = ZI(JIN+2-1)
      NBFPG = ZI(JIN+3-1)
      DO 111 I = 1,NBFPG
         NBPG(I) = ZI(JIN+3-1+I)
  111 CONTINUE
      NPG1 = NBPG(1)
C
      CHVAL = '&INEL.'//ALIAS//'.FFORMES'
      CALL JEVETE(CHVAL,'L',JVAL)
C
      IPOIDS = JVAL + (NDIM+1)*NNO*NNO
      IVF    = IPOIDS + NPG1
      IDFDE  = IVF    + NPG1*NNO
      IDFDN  = IDFDE  + 1
      IDFDK  = IDFDN  + 1
C
      CALL JEVECH('PGEOMER','L',IGEOM)
C
      CALL JEVECH('PMATERC','L',IMATE)

      MATER=ZI(IMATE)


      NOMRES(1)='E'
      NOMRES(2)='NU'
      NOMRES(3)='F_ALPHA'
      NOMRES(4)='C_ALPHA'
      NOMRES(5)='PHASE_REFE'
      NOMRES(6)='EPSF_EPSC_TREF'



C
      CALL JEVECH('PTEREF','L',ITREF)
      CALL JEVECH('PTEMPER','L',ITEMPE)
      CALL JEVECH('PPHASRR','L',IPHASE)
      CALL JEVECH('PVECTUR','E',IVECTU)

C     INFORMATION DU NOMBRE DE PHASE
      CALL TECACH(.TRUE.,.TRUE.,'PPHASRR',7,JTAB)
       NZ= JTAB(6)

C
      DO 101 KP=1,NPG1
        L=(KP-1)*NNO
        K=(KP-1)*NNO*3
        CALL DFDM3D ( NNO,ZR(IPOIDS+KP-1),ZR(IDFDE+K),ZR(IDFDN+K),
     &    ZR(IDFDK+K),ZR(IGEOM),DFDX,DFDY,DFDZ,POIDS )
        TPG     = 0.D0
C
        DO 102 I=1,NNO
          TPG  = TPG  +  ZR(ITEMPE+I-1)           *ZR(IVF+L+I-1)
102     CONTINUE
        TTRG = TPG - ZR(ITREF)
        CALL RCVALA ( MATER,'ELAS_META',1,'TEMP',TPG,6,NOMRES,VALRES,
     &                CODRET, 'FM' )
        COEF  = VALRES(1) / (1.D0 - 2.D0 * VALRES(2))
        IF (NZ .EQ. 7) THEN
           ZALPHA  = ZR(IPHASE+7*KP-7) + ZR(IPHASE+7*KP-6) +
     &             ZR(IPHASE+7*KP-5) + ZR(IPHASE+7*KP-4)
        ELSEIF (NZ .EQ. 3) THEN
           ZALPHA  = ZR(IPHASE+3*KP-3) + ZR(IPHASE+3*KP-2)
        ENDIF



        COEF1 = (1.D0-ZALPHA)*(VALRES(4)*TTRG-(1-VALRES(5))*VALRES(6))
        COEF2 = ZALPHA*(VALRES(3)*TTRG+VALRES(5)*VALRES(6))
        EPSTH = COEF1+COEF2
        POIDS = POIDS * COEF * EPSTH
C
        DO 104 I=1,NNO
           ZR(IVECTU+3*I-3) = ZR(IVECTU+3*I-3) + POIDS * DFDX(I)
           ZR(IVECTU+3*I-2) = ZR(IVECTU+3*I-2) + POIDS * DFDY(I)
           ZR(IVECTU+3*I-1) = ZR(IVECTU+3*I-1) + POIDS * DFDZ(I)
104     CONTINUE
101   CONTINUE
C
 9999 CONTINUE
      END
