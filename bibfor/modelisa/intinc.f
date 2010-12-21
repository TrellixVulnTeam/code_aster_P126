      SUBROUTINE INTINC(DIME  ,PRECCP,ITEMAX,NNS   ,
     &                  WG    ,NG    ,FG    ,DFG   ,
     &                  NNA   ,NNB   ,NOA   ,NOB   ,
     &                  TMB   ,HB    ,FB    ,
     &                  WJACG ,DFA   ,DFB   ,IRET)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 20/12/2010   AUTEUR PELLET J.PELLET 
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
C RESPONSABLE MEUNIER S.MEUNIER
C
      IMPLICIT NONE
      INTEGER       NNM
      PARAMETER     (NNM = 27)
C
      INTEGER       IRET,ITEMAX
      REAL*8        HB,PRECCP
      INTEGER       DIME,NNA,NNB,NG,NNS
      CHARACTER*8   TMB
      REAL*8        FG(NG*NNM),DFG(3*NG*NNM)
      REAL*8        WG(NG),WJACG(NG)
      REAL*8        FB(NG*NNM)
      REAL*8        DFA(3*NG*NNM),DFB(3*NG*NNM)
      REAL*8        NOA(3*NNM),NOB(3*NNM)
C
C ----------------------------------------------------------------------
C
C ROUTINE ARLEQUIN
C
C CALCUL DES FNCT FORME ET DERIVEES DANS LE CAS DE L'INCLUSION
C INTEGRATION DE LA MAILLE B SUR LA MAILLE A
C L'ESPACE MEDIATEUR EST CELUI DE LA MAILLE A
C
C ----------------------------------------------------------------------
C
C
C PAR NNM    : NOMBRE MAXI DE NOEUDS PAR MAILLE
C IN  DIME   : DIMENSION DE L'ESPACE
C IN  PRECCP : PRECISION POUR LE NEWTON (PROJ. SUR MAILLE REF.)
C IN  ITEMAX : NBRE. ITER. MAX. POUR LE NEWTON (PROJ. SUR MAILLE REF.)

C
C INFORMATIONS SUR LA MAILLE SUPPORT D'INTEGRATION
C
C IN  NNS    : NOMBRE DE NOEUDS D'ELEMENT (DE LA MAILLE SUPPORT)
C IN  WG     : POIDS DE GAUSS
C IN  NG     : NOMBRE DE POINTS DE GAUSS
C IN  FG     : FONCTIONS DE FORME AUX POINTS DE GAUSS
C IN  DFG    : DERIV./PARAM FCT. FORMES AUX POINTS DE GAUSS
C OUT WJACG  : POIDS*JACOBIEN DES PTS DE GAUSS
C
C INFORMATIONS SUR LE COUPLE DE MAILLES
C
C IN  NNA    : NOMBRE DE NOEUDS DE LA MAILLE A
C IN  NNB    : NOMBRE DE NOEUDS DE LA MAILLE B
C IN  NOA    : COORDONNEES DES NOEUDS DE LA MAILLE A DANS ESPACE REEL
C IN  NOB    : COORDONNEES DES NOEUDS DE LA MAILLE B DANS ESPACE REEL
C IN  TMB    : TYPE DE LA MAILLE B
C IN  HB     : DIAMETRE DE LA MAILLE B
C
C OUT FB     : FCT. FORMES AUX PTS DE GAUSS DE LA MAILLE B
C OUT DFA    : DERIV./PARAM FCT. FORMES AUX PTS DE GAUSS DE LA MAILLE A
C OUT DFB    : DERIV./PARAM FCT. FORMES AUX PTS DE GAUSS DE LA MAILLE B
C OUT IRET   : CODE RETOUR - DIFFERENT DE ZERO SI PROBLEME
C
C DERIV./PARAM: DERIVEES PAR RAPPORT AUX COORDONNEES DE L'ESPACE
C               PARAMETRIQUE
C DERIV./REEL : DERIVEES PAR RAPPORT AUX COORDONNEES DE L'ESPACE
C               REEL
C
C ----------------------------------------------------------------------
C
      INTEGER P0,P1,P2,P3,P4
      INTEGER IPG
      LOGICAL IFORM,PROJOK
      REAL*8  R8BID,PREC
      REAL*8  PGREEL(3),PGPARA(3*NG)
      REAL*8  JACOBA(3*NG),VOLMAI,JACOBB(3*NG)
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- INITIALISATIONS
C
      P0 = 1
      P1 = 1
      P2 = 1
      P3 = 1
      P4 = 1
      IRET  = 0
      IFORM = .TRUE.
      PREC  = HB * PRECCP
C
      DO 10 IPG = 1, NG
C
C --- COPIE DERIV. FCT. FORMES. AU POINT IPG
C
        CALL DCOPY (DIME*NNA,DFG(P1),1,DFA(P3),1)
C
C --- CALCUL DU JACOBIEN DE LA MAILLE A
C
        CALL MTPROD(NOA    ,DIME,0,DIME,0,NNA,
     &              DFA(P3),DIME,0,DIME,0,
     &              JACOBA)
C
C --- CALCUL DU JACOBIEN INVERSE DE LA MAILLE A ET SON DETERMINANT
C --- DFA   : DERIV./REEL FCT. FORMES AUX PTS DE GAUSS DE LA MAILLE A
C
        CALL MGAUSS('TFWD',JACOBA,DFA(P3),DIME,DIME,
     &              NNA   ,VOLMAI,IRET)

        IF (IRET.NE.0) THEN
          GOTO 140
        ENDIF
C
        WJACG(IPG) = WG(IPG) * ABS(VOLMAI)
C
C --- PGREEL: COORD PT GAUSS DE A DS ESPACE REEL
C
        CALL MTPROD(NOA   ,DIME,0,DIME,0,NNA,
     &              FG(P0),1   ,0,1   ,0,
     &              PGREEL)
C
C --- PGPARA: COORD PT GAUSS DE A DS ESPACE PARAMETRIQUE MAILLE B
C --- FB    : FCT. FORME SUR MAILLE B EN PGPARA
C
        CALL REFERE(PGREEL,NOB   ,DIME  ,TMB,PREC  ,
     &              ITEMAX,IFORM ,PGPARA,PROJOK,FB(P2))
C
        IF (.NOT.PROJOK) THEN
          IRET = 2
          GOTO 140
        ENDIF
C
C --- DFB   : DERIV./PARAM FCT. FORME SUR MAILLE B EN PGPARA
C
        CALL FORME1(PGPARA,TMB,DFB(P4),NNB   ,DIME)
C
C --- CALCUL DU JACOBIEN DE LA MAILLE 2
C
        CALL MTPROD(NOB    ,DIME,0,DIME,0,NNB   ,
     &              DFB(P4),DIME,0,DIME,0,
     &              JACOBB)
C
C --- CALCUL DU JACOBIEN INVERSE DE LA MAILLE B SANS SON DETERMINANT
C --- DFB   : DERIV./REEL FCT. FORMES AUX PTS DE GAUSS DE LA MAILLE B
C
        CALL MGAUSS('TFWP',JACOBB,DFB(P4),DIME,DIME,
     &              NNB   ,R8BID ,IRET)
C
        P0 = P0 + NNS
        P1 = P1 + NNS*DIME
        P2 = P2 + NNB
        P3 = P3 + NNA*DIME
        P4 = P4 + NNB*DIME

 10   CONTINUE
C
 140  CONTINUE
C
      CALL JEDEMA()

      END
