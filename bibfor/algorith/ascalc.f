      SUBROUTINE ASCALC(RESU,MASSE,MOME,PSMO,STAT,NBMODE,NEQ,NORDR,
     +                  KNOMSY,NBOPT,NDIR,MONOAP,NBSUP,NSUPP,TYPCMO,
     +                  TEMPS,COMDIR,TYPCDI,TRONC,AMORT,SPECTR,
     +                  ASSPEC,NOMSUP,REASUP,DEPSUP,TCOSUP,TCOSAP,
     +                  CORFRE,IMPR)
      IMPLICIT  REAL*8 (A-H,O-Z)
      INTEGER       NDIR(*),TCOSUP(*),NORDR(*),NSUPP(*),TCOSAP(NBSUP,*)
      REAL*8        AMORT(*),SPECTR(*),ASSPEC(*),DEPSUP(*),REASUP(*)
      CHARACTER*(*) RESU,MASSE,MOME,PSMO,STAT,TYPCMO,TYPCDI,
     +              KNOMSY(*),NOMSUP(*)
      LOGICAL       MONOAP, COMDIR, TRONC, CORFRE
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 18/06/2002   AUTEUR CIBHHPD D.NUNEZ 
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
C              SEE THE FILE "LICENSE.TERMS" FOR INFORMATION ON USAGE AND
C              REDISTRIBUTION OF THIS FILE.
C ======================================================================
C TOLE CRP_21
C     ------------------------------------------------------------------
C
C     UTILISE PAR LA COMMANDE : COMB_SISM_MODAL
C
C     ------------------------------------------------------------------
C IN  : RESU   : NOM UTILISATEUR DE LA COMMANDE
C IN  : MASSE  : MATRICE ASSEMBLEE
C IN  : MOME   : MODES MECANIQUES
C IN  : PSMO   : PSEUDO-MODES (SI PRISE EN COMPTE DE LA TRONCATURE)
C IN  : STAT   : MODE STATIQUES (CAS MULTI-SUPPORT)
C IN  : NBMODE : NOMBRE DE MODES
C IN  : NEQ    : NOMBRE D'EQUATIONS
C IN  : NORDR  : NUMERO D'ORDRE DES MODES MECANIQUES
C IN  : KNOMSY : LES OPTIONS DE CALCUL
C IN  : NBOPT  : NOMBRE D'OPTION DE CALCUL
C IN  : NDIR   : DIRECTIONS DE CALCUL
C IN  : MONOAP : =.TRUE.  , CAS DU MONO-SUPPORT
C                =.FALSE. , CAS DU MULTI-SUPPORT
C IN  : NBSUP  : NOMBRE DE SUPPORT
C IN  : NSUPP  : MAX DU NOMBRE DE SUPPORT PAR DIRECTION
C IN  : TYPCMO : TYPE DE RECOMBINAISON DES MODES
C IN  : TEMPS  : DUREE FORTE DU SEISME (TYPCMO='DSC')
C IN  : COMDIR : =.TRUE.  , COMBINAISON DES DIRECTIONS
C                =.FALSE. , PAS DE COMBINAISON DES DIRECTIONS
C IN  : TYPCDI : TYPE DE COMBINAISON DES DIRECTIONS
C IN  : TRONC  : =.TRUE.  , PRISE EN COMPTE DE LA TRONCATURE
C                =.FALSE. , PAS DE PRISE EN COMPTE DE LA TRONCATURE
C IN  : AMORT  : VECTEUR DES AMORTISSEMENTS MODAUX
C IN  : SPECTR : VECTEUR DES SPECTRES MODAUX
C IN  : ASSPEC : VECTEUR DES ASYMPTOTES DES SPECTRES AUX SUPPORTS
C IN  : NOMSUP : VECTEUR DES NOMS DES SUPPORTS
C IN  : REASUP : VECTEUR DES REACTIONS MODALES AUX SUPPORTS
C IN  : DEPSUP : VECTEUR DES DEPLACEMENTS DES SUPPORTS
C IN  : TCOSUP : TYPE DE RECOMBINAISON DES SUPPORTS
C IN  : CORFRE : =.TRUE.  , CORRECTION DES FREQUENCES
C IN  : IMPR   : NIVEAU D'IMPRESSION
C     ------------------------------------------------------------------
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER          ZI
      COMMON  /IVARJE/ ZI(1)
      REAL*8           ZR
      COMMON  /RVARJE/ ZR(1)
      COMPLEX*16       ZC
      COMMON  /CVARJE/ ZC(1)
      LOGICAL          ZL
      COMMON  /LVARJE/ ZL(1)
      CHARACTER*8      ZK8
      CHARACTER*16            ZK16
      CHARACTER*24                    ZK24
      CHARACTER*32                            ZK32
      CHARACTER*80                                    ZK80
      COMMON  /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
      PARAMETER    ( NBPARA = 5 )
      CHARACTER*4  CTYP
      CHARACTER*8  K8B, NUME
      CHARACTER*16 NOMSY, NOPARA(NBPARA)
      CHARACTER*19 KVEC, KVAL
      LOGICAL     PRIM,SECON,GLOB
