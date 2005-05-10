      SUBROUTINE CAZOCO(CHAR,MOTFAC,NOMA,NOMO,NDIM,IREAD,
     +                  IWRITE)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 09/05/2005   AUTEUR REZETTE C.REZETTE 
C ======================================================================
C COPYRIGHT (C) 1991 - 2004  EDF R&D                  WWW.CODE-ASTER.ORG
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
C TOLE CRP_20
C
      IMPLICIT     NONE
      CHARACTER*8  CHAR
      CHARACTER*16 MOTFAC
      CHARACTER*8  NOMA
      CHARACTER*8  NOMO     
      INTEGER      NDIM
      INTEGER      IREAD
      INTEGER      IWRITE  
C
C ----------------------------------------------------------------------
C ROUTINE APPELEE PAR : CARACO
C ----------------------------------------------------------------------
C
C LECTURE DES PRINCIPALES CARACTERISTIQUES DU CONTACT (SURFACE IREAD)
C REMPLISSAGE DE LA SD 'DEFICO' (SURFACE IWRITE)
C
C IN  CHAR   : NOM UTILISATEUR DU CONCEPT DE CHARGE
C IN  MOTFAC : MOT-CLE FACTEUR (VALANT 'CONTACT')
C IN  NOMA   : NOM DU MAILLAGE
C IN  NOMO   : NOM DU MODELE
C IN  NDIM   : NOMBRE DE DIMENSIONS DU PROBLEME
C IN  IREAD  : INDICE POUR LIRE LES DONNEES DANS AFFE_CHAR_MECA
C IN  IWRITE : INDICE POUR ECRIRE LES DONNEES DANS LA SD DEFICONT
C
C -------------- DEBUT DECLARATIONS NORMALISEES JEVEUX -----------------
C
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
C
C ---------------- FIN DECLARATIONS NORMALISEES JEVEUX -----------------
C
      INTEGER      ZMETH
      PARAMETER    (ZMETH=8)
      INTEGER      ZTOLE
      PARAMETER    (ZTOLE=4)
      INTEGER      ZCONV
      PARAMETER    (ZCONV=4)

      CHARACTER*16 NOMCMD,APPAR,PROJ,RECH,TYPM,TYPN,TYPF,GLIS
     
      INTEGER      NBREAC,LGBLOC,ITER

      CHARACTER*8  K8BID,REAC
      CHARACTER*16 K16BID,CHAM
      INTEGER      NOC,NOCN,NOCC,OLDMET,NEWMET
           
      CHARACTER*24 METHCO,TOLECO,CARACF,DIRCO,SANSNQ
      INTEGER      JMETH,JTOLE,JCMCF,JDIR,JSANSN
      CHARACTER*24 JEUSUP,JEUFO1,JEUFO2,JEUFO3      
      INTEGER      JJSUP,JJFO1,JJFO2,JJFO3     
      CHARACTER*24 NORLIS,TANDEF,CHAMCO,COEFCO,CONVCO
      INTEGER      JNORLI,JTGDEF,JCHAM,JCOEF,JCONV

      CHARACTER*8  JEUF1,JEUF2,JEUF3,ISTO
      CHARACTER*16 INTER
      CHARACTER*3  NOQU
      
      REAL*8       DIST1,DIST2,LAMB,GEOM,ALJEU
      REAL*8       DIR(3),COEF,SEUIL
      REAL*8       COEFRO,COEFPN,COEFPT,COEFTE

C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- INITIALISATIONS
C
      COEFPT = 0.D0
      COEFPN = 0.D0
      COEFTE = 0.D0
      COEFRO = 0.D0
      COEF   = 0.D0
      SEUIL  = 0.D0
      DIST1  = 0.D0
      DIST2  = 0.D0
      LAMB   = 0.D0
      GEOM   = 0.D0
      ALJEU  = -1.D0
C
C --- NOM DU CONCEPT RESULTAT D'AFFE_CHAR_MECA
C
      CALL GETRES(K8BID,K16BID,NOMCMD)     
