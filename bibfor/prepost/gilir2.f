      SUBROUTINE GILIR2 ( NFIC, NIV, NDIM, NBOBO )
      IMPLICIT   REAL*8 (A-H,O-Z)
      INTEGER    NFIC, NIV, NDIM, NBOBO
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF PREPOST  DATE 10/12/1999   AUTEUR D6BHHAM A.M.DONORE 
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
C TOLE CRS_512
C
C     BUT: LIRE LE FICHIER DE MAILLAGE GIBI (PROCEDURE SAUVER) :
C
C     IN : NFIC  : UNITE DE LECTURE
C          NIV   : NUMERO DU NIVEAU GIBI
C     OUT: NDIM  : DIMENSION DU PROBLEME (2D OU 3D)
C          NBOBO : NOMBRE D'OBJETS (AU SENS GIBI)
C
C ----------------------------------------------------------------------
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX --------------------
      INTEGER            ZI
      COMMON  / IVARJE / ZI(1)
      REAL*8             ZR
      COMMON  / RVARJE / ZR(1)
      COMPLEX*16         ZC
      COMMON  / CVARJE / ZC(1)
      LOGICAL            ZL
      COMMON  / LVARJE / ZL(1)
      CHARACTER*8        ZK8
      CHARACTER*16                ZK16
      CHARACTER*24                          ZK24
      CHARACTER*32                                    ZK32
      CHARACTER*80                                              ZK80
      COMMON  / KVARJE / ZK8(1) , ZK16(1) , ZK24(1) , ZK32(1) , ZK80(1)
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX --------------------
C
      REAL*8       R8BID
      INTEGER      NBOBNO, IPILE, NIVO, NBERR, NBOBLU
      CHARACTER*1  ITYP
      CHARACTER*4  K4BID, KBID4
      CHARACTER*6  K6BID
      CHARACTER*14 KBID14
      LOGICAL      LEGRNO
C     ------------------------------------------------------------------
C
      CALL JEMARQ()
C
      LEGRNO = .FALSE.
  1   CONTINUE
      READ(NFIC,1001,END=9997) KBID14, KBID4, ITYP
C
      IF ( KBID14.EQ.'ENREGISTREMENT' .AND. KBID4.EQ.'TYPE' ) THEN
C
         IF ( ITYP .EQ. '4' ) THEN
C
C -- INFORMATIONS GENERALES MAILLAGE ----
C
           READ(NFIC,1002) NIVO, NBERR, NDIM
           IF (NBERR.GT.0) THEN
             CALL UTMESS('A','GILIR2','LE MAILLAGE GIBI EST '
     +          //' PEUT ETRE ERRONE : '
     +          //' IL EST ECRIT : "NIVEAU RREUR N_ERR" '
     +          //' OU N_ERR EST >0 .ON CONTINUE QUAND MEME, '
     +          //' MAIS SI VOUS AVEZ DES PROBLEMES PLUS LOIN ...' )
           END IF
           READ(NFIC,1003) R8BID
           GOTO 1
C
        ELSEIF ( ITYP .EQ. '7' ) THEN
C
C -- INFORMATIONS GENERALES CASTEM 2000 ----
C
           READ(NFIC,1004)
           READ(NFIC,1004)
           GOTO 1
C
        ELSEIF ( ITYP .EQ. '5' ) THEN
C
C          -- ON A TOUT LU ----
C
           GOTO 9997
C
        ELSEIF ( ITYP .EQ. '2' ) THEN
C
C -- LECTURE D'UNE PILE  ----
C
          IF(NIV.EQ.3.OR.NIV.EQ.4.OR.NIV.EQ.5.OR.NIV.EQ.6) THEN
             READ(NFIC,1005) K4BID,K6BID,IPILE,NBOBNO,NBOBLU
          ELSEIF(NIV.EQ.8.OR.NIV.EQ.9.OR.NIV.EQ.10
     +             .OR.NIV.EQ.11) THEN
             READ(NFIC,1006) K4BID,K6BID,IPILE,NBOBNO,NBOBLU
          ENDIF
C
C
          IF ( IPILE .EQ. 0 ) THEN
C
C            --- LECTURE DES GROUPES DE NOEUDS NOMMES ---
             LEGRNO = .TRUE.
             CALL GILIG2 ( NFIC, NDIM, NBOBNO, NIV )
C
C            --- LECTURE DES COORDONNEES ---
             NBVAL = NBOBLU * ( NDIM + 1 )
             CALL GILIG1 ( NFIC, NDIM, NBVAL, NBOBLU )
C
             NBNOTO = NBOBLU
C
            CALL JEEXIN ( '&&GILIRE.INDIRECT', IRET)
            IF (IRET.EQ.0) THEN
              CALL WKVECT ( '&&GILIRE.INDIRECT' , 'V V I' ,NBOBLU ,
     +                   IAPTIN )
              DO 10 I = 1, NBOBLU
                ZI(IAPTIN+I-1) = I
  10          CONTINUE
            ENDIF
            GOTO 1
C
          ELSEIF ( IPILE .EQ. 32 ) THEN
C
C            --- LECTURE DES GROUPES DE NOEUDS NOMMES ---
             IF ( LEGRNO ) GOTO 1
             CALL GILIG3 ( NFIC, NDIM, NBOBNO, NIV, NBOBLU )
             GOTO 1
C
          ELSEIF ( IPILE .EQ. 33 ) THEN
C
            READ(NFIC,1010) NBVAL
C
C            --- LECTURE DES COORDONNEES ---
            NBOBLU = NBVAL / ( NDIM + 1 )
            CALL GILIG1 ( NFIC, NDIM, NBVAL, NBOBLU )
            NBNOTO = NBOBLU
C
            GOTO 1
C
          ELSEIF ( IPILE .EQ. 1 ) THEN
C
C            --- LECTURE DES GROUPES DE MAILLES NOMMEES ---
            CALL GILIG0 ( NFIC, NBOBLU, NBOBNO, NBOBO, NIV )
            GOTO 1
          ENDIF
C
        ENDIF
        GOTO 1
C
      ELSE
        GOTO 1
      ENDIF
C
 9997 CONTINUE
C
C     -- ON CREE .CONNEX2:
      CALL GICNX2 ( )
C
C     -- ON CREE .NUMANEW:
      CALL GIDOMA ( NBNOTO )
C
 9998 CONTINUE
C
 9999 CONTINUE
C
 1001  FORMAT(1X,A14,4X,A4,3X,A1)
 1002  FORMAT(7X,I4,14X,I4,10X,I4)
 1003  FORMAT(8X,D12.5)
 1004  FORMAT(10X)
 1005  FORMAT(1X,A4,1X,A6,I4,18X,I5,11X,I5)
 1006  FORMAT(1X,A4,1X,A6,I4,18X,I8,11X,I8)
 1010  FORMAT(1X,I7)
C
      CALL JEDEMA()
      END
