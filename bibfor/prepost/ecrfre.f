      SUBROUTINE ECRFRE(IFI1,IFI2,NOMSDR,NOMSYM,NUMORD,NUORD1,
     +             NORDEN,IORDEN,NBVSCA,NBVVEC,ICPRES,LCHAM1,LRESU,
     +             NBVSCO,NBVVCO,VIORD,VRORD,VKORD,TYPORD,LGNUO1,
     +             FICH,LGFICH)
      IMPLICIT REAL*8 (A-H,O-Z)
C
      INTEGER           IFI1,IFI2
      CHARACTER*(*)               NOMSDR,NOMSYM
      INTEGER      NORDEN,IORDEN,NBVSCA,NBVVEC,ICPRES,NUMORD,NUORD1
      INTEGER      NBVSCO,NBVVCO,VIORD,                   LGNUO1,LGFICH
      REAL*8                           VRORD
      CHARACTER*(*)                          VKORD,TYPORD
      LOGICAL                                         LCHAM1,LRESU
      CHARACTER*80 FICH
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF PREPOST  DATE 24/11/2000   AUTEUR CIBHHLV L.VIVAN 
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
C     LECTURE SI NECESSAIRE ET MODIFICATION DU DEBUT DU
C     FICHIER "RESULTS" ENSIGHT AVANT INSERTION DANS CE FICHIER
C     DE NOUVELLES VARIABLES SCALAIRES ET VECTORIELLES
C   ENTREE:
C      IFI1  : UNITE LOGIQUE DU FICHIER "RESULTS" ENSIGHT
C      IFI2  : UNITE LOGIQUE POUR LES FICHIERS DE VALEURS ENSIGHT
C      NOMSDR: NOM DE LA SD_RESULTAT DONT EST ISSU LE CHAM_NO
C      NOMSYM: NOM SYMBOLIQUE DU CHAM_NO
C      NUMORD: NUMERO D'ORDRE DU CHAMP
C      NUORD1: NUMERO DU PREMIER DES NUMEROS D'ORDRE A IMPRIMER
C      NORDEN: NOMBRE DE NUMEROS D'ORDRE A IMPRIMER
C      IORDEN: INDICE DE NUMORD DANS LA LISTE DES NUMEROS D'ORDRE
C      NBVSCA: NOMBRE DE VARIABLES SCALAIRES A RAJOUTER DANS LE
C              FICHIER "RESULTS" ENSIGHT
C      NBVVEC: NOMBRE DE VARIABLES VECTORIELLES A RAJOUTER
C      ICPRES: INDIQUE SI LE CHAMP EST PRESENT POUR LA 1ERE FOIS (=0)
C              AUQUEL CAS IL FAUDRA RAJOUTER DES NOMS GENERIQUES DE
C              FICHIERS ET DE VARIABLES DANS LE FICHIER "RESULTS"
C      LCHAM1: INDIQUE SI LE CHAMP EST LE PREMIER DES CHAMPS
C              A IMPRIMER POUR LE NUMERO D'ORDRE NUMORD
C      LRESU : =.TRUE. INDIQUE IMPRESSION D'UN CONCEPT RESULTAT
C   SORTIE:
C      NBVSC0: NOMBRE DE VARIABLES SCALAIRES DEJA PRESENTES DANS LE
C              FICHIER "RESULTS" ENSIGHT
C      NBVVCO: NOMBRE DE VARIABLES VECTORIELLES DEJA PRESENTES
C      VIORD : VALEUR ENTIERE ASSOCIEE AU NUMERO D'ORDRE NUMORD
C      VRORD : VALEUR REELLE  ASSOCIEE AU NUMERO D'ORDRE NUMORD
C      VKORD : CHAINE DE CARACTERES ASSOCIEE AU NUMERO D'ORDRE NUMORD
C      TYPORD: TYPE NUM. D'ORDRE: 'NUME_MODE','FREQ','INST','NUME_CAS'
C      LGNUO1: LONGUEUR DE LA CHAINE DE CARACTERES ASSOCIE A NUORD1
C      FICH  : DEBUT DU NOM GENERIQUE DES FICHIERS DE VALEURS ASSOCIES
C              AUX VARIABLES SCALAIRES ET VECTORIELLES A INSERER DANS
C              LE FICHIER "RESULTS"
C      LGFICH: LONGUEUR UTILE DE LA CHAINE DE CARACTERES FICH
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
      CHARACTER*6  CHORD1,CHNBOR
      CHARACTER*8  NOMSD,K8BID
      CHARACTER*15 NOMREP
      CHARACTER*16 NOSY16
      CHARACTER*26 NOFRGD
      CHARACTER*33 NOFRRE
      CHARACTER*80 FICVAR
      INTEGER      LGCONC,LGCH16,LGNORD
      INTEGER      GEOB,NUMPDT,NBRPDT,NUORD0,INCRNO
      INTEGER      IMODE,ANATYP
