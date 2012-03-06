      SUBROUTINE DLDIFF ( LCREA,LAMORT,NEQ,IMAT,
     &                    MASSE,RIGID,AMORT,
     &                    DEP0,VIT0,ACC0,FEXTE,FAMOR,FLIAI,T0,
     &                    NCHAR,NVECA,LIAD,LIFO,
     &                    MODELE,MATE,CARELE,
     &                    CHARGE,INFOCH,FOMULT,NUMEDD,NUME,
     &                    INPSCO,NBPASE,SOLVEU)
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 05/03/2012   AUTEUR IDOUX L.IDOUX 
C ======================================================================
C COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
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
C TOLE CRP_21
C     ------------------------------------------------------------------
C     CALCUL MECANIQUE TRANSITOIRE PAR INTEGRATION DIRECTE
C     AVEC  METHODE EXPLICITE :  DIFFERENCES CENTREES
C
C     ------------------------------------------------------------------
C
C  HYPOTHESES :                                                "
C  ----------   SYSTEME CONSERVATIF DE LA FORME  K.U    +    M.U = F
C           OU                                           '     "
C               SYSTEME DISSIPATIF  DE LA FORME  K.U + C.U + M.U = F
C
C     ------------------------------------------------------------------
C  IN  : LCREA     : LOGIQUE INDIQUANT SI IL Y A REPRISE
C  IN  : LAMORT    : LOGIQUE INDIQUANT SI IL Y A AMORTISSEMENT
C  IN  : NEQ       : NOMBRE D'EQUATIONS
C  IN  : IMAT      : TABLEAU D'ADRESSES POUR LES MATRICES
C  IN  : MASSE     : MATRICE DE MASSE
C  IN  : RIGID     : MATRICE DE RIGIDITE
C  IN  : AMORT     : MATRICE D'AMORTISSEMENT
C  IN  : NCHAR     : NOMBRE D'OCCURENCES DU MOT CLE CHARGE
C  IN  : NVECA     : NOMBRE D'OCCURENCES DU MOT CLE VECT_ASSE
C  IN  : LIAD      : LISTE DES ADRESSES DES VECTEURS CHARGEMENT (NVECT)
C  IN  : LIFO      : LISTE DES NOMS DES FONCTIONS EVOLUTION (NVECT)
C  IN  : T0        : INSTANT DE CALCUL INITIAL
C  IN  : MODELE    : NOM DU MODELE
C  IN  : MATE      : NOM DU CHAMP DE MATERIAU
C  IN  : CARELE    : CARACTERISTIQUES DES POUTRES ET COQUES
C  IN  : CHARGE    : LISTE DES CHARGES
C  IN  : INFOCH    : INFO SUR LES CHARGES
C  IN  : FOMULT    : LISTE DES FONC_MULT ASSOCIES A DES CHARGES
C  IN  : NUMEDD    : NUME_DDL DE LA MATR_ASSE RIGID
C  IN  : NUME      : NUMERO D'ORDRE DE REPRISE
C  IN  : NBPASE   : NOMBRE DE PARAMETRE SENSIBLE
C  IN  : INPSCO   : STRUCTURE CONTENANT LA LISTE DES NOMS (CF. PSNSIN)
C  VAR : DEP0      : TABLEAU DES DEPLACEMENTS A L'INSTANT N
C  VAR : VIT0      : TABLEAU DES VITESSES A L'INSTANT N
C  VAR : ACC0      : TABLEAU DES ACCELERATIONS A L'INSTANT N
C
C CORPS DU PROGRAMME
      IMPLICIT NONE

C DECLARATION PARAMETRES D'APPELS
      INTEGER      NEQ,IMAT(*),LIAD(*),NCHAR,NVECA,NUME
      INTEGER      NBPASE
C
      CHARACTER*8  MASSE, RIGID, AMORT
      CHARACTER*13 INPSCO
      CHARACTER*24 MODELE, CARELE, CHARGE, FOMULT, MATE, NUMEDD
      CHARACTER*24 INFOCH, LIFO(*)
      CHARACTER*19 SOLVEU