C ======================================================================
C --- LECTURE DES STRUCTURES DE DONNEES DE CONTACT
C ======================================================================
      CARACF = CHAR(1:8)//'.CONTACT.CARACF'
      CHAMCO = CHAR(1:8)//'.CONTACT.CHAMCO'
      COEFCO = CHAR(1:8)//'.CONTACT.COEFCO'
      CONVCO = CHAR(1:8)//'.CONTACT.CONVCO'
      DIRCO  = CHAR(1:8)//'.CONTACT.DIRCO'      
      JEUFO1 = CHAR(1:8)//'.CONTACT.JFO1CO'
      JEUFO2 = CHAR(1:8)//'.CONTACT.JFO2CO'
      JEUFO3 = CHAR(1:8)//'.CONTACT.JFO3CO'
      JEUSUP = CHAR(1:8)//'.CONTACT.JSUPCO'
      METHCO = CHAR(1:8)//'.CONTACT.METHCO'
      NORLIS = CHAR(1:8)//'.CONTACT.NORLIS'  
      SANSNQ = CHAR(1:8)//'.CONTACT.SANSNQ'
      TANDEF = CHAR(1:8)//'.CONTACT.TANDEF'
      TOLECO = CHAR(1:8)//'.CONTACT.TOLECO'
C ======================================================================
      CALL JEVEUO(CARACF,'E',JCMCF)
      CALL JEVEUO(CHAMCO,'E',JCHAM)
      CALL JEVEUO(COEFCO,'E',JCOEF)
      CALL JEVEUO(CONVCO,'E',JCONV)
      CALL JEVEUO(DIRCO, 'E',JDIR)
      CALL JEVEUO(JEUFO1,'E',JJFO1)
      CALL JEVEUO(JEUFO2,'E',JJFO2)
      CALL JEVEUO(JEUFO3,'E',JJFO3)
      CALL JEVEUO(JEUSUP,'E',JJSUP)
      CALL JEVEUO(METHCO,'E',JMETH)
      CALL JEVEUO(NORLIS,'E',JNORLI)
      CALL JEVEUO(SANSNQ,'E',JSANSN)
      CALL JEVEUO(TANDEF,'E',JTGDEF)
      CALL JEVEUO(TOLECO,'E',JTOLE)

C ----------------------------------------------------------------------
C
C     RECUPERATION DE LA METHODE DE CONTACT/FROTTEMENT
C
C ----------------------------------------------------------------------

      CALL GETVTX(MOTFAC,'METHODE',IREAD,1,1,TYPM,NOC)
      IF (TYPM(1:8).EQ.'PENALISA') THEN
          ZI(JMETH+ZMETH* (IWRITE-1)+6) = -1
          CALL GETVR8(MOTFAC,'E_N',1,1,1,COEFPN,NOCN)
          ZR(JCMCF+6* (IWRITE-1)+2) = COEFPN
      ELSE IF (TYPM(1:8).EQ.'LAGRANGI') THEN
          ZI(JMETH+ZMETH* (IWRITE-1)+6) = 1
      ELSE IF (TYPM(1:8).EQ.'CONTRAIN') THEN
          CALL GETVTX(MOTFAC,'GLISSIERE',IREAD,1,1,GLIS,NOC)
          IF (GLIS(1:3).EQ.'NON') THEN
            ZI(JMETH+ZMETH* (IWRITE-1)+6) = 0
          ELSE
            ZI(JMETH+ZMETH* (IWRITE-1)+6) = 7
            CALL GETVR8(MOTFAC,'ALARME_JEU',IREAD,1,1,ALJEU,NOC)
            ZR(JTOLE+ZTOLE*(IWRITE-1)+3)  = ALJEU
          ENDIF
         
      ELSE IF (TYPM(1:8).EQ.'CONTINUE') THEN
          ZI(JMETH+ZMETH* (IWRITE-1)+6) = 6
      ELSE IF (TYPM(1:5).EQ.'VERIF') THEN
          ZI(JMETH+ZMETH* (IWRITE-1)+6) = -2
      ELSE
          CALL UTMESS('F','CAZOCO',
     &           'NE CORRESPOND A AUCUNE METHODE DE CONTACT-FROTTEMENT'
     &                )
      END IF