C     ANATYP=TYPE D'ANALYSE: 1 STATIQUE   , 2 MODALE,
C                            4 TRANSITOIRE, 5 HARMONIQUE, 6 MULT_ELAS
      CHARACTER*16 TYPESD
      LOGICAL      EXIFGD,EXIFRE
      REAL*8       VALPDT
C
C     --- INITIALISATIONS ----
      CALL JEMARQ()
      NOMREP='./RESU_ENSIGHT/'
      NOMSD=NOMSDR
      NOSY16=NOMSYM
      LGCONC=LXLGUT(NOMSD)
      LGCH16=LXLGUT(NOSY16)
      GEOB=0
      NUMPDT=1
      NBRPDT=0
      NUORD0=0
      INCRNO=1
      NBVSCO=0
      NBVVCO=0
C
C     --- CAS D'UN CHAM_GD
      IF(.NOT.LRESU) THEN
        NOFRGD=NOMREP//'CHAM_GD.res'
        INQUIRE(FILE=NOFRGD,ERR=2,IOSTAT=IOS1,EXIST=EXIFGD)
   2    CONTINUE
        IF(IOS1.NE.0) GO TO 99
        IF(EXIFGD) THEN
          OPEN(UNIT=IFI1,ERR=3,STATUS='OLD',FILE=NOFRGD,IOSTAT=IOS2)
   3      CONTINUE
          IF(IOS2.NE.0) GO TO 99
          REWIND(UNIT=IFI1,ERR=4,IOSTAT=IOS3)
   4      CONTINUE
          IF(IOS3.NE.0) GO TO 99
          READ(IFI1,'(I6,1X,I6,1X,I6)') NBVSCO,NBVVCO,GEOB
          READ(IFI1,'(I6)') NUMPDT
          READ(IFI1,'(1PE13.5)') VALPDT
        ELSE
          OPEN(UNIT=IFI1,ERR=5,STATUS='NEW',FILE=NOFRGD,IOSTAT=IOS2)
   5      CONTINUE
          IF(IOS2.NE.0) GO TO 99
        ENDIF
      ELSE
C       - LE NOM DU FICHIER "RESULTS" ENSIGHT EST CONSTRUIT A PARTIR DU
C         NOM DU CONCEPT ET DU NUMERO DU 1ER NUMERO D'ORDRE A IMPRIMER.
C         CE FICHIER EST MODIFIE SI NECESSAIRE A CHAQUE APPEL A ECRFRE.
        NOFRRE=NOMREP//NOMSD(1:LGCONC)
        NOFRRE=NOFRRE(1:15+LGCONC)//'.res'
        CALL CODENT(NUORD1,'G',CHORD1)
        LGNUO1=LXLGUT(CHORD1)
        NOFRRE=NOFRRE(1:15+LGCONC+4)//CHORD1(1:LGNUO1)
