      SUBROUTINE LRMAST ( NOMU,NOMMAI,NOMNOE,COOVAL,COODSC,COOREF,
     >                    GRPNOE,GRPMAI,CONNEX,TITRE,TYPMAI,ADAPMA,
     >                    IFM,IFL,NIV,NBNOEU,NBMAIL,NBCOOR )
      IMPLICIT REAL*8 (A-H,O-Z)
C     IN
      INTEGER         IFM,    IFL,    NIV
      CHARACTER*24    COOVAL, COODSC, COOREF, GRPNOE, GRPMAI, CONNEX
      CHARACTER*24    TITRE,  NOMMAI, NOMNOE, TYPMAI
      CHARACTER*24    ADAPMA
      CHARACTER*8     NOMU
C     OUT
      INTEGER         NBNOEU,NBMAIL,NBCOOR
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 11/09/2002   AUTEUR VABHHTS J.PELLET 
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
C TOLE CRP_20
C     ------------------------------------------------------------------
C     LECTURE DU FICHIER MAILLAGE AU FORMAT ASTER
C
C  REMARQUES ET RESTRICTIONS D UTILISATION
C
C               - ON VERIFIE LA PRESENCE D'UN ITEM  LORSQUE CELUI CI
C                 EST ATTENDU ( ORDRE LOGIQUE DE LA SEQUENCE A LIRE )
C
C               - ON TESTE LA PRESENCE D UN ITEM LORSQUE CELUI CI EST
C                 EVENTUEL ( MOT CLE A LIRE )
C
C               - LES MOTS CLES SONT A PRIORI TOUS RESERVES, MAIS
C                 IL N Y A PAS VERIFICATION A TOUT INSTANT DE LA
C                 PRESENCE D'UN MOT CLE SAUF POUR FIN ET FINSF
C
C               - ON IMPOSE QUE LES MOTS CLES SE TROUVENT EN DEBUT DE
C                 LIGNE (PREMIERE POSITION DANS L ENREGISTREMENT)
C
C               - ON  IMPOSE QUE LES DONNEES COMMENCENT  EN DEBUT DE
C                 LIGNE POUR CHAQUE REPETITION DU FORMAT
C
C               - AUCUN MOT NE DEPASSE 8 CARACTERES (SAUF DANS LES
C                 COMMENTAIRES)
C               - LES MINUSCULES SONT RELEVEES EN MAJUSCULES
C
C               - TOUT TEXTE APRES LE CARACTERE RESERVE % EST CONSIDERE
C                 COMME DU COMMENTAIRE ET EST IGNORE JUSQU EN FIN
C                 DE LIGNE
C
C               - UNE LIGNE FAIT 80 CARACTERES > TRONCATURE A 80 SI
C                 LA LONGUEUR D ENREGISTREMENT DEPASSE CETTE VALEUR :
C                 ATTENTION LORS DE L EDITION DE FICHIERS MAILLAGES AVEC
C                 VI OU TEXTEDIT SUR SUN
C
C               - LE BLANC EST SEPARATEUR MAIS NON SIGNIFICATIF
C
C
C
C  NOMENCLATURE
C
C       XXX             TYPE DE MOT CLE (LIE AU MODE DE STOCKAGE JEVEUX)
C                       = TIT > TYPE TITRE
C                       = GRP > TYPE GROUPE
C                       = COO > TYPE COORDONNEES
C                       = MAI > TYPE MAILLE
C                       = DBG > TYPE DEBUG (ASSISTANCE)
C
C  DESCRIPTION DES ROUTINES
C
C       LECXXX          PREMIERE LECTURE DE VERIFICATION DES DONNEES ET
C                       DE DIMENSIONNEMENT DES OBJETS JEVEUX POUR LES
C                       MOTS CLES DU TYPE XXX
C
C       STKXXX          DEUXIEME LECTURE ET STOCKAGE DES DONNEES SUR
C                       LES BASES POUR LES MOTS CLES DU TYPE XXX
C
C       TESFIN          TESTE L OCCURENCE DES MOTS CLES FIN ET FINSF
C
C       TESMCL          TESTE LA PRESENCE D UN MOT CLE
C
C       VERMOT          VERIFIE LA PRESENCE ATTENDUE D UN MOT
C
C       VERNMB          VERIFIE LA PRESENCE ATTENDUE D UN NOMBRE
C
C       VERDBL          VERIFIE QUE L ITEM LU EST EN DEBUT DE LIGNE
C
C       LIRITM          RECHERCHE DE  L ITEM SUIVANT
C
C       LIRLIG          LECTURE DE LA LIGNE SUIVANTE
C
C  DESCRIPTION DES PRINCIPALES VARIABLES
C
C
C       NBMXXX          NOMBRE DE MOTS CLES DU TYPE XXX
C       NBTXXX          NOMBRE TOTAL D ITEMS LUS POUR CHAQUE MOT CLE  DU
C                       TYPE XXX
C       DIMXXX          NOMBRE D ELEMENTS    LUS POUR CHAQUE MOT CLE  DU
C                       TYPE XXX
C
C       FMTXXX          NOMBRE D ITEMS A LIRE POUR CHAQUE ELEMENT DE
C                       CHAQUE MOT CLE DU TYPE XXX
C       MCLXXX          LISTE DES MOT CLES DU TYPE XXX
C
C       NBCOOR          NOMBRE DE COORDONNEES
C       NBMAIL          NOMBRE DE MAILLES
C       NBNOEU          NOMBRE DE NOEUDS
C       NBLTIT          NOMBRE DE LIGNES DE TITRE
C       NBGRNO          NOMBRE DE GROUPES NOEUDS
C       NBGRMA          NOMBRE DE GROUPES MAILLES
C
C       NBNOMA          NOMBRE TOTAL DE NOEUDS LUS DANS MAILLE
C       NBNOGN          NOMBRE TOTAL DE NOEUDS LUS DANS  GROUPE NOEUD
C       NBMAGM          NOMBRE TOTAL DE MAILLES LUES DANS GROUPE MAILLE
C
C       COOVAL          NOM DE L OBJET CHAMP DE GEOMETRIE (VALEURS)
C       COODSC          NOM DE L OBJET CHAMP DE GEOMETRIE (DESCRIPTEUR)
C       COOREF          NOM DE L OBJET CHAMP DE GEOMETRIE (NOM MAILLAGE)
C       GRPNOE          NOM DE L OBJET GROUPE NOEUDS
C       GRPMAI          NOM DE L OBJET GROUPE MAILLES
C       CONNEX          NOM DE L OBJET CONNECTIVITES
C       NOMMAI          NOM DE L OBJET REPERTOIRE DES MAILLES
C       NOMNOE          NOM DE L OBJET REPERTOIRE DES NOEUDS
C       TITRE           NOM DE L OBJET TITRE
C       GRPNOV          NOM DE L OBJET GROUPE NOEUDS  (BASE V)
C       GRPMAV          NOM DE L OBJET GROUPE MAILLES (BASE V)
C       CONXV           NOM DE L OBJET CONNECTIVITES  (BASE V)
C
C-----------------------------------------------------------------------
C
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER            ZI
      COMMON  / IVARJE / ZI(1)
      REAL*8             ZR
      COMMON  / RVARJE / ZR(1)
      COMPLEX*16         ZC
      COMMON  / CVARJE / ZC(1)
      LOGICAL            ZL
      COMMON  / LVARJE / ZL(1)
      CHARACTER*8        ZK8
      CHARACTER*16                ZK16
      CHARACTER*24                          ZK24
      CHARACTER*32                                    ZK32
      CHARACTER*80                                              ZK80
      COMMON  / KVARJE / ZK8(1) , ZK16(1) , ZK24(1) , ZK32(1) , ZK80(1)
      CHARACTER*32       JEXNOM, JEXNUM
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
C
C ----- DECLARATIONS
C
        PARAMETER       (NBMTIT  = 1  )
        PARAMETER       (NBMGRP  = 2  )
        PARAMETER       (NBMCOO  = 3  )
        PARAMETER       (NBMMAX  = 100)
        PARAMETER       (NBMDBG  = 2  )
        PARAMETER       (NBMINT  = 7  )
