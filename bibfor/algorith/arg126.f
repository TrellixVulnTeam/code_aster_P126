      SUBROUTINE  ARG126 (NOMRES)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 14/01/98   AUTEUR VABHHTS J.PELLET 
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
      IMPLICIT REAL*8 (A-H,O-Z)
C  P. RICHARD     DATE 13/10/93
C-----------------------------------------------------------------------
C  BUT:      < RECUPERATION DES ARGUMENTS POUR OP0126 >
C
C  RECUPERER LES ARGUMENTS UTILISATEUR POUR LA DEFINITION DU MODELE
C  GENERALISE. DEFINITION DES SOUS-STRUCTURES ET DES LIAISONS ENTRE
C  LES SOUS-STRUCTURES.
C
C-----------------------------------------------------------------------
C
C NOMRES   /I/: NOM UTILISATEUR DU RESULTAT
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
      CHARACTER*32  JEXNOM,JEXNUM
C
C----------  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
C
      CHARACTER*6  PGC
      CHARACTER*8  NOMRES,LINTF,TT,SST1,SST2,NOMSST,MCLCOU,NOMCOU,NOMTMP
      CHARACTER*16 CLESST,CLENOM,CLEROT,CLEMCL,CLETRA,CLELIA,CLEL(4)
      CHARACTER*24 REPSST,NOMMCL,ROTSST,FAMLI,TRASST,DEFLIA
      LOGICAL      CONOK
      REAL*8       RBID
      CHARACTER*8  KBID
C
C-----------------------------------------------------------------------
      DATA PGC,TT        /'ARG126','&&ARG126'/
      DATA CLESST,CLENOM /'SOUS_STRUC','NOM'/
      DATA CLEROT,CLEMCL /'ANGL_NAUT','MACR_ELEM_DYNA'/
      DATA CLELIA,CLETRA /'LIAISON','TRANS'/
      DATA CLEL          /'SOUS_STRUC_1','SOUS_STRUC_2','INTERFACE_1',
     &                    'INTERFACE_2'/
C-----------------------------------------------------------------------
C
      CALL JEMARQ()
      PI=4.D+00*ATAN(1.D+00)
C
C-----TRAITEMENT DEFINITION SOUS-STRUCTURES-----------------------------
C
      CALL GETFAC(CLESST,NBSST)
C
      IF(NBSST.LT.2) THEN
        CALL UTDEBM('F',PGC,'ARRET NOMBRE DE SOUS-STRUCTURE INVALIDE')
        CALL UTIMPI('L','IL EN FAUT AU MINIMUM:',1,2)
        CALL UTIMPI('L','VOUS EN AVEZ DEFINI:',1,NBSST)
        CALL UTFINM
      ENDIF
C
      REPSST=NOMRES//'      .MODG.SSNO'
      NOMMCL=NOMRES//'      .MODG.SSME'
      ROTSST=NOMRES//'      .MODG.SSOR'
      TRASST=NOMRES//'      .MODG.SSTR'
C
      CALL JECREO(REPSST,'G N K8')
      CALL JEECRA(REPSST,'NOMMAX',NBSST,' ')
      CALL JECREC(NOMMCL,'G V K8','NU','CONTIG','CONSTANT',
     &            NBSST)
      CALL JECREC(ROTSST,'G V R','NU','CONTIG','CONSTANT',
     &            NBSST)
      CALL JECREC(TRASST,'G V R','NU','CONTIG','CONSTANT',
     &            NBSST)
      CALL JEECRA(NOMMCL,'LONT',NBSST,' ')
      CALL JEECRA(ROTSST,'LONT',3*NBSST,' ')
      CALL JEECRA(TRASST,'LONT',3*NBSST,' ')
C
C  DETERMINATION DU CAS DE TRAITEMENT DES TRANSLATIONS
C
      ITRAN=0
      DO 5 I=1,NBSST
        CALL GETVR8(CLESST,'TRANS',I,1,1,RBID,IREP)
        IF (IREP.NE.0) ITRAN=1
5     CONTINUE
C
C-----BOUCLE SUR LES SOUS-STRUCTURES DEFINIES-------------------------
C
      DO 10 I=1,NBSST
        CALL GETVTX(CLESST,CLENOM,I,1,0,KBID,IOC)
        IOC=-IOC
        IF(IOC.NE.1) THEN
          CALL UTDEBM('F',PGC,
     &         'ARRET NOMBRE DE NOM DE SOUS-STRUCTURE INVALIDE')
          CALL UTIMPI('L','IL EN FAUT EXACTEMENT:',1,1)
          CALL UTIMPI('L','VOUS EN AVEZ DEFINI:',1,IOC)
          CALL UTFINM
        ELSE
          CALL GETVTX(CLESST,CLENOM,I,1,1,NOMSST,IBID)
        ENDIF
        CALL JECROC(JEXNOM(REPSST,NOMSST))