C
C --- TEST POUR LES METHODES SANS FROTTEMENT
C
      IF (IWRITE.GT.1) THEN
        OLDMET = ZI(JMETH+ZMETH* (IWRITE-2)+6)
        NEWMET = ZI(JMETH+ZMETH* (IWRITE-1)+6)
        IF ((TYPM(1:8).EQ.'CONTRAIN').OR.(TYPM(1:5).EQ.'VERIF').OR.
     &      (TYPM(1:8).EQ.'CONTINUE')) THEN
          IF (OLDMET.NE.NEWMET) THEN
            CALL UTMESS('F','CAZOCO',
     &                  'METHODE DE CONTACT DIFFERENTES POUR'//
     &                  ' LES ZONES DE CONTACT')
          END IF
        END IF
      END IF

C ----------------------------------------------------------------------
C
C     PARAMETRES COMMUNS A TOUTES LES METHODES
C
C ----------------------------------------------------------------------

C 
C --- RECUPERATION DU TYPE D'APPARIEMENT 
C 
      CALL GETVTX(MOTFAC,'APPARIEMENT',IREAD,1,1,APPAR,NOC)

      IF (APPAR(1:3) .EQ.'NON'         ) THEN
         ZI(JMETH+ZMETH*(IWRITE-1)+1) = -1
      ELSE IF (APPAR(1:5) .EQ.'NODAL'       )  THEN
         ZI(JMETH+ZMETH*(IWRITE-1)+1) =  0
      ELSE IF (APPAR(1:9) .EQ.'MAIT_ESCL'   )  THEN
         ZI(JMETH+ZMETH*(IWRITE-1)+1) =  1
      ELSE
          CALL UTMESS('F','CAZOCO',
     &         'NE CORRESPOND A AUCUNE METHODE DU MOT CLE APPARIEMENT'
     &         )
      ENDIF

      IF (APPAR(1:3).EQ.'NON') THEN
         IF (TYPM(1:8).EQ.'CONTINUE') THEN
            CALL GETVTX(MOTFAC,'GROUP_MA_ESCL',1,1,1,K16BID,NOC)
            IF (NOC.NE.0) CALL UTMESS('F','CAZOCO',
     &                             'AVEC APPARIEMENT=NON, IL NE'//
     &                       ' FAUT PAS RENSEIGNER GROUP_MA_ESCL')
            CALL GETVTX(MOTFAC,'MAILLE_ESCL',1,1,1,K16BID,NOC)
            IF (NOC.NE.0) CALL UTMESS('F','CAZOCO',
     &                            'AVEC APPARIEMENT=NON, IL NE FAUT'//
     &                            ' PAS RENSEIGNER MAILLE_ESCL')
         ELSE
            CALL GETVTX(MOTFAC,'GROUP_MA_MAIT',1,1,1,K16BID,NOC)
            IF (NOC.NE.0) CALL UTMESS('F','CAZOCO',
     &                         'AVEC APPARIEMENT=NON, IL NE '//
     &                         'FAUT PAS RENSEIGNER GROUP_MA_MAIT')
            CALL GETVTX(MOTFAC,'MAILLE_MAIT',1,1,1,K16BID,NOC)
            IF (NOC.NE.0) CALL UTMESS('F','CAZOCO',
     &                          'AVEC APPARIEMENT=NON, IL NE FAUT '//
     &                          'PAS RENSEIGNER MAILLE_MAIT')
         ENDIF
      END IF

C 
C --- APPARIEMENT SYMETRIQUE ?
C
      IF (APPAR.EQ.'MAIT_ESCL_SYME') THEN
        ZI(JMETH+ZMETH*(IWRITE-1)+3) = 1
      ELSE
        ZI(JMETH+ZMETH* (IWRITE-1)+3) = 0
      ENDIF
C 
C --- RECUPERATION DU TYPE DE PROJECTION 
C 
      CALL GETVTX(MOTFAC,'PROJECTION',IREAD,1,1,PROJ,NOC)

      IF (PROJ.EQ.'LINEAIRE') THEN
        ZI(JMETH+ZMETH*(IWRITE-1)+4) = 1
      ELSE IF (PROJ.EQ.'QUADRATIQUE') THEN
        ZI(JMETH+ZMETH*(IWRITE-1)+4) = 2
      ELSE
          CALL UTMESS('F','CAZOCO',
     &         'NE CORRESPOND A AUCUNE METHODE DU MOT CLE PROJECTION'
     &         )
      ENDIF
