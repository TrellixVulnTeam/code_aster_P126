      SUBROUTINE CALIRG(IOCC,NDIM,NOMA,LNUNO2,GEOM2,MROTA,LROTA)
      IMPLICIT NONE
C
      INTEGER       IOCC,NDIM
      REAL*8        MROTA(3,3)
      LOGICAL       LROTA
      CHARACTER*8   NOMA
      CHARACTER*(*)  LNUNO2,GEOM2
C
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 29/06/99   AUTEUR CIBHHGB G.BERTRAND 
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
C     BUT : TRAITEMENT DES MOTS CLES LIAISON_MAIL :
C             TRAN/CENTRE/ANGL_NAUT
C
C     IN : IOCC (I) : NUMERO D'OCCURENCE DU MOT CLE FACTEUR
C     IN : NDIM (I) : DIMENSION DE L'ESPACE (2 OU 3)
C     IN : NOMA (K8): NOM DU MAILLAGE
C     IN/JXIN  : LNUNO2 (K*) : NOM D'UN OBJET QUI CONTIENT LA
C                               LISTE DES NUMEROS DES NOEUDS_2
C     IN/JXOUT : GEOM2 (K24) : NOM D'UN OBJET QUI CONTIENDRA LES
C            COORDONNEES DES NOEUDS DU GROUP_NO_2, TRANSFORMEES PAR
C            LA TRANSFORMATION GEOMETRIQUE DONNEE PAR L'UTILISATEUR
C     OUT : MROTA (R(3,3)) : MATRICE DE ROTATION DE LA TRANSFORMATION
C     OUT : LROTA (L) : .TRUE.  : IL EXISTE UNE ROTATION
C                       .FALSE. : IL N'EXISTE PAS DE ROTATION
C-----------------------------------------------------------------------
C
C     ----------- COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER           ZI
      COMMON / IVARJE / ZI(1)
      REAL*8            ZR
      COMMON / RVARJE / ZR(1)
      COMPLEX*16        ZC
      COMMON / CVARJE / ZC(1)
      LOGICAL           ZL
      COMMON / LVARJE / ZL(1)
      CHARACTER*8       ZK8
      CHARACTER*16              ZK16
      CHARACTER*24                       ZK24
      CHARACTER*32                                ZK32
      CHARACTER*80                                         ZK80
      COMMON / KVARJE / ZK8(1), ZK16(1), ZK24(1), ZK32(1), ZK80(1)
      CHARACTER*32      JEXNOM, JEXNUM
C---------------- FIN COMMUNS NORMALISES  JEVEUX  ----------------------
C
      INTEGER       NTRAN,NANGL,NCENTR,NANGMX,IAGEOM,JNUNO2
      INTEGER       IGEOM2,NBNO2,INO2,NUNO2,NNOMX,IER,K,KK
      REAL*8        TRAN(3),ANGL(3),CENTR(3),COOR2(3),ZERO,UN,R8DGRD
      CHARACTER*16  MOTFAC
      CHARACTER*1   KB
C
C ----------------------------------------------------------------------
C
C --- INITIALISATIONS :
C     ---------------
      ZERO   = 0.0D0
      UN     = 1.0D0
      MOTFAC = 'LIAISON_MAIL'
      LROTA  = .FALSE.
C
      DO 10 K = 1,3
C
        TRAN(K)  = ZERO
        ANGL(K)  = ZERO
        CENTR(K) = ZERO
C
        DO 20 KK = 1,3
          IF (K .EQ. KK) THEN
            MROTA(K,K) = UN
          ELSE
            MROTA(K,KK) = ZERO
            MROTA(KK,K) = ZERO
          ENDIF
 20     CONTINUE
 10   CONTINUE
C
C --- LECTURE DE L'ISOMETRIE DE TRANSFORMATION SI ELLE EXISTE :
C     -------------------------------------------------------
      CALL GETVR8(MOTFAC,'TRAN',IOCC,1,NDIM,TRAN,NTRAN)
      IF (NTRAN .LT. 0) THEN
        CALL CODENT(NDIM,'G',KB)
        CALL UTMESS('F','CALIRG','LE MOT CLE "TRAN" SOUS LE MOT CLE'
     +    //' FACTEUR '//MOTFAC//' N''ADMET QUE '//KB//' VALEURS')
      ENDIF
C
      IF (NDIM .EQ. 3) THEN
        NANGMX = 3
      ELSE
        NANGMX = 1
      ENDIF
      CALL GETVR8(MOTFAC,'ANGL_NAUT',IOCC,1,NANGMX,ANGL,NANGL)
      IF (NANGL .LT. 0) THEN
        CALL CODENT(NANGMX,'G',KB)
        CALL UTMESS('F','CALIRG','LE MOT CLE "ANGL_NAUT" SOUS LE MOT'
     +    //' CLE FACTEUR '//MOTFAC//' N''ADMET QUE '//KB//' VALEURS')
      ENDIF
      DO 30 K=1,3
        ANGL(K) = ANGL(K)*R8DGRD()
 30   CONTINUE
C
      CALL GETVR8(MOTFAC,'CENTRE',IOCC,1,NDIM,CENTR,NCENTR)
      IF (NCENTR .LT. 0) THEN
        CALL CODENT(NDIM,'G',KB)
        CALL UTMESS('F','CALIRG','LE MOT CLE "CENTRE" SOUS LE MOT'
     +    //' CLE FACTEUR '//MOTFAC//' N''ADMET QUE '//KB//' VALEURS')
      ENDIF
C
C --- DETERMINATION DE LA MATRICE DE ROTATION DE LA TRANSFORMATION :
C     ------------------------------------------------------------
      IF (NANGL .GE. 1) THEN
        CALL MATROT(ANGL,MROTA)
        LROTA = .TRUE.
      ENDIF
C
C --- DETERMINATION DES COORDONNEES TRANSFORMEES :
C     ------------------------------------------
      CALL DISMOI ('F','NB_NO_MAILLA',NOMA,'MAILLAGE',NNOMX,KB,IER)
      CALL WKVECT(GEOM2,'V V R',3*NNOMX,IGEOM2)
      CALL JEVEUO(NOMA//'.COORDO    .VALE','L',IAGEOM)
C
      CALL JEVEUO(LNUNO2,'L',JNUNO2)
      CALL JELIRA(LNUNO2,'LONUTI',NBNO2,KB)
C
      DO 40 INO2 = 1,NBNO2
        NUNO2 = ZI(JNUNO2+INO2-1)
        CALL PAROTR(NOMA,IAGEOM,NUNO2,0,CENTR,MROTA,TRAN,COOR2)
        DO 50 K = 1,3
          ZR(IGEOM2+3*(NUNO2-1)+K-1) = COOR2(K)
 50     CONTINUE
 40   CONTINUE
C
      END