C
      REAL*8 DEP0(*), VIT0(*), ACC0(*), T0
      REAL*8 FEXTE(*), FAMOR(*), FLIAI(*)
C
      LOGICAL LAMORT, LCREA
C
C    ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
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
C     ----- FIN COMMUNS NORMALISES  JEVEUX  ---------------------------

      INTEGER NBTYAR
      PARAMETER ( NBTYAR = 6 )
      INTEGER IWK0, IWK1, IWK2
      INTEGER NRPASE, NRORES
      INTEGER IFM, NIV, ETAUSR
      INTEGER IDEPL1
      INTEGER IVITE1, IVITE2
      INTEGER IACCE1
      INTEGER IARCHI
      INTEGER IAUX, JAUX, IBID
      INTEGER IPEPA, IGRPA
      INTEGER IPAS, ISTOP, ISTOC, JSTOC
      INTEGER JNBPA, JBINT, JLPAS
      INTEGER NPATOT, NBGRPA, NBPTPA
      INTEGER NBEXCL, NBORDR
      CHARACTER*4 TYP1(NBTYAR)
      CHARACTER*8 NOMRES
      CHARACTER*16 TYPRES, NOMCMD, TYPEAR(NBTYAR)
      CHARACTER*19 LISARC
      CHARACTER*24 LISINS, LISPAS, LIBINT, LINBPA
      CHARACTER*24 SOP
      REAL*8 TPS1(4),TPS2(4)
      REAL*8 DT, DTM, DTMAX, TEMPS, DT1, TF
      REAL*8 OMEG, DEUXPI
      REAL*8 R8BID
      REAL*8 R8DEPI
      CHARACTER*8   VALK
      INTEGER       VALI(2)
      REAL*8        VALR(2)
      LOGICAL       ENER

C
C     -----------------------------------------------------------------
      CALL JEMARQ()
C
C====
C 1. LES DONNEES DU CALCUL
C====
C 1.1. ==> RECUPERATION DU NIVEAU D'IMPRESSION

      CALL INFNIV(IFM,NIV)
C
C 1.2. ==> NOM DES STRUCTURES
C     --- RECUPERATION NOM DE LA COMMANDE ---

      CALL GETRES(NOMRES,TYPRES,NOMCMD)
