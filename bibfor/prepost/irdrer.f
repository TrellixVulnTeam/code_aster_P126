      SUBROUTINE IRDRER(IFI1,IFI2,NBNO,DESC,NEC,DG,
     +              NCMPMX,NBCMPT,NUCMPU,
     +              VALE,NOMGD,NCMPGD,NOMSDR,NOMSYM,
     +              NUMORD,NUORD1,NORDEN,IORDEN,NBCHAM,ICHAM,
     +              LCHAM1,LRESU)
      IMPLICIT REAL*8 (A-H,O-Z)
C
      INTEGER           IFI1,IFI2,NBNO,DESC(*),NEC,DG(*)
      INTEGER       NCMPMX,       NBCMPT,NUCMPU(*)
      REAL*8        VALE(*)
      CHARACTER*(*)      NOMGD,NCMPGD(*),NOMSDR,NOMSYM
      INTEGER       NUMORD,NUORD1,NORDEN,IORDEN,NBCHAM,ICHAM
      LOGICAL       LCHAM1,LRESU
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF PREPOST  DATE 09/03/99   AUTEUR JMBHH01 J.M.PROIX 
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
C TOLE CRP_21
C--------------------------------------------------------------------
C     ECRITURE AU FORMAT ENSIGHT D'UN CHAM_NO A
C     VALEURS REELLES ET PROFIL AU NOEUDS CONSTANT
C   ENTREE:
C     IFI1  : UNITE LOGIQUE DU FICHIER "RESULTS" ENSIGHT
C     IFI2  : UNITE LOGIQUE POUR LES FICHIERS DE VALEURS ENSIGHT
C     NBNO  : NOMBRE DE NOEUDS DU LIGREL ( DU MAILLAGE)
C     DESC  :
C     NEC   : NOMBRE D'ENTIERS-CODES
C     DG    : ENTIERS CODES
C     NCMPMX: NOMBRE MAXI DE CMP DE LA GRANDEUR NOMGD
C     NBCMPT: NOMBRE DE CMP A IMPRIMER (NBCMPT=0 : PAS DE SELECTION)
C     NUCMPU: NUMEROS DES CMP A IMPRIMER SI NBCMPT > 0
C     VALE  : VALEURS DU CHAM_NO
C     NOMGD : NOM DE LA GRANDEUR  DEPL_R, TEMP_R, SIEF_R, EPSI_R,...
C     NCMPGD: NOMS DES CMP DE LA GRANDEUR NOMGD
C     NOMSDR: NOM DE LA SD_RESULTAT DONT EST ISSU LE CHAM_NO
C     NOMSYM: NOM SYMBOLIQUE DU CHAM_NO
C     NUMORD: NUMERO D'ORDRE DU CHAMP
C     NUORD1: NUMERO DU PREMIER DES NUMEROS D'ORDRE A IMPRIMER
C     NORDEN: NOMBRE DE NUMEROS D'ORDRE A IMPRIMER
C     IORDEN: INDICE DE NUMORD DANS LA LISTE DES NUMEROS D'ORDRE
C             A IMPRIMER
C     NBCHAM: NOMBRE DE CHAMPS A IMPRIMER
C     ICHAM : INDICE DU CHAMP DANS LA LISTE DES CHAMPS A IMPRIMER
C     LCHAM1: INDIQUE SI LE CHAMP EST LE PREMIER DES CHAMPS
C             A IMPRIMER POUR LE NUMERO D'ORDRE NUMORD
C     LRESU : =.TRUE. INDIQUE IMPRESSION D'UN CONCEPT RESULTAT
C ----------------------------------------------------------------------
C !! EN CAS DE MODIFICATION DE CE SS-PGME, PENSER A IRDEER,IRDEEC,IRDREC
C
C     ----------- COMMUNS NORMALISES  JEVEUX  --------------------------
      COMMON /IVARJE/ZI(1)
      COMMON /RVARJE/ZR(1)
      COMMON /CVARJE/ZC(1)
      COMMON /LVARJE/ZL(1)
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      INTEGER ZI
      REAL*8 ZR
      COMPLEX*16 ZC
      LOGICAL ZL,EXISTE,EXISDG
      CHARACTER*8  ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32,JEXNUM,JEXNOM
      CHARACTER*80 ZK80