C
        INTEGER         DIMTIT(NBMTIT), DIMGRP(NBMGRP)
        INTEGER         DIMMAI(NBMMAX), DIMCOO(NBMCOO)
        INTEGER         DIMDBG(NBMDBG)
        INTEGER         NBTTIT(NBMTIT), NBTGRP(NBMGRP)
        INTEGER         NBTMAI(NBMMAX), NBTCOO(NBMCOO)
        INTEGER         DEBLIG
        INTEGER         FMTMAI(NBMMAX)
C
        REAL*8          RV
C
        CHARACTER*1     K1BID
        CHARACTER*4     DIMESP
        CHARACTER*8     MCLTIT(NBMTIT), MCLGRP(NBMGRP)
        CHARACTER*8     MCLMAI(NBMMAX), MCLCOO(NBMCOO)
        CHARACTER*8     MCLDBG(NBMDBG), MCLINT(NBMINT)
        CHARACTER*8     NOM, TYPE, NOMG, NOMN
        CHARACTER*8     NOM1
        CHARACTER*14    CNL
        CHARACTER*16    CMD
        CHARACTER*24    GRPNOV, GRPMAV, CONXV
        CHARACTER*24    NOMDBG(50,NBMDBG)
        CHARACTER*80    CV,     DAT
C
        COMMON          /OPMAIL/        CMD
