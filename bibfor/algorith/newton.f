      SUBROUTINE NEWTON (NP1,NP2,NP3,NP4,NBM,N2,NBMCD,ICOUPL,TC,DT,DTC,
     &     VECDT,NBNL,TYPCH,NBSEG,PHII,CHOC,ALPHA,BETA,GAMMA,ORIG,RC,
     &     THETA,VGAP,VECR4,INDIC,TPFL,VECI1,VECR1,VECR2,VECR5,VECR3,
     &     MASGI,AMORI,PULSI,AMOR,AMOR0,PULS,PULS0,XSI0,
     &     VITG,DEPG,ACCG0,VITG0,DEPG0,VITGC,DEPGC,VITGT,DEPGT,
     &     CMOD,KMOD,CMOD0,KMOD0,CMODCA,KMODCA,AMFLU0,AMFLUC,
     &     LOCFLC,CMODFA,NPFTS,TEXTTS,FEXTTS,NDEF,INDT,
     &     FEXMOD,FNLMOD,FMODA,FMRES,FMOD0,FMOD00,
     &     FMODT,FMOD0T,VITG0T,DEPG0T,
     &     FTMP,MTMP1,MTMP2,MTMP6,
     &     TTR,U,W,DD,LOC,INTGE1,INTGE2,INDX,INDXF,
     &     VVG,VG,VG0,VD,VD0,RR,RR0,RI,PREMAC,PREREL,TRANS,PULSD,S0,
     &     Z0,SR0,ZA1,ZA2,ZA3,ZIN,OLD,OLDIA,
     &     ICONFE,ICONFA,NBCHA,NBCHEA,FTEST,ICONFB,TCONF1,TCONF2,
     &     TOLN,TOLC,TOLV,INDNE0,TESTC,ITFORN)
C
      IMPLICIT NONE
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 16/05/2000   AUTEUR KXBADNG T.KESTENS 
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
C TOLE  CRP_20 CRP_21
C-----------------------------------------------------------------------
C DESCRIPTION : PROCEDURE D'ATTEINTE DE L'INSTANT DE CHANGEMENT DE
C -----------   CONFIGURATION PAR UNE METHODE DE NEWTON.
C
C               APPELANT : ALITMI
C
C-------------------   DECLARATION DES VARIABLES   ---------------------
C
C ARGUMENTS
C ---------
      INTEGER      NP1, NP2, NP3, NP4, NBM, N2, NBMCD, ICOUPL
      REAL*8       TC, DT, DTC, VECDT(*)
      INTEGER      NBNL, TYPCH(*), NBSEG(*)
      REAL*8       PHII(NP2,NP1,*), CHOC(5,*), ALPHA(2,*), BETA(2,*),
     &             GAMMA(2,*), ORIG(6,*), RC(NP3,*), THETA(NP3,*),
     &             VGAP, VECR4(*)
      INTEGER      INDIC
      CHARACTER*8  TPFL
      INTEGER      VECI1(*)
      REAL*8       VECR1(*), VECR2(*), VECR5(*), VECR3(*),
     &             MASGI(*), AMORI(*), PULSI(*),
     &             AMOR(*), AMOR0(*), PULS(*), PULS0(*), XSI0(*),
     &             VITG(*), DEPG(*), ACCG0(*), VITG0(*), DEPG0(*),
     &             VITGC(*), DEPGC(*), VITGT(*), DEPGT(*),
     &             CMOD(NP1,*), KMOD(NP1,*), CMOD0(NP1,*), KMOD0(NP1,*),
     &             CMODCA(NP1,*), KMODCA(NP1,*),
     &             AMFLU0(NP1,*), AMFLUC(NP1,*)
      LOGICAL      LOCFLC(*)
      REAL*8       CMODFA(NP1,*)
      INTEGER      NPFTS
      REAL*8       TEXTTS(*), FEXTTS(NP4,*)
      INTEGER      NDEF, INDT
      REAL*8       FEXMOD(*), FNLMOD(*), FMODA(*), FMRES(*),
     &             FMOD0(*), FMOD00(*), FMODT(*), FMOD0T(*), 
     &             VITG0T(*), DEPG0T(*),
     &             FTMP(*), MTMP1(NP1,*), MTMP2(NP1,*), MTMP6(3,*)
      REAL*8       TTR(N2,*), U(*), W(*), DD(*)
      LOGICAL      LOC(*)
      INTEGER      INTGE1(*), INTGE2(*), INDX(*), INDXF(*)
      REAL*8       VVG(NP1,*), VG(NP1,*), VG0(NP1,*),
     &             VD(NP1,*), VD0(NP1,*), RR(*), RR0(*), RI(*),
     &             PREMAC, PREREL, TRANS(2,2,*), PULSD(*)
      COMPLEX*16   S0(*), Z0(*), SR0(*), ZA1(*), ZA2(*), ZA3(*), ZIN(*)
      REAL*8       OLD(9,*)
      INTEGER      OLDIA(*), ICONFE, ICONFA, NBCHA, NBCHEA
      REAL*8       FTEST
      INTEGER      ICONFB(*)
      REAL*8       TCONF1(4,*), TCONF2(4,*), TOLN, TOLC, TOLV
      INTEGER      INDNE0, TESTC, ITFORN(*)
