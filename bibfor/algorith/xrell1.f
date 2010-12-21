      SUBROUTINE XRELL1(TABNOZ,NDIM  ,NAR   ,TABCO ,EXILI ,PICKNO,
     &                  NBPINO,NLISEQ,NLISRL,NLISCO)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 20/12/2010   AUTEUR PELLET J.PELLET 
C TOLE CRS_1404
C ======================================================================
C COPYRIGHT (C) 1991 - 2010  EDF R&D                  WWW.CODE-ASTER.ORG
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
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C RESPONSABLE GENIAUT S.GENIAUT
C
      IMPLICIT NONE
      INTEGER        NDIM,NAR,NBPINO
      INTEGER        TABNOZ(3,NAR),PICKNO(NBPINO)
      LOGICAL        EXILI
      REAL*8         TABCO(NDIM,NAR)
      CHARACTER*19   NLISEQ,NLISRL,NLISCO
C
C ----------------------------------------------------------------------
C
C ROUTINE XFEM (PREPARATION)
C
C CHOIX DE L'ESPACE DES LAGRANGES POUR LE CONTACT - V1:
C                    (VOIR BOOK VI 15/07/05)
C    - CREATION DES RELATIONS DE LIAISONS ENTRE LAGRANGE
C
C ----------------------------------------------------------------------
C
C
C IN  TABNOZ : TABLEAU DES NOEUDS EXTREMITES ET NOEUD MILIEU
C IN  NAR    : NOMBRE D'ARETES COUPEES
C IN  NDIM   : DIMENSION DU PROBLEME
C IN  TABCO  : TABLEAU DES COORDONNEES DE NOEUDS MILIEU
C IN  EXILI  : .TRUE. SI LAGRANGES AUX NOEUDS
C IN  PICKNO : NUMEROS DES NOEUDS SELECTIONNE
C IN  NBPINO : NOMBRE DE NOEUDS SELECTIONNE
C OUT NLISRL : LISTE REL. LIN. POUR V1 ET V2
C OUT NLISCO : LISTE REL. LIN. POUR V1 ET V2
C OUT NLISEQ : LISTE REL. LIN. POUR V2 SEULEMENT
C
C -------------- DEBUT DECLARATIONS NORMALISEES JEVEUX -----------------
C
      INTEGER ZI
      COMMON /IVARJE/ ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C
C ---------------- FIN DECLARATIONS NORMALISEES JEVEUX -----------------
C
      INTEGER      I,J,IN,DIMEQ,IA,EXT,LIBRE,K,EQ(100),TABNO(NAR,3),IE
      INTEGER      LISEQT(NAR,2),NRELEQ,JLIS1,PICKED,IEXT,NRELRL
      INTEGER      LISRLT(NAR,3),COEFI(2),JLIS2,JLIS3
      REAL*8       DISMIN,DIST,COEFR(2),LISCOT(NAR,3)
      REAL*8       R8MAEM,PADIST
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- INITIALISATIONS
C
      DO 10 I=1,NAR
        DO 11 J=1,3
          TABNO(I,J)=TABNOZ(J,I)
 11     CONTINUE
 10   CONTINUE
      NRELEQ = 0
C
C --- CREATION DU TABLEAU TEMPORAIRE DES RELATION D'EGALITE : LISEQT
C
      DO 100 I=1,NBPINO
        IN     = PICKNO(I)
        DIMEQ  = 0
        DO 110 IA=1,NAR
          DO 111 J=1,2
C           ON CHERCHE LES ARETES EMANANTES
            IF (TABNO(IA,J).EQ.IN) THEN
              EXT=TABNO(IA,3-J)
C             ON REGARDE SI L'AUTRE EXTREMITE EST LIBRE
              LIBRE=1
              DO 112 K=1,NBPINO
                IF (EXT.EQ.PICKNO(K)) LIBRE=0
 112          CONTINUE
              IF (LIBRE.EQ.1) THEN
                DIMEQ=DIMEQ+1
                EQ(DIMEQ)=IA
              ENDIF
            ENDIF
 111      CONTINUE
 110    CONTINUE
        IF (EXILI) THEN
          DO 121 IE=1,DIMEQ
            NRELEQ=NRELEQ+1
            LISEQT(NRELEQ,1)=TABNO(EQ(IE) , 1)
            LISEQT(NRELEQ,2)=TABNO(EQ(IE) , 2)
 121      CONTINUE
        ELSE
          CALL ASSERT(DIMEQ-1.GE.0)
          DO 120 IE=1,DIMEQ-1
            NRELEQ=NRELEQ+1
            LISEQT(NRELEQ,1)=TABNO(EQ(IE)  ,3)
            LISEQT(NRELEQ,2)=TABNO(EQ(IE+1),3)
 120      CONTINUE
        ENDIF
 100  CONTINUE