C
        DATA DAT        /' '/
        DATA MCLTIT     /'TITRE   '/
        DATA MCLGRP     /'GROUP_NO','GROUP_MA'/
        DATA MCLCOO     /'COOR_1D ','COOR_2D ','COOR_3D '/
        DATA MCLDBG     /'DUMP    ','DEBUG   '/
        DATA MCLINT     /'GROUP_FA','SYS_UNIT','SYS_COOR','MACRO_AR',
     >                   'MACRO_FA','MACRO_EL','MATERIAU'/
C
C ---   INITIALISATION DU NB D'ERREUR
C
        IER = 0
        CALL ASOPEN ( IFL, ' ' )
C
        CALL JEMARQ ( )
C
C  1    CONSTRUCTION DES NOMS JEVEUX POUR L OBJET-MAILLAGE
C       --------------------------------------------------
C
C
        CONXV   = NOMU//'.CONXV'
        GRPNOV  = NOMU//'.GROUPNOV'
        GRPMAV  = NOMU//'.GROUPMAV'
C
C
C  2    PREMIERE LECTURE DE DIMENSIONNEMENT DES OBJETS
C       ----------------------------------------------
C
        NBCOOR    =  0
        NBMAIL    =  0
        NBNOMA    =  0
        NBG       = -1
C
        DO 2 I = 1,NBMTIT
           NBTTIT(I) = 0
           DIMTIT(I) = 0
 2      CONTINUE
        DO 3 I = 1,NBMGRP
           NBTGRP(I) = 0
           DIMGRP(I) = 0
 3      CONTINUE
        DO 4 I = 1,NBMCOO
           NBTCOO(I) = 0
           DIMCOO(I) = 0
 4      CONTINUE
        DO 5 I = 1,NBMMAX
           FMTMAI(I) = 0
           NBTMAI(I) = 0
           DIMMAI(I) = 0
 5      CONTINUE
        DO 3000 I = 1,NBMDBG
           DIMDBG(I) = 0
 3000   CONTINUE
C
C -     LECTURE DES NOMS/NBNO DES TYPES DE MAILLES DANS LE CATALOGUE
C
      CALL JELIRA('&CATA.TM.NOMTM','NOMMAX',NBMMAI,K1BID)
      IF ( NBMMAI .GT. NBMMAX ) THEN
         CALL UTMESS ( 'F',CMD,'ERREUR FORTRAN DE DIMENSIONNEMENT'//
     &                                   ' DE TABLEAU (NBMMAI>NBMMAX)')
      ENDIF
      DO 7 I = 1,NBMMAI
         CALL JENUNO (JEXNUM('&CATA.TM.NOMTM',I),MCLMAI(I))
         CALL JEVEUO (JEXNUM('&CATA.TM.NBNO' ,I),'L',INBN)
         FMTMAI(I) = ZI(INBN)
  7   CONTINUE
C
C -     LECTURE PREMIER ITEM  EN DEBUT DE LIGNE SUIVANTE
C
  9     CONTINUE
        DEBLIG    = -1
        CALL LIRITM(IFL,IFM,ICL,IV,RV,CV,CNL,DEBLIG,1)
C
C -     ITEM = MOT CLE FIN , FINSF , AUTRE ?
C
        CALL TESFIN(ICL,IV,CV,IRTET)
        IF ( IRTET.GT.0 ) GOTO (8,9), IRTET
C
C -     PREMIERE LECTURE DES DONNEES POUR CHAQUE TYPE DE MOT CLE
C
        CALL LECDBG(IFL,ICL,IV,RV,CV,CNL,MCLDBG,NBMDBG,NBG,
     >              DIMDBG,NOMDBG,IER,IRTET)
        IF ( IRTET.GT.0 ) GOTO (8,9), IRTET
