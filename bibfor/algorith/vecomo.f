      SUBROUTINE VECOMO (MODGEN,SST1,SST2,INTF1,INTF2)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 20/06/2000   AUTEUR ACBHHCD G.DEVESA 
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
C  C. VARE     DATE 18/09/94
C-----------------------------------------------------------------------
C  BUT:  < VERIFIER LA COHERENCE DU MODELE GENERALISE >
C
C  ON VERIFIE QUE LA LIAISON DEFINIE DANS DEFI_MODELE_GENE EST
C  COMPATIBLE AVEC LES ORIENTATIONS ET LES TRANSLATIONS AFFECTEES AUX
C  SOUS-STRUCTURES. LES NOEUDS DES DEUX INTERFACES QUI FORMENT LA
C  LIAISON DOIVENT ETRE CONFONDUS 2 A 2
C
C-----------------------------------------------------------------------
C
C MODGEN  /I/ : NOM K8 DU MODELE GENERALISE
C SST1    /I/ : NOM K8 DE LA PREMIERE SOUS-STRUCTURE DE LA LIAISON
C SST2    /I/ : NOM K8 DE LA SECONDE SOUS-STRUCTURE DE LA LIAISON
C INTF1   /I/ : NOM K8 DE L'INTERFACE DE SST1
C INTF2   /I/ : NOM K8 DE L'INTERFACE DE SST2
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
      CHARACTER*32 JEXNUM,JEXNOM
C
C----------  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
C
C   PARAMETRE REPRESENTANT LE NOMBRE MAX DE COMPOSANTES DE LA GRANDEUR
C   SOUS-JACENTE TRAITEE
C
      PARAMETER   (NBCMPM=10)
      CHARACTER*6  PGC
      CHARACTER*8  MODGEN,LINT1,LINT2,CRITER
      CHARACTER*8  SST1,SST2,INTF 1,INTF2,MAIL1,MAIL2
      CHARACTER*24 REPNOM,INT1,INT2
      REAL*8       X1(3),X2(3),XR1(3),XR2(3),ROT1(3),ROT2(3),DXR
      REAL*8       MAT1(NBCMPM,NBCMPM),MAT2(NBCMPM,NBCMPM),TRA1(3)
      REAL*8       MAT3(NBCMPM,NBCMPM),ZERO,DXRM,LCARAM,TRA2(3)
      REAL*8       MATTMP(NBCMPM,NBCMPM),DIFMAX,LCARA1,LCARA2
      REAL*8       MATRO1(NBCMPM,NBCMPM),MATRO2(NBCMPM,NBCMPM)
      INTEGER      NBNO,ICRIT
      CHARACTER*8  K8BID,NOMNOI,NOMNOJ,NOMNOP
      LOGICAL      SAUT,ORDRE
C
C-----------------------------------------------------------------------
      DATA PGC  /'VECOMO'/
      DATA ZERO /0.0D+00/
C-----------------------------------------------------------------------
C
C-----SEUIL DE TOLERANCE ET CRITERE DE PRECISION
C
      CALL JEMARQ()
      DIFMAX=1.D-3
      CALL GETVR8('VERIF','PRECISION',1,1,1,SEUIL,IVAL)
      IF (IVAL.NE.0) DIFMAX=SEUIL
      ICRIT=1
      CALL GETVTX('VERIF','CRITERE',1,1,1,CRITER,IVAL)
      IF (IVAL.NE.0) THEN
        IF (CRITER.EQ.'ABSOLU')  ICRIT=2
      ENDIF
