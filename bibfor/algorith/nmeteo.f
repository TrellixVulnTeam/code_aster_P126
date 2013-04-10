      SUBROUTINE NMETEO(RESULT,SDIMPR,SDDISC,SDIETO,FORCE ,
     &                  NUMARC,INSTAN,ICHAM )
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 09/04/2013   AUTEUR ABBAS M.ABBAS 
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
      CHARACTER*24 SDIETO,SDIMPR
      CHARACTER*19 SDDISC
      CHARACTER*8  RESULT
      INTEGER      ICHAM
      INTEGER      NUMARC
      REAL*8       INSTAN
      LOGICAL      FORCE
C
C ----------------------------------------------------------------------
C
C ROUTINE GESTION IN ET OUT
C
C ECRITURE D'UN CHAMP DANS LA SD RESULAT
C
C ----------------------------------------------------------------------
C
C
C IN  RESULT : NOM SD EVOL_NOLI
C IN  SDDISC : SD DISCRETISATION TEMPORELLE
C IN  SDIMPR : SD AFFICHAGE
C IN  SDIETO : SD GESTION IN ET OUT
C IN  FORCE  : VRAI SI ON SOUHAITE FORCER L'ARCHIVAGE DE TOUS LES CHAMPS
C IN  INSTAN : INSTANT D'ARCHIVAGE
C IN  NUMARC : NUMERO D'ARCHIVAGE
C IN  ICHAM  : INDEX DU CHAMP DANS SDIETO
C
C ----------------------------------------------------------------------
C
      CHARACTER*24 IOINFO,IOLCHA
      INTEGER      JIOINF,JIOLCH
      INTEGER      ZIOCH
      CHARACTER*24 NOMCHA,NOMCHS,CHARCH
      LOGICAL      DIINCL,LPRINT
      INTEGER      IRET
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- ACCES SD IN ET OUT
C
      IOINFO = SDIETO(1:19)//'.INFO'
      IOLCHA = SDIETO(1:19)//'.LCHA'
      CALL JEVEUO(IOINFO,'L',JIOINF)
      CALL JEVEUO(IOLCHA,'E',JIOLCH)
      ZIOCH  = ZI(JIOINF+4-1)
C
C --- CHAMP A ARCHIVER ?
C
      CHARCH = ZK24(JIOLCH+ZIOCH*(ICHAM-1)+9-1)
      IF (CHARCH.EQ.'NON') GOTO 999
C
C --- AFFICHAGE POUR CE PAS ?
C
      LPRINT = .TRUE.
      IF (SDIMPR.NE.' ') CALL OBGETB(SDIMPR,'PRINT',LPRINT)
C
C --- NOM DU CHAMP DANS SD RESULTAT
C
      NOMCHS = ZK24(JIOLCH+ZIOCH*(ICHAM-1)+1-1)
C
C --- NOM DU CHAMP DANS L'OPERATEUR
C
      CALL NMETNC(SDIETO,ICHAM ,NOMCHA)
      CALL EXISD('CHAMP',NOMCHA,IRET)
C
C --- ARCHIVAGE DU CHAMP
C
      IF (DIINCL(SDDISC,NOMCHS,FORCE ).AND.
     &    (IRET.EQ.1)) THEN
        IF (LPRINT) THEN
          CALL U2MESG('I','ARCHIVAGE_6',1,NOMCHS,1,NUMARC,1,INSTAN)
        ENDIF
        CALL NMARCC(RESULT,NUMARC,NOMCHS,NOMCHA)
      ENDIF
C
 999  CONTINUE
C
      CALL JEDEMA()
      END