C
        CALL LECTIT(IFL,ICL,IV,RV,CV,CNL,MCLTIT,NBMTIT,NBG,
     >              DIMTIT,NBTTIT,IER,IRTET)
        IF ( IRTET.GT.0 ) GOTO (8,9), IRTET
C
        CALL LECGRP(IFL,ICL,IV,RV,CV,CNL,MCLGRP,NBMGRP,NBG,
     >              DIMGRP,NBTGRP,IER,IRTET)
        IF ( IRTET.GT.0 ) GOTO (8,9), IRTET
C
        CALL LECCOO(IFL,ICL,IV,RV,CV,CNL,MCLCOO,NBMCOO,NBG,
     >              DIMCOO,NBTCOO,IER,IRTET)
        IF ( IRTET.GT.0 ) GOTO (8,9), IRTET
C
        CALL LECMAI(IFL,ICL,IV,RV,CV,CNL,MCLMAI,NBMMAI,NBG,FMTMAI,
     >              DIMMAI,NBTMAI,IER,IRTET)
        IF ( IRTET.GT.0 ) GOTO (8,9), IRTET
C
        CALL LECINT(IFL,ICL,IV,RV,CV,CNL,MCLINT,NBMINT,NBG,IER,IRTET)
        IF ( IRTET.GT.0 ) GOTO (8,9), IRTET
C
C -     DIMENSIONS GLOBALES DES OBJETS
C
C -     DIMENSION ESPACE        (NB COORDONNEES)
C
 8      CONTINUE
        DO 99 I = 1,NBMCOO
           IF(DIMCOO(I).NE.0)NBCOOR = I
 99     CONTINUE
C
C -     DIMENSION CONNEX        (NB MAILLES)
C
        DO 100 I = 1,NBMMAI
           NBMAIL   = NBMAIL + DIMMAI(I)
 100    CONTINUE
C
C -     DIMENSION COORDO        (NB NOEUDS)
C
        IF(NBCOOR.EQ.0) NBNOEU = 0
        IF(NBCOOR.NE.0) NBNOEU = DIMCOO(NBCOOR)
C
C -     DIMENSION GROUPENO      (NB DE GROUPES DE NOEUDS)
C
        NBGRNO   = DIMGRP(1)
C
C -      DIMENSION GROUPEMA     (NB DE GROUPES DE MAILLES)
C
        NBGRMA   = DIMGRP(2)
C
C -     DIMENSION TITRE (NB DE LIGNES DU TITRE)
C
        NBLTIT   = DIMTIT(1)
C
C -     NOMBRE TOTAL DE NOEUDS LUS DANS LE TYPE MAILLE
C
        DO 98 I = 1 , NBMMAI
        NBNOMA = NBNOMA + NBTMAI(I)
 98     CONTINUE
C
C -     NOMBRE TOTAL DE NOEUDS LUS DANS LES GROUPES NOEUDS
C
        NBNOGN = NBTGRP(1)
C
C -     NOMBRE TOTAL DE MAILLES LUES DANS  LES GROUPES MAILLES
C
        NBMAGM = NBTGRP(2)
C
C -     DEBUG
C
        IF(NBG.GE.0)THEN
                CALL JEDBUG(1)
                WRITE(IFM,*)'NBCOOR = ',NBCOOR
                WRITE(IFM,*)'NBMAIL = ',NBMAIL
                WRITE(IFM,*)'NBNOEU = ',NBNOEU
                WRITE(IFM,*)'NBGRNO = ',NBGRNO
                WRITE(IFM,*)'NBGRMA = ',NBGRMA
                WRITE(IFM,*)'NBLTIT = ',NBLTIT
                WRITE(IFM,*)'NBNOMA = ',NBNOMA
                WRITE(IFM,*)'NBNOGN = ',NBNOGN
                WRITE(IFM,*)'NBMAGM = ',NBMAGM
                WRITE(IFM,*)' '
                DO 1001 I=1,NBMCOO
                WRITE(IFM,*)'DIMCOO ',I,' = ',DIMCOO(I)
 1001           CONTINUE
                DO 1002 I=1,NBMMAI
                WRITE(IFM,*)'DIMMAI ',I,' = ',DIMMAI(I)
 1002           CONTINUE
                DO 1003 I=1,NBMGRP
                WRITE(IFM,*)'DIMGRP ',I,' = ',DIMGRP(I)
 1003           CONTINUE
                DO 1004 I=1,NBMTIT
                WRITE(IFM,*)'DIMTIT ',I,' = ',DIMTIT(I)
 1004           CONTINUE
                WRITE(IFM,*)'-------- FIN DEBUG -------------------'
        ENDIF
