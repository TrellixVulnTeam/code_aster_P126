      SUBROUTINE RIGMI2(NOMA,NOGR,IFREQ,NFREQ,IFMIS,RIGMA,RIGTO)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 05/08/2004   AUTEUR ACBHHCD G.DEVESA 
C ======================================================================
C COPYRIGHT (C) 1991 - 2003  EDF R&D                  WWW.CODE-ASTER.ORG
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
      IMPLICIT REAL*8 (A-H,O-Z)
      INTEGER      IFMIS
      INTEGER      IFREQ, NFREQ
      CHARACTER*8  NOMA, NOGR
      REAL*8       RIGMA(*), RIGTO(*)
C      REAL*8       FREQ, RIGMA(*), RIGTO(*)
C     ------------------------------------------------------------------
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER          ZI
      COMMON  /IVARJE/ ZI(1)
      REAL*8           ZR
      COMMON  /RVARJE/ ZR(1)
      COMPLEX*16       ZC
      COMMON  /CVARJE/ ZC(1)
      LOGICAL          ZL
      COMMON  /LVARJE/ ZL(1)
      CHARACTER*8      ZK8
      CHARACTER*16            ZK16
      CHARACTER*24                    ZK24
      CHARACTER*32                            ZK32
      CHARACTER*80                                    ZK80
      COMMON  /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      CHARACTER*32     JEXNOM, JEXNUM
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
C
      CHARACTER*8  K8B
      CHARACTER*8  NOMGR, NOMMAI
      CHARACTER*24 MLGNMA, MAGRMA, MANOMA, TABRIG
      REAL*8       Z0

C
      CALL JEMARQ()
      IFR = IUNIFI('RESULTAT')
C
      MAGRMA = NOMA//'.GROUPEMA'
      MANOMA = NOMA//'.CONNEX'
      MLGNMA = NOMA//'.NOMMAI'
      NOEMAX = 0
      Z0 = 0.D0
C

      CALL JELIRA(JEXNOM(MAGRMA,NOGR),'LONMAX',NB,K8B)
      CALL JEVEUO(JEXNOM(MAGRMA,NOGR),'L',LDGM)
      DO 22 IN = 0,NB-1
         CALL JEVEUO(JEXNUM(MANOMA,ZI(LDGM+IN)),'L',LDNM)
         INOE = ZI(LDNM)
         NOEMAX = MAX(NOEMAX,INOE)
         INOE = ZI(LDNM+1)
         NOEMAX = MAX(NOEMAX,INOE)
 22   CONTINUE
C
C        TABLEAU DE PARTICIPATION DES NOEUDS DE L INTERFACE
C
      CALL WKVECT('&&RIGMI2.PARNO','V V I',NOEMAX,IPARNO)

      DO 23 IN = 0,NB-1
         CALL JEVEUO(JEXNUM(MANOMA,ZI(LDGM+IN)),'L',LDNM)
         INOE = ZI(LDNM)
         ZI(IPARNO+INOE-1) = ZI(IPARNO+INOE-1) + 1
         INOE = ZI(LDNM+1)
         ZI(IPARNO+INOE-1) = ZI(IPARNO+INOE-1) + 1
 23   CONTINUE
C
      NBNO = 0
      DO 25 IJ = 1, NOEMAX
         IF (ZI(IPARNO+IJ-1).EQ.0) GOTO 25
         NBNO = NBNO + 1
  25  CONTINUE
C
      CALL WKVECT('&&RIGMI2.NOEUD','V V I',NBNO,IDNO)
      II = 0
      DO 26 IJ = 1, NOEMAX
         IF (ZI(IPARNO+IJ-1).EQ.0) GOTO 26
         II = II + 1
         ZI(IDNO+II-1) = IJ
  26  CONTINUE
C
C     LECTURE DES RIGIDITES ELEMENTAIRES
C
      TABRIG = '&&ACEARM.RIGM'
      CALL JEEXIN(TABRIG,IRET)
      IF (IRET.EQ.0) CALL IRMIIM(IFMIS,IFREQ,NFREQ,NBNO,TABRIG)      
      CALL JEVEUO(TABRIG,'L',JRIG)
      NBMODE = 3*NBNO
      CALL WKVECT('&&RIGMI2.SOMTOT','V V R',NBMODE,ISOTO)
      CALL WKVECT('&&RIGMI2.SOMPAR','V V R',NBMODE,ISOPA)
      DO 28 I1 = 1, NBNO
      DO 28 I2 = 1, NBNO
         IF (I1.NE.I2) THEN
            ZR(ISOTO+3*I1-3) = ZR(ISOTO+3*I1-3) + 
     +       ZR(JRIG+(3*I2-3)*NBMODE+3*I1-3)
            ZR(ISOTO+3*I1-2) = ZR(ISOTO+3*I1-2) + 
     +       ZR(JRIG+(3*I2-2)*NBMODE+3*I1-2)
            ZR(ISOTO+3*I1-1) = ZR(ISOTO+3*I1-1) + 
     +       ZR(JRIG+(3*I2-1)*NBMODE+3*I1-1)
         ENDIF
  28  CONTINUE
