      SUBROUTINE FROT07 ( LMAT, XMAX )
      IMPLICIT   NONE
      INTEGER             LMAT
      REAL*8              XMAX
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 11/04/2000   AUTEUR ADBHHPM P.MASSIN 
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
C ----------------------------------------------------------------------
C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ---------------------------
C
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
      CHARACTER*32       JEXNUM , JEXNOM
C ---------- FIN  DECLARATIONS  NORMALISEES  JEVEUX --------------------
C
      INTEGER       IDADIA, IDBLOC, NBBLOC, IBLOC, IABLOC, IL1, IL2, 
     +              IEQUA, IADIA
      CHARACTER*19  MAT
C     ------------------------------------------------------------------
C
      XMAX = 0.D0
      MAT  = ZK24(ZI(LMAT+1))
C
C --- ADRESSE DU TABLEAU DES ADRESSES DES TERMES DIAGONAUX DANS
C --- LES BLOCS :
C     ---------
      CALL MTDSC2 ( MAT, 'ADIA', 'L', IDADIA )
C
C --- ADRESSE DU TABLEAU DES ADRESSES DU DEBUT DES BLOCS :
C     --------------------------------------------------
      CALL MTDSC2 ( MAT, 'ABLO', 'L', IDBLOC )
C
C --- NOMBRE DE BLOCS DE LA DEMI-MATRICE :
C     ----------------------------------
      NBBLOC = ZI(LMAT+13)
C
C --- BOUCLE SUR LES BLOCS DE LA MATRICE :
C     ----------------------------------
      DO 10 IBLOC = 1 , NBBLOC
C
C ------ RECUPERATION DU BLOC COURANT :
C        ----------------------------
         CALL JEVEUO ( JEXNUM(MAT//'.VALE',IBLOC), 'L', IABLOC )
C
C ------ IL1 : NUMERO DE LA PREMIERE LIGNE (OU COLONNE) DU BLOC 
C ------ IL2 : NUMERO DE LA DERNIERE LIGNE (OU COLONNE) DU BLOC :
C        ------------------------------------------------------
         IL1 = ZI(IDBLOC+IBLOC-1) + 1
         IL2 = ZI(IDBLOC+IBLOC)
C
C ------ BOUCLE SUR LES LIGNES DU BLOC COURANT :
C        -------------------------------------
         DO 20 IEQUA = IL1 , IL2
C
C --------- POSITION DU TERME DIAGONAL DE LA LIGNE DANS LE BLOC :
C           ---------------------------------------------------
            IADIA = IABLOC + ZI(IDADIA+IEQUA-1) - 1
C
            XMAX = MAX ( XMAX , ZR(IADIA) )
C
 20      CONTINUE
C
 10   CONTINUE
C
      END