C
C -     FIN  DE LECTURE DU FICHIER
C
        IF(NBNOEU.EQ.0)THEN
        CALL UTMESS('E',CMD,'LECTURE 1 : IL MANQUE LES COORDONNEES !')
        IER = 1
        ENDIF
        IF(NBMAIL.EQ.0)THEN
        CALL UTMESS('E',CMD,'LECTURE 1 : IL MANQUE LES MAILLES !')
        IER = 1
        ENDIF
C
        IF(IER.EQ.1)THEN
        CALL UTMESS('F',CMD,'LECTURE 1 : ERREUR DE SYNTAXE DETECTEE')
        ENDIF
C
C
C  3    CREATION  DES OBJETS TEMPORAIRES A TRANSCODER SUR LA VOLATILE
C       ET DES OBJETS PERMANENTS NON TRANSCODABLES SUR LA GLOBALE
C       -------------------------------------------------------------
C
C -     OBJET NOMMAI    = REPERTOIRE NOMS DE MAILLES  K8 SUR GLOBALE
C
        CALL JECREO(NOMMAI,'G N K8')
        CALL JEECRA(NOMMAI,'NOMMAX',NBMAIL,' ')
C
C -     OBJET NOMNOE    = REPERTOIRE NOMS DE NOEUDS K8 SUR GLOBALE
C
        CALL JECREO(NOMNOE,'G N K8')
        CALL JEECRA(NOMNOE,'NOMMAX',NBNOEU,' ')
C
C
        NBGRMP = NBGRMA
        NBGRNP = NBGRNO
C
C -     OBJET TITRE             = VECTEUR DE K80
C
        CALL JECREO(TITRE,'G V K80')
        IF ( NBLTIT .NE. 0 ) THEN
           CALL JEECRA(TITRE,'LONMAX',NBLTIT,' ')
        ELSE
           NBLTIT = 1
           CALL JEECRA(TITRE,'LONMAX',1,' ')
           CALL JEVEUO(TITRE,'E',IAD)
           CALL ENLIRD(DAT)
           ZK80(IAD)=DAT
        ENDIF
C
C -     OBJET TYPMAIL   = FAMILLE CONTIGUE D'ELEMENTS I (NUM TYPE ELE)
C                         POINTEUR DE NOM       = NOMMAI
C
        CALL WKVECT(TYPMAI,'G V I',NBMAIL,IBID)
C
C -     CHAMPS DE GEOMETRIE AUX NOEUDS
C
C -     OBJET COORDO.VALE = VECTEUR DE R8 CONTENANT LES COORDONNEES
C
        CALL JECREO(COOVAL,'G V R')
        CALL JEECRA(COOVAL,'LONMAX',NBNOEU*3,' ')
        CALL CODENT(NBCOOR,'G',DIMESP)
        CALL JEECRA(COOVAL,'DOCU',0,DIMESP)
C
C -     OBJET COORDO.DESC = VECTEUR 3*IS DESCRIPTEUR DU CHAMP
C
C -     RECUPERATION DU NUMERO IDENTIFIANT LE TYPE DE CHAM_NO GEOMETRIE
C
        CALL JENONU(JEXNOM('&CATA.GD.NOMGD','GEOM_R'),NTGEO)
C
        CALL JECREO(COODSC,'G V I')
        CALL JEECRA(COODSC,'LONMAX',3,' ')
        CALL JEECRA(COODSC,'DOCU',0,'CHNO')
        CALL JEVEUO(COODSC,'E',IAD)
        ZI(IAD)   =  NTGEO
        ZI(IAD+1) = -3
        ZI(IAD+2) = 14
C
C -     OBJET COORDO.REFE = VECTEUR 2*K24 NOM DU MAILLAGE !!!
C
        CALL WKVECT(COOREF,'G V K24',2,IAD)
        ZK24(IAD) = NOMU
C
C -     OBJET GROUPNOV  = FAMILLES CONTIGUES DE VECTEURS N*K8 VOLATILE
C                         POINTEUR DE NOM       = GROUPNOV.$$NOM
C                         POINTEUR DE LONGUEUR  = GROUPNOV.$$LONC
C                         LONGUEUR TOTALE       = NBNOGN
C
      IF ( NBGRNO .NE. 0 ) THEN
         CALL JECREC(GRPNOV,'V V K8','NO','CONTIG','VARIABLE',NBGRNO)
         CALL JEECRA(GRPNOV,'LONT',NBNOGN,' ')
      ENDIF
