      SUBROUTINE ARGU80(NOMRES)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 09/09/98   AUTEUR SABJLMA P.LATRUBESSE 
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
      IMPLICIT REAL*8 (A-H,O-Z)
C
C***********************************************************************
C    P. RICHARD     DATE 28/03/91
C-----------------------------------------------------------------------
C  BUT : RECUPERER LES ARGUMENTS D'APPEL (SAUF LES DIAMETRES ET LE
C        NOMBRE DE MODES A CALCULER) ET CREATION DES OBJETS
C        CORRESPONDANTS
C        VERIFICATION DES PROPRIETES DE REPETITIVITE SUR LE MAILLAGE
C-----------------------------------------------------------------------
C
C NOMRES   /I/: NOM UTILISATEUR DU CONCEPT RESULTAT
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
      CHARACTER*32 JEXNOM
C
C----------  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
C
      CHARACTER*6      PGC
      CHARACTER*8 DROITE,GAUCHE,AXE,TYPD,TYPG,TYPA
      CHARACTER*8 NOMRES,BASMOD,INTF
      CHARACTER*8 BLANC,VERIF
      CHARACTER*72 KAR72
C
C-----------------------------------------------------------------------
      DATA PGC /'ARGU80'/
      DATA BLANC /'  '/
C-----------------------------------------------------------------------
C
C
C-------------CREATION DES OBJETS DE LA SDD RESULTAT--------------------
C
      CALL JEMARQ()
      CALL WKVECT(NOMRES//'      .CYCL.NUIN','G V I',3,LDDNIN)
      CALL WKVECT(NOMRES//'      .CYCL.TYPE','G V K8',1,LDDTYP)
      CALL WKVECT(NOMRES//'      .CYCL.NBSC','G V I',1,LDDNBS)
C
C--------------------RECUPERATION DES CONCEPTS AMONTS-------------------
C
      CALL JEVEUO(NOMRES//'      .CYCL.REFE','L',LLREF)
      INTF=ZK24(LLREF+1)
C
C----------RECUPERATION NOM DES INTERFACES DE LIAISON-------------------
C
      CALL GETVTX('LIAISON','DROITE',1,1,1,KAR72,IBID)
      DROITE=KAR72
      CALL GETVTX('LIAISON','GAUCHE',1,1,1,KAR72,IBID)
      GAUCHE=KAR72
      CALL GETVTX('LIAISON','AXE',1,1,0,KAR72,IBAXE)
      IF(IBAXE.EQ.-1) THEN
        CALL GETVTX('LIAISON','AXE',1,1,1,KAR72,IBID)
        AXE=KAR72
      ELSE
        AXE='            '
      ENDIF
C
C   RECUPERATION DES NUMEROS D'INTERFACE
C
C   INTERFACE DE DROITE OBLIGATOIRE
C
      CALL JENONU(JEXNOM(INTF//'      .INTD.NOMS',DROITE),NUMD)
      IF(NUMD.EQ.0) THEN
          CALL UTDEBM('F',PGC,
     &' L''INTERFACE DE DROITE  N EXISTE PAS')
          CALL UTIMPK('L','INTERFACE DE NOM',1,DROITE)
          CALL UTFINM
      ENDIF
C
C   INTERFACE DE GAUCHE OBLIGATOIRE
C
      CALL JENONU(JEXNOM(INTF//'      .INTD.NOMS',GAUCHE),NUMG)
      IF(NUMG.EQ.0) THEN
        CALL UTDEBM('F',PGC,
     &' L''INTERFACE DE GAUCHE  N EXISTE PAS')
        CALL UTIMPK('L','INTERFACE DE NOM',1,GAUCHE)
        CALL UTFINM
      ENDIF
C
C   INTERFACE AXE FACULTATIVE
C
      IF(AXE.NE.'        ') THEN
        CALL JENONU(JEXNOM(INTF//'      .INTD.NOMS',AXE),NUMA)
        IF(NUMA.EQ.0) THEN
        CALL UTDEBM('F',PGC,
     &' L''INTERFACE AXE  N EXISTE PAS')
        CALL UTIMPK('L','INTERFACE DE NOM',1,AXE)
        CALL UTFINM
        ENDIF
      ELSE
        NUMA=0
      ENDIF
C
      ZI(LDDNIN)=NUMD
      ZI(LDDNIN+1)=NUMG
      ZI(LDDNIN+2)=NUMA
C
C   RECUPERATION DES TYPES DES INTERFACES
C
      CALL JEVEUO(INTF//'      .INTD.TYPE','L',LDDTBM)
      TYPD=ZK8(LDDTBM+NUMD-1)
      TYPG=ZK8(LDDTBM+NUMG-1)
      IF(NUMA.GT.0) THEN
        TYPA=ZK8(LDDTBM+NUMA-1)
      ELSE
        TYPA=TYPD
      ENDIF
C
C  VERIFICATIONS SUR LES TYPES INTERFACES
C
      IF(TYPG.NE.TYPD.OR.TYPA.NE.TYPD) THEN
        CALL UTDEBM('F',PGC,
     &'ARRET SUR PROBLEME INTERFACES DE TYPE DIFFERENTS')
        CALL UTFINM
      ENDIF
C
      IF(TYPD.NE.'MNEAL   '.AND.TYPD.NE.'CRAIGB  ') THEN
        IF(TYPD.NE.'AUCUN   '.AND.TYPD.NE.'CB_HARMO') THEN
          CALL UTDEBM('F',PGC,
     &'ARRET SUR PROBLEME DE TYPE INTERFACE NON SUPPORTE')
          CALL UTIMPK('L','TYPE INTERFACE --> ',1,TYPD)
          CALL UTFINM
        ENDIF
      ENDIF
C
C STOCKAGE TYPE INTERFACE
C
      ZK8(LDDTYP)= TYPD
C
C  RECUPERATION DU NOMBRE DE SECTEURS
C
      CALL GETVIS(BLANC,'NB_SECTEUR',1,1,1,NBSEC,IBID)
      IF(NBSEC.LT.2) THEN
        CALL UTDEBM('F',PGC,
     &'ARRET SUR NOMBRE DE SECTEURS IMPOSSIBLE')
        CALL UTIMPI('L',' NOMBRE DE SECTEURS --> ',1,NBSEC)
      ENDIF
C
      ZI(LDDNBS)=NBSEC
C
C---------------VERIFICATION DE LA REPETITIVITE SUR MAILLAGE------------
C
      CALL GETFAC('VERI_CYCL',NVERI)
      CALL GETVR8('VERI_CYCL','PRECISION',1,1,1,PREC,IBID)
      CALL GETVR8('VERI_CYCL','DIST_REFE',1,1,1,DIST,NDIST)
      IF (NVERI.EQ.0) PREC=1.D-3
      IF (NDIST.EQ.0) THEN
C     --- AU CAS OU LA DISTANCE DE REFERENCE N'EST PAS DONNEE,ON DEVRAIT
C         LA LIRE DANS LA SD MAILLAGE (VOIR COMMANDE LIRE_MAILLAGE).
C         CE TRAVAIL N'ETANT PAS ACCOMPLI, ON MET DIST < 0 AFIN DE 
C         SIGNIFIER A VERECY DE TRAVAILLER COMME AVANT
         DIST = -1.D0
      ENDIF
      CALL VERECY(INTF,NUMD,NUMG,NUMA,NBSEC,PREC,DIST)
C
 9999 CONTINUE
      CALL JEDEMA()
      END
