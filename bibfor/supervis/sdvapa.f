       SUBROUTINE SDVAPA(NOMSD,TYPSD,NOMPA,IORDR,ITYPE,RVAL,IVAL,KVAL)
       IMPLICIT NONE
       CHARACTER*(*) NOMSD,TYPSD,NOMPA,KVAL
       INTEGER IORDR,ITYPE,IVAL
       REAL*8 RVAL(2)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF SUPERVIS  DATE 09/05/2001   AUTEUR YESSAYAN A.YESSAYAN 
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
C -------------------------------------------------------------
C FONCTION :
C     POUR LA SD DE NOM NOMSD ET DE TYPE TYPSD
C     RECUPERATION DE LA VALEUR DU PARAMETRE NOMPA POUR LE
C     NUMERO D ORDRE IORDR
C IN  : NOMSD : K19  : NOM DE LA STRUCTURE DE DONNEES
C IN  : TYPSD : K19  : TYPE DE LA STRUCTURE DE DONNEES
C                          'TABLE' OU 'RESULTAT'
C IN  : NOMPA : K16  : NOM DU PARAMETRE
C IN  : IORDR : I    : NUMERO D ORDRE
C OUT : ITYPE : I    : TYPE 0=INEXISTANT,1=REEL,2=ENTIER,3=COMPLEXE,
C                          4=K8,5=K16,6=K24,7=K32,8=K80
C                          -1=DEMANDE IMPOSSIBLE A SATISFAIRE
C OUT : RVAL  : R(2) : VALEUR R(1) SI TYPE REEL (1),
C                             R(1),R(2) SI COMPLEXE (3)
C OUT : IVAL  : I    : VALEUR SI TYPE ENTIER (2)
C OUT : KVAL  : K    : VALEUR SI TYPE CHARACTER (4,5,6,7,8)
C REMARQUE : SI ITYPE = 0, LA VALEUR N'EXISTE PAS. CE CAS DE FIGURE SE
C       RENCONTRE DANS LES TABLES OU IL PEUT EXISTER DES TROUS
C -------------------------------------------------------------
C --------------- COMMUNS NORMALISES  JEVEUX  --------------------------
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
      CHARACTER*32 JEXNUM,JEXNOM,JEXATR,JEXR8
C ---------------- FIN COMMUNS NORMALISES  JEVEUX  -------------------
      CHARACTER*8 CTYPE
      INTEGER IAD
      ITYPE=-1
      IF(TYPSD.EQ.'TABLE')THEN
        CALL TBADPA(NOMSD,NOMPA,IORDR,ITYPE,RVAL,IVAL,KVAL)
      ELSE IF(TYPSD.EQ.'RESULTAT')THEN
        ITYPE=0
        CTYPE='     '
        CALL RSADPA(NOMSD,'L',1,NOMPA,IORDR,1,IAD,CTYPE)
        IF(CTYPE.EQ.'R')THEN
          ITYPE=1
          RVAL(1)=ZR(IAD)
        ELSE IF(CTYPE.EQ.'I')THEN
          ITYPE=2
          IVAL=ZI(IAD)
        ELSE IF(CTYPE.EQ.'C')THEN
          ITYPE=3
          RVAL(1)=DBLE(ZC(IAD))
          RVAL(2)=DIMAG(ZC(IAD))
        ELSE IF(CTYPE.EQ.'K8')THEN
          ITYPE=4
          KVAL=ZK8(IAD)
        ELSE IF(CTYPE.EQ.'K16')THEN
          ITYPE=5
          KVAL=ZK16(IAD)
        ELSE IF(CTYPE.EQ.'K24')THEN
          ITYPE=6
          KVAL=ZK24(IAD)
        ELSE IF(CTYPE.EQ.'K32')THEN
          ITYPE=7
          KVAL=ZK32(IAD)
        ELSE IF(CTYPE.EQ.'K80')THEN
          ITYPE=8
          KVAL=ZK80(IAD)
        ELSE
          ITYPE=-1
        ENDIF
      ELSE
        ITYPE=-1
      ENDIF
      END