C 
C --- RECUPERATION DE L'ENVIRONNEMENT DE RECHERCHE 
C 
      CALL GETVTX(MOTFAC,'RECHERCHE',IREAD,1,1,RECH,NOC)

      IF (APPAR.EQ.'NON'               ) THEN
        ZI(JMETH+ZMETH*(IWRITE-1)+5) =  0
      ELSE IF (RECH(1:12).EQ.'NOEUD_BOUCLE' ) THEN
        ZI(JMETH+ZMETH*(IWRITE-1)+5) =  1
      ELSE IF (RECH(1:12).EQ.'NOEUD_VOISIN' ) THEN
        ZI(JMETH+ZMETH*(IWRITE-1)+5) =  2
      ELSE
          CALL UTMESS('F','CAZOCO',
     &         'NE CORRESPOND A AUCUNE METHODE DU MOT CLE RECHERCHE'
     &         )
      ENDIF
C 
C --- PRESENCE DE LISSAGE ? 
C 
      CALL GETVTX(MOTFAC,'LISSAGE',IREAD,1,1,INTER,NOC)

      IF (INTER(1:3).EQ.'OUI') THEN
          ZI(JNORLI+ (IWRITE-1)+1) = 1
      ELSE IF (INTER(1:3).EQ.'NON') THEN
          ZI(JNORLI+ (IWRITE-1)+1) = 0
      ELSE
          CALL UTMESS('F','CAZOCO',
     &         'NE CORRESPOND A AUCUNE METHODE DU MOT CLE LISSAGE'
     &         )
      END IF
C 
C --- TYPE DE NORMALE 
C 
      CALL GETVTX(MOTFAC,'NORMALE',IREAD,1,1,TYPN,NOC)

      IF (TYPN(1:6).EQ.'MAIT') THEN
          ZI(JMETH+ZMETH* (IWRITE-1)+8) = 0
      ELSE IF (TYPN(1:9).EQ.'MAIT_ESCL') THEN
          ZI(JMETH+ZMETH* (IWRITE-1)+8) = 1
      ELSE
          CALL UTMESS('F','CAZOCO',
     &         'NE CORRESPOND A AUCUNE METHODE DU MOT CLE NORMALE'
     &         )
      END IF
C 
C --- RECUPERATION DES GRANDEURS UTILISEES (DEPLACEMENT, PRESSION OU 
C --- TEMPERATURE) ET DES COEFFICIENTS POUR LA LIAISON SANS APPARIEMENT
C --- DANS LA ZONE IOC 
C 
      CALL GETVTX(MOTFAC,'NOM_CHAM',IREAD,1,1,CHAM,NOC)
      IF (CHAM(1:4).EQ.'DEPL') THEN
        IF (APPAR(1:3).EQ.'NON') THEN
          ZI(JCHAM+IWRITE-1) = -1
        ELSE
          ZI(JCHAM+IWRITE-1) = 1
        END IF
      ELSE IF (CHAM(1:4).EQ.'PRES') THEN 
        ZI(JCHAM+IWRITE-1) = -2 
      ELSE IF (CHAM(1:4).EQ.'TEMP') THEN 
        ZI(JCHAM+IWRITE-1) = -3
      ELSE IF (CHAM(1:4).EQ.'PRE1') THEN 
        ZI(JCHAM+IWRITE-1) = -4
      ELSE IF (CHAM(1:4).EQ.'PRE2') THEN 
        ZI(JCHAM+IWRITE-1) = -5
      ELSE IF (CHAM(1:4).EQ.'VITE') THEN 
          CALL UTMESS('F','CAZOCO',
     &         'NOM_CHAM = VITE NON DISPONIBLE'
     &         ) 
      ELSE
        IF (TYPM(1:5).NE.'VERIF') THEN
          CALL UTMESS('F','CAZOCO',
     &         'NE CORRESPOND A AUCUNE METHODE DU MOT CLE NOM_CHAM'
     &         )
        ENDIF
      ENDIF
C
C --- METHODE CONTINUE: PARAMETRES SPECIFIQUES
C
      IF (TYPM(1:8).EQ.'CONTINUE') THEN
         CALL CAZOCC(CHAR,MOTFAC,NOMA,NOMO,NDIM,IREAD,IWRITE)
         GOTO 999
      ENDIF