C       - RECUPERATION DU TYPE ASSOCIE AU NUMERO D'ORDRE ET DE SA VALEUR
        ANATYP = 0
        CALL DISMOI('E','TYPE_RESU',NOMSD,'RESULTAT',IBID,TYPESD,IER)
        IF(TYPESD.NE.'CHAMP') THEN
          CALL RSNOPA(NOMSD,0,'&&ECRFRE.NOM_ACC',NBAC,NBPA)
          CALL JEVEUO('&&ECRFRE.NOM_ACC','E',JPAR)
          IF(NBAC.EQ.0) THEN
            ANATYP = 1
          ELSE
            DO 10 I=1,NBAC
              IF(ZK16(JPAR-1+I).EQ.'INST') THEN
                ANATYP = 4
                GO TO 11
              ELSEIF(ZK16(JPAR-1+I).EQ.'NUME_MODE') THEN
                ANATYP = 2
                GO TO 11
              ELSEIF (ZK16(JPAR-1+I).EQ.'FREQ') THEN
                ANATYP = 5
              ELSEIF (ZK16(JPAR-1+I).EQ.'NOM_CAS') THEN
                ANATYP = 6
                GO TO 11
              ENDIF
 10         CONTINUE
          ENDIF
        ENDIF
 11     CONTINUE
        CALL JEDETR('&&ECRFRE.NOM_ACC')
        IF((ANATYP.EQ.0).OR.(ANATYP.EQ.1)) THEN
          VIORD=0
          VRORD=DBLE(NUMORD)
          TYPORD='INCONNU'
        ELSEIF(ANATYP.EQ.2) THEN
          CALL RSADPA(NOMSD,'L',1,'NUME_MODE',NUMORD,0,IAD,K8BID)
          VIORD=ZI(IAD)
          CALL RSEXPA ( NOMSD, 2, 'FREQ', IRET )
          IF ( IRET .NE. 0 ) THEN
             CALL RSADPA(NOMSD,'L',1,'FREQ',NUMORD,0,IAD,K8BID)
          ELSE
             CALL RSEXPA ( NOMSD, 2, 'CHAR_CRIT', IRET )
             IF ( IRET .NE. 0 ) THEN
                CALL RSADPA(NOMSD,'L',1,'CHAR_CRIT',NUMORD,0,IAD,K8BID)
             ELSE
                K8BID = NOMSD(1:8)
               CALL UTMESS('F','ECRFRE','SD RESULTAT INCONNUE '//K8BID)
             ENDIF
          ENDIF
          VRORD  = ZR(IAD)
          TYPORD='NUME_MODE'
        ELSEIF(ANATYP.EQ.4) THEN
         VIORD=0
         CALL RSADPA(NOMSD,'L',1,'INST',NUMORD,0,IAD,K8BID)
         VRORD=ZR(IAD)
         TYPORD='INST'
        ELSEIF(ANATYP.EQ.5) THEN
          VIORD=0
          CALL RSADPA(NOMSD,'L',1,'FREQ',NUMORD,0,IAD,K8BID)
          VRORD=ZR(IAD)
          TYPORD='FREQ'
        ELSEIF(ANATYP.EQ.6) THEN
          VIORD=NUMORD
          CALL RSADPA(NOMSD,'L',1,'NOM_CAS',NUMORD,0,IAD,K8BID)
          VKORD=ZK16(IAD)
          VRORD=DBLE(NUMORD)
          TYPORD='NUME_CAS'
        END IF
C
        IF((IORDEN.EQ.1).AND.(LCHAM1)) THEN
C       - 1ER NUMERO D'ORDRE A ECRIRE ET 1ER CHAMP POUR CE NUMERO:
C         ON VERIFIE L'EXISTENCE DU FICHIER (SI OUI PROBLEME)
          INQUIRE(FILE=NOFRRE,ERR=6,IOSTAT=IOS1,EXIST=EXIFRE)
   6      CONTINUE
          IF(IOS1.NE.0) GO TO 100
          IF(EXIFRE) THEN
            CALL UTMESS('F','ECRFRE',' L''IMPRESSION DE LA'//
     +        ' SD_RESULTAT '//NOMSD(1:LGCONC)//' A DEJA'//
     +        ' ETE EFFECTUEE AVEC UNE LISTE DE NUMEROS D''ORDRE'//
     +        ' DONT LE PREMIER NUMERO ETAIT LE MEME QUE CELUI DE LA'
     +        //' LISTE ACTUELLE. ON ARRETE L''IMPRESSION AFIN'//
     +        ' D''EVITER L''ECRASEMENT DES FICHIERS ECRITS.')
            GOTO 9999
          ELSE
            OPEN(UNIT=IFI1,ERR=7,STATUS='NEW',FILE=NOFRRE,IOSTAT=IOS2)
   7        CONTINUE
            IF(IOS2.NE.0) GO TO 100
          ENDIF
        ELSE
C         - ON A NECESSAIREMENT DEJA ECRIT DANS LE FICHIER "RESULTS"
          OPEN(UNIT=IFI1,ERR=8,STATUS='OLD',FILE=NOFRRE,IOSTAT=IOS2)
   8      CONTINUE
          IF(IOS2.NE.0) GO TO 100
          REWIND(UNIT=IFI1,ERR=9,IOSTAT=IOS3)
   9      CONTINUE
          IF(IOS3.NE.0) GO TO 100
          IF((IORDEN.GT.1).OR.(.NOT.LCHAM1)) THEN
            READ(IFI1,'(I6,1X,I6,1X,I6)') NBVSCO,NBVVCO,GEOB
            READ(IFI1,'(I6)') NBRPDT
            CALL JEDETR('&&ECRFRE.VALPDT')
            CALL WKVECT('&&ECRFRE.VALPDT','V V R',NBRPDT+1,JVAPDT)
            READ(IFI1,'(6(1PE13.5))') (ZR(JVAPDT-1+IVAL),IVAL=1,NBRPDT)
            IF(LCHAM1) THEN
              ZR(JVAPDT+NBRPDT)=VRORD
              IF(TYPORD.EQ.'NUME_MODE') ZR(JVAPDT+NBRPDT)=DBLE(VIORD)
            ENDIF
            IF(NBRPDT.GT.1) READ(IFI1,'(I6,1X,I6)') NUORD0,INCRNO
          ENDIF
        ENDIF
      ENDIF
C     - IL VA FALLOIR RAJOUTER UN PAS DE TEMPS AVEC SA VALEUR OU
C       INSERER DES NOMS DE FICHIERS ET DE VARIABLES ENSIGHT
C       DANS LE FICHIER "RESULTS", ON LIT ET STOCKE LES NOMS DEJA ECRITS
      IF((NBVSCO+NBVVCO).GT.0) THEN
        CALL JEDETR('&&ECRFRE.NOMS_FIVA')
        CALL WKVECT('&&ECRFRE.NOMS_FIVA','V V K80',NBVSCO+NBVVCO,
     +                                                       JFIVA)
        DO 20 I=1,NBVSCO+NBVVCO
          READ(IFI1,'(A)') FICVAR
          ZK80(JFIVA-1+I)=FICVAR
   20   CONTINUE
      ENDIF
      REWIND(UNIT=IFI1,ERR=21,IOSTAT=IOS3)
   21 CONTINUE
      IF(IOS3.NE.0) THEN
        IF(.NOT.LRESU) GO TO 99
        GO TO 100
      ENDIF
C     --- ON COMMENCE ICI LA MODIFICATION DU FICHIER "RESULTS"
      IF((.NOT.LRESU).OR.(ICPRES.EQ.0)) THEN
        WRITE(IFI1,'(I6,1X,I6,1X,I6)') NBVSCO+NBVSCA,NBVVCO+NBVVEC,GEOB
      ELSE
        WRITE(IFI1,'(I6,1X,I6,1X,I6)') NBVSCO,NBVVCO,GEOB
      ENDIF
      IF(.NOT.LRESU) THEN
C       - CHAM_GD (1 SEUL PAS DE TEMPS DANS LE FICHIER "RESULTS")
        VALPDT=1.0D0
        WRITE(IFI1,'(I6)') NUMPDT
        WRITE(IFI1,'(1PE13.5)') VALPDT
C       - DEFINITION DU DEBUT DU NOM DE FICHIER DE VALEURS ENSIGHT
C         A PARTIR DU NOM DU CHAM_GD
C         (+ NOM DES COMPOSANTES POUR CHAQUE FICHIER DE VALEURS)
        FICH=NOSY16(1:LGCH16)//'.'
        LGFICH=LGCH16+1
      ELSE
C       - CONCEPT RESULTAT
C         (AUTANT DE PAS DE TEMPS QUE DE NUMEROS D'ORDRE A IMPRIMER)
        IF(IORDEN.EQ.1) THEN
          VALPDT=VRORD
          IF(LCHAM1) NBRPDT=1
          IF(TYPORD.EQ.'NUME_MODE') VALPDT=DBLE(VIORD)
          WRITE(IFI1,'(I6)') NBRPDT
          WRITE(IFI1,'(1PE13.5)') VALPDT
        ELSE
          IF(LCHAM1) NBRPDT=NBRPDT+1
          WRITE(IFI1,'(I6)') NBRPDT
          WRITE(IFI1,'(6(1PE13.5))') (ZR(JVAPDT-1+IVAL),IVAL=1,NBRPDT)
          WRITE(IFI1,'(I6,1X,I6)') NUORD0,INCRNO
        ENDIF
C       - DEFINITION DU DEBUT DU NOM GENERIQUE DE FICHIER DE VALEURS
C         ENSIGHT A PARTIR DU NOM DU CONCEPT, DU NOM DU CHAMP,
C         ET DU NUMERO DU 1ER NUMERO D'ORDRE
C         (PLUS LE NOM DES COMPOSANTES POUR CHAQUE FICHIER DE VALEURS)
        FICH=NOMSD(1:LGCONC)//'.'//NOSY16(1:LGCH16)//'.'
        LGFICH=LGCONC+1+LGCH16+1
        CALL CODENT(NORDEN,'G',CHNBOR)
        LGNORD=LXLGUT(CHNBOR)
        IF(NORDEN.EQ.1) THEN
          FICH=FICH(1:LGFICH)//CHORD1(1:LGNUO1)//'.'
          LGFICH=LGFICH+LGNUO1+1
        ELSE
          IF(LGNORD.EQ.1) THEN
            FICH=FICH(1:LGFICH)//CHORD1(1:LGNUO1)//'+*.'
          ELSEIF (LGNORD.EQ.2) THEN
            FICH=FICH(1:LGFICH)//CHORD1(1:LGNUO1)//'+**.'
          ELSEIF (LGNORD.EQ.3) THEN
            FICH=FICH(1:LGFICH)//CHORD1(1:LGNUO1)//'+***.'
          ELSEIF (LGNORD.EQ.4) THEN
            FICH=FICH(1:LGFICH)//CHORD1(1:LGNUO1)//'+****.'
          ELSEIF (LGNORD.EQ.5) THEN
            FICH=FICH(1:LGFICH)//CHORD1(1:LGNUO1)//'+*****.'
          ELSEIF (LGNORD.EQ.6) THEN
            FICH=FICH(1:LGFICH)//CHORD1(1:LGNUO1)//'+******.'
          ENDIF
          LGFICH=LGFICH+LGNUO1+LGNORD+2
        ENDIF
      ENDIF
      GOTO 999
  99  CONTINUE
      CALL UTMESS('E','IMPR_RESU','PROBLEME A L''OUVERTURE DU'//
     +     ' FICHIER RESULTAT ENSIGHT '//NOFRGD//
     +     ' POUR L''IMPRESSION DU CHAM_GD '//NOSY16)
      GOTO 999
 100  CONTINUE
      CALL UTMESS('E','IMPR_RESU','PROBLEME A L''OUVERTURE DU'//
     +     ' FICHIER RESULTAT ENSIGHT '//NOFRRE//
     +     ' POUR L''IMPRESSION DU CONCEPT '//NOMSD(1:LGCONC))
      GOTO 999
 999  CONTINUE
      CALL JEDETR('&&ECRFRE.VALPDT')
 9999 CONTINUE
      CALL JEDEMA()
      END
