      SUBROUTINE DXRIG(NOMTE,MATLOC)
      IMPLICIT REAL*8 (A-H,O-Z)
      REAL*8       MATLOC(300)
      CHARACTER*16 NOMTE
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 06/07/2001   AUTEUR CIBHHGB G.BERTRAND 
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
C     CALCUL DES MATRICES DE RIGIDITE ELEMENTAIRES ELASTIQUES
C     DE PLAQUE POUR LES ELEMENTS DKT, DST, DKQ, DSQ ET Q4G
C     DANS LE REPERE LOCAL A L'ELEMENT
C         OPTION TRAITEE  ==>  RIGI_MECA
C
C     IN   K16   NOMTE      : NOM DU TYPE_ELEMENT
C     OUT  R8   MATLOC(300) : MATRICE DE RIGIDITE ELEMENTAIRE
C                             MATLOC DE TAILLE 300 CAR
C     ---> POUR DKT/DST MATELEM = 3 * 6 DDL = 171 TERMES STOCKAGE SYME
C     ---> POUR DKQ/DSQ MATELEM = 4 * 6 DDL = 300 TERMES STOCKAGE SYME
C     ------------------------------------------------------------------
C     ----- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
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
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------
      INTEGER      MULTIC
      LOGICAL      GRILLE
      REAL*8       PGL(3,3),XYZL(3,4),ENER(3)
      CHARACTER*16 OPTION
      CHARACTER*24 DESI,DESR
C     ------------------------------------------------------------------
      OPTION = 'RIGI_MECA'
C
      DESI = '&INEL.'//NOMTE(1:8)//'.DESI'
      CALL JEVETE(DESI,'L',LZI)
      NNO = ZI(LZI)
C
      DESR = '&INEL.'//NOMTE(1:8)//'.DESR'
      CALL JEVETE(DESR,'L',LZR)
C
      IF (NOMTE(1:8).EQ.'MEGRDKT ') THEN
        GRILLE = .TRUE.
      ELSE
        GRILLE = .FALSE.
      END IF
C
C ---  RECUPERATION DES COORDONNEES DES CONNECTIVITES :
C      ----------------------------------------------
      CALL JEVECH('PGEOMER','L',JGEOM)
C
C ---  CONSTRUCTION DES MATRICES DE PASSAGE DU REPERE LOCAL
C ---  AU REPERE GLOBAL :
C      ----------------
      IF (NNO.EQ.3) THEN
        CALL DXTPGL(ZR(JGEOM),PGL)
      ELSE IF (NNO.EQ.4) THEN
        CALL DXQPGL(ZR(JGEOM),PGL)
      END IF
C
C ---  CALCUL DES COORDONNEES LOCALES DES CONNECTIVITES :
C      ------------------------------------------------
      CALL UTPVGL(NNO,3,PGL,ZR(JGEOM),XYZL)
C
C ---  CALCUL LA MATRICE DE RIGIDITE ELASTIQUE :
C      ------------------------------------------------
      IF(NOMTE(1:8).EQ.'MEDKTR3 '.OR.NOMTE(1:8).EQ.'MEGRDKT ') THEN
C
          CALL DKTRIG(XYZL, OPTION, PGL, MATLOC, ENER, MULTIC, GRILLE)
C
      ELSEIF (NOMTE(1:8) .EQ.'MEDSTR3 ') THEN
C
          CALL DSTRIG(XYZL, OPTION, PGL, MATLOC, ENER)
C
      ELSEIF (NOMTE(1:8) .EQ.'MEDKQU4 ') THEN
C
          CALL DKQRIG(XYZL, OPTION, PGL, MATLOC, ENER)
C
      ELSEIF (NOMTE(1:8) .EQ.'MEDSQU4 ') THEN
C
          CALL DSQRIG(XYZL, OPTION, PGL, MATLOC, ENER)
C
      ELSEIF (NOMTE(1:8) .EQ.'MEQ4QU4 ') THEN
C
          CALL Q4GRIG(XYZL, OPTION, PGL, MATLOC, ENER)
C
      ELSE
         CALL UTMESS('F','DXRIG','LE TYPE D''ELEMENT : '//NOMTE(1:8)
     +               //'N''EST PAS PREVU.')
      ENDIF
C
      END
