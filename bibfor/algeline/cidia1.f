      SUBROUTINE CIDIA1(TYPRES,LRES)
      IMPLICIT REAL*8 (A-H,O-Z)
      INTEGER LRES
      CHARACTER*(*) TYPRES
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGELINE  DATE 01/02/2000   AUTEUR VABHHTS J.PELLET 
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
C     MISE A 1 DES TERMES DIAGONAUX DES LIGNES ELIMINEES
C     DE LA MATRICE DONT L'ADRESSE DU DESCRIPTEUR EST LRES
C     -----------------------------------------------------------------
C IN   K* TYPRES = TYPE DES MATRICES   (R OU C)
C VAR  I  LRES   = POINTEUR DE LA MATRICE DONT ON REND EGAL A 1
C                  LES TERMES DIAGONAUX DES LIGNES ELIMINEES

C     -----------------------------------------------------------------

C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
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
      CHARACTER*32 JEXNUM
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------

C     -----------------------------------------------------------------
C     NBBLOC = NOMBRE DE BLOCS POUR CONSTITUER UNE MATRICE (.VALE)
      INTEGER NBBLOC,TYPSYM
C     -----------------------------------------------------------------
      CHARACTER*19 MATRES
      CHARACTER*24 VALER

      COMPLEX*16 CUN
C     -----------------------------------------------------------------
      CALL JEMARQ()

      UN = 1.0D0
      CUN = (1.0D0,0.0D0)

      MATRES = ZK24(ZI(LRES+1))
      VALER = MATRES//'.VALE'
      NBBLOC = ZI(LRES+13)

      CALL JEVEUO(MATRES//'.CONI','L',IDCONI)

      TYPSYM = ZI(LRES+4)
      CALL MTDSC2(ZK24(ZI(LRES+1)),'ABLO','L',IDABLO)
      CALL MTDSC2(ZK24(ZI(LRES+1)),'ADIA','L',IDADIA)

C --- BOUCLE SUR LES BLOCS DE LA MATRICE RESULTAT

      DO 50 IBLOC = 1,NBBLOC

        CALL JEVEUO(JEXNUM(VALER,IBLOC),'E',IATRES)
        IF (TYPSYM.EQ.0) THEN
          CALL JEVEUO(JEXNUM(VALER,IBLOC+NBBLOC),'E',IATREI)
        END IF

        IL1 = ZI(IDABLO+IBLOC-1) + 1
        IL2 = ZI(IDABLO+IBLOC)
        IF (TYPRES(1:1).EQ.'R') THEN
          DO 10 IEQUA = IL1,IL2
            IF (ZI(IDCONI+IEQUA-1).EQ.1) THEN
              ZR(IATRES+ZI(IDADIA+IEQUA-1)-1) = UN
            END IF
   10     CONTINUE

          IF (TYPSYM.EQ.0) THEN
            DO 20 IEQUA = IL1,IL2
              IF (ZI(IDCONI+IEQUA-1).EQ.1) THEN
                ZR(IATREI+ZI(IDADIA+IEQUA-1)-1) = UN
              END IF
   20       CONTINUE
          END IF
        ELSE IF (TYPRES(1:1).EQ.'C') THEN
          DO 30 IEQUA = IL1,IL2
            IF (ZI(IDCONI+IEQUA-1).EQ.1) THEN
              ZC(IATRES+ZI(IDADIA+IEQUA-1)-1) = CUN
            END IF
   30     CONTINUE

          IF (TYPSYM.EQ.0) THEN
            DO 40 IEQUA = IL1,IL2
              IF (ZI(IDCONI+IEQUA-1).EQ.1) THEN
                ZC(IATREI+ZI(IDADIA+IEQUA-1)-1) = CUN
              END IF
   40       CONTINUE
          END IF
        END IF
        CALL JELIBE(JEXNUM(VALER,IBLOC))
        IF (TYPSYM.EQ.0) THEN
          CALL JELIBE(JEXNUM(VALER,IBLOC+NBBLOC))
        END IF
   50 CONTINUE

      CALL JELIBE(MATRES//'.CONI')


      CALL JEDEMA()
      END
