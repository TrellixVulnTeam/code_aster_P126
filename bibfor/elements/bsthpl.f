      SUBROUTINE BSTHPL ( NOMTE, BSIGTH, INDITH )
      IMPLICIT  NONE
      REAL*8                     BSIGTH(24)
      LOGICAL                            INDITH
      CHARACTER*8         NOMTE
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 06/03/2002   AUTEUR CIBHHLV L.VIVAN 
C ======================================================================
C COPYRIGHT (C) 1991 - 2002  EDF R&D                  WWW.CODE-ASTER.ORG
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
C      CALCUL DU BSIGMA POUR LES CONTRAINTES THERMIQUES
C      (I.E. BT*D*ALPHA(T-TREF)) POUR LES ELEMENTS
C                                DE PLAQUE (DKT,DKQ,DST,DSQ,Q4G) 
C     ------------------------------------------------------------------
C     IN  NOMTE  : NOM DU TYPE D'ELEMENT
C     OUT BSIGTH : BT*SIGMA POUR LES CONTRAINTES THERMIQUES
C     OUT INDITH : LOGICAL = .TRUE.  YA DES DEFORMATIONS THERMIQUES
C                          = .FALSE. SINON
C     ------------------------------------------------------------------
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
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
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER       I, ICOMPX, JGEOM, LZI, NNO
      REAL*8        PGL(3,3), XYZL(3,4), TSUP(4), TMOY(4), TINF(4),
     +              SIGTH(32), ZERO
      CHARACTER*16  TYPELE, OPTION
C     ------------------------------------------------------------------
C
C --- INITIALISATIONS :
C     ---------------
      ZERO = 0.0D0
      INDITH = .FALSE.
      ICOMPX = -1
      TYPELE = NOMTE
      OPTION = 'INCONNU_INCONNU_'
C
      DO 10 I = 1, 24
        BSIGTH(I) = ZERO
  10  CONTINUE
C
C --- RECUPERATION DES TEMPERATURES AUX NOEUDS :
C     ----------------------------------------
      CALL DXTEMP(TYPELE, TSUP, TINF, TMOY, INDITH)
C
      IF (.NOT.INDITH) GOTO 9999
C
C --- RECUPERATION DE L'OBJET .DESI :
C     -----------------------------
      CALL JEVETE('&INEL.'//NOMTE//'.DESI',' ',LZI)
C
C --- NOMBRE DE NOEUDS :
C     ----------------
      NNO = ZI(LZI)
C
C --- RECUPERATION DES COORDONNEES DES NOEUDS DE L'ELEMENT :
C     ----------------------------------------------------
      CALL JEVECH('PGEOMER','L',JGEOM)
C
C --- DETERMINATION DE LA MATRICE DE PASSAGE REPERE GLOBAL --> LOCAL :
C     --------------------------------------------------------------
      IF (NNO.EQ.3) THEN
        CALL DXTPGL(ZR(JGEOM),PGL)
      ELSEIF (NNO.EQ.4) THEN
        CALL DXQPGL(ZR(JGEOM),PGL)
      ENDIF
C
C --- DETERMINATION DES COORDONNEES LOCALES XYZL DES NOEUDS  
C --- DE L'ELEMENT :
C     ------------
      CALL UTPVGL(NNO,3,PGL,ZR(JGEOM),XYZL)
C
C --- CALCUL DES EFFORTS GENERALISES D'ORIGNIE THERMIQUE AUX POINTS
C --- D'INTEGRATION :
C     -------------
      CALL DXEFGT(TYPELE,XYZL,PGL,TSUP,TINF,TMOY,SIGTH)
C
C --- PRISE EN COMPTE DE L'EXCENTREMENT SI ON CALCULE LES EFFORTS
C --- GENERALISES THERMIQUES SUR UN FEUILLET DE REFERENCE DIFFERENT
C --- DU FEUILLET DU MAILLAGE :
C     -----------------------
      CALL EXCENT(OPTION,TYPELE,NNO,SIGTH,ICOMPX)
C
C --- CALCUL DE BT*SIGTH :
C     ------------------
      CALL DXBSIG(TYPELE,XYZL,PGL,SIGTH,BSIGTH)
C
 9999 CONTINUE
C
      END
