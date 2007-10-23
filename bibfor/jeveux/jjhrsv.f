      SUBROUTINE JJHRSV(IDTS,NBVAL,IADMI)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF JEVEUX  DATE 23/10/2007   AUTEUR LEFEBVRE J-P.LEFEBVRE 
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
C TOLE CRP_18 CRS_508 CRS_512 CRS_513 CRS_505
      IMPLICIT NONE
      INTEGER            IDTS,NBVAL,IADMI
C ----------------------------------------------------------------------
C RELIT UN SEGMENT DE VALEURS ASSOCIE A UN OBJET JEVEUX, LE TYPE INTEGER
C EST TRAITE DE FACON PARTICULIERE POUR S'AJUSTER A LA PLATE-FORME
C
C IN  IDTS   : IDENTIFICATEUR DU DATASET HDF
C IN  NBVAL  : NOMBRE DE VALEURS DU DATASET
C IN  IADMI  : ADRESSE DANS JISZON DU TABLEAU DE VALEURS LUES
C ----------------------------------------------------------------------
      CHARACTER*1      K1ZON
      COMMON /KZONJE/  K1ZON(8)
      INTEGER          LK1ZON , JK1ZON , LISZON , JISZON , ISZON(1)
      COMMON /IZONJE/  LK1ZON , JK1ZON , LISZON , JISZON
      EQUIVALENCE    ( ISZON(1) , K1ZON(1) )
      INTEGER          LBIS , LOIS , LOLS , LOUA , LOR8 , LOC8
      COMMON /IENVJE/  LBIS , LOIS , LOLS , LOUA , LOR8 , LOC8
      INTEGER          ISTAT
      COMMON /ISTAJE/  ISTAT(4)
      INTEGER          LDYN , LGDYN , NBDYN , NBFREE
      COMMON /IDYNJE/  LDYN , LGDYN , NBDYN , NBFREE
      REAL *8          MXDYN , MCDYN , MLDYN , VMXDYN  
      COMMON /RDYNJE/  MXDYN , MCDYN , MLDYN , VMXDYN 
C---------- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER            ZI
      COMMON  / IVARJE / ZI(1)
C ----------------------------------------------------------------------
      INTEGER          IRET,JADR,KADM,NBV,K,LONOI,LTYPI,IBID
      INTEGER          HDFTSD,HDFRSV,HDFCLD,IR,KITAB,ICONV,IADYN
      CHARACTER*1      TYPEI
C DEB ------------------------------------------------------------------
      ICONV = 0
      IRET = HDFTSD(IDTS,TYPEI,LTYPI,NBV)
      IF (IRET .NE. 0) THEN
        CALL U2MESS('F','JEVEUX_52')
      ENDIF
      IF ( TYPEI .EQ. 'I' ) THEN
        ICONV = 1
        IF ( LOIS .LT. LTYPI ) THEN
          LONOI = NBVAL*LTYPI
          CALL JJALLS(LONOI,'V',TYPEI,LOIS,'INIT',ZI,JADR,KADM,IADYN)
          ISZON(JISZON+KADM-1) = ISTAT(2)
          ISZON(JISZON+ISZON(JISZON+KADM-4)-4) = ISTAT(4)
          IR = ISZON(JISZON + KADM - 3 )
          KITAB = JK1ZON+(KADM-1)*LOIS+IR+1
          IRET = HDFRSV(IDTS,NBV,K1ZON(KITAB),ICONV)
          DO 1 K=1,NBV
            ISZON(JISZON+IADMI-1+K)=ISZON(JISZON+KADM-1+K)
 1        CONTINUE
          IF (IADYN .NE. 0) THEN
            MCDYN = MCDYN - LONOI
            MLDYN = MLDYN + LONOI
            CALL HPDEALLC (IADYN, NBFREE, IBID)
          ELSE IF (KADM .NE. 0) THEN
            CALL JJLIBP (KADM)
          ENDIF
        ELSE
          IR = ISZON(JISZON + IADMI - 3 )
          KITAB = JK1ZON+(IADMI-1)*LOIS+IR+1
          IRET = HDFRSV(IDTS,NBV,K1ZON(KITAB),ICONV)
        ENDIF
      ELSE
        IR    = ISZON(JISZON+IADMI-3)
        KITAB = JK1ZON+(IADMI-1)*LOIS+IR+1
        IRET = HDFRSV(IDTS,NBV,K1ZON(KITAB),ICONV)
      ENDIF
      IF (IRET .NE. 0) THEN
        CALL U2MESS('F','JEVEUX_53')
      ENDIF
      IRET = HDFCLD(IDTS)
C FIN ------------------------------------------------------------------
      END
