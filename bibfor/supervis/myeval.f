      SUBROUTINE MYEVAL(SOURCE,ICLASS,IVAL,RVAL,IER)
      IMPLICIT NONE
      CHARACTER*(*)     SOURCE
      INTEGER      IVAL,ICLASS
      REAL*8       RVAL(2)
      INTEGER                         IER
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF SUPERVIS  DATE 13/02/2001   AUTEUR DURAND C.DURAND 
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
C     ------------------------------------------------------------------
C IN  SOURCE : K*  : EXPRESSION A EVALUER
C OUT ICLASS : I   : TYPE DU RESULTAT
C OUT IVAL   : I   : VALEUR ENTIERE
C OUT RVAL   : R   : VALEUR RELLE OU COMPLEXE
C OUT IER    : I   : CODE D ERREUR <0 => ERREUR
C     ------------------------------------------------------------------
C
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER          ZI
      COMMON  /IVARJE/ ZI(1)
      REAL*8           ZR
      COMMON  /RVARJE/ ZR(1)
      COMPLEX*16       ZC
      COMMON  /CVARJE/ ZC(1)
      LOGICAL          ZL
      COMMON  /LVARJE/ ZL(1)
      CHARACTER*8      ZK8
      CHARACTER*16            ZK16
      CHARACTER*24                    ZK24
      CHARACTER*32                            ZK32
      CHARACTER*80                                    ZK80
      COMMON  /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
C     ------- COMMUN FORMULE
      CHARACTER*80 CARTE
      COMMON /LXCC02/    CARTE
      INTEGER            ILECT, IECR, LRECL, IEOF, ICOL, ILIG
      COMMON /LXCN02/    ILECT, IECR, LRECL, IEOF, ICOL, ILIG

      INTEGER NOMBRE
      PARAMETER(NOMBRE=20)
      CHARACTER*80 FTEXT(NOMBRE)
      COMMON /CXFO01/FTEXT

      INTEGER        LPOS
      COMMON /CXFO00/LPOS
C
C     ------------------------------------------------------------------

      INTEGER      N , DEBUT , FIN , ICSTE
      CHARACTER*8  KBID
      CHARACTER*19 RESUFI
C     ------------------------------------------------------------------
      IEOF = 0
      CALL JEMARQ()
      RESUFI = '&&FIEVAL.FI.EVAL'
      IF( LEN(SOURCE).GT.NOMBRE*LEN(FTEXT(1)) ) THEN
CCCCC      WRITE(6,*)'++++ MYEVAL.F : SOURCE=',SOURCE
CCCCC      WRITE(6,*)'++++ MYEVAL.F : LEN(SOURCE)=',LEN(SOURCE)
CCCCC      WRITE(6,*)'++++ MYEVAL.F : LEN(FTEXT(1))=',LEN(FTEXT(1))
CCCCC      WRITE(6,*)'++++ ERREUR 1 DANS MYEVAL.F'
           CALL UTMESS('E','SUPERVISEUR.(ERREUR.MYEVAL.01)',
     +                 'ZONE FTEXT TROP PETITE POUR STOCKER SOURCE')
           CALL JXABOR()
      ENDIF

C AY :AVANT      FTEXT(1)=SOURCE
C AY :COPIE DE LA GRANDE CHAINE SOURCE DANS LES "NOMBRE" PETITES CHAINES
C      FTEXT
      N = 0
      DO 100 DEBUT = 1, LEN(SOURCE) , LEN(FTEXT(1))
           N=N+1
           FTEXT(N) = ' '
           FIN = MIN((DEBUT+LEN(FTEXT(1))-1),LEN(SOURCE))
           FTEXT(N) = SOURCE(DEBUT:FIN)
 100  CONTINUE


C LXLIRE LIT DANS FTEXT
      LPOS=1
      ICOL=LRECL+1
      ILIG=0
      CALL FIRMPQ('LONUTI',ICSTE)
      CALL FIPREP('EVAL',RESUFI,'L',KBID,IER)
C LXLIRE LIT DANS LES FICHIERS SPECIFIES PAR LXUNIT
      LPOS=0
      IF ( IER .EQ. 0 ) THEN
         CALL FIOPER('F',RESUFI,ICLASS,IVAL,RVAL,IER)
      ENDIF
      CALL JEDETR(RESUFI//'.POLO')
      CALL JEDETR(RESUFI//'.INFX')
      CALL JEDETR(RESUFI//'.NOVA')
      CALL JEDETR(RESUFI//'.ADVA')
      CALL FIRMPQ('NEW_LONUTI',ICSTE)
      CALL JEDEMA()
      END
