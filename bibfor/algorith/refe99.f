      SUBROUTINE  REFE99 (NOMRES)
      IMPLICIT NONE
      CHARACTER*8  NOMRES
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 18/10/2010   AUTEUR NISTOR I.NISTOR 
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
C
C     BUT:
C       RECUPERER LES NOMS UTILISATEUR DES CONCEPTS ASSOCIES AUX
C       MATRICES ASSEMBLEES CONSIDEREES - EFFECTUER QUELQUES CONTROLES
C       CREER LE .REFD
C
C
C     ARGUMENTS:
C     ----------
C
C      ENTREE :
C-------------
C IN   NOMRES   : NOM DE LA SD_RESULTAT
C
C ......................................................................
C
C-------- DEBUT COMMUNS NORMALISES  JEVEUX  ----------------------------
C
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
C
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------
C
      CHARACTER*6 NOMPRO
      PARAMETER (NOMPRO='REFE99')

      INTEGER      I,IOC1,IOC3,IOC4,IOC5,IOCI,IRET,IBID
      INTEGER      LDREF,LLRES,LTMOME,NBG,NBMOME
C
      CHARACTER*8  K8BID,RESUL
      CHARACTER*8  MECA
      CHARACTER*19 NUMDDL,NUMBIS
      CHARACTER*24 RAID,MASS,INTF,AMOR
      CHARACTER*24 VALK(4)
C
      LOGICAL      NOSEUL
C
C-----------------------------------------------------------------------
C
      CALL JEMARQ()
      NUMDDL = ' '
      RAID = ' '
      MASS = ' '
      AMOR = ' '
C
C --- DETERMINATION DU TYPE DE BASE
C
      CALL GETFAC('CLASSIQUE',IOC1)
      CALL GETFAC('RITZ',IOC3)
      CALL GETFAC('DIAG_MASS',IOC4)
      CALL GETFAC('ORTHO_BASE',IOC5)
C
C --- CAS CLASSIQUE
C
      IF(IOC1.GT.0) THEN
        NUMBIS =' '
        CALL GETVID('CLASSIQUE','INTERF_DYNA',1,1,1,INTF,IBID)
        CALL DISMOI('F','NOM_NUME_DDL',INTF,'INTERF_DYNA',
     &              IBID,NUMDDL,IRET)
C        NUMDDL(15:19)='.NUME'
        CALL GETVID('CLASSIQUE','MODE_MECA',1,1,0,K8BID,NBMOME)
        NBMOME = -NBMOME
        CALL WKVECT('&&'//NOMPRO//'.MODE_MECA','V V K8',NBMOME,LTMOME)
        CALL GETVID('CLASSIQUE','MODE_MECA',1,1,NBMOME,ZK8(LTMOME),IBID)
        DO 10 I=1,NBMOME
          CALL JEVEUO(ZK8(LTMOME-1+I)//'           .REFD','L',LLRES)
          RAID=ZK24(LLRES)
          MASS=ZK24(LLRES+1)
          AMOR=ZK24(LLRES+2)
          CALL DISMOI('F','NOM_NUME_DDL',RAID,'MATR_ASSE',IBID,
     &                 NUMBIS,IRET)
C          NUMBIS(15:19)='.NUME'
          IF(NUMBIS(1:14).NE.NUMDDL(1:14)) THEN
            RESUL = ZK8(LTMOME-1+I)
            VALK (1) = RESUL
            VALK (2) = NUMBIS(1:8)
            VALK (3) = INTF
            VALK (4) = NUMDDL(1:8)
            CALL U2MESG('F', 'ALGORITH14_24',4,VALK,0,0,0,0.D0)
          ENDIF
10      CONTINUE
        CALL JEDETR('&&'//NOMPRO//'.MODE_MECA')

      ENDIF
C
C --- CAS RITZ
C
      IF(IOC3.GT.0) THEN
        NOSEUL=.FALSE.
        CALL GETVID('RITZ','MODE_MECA',1,1,999,K8BID,NBG)
        CALL GETVID('RITZ','MODE_INTF',2,1,0,K8BID,IBID)
        IF ((IBID.GT.0).OR.(NBG.GT.1)) THEN 
          NOSEUL=.TRUE.
        ENDIF
        CALL GETVID('    ','NUME_REF',1,1,1,NUMDDL,IBID)
        IF ((IBID.EQ.0).AND.NOSEUL) THEN
C         si on a plus d'un mode_meca en entree, preciser NUME_REF
          CALL U2MESG('E', 'ALGORITH17_8',0,' ',0,0,0,0.D0)
        ENDIF
C        NUMDDL(15:19)='.NUME'
        CALL GETVID('  ','INTERF_DYNA',1,1,0,INTF,IOCI)
        IF(IOCI.LT.0) THEN
          CALL GETVID('  ','INTERF_DYNA',1,1,1,INTF,IOCI)
        ELSE
          INTF=' '
        ENDIF
      ENDIF
C
C --- DIAGONALISATION DE LA MATRICE DE MASSE 
C
      IF (IOC4.GT.0) THEN
        INTF = ' '
C - RECUPERATION DE LA MASSE
        CALL GETVID('DIAG_MASS','MODE_MECA',1,1,1,MECA,IBID)
        CALL JEVEUO(MECA//'           .REFD','L',LLRES)
        RAID = ZK24(LLRES)
        MASS = ZK24(LLRES+1)
        AMOR = ZK24(LLRES+2)

        CALL DISMOI('F','NOM_NUME_DDL',MASS,'MATR_ASSE',IBID,
     &                 NUMDDL,IRET)
      ENDIF
C
C --- CAS ORTHO_BASE
C
      IF(IOC5.GT.0) THEN
        INTF = ' '
        CALL GETVID('ORTHO_BASE','BASE',1,1,1,MECA,IBID)
        CALL JEVEUO(MECA//'           .REFD','L',LLRES)
        RAID = ZK24(LLRES)
        MASS = ZK24(LLRES+1)
        AMOR = ZK24(LLRES+2)
        CALL DISMOI('F','NOM_NUME_DDL',MASS,'MATR_ASSE',IBID,
     &                 NUMDDL,IRET)
      ENDIF
C
C --- CREATION DU .REFD
C
      CALL JEEXIN(NOMRES//'           .REFD',IRET)
      IF (IRET.EQ.0) THEN 
         CALL WKVECT(NOMRES//'           .REFD','G V K24',7,LDREF)
         ZK24(LDREF) = RAID
         ZK24(LDREF+1) = MASS
         ZK24(LDREF+2) = AMOR
         ZK24(LDREF+3) = NUMDDL(1:14)
         ZK24(LDREF+4)   = INTF
         ZK24(LDREF+5) = '  '
         IF (IOC1.GT.0) THEN
           ZK24(LDREF+6) = 'CLASSIQUE'
         ELSEIF (IOC3.GT.0)  THEN
           ZK24(LDREF+6) = 'RITZ'
         ELSEIF (IOC4.GT.0)  THEN
           ZK24(LDREF+6) = 'DIAG_MASS'
         ELSEIF (IOC5.GT.0)  THEN
           ZK24(LDREF+6) = 'ORTHO_BASE'
         ENDIF
      ENDIF
C
      CALL JEDEMA()
C
      END
