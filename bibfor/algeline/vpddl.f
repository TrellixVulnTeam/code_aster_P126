      SUBROUTINE VPDDL(RAIDE, MASSE, NEQ, NBLAGR, NBCINE, NEQACT,
     &                 DLAGR, DBLOQ, IER, TYPE)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGELINE  DATE 10/03/98   AUTEUR VABHHTS J.PELLET 
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
      IMPLICIT NONE
      CHARACTER*19 MASSE, RAIDE
      INTEGER      NEQ, NBLAGR, NBCINE, NEQACT, DLAGR(NEQ), DBLOQ(NEQ),
     &             IER
      CHARACTER*1  TYPE
C
C     ------------------------------------------------------------------
C     RENSEIGNEMENTS SUR LES DDL : LAGRANGE, BLOQUE, EXCLUS.
C     CONSTRUCTION DE TABLEAUX D'ENTIERS REPERANT LA POSITION DE CES DDL
C     ------------------------------------------------------------------
C IN  RAIDEUR : K  : NOM DE LA MATRICE DE "RAIDEUR"
C IN  MASSE   : K  : NOM DE LA MATRICE DE "MASSE"
C IN  NEQ     : IS : NPMBRE DE DDL
C OUT NBLAGR  : IS : NOMBRE DE DDL DE LAGRANGE
C OUT NBCINE  : IS : NOMBRE DE DDL BLOQUES PAR AFFE_CHAR_CINE
C OUT NEQACT  : IS : NOMBRE DE DDL ACTIFS
C OUT DLAGR   : IS : POSITION DES DDL DE LAGRANGE
C OUT DBLOQ   : IS : POSITION DES DDL BLOQUES PAR AFFE_CHAR_CINE
C IN  TYPE    : K  : NATURE DU PROBLEME : GENE. (R) QUADRA (C)
C
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
      CHARACTER*32 JEXNUM,JEXNOM,JEXR8,JEXATR
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8  ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------
C

      INTEGER      IBID, IERD, IDCONI,IERCON, NBPRNO, NBEXCL, NBT,
     &             LEXCL, LDDLEX, LD, IEXCL, IEQ, L, MXDDL, NBA,
     &             NBB, NBL, NBLIAI,IFM,NIV
      CHARACTER*14 NUME
      PARAMETER    (MXDDL=1)
      CHARACTER*8  NOMDDL(MXDDL), K8BID
C
      DATA NOMDDL/'LAGR'/
C
C     ------------------------------------------------------------------
C     ------------------------------------------------------------------
C
      CALL JEMARQ()

C     ---RECUPERATION DU NIVEAU D'IMPRESSION---
      CALL INFNIV(IFM,NIV)
C     -----------------------------------------

C     --- CALCUL DU NOMBRE DE LAGRANGES ---
C     -------------------------------------
C
C       --- RECUPERATION DU NOM DE LA NUMEROTATION ASSOCIEE AUX MATRICES
        CALL DISMOI('F','NOM_NUME_DDL',RAIDE,'MATR_ASSE',IBID,NUME,IERD)
C
C       --- RECUPERATION DES POSITIONS DES DDL LAGRANGE : DLAGR
        CALL PTEDDL('NUME_DDL',NUME,MXDDL,NOMDDL,NEQ,DLAGR)
C
C       --- CALCUL DU NOMBRE DE 'LAGRANGE': NBLAGR
        NBLAGR = 0
        DO 10 IEQ = 1, NEQ
           NBLAGR = NBLAGR + DLAGR(IEQ)
  10    CONTINUE
C
C       --- INVERSION : DLAGR = 0 SI LAGRANGE ET 1 SINON
        DO 20 IEQ = 1 ,NEQ
           DLAGR(IEQ) = ABS(DLAGR(IEQ)-1)
  20    CONTINUE
C
C     --- DETECTION DES DDL BLOQUES PAR AFFE_CHAR_CINE ---
C     ----------------------------------------------------
C
        CALL TYPDDL('ACLA',NUME,NEQ,DBLOQ,NBA,NBB,NBL,NBLIAI)
C
C       --- MISE A JOUR DE DBLOQ QUI VAUT 0 POUR TOUS LES DDL BLOQUES
        CALL JEEXIN(MASSE//'.CONI',IERCON)
        NBCINE = 0
        IF (IERCON.NE.0) THEN
           CALL JEVEUO(MASSE//'.CONI','E',IDCONI)
           DO 40 IEQ = 1, NEQ
              DBLOQ(IEQ) = DBLOQ(IEQ) * ABS(ZI(IDCONI+IEQ-1)-1)
 40        CONTINUE
C
C       --- CALCUL DU NOMBRE DE DDL BLOQUE PAR CETTE METHODE : NCINE ---
           DO 50 IEQ = 1, NEQ
              NBCINE = NBCINE + ZI(IDCONI+IEQ-1)
 50        CONTINUE
        ENDIF
C
C     --- SI NUMEROTATION GENERALISEE : PAS DE DDLS BLOQUES ---
C     ---------------------------------------------------------
        CALL JENONU(JEXNOM(NUME//'.NUME.LILI','&SOUSSTR'),NBPRNO)
        IF (NBPRNO.NE.0) THEN
           DO 60 IEQ = 1, NEQ
              DBLOQ(IEQ) = 1
 60        CONTINUE
        ENDIF
C
C     ----------------- CALCUL DU NOMBRE DE DDL ACTIFS -----------------
      NEQACT = NEQ - 3 * (NBLAGR/2) - NBCINE
      IF (NEQACT.LE.0) CALL UTMESS('F','VPDDL',
     +               'LE SYSTEME A RESOUDRE N''A PAS DE DDL ACTIF.')

     C
C    -----IMPRESSION DES DDL -----
C
      IF (NIV .GE. 1) THEN
        WRITE(IFM,1000)
        WRITE(IFM,1100) NEQ
        WRITE(IFM,1200) NBLAGR
       IF (NBCINE .NE. 0) THEN
          WRITE(IFM,1300) NBCINE
       ENDIF
        WRITE(IFM,1400) NEQACT
      ENDIF
C     -----------------------------------------------------------------
 1000 FORMAT(//,72('-'),/, 'LE NOMBRE DE DDL',/)
 1100 FORMAT(3X,'TOTAL EST:',18X,I7,/)
 1200 FORMAT(3X,'DE LAGRANGE EST:',12X,I7,/)
 1300 FORMAT(3X,'BLOQUES CINEMATIQUEMENT:',4X,I7,//)
 1400 FORMAT( 'LE NOMBRE DE DDL ACTIFS EST:',3X,I7,/,72('-'))
C     -----------------------------------------------------------------


      CALL JEDETC('V','&&VPDDL',1)
      IER=0
      CALL JEDEMA()
      END