C
C VARIABLES LOCALES
C -----------------
      INTEGER      I, IC, ICOMPT, IER, INEWTO,
     &             NITERN, NITNEW, NITMAX, TESTC0, TYPJ
      REAL*8       ABSDTC, DDIST2, DIST2, DT0, DTC0, MAXVIT, TDTC,
     &             TETAES
      CHARACTER*10 KB10
      CHARACTER*3  KB3
C DEBUG
      INTEGER      ICYCL, IDT, ILAST, ITBACK
      REAL*8       DT00, DTMIN, EPSDTC, TDT, SCALV, VGLO(3), VGLO0(3)
C DEBUG
C
C FONCTIONS INTRINSEQUES
C ----------------------
C     INTRINSIC    ABS, DBLE
C
C ROUTINES EXTERNES
C -----------------
C     EXTERNAL     ADIMVE, CALCMD, CALCMI, CALFMN, CALFNL, CALND1,
C    &             CALND2, COUPLA, ESTIVD, INIPAN, PRBRED, PROJMD,
C    &             PROJVD, SOMMMA, TESTCH, UTMESS
C
C-------------------   DEBUT DU CODE EXECUTABLE    ---------------------
C
      TESTC0 = TESTC
      NITERN = 1
      NITNEW = 0
      NITMAX = 150
      INEWTO = 1
      TETAES = 1.0D0
C DEBUG
      ITBACK = 0
      ILAST  = 0
      ICYCL  = 0
      EPSDTC = 1.0D-04
      DT00   = DT
      CALL INITVE ( NITMAX+1,VECDT)
C DEBUG
C
C-----------------------------------------------------------------------
C 1.  PREMIER AJUSTEMENT DU PAS DE TEMPS ET DE L'INSTANT N+1
C-----------------------------------------------------------------------
C 1.1 LA DERNIERE SOLUTION DETERMINEE PAR ALITMI A ETE CALCULEE SUR
C     LA BASE MODALE DE LA CONFIGURATION A L'INSTANT N
C
      IF ( (ICONFE.EQ.1).AND.(ICONFA.EQ.0) ) THEN
C
C ------ LE CHANGEMENT DE CONFIGURATION EST DEJA ATTEINT
C
         IF ( NBCHA.EQ.NBCHEA ) THEN
            DTC = 0.0D0
            GO TO 999
         ENDIF
C
C ------ ON SE PLACE A L'INSTANT N+1
C ------ ON DETERMINE L'INCREMENT TEMPOREL NEGATIF DE PLUS GRANDE VALEUR
C ------ ABSOLUE AFIN DE REVENIR AU CHANGEMENT D'ETAT LE PLUS PROCHE DE
C ------ L'INSTANT N. ON NE CONSIDERE QUE LES BUTEES EN LESQUELLES UN
C ------ CHANGEMENT D'ETAT A ETE DETECTE.
C
         DT0 = DT
         TC  = TC - DT0
         ICOMPT = 0
         DTC    = 0.0D0
         ABSDTC = 0.0D0
         DO 10 IC = 1, NBNL
            IF ( ICONFB(IC).EQ.0 ) THEN
               ICOMPT = ICOMPT + 1
               CALL CALND1 ( IC,NP1,NP2,NP3,NBM,NBNL,
     &                       CHOC,ALPHA,BETA,GAMMA,ORIG,RC,THETA,
     &                       TYPCH,NBSEG,PHII,DEPG,DIST2)
               CALL CALND2 ( IC,NP1,NP2,NP3,NBM,NBNL,TYPCH,NBSEG,
     &                       CHOC,ALPHA,BETA,GAMMA,ORIG,RC,THETA,
     &                       PHII,DEPG,VITG,DDIST2)
               TDTC = -DIST2 / DDIST2
               IF ( (TDTC.LT.0.0D0).AND.(ABS(TDTC).GT.ABSDTC) ) THEN
                  DTC = TDTC
                  ABSDTC = ABS(TDTC)
               ENDIF
            ENDIF
            IF ( ICOMPT.EQ.NBCHA ) GO TO 11
  10     CONTINUE
  11     CONTINUE