C
        CALL GETVID(CLESST,CLEMCL,I,1,0,KBID,IOC)
        IOC=-IOC
        IF(IOC.NE.1) THEN
          CALL UTDEBM('F',PGC,'NOMBRE DE MACR_ELEM INVALIDE')
          CALL UTIMPK('L','SOUS_STRUCTURE',1,NOMSST)
          CALL UTIMPI('L','VOUS EN AVEZ DEFINI:',1,IOC)
          CALL UTIMPI('L','IL EN FAUT EXACTEMENT:',1,1)
          CALL UTFINM
        ELSE
          CALL GETVID(CLESST,CLEMCL,I,1,1,MCLCOU,IBID)
        ENDIF
        CALL JENONU(JEXNOM(REPSST,NOMSST),IBID)
        CALL JEVEUO(JEXNUM(NOMMCL,IBID),'E',LDNMCL)
        ZK8(LDNMCL)=MCLCOU
C
C  TRAITEMENT DES ROTATIONS
C
        CALL JENONU(JEXNOM(REPSST,NOMSST),IBID)
        CALL JEVEUO(JEXNUM(ROTSST,IBID),'E',LDROT)
        CALL GETVR8(CLESST,CLEROT,I,1,0,BID,IOC)
        IOC=-IOC
        IF(IOC.EQ.0) THEN
          DO 30 J=1,3
            ZR(LDROT+J-1)=0.D+00
30        CONTINUE
        ELSEIF(IOC.EQ.3) THEN
          CALL GETVR8(CLESST,CLEROT,I,1,3,ZR(LDROT),IBID)
          DO 20 J=1,3
            ZR(LDROT+J-1)=ZR(LDROT+J-1)*PI/180.D+00
20        CONTINUE
        ELSE
          CALL UTDEBM('F',PGC,'NOMBRE D''ANGLES NAUTIQUES INVALIDE')
          CALL UTIMPK('L','SOUS_STRUCTURE',1,NOMSST)
          CALL UTIMPI('L','VOUS EN AVEZ DEFINI:',1,IOC)
          CALL UTIMPI('L','IL EN FAUT EXACTEMENT: ',1,3)
          CALL UTFINM
        ENDIF
C
C  TRAITEMENT DES TRANSLATIONS SI INTRODUIT PAR L'UTILISATEUR
C
        IF (ITRAN.EQ.1) THEN
          CALL JENONU(JEXNOM(REPSST,NOMSST),IBID)
          CALL JEVEUO(JEXNUM(TRASST,IBID),'E',LDTRA)
          CALL GETVR8(CLESST,CLETRA,I,1,0,BID,IOC)
          IOC=-IOC
          IF(IOC.EQ.0) THEN
            DO 40 J=1,3
              ZR(LDTRA+J-1)=0.D+00
40         CONTINUE
          ELSEIF(IOC.EQ.3) THEN
            CALL GETVR8(CLESST,CLETRA,I,1,3,ZR(LDTRA),IBID)
          ELSE
            CALL UTDEBM('F',PGC,'NOMBRE DE TRANSLATION INVALIDE')
            CALL UTIMPK('L','SOUS_STRUCTURE',1,NOMSST)
            CALL UTIMPI('L','VOUS EN AVEZ DEFINI:',1,IOC)
            CALL UTIMPI('L','IL EN FAUT EXACTEMENT: ',1,3)
            CALL UTFINM
          ENDIF
        ENDIF
C
10    CONTINUE
C
C-----RECUPERATION DU NOMBRE DE LIAISONS DEFINIES-----------------------
C
      CALL GETFAC(CLELIA,NBLIA)
      IF(NBLIA.EQ.0) THEN
        CALL UTDEBM('F',PGC,'NOMBRE DE LIAISON DEFINIES INVALIDE')
        CALL UTIMPI('L','VOUS EN AVEZ DEFINI:',1,NBLIA)
        CALL UTIMPI('L','IL EN FAUT AU MINIMUM:',1,1)
        CALL UTFINM
      ENDIF
C
      FAMLI=NOMRES//'      .MODG.LIDF'
      CALL JECREC(FAMLI,'G V K8','NU','DISPERSE','CONSTANT',NBLIA)
      CALL JEECRA(FAMLI,'LONMAX',4,' ')
C
C-----BOUCLE SUR LES LIAISONS------------------------------------------
C
      DO 140 I=1,NBLIA
        CALL JECROC(JEXNUM(FAMLI,I))
        CALL JEVEUO(JEXNUM(FAMLI,I),'E',LDLID)
