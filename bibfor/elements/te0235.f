      SUBROUTINE TE0235 ( OPTION , NOMTE )
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 04/04/2002   AUTEUR VABHHTS J.PELLET 
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
C    - FONCTION REALISEE:  CALCUL DES VECTEURS ELEMENTAIRES
C                          OPTION : 'CHAR_THER_EVOLNI'
C                                   'CHAR_SENS_EVOLNI'
C                          ELEMENTS 2D ISOPARAMETRIQUES
C
C    - ARGUMENTS:
C        DONNEES:      OPTION       -->  OPTION DE CALCUL
C                      NOMTE        -->  NOM DU TYPE ELEMENT
C
C THERMIQUE NON LINEAIRE ET SECHAGE
C   -------------------------------------------------------------------
C     ASTER INFORMATIONS:
C       05/03/02 (OB): MODIFICATIONS POUR INSERER LES ARGUMENTS OPTION
C        NELS PERMETTANT D'UTILISER CETTE ROUTINE POUR CALCULER LA
C        SENSIBILITE PAR RAPPORT AUX CARACTERISTIQUES MATERIAU.
C        + MODIFS FORMELLES: IMPLICIT NONE, IDENTATION...
C----------------------------------------------------------------------
C CORPS DU PROGRAMME
      IMPLICIT NONE

C PARAMETRES D'APPEL
      CHARACTER*16       NOMTE,OPTION

C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
      CHARACTER*32       JEXNUM , JEXNOM , JEXR8 , JEXATR
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
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------

      CHARACTER*6   NOMPRO
      PARAMETER   ( NOMPRO = 'TE0235' )
      CHARACTER*2   CODRET
      CHARACTER*8   ELREFE
      CHARACTER*24  CARAC,FF
      REAL*8        BETA,DBETA,LAMBDA,R8BID,CHAL,DFDX(9),DFDY(9),POIDS,
     &              R,TPG,THETA,DIFF, TPSEC,DELTAT,DTPGDX,DTPGDY,LAMBS,
     &              CPS,PREC,R8PREM,DTPGMX,DTPGMY,DTPGPX,DTPGPY,
     &              TEMS,DLAMBD,FLUXS(2),TPGBUF,TPGM
      INTEGER       NNO,KP,NPG1,NPG2,I,K,ITEMPS,IVECTT,IVECTI,ICARAC,
     &              IFF,IPOIDS,IVF,IDFDE,IDFDK,IGEOM,IMATE,ICOMP,IHYDR,
     &              IFON(3),ISECHI,ISECHF,ITEMP,IMATSE,IVAPRI,IVAPRM,
     &              IFONS(3),TETYPS,IFM,NIV
      LOGICAL       LSENS,LSTAT,LAXI,LHYD

C====
C 1.1 PREALABLES: RECUPERATION ADRESSES FONCTIONS DE FORMES...
C====
      CALL ELREF1(ELREFE)
      PREC = R8PREM()*10.D0
      CARAC='&INEL.'//ELREFE//'.CARAC'
      CALL JEVETE(CARAC,'L',ICARAC)
      NNO  = ZI(ICARAC)
      NPG1 = ZI(ICARAC+2)
      NPG2 = ZI(ICARAC+3)
      FF   ='&INEL.'//ELREFE//'.FF'
      CALL JEVETE(FF,'L',IFF)
      IPOIDS=IFF   +NPG1*(1+3*NNO)
      IVF   =IPOIDS+NPG2
      IDFDE =IVF   +NPG2*NNO
      IDFDK =IDFDE +NPG2*NNO
      IF (NOMTE(3:4).EQ.'AX') THEN
        LAXI = .TRUE.
      ELSE
        LAXI = .FALSE.
      ENDIF
      IF (OPTION(6:9).EQ.'SENS') THEN
        LSENS = .TRUE.
      ELSE IF (OPTION(6:9).EQ.'THER') THEN
        LSENS = .FALSE.
      ELSE
        CALL UTMESS('F','TE0235','OPTION DE CALCUL INVALIDE')
      ENDIF


C====
C 1.2 PREALABLES LIES AUX CALCULS DE SENSIBILITE PART I
C====

      LSTAT = .FALSE.
      IMATSE = 0
      IF (LSENS) THEN
        CALL TECACH(.TRUE.,.FALSE.,'PMATSEN',1,IMATSE)
        CALL JEVECH('PVAPRIN','L',IVAPRI)
        CALL TECACH(.TRUE.,.FALSE.,'PVAPRMO',1,IVAPRM)