C
C -      OBJET GROUPMAV = FAMILLE CONTIGUE DE VECTEURS N*K8 VOLATILE
C                         POINTEUR DE NOM       = GROUPMAV.$$NOM
C                         POINTEUR DE LONGUEUR  = GROUPMAV.$$LONC
C                         LONGUEUR TOTALE       = NBMAGM
C
      IF ( NBGRMA .NE. 0 )THEN
         CALL JECREC(GRPMAV,'V V K8','NO','CONTIG','VARIABLE',NBGRMA)
         CALL JEECRA(GRPMAV,'LONT',NBMAGM,' ')
      ENDIF
C
C -     OBJET CONXV     = FAMILLE CONTIGUE DE VECTEURS N*K8 VOLATILE
C                         POINTEUR DE NOM       = CONXV.$$NOM
C                         POINTEUR DE LONGUEUR  = CONXV.$$LONC
C                         LONGUEUR TOTALE       = NBNOMA
C
        CALL JECREC(CONXV,'V V K8','NO','CONTIG','VARIABLE',NBMAIL)
        CALL JEECRA(CONXV,'LONT',NBNOMA,' ')
C
C -     OBJET GROUPENO   = FAMILLE DISPERSEE DE VECTEURS N*IS
C                         POINTEUR DE LONGUEUR  = GROUPENO.$$LONC
C                         LONGUEUR TOTALE       = NBNOGN
C
      IF ( NBGRNO .NE. 0 ) THEN
         CALL JECREC(GRPNOE,'G V I','NO','DISPERSE','VARIABLE',NBGRNP)
      ENDIF
C
C -     OBJET GROUPEMA  = FAMILLE CONTIGUE DE VECTEURS N*IS
C                         POINTEUR DE LONGUEUR  = GROUPEMA.$$LONC
C                         LONGUEUR TOTALE       = NBMAGM
C
      IF ( NBGRMA .NE. 0 )THEN
         CALL JECREC(GRPMAI,'G V I','NO','DISPERSE','VARIABLE',NBGRMP)
      ENDIF
C
C -     OBJET CONNEX    = FAMILLE CONTIGUE DE VECTEURS N*IS
C                         POINTEUR DE NOM       = NOMMAI
C                         POINTEUR DE LONGUEUR  = CONNEX.$$LONC
C                         LONGUEUR TOTALE       = NBNOMA
C
      CALL JECREC(CONNEX,'G V I','NU','CONTIG','VARIABLE',NBMAIL)
      CALL JEECRA(CONNEX,'LONT',NBNOMA,' ')
C
C -     OBJET ADAPMA   = INFORMATION SUR L'ADAPTATION DE MAILLAGE
C
        CALL WKVECT(ADAPMA,'G V I',1,IAD)
        ZI(IAD)   =  0
C
C
C  4    SECONDE LECTURE DU FICHIER MAILLAGE POUR STOCKAGE DES OBJETS
C       ------------------------------------------------------------
C
C       REMBOBINAGE DU FICHIER
C
        REWIND(IFL)
C
C -     LECTURE PREMIER ITEM EN DEBUT DE LIGNE
C
        NUMLTI = 0
        NUMNEU = 0
        NUMELE = 0
        NUMNOD = 0
        NUMGRN = 0
        NUMGRM = 0
C
  900   CONTINUE
        DEBLIG    = -1
        CALL LIRITM(IFL,IFM,ICL,IV,RV,CV,CNL,DEBLIG,2)
C
C -     ITEM = MOT CLE  FIN OU FINSF OU AUTRE ?
C
        CALL TESFIN(ICL,IV,CV,IRTET)
        IF ( IRTET.GT.0 ) GOTO (800,900), IRTET
C
C -     STOCKAGE DES DONNEES POUR CHAQUE TYPE DE  MOT CLE
C
        CALL STKTIT(IFL,ICL,IV,RV,CV,CNL,MCLTIT,NBMTIT,NUMLTI,
     >  TITRE,DIMTIT,IRTET)
        IF ( IRTET.GT.0 ) GOTO (800,900), IRTET
C
        CALL STKCOO ( IFL, ICL, IV, RV, CV, CNL, MCLCOO, NBMCOO, NUMNEU,
     >                COOVAL, NOMNOE, DIMCOO, IRTET )
        IF ( IRTET.GT.0 ) GOTO (800,900), IRTET