C
C 1.3. ==> VECTEURS DE TRAVAIL SUR BASE VOLATILE ---
C
      CALL WKVECT('&&DLDIFF.F0'    ,'V V R',NEQ,IWK0  )
      CALL WKVECT('&&DLDIFF.F1'    ,'V V R',NEQ,IWK1  )
      CALL WKVECT('&&DLDIFF.F2'    ,'V V R',NEQ,IWK2  )
      CALL VTCREB('&&DLDIFF.DEPL1',NUMEDD,'V','R',NEQ)
      CALL JEVEUO('&&DLDIFF.DEPL1     '//'.VALE','E',IDEPL1)
      CALL WKVECT('&&DLDIFF.VITE1' ,'V V R',NEQ,IVITE1 )
      CALL WKVECT('&&DLDIFF.VITE2' ,'V V R',NEQ,IVITE2 )
      CALL WKVECT('&&DLDIFF.ACCE1' ,'V V R',NEQ,IACCE1 )
C
      DEUXPI = R8DEPI()
      IARCHI = NUME
      ENER=.FALSE.
      CALL GETFAC('ENERGIE',IAUX)
      IF (IAUX.NE.0) THEN
        ENER=.TRUE.
      ENDIF
C
C 1.4. ==> PARAMETRES D'INTEGRATION
C
      CALL DLTINS(NBGRPA,LISPAS,LIBINT,LINBPA,NPATOT,T0,LISINS)
      CALL JEVEUO(LISPAS,'L',JLPAS)
      CALL JEVEUO(LIBINT,'L',JBINT)
      CALL JEVEUO(LINBPA,'L',JNBPA)     
C
C 1.5. ==> EXTRACTION DIAGONALE M ET CALCUL VITESSE INITIALE
C
      CALL DISMOI('C','SUR_OPTION',MASSE,'MATR_ASSE',IBID,SOP,IBID)
      IF ( SOP.EQ.'MASS_MECA_DIAG' ) THEN
        CALL EXTDIA (MASSE, NUMEDD, 2, ZR(IWK1))
      ELSE
        CALL U2MESS('F','ALGORITH3_13')
      ENDIF
C
      DT1 = ZR(JLPAS)
      R8BID = DT1/2.D0
      DO 15,  IAUX = 1, NEQ
        IF (ZR(IWK1+IAUX-1).NE.0.D0) THEN
           ZR(IWK1+IAUX-1)=1.0D0/ZR(IWK1+IAUX-1)
        ENDIF
        DO 151 , NRPASE = 0, NBPASE
          JAUX = NEQ*NRPASE + 1
          VIT0(JAUX+IAUX) = VIT0(JAUX+IAUX) - R8BID*ACC0(JAUX+IAUX)
  151   CONTINUE
   15 CONTINUE
C
C 1.6. ==> --- ARCHIVAGE ---
C
      LISARC = '&&DLDIFF.ARCHIVAGE'
      CALL  DYARCH ( NPATOT, LISINS, LISARC, NBORDR, 1, NBEXCL, TYP1 )
      CALL JEVEUO(LISARC,'E',JSTOC)
C
      TYPEAR(1) = 'DEPL'
      TYPEAR(2) = 'VITE'
      TYPEAR(3) = 'ACCE'
      IF (ENER) THEN
        TYPEAR(4) = 'FORC_EXTE'
        TYPEAR(5) = 'FORC_AMOR'
        TYPEAR(6) = 'FORC_LIAI'
      ELSE
        TYPEAR(4) = '         '
        TYPEAR(5) = '         '
        TYPEAR(6) = '         '
      ENDIF
      IF ( NBEXCL.EQ.NBTYAR ) THEN
        CALL U2MESS('F','ALGORITH3_14')
      ENDIF
      DO 16 , IAUX = 1,NBEXCL
        IF (TYP1(IAUX).EQ.'DEPL') THEN
          TYPEAR(1) = '    '
        ELSEIF (TYP1(IAUX).EQ.'VITE') THEN
          TYPEAR(2) = '    '
        ELSEIF (TYP1(IAUX).EQ.'ACCE') THEN
          TYPEAR(3) = '    '
        ENDIF
   16 CONTINUE
C
C 1.7. ==> --- AFFICHAGE DE MESSAGES SUR LE CALCUL ---
C
      WRITE(IFM,*) '-------------------------------------------------'
      WRITE(IFM,*) '--- CALCUL PAR INTEGRATION TEMPORELLE DIRECTE ---'
      WRITE(IFM,*) '! LA MATRICE DE MASSE EST         : ',MASSE
      WRITE(IFM,*) '! LA MATRICE DE RIGIDITE EST      : ',RIGID
      IF ( LAMORT ) WRITE(IFM,*)
     &'! LA MATRICE D''AMORTISSEMENT EST : ',AMORT
      WRITE(IFM,*) '! LE NB D''EQUATIONS EST          : ',NEQ
      IF ( NUME.NE.0 ) WRITE(IFM,*)
     &'! REPRISE A PARTIR DU NUME_ORDRE  : ',NUME
      DO 17 , IAUX = 1,NBGRPA
        DT = ZR(JLPAS-1+IAUX)
        NBPTPA = ZI(JNBPA-1+IAUX)
        T0 = ZR(JBINT-1+IAUX)
        TF = T0 + NBPTPA*DT
        WRITE(IFM,*)'! L''INSTANT INITIAL EST        : ',T0
        WRITE(IFM,*)'! L''INSTANT FINAL EST          : ',TF
        WRITE(IFM,*)'! LE PAS DE TEMPS DU CALCUL EST : ',DT
        WRITE(IFM,*)'! LE NB DE PAS DE CALCUL EST    : ',NBPTPA
   17 CONTINUE  
      WRITE(IFM,*) '----------------------------------------------',' '
C
C====
C 2. BOUCLE SUR CREATION DES CONCEPTS RESULTAT
C====
C
      T0 = ZR(JBINT) 
C         
      DO 21 , NRORES = 0 , NBPASE
C
        NRPASE = NRORES
        IAUX = 1 + NEQ*NRPASE
        JAUX = NBTYAR
C
        CALL DLTCRR ( NRPASE, INPSCO,
     &                NEQ, NBORDR, IARCHI, ' ', IFM,
     &                T0, LCREA, TYPRES,
     &                MASSE, RIGID, AMORT,
     &                DEP0(IAUX), VIT0(IAUX), ACC0(IAUX),
     &                FEXTE(1),FAMOR(1),FLIAI(1),
     &                NUMEDD, NUME, JAUX, TYPEAR )

   21 CONTINUE
C
      CALL TITRE
C       
C
C
C====
C 3. CALCUL
C====
C
C 3.1. ==> BOUCLE SUR LES GROUPES DE PAS DE TEMPS
      ISTOP = 0
      IPAS = 0
C
      CALL UTTCPU('CPU.DLDIFF.1','INIT',' ')
      CALL UTTCPU('CPU.DLDIFF.2','INIT',' ')
C
      DO 31 , IGRPA = 1,NBGRPA
C
C 3.1.1. ==> PREALABLES
C        
       CALL UTTCPU('CPU.DLDIFF.1','DEBUT',' ')       
       DT = ZR(JLPAS-1+IGRPA)
       NBPTPA = ZI(JNBPA-1+IGRPA)
       T0 = ZR(JBINT-1+IGRPA)
       TF = ZR(JBINT+IGRPA)
C
C 3.1.2. ==> VERIFICATION DU PAS DE TEMPS
C
       CALL EXTDIA( RIGID, NUMEDD, 2, ZR(IWK2))
       IBID=0
       DTMAX=DT
       DO 312 IAUX=1,NEQ
        IF (ZR(IWK1+IAUX-1).NE.0.D0) THEN
          OMEG = SQRT( ZR(IWK2+IAUX-1) * ZR(IWK1+IAUX-1) )
          DTM = 5.D-02*DEUXPI/OMEG
          IF (DTMAX.GT.DTM) THEN
            DTMAX=DTM
            IBID=1
          ENDIF
        ENDIF
  312  CONTINUE
C
       IF (IBID.EQ.1) THEN
        VALI(1) = NINT((TF-T0)/DTMAX)
        VALI(2) = IGRPA
        VALR(1) = DT
        VALR(2) = DTMAX
        CALL U2MESG('F', 'DYNAMIQUE_12', 0, VALK, 2, VALI, 2, VALR)
       ENDIF
C ==> FIN DE VERIFICATION
C
C       
C 3.1.3. ==> BOUCLE SUR LES NBPTPA "PETITS" PAS DE TEMPS
C
       DO 313 , IPEPA = 1 , NBPTPA
        IPAS = IPAS+1
        IF (IPAS.GT.NPATOT) GOTO 3900
        ISTOC = 0
        TEMPS = T0 + DT*IPEPA
        CALL UTTCPU('CPU.DLDIFF.2','DEBUT',' ')
C
C 3.1.3.1 ==> BOUCLE SUR LES CAS STANDARD ET SENSIBLES
C
        DO 3131 , NRORES = 0 , NBPASE
C
          NRPASE = NRORES
          IAUX = 1 + NEQ*NRPASE
          IBID = ZI(JSTOC+IPAS-1)
C
          CALL DLDIF0 ( NRPASE, NBPASE, INPSCO,
     &                  NEQ, ISTOC, IARCHI, IFM,
     &                  LAMORT,
     &                  IMAT, MASSE, RIGID, AMORT,
     &                  DEP0(IAUX), VIT0(IAUX), ACC0(IAUX),
     &                  ZR(IDEPL1), ZR(IVITE1), ZR(IACCE1), ZR(IVITE2),
     &                  FEXTE(1),FAMOR(1),FLIAI(1),
     &                  NCHAR, NVECA, LIAD, LIFO, MODELE,ENER,SOLVEU,
     &                  MATE, CARELE, CHARGE, INFOCH, FOMULT, NUMEDD,
     &                  DT, TEMPS,
     &                  ZR(IWK0), ZR(IWK1),
     &                  IBID, NBTYAR, TYPEAR )

 3131   CONTINUE
C
C 3.5. ==> VERIFICATION DU TEMPS DE CALCUL RESTANT
C
        CALL UTTCPU('CPU.DLDIFF.2','FIN',' ')
        CALL UTTCPR('CPU.DLDIFF.2', 4, TPS2)
        IF ( TPS2(1) .LT. 5.D0  .OR. TPS2(4).GT.TPS2(1) ) THEN
           IF ( IPEPA .NE. NPATOT ) THEN
            ISTOP = 1
            VALI(1) = IGRPA
            VALI(2) = IPEPA            
            VALR(1) = TPS2(4)
            VALR(2) = TPS2(1)
            GOTO 3900
           ENDIF
        ENDIF
C
C ---------- FIN DE LA BOUCLE SUR LES NBPTPA "PETITS" PAS DE TEMPS
  313 CONTINUE
      CALL UTTCPU('CPU.DLDIFF.1','FIN',' ')
      CALL UTTCPR('CPU.DLDIFF.1',4,TPS1)
      IF (TPS1(1).LT.5.D0 .AND. IGRPA.NE.NBGRPA) THEN
          ISTOP = 1
          VALI(1) = IGRPA
          VALI(2) = IPEPA
          VALR(1) = TPS1(4)
          VALR(2) = TPS1(1)
          GO TO 3900
      END IF
C ------- FIN BOUCLE SUR LES GROUPES DE PAS DE TEMPS   
   31 CONTINUE  
C
 3900 CONTINUE
C
C====
C 4. ARCHIVAGE DU DERNIER INSTANT DE CALCUL POUR LES CHAMPS QUI ONT
C    ETE EXCLUS DE L'ARCHIVAGE AU FIL DES PAS DE TEMPS
C====
C
      IF ( NBEXCL.NE.0 ) THEN
C
        DO 41 , IAUX = 1,NBEXCL
          TYPEAR(IAUX) = TYP1(IAUX)
   41   CONTINUE
C
        JAUX = 0
        DO 42 , NRORES = 0 , NBPASE

          NRPASE = NRORES
          IAUX = NEQ*NRPASE
C
          CALL DLARCH ( NRORES, INPSCO,
     &                  NEQ, ISTOC, IARCHI, ' ',
     &                  JAUX, IFM, TEMPS,
     &                  NBEXCL, TYPEAR, MASSE,
     &                  ZR(IDEPL1+IAUX), ZR(IVITE1+IAUX),
     &                  ZR(IACCE1+IAUX), FEXTE(1+NEQ),
     &                  FAMOR(1+NEQ), FLIAI(1+NEQ) )
C
   42   CONTINUE
C
      ENDIF
C
C====
C 5. LA FIN
C====
C
C --- VERIFICATION SI INTERRUPTION DEMANDEE PAR SIGNAL USR1
C
      IF ( ETAUSR().EQ.1 ) THEN
         CALL SIGUSR()
      ENDIF
C
      IF (ISTOP.EQ.1) THEN
        CALL UTEXCM(28, 'DYNAMIQUE_10', 0, VALK, 2, VALI, 2, VALR)
      ENDIF
C
C     --- DESTRUCTION DES OBJETS DE TRAVAIL ---
C
      CALL JEDETC('V','.CODI',20)
      CALL JEDETC('V','.MATE_CODE',9)
C
      CALL JEDEMA()

      END