C DANS LE CAS DES DERIVEES MATERIAUX:
C L'ABSENCE DE CE CHAMP DETERMINE LE CRITERE STATIONNAIRE OU PAS
C ON "TRUANDE" ALORS DE MANIERE PEU OPTIMALE MAIS FACILE A MAINTE
C NIR: CP ET/OU CPS SONT ANNULES ET ON CREE UN CHAMP T- BIDON.
        IF (IVAPRM.EQ.0) THEN
          LSTAT = .TRUE.
          IVAPRM = IVAPRI
        ENDIF
      ENDIF

C====
C 1.3 PREALABLES LIES AUX RECHERCHES DE DONNEES GENERALES
C====

      CALL JEVECH('PGEOMER','L',IGEOM )
      CALL JEVECH('PMATERC','L',IMATE )
      CALL JEVECH('PTEMPSR','L',ITEMPS)
      IF (.NOT.LSTAT) CALL JEVECH('PTEMPER','L',ITEMP )
      CALL JEVECH('PCOMPOR','L',ICOMP)
      CALL JEVECH('PVECTTR','E',IVECTT)
      CALL JEVECH('PVECTTI','E',IVECTI)
      DELTAT = ZR(ITEMPS+1)
      THETA  = ZR(ITEMPS+2)

C====
C 2. CALCUL DE L'OPTION SI SECHAGE
C====

      IF(ZK16(ICOMP)(1:5).EQ.'SECH_') THEN
        IF (LSENS) CALL UTMESS('F',NOMPRO,
     &    'OPTION SENSIBILITE NON DEVELOPPEE EN SECHAGE')
        IF(ZK16(ICOMP)(1:12).EQ.'SECH_GRANGER'
     & .OR.ZK16(ICOMP)(1:10).EQ.'SECH_NAPPE') THEN
           CALL JEVECH('PTMPCHI','L',ISECHI)
           CALL JEVECH('PTMPCHF','L',ISECHF)
        ELSE
C          POUR LES AUTRES LOIS, PAS DE CHAMP DE TEMPERATURE
C          ISECHI ET ISECHF SONT FICTIFS
           ISECHI = ITEMP
           ISECHF = ITEMP
        ENDIF
        DO 201 KP=1,NPG2
          K=(KP-1)*NNO
          CALL DFDM2D ( NNO,ZR(IPOIDS+KP-1),ZR(IDFDE+K),ZR(IDFDK+K),
     &                  ZR(IGEOM),DFDX,DFDY,POIDS )
          R      = 0.D0
          TPG    = 0.D0
          DTPGDX = 0.D0
          DTPGDY = 0.D0
          TPSEC  = 0.D0
          DO 202 I=1,NNO
            R      = R      + ZR(IGEOM+2*(I-1))*ZR(IVF+K+I-1)
            TPG    = TPG    + ZR(ITEMP+I-1)    *ZR(IVF+K+I-1)
            DTPGDX = DTPGDX + ZR(ITEMP+I-1)    *DFDX(I)
            DTPGDY = DTPGDY + ZR(ITEMP+I-1)    *DFDY(I)
            TPSEC  = TPSEC  + ZR(ISECHI+I-1)   *ZR(IVF+K+I-1)
202       CONTINUE
          CALL RCDIFF(ZI(IMATE), ZK16(ICOMP), TPSEC,  TPG, DIFF )
          IF (LAXI) POIDS = POIDS*R
CCDIR$ IVDEP
          DO 203 I=1,NNO
             ZR(IVECTT+I-1) = ZR(IVECTT+I-1) + POIDS *
     &        ( TPG/DELTAT*ZR(IVF+K+I-1)
     &         -(1.0D0-THETA)*DIFF*(DFDX(I)*DTPGDX+DFDY(I)*DTPGDY) )
             ZR(IVECTI+I-1) = ZR(IVECTT+I-1)
203       CONTINUE
201     CONTINUE

      ELSE

C====
C 3. CALCULS DE L'OPTION POUR NEWTON (CALCUL STD) AVEC EVENTUELLEMENT
C    HYDRATATION OU POUR LA SENSIBILITE (SANS HYDRATATION)
C====

C====
C 3.1 PREALABLES LIES A L'HYDRATATION
C====
        CALL NTFCMA (ZI(IMATE),IFON)
        IF (ZK16(ICOMP)(1:9).EQ.'THER_HYDR') THEN
          LHYD = .TRUE.
          IF (LSENS) CALL UTMESS('F',NOMPRO,
     &      'OPTION SENSIBILITE NON DEVELOPPEE EN HYDRATATION')
          CALL JEVECH('PHYDRPG','L',IHYDR )
          CALL RCVALA (ZI(IMATE),'THER_HYDR',0,' ',R8BID,1,'CHALHYDR',
     &                 CHAL,CODRET,'FM')
        ELSE
          LHYD = .FALSE.
        ENDIF