C 
C --- MOT-CLE VECT_NORM_ESCL 
C 
      CALL GETVR8(MOTFAC,'VECT_NORM_ESCL',IREAD,1,3,DIR,NOC)
      IF (NOC.NE.0) THEN
         IF (APPAR(1:5).NE.'NODAL') THEN
            CALL UTMESS('F','CAZOCO',' ON NE PEUT PAS UTILISER '//
     &                  'UNE DIRECTION D''APPARIEMENT FIXE SI '//
     &                  'L''APPARIEMENT N''EST PAS NODAL')
         END IF
         ZI(JMETH+ZMETH* (IWRITE-1)+1) = 4
         ZR(JDIR+3* (IWRITE-1)) = DIR(1)
         ZR(JDIR+3* (IWRITE-1)+1) = DIR(2)
         IF (NDIM.EQ.3) THEN
            ZR(JDIR+3* (IWRITE-1)+2) = DIR(3)
         ELSE
            ZR(JDIR+3* (IWRITE-1)+2) = 0.D0
         END IF
      END IF
C 
C --- MOT-CLE VECT_Y
C 
      CALL GETVTX(MOTFAC,'FROTTEMENT',IREAD,1,1,TYPF,NOCC)
      ZI(JMETH+ZMETH* (IWRITE-1)+2) = 0
      IF (NOCC.NE.0) THEN
         CALL GETVR8(MOTFAC,'VECT_Y',IREAD,1,3,DIR,NOC)
         IF (NOC.NE.0) THEN
            IF (NDIM.EQ.2) THEN
               CALL UTMESS('A','CAZOCO','LA COMMANDE VECT_Y'//
     &                   ' N''INTERVIENT PAS EN 2D.')
            ELSE
               ZI(JMETH+ZMETH* (IWRITE-1)+2) = 1
               ZR(JTGDEF+ (IWRITE-1)*3  ) = DIR(1)
               ZR(JTGDEF+ (IWRITE-1)*3+1) = DIR(2)
               ZR(JTGDEF+ (IWRITE-1)*3+2) = DIR(3)
            END IF
         END IF
      END IF
C 
C --- RECUPERATION DU JEU SUPPLEMENTAIRE MECANIQUE POUR LA ZONE IOC 
C --- LE JEU TOTAL SERA JEU - JEUSUP (SOIT : D - DIST1 - DIST2) 
C 
      ZR(JJSUP+IWRITE-1) = 0.D0
      ZK8(JJFO1+IWRITE-1) = ' '
      ZK8(JJFO2+IWRITE-1) = ' '
C 
C --- CAS D'UN JEU SUPPLEMENTAIRE REEL (AFFE_CHAR_MECA) 
C
      IF (NOMCMD.EQ.'AFFE_CHAR_MECA') THEN
         CALL GETVR8(MOTFAC,'DIST_MAIT',IREAD,1,1,DIST1,NOC)
         CALL GETVR8(MOTFAC,'DIST_ESCL',IREAD,1,1,DIST2,NOC)
         ZR(JJSUP+IWRITE-1) = DIST1 + DIST2
      END IF
C 
C --- CAS D'UN JEU SUPPLEMENTAIRE FONCTION (AFFE_CHAR_MECA_F) 
C 
      IF (NOMCMD.EQ.'AFFE_CHAR_MECA_F') THEN
        CALL GETVID(MOTFAC,'DIST_MAIT',IREAD,1,1,JEUF1,NOC)
        IF (NOC.NE.0) ZK8(JJFO1+IWRITE-1) = JEUF1
        CALL GETVID(MOTFAC,'DIST_ESCL',IREAD,1,1,JEUF2,NOC)
        IF (NOC.NE.0) ZK8(JJFO2+IWRITE-1) = JEUF2
      END IF

C
C --- CONTACT SANS CALCUL: PARAMETRES SPECIFIQUES
C
      IF (TYPM(1:5).EQ.'VERIF') THEN
         CALL CAZOCV(CHAR,MOTFAC,IREAD,IWRITE)
         GOTO 999
      ENDIF