C
      DATA  NOPARA /        'OMEGA2'          , 'MASS_GENE'       ,
     +  'FACT_PARTICI_DX' , 'FACT_PARTICI_DY' , 'FACT_PARTICI_DZ'  /
C     ------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL DISMOI('F','NOM_NUME_DDL',MASSE,'MATR_ASSE',IBID,NUME,IRET)
C
      CALL GETFAC ( 'COMB_DEPL_APPUI', NDEPL )
      IF ( NDEPL .NE. 0 ) THEN
         PRIM = .TRUE.
         SECON =.TRUE.
         GLOB = .FALSE.
      ELSE
         PRIM = .FALSE.
         SECON =.FALSE.
         GLOB = .TRUE.
      ENDIF
C
C
C     --- BOUCLE SUR LES OPTIONS DE CALCUL "NOMSY" ---
      DO 10 IN = 1,NBOPT
         KVEC = '&&ASCALC.VAL_PROPRE'
         KVAL = '&&ASCALC.GRAN_MODAL'
         NOMSY = KNOMSY(IN)
         IF (NOMSY(1:4).EQ.'VITE') NOMSY = 'DEPL'
         IF (NOMSY(1:4).EQ.'ACCE') NOMSY = 'DEPL'
         CALL VPRECU ( MOME, NOMSY, NBMODE, NORDR, KVEC, 
     +                 NBPARA, NOPARA, K8B, KVAL, K8B,
     +                 NEQ, NBMODE, CTYP, NBPARI, NBPARR, NBPARK )
         CALL JEVEUO(KVEC,'L',JMOD)
         CALL JEVEUO(KVAL,'L',JVAL)
         CALL WKVECT('&&ASCALC.REP_MOD','V V R',3*NEQ*NBMODE*NBSUP,JREP)
         CALL WKVECT('&&ASCALC.C_REP_MOD','V V R',3*NEQ*NBSUP,JCREP)
         CALL WKVECT('&&ASCALC.REP_DIR','V V R',3*NEQ,JDIR)
         CALL WKVECT('&&ASCALC.TABS','V V R',NBSUP*NEQ,JTABS)
C
C        ---------------------------------------------------------------
C                        REPONSE PRIMAIRE OU GLOBAL
C        ---------------------------------------------------------------
C
C        --- BOUCLE SUR LES DIRECTIONS ----
         DO 20 ID = 1,3
            IF (NDIR(ID).EQ.1) THEN
C
C              --- CALCUL DES REPONSE MODALES ---
C
               CALL ASCARM(KNOMSY(IN),MONOAP,NBSUP,NSUPP,NEQ,NBMODE,
     +                     ZR(JMOD),ZR(JVAL),ID,REASUP,SPECTR,
     +                     ZR(JREP),CORFRE,AMORT)