C====
C 3.2 PREALABLES LIES AUX CALCULS DE SENSIBILITE PART II
C     (NE CONCERNE QUE LES DERIVES MATERIAU AVEC UN IMATSE NON NUL)
C====
        TETYPS = 0
        IF (IMATSE.NE.0) THEN
          CALL INFNIV(IFM,NIV)
          CALL NTFCMA(ZI(IMATSE),IFONS)
          TPG = 0.D0
          IF (LSTAT) THEN
            CALL RCFODE(IFONS(2),TPG,LAMBS,R8BID)
            CPS    = 0.D0
          ELSE
            CALL RCFODE(IFONS(1),TPG,R8BID,CPS)
            CALL RCFODE(IFONS(2),TPG,LAMBS,R8BID)
          ENDIF
          IF ((ABS(CPS).LT.PREC).AND.(ABS(LAMBS).LT.PREC)) THEN
C PAS DE TERME DE SENSIBILITE SUPPLEMENTAIRE, CALCUL INSENSIBLE
            TETYPS = 0
          ELSE IF (ABS(LAMBS).LT.PREC) THEN
C SENSIBILITE PAR RAPPORT A RHO_CP
            TETYPS = 2
          ELSE IF (CPS.LT.PREC) THEN
C SENSIBILITE PAR RAPPORT A LAMBDA
            TETYPS = 1
          ELSE
           CALL UTMESS('F',NOMPRO,'PB DETERMINATION '//
     &                      'SENSIBILITE MATERIAU THER_NL')
          ENDIF
          IF (NIV.EQ.2) THEN
            WRITE(IFM,*)'   CPS/LAMBS :',CPS,LAMBS
          ENDIF
        ENDIF

        DO 401 KP=1,NPG2
          K=(KP-1)*NNO
          CALL DFDM2D ( NNO,ZR(IPOIDS+KP-1),ZR(IDFDE+K),ZR(IDFDK+K),
     &                  ZR(IGEOM),DFDX,DFDY,POIDS )
          R      = 0.D0
          TPG    = 0.D0
          DTPGDX = 0.D0
          DTPGDY = 0.D0
          IF (.NOT.LSTAT) THEN
            DO 402 I=1,NNO
C CALCUL DE T- (OU (DT/DS)- EN SENSI) ET DE SON GRADIENT
              TPG    = TPG    + ZR(ITEMP+I-1)    *ZR(IVF+K+I-1)
              DTPGDX = DTPGDX + ZR(ITEMP+I-1)    *DFDX(I)
              DTPGDY = DTPGDY + ZR(ITEMP+I-1)    *DFDY(I)
402         CONTINUE
          ENDIF
          IF (LAXI) THEN
            DO 403 I=1,NNO
C CALCUL DE R POUR JACOBIEN
              R      = R      + ZR(IGEOM+2*(I-1))*ZR(IVF+K+I-1)
403         CONTINUE
            POIDS = POIDS*R
          ENDIF

C CALCUL DE SENSIBILITE PART III
          IF (LSENS) THEN
            DTPGMX  = 0.D0
            DTPGMY  = 0.D0
            DTPGPX  = 0.D0
            DTPGPY  = 0.D0
            TEMS    = 0.D0
            TPGM    = 0.D0
          ENDIF
          IF (TETYPS.EQ.1) THEN
            DO 412 I=1,NNO
C CALCUL DE GRAD(T+) POUR TERME DE RIGIDITE. LE TERME GRAD(T-)
C EST CALCULE SI NECESSAIRE CI-DESSOUS.
              DTPGPX = DTPGPX  + ZR(IVAPRI+I-1) * DFDX(I)
              DTPGPY = DTPGPY  + ZR(IVAPRI+I-1) * DFDY(I)
412         CONTINUE
          ELSE IF ((TETYPS.EQ.2).AND.(.NOT.LSTAT)) THEN
            DO 414 I=1,NNO
C CALCUL DE (T- - T+) POUR TERME DE MASSE
              TEMS=TEMS+(ZR(IVAPRM+I-1)-ZR(IVAPRI+I-1))*ZR(IVF+K+I-1)
414         CONTINUE
          ENDIF
          IF (LSENS.AND.(.NOT.LSTAT)) THEN
            DO 416 I=1,NNO
C CALCUL DE GRAD(T-) POUR TERME COMPLEMENTAIRE EN DLAMBDA/DT
              DTPGMX = DTPGMX  + ZR(IVAPRM+I-1) * DFDX(I)
              DTPGMY = DTPGMY  + ZR(IVAPRM+I-1) * DFDY(I)
C CALCUL DE T- EN SENSIBILITE
              TPGM   = TPGM    + ZR(IVAPRM+I-1) * ZR(IVF+K+I-1)
