      SUBROUTINE PREFLX(GRAEXC,MAILLA,CHAMAT,CELEM,NPDSC3,
     & IADSC3,NINDEX,ILNOEX,LIFEX2)
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
C    C. DUVAL
C-----------------------------------------------------------------------
C  BUT: MODIFIER L INTERSPECTRE EXCITATION POUR BIEN REPRESENTER LES
      IMPLICIT REAL*8 (A-H,O-Z)
C      SOURCES FLUIDES EXCITATION
C        (CALCUL DYNAMIQUE ALEATOIRE)
C
C-----------------------------------------------------------------------
C
C GRAEXC   /IN /: GRANDEUR EXCITATION
C MAILLA   /IN /: CONCEPT MAILLAGE
C CHAMAT   /IN /: CONCEPT CHAMP_MATER
C CELEM    /IN /: CONCEPT CARA_ELEM
C NPDSC3   /IN /: NOMBRE DE FREQUENCES DANS LA DISCRETISATION
C IADSC3   /IN /: POINTEUR DANS ZR DU DEBUT DES FREQUENCES DISCRETISEES
C NINDEX   /IN /: NOMBRE D INDICE UTILES DANS L INTESPECTRE EXCITATION
C ILNOEX   /IN /: POINTEUR DANS ZK8 DES NOEUDS EXCITATION
C LIFEX2   /IN /: TABLEAU DES ADRESSES DES DEBUTS D INTERSP
C                 EXCITATION
C LIFEX2   /OUT/: IDEM
C
C-------- DEBUT COMMUNS NORMALISES  JEVEUX  ----------------------------
C
      INTEGER          ZI
      COMMON  /IVARJE/ZI(1)
      REAL*8          ZR
      COMMON  /RVARJE/ZR(1)
      COMPLEX*16      ZC
      COMMON  /CVARJE/ZC(1)
      LOGICAL         ZL
      COMMON  /LVARJE/ZL(1)
      CHARACTER*8     ZK8
      CHARACTER*16             ZK16
      CHARACTER*24                       ZK24
      CHARACTER*32                                 ZK32
      CHARACTER*80                                           ZK80
      COMMON  /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C
C
C----------  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
C
      CHARACTER*8   NMNOE1,NMNOE2,CHAMAT,CELEM,MAILLA,MATER,KBID
      CHARACTER*16  GRAEXC
      CHARACTER*24  K24BD1
      CHARACTER*32  JEXNOM,JEXNUM
      CHARACTER*24  LIFEX2, LIFEX3

C
      CALL JEMARQ()
      IF(GRAEXC(1:5).NE.'SOUR_') GOTO 9999
C
      PI=R8PI()
C
C
C----1----RECUPERATION DE RHO DX SECTFLUIDE POUR LES SOURCE FLUIDES
C
      CALL WKVECT('&&OP0131.RHO','V V R8',NINDEX,IADRHO)
      CALL WKVECT('&&OP0131.DX','V V R8',NINDEX,IADDX)
      CALL WKVECT('&&OP0131.SECTFLUID','V V R8',2*NINDEX,IADSEC)
      DO  306 IEXC1=1,NINDEX