C
      DO 33 IN = 0,NB-1
         IM = ZI(LDGM+IN)
         CALL JEVEUO(JEXNUM(MANOMA,ZI(LDGM+IN)),'L',LDNM)
         DO 37 II = 1, NBNO
            IF (ZI(LDNM).EQ.ZI(IDNO+II-1)) I1 = II
            IF (ZI(LDNM+1).EQ.ZI(IDNO+II-1)) I2 = II
 37      CONTINUE 
         ZR(ISOPA+3*I1-3) = ZR(ISOPA+3*I1-3) + 
     +    ZR(JRIG+(3*I2-3)*NBMODE+3*I1-3)
         ZR(ISOPA+3*I2-3) = ZR(ISOPA+3*I2-3) + 
     +    ZR(JRIG+(3*I2-3)*NBMODE+3*I1-3)
         ZR(ISOPA+3*I1-2) = ZR(ISOPA+3*I1-2) + 
     +    ZR(JRIG+(3*I2-2)*NBMODE+3*I1-2)
         ZR(ISOPA+3*I2-2) = ZR(ISOPA+3*I2-2) + 
     +    ZR(JRIG+(3*I2-2)*NBMODE+3*I1-2)
         ZR(ISOPA+3*I1-1) = ZR(ISOPA+3*I1-1) + 
     +    ZR(JRIG+(3*I2-1)*NBMODE+3*I1-1)
         ZR(ISOPA+3*I2-1) = ZR(ISOPA+3*I2-1) + 
     +    ZR(JRIG+(3*I2-1)*NBMODE+3*I1-1)
 33   CONTINUE
C
      DO 34 IN = 0,NB-1
         IM = ZI(LDGM+IN)
         CALL JEVEUO(JEXNUM(MANOMA,ZI(LDGM+IN)),'L',LDNM)
         DO 38 II = 1, NBNO
            IF (ZI(LDNM).EQ.ZI(IDNO+II-1)) I1 = II
            IF (ZI(LDNM+1).EQ.ZI(IDNO+II-1)) I2 = II
 38      CONTINUE 
         RIGMA(3*IN+1) = 0.25D0*ZR(JRIG+(3*I2-3)*NBMODE+3*I1-3)*
     +    (ZR(ISOTO+3*I1-3)/ZR(ISOPA+3*I1-3) + 
     +     ZR(ISOTO+3*I2-3)/ZR(ISOPA+3*I2-3)+0.D0)
         RIGMA(3*IN+2) = 0.25D0*ZR(JRIG+(3*I2-2)*NBMODE+3*I1-2)*
     +    (ZR(ISOTO+3*I1-2)/ZR(ISOPA+3*I1-2) + 
     +     ZR(ISOTO+3*I2-2)/ZR(ISOPA+3*I2-2)+0.D0)
         RIGMA(3*IN+3) = 0.25D0*ZR(JRIG+(3*I2-1)*NBMODE+3*I1-1)*
     +    (ZR(ISOTO+3*I1-1)/ZR(ISOPA+3*I1-1) + 
     +     ZR(ISOTO+3*I2-1)/ZR(ISOPA+3*I2-1)+0.D0)         
 34   CONTINUE
C
      DO 35 IN = 0,NB-1
         IM = ZI(LDGM+IN)
         R1 = RIGMA(3*IN+1)
         R2 = RIGMA(3*IN+2)
         R3 = RIGMA(3*IN+3)

         RIGTO(3*(IM-1)+1) = R1 + RIGTO(3*(IM-1)+1)
         RIGTO(3*(IM-1)+2) = R2 + RIGTO(3*(IM-1)+2)
         RIGTO(3*(IM-1)+3) = R3 + RIGTO(3*(IM-1)+3)

         R1 = RIGTO(3*(IM-1)+1)
         R2 = RIGTO(3*(IM-1)+2)
         R3 = RIGTO(3*(IM-1)+3)

         RIGMA(3*IN+1) = R1
         RIGMA(3*IN+2) = R2
         RIGMA(3*IN+3) = R3
         CALL JENUNO(JEXNUM(MLGNMA,IM),NOMMAI)
         WRITE(IFR,1000) NOMMAI,Z0,Z0,Z0,Z0,Z0,Z0,R1,Z0,Z0,Z0,Z0,R2,
     +                   Z0,Z0,Z0,Z0,Z0,R3,Z0,Z0,Z0
 35   CONTINUE
C
 1000 FORMAT(2X,'_F ( MAILLE=''',A8,''',',1X,'CARA= ''K_T_L'' , ',
     +      /7X,'VALE=(',7(/1X,3(1X,1PE12.5,',')),/1X,'),',
     +      /'   ),')

 9999 CONTINUE
      CALL JEDETR('&&RIGMI2.PARNO')
      CALL JEDETR('&&RIGMI2.NOEUD')
      CALL JEDETR('&&RIGMI2.SOMTOT')
      CALL JEDETR('&&RIGMI2.SOMPAR')
C
      CALL JEDEMA()
      END