C
C --- TOUTES LES AUTRES METHODES (DISCRETES)
C
C
C --- TOLE_PROJ_EXT
C --- TOLE_PROJ_EXT <0: LA PROJECTION HORS DE LA MAILLE EST INTERDITE
C --- TOLE_PROJ_EXT >0: LA PROJECTION HORS DE LA MAILLE EST AUTORISEE
C ---                    MAIS LIMITEE PAR LAMB
C
      CALL GETVR8(MOTFAC,'TOLE_PROJ_EXT',IREAD,1,1,LAMB,NOC)
      IF (LAMB.LE.0.D0) THEN
         ZR(JTOLE+ZTOLE*(IWRITE-1)) = -1.D0        
      ELSE
         ZR(JTOLE+ZTOLE*(IWRITE-1)) = LAMB
      ENDIF
C
C --- TOLE_PROJ_INT
C --- TOLE_PROJ_INT   : LA PROJECTION SUR LES ENTITES GEOMETRIQUES
C ---                   INTERNES (NOEUDS, ARETES, DIAGONALES) EST 
C ---                   DETECTEE DANS LA ZONE LIMITEE PAR LAMB
C
      CALL GETVR8(MOTFAC,'TOLE_PROJ_INT',IREAD,1,1,LAMB,NOC)
      ZR(JTOLE+ZTOLE*(IWRITE-1)+1) = LAMB 
C
C --- TOLE_REAC_GEOM
C
      CALL GETVR8(MOTFAC,'TOLE_REAC_GEOM',IREAD,1,1,GEOM,NOC)
      ZR(JTOLE+ZTOLE*(IWRITE-1)+2) = GEOM  
C 
C --- PARAMETRES DE REACTUALISATION GEOMETRIQUE 
C       
      CALL GETVTX(MOTFAC,'REAC_GEOM',IREAD,1,1,REAC,NOC)

      IF (REAC.EQ.'SANS') THEN
          ZI(JMETH+ZMETH*(IWRITE-1)+7) =  0
      ELSE IF (REAC.EQ.'AUTOMATI') THEN
          ZI(JMETH+ZMETH*(IWRITE-1)+7) = -1
      ELSE IF (REAC.EQ.'CONTROLE') THEN
          CALL GETVIS(MOTFAC,'NB_REAC_GEOM',IREAD,1,1,NBREAC,NOC)
          ZI(JMETH+ZMETH*(IWRITE-1)+7) = NBREAC
      ELSE
          CALL UTMESS('F','CAZOCO',
     &         'NE CORRESPOND A AUCUNE METHODE DU MOT CLE REAC_GEOM'
     &         )
      ENDIF
C
C --- ARRET OU PAS SI MATRICE DE CONTACT SINGULIERE 
C       
      CALL GETVTX(MOTFAC,'STOP_SINGULIER',IREAD,1,1,ISTO,NOC)
      ZI(JCONV+ZCONV*(IWRITE-1)) = 0
      IF (ISTO.EQ.'OUI') THEN
           ZI(JCONV+ZCONV*(IWRITE-1)) = 0
      ELSE IF (ISTO.EQ.'NON') THEN
           ZI(JCONV+ZCONV*(IWRITE-1)) = 1
      ELSE
          CALL UTMESS('F','CAZOCO',
     &        'NE CORRESPOND A AUCUNE METHODE DU MOT CLE STOPSINGULIER'
     &         )
      ENDIF
C
C --- NOMBRE DE PAQUETS POUR LA RESOLUTION DES SYSTEMES LINEAIRES  
C 
      CALL GETVIS(MOTFAC,'NB_RESOL',IREAD,1,1,LGBLOC,NOC)
      ZI(JCONV+ZCONV*(IWRITE-1)+1) = LGBLOC
C
C --- NOMBRE D'ITERATIONS DE CONTACT MAX = NBLIAI*ITER_MULT_MAXI  
C 
      IF (TYPM(1:10).NE.'CONTRAINTE') THEN
         CALL GETVIS(MOTFAC,'ITER_MULT_MAXI',IREAD,1,1,ITER,NOC)
         ZI(JCONV+ZCONV*(IWRITE-1)+2) = ITER
      ENDIF