C
C              --- COMBINAISON DES REPONSES MODALES ---
               CALL ASCORM(MONOAP,TYPCMO,NBSUP,NSUPP,NEQ,NBMODE,
     +                     ZR(JREP),AMORT,ZR(JVAL),ID,TEMPS,
     +                     ZR(JCREP),ZR(JTABS))

C
C              --- PRISE EN COMPTE DES EFFETS D'ENTRAINEMENT ---
C              --- DANS LE CAS DE CALCUL DE REPONSE GLOBALE  ---
C
               IF ( (.NOT.MONOAP) .AND. GLOB ) THEN
                  CALL ASEFEN (GLOB,NOMSY,MASSE,ID,STAT,NEQ,NBSUP,
     +                              NSUPP,NOMSUP,DEPSUP,ZR(JCREP))
               ENDIF
C
C              ----CALCUL DE L ACCELERATION ABSOLUE
C
               CALL ASACCE(KNOMSY(IN),MONOAP,NBSUP,NSUPP,NEQ,NBMODE,
     +                        ID,NUME,ZR(JMOD),ZR(JVAL),ASSPEC,
     +                        NOMSUP,REASUP,ZR(JCREP) )
C
C              --- PRISE EN COMPTE DE LA TRONCATURE ---
C              --- DANS LE CAS DE CALCUL DE REPONSE GLOBALE  ---

               IF ( TRONC ) THEN
                 CALL ASTRON(KNOMSY(IN),PSMO,MONOAP,NBSUP,NSUPP,
     +                     NEQ,NBMODE,ID,NUME,ZR(JMOD),ZR(JVAL),ASSPEC,
     +                     NOMSUP,REASUP,ZR(JCREP) )
               ENDIF
C
C              --- CALCUL DES RECOMBINAISONS PAR DIRECTIONS---
               CALL ASDIR (MONOAP,ID,NEQ,NBSUP,NSUPP,
     +                     TCOSUP,ZR(JCREP),ZR(JDIR))
            ENDIF
 20      CONTINUE
C
C        --- STOCKAGE ---
C
         CALL ASSTOC(MOME,RESU,KNOMSY(IN),NEQ,ZR(JDIR),NDIR,
     +               COMDIR,TYPCDI,GLOB,PRIM,SECON)
C
C        ---------------------------------------------------------------
C                            REPONSE SECONDAIRE
C        ---------------------------------------------------------------
         IF ( SECON ) THEN
          ZERO =0.0D0
          DO 2 IS = 1,3*NBSUP*NEQ
            ZR(JCREP+IS-1) = ZERO
 2        CONTINUE
C
C        --- BOUCLE SUR LES DIRECTIONS ----
          DO 30 ID = 1,3
            IF (NDIR(ID).EQ.1) THEN
C
C              --- PRISE EN COMPTE DES EFFETS D'ENTRAINEMENT ---
C              --- DANS LE CAS DE CALCUL DE REPONSE GLOBALE  ---
C
               CALL ASEFEN (GLOB,NOMSY,MASSE,ID,STAT,NEQ,NBSUP,
     +                              NSUPP,NOMSUP,DEPSUP,ZR(JCREP))
C
C              --- CALCUL DES RECOMBINAISONS PAR DIRECTIONS---

               CALL ASDIR (MONOAP,ID,NEQ,NBSUP,NSUPP,
     +                     TCOSAP,ZR(JCREP),ZR(JDIR))
            ENDIF
 30      CONTINUE
C
C        --- STOCKAGE ---
C
         CALL ASSTOC(MOME,RESU,KNOMSY(IN),NEQ,ZR(JDIR),NDIR,
     +               .FALSE.,TYPCDI,.FALSE.,.FALSE.,.TRUE.)
C
         ENDIF
C
         CALL JEDETR(KVEC)
         CALL JEDETR(KVAL)
         CALL JEDETR('&&ASCALC.REP_MOD')
         CALL JEDETR('&&ASCALC.C_REP_MOD')
         CALL JEDETR('&&ASCALC.REP_DIR')
         CALL JEDETR('&&ASCALC.TABS')
 10   CONTINUE
C
      CALL JEDEMA()
      END
