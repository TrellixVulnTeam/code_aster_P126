      SUBROUTINE VELAME(MODELE,CHARGE,INFCHA,INSTAP,DEPMOI,DEPDEL,
     &                  VECELZ)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 11/09/2002   AUTEUR VABHHTS J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
C (AT YOUR OPTION) ANY LATER VERSION.

C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.

C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
      IMPLICIT REAL*8 (A-H,O-Z)
      CHARACTER*(*) VECELZ
      CHARACTER*24 MODELE,CHARGE,INFCHA,DEPMOI,DEPDEL
      REAL*8 INSTAP
C ----------------------------------------------------------------------
C     CALCUL DES VECTEURS ELEMENTAIRES DES FORCES DE LAPLACE
C     PRODUIT UN VECT_ELEM DEVANT ETRE ASSEMBLE PAR LA ROUTINE ASASVE

C IN  MODELE  : NOM DU MODELE
C IN  CHARGE  : LISTE DES CHARGES
C IN  INFCHA  : INFORMATIONS SUR LES CHARGEMENTS
C IN  INSTAP  : INSTANT DU CALCUL
C IN  DEPMOI  : DEPLACEMENT A L'INSTANT TEMMOI
C IN  DEPDEL  : INCREMENT DE DEPLACEMENT AU COURS DES ITERATIONS
C OUT/JXOUT  VECELZ  : VECT_ELEM RESULTAT.

C   ATTENTION :
C   -----------
C   LE VECT_ELEM (VECELZ) RESULTAT A 2 PARTICULARITES :
C   1) LE NOM DES RESUELEM COMMENCE PAR '&&ASASVE.'
C   2) LES RESUELEM VERIFIENT LA  PROPRIETE :
C      AU CHARGEMENT ELEMENTAIRE
C      (ICHA=0 SI IL N'Y A PAS DE CHARGE)

C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------

      CHARACTER*32 JEXNUM,JEXNOM,JEXR8,JEXATR
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

C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------
      CHARACTER*8 NOMCHA,VECEL,LPAIN(3),PAOUT,K8BID,VECELE
      CHARACTER*8 LCMP(2),NEWNOM
      CHARACTER*16 OPTION
      CHARACTER*19 RESUEL
      CHARACTER*24 CHGEOM,CHLAPL,CHGEO2
      CHARACTER*24 LIGRMO,LIGRCH,LCHIN(3),KCMP(2)
      INTEGER IBID,IRET,NCHAR,ILVE
      REAL*8 ALPHA,TIME
      LOGICAL EXIGEO,BIDON
      COMPLEX*16 CBID

      CALL JEMARQ()
      NEWNOM = '.0000000'

      VECELE = '&&VELAME'
      RESUEL = '&&VELAME.???????'

      BIDON = .TRUE.
      LONLIS = 0
      CALL JEEXIN(CHARGE,IRET)
      IF (IRET.NE.0) THEN
        CALL JELIRA(CHARGE,'LONMAX',NCHAR,K8BID)
        IF (NCHAR.NE.0) THEN
          BIDON = .FALSE.
          CALL JEVEUO(CHARGE,'L',JCHAR)
          CALL JEVEUO(INFCHA,'L',JINF)
          LONLIS = (ZI(JINF+2*NCHAR+2))*NCHAR
          IF (LONLIS.EQ.0) BIDON = .TRUE.
        END IF
      END IF


C     -- ALLOCATION DU VECT_ELEM RESULTAT :
C     -------------------------------------
      CALL DETRSD('VECT_ELEM',VECELE)
      CALL MEMARE('V',VECELE,MODELE(1:8),' ',' ','CHAR_MECA')
      IF (BIDON) THEN
        CALL WKVECT(VECELE//'.LISTE_RESU','V V K24',1,JLVE)
        CALL JEECRA(VECELE//'.LISTE_RESU','LONUTI',0,K8BID)
        GO TO 40
      ELSE
        CALL WKVECT(VECELE//'.LISTE_RESU','V V K24',LONLIS,JLVE)
        CALL JEECRA(VECELE//'.LISTE_RESU','LONUTI',0,K8BID)
      END IF


      LIGRMO = MODELE(1:8)//'.MODELE'
      CALL MEGEOM(MODELE(1:8),ZK24(JCHAR) (1:8),EXIGEO,CHGEOM)

C     REACTUALISATION DE LA GEOMETRIE SI DEPMOI EXISTE
      IF (DEPMOI.NE.' ') THEN
        CHGEO2 = '&&VELAME.CH_GEOMER'
        ALPHA = 1.0D0
        CALL VTGPLD(CHGEOM,ALPHA,DEPMOI,'V',CHGEO2)
      ELSE
        CHGEO2 = CHGEOM
      END IF


      OPTION = 'CHAR_MECA_FRLAPL'
      LPAIN(1) = 'PFLAPLA'
      LPAIN(2) = 'PGEOMER'
      LCHIN(2) = CHGEO2
      LPAIN(3) = 'PLISTMA'
      PAOUT = 'PVECTUR'

      IFLA = 0
      ILVE = 0
      DO 30 ICHA = 1,NCHAR
        NOMCHA = ZK24(JCHAR+ICHA-1) (1:8)
        LIGRCH = NOMCHA//'.CHME.LIGRE'
        LCHIN(3) (1:17) = LIGRCH(1:13)//'.FL1'
        DO 10 J = 1,99
          CALL CODENT(J,'D0',LCHIN(3) (18:19))
          LCHIN(3) = LCHIN(3) (1:19)//'.DESC'
          CALL EXISD('CHAMP_GD',LCHIN(3),IRET)
          IF (IRET.NE.0) THEN
            IF (IFLA.EQ.0) THEN
              CHLAPL = '&&VELAME.CH_FLAPLA'
              LCMP(1) = 'NOMAIL'
              LCMP(2) = 'NOGEOM'
              KCMP(1) = CHGEOM(1:8)
              KCMP(2) = CHGEO2(1:19)
              CALL MECACT('V',CHLAPL,'MODELE',MODELE,'FLAPLA  ',2,LCMP,
     &                    IBID,TIME,CBID,KCMP)
              LCHIN(1) = CHLAPL
              IFLA = 1
            END IF
            CALL GCNCO2(NEWNOM)
            RESUEL(10:16) = NEWNOM(2:8)
            CALL CORICH('E',RESUEL,ICHA,IBID)

            CALL CALCUL('S',OPTION,LIGRMO,3,LCHIN,LPAIN,1,RESUEL,PAOUT,
     &                  'V')
            ILVE = ILVE + 1
            ZK24(JLVE-1+ILVE) = RESUEL
          ELSE
            GO TO 20
          END IF
   10   CONTINUE
   20   CONTINUE
        CALL JEECRA(VECELE//'.LISTE_RESU','LONUTI',ILVE,K8BID)

   30 CONTINUE

   40 CONTINUE
      VECELZ = VECELE

      CALL JEDEMA()
      END