C 
C --- EXCLUSION DE NOEUDS QUADRATIQUES (VOIR CACOOEQ) 
C 
      CALL GETVTX(MOTFAC,'SANS_NOEUD_QUAD',IREAD,1,1,NOQU,NOC)
      IF (NOQU.EQ.'OUI') THEN
         ZI(JSANSN+(IWRITE-1)) = 1        
      ELSE IF (NOQU.EQ.'NON') THEN
         ZI(JSANSN+(IWRITE-1)) = 0
      ELSE
          CALL UTMESS('F','CAZOCO',
     &      'NE CORRESPOND A AUCUNE METHODE DU MOT CLE SANS_NOEUD_QUAD'
     &       )
      ENDIF


      IF (APPAR(1:3).EQ.'NON') THEN
         CALL GETVR8(MOTFAC,'COEF_MULT_ESCL',IREAD,1,1,COEF,NOC)
         ZR(JCOEF+IWRITE-1) = COEF

         IF (NOMCMD.EQ.'AFFE_CHAR_MECA') THEN
           CALL GETVR8(MOTFAC,'COEF_IMPO',IREAD,1,1,SEUIL,NOC)
           ZR(JJSUP+IWRITE-1) = SEUIL
         ELSE IF (NOMCMD.EQ.'AFFE_CHAR_MECA_F') THEN
           CALL GETVID(MOTFAC,'COEF_IMPO',IREAD,1,1,JEUF3,NOC)
           IF (NOC.NE.0) THEN
             ZK8(JJFO3+IWRITE-1) = JEUF3
           ENDIF
         ELSE
           CALL UTMESS('F','CALICO00','AAAAAAAAAAARRRRGHHHH...')
         ENDIF
      ELSE
         ZR(JCOEF+IWRITE-1) = 1.D0
      ENDIF
C
C --- PARAMETRES DU FROTTEMENT
C
      CALL GETVTX(MOTFAC,'FROTTEMENT',IREAD,1,1,TYPF,NOCC)
      IF (NOCC.NE.0) THEN
       IF (TYPF.EQ.'COULOMB') THEN
         ZR(JCMCF+6* (IWRITE-1)+5) = 3.D0
         CALL GETVR8(MOTFAC,'COULOMB',IREAD,1,1,COEFRO,NOC)
         ZR(JCMCF+6* (IWRITE-1)+4) = COEFRO
         CALL GETVR8(MOTFAC,'E_T',IREAD,1,1,COEFPT,NOC)
         ZR(JCMCF+6* (IWRITE-1)+3) = COEFPT
         CALL GETVR8(MOTFAC,'COEF_MATR_FROT',IREAD,1,1,COEFTE,NOC)
         ZR(JCMCF+6* (IWRITE-1)+6) = COEFTE
         IF (NDIM.EQ.2) THEN
            IF (TYPM(1:8).EQ.'PENALISA') THEN
               ZI(JMETH+ZMETH* (IWRITE-1)+6) = 3
               IF (NOCN.NE.0) ZI(JMETH+ZMETH* (IWRITE-1)+6) = 5
            ELSE IF (TYPM(1:8).EQ.'LAGRANGI') THEN
               ZI(JMETH+ZMETH* (IWRITE-1)+6) = 2
            END IF
         ELSE IF (NDIM.EQ.3) THEN
            IF (TYPM(1:8).EQ.'PENALISA') THEN
               ZI(JMETH+ZMETH* (IWRITE-1)+6) = 3
               IF (NOCN.NE.0) ZI(JMETH+ZMETH* (IWRITE-1)+6) = 5
            ELSE IF (TYPM(1:8).EQ.'LAGRANGI') THEN
               ZI(JMETH+ZMETH* (IWRITE-1)+6) = 4
            END IF
         END IF
       ENDIF
      ENDIF
C
C --- TEST POUR LES METHODES AVEC FROTTEMENT
C
      IF (IWRITE.GT.1) THEN
        OLDMET = ZI(JMETH+ZMETH* (IWRITE-2)+6)
        NEWMET = ZI(JMETH+ZMETH* (IWRITE-1)+6)
        IF ((TYPM(1:8).EQ.'PENALISA').OR.(TYPM(1:8).EQ.'LAGRANGI')) THEN
          IF (OLDMET.NE.NEWMET) THEN
            CALL UTMESS('F','CAZOCO',
     &                  'METHODE DE CONTACT DIFFERENTES POUR'//
     &                  ' LES ZONES DE CONTACT')
          END IF
        END IF
      END IF
C
 999  CONTINUE
C
      CALL JEDEMA()

      END
