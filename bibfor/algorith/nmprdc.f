      SUBROUTINE NMPRDC(METHOD,NUMEDD,DEPMOI,SDDISC,NUMINS,
     &                  INCEST,DEPEST)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 12/02/2013   AUTEUR SELLENET N.SELLENET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2013  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE MABBAS M.ABBAS
C
      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      CHARACTER*16 METHOD(*)
      CHARACTER*19 DEPMOI,DEPEST
      CHARACTER*24 NUMEDD
      CHARACTER*19 SDDISC,INCEST
      INTEGER      NUMINS
C
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (ALGORITHME - PREDICTION)
C
C PREDICTION PAR DEPLACEMENT CALCULE
C
C ----------------------------------------------------------------------
C
C
C IN  METHOD : INFORMATIONS SUR LES METHODES DE RESOLUTION
C IN  NUMEDD : NUME_DDL
C IN  NUMINS : NUMERO INSTANT COURANT
C IN  SDDISC : SD DISC_INST
C IN  DEPMOI : DEPL. EN T-
C OUT INCEST : INCREMENT DE DEPLACEMENT EN PREDICTION
C OUT DEPEST : DEPLACEMENT ESTIME
C
C
C
C
      INTEGER      IFM,NIV
      INTEGER      JDEPES,JDEPM,JINCES,NEQ
      INTEGER      IRET,IBID
      REAL*8       DIINST,INSTAN
      CHARACTER*8  K8BID
      CHARACTER*19 DEPLU
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFDBG('MECA_NON_LINE',IFM,NIV)
C
C --- AFFICHAGE
C
      IF (NIV.GE.2) THEN
        WRITE (IFM,*) '<MECANONLINE> ... PAR DEPL. CALCULE'
      ENDIF
C
C --- INITIALISATIONS
C
      CALL DISMOI('F','NB_EQUA',NUMEDD,'NUME_DDL',NEQ   ,K8BID,IRET)
      INSTAN    = DIINST(SDDISC,NUMINS  )
C
C --- INITIALISATIONS
C
      DEPLU     = '&&NMPRDC.DEPEST'
C
C --- LECTURE DANS LE CONCEPT EVOL_NOLI
C
      CALL RSINCH(METHOD(6)(1:8),'DEPL','INST',INSTAN,DEPLU ,
     &            'EXCLU', 'EXCLU',0,'V',IRET)
      IF (IRET.GT.0) THEN
        CALL U2MESG('F','MECANONLINE2_27',1,METHOD(6)(1:8),1,IBID  ,
     &                                                     1,INSTAN)
      ENDIF
C
C --- COPIE DU DEPLACEMENT ESTIME
C
      IF (NUMINS.EQ.1) THEN
        CALL VTCOPY(DEPLU ,DEPEST,'F',IRET)      
      ELSE
        CALL COPISD('CHAMP_GD','V',DEPLU ,DEPEST)
      ENDIF
C      
      CALL JEVEUO(DEPEST(1:19)//'.VALE','L',JDEPES)
      CALL JEVEUO(DEPMOI(1:19)//'.VALE','L',JDEPM )
C
C --- INITIALISATION DE L'INCREMENT: INCEST = DEPEST - DEPMOI
C
      CALL JEVEUO(INCEST(1:19)// '.VALE','E',JINCES)
      CALL DCOPY (NEQ,ZR(JDEPES),1,ZR(JINCES),1)
      CALL DAXPY (NEQ,-1.D0,ZR(JDEPM),1,ZR(JINCES),1)
C
      CALL JEDEMA()
      END