C
C  BOUCLE SUR LES SOUS-STRUCTURES DE LA LIAISON
C
        DO 150 J=1,2
          CALL GETVTX(CLELIA,CLEL(J),I,1,0,KBID,IOC)
          IOC=-IOC
          IF(IOC.NE.1) THEN
            CALL UTDEBM('F',PGC,'NOMBRE DE MOT-CLE INVALIDE')
            CALL UTIMPI('L','NUMERO LIAISON:',1,I)
            CALL UTIMPK('L','MOT-CLE:',1,CLEL(J))
            CALL UTIMPI('L','VOUS EN AVEZ DEFINI:',1,IOC)
            CALL UTIMPI('L','IL EN FAUT EXACTEMENT:',1,1)
            CALL UTFINM
          ELSE
            CALL GETVTX(CLELIA,CLEL(J),I,1,1,NOMCOU,IBID)
C
C  VERIFICATION EXISTANCE DE LA SOUS-STRUCTURE
C
            CALL JENONU(JEXNOM(REPSST,NOMCOU),IRET)
            IF(IRET.EQ.0) THEN
              CALL UTDEBM('F',PGC,'SOUS-STRUCTURE INDEFINIE')
              CALL UTIMPI('L','NUMERO LIAISON:',1,I)
              CALL UTIMPK('L','NOM SOUS-STRUCTURE:',1,NOMCOU)
              CALL UTFINM
            ENDIF
            ZK8(LDLID+(J-1)*2)=NOMCOU
          ENDIF
150     CONTINUE
C
C  BOUCLE SUR LES INTERFACES
C
        DO 160 J=3,4
          CALL GETVTX(CLELIA,CLEL(J),I,1,0,KBID,IOC)
          IOC=-IOC
          IF(IOC.NE.1) THEN
            CALL UTDEBM('F',PGC,'NOMBRE DE MOT-CLE INVALIDE')
            CALL UTIMPI('L','NUMERO LIAISON:',1,I)
            CALL UTIMPK('L','MOT-CLE:',1,CLEL(J))
            CALL UTIMPI('L','VOUS EN AVEZ DEFINI:',1,IOC)
            CALL UTIMPI('L','IL EN FAUT EXACTEMENT:',1,1)
            CALL UTFINM
          ELSE
            CALL GETVTX(CLELIA,CLEL(J),I,1,1,NOMCOU,IBID)
          ENDIF
