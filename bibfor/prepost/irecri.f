      SUBROUTINE IRECRI(NOMCON,NOSIMP,NOPASE,FORM,FICH,TITRE,
     >     NBCHAM,CHAM,NBPARA,PARA,NBORDR,ORDR,
     >     LRESU,MOTFAC,IOCC,MODELE,CECR,LCOR,NBNOT,
     >     NUMNOE,NBMAT,NUMMAI,NBCMP,NOMCMP,
     >     LSUP,BORSUP,LINF,BORINF,LMAX,LMIN,FORMR,LMOD,
     >     NIVE )
      IMPLICIT REAL*8 (A-H,O-Z)
C
      CHARACTER*(*)     NOMCON,NOSIMP,NOPASE
      CHARACTER*(*)     FORM,FICH,TITRE,      CHAM(*),   PARA(*)
      CHARACTER*(*)                       MOTFAC,     MODELE,CECR
      CHARACTER*(*)     NOMCMP(*), FORMR
      REAL*8            BORSUP,BORINF
      INTEGER           NIVE,              NBCHAM, NBPARA
      INTEGER           NBORDR,ORDR(*),NBCMP,IOCC
      INTEGER           NBNOT,NUMNOE(*),NBMAT,NUMMAI(*)
      LOGICAL                                   LRESU,LCOR
      LOGICAL           LSUP,LINF,              LMAX,LMIN,LMOD
