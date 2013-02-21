      SUBROUTINE NMETL1(RESULT,NUMEIN,SDIETO,ICHAM )
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
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C RESPONSABLE ABBAS M.ABBAS
C
      IMPLICIT     NONE
      INCLUDE 'jeveux.h'
      CHARACTER*24 SDIETO
      CHARACTER*8  RESULT
      INTEGER      ICHAM,NUMEIN
C
C ----------------------------------------------------------------------
C
C ROUTINE GESTION IN ET OUT
C
C LECTURE D'UN CHAMP - CAS DE LA SD RESULTAT DANS ETAT_INIT
C
C ----------------------------------------------------------------------
C
C
C IN  RESULT : NOM SD RESULTAT
C IN  SDIETO : SD GESTION IN ET OUT
C IN  NUMEIN : NUMERO ORDRE INSTANT INITIAL
C IN  ICHAM  : INDEX DU CHAMP DANS SDIETO
C
C
C
C
      CHARACTER*24 IOINFO,IOLCHA
      INTEGER      JIOINF,JIOLCH
      INTEGER      ZIOCH
      CHARACTER*24 CHAMP
      INTEGER      IEVOL,IRET
      CHARACTER*24 CHETIN,NOMCHS
      CHARACTER*24 NOMCHA,NOMCH0,LOCCHA
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- INITIALISATION
C
      CHAMP  = '&&NMETL1.CHAMP'
C
C --- ACCES AUX SDS
C
      IOINFO = SDIETO(1:19)//'.INFO'
      IOLCHA = SDIETO(1:19)//'.LCHA'
      CALL JEVEUO(IOINFO,'L',JIOINF)
      CALL JEVEUO(IOLCHA,'E',JIOLCH)
      ZIOCH  = ZI(JIOINF+4-1)
C
C --- CHAMP A LIRE ?
C
      CHETIN = ZK24(JIOLCH+ZIOCH*(ICHAM-1)+8-1)
      IF (CHETIN.EQ.'NON') GOTO 999
C
C --- NOM DU CHAMP DANS SD RESULTAT
C
      NOMCHS = ZK24(JIOLCH+ZIOCH*(ICHAM-1)+1-1)
C
C --- NOM DU CHAMP NUL
C
      NOMCH0 = ZK24(JIOLCH+ZIOCH*(ICHAM-1)+2-1)
C
C --- LOCALISATION DU CHAMP
C
      LOCCHA = ZK24(JIOLCH+ZIOCH*(ICHAM-1)+5-1)
C
C --- NOM DU CHAMP DANS L'OPERATEUR
C
      CALL NMETNC(SDIETO,ICHAM ,NOMCHA)
C
C --- RECUP DANS LA SD RESULTAT
C
      CALL RSEXCH(' ',RESULT,NOMCHS,NUMEIN,CHAMP ,IEVOL )
C
C --- TRAITEMENT DU CHAMP
C
      IF (IEVOL.NE.0) THEN
        IF (NOMCH0.NE.' ') THEN
          CALL COPISD('CHAMP','V',NOMCH0,NOMCHA)
          ZK24(JIOLCH+ZIOCH*(ICHAM-1)+4-1) = 'ZERO'
        ENDIF
      ELSE
C
C ----- RECOPIE DU CHAMP EN LOCAL
C
        IF (LOCCHA.EQ.'NOEU') THEN
          CALL VTCOPY(CHAMP ,NOMCHA,'F',IRET)
        ELSEIF ((LOCCHA.EQ.'ELGA').OR.
     &          (LOCCHA.EQ.'ELNO').OR.
     &          (LOCCHA.EQ.'ELEM')) THEN
          CALL COPISD('CHAMP_GD','V',CHAMP ,NOMCHA)
        ELSE
          WRITE(6,*) 'LOCCHA: ',LOCCHA
          CALL ASSERT(.FALSE.)
        ENDIF
C
C ----- STATUT DU CHAMP: LU DANS SD RESULTAT
C
        ZK24(JIOLCH+ZIOCH*(ICHAM-1)+4-1) = 'SDRESU'
      ENDIF
C
 999  CONTINUE
C
      CALL JEDEMA()
      END