C     ------------------------------------------------------------------
      CHARACTER*4  FITYPE
      CHARACTER*6  CHORD1,CHNBOR,CHNUOR,CHNMOD
      CHARACTER*8  NOMSD,NOCMP,NOCMP1,NOCMP2,NOCMP3
      CHARACTER*10 TYPORD
      CHARACTER*16 NOSY16,VKORD
      CHARACTER*19 NOMVAR
      CHARACTER*60 NOFIVA,FIEN
      CHARACTER*80 FICH,FICVAR,DESRFV,DESIFV
      INTEGER      NBVSMX,NBVSCA,NBVVMX,NBVVEC,LGCONC,LGDESC
      INTEGER      LGCH16,LGCOMP,LGCMP1,LGCMP2,LGCMP3
      INTEGER      LGFIVA,LGFICH,LGNUO1,LGNORD,LGIORD,LGNTXT
      INTEGER      ICPRES,NVIDAV,NVIDAP,VIORD
      INTEGER      NBVSCO,NBVVCO,IPVSCA(500),IPVVEC(500,3)
      LOGICAL      IMPSCA(500),IMPVEC(500),EXIFVA
      LOGICAL      LNULV1,LNULV2,LNULV3
      REAL*8       VRORD,VALR8(6)
C
C     --- INITIALISATIONS ----
      CALL JEMARQ()
      NOMSD=NOMSDR
      NOSY16=NOMSYM
      LGCONC=LXLGUT(NOMSD)
      LGCH16=LXLGUT(NOSY16)
      LNULV1=.FALSE.
      LNULV2=.FALSE.
      LNULV3=.FALSE.
      NBVSMX=0
      NBVVMX=0
      NBVSCA=0
      NBVVEC=0
      ICPRES=-1
      NVIDAV=0
      NVIDAP=0