C-----------------------------------------------------------------------
C MODIF PREPOST  DATE 15/10/2002   AUTEUR DURAND C.DURAND 
C            CONFIGURATION MANAGEMENT OF EDF VERSION
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
C
C-----------------------------------------------------------------------
C     ECRITURE D'UN CONCEPT SUR FICHIER RESULTAT
C
C IN  NOMCON : K8  : NOM DU CONCEPT A IMPRIMER
C IN  NOSIMP : K8  : NOM SIMPLE ASSOCIE AU CONCEPT NOMCON SI SENSIBILITE
C IN  NOPASE : K8  : NOM DU PARAMETRE SENSIBLE
C IN  FORM   : K8  : FORMAT D'ECRITURE
C IN  FICH   : K16 : FICHIER D'ECRITURE
C IN  TITRE  : K80 : TITRE POUR ALI_BABA, SUPERTAB ET ENSIGHT
C IN  NBCHAM : I   : NOMBRE DE CHAMP DANS LE TABLEAU CHAM
C IN  CHAM   : K16 : NOM DES CHAMPS A IMPRIMER ( EX 'DEPL', ....
C IN  NBPARA : I   : NOMBRE DE PARAMETRES LE TABLEAU PARA
C IN  PARA   : K16 : NOM DES PARAMETRES A IMPRIMER ( EX 'OMEGA2', ...
C IN  NBORDR : I   : NOMBRE DE NUMEROS D'ORDRE DANS LE TABLEAU ORDR
C IN  ORDR   : I   : LISTE DES NUMEROS D'ORDRE A IMPRIMER
C IN  LRESU  : L   : INDIQUE SI NOMCON EST UN CHAMP OU UN RESULTAT
C IN  MOTFAC : K   : NOM DU MOT CLE FACTEUR
C IN  IOCC   : I   : NUMERO D'OCCURENCE DU MOT CLE FACTEUR
C IN  MODELE : K   : NOM DU MODELE
C IN  CECR   : K1  : CODE D'ECRITURE DES PARAMETRES
C                    'T' TABLEAU 'L' LISTE
C IN  LCOR   : L   : INDIQUE SI IMPRESSION DES COORDONNEES DES NOEUDS
C                    .TRUE.  IMPRESSION
C IN  NBNOT  : I   : NOMBRE DE NOEUDS A IMPRIMER
C IN  NUMNOE : I   : NUMEROS DES NOEUDS A IMPRIMER
C IN  NBMAT  : I   : NOMBRE DE MAILLES A IMPRIMER
C IN  NUMMAI : I   : NUMEROS DES MAILLES A IMPRIMER
C IN  NBCMP  : I   : NOMBRE DE COMPOSANTES A IMPRIMER
C IN  NOMCMP : K8  : NOMS DES COMPOSANTES A IMPRIMER
C IN  LSUP   : L   : =.TRUE. INDIQUE PRESENCE D'UNE BORNE SUPERIEURE
C IN  BORSUP : R   : VALEUR DE LA BORNE SUPERIEURE
C IN  LINF   : L   : =.TRUE. INDIQUE PRESENCE D'UNE BORNE INFERIEURE
C IN  BORINF : R   : VALEUR DE LA BORNE INFERIEURE
C IN  LMAX   : L   : =.TRUE. INDIQUE IMPRESSION VALEUR MAXIMALE
C IN  LMIN   : L   : =.TRUE. INDIQUE IMPRESSION VALEUR MINIMALE
C IN  FORMR  : K   : FORMAT D'ECRITURE DES REELS SUR "RESULTAT"
C IN  LMOD   : L   : INDIQUE SI UN MODELE A ETE INDIQUE
C IN  NIVE   : I   : NIVEAU IMPRESSION CASTEM 3 OU 10
C     ------------------------------------------------------------------
C
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
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
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
C     ------------------------------------------------------------------
      INTEGER      IFIEN1
      PARAMETER   (IFIEN1=31)
      CHARACTER*1  K1BID
      CHARACTER*4  TYCH
      CHARACTER*6  CHNUMO
      CHARACTER*8  NOMCO
      CHARACTER*16 CH16
      CHARACTER*19 NOCH19,KNACC
      CHARACTER*24 NOMST
      LOGICAL      LORDR,LCHABS,LCHAM1
      INTEGER      NBCHCA,NBACC,NBCARA,NORDEN,IORDEN,IORDR1,NUORD1
      INTEGER      LGCONC,NBCHEN,LGCH16
      INTEGER      NBRK16,NBK16,IERD,IBID
      INTEGER LXLGUT
C     ------------------------------------------------------------------
C     --- IMPRESSION D'UN TABLEAU SYNTHETIQUE DES PARAMETRES-----
C         (UNIQUEMENT FORMAT 'RESULTAT')
      CALL JEMARQ()
      IF ( CECR(1:1) .EQ. 'E' ) THEN
         CALL IRPARA(NOMCON,FORM,FICH,NBORDR,ORDR,NBPARA,PARA,'E')
      ELSE
         CALL IRPARA(NOMCON,FORM,FICH,NBORDR,ORDR,NBPARA,PARA,'T')
      ENDIF
C
      NOMST = '&&IRECRI.SOUS_TITRE.TITR'
      NOMCO = NOMCON
C
      IF ( FORM(1:7) .EQ. 'ENSIGHT' ) THEN
        IFI = IFIEN1
      ELSE
        IFI = IUNIFI(FICH)
      ENDIF
C
C     --- RECHERCHE DES OBJETS COMPOSANT LA TABLE CASTEM
C         (UNIQUEMENT FORMAT 'CASTEM')
      IF (FORM.EQ.'CASTEM'.AND.LRESU.AND.NBORDR.NE.0) THEN
        CALL JEEXIN('&&IRECRI.TABLE.TOT',IRET)
        IF(IRET.EQ.0) THEN
          CALL WKVECT('&&IRECRI.TABLE.TOT','V V I',NBORDR*4,JTOT)
        ENDIF
        NBCHCA = 0
        CALL WKVECT('&&IRECRI.CHAM.CASTEM','V V K16',NBCHAM,JCHAM)
        DO 50 ICHA = 1,NBCHAM
          DO 51 IORD = 1,NBORDR
            CALL RSEXCH (NOMCO,CHAM(ICHA),ORDR(IORD),NOCH19,IRET)
            IF (IRET.EQ.0) THEN
              CALL DISMOI('A','TYPE_CHAMP',NOCH19,'CHAMP',IBIB,
     +                TYCH,IERD)
              IF(TYCH(1:4).EQ.'NOEU'.OR.TYCH(1:4).EQ.'ELNO') THEN
                NBCHCA = NBCHCA + 1
                ZK16(JCHAM-1+NBCHCA) = CHAM(ICHA)
                GO TO 50
              ENDIF
            ENDIF
  51      CONTINUE
  50    CONTINUE
        KNACC = '&&IRECRI.NOM_ACCES '
        CALL RSNOPA(NOMCO,0,KNACC,NBACC,IBID)
        CALL JEEXIN(KNACC,IRET)
        IF (IRET.GT.0)  CALL JEVEUO(KNACC,'E',JPARA)
        NBOBJ = NBCHCA + NBACC + 1
      ENDIF
C
C***********************************************************************
C     POUR UN RESULTAT COMPOSE AU FORMAT 'ENSIGHT', L'ECRITURE DU
C     FICHIER "RESULTS" ENSIGHT ET DES FICHIERS DE VALEURS ASSOCIES
C     NECESSITE DE CREER TROIS OBJETS JEVEUX DE TYPE VECTEUR D'ENTIERS.
C     CES OBJETS, DE TAILLE NBCHAM*NBORDR INDIQUENT, POUR UN CHAMP
C     CHAM(ISY) ET UN NUMERO D'ORDRE ORDR(IORDR) :
C     - POUR L'OBJET '&&IRECRI.CHPRES',
C        * SI LE CHAMP EST PRESENT:  0 (1ERE FOIS), 1 SINON
C        * SI LE CHAMP EST ABSENT : -1
C     - POUR L'OBJET '&&IRECRI.FVIDAV', LE NOMBRE DE FICHIERS VIDES DE
C       VALEURS A ECRIRE AVANT LES FICHIERS DE VALEURS DU CHAMP
C     - POUR L'OBJET '&&IRECRI.FVIDAP', LE NOMBRE DE FICHIERS VIDES DE
C       VALEURS A ECRIRE APRES LES FICHIERS DE VALEURS DU CHAMP
C***********************************************************************
      LCHABS=.FALSE.
      IORDR1=1
      IF(FORM(1:7).EQ.'ENSIGHT'.AND.LRESU) THEN
        CALL JEEXIN('&&IRECRI.CHPRES',IRET)
        IF(IRET.NE.0) CALL JEDETR('&&IRECRI.CHPRES')
        CALL WKVECT('&&IRECRI.CHPRES','V V I',NBCHAM*NBORDR,JCPRES)
        CALL JEVEUO('&&IRECRI.CHPRES','E',JCPRES)
        CALL JEEXIN('&&IRECRI.FVIDAV',IRET)
        IF(IRET.NE.0) CALL JEDETR('&&IRECRI.FVIDAV')
        CALL WKVECT('&&IRECRI.FVIDAV','V V I',NBCHAM*NBORDR,JVIDAV)
        CALL JEVEUO('&&IRECRI.FVIDAV','E',JVIDAV)
        CALL JEEXIN('&&IRECRI.FVIDAV',IRET)
        IF(IRET.NE.0) CALL JEDETR('&&IRECRI.FVIDAP')
        CALL WKVECT('&&IRECRI.FVIDAP','V V I',NBCHAM*NBORDR,JVIDAP)
        CALL JEVEUO('&&IRECRI.FVIDAP','E',JVIDAP)
        IORDEN=0
        NORDEN=0
        DO 10 IORDR=1,NBORDR
C       - VERIFICATION CORRESPONDANCE ENTRE NUMERO D'ORDRE
C         UTILISATEUR ORDR(IORDR) ET NUMERO DE RANGEMENT IRET
          CALL RSUTRG(NOMCON,ORDR(IORDR),IRET)
          IF(IRET.EQ.0) THEN
            CALL CODENT(ORDR(IORDR),'G',CHNUMO)
            CALL UTMESS('A','IRECRI',' NUMERO D''ORDRE '//
     +           CHNUMO//' NON LICITE ')
            IF(IORDR.EQ.IORDR1) THEN
              IORDR1=IORDR1+1
              CALL UTMESS('A','IRECRI',' LE NUMERO D''ORDRE'//
     +             ' SUIVANT EST DESORMAIS CONSIDERE COMME LE'//
     +             ' PREMIER NUMERO D''ORDRE DEMANDE')
            ENDIF
            GOTO 10
          ENDIF
          IORDEN=IORDEN+1
          NORDEN=NORDEN+1
          DO 11 ISY=1,NBCHAM
C           - VERIFICATION EXISTENCE DANS LA SD RESULTAT NOMCON
C             DU CHAMP CHAM(ISY) POUR LE NO. D'ORDRE ORDR(IORDR)
            CALL RSEXCH(NOMCON,CHAM(ISY),ORDR(IORDR),NOCH19,IRET)
            ICPRES=JCPRES-1+(IORDEN-1)*NBCHAM+ISY
            IF(IRET.NE.0) THEN
              ZI(ICPRES)=-1
            ELSE
              IF(IORDEN.EQ.1) THEN
                ZI(ICPRES)=0
              ELSE
                IF(ZI(ICPRES-NBCHAM).GE.0) THEN
                  ZI(ICPRES)=1
                ELSE
                  ZI(ICPRES)=0
                ENDIF
              ENDIF
            ENDIF
  11      CONTINUE
  10    CONTINUE
        CALL JEVEUO('&&IRECRI.CHPRES','L',JCPRES)
        DO 12 ISY=1,NBCHAM
          LCHABS=.FALSE.
          DO 13 IORDEN=1,NORDEN
            ICPRES=JCPRES-1+(IORDEN-1)*NBCHAM+ISY
            IVIDAV=JVIDAV-1+(IORDEN-1)*NBCHAM+ISY
            IF(ZI(ICPRES).EQ.-1) THEN
              IF(IORDEN.EQ.1) THEN
                ZI(IVIDAV)=1
              ELSE
                IF(ZI(ICPRES-NBCHAM).EQ.-1) THEN
                  ZI(IVIDAV)=ZI(IVIDAV-NBCHAM)+1
                ELSE
                  IF(.NOT.LCHABS) LCHABS=.TRUE.
                  ZI(IVIDAV)=1
                ENDIF
              ENDIF
            ELSE
              IF(IORDEN.EQ.1) THEN
                ZI(IVIDAV)=0
              ELSE
                ZI(IVIDAV)=ZI(IVIDAV-NBCHAM)
              ENDIF
            ENDIF
  13      CONTINUE
          IF(LCHABS) THEN
            CH16=CHAM(ISY)
            LGCH16=LXLGUT(CH16)
            LGCONC=LXLGUT(NOMCO)
            CALL UTMESS('A','IRECRI',' POUR CERTAINS NUMEROS'//
     +        ' D''ORDRE LE CHAMP '//CH16(1:LGCH16)//
     +        ' N''EST PAS PRESENT DANS LA SD_RESULTAT '//
     +        NOMCO(1:LGCONC)//'==> DES FICHIERS DE VALEURS'//
     +        ' VIDES SERONT GENERES AFIN DE RESPECTER LE'//
     +        ' FORMAT ENSIGHT.')
          ENDIF
  12    CONTINUE
        DO 14 ISY=1,NBCHAM
          LCHABS=.FALSE.
          DO 15 IORDEN=NORDEN,1,-1
            ICPRES=JCPRES-1+(IORDEN-1)*NBCHAM+ISY
            IVIDAP=JVIDAP-1+(IORDEN-1)*NBCHAM+ISY
            IF(ZI(ICPRES).EQ.-1) THEN
              IF(IORDEN.EQ.NORDEN) THEN
                ZI(IVIDAP)=1
              ELSE
                IF(ZI(ICPRES+NBCHAM).EQ.-1) THEN
                  IF(ZI(IVIDAP+NBCHAM).GT.0) THEN
                    ZI(IVIDAP)=ZI(IVIDAP+NBCHAM)+1
                  ELSE
                    ZI(IVIDAP)=0
                  ENDIF
                ELSE
                  ZI(IVIDAP)=0
                ENDIF
              ENDIF
            ELSE
              IF(IORDEN.EQ.NORDEN) THEN
                ZI(IVIDAP)=0
              ELSE
                IF(ZI(ICPRES+NBCHAM).EQ.-1) THEN
                  ZI(IVIDAP)=ZI(IVIDAP+NBCHAM)
                ELSE
                  ZI(IVIDAP)=0
                ENDIF
              ENDIF
            ENDIF
  15      CONTINUE
  14    CONTINUE
      ENDIF
C
C     --------------------------
C     TRAITEMENT DU FORMAT GMSH
C     -------------------------
C
      IF (FORM .EQ. 'GMSH') THEN
      
         CALL IRGMSH ( NOMCON, IFI, NBCHAM, CHAM, LRESU, NBORDR, ORDR,
     +                 NBCMP, NOMCMP, NBMAT, NUMMAI,IOCC )
C
C     -----------------------------
C     TRAITEMENT DES AUTRES FORMATS
C     -----------------------------
C
      ELSE
C
C     *******************************************
C     --- BOUCLE SUR LA LISTE DES NUMEROS D'ORDRE
C     *******************************************
      IORDEN=0
      NUORD1=ORDR(IORDR1)
      NBRK16 = 0
C
      DO 21 IORDR = 1,NBORDR
C       --- FORMAT 'CASTEM'
        IF(FORM.EQ.'CASTEM'.AND.LRESU) THEN
          CALL IRPACA(NOMCON,IFI,NBORDR,IORDR,ORDR,NBACC,
     +          ZK16(JPARA),NBCHCA,ZK16(JCHAM),NBK16,NIVE)
          NBRK16 = NBRK16 + NBK16
        ENDIF
C
C       --- SI VARIABLE DE TYPE RESULTAT = RESULTAT COMPOSE :
C           VERIFICATION CORRESPONDANCE ENTRE NUMERO D'ORDRE
C           UTILISATEUR ORDR(IORDR) ET NUMERO DE RANGEMENT IRET
C           (SAUF AU FORMAT 'ENSIGHT' CAR VERIFICATION DEJA FAITE)
        IF(LRESU.AND.(FORM(1:7).NE.'ENSIGHT')) THEN
          CALL RSUTRG(NOMCON,ORDR(IORDR),IRET)
          IF(IRET.EQ.0) THEN
C           - MESSAGE NUMERO D'ORDRE NON LICITE
            CALL CODENT(ORDR(IORDR),'G',CHNUMO)
            CALL UTMESS('A','IRECRI',' NUMERO D''ORDRE '//
     +                                 CHNUMO//' NON LICITE ')
            GOTO 21
          ENDIF
          LORDR=.TRUE.
        ENDIF
C
C       --- BOUCLE SUR LE NOMBRE DE CHAMPS A IMPRIMER
        IORDEN=IORDEN+1
        NBCHEN=0
        LCHAM1=.FALSE.
        IF(NBCHAM.NE.0) THEN
          DO 20 ISY = 1,NBCHAM
            IF( LRESU ) THEN
C           * RESULTAT COMPOSE
C             - VERIFICATION EXISTENCE DANS LA SD RESULTAT NOMCON
C               DU CHAMP CHAM(ISY) POUR LE NO. D'ORDRE ORDR(IORDR)
C               ET RECUPERATION DANS NOCH19 DU NOM SE LE CHAM_GD EXISTE
              CALL RSEXCH(NOMCON,CHAM(ISY),ORDR(IORDR),NOCH19,IRET)
              IF(IRET.NE.0) THEN
C               - ON PASSE AU CHAMP SUIVANT
C-DEL           CALL UTDEBM('I','IMPRESSION','LE CHAMP ')
C-DEL           CALL UTIMPK('S',' ',1,CHAM(ISY))
C-DEL           CALL UTIMPK('S',CHAM(ISY),1,NOCH19)
C-DEL           CALL UTIMPK('S',' N''EXISTE PAS',0,' ')
C-DEL           CALL UTFINM()
                GOTO 20
              ENDIF
              IF((FORM(1:7).EQ.'ENSIGHT').AND.
     +                                   (NBCHEN.EQ.0)) LCHAM1=.TRUE.
              NBCHEN=NBCHEN+1
            ELSE
C           * CHAM_GD
              NOCH19 = NOMCON
            ENDIF
C
C           * IMPRESSION DES PARAMETRES (FORMAT 'RESULTAT')
            IF (LORDR.AND.FORM.EQ.'RESULTAT')  THEN
C             - SEPARATION DES DIVERS NUMEROS D'ORDRE PUIS IMPRESSION
              WRITE(IFI,'(/,1X,A)') '======>'
              CALL IRPARA(NOMCON,FORM,FICH,1,ORDR(IORDR),NBPARA,
     +                                                       PARA,CECR)
              LORDR=.FALSE.
            ENDIF
C           * CREATION D'UN SOUS-TITRE
            IF(FORM.EQ.'RESULTAT'.OR.FORM.EQ.'IDEAS') THEN
               CALL TITRE2(NOMCON,NOCH19,NOMST,MOTFAC,IOCC)
            ENDIF
C
C           * IMPRESSION DU SOUS-TITRE SI FORMAT 'RESULTAT'
            IF(FORM.EQ.'RESULTAT') THEN
C              ---- SEPARATION DES DIVERS CHAMPS -----
               WRITE(IFI,'(/,1X,A)') '------>'
               CALL JEVEUO(NOMST,'L',JTITR)
               CALL JELIRA(NOMST,'LONMAX',NBTITR,K1BID)
               WRITE(IFI,'(1X,A)') (ZK80(JTITR+I-1),I=1,NBTITR)
            ENDIF
C
C           ********************************************************
C           * IMPRESSION DU CHAMP (CHAM_NO OU CHAM_ELEM) AU FORMAT
C             'RESULTAT' , 'SUPERTAB' OU 'ENSIGHT'
C                LE CHAMP EST UN CHAM_GD SIMPLE SI LRESU=.FALSE. OU
C                LE CHAMP EST LE CHAM_GD CHAM(ISY) DE NUMERO D'ORDRE
C                ORDR(IORDR) ISSU DE LA SD_RESULTAT NOMCON
            CALL IRCH19(NOCH19,FORM,FICH,TITRE,MODELE,
     >        NOMCON,NOSIMP,NOPASE,
     >        CHAM(ISY),ORDR(IORDR),NUORD1,NORDEN,IORDEN,NBCHAM,ISY,
     >        LCHAM1,LCOR,NBNOT,NUMNOE,NBMAT,NUMMAI,NBCMP,NOMCMP,
     >        LSUP,BORSUP,LINF,BORINF,LMAX,LMIN,LRESU,FORMR,
     >        NIVE )
            IF(LCHAM1) LCHAM1=.FALSE.
   20     CONTINUE
        ENDIF
C
C       --- IMPRESSION  DE LA TABLE SI FORMAT 'CASTEM'
        IF (FORM.EQ.'CASTEM'.AND.LRESU.AND.NBORDR.NE.0) THEN
          CALL JEVEUO('&&IRPACA.TABL.CASTEM','L',JTABL)
          CALL JEVEUO('&&OP0039.LAST','E',JLAST)
          NBCARA = 4*NBOBJ
          ITYPE = 10
          IVSI  = 26
          ZI(JTOT-1+(IORDR-1)*4+1)= IVSI
          ZI(JTOT-1+(IORDR-1)*4+2)= ZI(JLAST-1+7)+IORDR*2-1
          ZI(JTOT-1+(IORDR-1)*4+3)= ITYPE
          ZI(JTOT-1+(IORDR-1)*4+4)= ZI(JLAST-1+6)*2+1
          IUN   =  1
          IDEU  =  2
          ITYPE = 10
          WRITE (IFI,'(A,I4)')   ' ENREGISTREMENT DE TYPE',IDEU
          IF (NIVE.EQ.3) THEN
              WRITE (IFI,'(A,I4,A,I4,A,I4)')  ' PILE NUMERO',ITYPE,
     +        'NBRE OBJETS NOMMES ',IUN,'NBRE OBJETS ',IDEU
          ELSE IF (NIVE.EQ.10) THEN
              WRITE (IFI,'(A,I4,A,I8,A,I8)')  ' PILE NUMERO',ITYPE,
     +        'NBRE OBJETS NOMMES',IUN,'NBRE OBJETS',IDEU
          ENDIF
          CALL LXCAPS(NOMCO)
          WRITE(IFI,'(1X,A8)') NOMCO
          IF (NIVE.EQ.3) THEN
             WRITE(IFI,'(I5)') ZI(JLAST-1+6)*2+2
             WRITE(IFI,'(I5)') NBCARA
             WRITE(IFI,'(16I5)') (ZI(JTABL-1+I),I=1,NBOBJ*4)
             WRITE(IFI,'(I5)') 4*IORDR
             WRITE(IFI,'(16I5)') (ZI(JTOT-1+I),I=1,IORDR*4)
          ELSEIF (NIVE.EQ.10) THEN
             WRITE(IFI,'(I8)') ZI(JLAST-1+6)*2+2
             WRITE(IFI,'(I8)') NBCARA
             WRITE(IFI,'(10I8)') (ZI(JTABL-1+I),I=1,NBOBJ*4)
             WRITE(IFI,'(I8)') 4*IORDR
             WRITE(IFI,'(10I8)') (ZI(JTOT-1+I),I=1,IORDR*4)
          ENDIF
          ZI(JLAST-1+6) = ZI(JLAST-1+6) + 1
          CALL JEDETR('&&IRPACA.TABL.CASTEM')
        ENDIF
   21 CONTINUE
C
      IF(LRESU.AND.FORM.EQ.'CASTEM'.AND.NBORDR.NE.0) THEN
         ZI(JLAST-1+7) = ZI(JLAST-1+1)
         ZI(JLAST-1+8) = ZI(JLAST-1+8) + NBOBJ + NBRK16
         ZI(JLAST-1+3) = ZI(JLAST-1+3) + NBOBJ
      ENDIF
C
      ENDIF
C
C     --- DESTRUCTION OBJETS DE TRAVAIL
      CALL JEDETR('&&IRECRI.CHPRES')
      CALL JEDETR('&&IRECRI.FVIDAV')
      CALL JEDETR('&&IRECRI.FVIDAP')
      CALL JEDETR('&&IRECRI.NOM_ACC')
      CALL JEDETR('&&IRPACA.TABL.CASTEM')
      CALL JEDETR('&&IRECRI.CHAM.CASTEM')
      CALL JEDETR('&&IRECRI.TABLE.TOT')
      CALL JEEXIN(NOMST,IRET)
      IF(IRET.NE.0) CALL JEDETR(NOMST)
C
      CALL JEDEMA()
      END