C ...... SI DTC = 0.0D0 ON EFFECTUE UN DEMI-TOUR ENTRE LES INSTANTS N
C ...... ET N+1 => DTC = -DT0/2.0D0
         IF ( DTC.EQ.0.0D0 ) THEN
            DTC = -DT0/2.0D0
         ENDIF
C
         IF ( (DT0+DTC).LT.0.0D0 ) DTC = -DT0/2.0D0
         DTC0 = DTC
         DT = DT0 + DTC
         TC = TC  + DT
C
C 1.2 LA DERNIERE SOLUTION DETERMINEE PAR ALITMI A ETE CALCULEE SUR
C     LA BASE MODALE DE LA CONFIGURATION A L'INSTANT N+1
C
      ELSE
C
C ------ ON SE PLACE A L'INSTANT N
C ------ ON DETERMINE L'INCREMENT TEMPOREL POSITIF DE PLUS PETITE VALEUR
C ------ ABSOLUE AFIN D'ATTEINDRE LE CHANGEMENT D'ETAT LE PLUS PROCHE DE
C ------ L'INSTANT N. ON CONSIDERE TOUTES LES BUTEES.
C
         DT0 = DT
         TC  = TC - DT0
         DT  = 1.0D+10
         DO 20 IC = 1, NBNL
            CALL CALND1 ( IC,NP1,NP2,NP3,NBM,NBNL,
     &                    CHOC,ALPHA,BETA,GAMMA,ORIG,RC,THETA,
     &                    TYPCH,NBSEG,PHII,DEPG0,DIST2)
            CALL CALND2 ( IC,NP1,NP2,NP3,NBM,NBNL,TYPCH,NBSEG,
     &                    CHOC,ALPHA,BETA,GAMMA,ORIG,RC,THETA,
     &                    PHII,DEPG0,VITG0,DDIST2)
            TDT = -DIST2 / DDIST2
            IF ( (TDT.GT.0.0D0).AND.(TDT.LT.DT) ) DT = TDT
  20     CONTINUE
C DEBUG
C ------ ON VALIDE L'INSTANT N+1 EN CAS D'ELOIGNEMENT DU CHANGEMENT DE
C ------ CONFIGURATION
         IF ( DT.EQ.1.0D+10 ) THEN
C     &      CALL UTMESS('F','NEWTON','PREMIER AJUSTEMENT DU PAS '//
C     &      'DE TEMPS, CAS 2 : INCREMENT TEMPOREL INDETERMINE')
            DT  = DT0
            DTC = 0.0D0
            TC  = TC + DT0
            GO TO 999
         ENDIF
C DEBUG
C
         DTC  = DT - DT0
         DTC0 = DTC
         TC   = TC + DT
C
      ENDIF
      VECDT(1) = DT
C
C-----------------------------------------------------------------------
C 2.  PREMIERE ESTIMATION DES DDLS GENERALISES A L'INSTANT N+1
C-----------------------------------------------------------------------
C 2.1 DETERMINATION DE LA COMPOSANTE DE PLUS GRANDE VALEUR ABSOLUE
C     DU VECTEUR VITESSES GENERALISEES A L'INSTANT N
C
      MAXVIT = 0.0D0
      DO 30 I = 1, NBM
         IF ( ABS(VITG0(I)).GT.MAXVIT ) MAXVIT = ABS(VITG0(I))
  30  CONTINUE
C
C 2.2 ESTIMATION DES DDLS GENERALISES A L'INSTANT N+1 PAR LE SCHEMA
C     D'EULER AFIN DE DETERMINER UNE POSITION AUTOUR DE LAQUELLE
C     ON VA LINEARISER LES FORCES DE CHOC
C     INEWTO = 1 INDIQUE A ESTIVD QUE LA ROUTINE APPELANTE EST NEWTON
C
      CALL ESTIVD(NBM,DT,VITGC,DEPGC,ACCG0,VITG0,DEPG0,TETAES,
     &            MAXVIT,INEWTO)
C
C-----------------------------------------------------------------------
C 3.  CALCUL DES DDLS GENERALISES A L'INSTANT N+1 PAR LE SCHEMA ITMI
C     JUSQU'A VALIDATION DE L'INSTANT N+1 (BLOC REPETER)
C-----------------------------------------------------------------------
 100  CONTINUE
      CALL INITVE ( NBM,DEPG)
      CALL INITVE ( NBM,VITG)
