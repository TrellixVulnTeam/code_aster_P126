      SUBROUTINE FOCASO(NOMFON,METHOD,NBAMOR,AMOR,NBFREQ,FREQ,NORME,
     +                                Q0,V0,NATURE,NATURF,SPECTR,BASE)
      IMPLICIT REAL*8 (A-H,O-Z)
      CHARACTER*(*)     NOMFON,METHOD,      NATURE,NATURF,SPECTR
      INTEGER                         NBAMOR,     NBFREQ
      REAL*8                                 AMOR(*),   FREQ(*),NORME
      REAL*8                                 Q0,V0
      CHARACTER*1                                                BASE
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 11/04/97   AUTEUR VABHHTS J.PELLET 
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
C     CREATION (ET CALCUL) DU SPECTRE D'OSCILLATEUR D'UNE FONCTION
C     ------------------------------------------------------------------
C IN  NOMFON : K19 : NOM DE LA FONCTION DONT ON CALCULE LE SPECTRE
C IN  METHOD : K16 : METHODE POUR LE CALCUL DU SPECTRE
C       = 1 : CALCUL DE L'INTEGRALE DE DUHAMEL PAR LA METHODE DE SIMPSON
C IN  NBAMOR : IS  : NOMBRE D'AMORTISSEMENT
C IN  AMOR   : R8  : LISTE DES AMORTISSEMENTS
C IN  NBFREQ : IS  : NOMBRE DE FREQUENCES
C IN  FREQ   : R8  : LISTE DES FREQUENCES
C IN  Q0     : R8  : DEPLACEMENT INITIAL
C IN  V0     : R8  : VITESSE INITIALE
C IN  NATURE : K8  : NATURE DU SPECTRE
C IN  NATURF : K8  : NATURE DE LA FONCTION
C OUT SPECTR : K8  : NOM DU SPECTRE D'OSCILLATEUR A CREER
C                  : (C'EST UNE NAPPE  F(AMOR,FREQ) )
C     ------------------------------------------------------------------
C     PRECAUTION D'EMPLOI:    LA NAPPE "SPECTR" NE DOIT PAS EXISTER
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
      CHARACTER*16              ZK16
      CHARACTER*24                        ZK24
      CHARACTER*32                                  ZK32
      CHARACTER*80                                            ZK80
      COMMON  /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      CHARACTER*32 JEXNUM
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
      REAL*8       DELTAT,DELTA1,DELTA2,UN,EPS,ECART,EPS1
      CHARACTER*8  NOMRES
      CHARACTER*16 CBID
      CHARACTER*19 NOMCMD
      CHARACTER*24 PROL  , VALE, PARA
C     ----------------------------------------------------------------
      CALL JEMARQ()
      NOMCMD = 'SPECTRE_OSCILLATEUR'
      IF ( ABS(NORME) .LT. 1.D-10 ) THEN
         CALL UTMESS('F',NOMCMD,'LA NORME NE PEUT ETRE NULLE.')
      ENDIF
C
      IF ( NATURF(1:4) .NE. 'ACCE' ) CALL UTMESS('F',NOMCMD,
     +                      'LE TYPE DE LA FONCTION DOIT ETRE "ACCE".')
C
      CALL WKVECT('&&FOCASO.SPECTRE_DEP','V V R',3*NBAMOR*NBFREQ,LSPECT)
      UN   = 1.D0
      EPS  = 1.D-6
C
      VALE( 1:19) = NOMFON
      VALE(20:24) = '.VALE'
      CALL JEVEUO(VALE,'L',LVAR)
      CALL JELIRA(VALE,'LONUTI',NBVAL,CBID)
      NBINST = NBVAL/2
      LFON   = LVAR + NBINST
C
      IF ( METHOD .EQ. 'NIGAM' .OR. METHOD .EQ. '  ' ) THEN
C
C        --- VERIFICATION QUE L'ON EST EN AMORTISSEMENT SOUS-CRITIQUE --
         DO 30 IAMOR = 1,NBAMOR
            IF ( AMOR(IAMOR) .GT. UN-EPS) THEN
              CALL UTMESS('F',NOMCMD,'LA METHODE CHOISIE'
     +                     //' SUPPOSE DES AMORTISSEMENTS SOUS-CRITIQUE'
     +                     //' (IE AMOR < 1.).')
            ENDIF
  30     CONTINUE
C
C        --- INTEGRATION PAR LA METHODE DE NIGAM_JENNINGS (SPECTRE) ---
         CALL UTDEBM('I',NOMCMD,
     +                  'INTEGRATION PAR LA METHODE DE NIGAM_JENNINGS')
C
C        --- EST-ON A PAS CONSTANT ? ---
         DELTAT = ZR(LVAR+1) - ZR(LVAR)
         DELTA1 = DELTAT
         ECART  = 0.D0
         DO 20 INST = 2,NBINST-1
            DELTA2 = ZR(LVAR+INST) - ZR(LVAR+INST-1)
            ECART2 = ( DELTA2 - DELTA1 ) / DELTA2
            IF ( ABS(ECART2) .GT. EPS ) GOTO 22
            DELTAT = MAX( DELTAT , DELTA2 )
            ECART  = MAX( ECART  , ECART2 )
  20     CONTINUE
C
         CALL UTIMPR('L','AVEC UN PAS CONSTANT    ',0,DELTAT)
         CALL UTIMPR('L','  VALEUR DU DELTA_T     ',1,DELTAT)
         CALL UTIMPR('L','  ECART SUR LE DELTA_T  ',1,ECART )
         CALL UTFINM()
         CALL FOC2SO ( NBFREQ, FREQ, NBAMOR, AMOR, NBINST, DELTAT,
     +                               ZR(LFON), ZR(LSPECT) )
         GOTO 24
C
  22     CONTINUE
         CALL UTIMPR('L','AVEC UN PAS NON CONSTANT',0,TOLE)
         CALL UTFINM()
         CALL FOC3SO ( NBFREQ, FREQ, NBAMOR, AMOR, NBINST, ZR(LVAR),
     +                               ZR(LFON), ZR(LSPECT) )
      ENDIF
  24  CONTINUE
C
C     --- CREATION DES TABLEAUX DES VALEURS DE FONCTION DE LA NAPPE ---
      PROL( 1:19) = SPECTR
      PROL(20:24) = '.PROL'
      CALL WKVECT(PROL,BASE//' V K8',6+2*NBAMOR,LPROL)
      ZK8(LPROL)   = 'NAPPE   '
      ZK8(LPROL+1) = 'LIN LOG '
      ZK8(LPROL+2) = 'AMOR    '
      ZK8(LPROL+3) = NATURE(1:4)
      ZK8(LPROL+4) = 'EE      '
      ZK8(LPROL+5) = 'FREQ    '
C
      VALE( 1:19) = SPECTR
      VALE(20:24) = '.VALE'
      CALL JECREC(VALE,BASE//' V R','NU','CONTIG','VARIABLE',NBAMOR)
      CALL JEECRA(VALE,'LONT',NBAMOR*2*NBFREQ,' ')
      IF (NATURE(1:4).EQ.'DEPL') THEN
         IDEB = 0
      ELSEIF (NATURE(1:4).EQ.'VITE') THEN
         IDEB = NBAMOR*NBFREQ
      ELSE
         IDEB = 2*NBAMOR*NBFREQ
      ENDIF
      DO 100 IAMOR =1,NBAMOR
C
         ZK8(LPROL+5+2*IAMOR-1) = 'LOG LOG '
         ZK8(LPROL+5+2*IAMOR  ) = 'EC      '
C
         CALL JECROC(JEXNUM(VALE,IAMOR))
         CALL JEECRA(JEXNUM(VALE,IAMOR),'LONMAX',2*NBFREQ,' ')
         CALL JEECRA(JEXNUM(VALE,IAMOR),'LONUTI',2*NBFREQ,' ')
         CALL JEVEUO(JEXNUM(VALE,IAMOR),'E',LVAR)
         LFON  = LVAR + NBFREQ
         LFONS = IDEB+LSPECT+(IAMOR-1)*NBFREQ
         DO 110 IFREQ=1,NBFREQ
            ZR(LVAR+IFREQ-1) = FREQ(IFREQ)
            ZR(LFON+IFREQ-1) = ZR(LFONS+IFREQ-1)/NORME
 110     CONTINUE
 100  CONTINUE
C
      PARA( 1:19) = SPECTR
      PARA(20:24) = '.PARA'
      CALL WKVECT(PARA,BASE//' V R',NBAMOR,LPARA)
      DO 120 IAMOR =1,NBAMOR
         ZR(LPARA+IAMOR-1) = AMOR(IAMOR)
 120  CONTINUE
      CALL JEDETR('&&FOCASO.SPECTRE_DEP')
C
      CALL JEDEMA()
      END
