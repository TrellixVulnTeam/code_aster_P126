      SUBROUTINE RSEXCH(NOMSD,NOMSY,IORDR,CHEXTR,ICODE)
      IMPLICIT REAL*8 (A-H,O-Z)
      INTEGER IORDR,ICODE
      CHARACTER*(*) NOMSD,NOMSY,CHEXTR
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 03/10/2000   AUTEUR VABHHTS J.PELLET 
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
C RESPONSABLE VABHHTS J.PELLET
C      RECUPERATION DU NOM DU CHAMP-GD  CORRESPONDANT A:
C          NOMSD(IORDR,NOMSY).
C ----------------------------------------------------------------------
C IN  : NOMSD  : NOM DE LA STRUCTURE "RESULTAT"
C IN  : NOMSY  : NOM SYMBOLIQUE DU CHAMP A CHERCHER.
C IN  : IORDR  : NUMERO D'ORDRE DU CHAMP A CHERCHER.
C OUT : CHEXTR : NOM DU CHAMP EXTRAIT.
C OUT : ICODE  : CODE RETOUR    0 : LE CHAMP EXISTE.
C                              >0 : LE CHAMP N'EXISTE PAS.
C            ---> 1) IORDR EST INFERIEUR AU MAX AUTORISE:
C                    100 : LE NOM SYMBOLIQUE EST LICITE.
C                    101 : LE NOM SYMBOLIQUE EST INTERDIT.
C            ---> 2) IORDR EST SUPERIEUR AU MAX AUTORISE:
C                 => IL FAUT AGRANDIR NOMSD AVANT DE STOCKER IORDR
C                    110 : LE NOM SYMBOLIQUE EST LICITE.
C                    111 : LE NOM SYMBOLIQUE EST INTERDIT.
C ----------------------------------------------------------------------
C --------------- COMMUNS NORMALISES  JEVEUX  --------------------------
      CHARACTER*32 JEXNUM,JEXNOM,JEXATR,JEXR8
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C ---------------- FIN COMMUNS NORMALISES  JEVEUX  --------------------
      CHARACTER*2 NUCH
      CHARACTER*4 TYPE,TYSCA
      CHARACTER*6 CHFORD
      CHARACTER*8 NOMOBJ,K8BID,K8DEBU,K8MAXI,K8ENT
      CHARACTER*16 TYSD,NOMS2
      CHARACTER*19 NOMD2,CHEXT2
      CHARACTER*1 K1BID
C ----------------------------------------------------------------------
      CALL JEMARQ()
      ICODE = 0
      NOMS2 = NOMSY
      NOMD2 = NOMSD
      CHEXTR = '???'


C     --- RECUPERATION DU NUMERO DE RANGEMENT ---
      CALL RSUTRG(NOMSD,IORDR,IRANG)
      CALL JENONU(JEXNOM(NOMD2//'.DESC',NOMS2),IRETOU)


C     -- LE NUMERO DE RANGEMENT EXISTE :
C     -----------------------------------------
      IF (IRANG.GT.0) THEN

C        --- LE NOM SYMBOLIQUE N'EXISTE PAS ---
        IF (IRETOU.EQ.0) THEN
          ICODE = 101
          GO TO 10
        END IF

        CALL JENONU(JEXNOM(NOMD2//'.DESC',NOMS2),IBID)
        CALL JEVEUO(JEXNUM(NOMD2//'.TACH',IBID),'E',IATACH)
        CHEXT2 = ZK24(IATACH+IRANG-1)
        IF (CHEXT2.EQ.' ') THEN
          CALL RSUTCH(NOMSD,NOMS2,IORDR,CHEXT2,IRET)
          ICODE = IRET
          CALL EXISD('CHAMP_GD',CHEXT2,IRET)
          IF (IRET.EQ.0) ICODE = ICODE + 100
        END IF


C     --- LE NUMERO DE RANGEMENT N'EXISTE PAS :
C     -----------------------------------------
      ELSE
        CALL JELIRA(NOMD2//'.ORDR','LONMAX',NBORDR,K1BID)
        CALL JELIRA(NOMD2//'.ORDR','LONUTI',NRANG,K1BID)
        NRANG = NRANG + 1
        IF (NRANG.GT.NBORDR) THEN
          ICODE = 110
          IF (IRETOU.EQ.0) ICODE = 111
          GO TO 10
        END IF
        CALL JEECRA(NOMD2//'.ORDR','LONUTI',NRANG,' ')
        CALL JEVEUO(NOMD2//'.ORDR','E',JORDR)
        ZI(JORDR-1+NRANG) = IORDR
        CALL RSUTCH(NOMSD,NOMS2,IORDR,CHEXT2,IRET)
        ICODE = IRET
        CALL EXISD('CHAMP_GD',CHEXT2,IRET)
        IF (IRET.EQ.0) ICODE = ICODE + 100
      END IF
      CHEXTR = CHEXT2

   10 CONTINUE
      CALL JEDEMA()
      END