C
C 3.1 ESTIMATION DE LA FORCE NON-LINEAIRE A L'INSTANT N+1
C     INEWTO = 1 INDIQUE A MDCHOE QUE LA ROUTINE APPELANTE EST NEWTON,
C     DONC LE CALCUL EST REALISE DANS LA CONFIGURATION A L'INSTANT N
C
      CALL CALFNL ( NP1,NP2,NP3,NP4,NBM,NBM,NPFTS,TC,
     &              NBNL,TYPCH,NBSEG,PHII,
     &              CHOC,ALPHA,BETA,GAMMA,ORIG,RC,THETA,
     &              MASGI,AMORI,PULSI,
     &              VITGC,DEPGC,VITG0,DEPG0,
     &              CMOD,KMOD,CMODCA,KMODCA,
     &              TEXTTS,FEXTTS,NDEF,INDT,NITERN,
     &              FEXMOD,FNLMOD,FMRES,FMODA,FTMP,MTMP1,MTMP6,
     &              OLD,OLDIA,TESTC,ITFORN,INEWTO,TOLN)
C
C
C 3.2 DIAGONALISATION DE LA MATRICE DE RAIDEUR
C     (CONFIGURATION A L'INSTANT N)
C
      IER = 0
      CALL CALCMD ( NP1,KMODCA,KMOD0,NBM,NBMCD,TYPJ,VVG,VG,VG0,VD,VD0,
     &              RR,RR0,RI,N2,IER,TESTC,PREMAC,PREREL,
     &              MTMP1,MTMP2,TTR,U,W,DD,INTGE1,INTGE2,INDX,INDXF,LOC)
      IF ( IER.NE.0 )
     &   CALL UTMESS('F','NEWTON','IMPOSSIBLE DE DIAGONALISER LA '//
     &               'MATRICE DE RAIDEUR EN CHOC')
      DO 110 I = 1, NBM
         PULS(I) = RR(I)
 110  CONTINUE
      DO 120 I = 1, NBM
         IF ( (PULS(I).EQ.0.0D0).AND.(I.LE.NBMCD) ) THEN
            PULS(I) = PULS0(I)
            CALL UTMESS('I','NEWTON','PULS(I) = 0. '//
     &                      'INITIALISATION A PULS0(I).')
         ENDIF
 120  CONTINUE
C
      IF ( (TESTC0.EQ.1).AND.(TESTC.EQ.0) ) TYPJ = 1
C
C 3.3 CALCUL DES FORCES DE COUPLAGE (CONFIGURATION A L'INSTANT N)
C
      IF ( (TESTC.EQ.1).AND.(ICOUPL.EQ.1) ) THEN
         CALL COUPLA ( NP1,NBM,INDIC,TPFL,VECI1,
     &                 VGAP,VECR4,VECR1(1),VECR2,VECR5,VECR3,
     &                 MASGI,PULS,LOCFLC,AMFLU0,AMFLUC,XSI0)
         CALL SOMMMA ( NP1,NBM,NBM,AMFLUC,CMODCA,CMODFA)
      ENDIF
C
C 3.4 CALCUL DES EXCITATIONS GENERALISEES A L'INSTANT N
C
      CALL CALFMN ( NP1,NBM,TESTC0,
     &              FMOD0,FMOD00,CMOD,KMOD,VITG0,DEPG0)
      CALL ADIMVE ( NBM,FMOD0,MASGI)
C
C 3.5 PROJECTIONS SUR LA BASE MODALE (CONFIGURATION A L'INSTANT N)
C
      IF ( (TESTC.EQ.1).AND.(ICOUPL.EQ.1) ) THEN
         CALL PROJMD (TESTC,NP1,NBM,NBMCD,CMODFA,VG,VD,AMOR,MTMP1,MTMP2)
      ELSE
         CALL PROJMD (TESTC,NP1,NBM,NBMCD,CMODCA,VG,VD,AMOR,MTMP1,MTMP2)
      ENDIF
C
       CALL PROJVD ( TESTC,NP1,NBM,NBM,VG,FMOD0,FMOD0T)
       CALL PROJVD ( TESTC,NP1,NBM,NBM,VG,FMODA,FMODT)
       CALL PROJVD ( TESTC,NP1,NBM,NBM,VG,DEPG0,DEPG0T)
       CALL PROJVD ( TESTC,NP1,NBM,NBM,VG,VITG0,VITG0T)
C
C 3.6 CALCUL DES DDLS GENERALISES A L'INSTANT N+1 PAR LE SCHEMA ITMI
C     PUIS RETOUR SUR LA BASE EN VOL
C
      CALL CALCMI ( NP1,NBMCD,DT0,DT,
     &              VITGT,DEPGT,VITG0T,DEPG0T,FMODT,FMOD0T,
     &              MASGI,AMOR,AMOR0,PULS,PULS0,
     &              TRANS,PULSD,S0,Z0,SR0,ZA1,ZA2,ZA3,ZIN)
      CALL PROJVD ( TESTC,NP1,NBM,NBMCD,VD,DEPGT,DEPG)
      CALL PROJVD ( TESTC,NP1,NBM,NBMCD,VD,VITGT,VITG)
C
C 3.7 TEST DE CHANGEMENT DE CONFIGURATION ENTRE LES INSTANTS N ET N+1
C     AVEC LA SOLUTION DU SCHEMA ITMI
C
      IF ( TESTC.EQ.1 ) THEN
         CALL TESTCH ( NP1,NP2,NP3,NBM,NBNL,
     &                 TOLN,TOLC,TOLV,TYPCH,NBSEG,PHII,
     &                 ALPHA,BETA,GAMMA,ORIG,RC,THETA,
     &                 TCONF1,DEPG,
     &                 NBCHA,NBCHEA,ICONFA,FTEST,ICONFB,TCONF2)
      ELSE IF ( TESTC.EQ.0 ) THEN
         CALL TESTCH ( NP1,NP2,NP3,NBMCD,NBNL,
     &                 TOLN,TOLC,TOLV,TYPCH,NBSEG,PHII,
     &                 ALPHA,BETA,GAMMA,ORIG,RC,THETA,
     &                 TCONF1,DEPG,
     &                 NBCHA,NBCHEA,ICONFA,FTEST,ICONFB,TCONF2)
      ENDIF
      IF ( ILAST.EQ.1 ) THEN
         IF ( ICONFA.EQ.1 ) GO TO 999
         CALL UTMESS('F','NEWTON','ITERATIONS CYCLIQUES : CHANGEMENT '//
     &               'DE CONFIGURATION OU VARIATION TROP IMPORTANTE '//
     &               'DU DEPLACEMENT PHYSIQUE A L''ISSUE DE LA '//
     &               'DERNIERE ITERATION')
      ENDIF
C
C 3.8 AJUSTEMENT DU PAS DE TEMPS ET DE L'INSTANT N+1 SI LE CHANGEMENT
C     DE CONFIGURATION N'EST PAS ENCORE ATTEINT OU DEJA DEPASSE
C     DANS LE CAS CONTRAIRE, L'INSTANT N+1 EST VALIDE ET ON RETOURNE
C     A L'APPELANT ALITMI
C
      NITNEW = NITNEW + 1
C
C*****CAS 1 : VARIATION IMPORTANTE DU DEPLACEMENT PHYSIQUE D'UN NOEUD
C             DE CHOC AU MOINS ENTRE LES INSTANTS N ET N+1
C
      IF ( ICONFA.EQ.-1 ) THEN
         IF ( NITNEW.GT.NITMAX ) THEN
            WRITE(KB3,'(I3)') NITMAX
            WRITE(KB10,'(1PD10.4)') TC
            CALL UTMESS('F','NEWTON','PAS DE CONVERGENCE DE ' //
     &                  'L''ALGORITHME DE NEWTON EN '// KB3 //
     &                  ' ITERATIONS A L''INSTANT '// KB10 // '. IL'//
     &                  ' FAUT REDUIRE LA RIGIDITE NORMALE, OU LE JEU.')
         ENDIF
C
C ------ AJUSTEMENT DU PAS DE TEMPS ET DE L'INSTANT N+1
         DT0  = DT
         DTC0 = DTC
         TC   = TC - DT0
         DTC  = -DT0/2.0D0
C ...... SI DTC = -DTC0 (VALEUR A L'ITERATION PRECEDENTE)
C ...... ON DIVISE DTC PAR 2.0D0
C DEBUG
         IF ( ABS((DTC0+DTC)/DTC).LT.1.0D-02 ) THEN
            DTC = DTC/2.0D0
         ENDIF
         DT = DT0 + DTC
C....... DETECTION D'EVENTUELLES ITERATIONS CYCLIQUES
         VECDT(NITNEW+1) = DT
         CALL DTCYCL ( VECDT,NITNEW,ICYCL,DTMIN)
         IF ( ICYCL.EQ.1 ) THEN
C.......... ON FIXE DT A DTMIN SUR LE CYCLE POUR EFFECTUER UNE
C.......... DERNIERE ITERATION AVANT DE RETOURNER A ALITMI.
            ILAST = 1
            DT  = DTMIN
            DTC = DTMIN - DT00
            TC  = TC + DTMIN
         ELSE
            TC  = TC + DT
         ENDIF
C DEBUG
C
C ------ ESTIMATION DES DDLS GENERALISES A L'INSTANT N+1 PAR LE SCHEMA
C ------ D'EULER AFIN DE DETERMINER UNE POSITION AUTOUR DE LAQUELLE
C ------ ON VA LINEARISER LES FORCES DE CHOC
         CALL ESTIVD(NBM,DT,VITGC,DEPGC,ACCG0,VITG0,DEPG0,TETAES,
     &               MAXVIT,INEWTO)
C
C ------ INITIALISATION DES PARAMETRES POUR L'ITERATION SUIVANTE
         CALL INIPAN(NP1,NBM,CMOD0,KMOD0,CMODCA,KMODCA,
     &               AMOR0,PULS0,AMOR,PULS,FNLMOD,FEXMOD,FMOD00)
C
C ------ RETOURNER A REPETER
         GO TO 100
C
C*****CAS 2 : AUCUN CHANGEMENT D'ETAT N'EST ENCORE ATTEINT
C
      ELSE IF ( ICONFA.EQ.1 ) THEN
         IF ( NITNEW.GT.NITMAX ) THEN
            WRITE(KB3,'(I3)') NITMAX
            WRITE(KB10,'(1PD10.4)') TC
            CALL UTMESS('F','NEWTON','PAS DE CONVERGENCE DE ' //
     &                  'L''ALGORITHME DE NEWTON EN '// KB3 //
     &                  ' ITERATIONS A L''INSTANT '// KB10 // '. IL'//
     &                  ' FAUT REDUIRE LA RIGIDITE NORMALE, OU LE JEU.')
         ENDIF
C
C ------ ON SE PLACE A L'INSTANT N+1 SI LA VITESSE NE CHANGE PAS DE SENS
C ------ OU A L'INSTANT N DANS LE CAS CONTRAIRE.
C ------ ON DETERMINE L'INCREMENT TEMPOREL POSITIF DE PLUS PETITE VALEUR
C ------ ABSOLUE AFIN D'ATTEINDRE LE CHANGEMENT D'ETAT LE PLUS PROCHE DE
C ------ L'INSTANT N. ON CONSIDERE TOUTES LES BUTEES.
C
C DEBUG
         DT0  = DT
         DTC0 = DTC
         TC   = TC - DT0
         DT   = 1.0D+10
         DTC  = 0.0D0
         DO 140 IC = 1, NBNL
            CALL PROJMG ( NP1,NP2,IC,NBM,PHII,VITG0,VGLO0)
            CALL PROJMG ( NP1,NP2,IC,NBM,PHII,VITG ,VGLO )
            SCALV = VGLO0(1) * VGLO(1) + VGLO0(2) * VGLO(2)
     &            + VGLO0(3) * VGLO(3)
            IF ( SCALV.GT.0.0D0 ) THEN
               CALL CALND1 ( IC,NP1,NP2,NP3,NBM,NBNL,
     &                       CHOC,ALPHA,BETA,GAMMA,ORIG,RC,THETA,
     &                       TYPCH,NBSEG,PHII,DEPG,DIST2)
               CALL CALND2 ( IC,NP1,NP2,NP3,NBM,NBNL,TYPCH,NBSEG,
     &                       CHOC,ALPHA,BETA,GAMMA,ORIG,RC,THETA,
     &                       PHII,DEPG,VITG,DDIST2)
               TDTC = -DIST2 / DDIST2
               IF ( (TDTC.GT.0.0D0).AND.((DT0+TDTC).LT.DT) ) THEN
                  DT  = DT0 + TDTC
                  DTC = TDTC
                  IDT = 1
               ENDIF
            ELSE
               CALL CALND1 ( IC,NP1,NP2,NP3,NBM,NBNL,
     &                       CHOC,ALPHA,BETA,GAMMA,ORIG,RC,THETA,
     &                       TYPCH,NBSEG,PHII,DEPG0,DIST2)
               CALL CALND2 ( IC,NP1,NP2,NP3,NBM,NBNL,TYPCH,NBSEG,
     &                       CHOC,ALPHA,BETA,GAMMA,ORIG,RC,THETA,
     &                       PHII,DEPG0,VITG0,DDIST2)
               TDT = -DIST2 / DDIST2
               IF ( (TDT.GT.0.0D0).AND.(TDT.LT.DT) ) THEN
                  DT  = TDT
                  DTC = DT - DT0
                  IDT = 0
               ENDIF
C POUR ECRITURE
               TDTC = TDT - DT0
C POUR ECRITURE
            ENDIF
 140     CONTINUE
C
C ------ ON VALIDE L'INSTANT N+1 EN CAS D'ELOIGNEMENT DU CHANGEMENT DE
C ------ CONFIGURATION
         IF ( DT.EQ.1.0D+10 ) THEN
C     &      CALL UTMESS('F','NEWTON','AJUSTEMENT DU PAS DE TEMPS, '//
C     &      'CAS 2 : INCREMENT TEMPOREL INDETERMINE')
            DT  = DT0
            DTC = DTC0
            TC  = TC + DT0
            GO TO 999
         ENDIF
C
C ------ DEMI-TOUR SANS CHANGEMENT DE CONFIGURATION ENTRE LES
C ------ INSTANTS N ET N+1
         IF ( (ABS(DTC)/DT0).LT.EPSDTC ) THEN
            IF ( IDT.EQ.0 ) ITBACK = ITBACK + 1
C ......... AU PREMIER PASSAGE ON DIVISE LE PAS DE TEMPS PAR 2.0D0
            IF ( ITBACK.LT.2 ) THEN
               DTC = -DT0/2.0D0
               DT  = DT0 + DTC
C ......... AU PASSAGE SUIVANT ON CONCLUT AU DEMI-TOUR SANS CHANGEMENT
C ......... DE CONFIGURATION. ON FIXE DT A VECDT(1) POUR EFFECTUER UNE
C ......... DERNIERE ITERATION AVANT DE RETOURNER A L'APPELANT ALITMI.
            ELSE
               ILAST = 1
               DT  = VECDT(1)
               DTC = DT - DT00
               TC  = TC + DT
            ENDIF
         ENDIF
C
C ------ AJUSTEMENT DU PAS DE TEMPS ET DE L'INSTANT N+1
         IF ( ILAST.EQ.0 ) THEN
C ......... SI DTC = -DTC0 (VALEUR A L'ITERATION PRECEDENTE)
C ......... ON DIVISE DTC PAR 2.0D0
            IF ( ABS((DTC0+DTC)/DTC).LT.1.0D-02 ) THEN
               DTC = DTC/2.0D0
               DT  = DT0 + DTC
            ENDIF
C.......... DETECTION D'EVENTUELLES ITERATIONS CYCLIQUES
            VECDT(NITNEW+1) = DT
            CALL DTCYCL ( VECDT,NITNEW,ICYCL,DTMIN)
            IF ( ICYCL.EQ.1 ) THEN
C............. ON FIXE DT A DTMIN SUR LE CYCLE POUR EFFECTUER UNE
C............. DERNIERE ITERATION AVANT DE RETOURNER A ALITMI.
               ILAST = 1
               DT  = DTMIN
               DTC = DTMIN - DT00
               TC  = TC + DTMIN
            ELSE
               TC  = TC + DT
            ENDIF
         ENDIF
C DEBUG
C
C ------ ESTIMATION DES DDLS GENERALISES A L'INSTANT N+1 PAR LE SCHEMA
C ------ D'EULER AFIN DE DETERMINER UNE POSITION AUTOUR DE LAQUELLE
C ------ ON VA LINEARISER LES FORCES DE CHOC
         CALL ESTIVD(NBM,DT,VITGC,DEPGC,ACCG0,VITG0,DEPG0,TETAES,
     &               MAXVIT,INEWTO)
C
C ------ INITIALISATION DES PARAMETRES POUR L'ITERATION SUIVANTE
         CALL INIPAN(NP1,NBM,CMOD0,KMOD0,CMODCA,KMODCA,
     &               AMOR0,PULS0,AMOR,PULS,FNLMOD,FEXMOD,FMOD00)
C
C ------ RETOURNER A REPETER
         GO TO 100
C
C*****CAS 3 : AU MOINS UN CHANGEMENT D'ETAT EST DEPASSE
C
      ELSE IF ( NBCHA.GT.NBCHEA ) THEN
         IF ( NITNEW.GT.NITMAX ) THEN
            WRITE(KB3,'(I3)') NITMAX
            WRITE(KB10,'(1PD10.4)') TC
            CALL UTMESS('F','NEWTON','PAS DE CONVERGENCE DE ' //
     &                  'L''ALGORITHME DE NEWTON EN '// KB3 //
     &                  ' ITERATIONS A L''INSTANT '// KB10 // '. IL'//
     &                  ' FAUT REDUIRE LA RIGIDITE NORMALE, OU LE JEU.')
         ENDIF
C
C ------ ON SE PLACE A L'INSTANT N+1
C ------ ON DETERMINE L'INCREMENT TEMPOREL NEGATIF DE PLUS GRANDE VALEUR
C ------ ABSOLUE AFIN DE REVENIR AU CHANGEMENT D'ETAT LE PLUS PROCHE DE
C ------ L'INSTANT N. ON NE CONSIDERE QUE LES BUTEES EN LESQUELLES UN
C ------ CHANGEMENT D'ETAT A ETE DETECTE.
C
         DT0  = DT
         DTC0 = DTC
         TC   = TC - DT0
         ICOMPT = 0
         DTC    = 0.0D0
         ABSDTC = 0.0D0
         DO 150 IC = 1, NBNL
            IF ( ICONFB(IC).EQ.0 ) THEN
               ICOMPT = ICOMPT + 1
               CALL CALND1 ( IC,NP1,NP2,NP3,NBM,NBNL,
     &                       CHOC,ALPHA,BETA,GAMMA,ORIG,RC,THETA,
     &                       TYPCH,NBSEG,PHII,DEPG,DIST2)
               CALL CALND2 ( IC,NP1,NP2,NP3,NBM,NBNL,TYPCH,NBSEG,
     &                       CHOC,ALPHA,BETA,GAMMA,ORIG,RC,THETA,
     &                       PHII,DEPG,VITG,DDIST2)
               TDTC = -DIST2 / DDIST2
               IF ( (TDTC.LT.0.0D0).AND.(ABS(TDTC).GT.ABSDTC) ) THEN
                  DTC = TDTC
                  ABSDTC = ABS(TDTC)
               ENDIF
            ENDIF
            IF ( ICOMPT.EQ.NBCHA ) GO TO 151
 150     CONTINUE
 151     CONTINUE
C DEBUG
C ------ SI DTC = 0.0D0 ON EFFECTUE UN DEMI-TOUR ENTRE LES INSTANTS N
C ------ ET N+1 => DTC = -DT0/2.0D0
         IF ( DTC.EQ.0.0D0 ) THEN
            DTC = -DT0/2.0D0
         ENDIF
C
C ------ AJUSTEMENT DU PAS DE TEMPS ET DE L'INSTANT N+1
         IF ( (DT0+DTC).LT.0.0D0 ) DTC = -DT0/2.0D0
C ...... SI DTC = -DTC0 (VALEUR A L'ITERATION PRECEDENTE)
C ...... ON DIVISE DTC PAR 2.0D0
         IF ( ABS((DTC0+DTC)/DTC).LT.1.0D-02 ) THEN
            DTC = DTC/2.0D0
         ENDIF
         DT = DT0 + DTC
C....... DETECTION D'EVENTUELLES ITERATIONS CYCLIQUES
         VECDT(NITNEW+1) = DT
         CALL DTCYCL ( VECDT,NITNEW,ICYCL,DTMIN)
         IF ( ICYCL.EQ.1 ) THEN
C.......... ON FIXE DT A DTMIN SUR LE CYCLE POUR EFFECTUER UNE
C.......... DERNIERE ITERATION AVANT DE RETOURNER A ALITMI.
            ILAST = 1
            DT  = DTMIN
            DTC = DTMIN - DT00
            TC  = TC + DTMIN
         ELSE
            TC  = TC + DT
         ENDIF
C DEBUG
C
C ------ ESTIMATION DES DDLS GENERALISES A L'INSTANT N+1 PAR LE SCHEMA
C ------ D'EULER AFIN DE DETERMINER UNE POSITION AUTOUR DE LAQUELLE
C ------ ON VA LINEARISER LES FORCES DE CHOC
         CALL ESTIVD(NBM,DT,VITGC,DEPGC,ACCG0,VITG0,DEPG0,TETAES,
     &               MAXVIT,INEWTO)
C
C ------ INITIALISATION DES PARAMETRES POUR L'ITERATION SUIVANTE
         CALL INIPAN(NP1,NBM,CMOD0,KMOD0,CMODCA,KMODCA,
     &               AMOR0,PULS0,AMOR,PULS,FNLMOD,FEXMOD,FMOD00)
C
C ------ RETOURNER A REPETER
         GO TO 100
C
      ENDIF
 999  CONTINUE
C
C --- FIN DE NEWTON.
      END
