      SUBROUTINE RECYEC(NMRESZ,MDCYCZ,NUMSEC,TYPSDZ)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 07/01/98   AUTEUR CIBHHLB L.BOURHRARA 
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
C***********************************************************************
C    P. RICHARD     DATE 16/04/91
C-----------------------------------------------------------------------
C  BUT:      < RESTITUTION CYCLIQUE ECLATEE >
      IMPLICIT REAL*8 (A-H,O-Z)
C
C      RESTITUER EN BASE PHYSIQUE SUR UN SECTEUR LES RESULTATS
C                ISSU DE LA SOUS-STRUCTURATION CYCLIQUE
C  LE CONCEPT RESULTAT EST UN RESULTAT COMPOSE "MODE_MECA"
C
C-----------------------------------------------------------------------
C
C NMRESZ   /I/: NOM K8 DU CONCEPT MODE MECA RESULTAT
C MDCYCZ   /I/: NOM K8 MODE_CYCL AMONT
C NUMSEC   /I/: NUMERO DU SECTEUR SUR LEQUEL RESTITUER
C TYPSDZ   /I/: TYPE STRUCTURE DONNEE RESULTAT (MODE_MECA,BASE_MODALE)
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
C----------  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
C
      CHARACTER*8 NOMRES,MODCYC,BASMOD,TYPINT
      CHARACTER*(*) NMRESZ,MDCYCZ,TYPSDZ
      CHARACTER*16 TYPSD
C
C-----------------------------------------------------------------------
C-----------------------------------------------------------------------
C
C-----------------ECRITURE DU TITRE-------------------------------------
C
      CALL JEMARQ()
      NOMRES = NMRESZ
      MODCYC = MDCYCZ
      TYPSD  = TYPSDZ
C
      CALL TITRE
C
C-------------------RECUPERATION DE LA BASE MODALE----------------------
C
      CALL JEVEUO(MODCYC//'      .CYCL.REFE','L',LLREF)
      BASMOD=ZK24(LLREF+2)
C
C-----------------------RECUPERATION DU TYPE INTERFACE------------------
C
C
      CALL JEVEUO(MODCYC//'      .CYCL.TYPE','L',LLTYP)
      TYPINT=ZK8(LLTYP)
C
C
C------------------------------RESTITUTION -----------------------------
C
C    CAS CRAIG-BAMPTON ET CRAIG-BAMPTON HARMONIQUE
C
      IF(TYPINT.EQ.'CRAIGB  '.OR.TYPINT.EQ.'CB_HARMO') THEN
        CALL RECBEC(NOMRES,TYPSD,BASMOD,MODCYC,NUMSEC)
      ENDIF
C
C
C    CAS MAC NEAL AVEC ET SANS CORRECTION
C
      IF(TYPINT.EQ.'MNEAL   '.OR.TYPINT.EQ.'AUCUN   ') THEN
        CALL REMNEC(NOMRES,TYPSD,BASMOD,MODCYC,NUMSEC)
      ENDIF
C
C
 9999 CONTINUE
      CALL JEDEMA()
      END