C
C --- STOCKAGE DE LISEQT
C
      IF (NRELEQ.GT.0) THEN
        CALL WKVECT(NLISEQ,'G V I',NRELEQ*2,JLIS1)
        DO 130 IE=1,NRELEQ
          ZI(JLIS1-1+2*(IE-1)+1)=LISEQT(IE,1)
          ZI(JLIS1-1+2*(IE-1)+2)=LISEQT(IE,2)
C          WRITE(6,*)'LISEQ ',IE,LISEQT(IE,1),LISEQT(IE,2)
 130    CONTINUE
      ENDIF
C
C --- DANS LE CAS LAGRANGES AUX NOEUDS, LES EVENTUELLES RELATIONS
C     LINEAIRES SONT IMPOSEES DANS XLAGSL
C
      IF (EXILI) GOTO 999
C
C --- CREATION DU TABLEAU TEMPORAIRE DES RELATION LINEAIRES      :LISRLT
C --- ET DU TABLEAU TEMPORAIRE DES COEFFICIENTS DE CES RELATIONS :LISCOT
C
      NRELRL = 0
      DO 200 IA=1,NAR
        PICKED = 0
        DO 210 J=1,2
          DO 211 K=1,NBPINO
            IF (TABNO(IA,J).EQ.PICKNO(K))   PICKED=PICKED+1
 211      CONTINUE
 210    CONTINUE
C
        IF (PICKED.EQ.2) THEN
          DO 220 IEXT=1,2
C           ON PARCOURT LES ARETES EMANANTES LIBRE
            DISMIN=R8MAEM()
            DO 221 I=1,NAR
              DO 222 J=1,2
                IF (TABNO(I,J).EQ.TABNO(IA,IEXT)) THEN
                  EXT=TABNO(I,3-J)
C                 ON VERIFIE SI L'AUTRE EXTREMITE EST LIBRE
                  LIBRE=1
                  DO 223 K=1,NBPINO
                     IF (EXT.EQ.PICKNO(K)) LIBRE=0
 223              CONTINUE
                  IF (LIBRE.EQ.1) THEN
C                    CALCUL DISTANCE ENTRE LAG �LIER ET LE LAG EXT
                     DIST   = PADIST(NDIM,TABCO(1,I),TABCO(1,IA))
                     IF (DIST.LT.DISMIN) THEN
                        DISMIN=DIST
                        COEFI(IEXT)=TABNO(I,3)
                        COEFR(IEXT)=DIST
                     ENDIF
                  ENDIF
                ENDIF
 222          CONTINUE
 221        CONTINUE
 220      CONTINUE
          NRELRL=NRELRL+1
          LISRLT(NRELRL,1)=TABNO(IA,3)
          LISRLT(NRELRL,2)=COEFI(1)
          LISRLT(NRELRL,3)=COEFI(2)
          LISCOT(NRELRL,1)=1.D0
          LISCOT(NRELRL,2)=-COEFR(2)/(COEFR(1)+COEFR(2))
          LISCOT(NRELRL,3)=-COEFR(1)/(COEFR(1)+COEFR(2))
        ENDIF

 200  CONTINUE
C
C --- STOCKAGE DE LISRLT ET LISCOT
C
      IF (NRELRL.GT.0) THEN
        CALL WKVECT(NLISRL,'G V I',NRELRL*3,JLIS2)
        CALL WKVECT(NLISCO,'G V R',NRELRL*3,JLIS3)
        DO 230 IE=1,NRELRL
          DO 231 J=1,3
            ZI(JLIS2-1+3*(IE-1)+J) = LISRLT(IE,J)
            ZR(JLIS3-1+3*(IE-1)+J) = LISCOT(IE,J)
 231      CONTINUE
 230    CONTINUE
      ENDIF
C
 999  CONTINUE
C
      CALL JEDEMA()
      END