416         CONTINUE
          ENDIF

C CALCUL DES CARACTERISTIQUES MATERIAUX STD EN TRANSITOIRE UNIQUEMENT
C POUR LE PB STD ON LES EVALUE AVEC TPG=T-
C POUR LE PB DERIVE, ON UTILISE TPGM=T-
          IF (.NOT.LSTAT) THEN
            IF (.NOT.LSENS) THEN
              TPGBUF = TPG
            ELSE
              TPGBUF = TPGM
            ENDIF
            CALL RCFODE (IFON(1),TPGBUF,BETA,DBETA)
            CALL RCFODE (IFON(2),TPGBUF,LAMBDA,DLAMBD)
          ELSE
            BETA = 0.D0
            DBETA = 0.D0
            LAMBDA = 0.D0
            DLAMBD = 0.D0
          ENDIF

CCDIR$ IVDEP
          IF(LHYD) THEN
C THER_HYDR

            DO 420 I=1,NNO
              ZR(IVECTT+I-1) = ZR(IVECTT+I-1) + POIDS *
     &         ((BETA-CHAL*ZR(IHYDR+KP-1))*ZR(IVF+K+I-1)/DELTAT
     &          -(1.0D0-THETA)*LAMBDA*(DFDX(I)*DTPGDX+DFDY(I)*DTPGDY))
              ZR(IVECTI+I-1) = ZR(IVECTI+I-1) + POIDS *
     &         ((DBETA*TPG-CHAL*ZR(IHYDR+KP-1))*ZR(IVF+K+I-1)/DELTAT
     &         -(1.0D0-THETA)*LAMBDA*(DFDX(I)*DTPGDX+DFDY(I)*DTPGDY))
420        CONTINUE
          ELSE
C THER_NL

            IF (.NOT.LSENS) THEN
C CALCUL STD A 2 OUTPUTS (LE DEUXIEME NE SERT QUE POUR LA PREDICTION)

              DO 422 I=1,NNO
                ZR(IVECTT+I-1) = ZR(IVECTT+I-1) + POIDS *
     &            (BETA/DELTAT*ZR(IVF+K+I-1)
     &           -(1.0D0-THETA)*LAMBDA*(DFDX(I)*DTPGDX+DFDY(I)*DTPGDY))
                ZR(IVECTI+I-1) = ZR(IVECTI+I-1) + POIDS *
     &            (DBETA*TPG/DELTAT*ZR(IVF+K+I-1)
     &           -(1.0D0-THETA)*LAMBDA*(DFDX(I)*DTPGDX+DFDY(I)*DTPGDY))
422           CONTINUE
            ELSE

C CALCUL DE SENSIBILITE PART IV: TRONC COMMUN TRANSITOIRE
              IF (.NOT.LSTAT) THEN
                DO 424 I=1,NNO
                  ZR(IVECTT+I-1) = ZR(IVECTT+I-1) + POIDS*(
     &              (DBETA*TPG*ZR(IVF+K+I-1)/DELTAT)+
     &            (THETA-1.D0)*(LAMBDA*(DFDX(I)*DTPGDX+DFDY(I)*DTPGDY)+
     &                      DLAMBD*TPG*(DFDX(I)*DTPGMX+DFDY(I)*DTPGMY)))
424             CONTINUE
              ENDIF

C CALCUL DE SENSIBILITE PART V: TERME PARTICULIER STATIONNAIRE OU TRANSI
              IF (TETYPS.EQ.1) THEN
                FLUXS(1) = THETA*DTPGPX+(1.D0-THETA)*DTPGMX
                FLUXS(2) = THETA*DTPGPY+(1.D0-THETA)*DTPGMY
                DO 426 I=1,NNO
                  ZR(IVECTT+I-1) = ZR(IVECTT+I-1) - POIDS*LAMBS*(
     &                DFDX(I)*FLUXS(1)+DFDY(I)*FLUXS(2))
426             CONTINUE
              ELSE IF ((TETYPS.EQ.2).AND.(.NOT.LSTAT)) THEN
                DO 428 I=1,NNO
                  ZR(IVECTT+I-1) = ZR(IVECTT+I-1) + POIDS*CPS/DELTAT*
     &                             ZR(IVF+K+I-1)*TEMS
428             CONTINUE
              ENDIF

C FIN DU IF LSENS
            ENDIF
C FIN DU IF THERMIQUE AVEC OU SANS HYDRATATION
          ENDIF
C FIN BOUCLE SUR LES PT DE GAUSS
401     CONTINUE
C FIN DU IF SECHAGE OU THERMIQUE
      ENDIF
C FIN ------------------------------------------------------------------
      END
