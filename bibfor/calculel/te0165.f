      SUBROUTINE TE0165 ( OPTION , NOMTE )
      IMPLICIT  NONE
      CHARACTER*16        OPTION , NOMTE
C ......................................................................
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 21/06/2000   AUTEUR CIBHHLV L.VIVAN 
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
C INTRODUCTION DE LA TEMPERATURE
C
C    - FONCTION REALISEE:  CALCUL MATRICE DE RIGIDITE MEPOULI
C                          OPTION : 'FULL_MECA        '
C                          OPTION : 'RAPH_MECA        '
C                          OPTION : 'RIGI_MECA_TANG   '
C
C    - ARGUMENTS:
C        DONNEES:      OPTION       -->  OPTION DE CALCUL
C                      NOMTE        -->  NOM DU TYPE ELEMENT
C ......................................................................
C
      CHARACTER*24       CARAC,FF
      CHARACTER*8        NOMRES(2)
      CHARACTER*2        BL2, CODRET(2)
      REAL*8             A,W(9),NX,L1(3),L2(3),L10(3),L20(3)
      REAL*8             VALRES(2),E,ALPHA
      REAL*8             NORML1,NORML2,NORL10,NORL20,L0,ALLONG
      REAL*8             PRETEN, R8BID, TEMP, TROIS, ZERO
      INTEGER            IMATUU,JEFINT,LSIGMA
      INTEGER            ICOMPO,LSECT,IGEOM,IMATE,IDEPLA,IDEPLP
      INTEGER            I, ITEMPR, JCRET, KC
C
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
      CHARACTER*32       JEXNUM , JEXNOM , JEXR8 , JEXATR
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
      ZERO  = 0.D0
      TROIS = 3.D0
C***  ESSAI DE PRETENSION
C     PRETEN = 1000.D0
C***  FIN DE L'ESSAI DE PRETENSION
C
      CALL JEVECH('PCOMPOR','L',ICOMPO)
      IF (ZK16(ICOMPO)(1:4).NE.'ELAS') THEN
        CALL UTMESS('F','TE0165_1',' RELATION : '//ZK16(ICOMPO)//
     &              ' NON IMPLANTEE SUR LES POULIES')
      ENDIF
      IF (ZK16(ICOMPO+1)(1:8).NE.'GREEN   ') THEN
        CALL UTMESS('F','TE0165_2',' DEFORMATION : '//ZK16(ICOMPO+1)//
     &              ' NON IMPLANTEE SUR LES POULIES')
      ENDIF
      CALL JEVECH('PGEOMER','L',IGEOM)
      CALL JEVECH('PMATERC','L',IMATE)
      BL2 = '  '
      NOMRES(1) = 'E'
      NOMRES(2) = 'ALPHA'
      CALL RCVALA ( ZI(IMATE),'ELAS',0,'  ',R8BID,1,NOMRES,
     +              VALRES,CODRET , 'FM' )
      CALL RCVALA ( ZI(IMATE),'ELAS',0,'  ',R8BID,1,NOMRES(2),
     +              VALRES(2),CODRET(2) , BL2 )
      IF ( CODRET(2).NE.'OK' )  VALRES(2) = ZERO
      E     = VALRES(1)
      ALPHA = VALRES(2)
      CALL JEVECH('PCACABL','L',LSECT)
      A = ZR(LSECT)
      PRETEN = ZR(LSECT+1)
C
      CALL JEVECH('PTEMPPR','L',ITEMPR)
      CALL JEVECH('PDEPLMR','L',IDEPLA)
      CALL JEVECH('PDEPLPR','L',IDEPLP)
C
      IF(OPTION(1:9) .EQ. 'FULL_MECA' .OR.
     &   OPTION(1:14) .EQ. 'RIGI_MECA_TANG'     ) THEN
        CALL JEVECH('PMATUUR','E',IMATUU)
      ENDIF
      IF(OPTION(1:9) .EQ. 'FULL_MECA' .OR.
     &   OPTION(1:9) .EQ. 'RAPH_MECA'     ) THEN
        CALL JEVECH('PVECTUR','E',JEFINT)
        CALL JEVECH('PCONTPR','E',LSIGMA)
      ENDIF
C
      TEMP = ZERO
      DO 9 I=1,3
        TEMP = TEMP + ZR(ITEMPR-1+I)
 9    CONTINUE
      TEMP = TEMP / TROIS
      DO 10 I=1,9
        W(I)=ZR(IDEPLA-1+I)+ZR(IDEPLP-1+I)
10    CONTINUE
C
      DO 21 KC=1,3
      L1(KC)  = W(KC  ) + ZR(IGEOM-1+KC) - W(6+KC) - ZR(IGEOM+5+KC)
      L10(KC) =           ZR(IGEOM-1+KC)           - ZR(IGEOM+5+KC)
21    CONTINUE
      DO 22 KC=1,3
      L2(KC)  = W(3+KC) + ZR(IGEOM+2+KC) - W(6+KC) - ZR(IGEOM+5+KC)
      L20(KC) =           ZR(IGEOM+2+KC)           - ZR(IGEOM+5+KC)
22    CONTINUE
      CALL PSCAL (3,L1 ,L1 ,   NORML1)
      CALL PSCAL (3,L2 ,L2 ,   NORML2)
      CALL PSCAL (3,L10,L10,   NORL10)
      CALL PSCAL (3,L20,L20,   NORL20)
      NORML1 = SQRT (NORML1)
      NORML2 = SQRT (NORML2)
      NORL10 = SQRT (NORL10)
      NORL20 = SQRT (NORL20)
      L0 = NORL10 + NORL20
      ALLONG = (NORML1 + NORML2 - L0) / L0
      NX = E * A * ALLONG
C
        IF (ABS(NX).LE.1.D-6) THEN 
          NX = PRETEN
        ELSE
          NX = NX - E * A * ALPHA*TEMP
        ENDIF
C
        IF(OPTION(1:9)  .EQ. 'FULL_MECA' .OR.
     &     OPTION(1:14) .EQ. 'RIGI_MECA_TANG'   ) THEN
          CALL KPOULI (E,A,NX,L0,L1,L2,NORML1,NORML2,ZR(IMATUU))
        ENDIF
        IF(OPTION(1:9) .EQ. 'FULL_MECA' .OR.
     &     OPTION(1:9) .EQ. 'RAPH_MECA'   ) THEN
          CALL FPOULI (NX,L1,L2,NORML1,NORML2,ZR(JEFINT))
          ZR(LSIGMA) = NX
        ENDIF
C
      IF ( OPTION(1:9).EQ.'FULL_MECA'  .OR.  
     +     OPTION(1:9).EQ.'RAPH_MECA'  ) THEN
         CALL JEVECH ( 'PCODRET', 'E', JCRET )
         ZI(JCRET) = 0
      ENDIF
C
      END
