      SUBROUTINE TE0275 ( OPTION , NOMTE )
      IMPLICIT   NONE
      CHARACTER*16        OPTION , NOMTE
C ......................................................................
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 04/04/2002   AUTEUR VABHHTS J.PELLET 
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
C    - FONCTION REALISEE:  CALCUL DES VECTEURS ELEMENTAIRES
C                          OPTION : 'RESI_THER_PARO_R'
C    - ARGUMENTS:
C        DONNEES:      OPTION       -->  OPTION DE CALCUL
C                      NOMTE        -->  NOM DU TYPE ELEMENT
C ......................................................................
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
      INTEGER            ZI
      COMMON  / IVARJE / ZI(1)
      REAL*8             ZR
      COMMON  / RVARJE / ZR(1)
      COMPLEX*16         ZC
      COMMON  / CVARJE / ZC(1)
      LOGICAL            ZL
      COMMON  / LVARJE / ZL(1)
      CHARACTER*8        ZK8
      CHARACTER*16                ZK16
      CHARACTER*24                          ZK24
      CHARACTER*32                                    ZK32
      CHARACTER*80                                              ZK80
      COMMON  / KVARJE / ZK8(1) , ZK16(1) , ZK24(1) , ZK32(1) , ZK80(1)
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------
C
      INTEGER        NNO,KP,NPG,ICARAC,IFF,IPOIDS,IVF,IDFDE,IGEOM
      INTEGER        IVERES,K,I,L,LI,IHECHP,ITEMPS,ITEMP
      REAL*8         POIDS,POIDS1,POIDS2,COEFH
      REAL*8         R1,R2,NX,NY,TPG,THETA
      CHARACTER*24   CARAC,FF
      CHARACTER*8    ELREFE
C     ------------------------------------------------------------------
C
      CALL ELREF1(ELREFE)

      CARAC='&INEL.'//ELREFE//'.CARAC'
      CALL JEVETE(CARAC,'L',ICARAC)
      NNO=ZI(ICARAC)
      NPG=ZI(ICARAC+2)
C
      FF   ='&INEL.'//ELREFE//'.FF'
      CALL JEVETE(FF,'L',IFF)
      IPOIDS=IFF
      IVF   =IPOIDS+NPG
      IDFDE =IVF   +NPG*NNO
C
      CALL JEVECH ('PGEOMER','L',IGEOM)
      CALL JEVECH ('PTEMPSR','L',ITEMPS)
      CALL JEVECH ('PHECHPR','L',IHECHP)
      CALL JEVECH ('PTEMPEI','L',ITEMP)
      CALL JEVECH ('PRESIDU','E',IVERES)
C
      THETA = ZR(ITEMPS+2)
C
      DO 100 KP=1,NPG
        COEFH = ZR(IHECHP+KP-1)
        K = (KP-1)*NNO
        CALL VFF2DN (NNO,ZR(IPOIDS+KP-1),ZR(IDFDE+K),ZR(IGEOM),NX,NY,
     &               POIDS1)
        CALL VFF2DN (NNO,ZR(IPOIDS+KP-1),ZR(IDFDE+K),ZR(IGEOM+2*NNO),
     &               NX,NY,POIDS2)
        R1 = 0.D0
        R2 = 0.D0
        TPG = 0.D0
        DO 110 I=1,NNO
          L = (KP-1)*NNO+I
          R1  = R1 + ZR(IGEOM+2*I-2) * ZR(IVF+L-1)
          R2  = R2 + ZR(IGEOM+2*(NNO+I)-2) * ZR(IVF+L-1)
          TPG = TPG + (ZR(ITEMP+NNO+I-1)- ZR(ITEMP+I-1))*ZR(IVF+L-1)
110     CONTINUE
        IF ( NOMTE(3:4) .EQ. 'AX' ) THEN
          POIDS1 = POIDS1*R1
          POIDS2 = POIDS2*R2
        ENDIF
        POIDS = (POIDS1+POIDS2)/2
CCDIR$ IVDEP
        DO 120 I=1,NNO
          LI = IVF+(KP-1)*NNO+I-1
          ZR(IVERES+I-1) = ZR(IVERES+I-1) - POIDS * ZR(LI)
     &                   * COEFH * THETA*TPG
          ZR(IVERES+I-1+NNO) = ZR(IVERES+I-1+NNO) + POIDS*ZR(LI)
     &                       * COEFH * THETA*TPG
120     CONTINUE
100   CONTINUE
      END
