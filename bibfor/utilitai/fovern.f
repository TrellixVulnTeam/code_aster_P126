      SUBROUTINE FOVERN(VECNOM,NBFONC,VECPRO,IER)
      IMPLICIT REAL*8 (A-H,O-Z)
      INTEGER                  NBFONC,       IER
      CHARACTER*(*)     VECNOM(NBFONC),    VECPRO(*)
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 17/12/2002   AUTEUR CIBHHGB G.BERTRAND 
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
C     VERIFICATION DE L'HOMOGENEITE DES PARAMETRES DES FONCTIONS
C     COMPOSANT UNE NAPPE
C     STOCKAGE DE CE PARAMETRE UNIQUE ET DES TYPES DE PROLONGEMENTS
C     ET D'INTERPOLATION DE CHAQUE FONCTION
C     ------------------------------------------------------------------
C IN  VECNOM: VECTEUR DES NOMS DES FONCTIONS
C IN  NBFONC: NOMBRE DE FONCTIONS
C OUT    VECPRO: VECTEUR DESCRIPTEUR DE LA NAPPE
C     ------------------------------------------------------------------
C     OBJETS SIMPLES LUS
C        CHNOM=VECNOM(I)//'.PROL'
C     ------------------------------------------------------------------
C
C     ----------- COMMUNS NORMALISES  JEVEUX  --------------------------
      COMMON/IVARJE/ZI(1)
      COMMON/RVARJE/ZR(1)
      COMMON/CVARJE/ZC(1)
      COMMON/LVARJE/ZL(1)
      COMMON/KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      INTEGER ZI
      REAL*8 ZR
      COMPLEX*16 ZC
      LOGICAL ZL
      CHARACTER*8  ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
C     ------------------------------------------------------------------
      INTEGER      I,JPROF,NBPF
      CHARACTER*24 CHNOM
      CHARACTER*16 PROLGD,INTERP,TYPFON,NOMPF(10)
C     ------------------------------------------------------------------
      CALL JEMARQ()
      CHNOM(20:24) = '.PROL'
      DO 1 I=1,NBFONC
         CHNOM(1:19) = VECNOM(I)
         CALL JEVEUO(CHNOM,'L',JPROF)
         CALL FOPRO1(ZK16(JPROF),0,PROLGD,INTERP)
         CALL FONBPA(CHNOM(1:19),ZK16(JPROF),TYPFON,10,NBPF,NOMPF)
         CALL JELIBE(CHNOM)
         IF (NOMPF(1).NE.'TOUTPARA') THEN
            VECPRO(6)=NOMPF(1)
            GO TO 2
         END IF
    1 CONTINUE
      CALL UTDEBM('E','FOVERN','RIEN QUE DES CONSTANTES POUR UNE NAPPE')
      CALL UTIMPI('L','NOMBRE DE FONCTIONS CONSTANTES',1,NBFONC)
      CALL UTFINM()
      IER=IER+1
    2 CONTINUE
      DO 3 I=1,NBFONC
         CHNOM(1:19) = VECNOM(I)
         CALL JEVEUO(CHNOM,'L',JPROF)
         CALL FOPRO1(ZK16(JPROF),0,PROLGD,INTERP)
         CALL FONBPA(CHNOM(1:19),ZK16(JPROF),TYPFON,10,NBPF,NOMPF)
         CALL JELIBE(CHNOM)
         IF (NOMPF(1).NE.VECPRO(6).AND.NOMPF(1).NE.'TOUTPARA') THEN
            CALL UTDEBM('E','FOVERN','PARAMETRES DIFFERENTS')
            CALL UTIMPK('L','FONCTION',1,VECNOM(I) )
            CALL UTIMPK('S','DE PARAMETRE',1,NOMPF(1))
            CALL UTIMPK('S','AU LIEU DE',1,VECPRO(6))
            CALL UTFINM()
            IER=IER+1
         END IF
         VECPRO(6+2*I-1) = INTERP
         VECPRO(6+2*I  ) = PROLGD
    3 CONTINUE
      CALL JEDEMA()
      END