C
C-----RECUPERATION DES ROTATIONS ET DES TRANSLATIONS
C
      REPNOM=MODGEN//'      .MODG.SSNO'
      CALL JENONU(JEXNOM(REPNOM,SST1),NUSST1)
      CALL JENONU(JEXNOM(REPNOM,SST2),NUSST2)
      CALL JEVEUO(JEXNUM(MODGEN//'      .MODG.SSOR',NUSST1),'L',LLROT1)
      CALL JEVEUO(JEXNUM(MODGEN//'      .MODG.SSOR',NUSST2),'L',LLROT2)
      DO 10 I=1,3
        ROT1(I)=ZR(LLROT1+I-1)
        ROT2(I)=ZR(LLROT2+I-1)
10    CONTINUE
      CALL JEVEUO(JEXNUM(MODGEN//'      .MODG.SSTR',NUSST1),'L',LLTRA1)
      CALL JEVEUO(JEXNUM(MODGEN//'      .MODG.SSTR',NUSST2),'L',LLTRA2)
      DO 110 I=1,3
        TRA1(I)=ZR(LLTRA1+I-1)
        TRA2(I)=ZR(LLTRA2+I-1)
110   CONTINUE
C
C-----CALCUL DES MATRICES DE ROTATION
C
      CALL INTET0(ROT1(1),MAT1,3)
      CALL INTET0(ROT1(2),MAT2,2)
      CALL INTET0(ROT1(3),MAT3,1)
      CALL R8INIR(NBCMPM*NBCMPM,ZERO,MATTMP,1)
      CALL PMPPR(MAT1,NBCMPM,NBCMPM,1,MAT2,NBCMPM,NBCMPM,1,
     &           MATTMP,NBCMPM,NBCMPM)
      CALL R8INIR(NBCMPM*NBCMPM,ZERO,MATRO1,1)
      CALL PMPPR(MATTMP,NBCMPM,NBCMPM,1,MAT3,NBCMPM,NBCMPM,1,
     &           MATRO1,NBCMPM,NBCMPM)
C
      CALL INTET0(ROT2(1),MAT1,3)
      CALL INTET0(ROT2(2),MAT2,2)
      CALL INTET0(ROT2(3),MAT3,1)
      CALL R8INIR(NBCMPM*NBCMPM,ZERO,MATTMP,1)
      CALL PMPPR(MAT1,NBCMPM,NBCMPM,1,MAT2,NBCMPM,NBCMPM,1,
     &           MATTMP,NBCMPM,NBCMPM)
      CALL R8INIR(NBCMPM*NBCMPM,ZERO,MATRO2,1)
      CALL PMPPR(MATTMP,NBCMPM,NBCMPM,1,MAT3,NBCMPM,NBCMPM,1,
     &           MATRO2,NBCMPM,NBCMPM)
C
C
C-----RECUPERATION MAILLAGE ET INTERFACE AMONT DES SOUS-STRUCTURES
C
      CALL MGUTDM(MODGEN,SST1,IBID,'NOM_MAILLAGE',IBID,MAIL1)
      CALL MGUTDM(MODGEN,SST1,IBID,'NOM_LIST_INTERF',IBID,LINT1)
C
      CALL MGUTDM(MODGEN,SST2,IBID,'NOM_MAILLAGE',IBID,MAIL2)
      CALL MGUTDM(MODGEN,SST2,IBID,'NOM_LIST_INTERF',IBID,LINT2)
C
C-----RECUPERATION DU NOMBRE DES NOEUDS DE L'INTERFACE
C
      INT1=LINT1//'      .INTD.LINO'
      CALL JENONU(JEXNOM(INT1(1:19)//'.NOMS',INTF1),IBID)
      CALL JELIRA(JEXNUM(INT1,IBID),'LONMAX',NBNO1,K8BID)
C
      INT2=LINT2//'      .INTD.LINO'
      CALL JENONU(JEXNOM(INT2(1:19)//'.NOMS',INTF2),IBID)
      CALL JELIRA(JEXNUM(INT2,IBID),'LONMAX',NBNO2,K8BID)
C
      IF (NBNO1.NE.NBNO2) THEN
        CALL UTDEBM('F',PGC,
     &   'LES INTERFACES DE LA LIAISON N''ONT PAS LA MEME LONGUEUR')
        CALL UTIMPK('L',' SOUS-STRUCTURE 1 --> ',1,SST1)
        CALL UTIMPK('L',' INTERFACE 1      --> ',1,INTF1)
        CALL UTIMPK('L',' SOUS-STRUCTURE 2 --> ',1,SST2)
        CALL UTIMPK('L',' INTERFACE 2      --> ',1,INTF2)
        CALL UTFINM
      ENDIF
      NBNO=NBNO1
C
CC
CCC---ON VERIFIE LA COINCIDENCE DE CHAQUE COUPLE DE NOEUDS
CC
C
      CALL JENONU(JEXNOM(LINT1 //'      .INTD.NOMS',INTF1),IBID)
      CALL JEVEUO(JEXNUM(LINT1 //'      .INTD.LINO',IBID),'L',LLINT1)
      CALL JEVEUO(LINT1//'      .INTD.DEFO','L',LDESC1)
      CALL JEVEUO(MAIL1//'.COORDO    .VALE','L',LLCOO1)
      CALL JENONU(JEXNOM(LINT2//'      .INTD.NOMS',INTF2),IBID)
      CALL JEVEUO(JEXNUM(LINT2//'      .INTD.LINO',IBID),'E',LLINT2)
      CALL JEVEUO(LINT2//'      .INTD.DEFO','L',LDESC2)
      CALL JEVEUO(MAIL2//'.COORDO    .VALE','L',LLCOO2)
C
C     --- CONSTITUTION DE LISTA ET LISTB :
C         LE IEME NOEUD DE L'INTERFACE DROITE A POUR VIS-A-VIS
C         LE ZI(LISTA-1+I) EME NOEUD DE L'INTERFACE GAUCHE
C         RECIPROQUEMENT LE NOEUD DE POSITION J DE L'INTERFACE GAUCHE
C         EST LE VIS-A-VIS DU NOEUD DE POSITION ZI(LISTB-1+J) DE
C         L'INTERFACE DROITE.
      CALL WKVECT('&&VECOMO.LISTA','V V I',NBNO,LLISTA)
      CALL WKVECT('&&VECOMO.LISTB','V V I',NBNO,LLISTB)
      DXRM=0.D0
      LCARAM=0.D0
      ORDRE = .TRUE.
C
      DO 20 I=1,NBNO
C     ---RECUPERATION DES COORDONNEES DES NOEUDS DE L'INTERFACE DROITE
C
        INU1=ZI(LLINT1-1+I)
        NUNO1=ZI(LDESC1+INU1-1)
        DO 30 K=1,3
          X1(K)=ZR(LLCOO1+(NUNO1-1)*3+K-1)
30      CONTINUE
        DO 40 K=1,3
          XR1(K)=0.D0
          DO 50 L=1,3
            XR1(K)=XR1(K)+MATRO1(K,L)*X1(L)
50        CONTINUE
          XR1(K)=XR1(K)+TRA1(K)
40      CONTINUE
C
        DXR = 0.D0
        DO 120 J = 1,NBNO
C       ---RECUPERATION DES COORDONNEES DES NOEUDS DE L'INTERFACE GAUCHE
C
           INU2=ZI(LLINT2-1+J)
           NUNO2=ZI(LDESC2+INU2-1)
           SAUT = .FALSE.
           DO 60 K=1,3
             X2(K)=ZR(LLCOO2+(NUNO2-1)*3+K-1)
60         CONTINUE
           DO 70 K=1,3
             XR2(K)=0.D0
             DO 80 L=1,3
               XR2(K)=XR2(K)+MATRO2(K,L)*X2(L)
80           CONTINUE
             XR2(K)=XR2(K)+TRA2(K)
             IF (J.NE.1 .AND. ABS(XR2(K)-XR1(K)).GT.DXR) THEN
C               --- COMPARAISON COMPOSANTE AVEC DISTANCE --
C                   (SI COMPOSANTE > DISTANCE MIN ALORS
C                     TEST SUR DISTANCE INUTILE ET SAUT=.TRUE.)
                IF (J.EQ.I .AND. ICRIT.EQ.1) THEN
                   SAUT = .TRUE.
                ELSE
                   GOTO 120
                ENDIF
             ENDIF
70         CONTINUE
C
C          ---CALCUL DE LA DIFFERENCE DES DISTANCES NOEUD A NOEUD
C
           IF (.NOT.SAUT) THEN
              DXRIJ=0.D0
              DO 90 K=1,3
                DXRIJ=DXRIJ+(XR1(K)-XR2(K))**2
90            CONTINUE
              DXRIJ=SQRT(DXRIJ)
              IF (J.EQ.1 .OR. DXRIJ.LT.DXR) THEN
C             --- CRITERE SUR DISTANCE (RECHERCHE DU MINIMUM)
                 DXR = DXRIJ
                 JNODE = J
              ENDIF
           ENDIF
C
C          ---CALCUL D'UNE LONGUEUR CARACTERISTIQUE SI CRITERE RELATIF
C
           IF (ICRIT.EQ.1 .AND. J.EQ.I) THEN
             LCARA1=0.D0
             LCARA2=0.D0
             DO 100 K=1,3
               LCARA1=LCARA1+XR1(K)**2
               LCARA2=LCARA2+XR2(K)**2
  100        CONTINUE
             LCARA1=SQRT(LCARA1)
             LCARA2=SQRT(LCARA2)
             IF (LCARAM.LT.LCARA1) LCARAM=LCARA1
             IF (LCARAM.LT.LCARA2) LCARAM=LCARA2
           ENDIF
C
  120    CONTINUE
C
         IF (DXRM.LT.DXR) DXRM=DXR
         ZI(LLISTA-1+I) = JNODE
         IF (ZI(LLISTB-1+JNODE).NE.0) THEN
C        --- CAS OU JNODE EST DEJA UN VIS-A-VIS ---
            IP = ZI(LLISTB-1+JNODE)
            INU    = ZI(LLINT1-1+I)
            NUNO   = ZI(LDESC1-1+INU)
            CALL JENUNO(JEXNUM(MAIL1//'.NOMNOE',NUNO),NOMNOI)
            INU    = ZI(LLINT2-1+JNODE)
            NUNO   = ZI(LDESC2-1+INU)
            CALL JENUNO(JEXNUM(MAIL2//'.NOMNOE',NUNO),NOMNOJ)
            INU    = ZI(LLINT1-1+IP)
            NUNO   = ZI(LDESC1-1+INU)
            CALL JENUNO(JEXNUM(MAIL1//'.NOMNOE',NUNO),NOMNOP)
            CALL UTDEBM('F','VECOMO','CONFLIT DANS LES VIS_A_VIS '//
     +                  'DES NOEUDS')
            CALL UTIMPK('L','LE NOEUD ',1,NOMNOJ)
            CALL UTIMPK('S','EST LE VIS-A-VIS DES NOEUDS ',1,NOMNOP)
            CALL UTIMPK('S','ET ',1,NOMNOI)
            CALL UTFINM()
         ENDIF
         ZI(LLISTB-1+JNODE) = I
C        SI JNODE EST DIFFERENT DE I, C'EST QUE LES NOEUDS D'INTERFACE
C        ONT ETE DONNES DANS UN ORDRE DE NON CORRESPONDANCE
         IF (JNODE.NE.I) ORDRE = .FALSE.
C
20    CONTINUE
C
C-----VERIFICATION FINALE
C
        IF (ICRIT.EQ.1) THEN
          IF (LCARAM.EQ.0.D0) THEN
            CALL UTDEBM('F',PGC,'LE CRITERE DE VERIFICATION NE PEUT'
     &  //' ETRE RELATIF DANS VOTRE CAS, LA LONGUEUR CARACTERISTIQUE'
     &  //' DE L''INTERFACE DE LA SOUS-STRUCTURE ETANT NULLE.')
            CALL UTIMPK('L',' SOUS-STRUCTURE 1 --> ',1,SST1)
            CALL UTIMPK('L',' INTERFACE 1      --> ',1,INTF1)
            CALL UTIMPK('L',' SOUS-STRUCTURE 2 --> ',1,SST2)
            CALL UTIMPK('L',' INTERFACE 2      --> ',1,INTF2)
            CALL UTFINM
          ENDIF
          DXRM=DXRM/LCARAM
        ENDIF
        IF (DXRM.GT.DIFMAX) THEN
          CALL UTDEBM('F',PGC,'LES INTERFACES NE SONT PAS COMPATIBLES')
          CALL UTIMPK('L',' SOUS-STRUCTURE 1 --> ',1,SST1)
          CALL UTIMPK('L',' INTERFACE 1      --> ',1,INTF1)
          CALL UTIMPK('L',' SOUS-STRUCTURE 2 --> ',1,SST2)
          CALL UTIMPK('L',' INTERFACE 2      --> ',1,INTF2)
          CALL UTFINM
        ENDIF
        IF (.NOT.ORDRE) THEN
C       --- LES NOEUDS NE SONT PAS EN VIS-A-VIS ---
C           ON REGARDE D'ABORD SI LE TRI EST PLAUSIBLE
          DO 130 I = 1,NBNO
             IF (ZI(LLISTB-1+ZI(LLISTA-1+I)).NE.I) THEN
                CALL UTDEBM('F',PGC,'LES INTERFACES NE SONT PAS '//
     &                              'COMPATIBLES')
                CALL UTIMPK('L',' SOUS-STRUCTURE 1 --> ',1,SST1)
                CALL UTIMPK('L',' INTERFACE 1      --> ',1,INTF1)
                CALL UTIMPK('L',' SOUS-STRUCTURE 2 --> ',1,SST2)
                CALL UTIMPK('L',' INTERFACE 2      --> ',1,INTF2)
                CALL UTFINM
             ENDIF
  130     CONTINUE
C
          CALL UTDEBM('A',PGC,'LES NOEUDS DES INTERFACES NE SONT PAS'//
     &                 ' ALIGNES EN VIS-A-VIS')
          CALL UTIMPK('L',' SOUS-STRUCTURE 1 --> ',1,SST1)
          CALL UTIMPK('L',' INTERFACE 1      --> ',1,INTF1)
          CALL UTIMPK('L',' SOUS-STRUCTURE 2 --> ',1,SST2)
          CALL UTIMPK('L',' INTERFACE 2      --> ',1,INTF2)
          CALL UTIMPK('L','LES NOEUDS ONT ETE REORDONNES',1,' ')
          CALL UTFINM
C    ---  ON ORDONNE LES NOEUDS DE LLINT2 SUIVANT LLISTA
          DO 140 I=1,NBNO
C         --- RECOPIE DE LLINT2 DANS LLISTB
             ZI(LLISTB-1+I) = ZI(LLINT2-1+I)
  140     CONTINUE
          DO 150 I=1,NBNO
             ZI(LLINT2-1+I) = ZI(LLISTB-1+ZI(LLISTA-1+I))
  150     CONTINUE
C    ---  ON REORDONNE LES CODES DE CONDITIONS AUX LIMITES
C         AFIN D'AVOIR UNE VERIFICATION CORRECTE DANS VERILI
          CALL JENONU(JEXNOM(LINT2//'      .INTD.NOMS',INTF2),IBID)
          CALL JEVEUO(JEXNUM(LINT2//'      .INTD.DDAC',IBID),'E',LDAC2)
          DO 160 I=1,NBNO
C         --- RECOPIE DE LDAC2 DANS LLISTB
             ZI(LLISTB-1+I) = ZI(LDAC2-1+I)
  160     CONTINUE
          DO 170 I=1,NBNO
             ZI(LDAC2-1+I) = ZI(LLISTB-1+ZI(LLISTA-1+I))
  170     CONTINUE
C
        ENDIF
C
C       --- DESTRUCTION OBJETS SUR VOLATILE
        CALL JEDETR('&&VECOMO.LISTA')
        CALL JEDETR('&&VECOMO.LISTB')
C
 9999 CONTINUE
      CALL JEDEMA()
      END