C
C-----ON RECHERCHE LA PREMIERE MAILLE CONTENANT LE NOEUD:IMAI1
C
        IF((GRAEXC.EQ.'SOUR_PRESS').OR.(GRAEXC.EQ.'SOUR_FORCE'))THEN
            INOE1=2*(IEXC1-1)+1
        ELSE
          INOE1=IEXC1
        ENDIF
        NMNOE1=ZK8(ILNOEX-1+INOE1)
        CALL JENONU(JEXNOM(MAILLA//'.NOMNOE',NMNOE1),INUNO1)
C
C----RECUPERATION DE DX DISTANCE ENTRE LES DEUX POINTS DE LA SOURCE
C
        IF((GRAEXC.EQ.'SOUR_PRESS').OR.(GRAEXC.EQ.
     &         'SOUR_FORCE'))THEN
C
          NMNOE2=ZK8(ILNOEX-1+INOE1+1)
          CALL JENONU(JEXNOM(MAILLA//'.NOMNOE',NMNOE2),INUNO2)
          CALL JEVEUO(MAILLA//'.COORDO    .VALE','L',IAD1)
          X1=ZR(IAD1-1+(INUNO1-1)*3+1)
          Y1=ZR(IAD1-1+(INUNO1-1)*3+2)
          Z1=ZR(IAD1-1+(INUNO1-1)*3+3)
          X2=ZR(IAD1-1+(INUNO2-1)*3+1)
          Y2=ZR(IAD1-1+(INUNO2-1)*3+2)
          Z2=ZR(IAD1-1+(INUNO2-1)*3+3)
          DX=SQRT((X2-X1)**2+(Y2-Y1)**2+(Z2-Z1)**2)
          ZR(IADDX-1+IEXC1)=DX
C
        ENDIF
C------------
        K24BD1=MAILLA//'.CONNEX'
        CALL JELIRA(K24BD1,'NUTIOC',INBMAI,KBID)
        DO 307 IMAI1=1,INBMAI
          CALL JEVEUO(JEXNUM(K24BD1,IMAI1),'L',IAD1)
          CALL JELIRA(JEXNUM(K24BD1,IMAI1),'LONMAX',INBNOE,KBID)
          DO 308 INOE1=1,INBNOE
            INUNO3=ZI(IAD1-1+INOE1)
            IF(INUNO1.EQ.INUNO3) THEN
              INOE2=100
              IF((GRAEXC.EQ.'SOUR_PRESS').OR.(GRAEXC.EQ.
     &              'SOUR_FORCE'))THEN
                DO 319 INOE2=1,INBNOE
                  INUNO4=ZI(IAD1-1+INOE2)
                  IF(INUNO2.EQ.INUNO4) GO TO 309
 319            CONTINUE
              ELSE
                GO TO 309
              ENDIF
            ENDIF
 308      CONTINUE
 307    CONTINUE
 309    CONTINUE
C
C-------ON RECUPERE LES SECTIONS FLUIDES DE LA MAILLE IMAI1
C
        IF(INOE1.LT.INOE2)THEN
          CALL RESECI(CELEM,IMAI1,ZR(IADSEC-1+2*(IEXC1-1)+1),
     &          ZR(IADSEC-1+2*(IEXC1-1)+2))
        ELSE
          CALL RESECI(CELEM,IMAI1,ZR(IADSEC-1+2*(IEXC1-1)+2),
     &    ZR(IADSEC-1+2*(IEXC1-1)+1))
        ENDIF
C
C
C--------ON RECHERCHE LE MATERIAU CORRESPONDANT AU GROUPE DE MAILLES
C        IL EST REPERE PAR SON NUMERO D ORDRE ILIEN1
C
        CALL JEVEUO(CHAMAT//'.CHAMP_MAT .DESC','L',IADESC)
        INLIEN=ZI(IADESC-1+3)
        DO 310 ILIEN1=1,INLIEN
          ICODE=ZI(IADESC+3-1+2*(ILIEN1-1)+1)
          IF(ICODE.EQ.1)THEN
C----- -----DANS CE CAS TOUTES LES MAILLES ONT LE MEME CHAMAT
            ILIEN2=1
            GO TO 311
          ELSEIF(ICODE.EQ.2)THEN
C
C----- -----DANS CE CAS LA MAILLE A ETE DEFINIE LORS DU MAILLA
C--------ON RECHERCHE LE PREMIER GROUP_MAI QUI CONTIENT LA MAILLE
C        ET QUI A UN MATERIAU AFFECTE
C
              CALL JELIRA(MAILLA//'.GROUPEMA','NUTIOC',INGRMA,KBID)
            DO 312 IGRMA1=1,INGRMA
              CALL JEVEUO(JEXNUM(MAILLA//'.GROUPEMA',IGRMA1),'L',IAD1)
              CALL JELIRA(JEXNUM(MAILLA//'.GROUPEMA',IGRMA1),'LONMAX',
     &             INBMAI,KBID)
              DO 313 IMAI2=1,INBMAI
                IMAI3=ZI(IAD1-1+IMAI2)
                IF(IMAI3.EQ.IMAI1)THEN
                  GO TO 314
                ENDIF
 313          CONTINUE
 312        CONTINUE
 314      CONTINUE
          IGRMA2=ZI(IADESC+3-1+2*ILIEN1)
            IF(IGRMA1.EQ.IGRMA2)THEN
              ILIEN2=ILIEN1
              GO TO 311
            ENDIF
          ELSEIF(ICODE.EQ.3)THEN
C----------DANS CE CAS LA MAILLE A ETE DEFINIE PAR AFFE_MATERIAU
            ILIMA=ZI(IADESC+3-1+2*ILIEN1)
            CALL JEVEUO(JEXNUM(CHAMAT//'.CHAMP_MAT .LIMA',ILIMA),'L',
     &           IADLMA)
            CALL JELIRA(JEXNUM(CHAMAT//'.CHAMP_MAT .LIMA',ILIMA),
     &          'LONMAX',NMALIM,KBID)
            DO 326 IMA1=1,NMALIM
              IF(ZI(IADLMA-1+IMA1).EQ.IMAI1)THEN
                ILIEN2=ILIEN1
                GO TO 311
              ENDIF
 326        CONTINUE
          ENDIF
 310    CONTINUE
 311   CONTINUE
C
C--------POUR LE LIEN ILIEN2 ON VA RECUPERER LE MATERIAU PUIS
C        LA MASSE VOLUMIQUE
C
       CALL JEVEUO(CHAMAT//'.CHAMP_MAT .VALE','L',IAD1)
       MATER=ZK8(IAD1-1+ILIEN2)
       K24BD1=MATER//'.FLUIDE    .VALK'
       CALL JEVEUO(K24BD1,'L',IAD1)
       CALL JELIRA(K24BD1,'LONMAX',INVALK,KBID)
        DO 317 IVALK1=1,INVALK
          KBID=ZK8(IAD1-1+IVALK1)
          IF(KBID(1:3).EQ.'RHO')THEN
           INURHO=IVALK1
           GO TO 318
          ENDIF
 317    CONTINUE
 318   CONTINUE
       K24BD1=MATER//'.FLUIDE    .VALR'
       CALL JEVEUO(K24BD1,'L',IAD1)
       RHO=ZR(IAD1-1+INURHO)
       ZR(IADRHO-1+IEXC1)=RHO
 306  CONTINUE
C
C---2-----MULTIPLICATION PAR LE BON COEF :
C          RHOI*RHOJ*OMEGA**2 POUR DEBIT VOLUME
C          OMEGA**2             POUR DEBIT MASSE
C          SECT1*SECT2/DX1/DX2  POUR SAUT DE PRESSION
C          1.         /DX1/DX2  POUR SAUT DE FORCE
C
C
      CALL JEVEUO(LIFEX2,'L',ILFEX2)
      DO 320 IAPP1=1,NINDEX
       DO 321 IAPP2=IAPP1,NINDEX
        IJ1=((IAPP2-1)*IAPP2)/2+IAPP1
        IAD1=ZI(ILFEX2-1+IJ1)
        DO 323 IFREQ1=1,NPDSC3
         IDEC1=NPDSC3+2*(IFREQ1-1)+1
         IF(GRAEXC.EQ.'SOUR_DEBI_VOLU')THEN
          RHO1=ZR(IADRHO-1+IAPP1)
          RHO2=ZR(IADRHO-1+IAPP2)
          OMEGA=ZR(IADSC3-1+IFREQ1)*2.D0*PI
          ZR(IAD1-1+IDEC1)=ZR(IAD1-1+IDEC1)*RHO1*RHO2*(OMEGA**2)
          ZR(IAD1-1+IDEC1+1)=ZR(IAD1-1+IDEC1+1)*RHO1*RHO2*(OMEGA**2)
         ELSEIF(GRAEXC.EQ.'SOUR_DEBI_MASS')THEN
          OMEGA=ZR(IADSC3-1+IFREQ1)*2.D0*PI
          ZR(IAD1-1+IDEC1)=ZR(IAD1-1+IDEC1)*(OMEGA**2)
          ZR(IAD1-1+IDEC1+1)=ZR(IAD1-1+IDEC1+1)*(OMEGA**2)
         ELSEIF(GRAEXC.EQ.'SOUR_PRESS')THEN
          SECT1=ZR(IADSEC-1+2*(IAPP1-1)+1)
          SECT2=ZR(IADSEC-1+2*(IAPP2-1)+1)
          DX1=ZR(IADDX-1+IAPP1)
          DX2=ZR(IADDX-1+IAPP2)
          ZR(IAD1-1+IDEC1)=ZR(IAD1-1+IDEC1)*SECT1*SECT2/DX1/DX2
          ZR(IAD1-1+IDEC1+1)=ZR(IAD1-1+IDEC1+1)*SECT1*SECT2/DX1/DX2
         ELSEIF(GRAEXC.EQ.'SOUR_FORCE')THEN
          DX1=ZR(IADDX-1+IAPP1)
          DX2=ZR(IADDX-1+IAPP2)
          ZR(IAD1-1+IDEC1)=ZR(IAD1-1+IDEC1)/DX1/DX2
          ZR(IAD1-1+IDEC1+1)=ZR(IAD1-1+IDEC1+1)/DX1/DX2
         ENDIF
 323    CONTINUE
 321   CONTINUE
 320  CONTINUE
C
C
C---3-----DUPLICATION DE L INTERSPECTRE DANS LE CAS DE SOURCE DE
C          PRESSION OU DE FORCE
C
      IF((GRAEXC.EQ.'SOUR_FORCE').OR.(GRAEXC.EQ.'SOUR_PRESS'))THEN
C
C
      INBFX3=(2*NINDEX*(2*NINDEX+1))/2
      LIFEX3 = '&&OP0131.LIADFX3'
      CALL WKVECT('&&OP0131.LIADFX3','V V I',INBFX3,ILFEX3)
      DO 322 IAPP1=1,2*NINDEX
       IPAR1=MOD(IAPP1,2)
       DO 324 IAPP2=IAPP1,2*NINDEX
        IPAR2=MOD(IAPP2,2)
        IF(IPAR1.EQ.IPAR2)THEN
         SIGN=1.D0
        ELSE
         SIGN=-1.D0
        ENDIF
        WRITE(K24BD1,'(A8,A3,2I4.4,A5)')'&&OP0131','.F3',IAPP1,IAPP2,
     &'.VALE'
        IJ1=(IAPP2*(IAPP2-1))/2+IAPP1
        CALL JECREO(K24BD1,'V V R8')
        CALL JEECRA(K24BD1,'LONMAX',NPDSC3*3,KBID)
        CALL JEECRA(K24BD1,'LONUTI',NPDSC3*3,KBID)
        CALL JEVEUT(K24BD1,'E',ZI(ILFEX3-1+IJ1))
        IADFX3=ZI(ILFEX3-1+IJ1)
        IAPP1B=(IAPP1+IPAR1)/2
        IAPP2B=(IAPP2+IPAR2)/2
        IJ2=(IAPP2B*(IAPP2B-1))/2+IAPP1B
        IADFX2=ZI(ILFEX2-1+IJ2)
        DO 325 IFREQ1=NPDSC3+1,3*NPDSC3
         ZR(IADFX3-1+IFREQ1)=ZR(IADFX2-1+IFREQ1)*SIGN
 325    CONTINUE
 324  CONTINUE
 322  CONTINUE
      LIFEX2=LIFEX3
C
      ENDIF
 9999 CONTINUE
      CALL JEDEMA()
      END