C
        CALL STKGRP(IFL,ICL,IV,RV,CV,CNL,MCLGRP,NBMGRP,NUMGRN,NUMGRM,
     >  GRPNOV,GRPMAV,DIMGRP,IRTET)
        IF ( IRTET.GT.0 ) GOTO (800,900), IRTET
C
        CALL STKMAI(IFL,ICL,IV,RV,CV,CNL,MCLMAI,NBMMAI,NUMELE,NUMNOD,
     >  CONXV,TYPMAI,FMTMAI,DIMMAI,IRTET)
        IF ( IRTET.GT.0 ) GOTO (800,900), IRTET
C
        GOTO 900
 800    CONTINUE
C
C
C
C
C  6    TRANSCODAGE EN REPRESENTATION INTERNE ET STOCKAGE
C       -------------------------------------------------
C
C -     TRANSCODAGE DE CONNEX
C
        DO 500 I = 1 , NBMAIL
        CALL JENUNO(JEXNUM(CONXV,I),NOMN)
        CALL JEVEUO(JEXNUM(CONXV,I),'L',JVCNX)
        CALL JELIRA(JEXNUM(CONXV,I),'LONMAX',NBNO,K1BID)
        CALL JENONU(JEXNOM(NOMU//'.NOMMAI',NOMN),IBID)
        CALL JEECRA(JEXNUM(CONNEX,IBID),'LONMAX',NBNO,' ')
        CALL JEVEUO(JEXNUM(CONNEX,IBID),'E',JGCNX)
                DO 550 J = 1 , NBNO
                NOM   = ZK8(JVCNX+J-1)
                CALL JENONU(JEXNOM(NOMNOE,NOM),NUM)
                ZI(JGCNX+J-1) = NUM
                IF(NUM.EQ.0)THEN
                CALL UTMESS('E',CMD,'TRANSCODAGE : '//
     >          'LE NOEUD '//NOM//' DECLARE DANS '//
     >          'LA CONNECTIVITE DE LA MAILLE '//NOMN//' N EXISTE '//
     >          'PAS DANS LES COORDONNEES')
                IER = 1
                ENDIF
 550            CONTINUE
 500    CONTINUE
C
C
C -     TRANSCODAGE DE GROUPENO
C
      IF ( NBGRNO .NE. 0 ) THEN
        CALL WKVECT('&&OP0001.NOEUD' ,'V V I',NBNOEU,JNOEU)
        CALL WKVECT('&&OP0001.NOEUD2','V V I',NBNOEU,JNOEU2)
        DO 600 I = 1 , NBGRNO
C
C         REMISE A ZERO DE L'OBJET "&&OP001.NOEUD2" :
          DO 601 II=1,NBNOEU
            ZI(JNOEU2-1+II)=0
 601      CONTINUE

          CALL JENUNO(JEXNUM(GRPNOV,I),NOMG)
          CALL JEVEUO(JEXNUM(GRPNOV,I),'L',JVG)
          CALL JELIRA(JEXNUM(GRPNOV,I),'LONMAX',NBNO,K1BID)
C         --- ON VERIFIE QUE TOUS LES NOEUDS SONT DISTINCTS ---
          NBNO1 = 0
          DO 610 IM1 = 1 , NBNO
             NOM1 = ZK8(JVG+IM1-1)
             CALL JENONU(JEXNOM(NOMNOE,NOM1),NUM)
             IF ( NUM .EQ. 0 )THEN
                IER = IER + 1
                CALL UTMESS('E',CMD,'TRANSCODAGE : LE NOEUD '//NOM1//
     >                      ' DECLARE DANS LE GROUP_NO: '//NOMG//
     >                      ' N''EXISTE PAS DANS LES COORDONNEES')
                GOTO 610
             ENDIF
             ZI(JNOEU2-1+NUM)=ZI(JNOEU2-1+NUM)+1
             IF (ZI(JNOEU2-1+NUM)  .GE. 2 ) THEN
                CALL UTMESS('A',CMD,'LE NOEUD : '//NOM1//
     >        ' EST EN DOUBLE DANS LE GROUP_NO: '//NOMG//
     >        '. ON ELIMINE LES DOUBLONS')
                GOTO 610
             ENDIF
             NBNO1 = NBNO1 + 1
             ZI(JNOEU+NBNO1-1) = NUM
 610      CONTINUE
          CALL JECROC(JEXNOM(GRPNOE,NOMG))
          CALL JEECRA(JEXNOM(GRPNOE,NOMG),'LONMAX',NBNO1,' ')
          CALL JEVEUO(JEXNOM(GRPNOE,NOMG),'E',JGG)
          DO 650 J = 0 , NBNO1-1
            ZI(JGG+J) = ZI(JNOEU+J)
 650      CONTINUE
 600    CONTINUE
        CALL JEDETR('&&OP0001.NOEUD')
        CALL JEDETR('&&OP0001.NOEUD2')
      ENDIF
C
C
C -     TRANCODAGE DE GROUPEMA
C
      IF ( NBGRMA .NE. 0 ) THEN
        CALL WKVECT('&&OP0001.MAILLE' ,'V V I',NBMAIL,JMAIL)
        CALL WKVECT('&&OP0001.MAILLE2','V V I',NBMAIL,JMAIL2)
        DO 700 I = 1 , NBGRMA
C
C         REMISE A ZERO DE L'OBJET "&&OP001.MAILLE2" :
          DO 706 II=1,NBMAIL
            ZI(JMAIL2-1+II)=0
 706      CONTINUE
          CALL JENUNO(JEXNUM(GRPMAV,I),NOMG)
          CALL JEVEUO(JEXNUM(GRPMAV,I),'L',JVG)
          CALL JELIRA(JEXNUM(GRPMAV,I),'LONMAX',NBMA,K1BID)
C         --- ON VERIFIE QUE TOUTES LES MAILLES SONT DISTINCTS ---
          NBMA1 = 0
          DO 710 IM1 = 1 , NBMA
             NOM1 = ZK8(JVG+IM1-1)
             CALL JENONU(JEXNOM(NOMMAI,NOM1),NUM)
             IF ( NUM .EQ. 0 ) THEN
                IER = IER + 1
                CALL UTMESS('E',CMD,'TRANSCODAGE : LA MAILLE '//NOM1//
     >                      ' DECLARE DANS LE GROUP_MA: '//NOMG//
     >                      ' N''EXISTE PAS DANS LES CONNECTIVITEES')
                GOTO 710
             ENDIF
             ZI(JMAIL2-1+NUM)=ZI(JMAIL2-1+NUM)+1
             IF (ZI(JMAIL2-1+NUM)  .GE. 2 ) THEN
                CALL UTMESS('A',CMD,'LA MAILLE : '//NOM1//
     >         ' EST EN DOUBLE DANS LE GROUP_MA: '//NOMG//
     >         '. ON ELIMINE LES DOUBLONS')
                GOTO 710
             ENDIF
             NBMA1 = NBMA1 + 1
             ZI(JMAIL+NBMA1-1) = NUM
 710      CONTINUE
          CALL JECROC(JEXNOM(GRPMAI,NOMG))
          CALL JEECRA(JEXNOM(GRPMAI,NOMG),'LONMAX',NBMA1,' ')
          CALL JEVEUO(JEXNOM(GRPMAI,NOMG),'E',JGG)
          DO 750 J = 0 , NBMA1-1
             ZI(JGG+J) = ZI(JMAIL+J)
 750      CONTINUE
 700    CONTINUE
        CALL JEDETR('&&OP0001.MAILLE')
        CALL JEDETR('&&OP0001.MAILLE2')
      ENDIF
C
C -     FIN DE TRANSCODAGE
C
      IF ( IER .NE. 0 ) THEN
         CALL UTMESS('F',CMD,'TRANSCODAGE : UNE INCOHERENCE A ETE '//
     >               'DETECTEE ENTRE LES DECLARATIONS DE NOMS DE '//
     >               'NOEUDS OU DE MAILLES LORS DU TRANSCODAGE '//
     >               'DES OBJETS GROUPES ET CONNECTIVITEES')
         GOTO 9999
      ENDIF
C
C -     DUMP DES OBJETS DEMANDES
C
        IF(DIMDBG(1).NE.0)THEN
        DO 2000 J = 1,DIMDBG(1)
        CALL JEEXIN(NOMDBG(J,1),IRET)
        IF(IRET.GT.0)THEN
        CALL JEIMPO('MESSAGE',NOMDBG(J,1),' ','DUMP DE '//NOMDBG(J,1))
        ENDIF
 2000   CONTINUE
        ENDIF

        IF(NBG.GE.0)CALL JEDBUG(0)
C
        CALL JEDETC('V',NOMU,1)
        CALL JEDETC('V','&&',1)
 9999   CONTINUE
C
C FERMETURE DU FICHIER
C
        CALL ASOPEN ( -IFL, ' ' )
C
        CALL JEDEMA ( )
        END
