      SUBROUTINE EXTRAI(NIN,LCHIN,LPAIN,NOMPAR,LIGREL,OPT,TE)
      IMPLICIT REAL*8 (A-H,O-Z)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 16/07/2002   AUTEUR CIBHHPD D.NUNEZ 
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
C RESPONSABLE                            VABHHTS J.PELLET
C     ARGUMENTS:
C     ----------
      INTEGER NIN,IGR,IEL,OPT,TE
      CHARACTER*(*) LCHIN(*)
      CHARACTER*8 LPAIN(*)
      CHARACTER*19 LIGREL
      CHARACTER*8 NOMPAR
C ----------------------------------------------------------------------
C     ENTREES:
C      IGR   : NUMERO DU GREL SUR LEQUEL ON EXTRAIT (COMMON)
C      LCHIN : LISTE DES NOMS DES CHAMPS "IN"
C      LPAIN : LISTE DES NOMS DES PARAMETRES "IN"
C      NOMPAR: NOM DU PARAMETRE A EXTRAIRE

C ----------------------------------------------------------------------
      CHARACTER*16 OPTION,NOMTE,NOMTM
      COMMON /CAKK01/OPTION,NOMTE,NOMTM
      COMMON /CAII01/IGD,NEC,NCMPMX,IACHIN,IACHLO,IICHIN,IANUEQ,LPRNO,
     &        ILCHLO
      COMMON /CAKK02/TYPEGD
      COMMON /CAII02/IAOPTT,LGCO,IAOPMO,ILOPMO,IAOPNO,ILOPNO,IAOPDS,
     &       IAOPPA,NPARIO,NPARIN,IAMLOC,ILMLOC,IADSGD
      COMMON /CAII04/IACHII,IACHIK,IACHIX
      COMMON /CAII06/IAWLOC,IAWTYP,NBELGR,IGR
      COMMON /CAII08/IEL
      CHARACTER*8 TYPEGD

C     FONCTIONS EXTERNES:
C     -------------------

C     VARIABLES LOCALES:
C     ------------------
      CHARACTER*19 CHIN
      CHARACTER*4 TYPE

C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------

      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL ZL,ETENDU
      COMMON /LVARJE/ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)

C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------


C DEB-------------------------------------------------------------------

      I = INDIK8(LPAIN,NOMPAR,1,NIN)
      IF (I.EQ.0)  CALL UTMESS('F','EXTRAI','STOP1')

      CHIN = LCHIN(I)
      IF (CHIN(1:1).EQ.' ')  CALL UTMESS('E','EXTRAI',
     &  ' ERREUR LORS D''UNE EXTRACTION: '//
     &              'LE CHAMP ASSOCIE AU PARAMETRE : '//NOMPAR//
     &              ' N''EST PAS '//
     &              'DANS LA LISTE DES CHAMPS PARAMETRES.')



C     -- MISE A JOUR DES COMMON CAII01 ET CAKK02:
      IICHIN = I
      IGD = ZI(IACHII-1+11* (I-1)+1)
      NEC = ZI(IACHII-1+11* (I-1)+2)
      NCMPMX = ZI(IACHII-1+11* (I-1)+3)
      IACHIN = ZI(IACHII-1+11* (I-1)+5)
      IANUEQ = ZI(IACHII-1+11* (I-1)+10)
      LPRNO = ZI(IACHII-1+11* (I-1)+11)
      IPARG = INDIK8(ZK8(IAOPPA),NOMPAR,1,NPARIO)
      IACHLO = ZI(IAWLOC-1+7* (IPARG-1)+1)
      ILCHLO = ZI(IAWLOC-1+7* (IPARG-1)+2)
      IMODAT = ZI(IAWLOC-1+7* (IPARG-1)+3)
      LGCATA = ZI(IAWLOC-1+7* (IPARG-1)+4)
      IF ((IACHLO.GE.-2) .AND. (IACHLO.LE.0)) CALL UTMESS('F','EXTRAI',
     &    'STOP 1')
      IF (ILCHLO.EQ.-1) CALL UTMESS('F','EXTRAI','IMPOSSIBLE')
      TYPE = ZK8(IACHIK-1+2* (I-1)+1) (1:4)
      TYPEGD = ZK8(IACHIK-1+2* (I-1)+2)



C     1- MISE A .FALSE. DU CHAMP_LOC.EXIS :
C     -------------------------------------------
      CALL CHLOET(IPARG,ETENDU,JCELD)
      IF (ETENDU) THEN
        LGGREL = ZI(JCELD-1+ZI(JCELD-1+4+IGR)+4)
      ELSE
        LGGREL = NBELGR*LGCATA
      END IF

      DO 777,K=1,LGGREL
        ZL(ILCHLO-1+K)=.FALSE.
 777  CONTINUE

C     2- ON LANCE L'EXTRACTION:
C     -------------------------------------------
      IF (TYPE.EQ.'CART') CALL EXCART(CHIN,LIGREL,IMODAT,IPARG)
      IF (TYPE.EQ.'CHML') CALL EXCHML(CHIN,IMODAT)
      IF (TYPE.EQ.'CHNO') CALL EXCHNO(CHIN,LIGREL,IMODAT,IPARG)
      IF (TYPE.EQ.'RESL') CALL EXRESL(CHIN,IMODAT)

C     POUR L'INSTANT EXCHML/EXRESL TROUVENT TOUJOURS TOUT :
      IF ((TYPE.EQ.'CHML').OR.(TYPE.EQ.'RESL')) THEN
        DO 779,K=1,LGGREL
          ZL(ILCHLO-1+K)=.TRUE.
 779    CONTINUE
      END IF


   30 CONTINUE
      END