C
C     - PARCOURS DES COMPOSANTES DU CHAM_NO PORTEES PAR CHACUN DES
C       NOEUDS UNIQUEMENT, DEFINITION DES VARIABLES ENSIGHT SCALAIRES
C       ET VECTORIELLES A PARTIR DES COMPOSANTES ET DE LEURS POSITIONS
C       DANS LE CHAM_NO
      CALL IRGAGE(NCMPMX,NCMPGD,NBCMPT,NUCMPU,
     +            NBVSMX,IPVSCA,NBVVMX,IPVVEC)
      IF (NBVSMX.GT.500.OR.NBVVMX.GT.500) CALL UTMESS('F','IRDRER','LE'
     &  //' LE NOMBRE DE CMPS DE LA GRANDEUR DU CHAMP DEPASSE 500'
     &  //' AUGMENTER LA DIMENSION DE 4 TABLEAUX STATIQUES')
      NBVSCA=NBVSMX
      NBVVEC=NBVVMX
C     --- LE CHAMP EST A REPRESENTATION CONSTANTE, TOUS LES NOEUDS
C         PORTENT LE MEME NOMBRE DE COMPOSANTES ET LE RANG DE CHACUNE
C         DANS VALE(*) EST LE MEME POUR TOUS LES NOEUDS
C     - NCMP : NOMBRE DE CMPS PORTEES PAR CHACUN DES NOEUDS
      NCMP = -DESC(2)
      DO 57 IEC=1,NEC
        DG(IEC)=DESC(3+IEC-1)
  57  CONTINUE
C     - ON VERIFIE QUE LES VARIABLES SCALAIRES (COMPOSANTES) SONT
C       PORTEES PAR LES NOEUDS. SINON ON NE LES IMPRIMERA PAS.
      DO 70 ISCA=1,NBVSMX
        IMPSCA(ISCA)=.FALSE.
        ICMPAS=IPVSCA(ISCA)
        IF(EXISDG(DG,ICMPAS)) THEN
           IMPSCA(ISCA)=.TRUE.
           GO TO 70
        ENDIF
        NBVSCA=NBVSCA-1
        IF(NBCMPT.GT.0) THEN
          NOCMP=NCMPGD(ICMPAS)
          LGCOMP=LXLGUT(NOCMP)
          IF(.NOT.LRESU) THEN
            CALL UTMESS('A','IRDRER',' IMPR_RESU FORMAT ENSIGHT :'//
     +            ' LA COMPOSANTE '//NOCMP(1:LGCOMP)//' DU CHAM_GD '
     +            //NOSY16(1:LGCH16)//' N''EST PAS PORTEE PAR '//
     +            'LES NOEUDS DU MAILLAGE ET NE SERA PAS IMPRIMEE')
          ELSE
            CALL UTMESS('A','IRDRER',' IMPR_RESU FORMAT ENSIGHT :'//
     +            ' LA COMPOSANTE '//NOCMP(1:LGCOMP)//' DU CHAMP '
     +            //NOSY16(1:LGCH16)//' DU CONCEPT '//
     +            NOMSD(1:LGCONC)//' N''EST PAS PORTEE PAR '//
     +            'LES NOEUDS DU MAILLAGE ET NE SERA PAS IMPRIMEE')
          ENDIF
        ENDIF
  70  CONTINUE
C
C      - ON VERIFIE QU'AU MOINS UNE DES COMPOSANTES DES VECTEURS
C        EST PORTEE PAR LES NOEUDS DU MAILLAGE. SINON ON NE DOIT PAS
C        IMPRIMER LA VARIABLE VECTORIELLE ASSOCIEE
      DO 80 IVEC=1,NBVVMX
        IMPVEC(IVEC)=.FALSE.
        ICMPA1=IPVVEC(IVEC,1)
        ICMPA2=IPVVEC(IVEC,2)
        ICMPA3=IPVVEC(IVEC,3)
        IF(EXISDG(DG,ICMPA1).OR.
     +       EXISDG(DG,ICMPA2).OR.EXISDG(DG,ICMPA3)) THEN
           IMPVEC(IVEC)=.TRUE.
           GO TO 80
        ENDIF
        NBVVEC=NBVVEC-1
        IF(NBCMPT.GT.0) THEN
          NOCMP1=NCMPGD(ICMPA1)
          NOCMP2=NCMPGD(ICMPA2)
          NOCMP3=NCMPGD(ICMPA3)
          LGCMP1=LXLGUT(NOCMP1)
          LGCMP2=LXLGUT(NOCMP2)
          LGCMP3=LXLGUT(NOCMP3)
          IF(.NOT.LRESU) THEN
             CALL UTMESS('A','IRDRER',' IMPR_RESU FORMAT ENSIGHT :'//
     +            ' AUCUNE DES TROIS COMPOSANTES '//
     +            NOCMP1(1:LGCMP1)//' '//NOCMP2(1:LGCMP2)//' '//
     +            NOCMP3(1:LGCMP3)//' DU CHAM_GD '//NOSY16(1:LGCH16)//
     +            ' N''EST PORTEE PAR LES NOEUDS DU MAILLAGE ET LE'//
     +            ' VECTEUR ENSIGHT CORRESPONDANT NE SERA PAS IMPRIME')
          ELSE
             CALL UTMESS('A','IRDRER',' IMPR_RESU FORMAT ENSIGHT :'//
     +            ' AUCUNE DES TROIS COMPOSANTES '//
     +            NOCMP1(1:LGCMP1)//' '//NOCMP2(1:LGCMP2)//' '//
     +            NOCMP3(1:LGCMP3)//' DU CHAMP '//NOSY16(1:LGCH16)//
     +            ' DU CONCEPT '//NOMSD(1:LGCONC)//
     +            ' N''EST PORTEE PAR LES NOEUDS DU MAILLAGE ET LE'//
     +            ' VECTEUR ENSIGHT CORRESPONDANT NE SERA PAS IMPRIME')
          ENDIF
        ENDIF
  80  CONTINUE
C
      IF(LRESU) THEN
C     --- CAS D'UNE SD_RESULTAT: ON RECUPERE LES OBJETS DESCRIPTIFS ---
C       * ICPRES=0 INDIQUE QUE LE CHAMP EST PRESENT POUR LA 1ERE FOIS,
C         AUQUEL CAS IL FAUDRA RAJOUTER DES NOMS GENERIQUES DE FICHIERS
C         ET DE VARIABLES DANS LE FICHIER "RESULTS" ENSIGHT
C       * NVIDAV DONNE LE NOMBRE DE FICHIERS VIDES DE VALEURS A ECRIRE
C         AVANT LES FICHIERS DU CHAMP COURANT
C       * NVIDAP DONNE LE NOMBRE DE FICHIERS VIDES DE VALEURS A ECRIRE
C         APRES LES FICHIERS DU CHAMP COURANT
        CALL JEVEUO('&&IRECRI.CHPRES','L',JCPRES)
        CALL JEVEUO('&&IRECRI.FVIDAV','L',JVIDAV)
        CALL JEVEUO('&&IRECRI.FVIDAP','L',JVIDAP)
        ICPRES=ZI(JCPRES-1+(IORDEN-1)*NBCHAM+ICHAM)
        NVIDAV=ZI(JVIDAV-1+(IORDEN-1)*NBCHAM+ICHAM)
        NVIDAP=ZI(JVIDAP-1+(IORDEN-1)*NBCHAM+ICHAM)
      ENDIF
C
C     - LECTURE ET MODIFICATION DU DEBUT DU FICHIER "RESULTS" ENSIGHT
C       AVANT INSERTION DE NOUVELLES VARIABLES SCALAIRES ET VECTORIELLES
      CALL ECRFRE(IFI1,IFI2,NOMSDR,NOMSYM,NUMORD,NUORD1,
     +            NORDEN,IORDEN,NBVSCA,NBVVEC,ICPRES,LCHAM1,LRESU,
     +            NBVSCO,NBVVCO,VIORD,VRORD,VKORD,TYPORD,LGNUO1,
     +            FICH,LGFIVA)
      NOFIVA=FICH(1:LGFIVA)
C
C     - INSERTION DES NOUVELLES VARIABLES SCALAIRES ET DES FICHIERS
C       DE VALEURS ASSOCIES
      IF(NBVSCA.NE.0) THEN
C       - ECRITURE DES NOMS DES NOUVELLES VARIABLES SCALAIRES
C         (FICHIER "RESULTS" ENSIGHT) PUIS DES FICHIERS DE VALEURS
        DO 20 ISCA=1,NBVSMX
          IF(.NOT.IMPSCA(ISCA)) GO TO 20
          ICMPAS=IPVSCA(ISCA)
          NOCMP=NCMPGD(ICMPAS)
          LGCOMP=LXLGUT(NOCMP)
C         - COMPOSANTE AJOUTEE AU NOM GENERIQUE DU FICHIER DE VALEURS
          NOFIVA=NOFIVA(1:LGFIVA)//NOCMP(1:LGCOMP)
C         - ON ECRIT LES FICHIERS VIDES DE VALEURS SI LE CHAMP
C           N'ETAIT PAS PRESENT A DES INDICES PRECEDENTS
          IF(LRESU.AND.(NVIDAV.GT.0)) THEN
            DO 84 IVIDE=IORDEN-NVIDAV,IORDEN-1
C             - ON DEFINIT LE NOM DU FICHIER VIDE DE VALEURS
              CALL DEFIEN(NOFIVA,NOMSD,LGCONC,NOMGD,NOSY16,LGCH16,
     +                    NOCMP,LGCOMP,LGNUO1,NORDEN,IVIDE,LRESU,
     +                    'SCA_VIDE',0,FICH,LGFICH,NOMVAR,LGNOVA,
     +                    LGDESC,DESRFV,DESIFV)
              FIEN=FICH(1:LGFICH)
              INQUIRE(FILE=FIEN,ERR=200,IOSTAT=IOS1,EXIST=EXIFVA)
 200          CONTINUE
              IF(IOS1.NE.0) THEN
                IF(.NOT.LRESU) GO TO 101
                GOTO 102
              ENDIF
              IF(EXIFVA) GO TO 998
              OPEN(UNIT=IFI2,ERR=85,STATUS='NEW',FILE=FIEN,IOSTAT=IOS2)
  85          CONTINUE
              IF(IOS2.NE.0) THEN
                IF(.NOT.LRESU) GO TO 101
                GOTO 102
              ENDIF
              CLOSE(IFI2)
  84        CONTINUE
          ENDIF
C         --- FICHIER DE VALEURS COURANT ---
C         - ON DEFINIT LE NOM DU FICHIER CONTENANT LES VALEURS,
C           LE NOM DE LA VARIABLE ENSIGHT ASSOCIEE AINSI QUE
C           LA DESCRIPTION DU CONTENU DU FICHIER DE VALEURS
          CALL DEFIEN(NOFIVA,NOMSD,LGCONC,NOMGD,NOSY16,LGCH16,
     +                NOCMP,LGCOMP,LGNUO1,NORDEN,IORDEN,LRESU,
     +                'SCALAIRE',0,FICH,LGFICH,NOMVAR,LGNOVA,
     +                LGDESC,DESRFV,DESIFV)
          IF((.NOT.LRESU) .OR. (ICPRES.EQ.0))
     +         WRITE(IFI1,'(A,1X,A)') NOFIVA(1:LGFIVA+LGCOMP),
     +                                NOMVAR(1:LGNOVA)
          FIEN=FICH(1:LGFICH)
          INQUIRE(FILE=FIEN,ERR=201,IOSTAT=IOS1,EXIST=EXIFVA)
 201      CONTINUE
          IF(IOS1.NE.0) THEN
            IF(.NOT.LRESU) GO TO 101
            GOTO 102
          ENDIF
          IF(EXIFVA) GO TO 998
          OPEN(UNIT=IFI2,ERR=21,STATUS='NEW',FILE=FIEN,IOSTAT=IOS2)
  21      CONTINUE
          IF(IOS2.NE.0) THEN
            IF(.NOT.LRESU) GO TO 101
            GOTO 102
          ENDIF
          IF(TYPORD.EQ.'INST') THEN
            WRITE(IFI2,'(A,A,1PE10.3)') DESRFV(1:LGDESC),' INST=',VRORD
          ELSEIF(TYPORD.EQ.'FREQ') THEN
            WRITE(IFI2,'(A,A,1PE10.3)') DESRFV(1:LGDESC),' FREQ=',VRORD
          ELSEIF(TYPORD.EQ.'NUME_MODE') THEN
            CALL CODENT(VIORD,'G',CHNMOD)
            LGNTXT=LXLGUT(CHNMOD)
            WRITE(IFI2,'(A,1PE10.3)') DESRFV(1:LGDESC)//
     +           ' MODE='//CHNMOD(1:LGNTXT)//' F=',VRORD
          ELSEIF(TYPORD.EQ.'NUME_CAS') THEN
            LGNTXT=LXLGUT(VKORD)
            WRITE(IFI2,'(A)') DESRFV(1:LGDESC)//
     +           ' CAS='//VKORD(1:LGNTXT)
          ELSE
            WRITE(IFI2,'(A)') DESRFV(1:LGDESC)
          ENDIF
          INUVAL=0
          DO 22 INO=1,NBNO
            IVAL=(INO-1)*NCMP
            INUVAL=INUVAL+1
            VALR8(INUVAL)=VALE(IVAL+ICMPAS)
            IF(INUVAL.EQ.6) THEN
              WRITE(IFI2,'(6(1PE12.5))') (VALR8(I),I=1,6)
              INUVAL=0
            ELSEIF(INO.EQ.NBNO) THEN
              WRITE(IFI2,'(6(1PE12.5))') (VALR8(I),I=1,INUVAL)
            ENDIF
  22      CONTINUE
          CLOSE(IFI2)
          IF(LRESU.AND.(NVIDAP.GT.0)) THEN
C           - ON ECRIT LES FICHIERS VIDES DE VALEURS QUI SUIVENT
            DO 86 IVIDE=IORDEN+1,IORDEN+NVIDAP
C             - ON DEFINIT LE NOM DU FICHIER VIDE DE VALEURS
              CALL DEFIEN(NOFIVA,NOMSD,LGCONC,NOMGD,NOSY16,LGCH16,
     +                    NOCMP,LGCOMP,LGNUO1,NORDEN,IVIDE,LRESU,
     +                    'SCA_VIDE',0,FICH,LGFICH,NOMVAR,LGNOVA,
     +                    LGDESC,DESRFV,DESIFV)
              FIEN=FICH(1:LGFICH)
              INQUIRE(FILE=FIEN,ERR=202,IOSTAT=IOS1,EXIST=EXIFVA)
 202          CONTINUE
              IF(IOS1.NE.0) THEN
                IF(.NOT.LRESU) GO TO 101
                GOTO 102
              ENDIF
              IF(EXIFVA) GO TO 998
              OPEN(UNIT=IFI2,ERR=87,STATUS='NEW',FILE=FIEN,IOSTAT=IOS2)
  87          CONTINUE
              IF(IOS2.NE.0) THEN
                IF(.NOT.LRESU) GO TO 101
                GOTO 102
              ENDIF
              CLOSE(IFI2)
  86        CONTINUE
          ENDIF
  20    CONTINUE
      ENDIF

      IF((NBVSCO+NBVVCO).GT.0) THEN
C       - ON RECRIT LES NOMS DES FICHIERS DE VALEURS ET DES VARIABLES
C         QUI ETAIENT DEJA PRESENTS DANS LE FICHIER "RESULTS" ENSIGHT
        CALL JEVEUO('&&ECRFRE.NOMS_FIVA','L',JFIVA)
        DO 27 I=1,NBVSCO+NBVVCO
          FICVAR=ZK80(JFIVA-1+I)
          LGFICH=LXLGUT(FICVAR)
          WRITE(IFI1,'(A)') FICVAR(1:LGFICH)
  27    CONTINUE
      ENDIF

      IF(NBVVEC.NE.0) THEN
C       - CETTE FOIS ON TRAITE LES VARIABLES VECTORIELLES ENSIGHT
        DO 30 IVEC=1,NBVVMX
          IF(.NOT.IMPVEC(IVEC)) GO TO 30
          ICMPA1=IPVVEC(IVEC,1)
          IF(.NOT.EXISDG(DG,ICMPA1)) LNULV1=.TRUE.
          ICMPA2=IPVVEC(IVEC,2)
          IF(.NOT.EXISDG(DG,ICMPA2)) LNULV2=.TRUE.
          ICMPA3=IPVVEC(IVEC,3)
          IF(.NOT.EXISDG(DG,ICMPA3)) LNULV3=.TRUE.
          NOCMP=' '
          LGCOMP=0
          IF(LRESU.AND.(NVIDAV.GT.0)) THEN
            DO 88 IVIDE=IORDEN-NVIDAV,IORDEN-1
              CALL DEFIEN(NOFIVA,NOMSD,LGCONC,NOMGD,NOSY16,LGCH16,
     +                    NOCMP,LGCOMP,LGNUO1,NORDEN,IVIDE,LRESU,
     +                    'VEC_VIDE',0,FICH,LGFICH,NOMVAR,LGNOVA,
     +                    LGDESC,DESRFV,DESIFV)
              FIEN=FICH(1:LGFICH)
              INQUIRE(FILE=FIEN,ERR=203,IOSTAT=IOS1,EXIST=EXIFVA)
 203          CONTINUE
              IF(IOS1.NE.0) THEN
                IF(.NOT.LRESU) GO TO 101
                GOTO 102
              ENDIF
              IF(EXIFVA) GO TO 998
              OPEN(UNIT=IFI2,ERR=89,STATUS='NEW',FILE=FIEN,IOSTAT=IOS2)
  89          CONTINUE
              IF(IOS2.NE.0) THEN
                IF(.NOT.LRESU) GO TO 101
                GOTO 102
              ENDIF
              CLOSE(IFI2)
  88        CONTINUE
          ENDIF
C         --- FICHIER DE VALEURS COURANT ---
          CALL DEFIEN(NOFIVA,NOMSD,LGCONC,NOMGD,NOSY16,LGCH16,
     +                NOCMP,LGCOMP,LGNUO1,NORDEN,IORDEN,LRESU,
     +                'VECTEUR ',0,FICH,LGFICH,NOMVAR,LGNOVA,
     +                LGDESC,DESRFV,DESIFV)
          IF((.NOT.LRESU) .OR. (ICPRES.EQ.0)) THEN
            WRITE(IFI1,'(A,1X,A)') NOFIVA(1:LGFIVA-1),NOMVAR(1:LGNOVA)
          ENDIF
          FIEN=FICH(1:LGFICH)
          INQUIRE(FILE=FIEN,ERR=204,IOSTAT=IOS1,EXIST=EXIFVA)
 204      CONTINUE
          IF(IOS1.NE.0) THEN
            IF(.NOT.LRESU) GO TO 101
            GOTO 102
          ENDIF
          IF(EXIFVA) GO TO 998
          OPEN(UNIT=IFI2,ERR=31,STATUS='NEW',FILE=FIEN,IOSTAT=IOS2)
  31      CONTINUE
          IF(IOS2.NE.0) THEN
            IF(.NOT.LRESU) GO TO 101
            GOTO 102
          ENDIF
          IF(TYPORD.EQ.'INST') THEN
            WRITE(IFI2,'(A,A,1PE10.3)') DESRFV(1:LGDESC),' INST=',VRORD
          ELSEIF(TYPORD.EQ.'FREQ') THEN
            WRITE(IFI2,'(A,A,1PE10.3)') DESRFV(1:LGDESC),' FREQ=',VRORD
          ELSEIF(TYPORD.EQ.'NUME_MODE') THEN
            CALL CODENT(VIORD,'G',CHNMOD)
            LGNTXT=LXLGUT(CHNMOD)
            WRITE(IFI2,'(A,1PE10.3)') DESRFV(1:LGDESC)//
     +           ' MODE='//CHNMOD(1:LGNTXT)//' F=',VRORD
          ELSEIF(TYPORD.EQ.'NUME_CAS') THEN
            LGNTXT=LXLGUT(VKORD)
            WRITE(IFI2,'(A)') DESRFV(1:LGDESC)//
     +           ' CAS='//VKORD(1:LGNTXT)
          ELSE
             WRITE(IFI2,'(A)') DESRFV(1:LGDESC)
          ENDIF
          INUVAL=0
          DO 32 INO=1,NBNO
            IVAL=(INO-1)*NCMP
            INUVAL=INUVAL+1
            IF(.NOT.LNULV1) THEN
               VALR8(3*(INUVAL-1)+1)=VALE(IVAL+ICMPA1)
            ELSE
               VALR8(3*(INUVAL-1)+1)=0.0D0
            ENDIF
            IF(.NOT.LNULV2) THEN
               VALR8(3*(INUVAL-1)+2)=VALE(IVAL+ICMPA2)
            ELSE
               VALR8(3*(INUVAL-1)+2)=0.0D0
            ENDIF
            IF(.NOT.LNULV3) THEN
               VALR8(3*(INUVAL-1)+3)=VALE(IVAL+ICMPA3)
            ELSE
               VALR8(3*(INUVAL-1)+3)=0.0D0
            ENDIF
            IF(INUVAL.EQ.2) THEN
              WRITE(IFI2,'(6(1PE12.5))') (VALR8(I),I=1,6)
              INUVAL=0
            ELSEIF(INO.EQ.NBNO) THEN
              WRITE(IFI2,'(3(1PE12.5))') (VALR8(I),I=1,3)
            ENDIF
  32      CONTINUE
          CLOSE(IFI2)
          IF(LNULV1) LNULV1=.FALSE.
          IF(LNULV2) LNULV2=.FALSE.
          IF(LNULV3) LNULV3=.FALSE.
C
          IF(LRESU.AND.(NVIDAP.GT.0)) THEN
C           - ON ECRIT LES FICHIERS VIDES DE VALEURS QUI SUIVENT
            DO 90 IVIDE=IORDEN+1,IORDEN+NVIDAP
              CALL DEFIEN(NOFIVA,NOMSD,LGCONC,NOMGD,NOSY16,LGCH16,
     +                    NOCMP,LGCOMP,LGNUO1,NORDEN,IVIDE,LRESU,
     +                    'VEC_VIDE',0,FICH,LGFICH,NOMVAR,LGNOVA,
     +                    LGDESC,DESRFV,DESIFV)
              FIEN=FICH(1:LGFICH)
              INQUIRE(FILE=FIEN,ERR=205,IOSTAT=IOS1,EXIST=EXIFVA)
 205          CONTINUE
              IF(IOS1.NE.0) THEN
                IF(.NOT.LRESU) GO TO 101
                GOTO 102
              ENDIF
              IF(EXIFVA) GO TO 998
              OPEN(UNIT=IFI2,ERR=91,STATUS='NEW',FILE=FIEN,IOSTAT=IOS2)
  91          CONTINUE
              IF(IOS2.NE.0) THEN
                IF(.NOT.LRESU) GO TO 101
                GOTO 102
              ENDIF
              CLOSE(IFI2)
  90        CONTINUE
          ENDIF
  30    CONTINUE
      ENDIF
      CLOSE(IFI1)
      GOTO 999
 101  CONTINUE
      CALL UTMESS('E','IRDRER','PROBLEME A L''OUVERTURE DU'//
     +     ' FICHIER DE VALEURS ENSIGHT '//FIEN(1:LGFICH)//
     +     ' POUR L''IMPRESSION DU CHAM_GD '//NOSY16(1:LGCH16))
      GOTO 999
 102  CONTINUE
      CALL UTMESS('E','IRDRER','PROBLEME A L''OUVERTURE DU'//
     +     ' FICHIER DE VALEURS ENSIGHT '//FIEN(1:LGFICH)//
     +     ' POUR L''IMPRESSION DU CHAMP '//NOSY16(1:LGCH16)//
     +     ' DU CONCEPT '//NOMSD(1:LGCONC))
      GOTO 999
 998  CONTINUE
      CALL UTMESS('E','IRDRER','PROBLEME A L''OUVERTURE DU'//
     +     ' FICHIER DE VALEURS ENSIGHT '//FIEN(1:LGFICH)//' : CE '//
     +     'FICHIER EXISTE DEJA !! L''IMPRESSION DU MEME CHAMP OU'//
     +     'CONCEPT RESULTAT EST DEMANDEE DEUX FOIS OU UNE MEME '//
     +     'COMPOSANTE EST SELECTIONNEE 2 FOIS SOUS LE MOT-CLE NOM_CMP')
 999  CONTINUE
      CALL JEDETR('&&ECRFRE.NOMS_FIVA')
      CALL JEDEMA()
      END
