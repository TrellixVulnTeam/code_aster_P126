      SUBROUTINE DCHLMX(OPT,LIGREL,NOMPAR,NIN,LPAIN,NOUT,LPAOUT,
     &          ICODE,TAILLE)
      IMPLICIT NONE

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 30/01/2002   AUTEUR VABHHTS J.TESELET 
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
C RESPONSABLE                            VABHHTS J.PELLET
C     ARGUMENTS:
C     ----------
      INTEGER OPT,NIN,NOUT,TAILLE
      CHARACTER*19 LIGREL
      CHARACTER*8 NOMPAR
      CHARACTER*8 LPAIN(*),LPAOUT(*)
C ----------------------------------------------------------------------
C     ENTREES:
C      OPT : OPTION
C     LIGREL: LIGREL
C     NOMPAR: NOM DU PARAMETRE

C     SORTIES:
C     TAILLE: DIMENSION MAXIMALE D'UN CHAMP_LOC (NOMPAR)
C             =MAX(DIMENSION_D_UN_ELEMENT)*NBEL(IGR))
C             =0 => AUCUN TYPE_ELEM NE CONNAIT LE PARAMETRE NOMPAR
C     ICODE:  0  => AUCUN TYPE_ELEM NE CONNAIT LE PARAMETRE NOMPAR
C             1  => NOMPAR EST DE TYPE 'ELEM'
C             2  => NOMPAR EST DE TYPE 'ELNO'
C             3  => NOMPAR EST DE TYPE 'ELGA'
C             4  => NOMPAR EST DE TYPE 'VECTEUR'
C             5  => NOMPAR EST DE TYPE 'MATRICE'
C ----------------------------------------------------------------------

      COMMON /CAII04/IACHII,IACHIK,IACHIX
      COMMON /CAII07/IACHOI,IACHOK
      COMMON /CAII02/IAOPTT,LGCO,IAOPMO,ILOPMO,IAOPNO,ILOPNO,IAOPDS,
     +       IAOPPA,NPARIO,NPARIN,IAMLOC,ILMLOC,IADSGD
C---------------- COMMUNS NORMALISES  JEVEUX  --------------------------
      CHARACTER*32 JEXNUM,JEXNOM,JEXATR,JEXR8
      COMMON /IVARJE/ZI(1)
      COMMON /RVARJE/ZR(1)
      COMMON /CVARJE/ZC(1)
      COMMON /LVARJE/ZL(1)
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      INTEGER ZI
      REAL*8 ZR
      COMPLEX*16 ZC
      LOGICAL ZL
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
C ---------------- FIN COMMUNS NORMALISES  JEVEUX  --------------------
      INTEGER NBGREL,TYPELE,NBPARA,MODATT,DIGDE2,MAX,INDIK8,NBELEM
      INTEGER IACHII,IACHIK,IACHIX,IACHOI,IACHOK
      INTEGER IPARIN,IPAROU,JCELD
      INTEGER LGGREL,NBELGR,NGREL,NPIN,NPOU
      INTEGER IGR,TE,IPAR,NVAL,MODE,ICODE,ICOD1
      INTEGER IAOPTT,LGCO,IAOPMO,ILOPMO,IAOPNO,ILOPNO,IAOPDS,IAOPPA
      INTEGER NPARIO,NPARIN,IAMLOC,ILMLOC,IADSGD
      CHARACTER*8 NOPARA,TYCH
      CHARACTER*8 NOPARE

C DEB-------------------------------------------------------------------

      TAILLE = 0
      ICODE=0
      NGREL = NBGREL(LIGREL)
      DO 30 IGR = 1,NGREL
        TE = TYPELE(LIGREL,IGR)
        NBELGR = NBELEM(LIGREL,IGR)
        NPIN = NBPARA(OPT,TE,'IN ')
        NPOU = NBPARA(OPT,TE,'OUT')
        ICOD1=0

C           ---IN:
C           ------
        DO 10 IPAR = 1,NPIN
          NOPARE = NOPARA(OPT,TE,'IN ',IPAR)
          IF (NOPARE.EQ.NOMPAR) THEN
            IPARIN = INDIK8(LPAIN,NOMPAR,1,NIN)
            MODE = MODATT(OPT,TE,'IN ',IPAR)
            ICOD1 = ZI(IAMLOC - 1 + ZI(ILMLOC-1+MODE) -1+1)
            NVAL = DIGDE2(MODE)
            TYCH = ZK8(IACHIK-1+2* (IPARIN-1)+1)

C           CAS DES CHAM_ELEM :
            IF (TYCH(1:4).EQ.'CHML') THEN
C   ATTENTION : CETTE PROGRAMMATION SUPPOSE QUE LE MODE ATTENDU
C               EST LE MEME QUE CELUI DU CHAMP GLOBAL
C               (CE QUI EST ACTUELLEMNT VERIFIE PAR EXCHML)
              JCELD = ZI(IACHII-1+11* (IPARIN-1)+4)
              LGGREL = ZI(JCELD-1+ZI(JCELD-1+4+IGR)+4)
              TAILLE = MAX(TAILLE,LGGREL)
            ELSE
              TAILLE = MAX(TAILLE,NVAL*NBELGR)
            END IF

            GO TO 29
          END IF
   10   CONTINUE

C           ---OUT:
C           ------
        DO 20 IPAR = 1,NPOU
          NOPARE = NOPARA(OPT,TE,'OUT',IPAR)
          IF (NOPARE.EQ.NOMPAR) THEN
            IPAROU = INDIK8(LPAOUT,NOMPAR,1,NOUT)
            MODE = MODATT(OPT,TE,'OUT',IPAR)
            ICOD1 = ZI(IAMLOC - 1 + ZI(ILMLOC-1+MODE) -1+1)
            NVAL = DIGDE2(MODE)
            TYCH = ZK8(IACHOK-1+2* (IPAROU-1)+1)

C           CAS DES CHAM_ELEM :
            IF (TYCH(1:4).EQ.'CHML') THEN
              JCELD = ZI(IACHOI-1+2* (IPAROU-1)+1)
              LGGREL = ZI(JCELD-1+ZI(JCELD-1+4+IGR)+4)
              TAILLE = MAX(TAILLE,LGGREL)
            ELSE
              TAILLE = MAX(TAILLE,NVAL*NBELGR)
            END IF

            GO TO 29
          END IF
   20   CONTINUE

   29   CONTINUE
        IF (ICOD1.GT.0) THEN
           IF (ICODE.EQ.0) THEN
             ICODE=ICOD1
           ELSE
             IF (ICOD1.NE.ICODE) CALL UTMESS('F','DIGDEL',
     &     'INCOHERENCE DES TYPES DE MODES LOCAUX ENTRE LES GRELS.')
           END IF
        END IF

   30 CONTINUE
   40 CONTINUE
      END