C
C  VERIFICATION DE L'EXISTANCE DE L'INTERFACE
C
            NOMSST=ZK8(LDLID+(J-3)*2)
            CALL MGUTDM(NOMRES,NOMSST,IBID,'NOM_LIST_INTERF',IBID,LINTF)
            CALL JENONU(JEXNOM(LINTF//'      .INTD.NOMS',NOMCOU),IRET)
            IF(IRET.EQ.0) THEN
              CALL UTDEBM('F',PGC,'INTERFACE INEXISTANTES')
              CALL UTIMPI('L','NUMERO LIAISON:',1,I)
              CALL UTIMPK('L','NOM SOUS-STRUCTURE:',1,NOMSST)
              CALL UTIMPK('L','NOM MACR_ELEM:',1,NOMTMP)
              CALL UTIMPK('L','NOM INTERFACE INEXISTANTE:',1,NOMCOU)
              CALL UTFINM
            ENDIF
            ZK8(LDLID+(J-3)*2+1)=NOMCOU
160     CONTINUE
140   CONTINUE
C
C-----TRAITEMENT DES TRANSLATIONS SI NON INTRODUIT PAR L'UTILISATEUR
C
      IF(ITRAN.EQ.0) THEN
        CALL GETFAC(CLELIA,NBLIA)
        DEFLIA=NOMRES//'      .MODG.LIDF'
        CALL WKVECT(TT//'.DEF.LIA','V V I',NBLIA*2,LTLIA)
C
C  RECUPERATION DE LA DEFINITION DES LIAISONS
C
        DO 50 I=1,NBLIA
          CALL JEVEUO(JEXNUM(DEFLIA,I),'L',LLDEFL)
          SST1=ZK8(LLDEFL)
          SST2=ZK8(LLDEFL+2)
          CALL JENONU(JEXNOM(REPSST,SST1),NUSST1)
          CALL JENONU(JEXNOM(REPSST,SST2),NUSST2)
          ZI(LTLIA+(I-1)*2)=NUSST1
          ZI(LTLIA+(I-1)*2+1)=NUSST2
50      CONTINUE
C
        CALL WKVECT(TT//'.DESC.ORIENT','V V I',NBSST*3,LTDESC)
        CALL WKVECT(TT//'.ACTIF','V V I',NBSST,LTFAC)
C
C-----DETERMINATION DE L'ORDRE DE PRISE EN COMPTE DES SST---------------
C
C     POUR CHAQUE SST ACTIVE 1--> NUMERO SST DANS NOMRES
C                            2--> NUMERO DE LIAISON POUR POSITIONNEMENT
C                            3--> NUMERO ANTAGONISTE DANS NOMRES
C
C  ON TRAITE LA PREMIERE SST
C
        ICOMP=1
        ZI(LTDESC)=ZI(LTLIA)
C
C  BOUCLE SUR LES SST
C
        DO 60 I=1,NBSST
          ZI(LTFAC+I-1)=1
60      CONTINUE
        NUDEP=ZI(LTDESC)
        ZI(LTFAC+NUDEP-1)=0
C
        DO 70 I=1,NBSST
          NUDEP=ZI(LTDESC+(I-1)*3)
C
C  ON TRAITE LES SST QUI Y SONT RELIEES
C
          DO 80 J=1,NBLIA
            NU1=ZI(LTLIA+(J-1)*2)
            NU2=ZI(LTLIA+(J-1)*2+1)
            CONOK=.TRUE.
            NUAR=0
C
C  ON REGARDE SI LA SST ANTAGONISTE N'EST PAS DEJA TRAITEE
C
            IF(NUDEP.EQ.NU1) THEN
              NUAR=NU2
              DO 90 K=1,ICOMP
                IF(ZI(LTDESC+(K-1)*3).EQ.NU2) CONOK=.FALSE.
90            CONTINUE
            ENDIF
            IF(NUDEP.EQ.NU2) THEN
              NUAR=NU1
              DO 100 K=1,ICOMP
                IF(ZI(LTDESC+(K-1)*3).EQ.NU1) CONOK=.FALSE.
100           CONTINUE
            ENDIF
C
C  SI L'ANTAGONISTE N'EST PAS TRAITEE ON LA TRAITE
C
            IF(CONOK.AND.NUAR.NE.0) THEN
              ICOMP=ICOMP+1
              ZI(LTDESC+(ICOMP-1)*3)=NUAR
              ZI(LTDESC+(ICOMP-1)*3+1)=J
              ZI(LTDESC+(ICOMP-1)*3+2)=NUDEP
              ZI(LTFAC+NUAR-1)=0
            ENDIF
80        CONTINUE
70      CONTINUE
C
C  ON REGARDE S'IL RESTE DES SST NON TRAITEES
C
        DO 110 I=1,NBSST
          NUSST=ZI(LTFAC+I-1)
          IF(NUSST.NE.0) THEN
            CALL JENUNO(JEXNUM(REPSST,NUSST),NOMSST)
            CALL UTDEBM('F',PGC,'UNE SOUS-STRUCTURE EST SANS CONNEXION')
            CALL UTIMPK('L',' SOUS-STRUCTURE --> ',1,NOMSST)
            CALL UTFINM
          ENDIF
110      CONTINUE
C
        CALL JEDETR(TT//'.DEF.LIA')
        CALL JEDETR(TT//'.ACTIF')
C
C-----CALCUL DU VECTEUR DES TRANSLATIONS
C
        CALL WKVECT(TT//'.TRANSLATION','V V R',NBSST*3,LTTRA)
        CALL WKVECT(TT//'.ROTATION','V V R',NBSST*3,LTROT)
        DO 200 I=1,NBSST
          NUSST=ZI(LTDESC+(I-1)*3)
          CALL JENUNO(JEXNUM(REPSST,NUSST),NOMSST)
          CALL JENONU(JEXNOM(REPSST,NOMSST),IBID)
          CALL JEVEUO(JEXNUM(ROTSST,IBID),'L',LLROT)
          DO 210 K=1,3
            ZR(LTROT+(I-1)*3+K-1)=ZR(LLROT+K-1)
210       CONTINUE
200     CONTINUE
        CALL CALCTR(NOMRES,NBSST,ZI(LTDESC),ZR(LTROT),ZR(LTTRA))
        DO 120 I=1,NBSST
          NUSST=ZI(LTDESC+(I-1)*3)
          CALL JENUNO(JEXNUM(REPSST,NUSST),NOMSST)
          CALL JENONU(JEXNOM(REPSST,NOMSST),IBID)
          CALL JEVEUO(JEXNUM(TRASST,IBID),'E',LDTRA)
          DO 130 J=1,3
            ZR(LDTRA+J-1)=ZR(LTTRA+(I-1)*3+J-1)
130       CONTINUE
120     CONTINUE
C
        CALL JEDETR(TT//'.DESC.ORIENT')
        CALL JEDETR(TT//'.TRANSLATION')
        CALL JEDETR(TT//'.ROTATION')
      ENDIF
C
 9999 CONTINUE
      CALL JEDEMA()
      END
