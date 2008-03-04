      SUBROUTINE NUMMO1(NUGENE,MODMEC,NBMODE,TYPROF)
      IMPLICIT    NONE
      INTEGER NBMODE
      CHARACTER*8 MODMEC
      CHARACTER*(*) TYPROF
      CHARACTER*14 NUGENE
      CHARACTER*19 PRGENE,STOMOR
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 21/02/2008   AUTEUR ANDRIAM H.ANDRIAMBOLOLONA 
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
C-----------------------------------------------------------------------
C    BUT: < NUMEROTATION GENERALISEE >
C
C    DETERMINER LA NUMEROTATION GENERALISEE A PARTIR D'UN MODE_MECA
C    OU D'UN MODE_GENE
C
C IN : NUGENE : NOM K14 DU NUME_DDL_GENE
C IN : MODMEC : NOM K8 DU MODE_MECA OU DU MODE_GENE
C IN : NBMODE : NOMBRE DE MODES
C IN : TYPROF : TYPE DE STOCKAGE
C-----------------------------------------------------------------------
C-------- DEBUT COMMUNS NORMALISES  JEVEUX  ----------------------------
C
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
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      CHARACTER*32 JEXNUM,JEXNOM
C
C----------  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
C
      INTEGER IBID,JREFN,JDESC,LDNEQU,LDORS,LDPRS,LDORL,LDPRL,LDDEEQ,
     &        LDNUEQ,J,LDDELG
C     ------------------------------------------------------------------
C
      CALL JEMARQ()
      PRGENE=NUGENE//'.NUME'
      STOMOR=NUGENE//'.SMOS'
C
C-----CREATION DU .REFN
C
      CALL WKVECT(PRGENE//'.REFN','G V K24',4,JREFN)
      ZK24(JREFN)=MODMEC
      ZK24(JREFN+1)='DEPL_R'
C
C-----CREATION DU .DESC
C
      CALL WKVECT(PRGENE//'.DESC','G V I',1,JDESC)
      ZI(JDESC)=2
C
C---------------------------DECLARATION JEVEUX--------------------------
C
C     CREATION DE LA COLLECTION .LILI
C
      CALL JECREO(PRGENE//'.LILI','G N K8')
      CALL JEECRA(PRGENE//'.LILI','NOMMAX',2,' ')
      CALL JECROC(JEXNOM(PRGENE//'.LILI','&SOUSSTR'))
      CALL JECROC(JEXNOM(PRGENE//'.LILI','LIAISONS'))
C
C     CREATION DES COLLECTIONS
C
      CALL JECREC(PRGENE//'.PRNO','G V I','NU','DISPERSE','VARIABLE',2)
      CALL JECREC(PRGENE//'.ORIG','G V I','NU','DISPERSE','VARIABLE',2)
C
C------RECUPERATION DES DIMENSIONS PRINCIPALES
C
      CALL WKVECT(PRGENE//'.NEQU','G V I',1,LDNEQU)
      ZI(LDNEQU)=NBMODE
C
C-----ECRITURE DIMENSIONS
C
      CALL JENONU(JEXNOM(PRGENE//'.LILI','&SOUSSTR'),IBID)

      CALL JEECRA(JEXNUM(PRGENE//'.PRNO',IBID),'LONMAX',2,' ')
      CALL JEVEUO(JEXNUM(PRGENE//'.PRNO',IBID),'E',LDPRS)

      CALL JEECRA(JEXNUM(PRGENE//'.ORIG',IBID),'LONMAX',2,' ')
      CALL JEVEUO(JEXNUM(PRGENE//'.ORIG',IBID),'E',LDORS)

      CALL JENONU(JEXNOM(PRGENE//'.LILI','LIAISONS'),IBID)

      CALL JEECRA(JEXNUM(PRGENE//'.PRNO',IBID),'LONMAX',2,' ')
      CALL JEVEUO(JEXNUM(PRGENE//'.PRNO',IBID),'E',LDPRL)

      CALL JEECRA(JEXNUM(PRGENE//'.ORIG',IBID),'LONMAX',2,' ')
      CALL JEVEUO(JEXNUM(PRGENE//'.ORIG',IBID),'E',LDORL)
C
      ZI(LDORS)=1
      ZI(LDPRS)=1
      ZI(LDPRS+1)=NBMODE
      ZI(LDORL)=1
      ZI(LDORL+1)=1
      ZI(LDPRL)=0
      ZI(LDPRL+1)=0
C
C-----BOUCLES DE COMPTAGE DES DDL
C
C
C-----ALLOCATIONS DIVERSES
C
      CALL WKVECT(PRGENE//'.DELG','G V I',NBMODE,LDDELG)
      CALL WKVECT(PRGENE//'.DEEQ','G V I',NBMODE*2,LDDEEQ)
      CALL WKVECT(PRGENE//'.NUEQ','G V I',NBMODE,LDNUEQ)
C
C     REMPLISSAGE DU .DEEQ ET DU .NUEQ
C
      DO 10 J=1,NBMODE
        ZI(LDNUEQ+J-1)=J
        ZI(LDDELG+J-1)=0
        ZI(LDDEEQ+2*J-1)=1
        ZI(LDDEEQ+2*J-2)=J
   10 CONTINUE


C     CREATION DU STOCKAGE MORSE :
      CALL CRSMOS(STOMOR,TYPROF,NBMODE)

      CALL JEDEMA()
      END
