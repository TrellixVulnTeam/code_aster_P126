      SUBROUTINE UTNONO ( MESS, NOMMA, TYPE, NOMGRP, NOMOBJ, IRET )
      IMPLICIT   NONE
      CHARACTER*8               NOMMA,       NOMGRP, NOMOBJ
      CHARACTER*(*)       MESS,        TYPE
      INTEGER                                                IRET
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 19/08/97   AUTEUR CIBHHGB G.BERTRAND 
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
C
C     RENVOIE LE PREMIER NOEUD OU MAILLE CONTENU DANS UN GROUP_NO
C             OU UN GROUP_MA
C
C IN  : MESS   : TYPE DE MESSAGE UE L'ON VEUT IMPRIMER
C                'F'  MESSAGE FATAL
C                'E'  MESSAGE ERREUR
C                ' '  LE CODE RETOUR EST GERE PAR LE DEVELOPPEUR
C IN  : NOMMA  : NOM DU MAILLAGE.
C IN  : TYPE   : TRAITEMENT MAILLE OU NOEUD
C IN  : NOMGRP : NOM D'UN GROUP_NO OU D'UN GROUP_MA
C OUT : NOMOBJ : NOM DU NOEUD OU DE LA MAILLE
C OUT : IRET   : CODE RETOUR 
C                 0 --> OK 
C                10 --> LE GROUPE N'EXISTE PAS
C                 1 -->  PLUSIEURS NOEUDS OU MAILLES DANS LE GROUPE 
C ----------------------------------------------------------------------
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER           ZI
      COMMON / IVARJE / ZI(1)
      REAL*8            ZR
      COMMON / RVARJE / ZR(1)
      COMPLEX*16        ZC
      COMMON / CVARJE / ZC(1)
      LOGICAL           ZL
      COMMON / LVARJE / ZL(1)
      CHARACTER*8       ZK8
      CHARACTER*16              ZK16
      CHARACTER*24                       ZK24
      CHARACTER*32                                ZK32
      CHARACTER*80                                         ZK80
      COMMON / KVARJE / ZK8(1), ZK16(1), ZK24(1), ZK32(1), ZK80(1)
      CHARACTER*32      JEXNUM, JEXNOM
C
      INTEGER      IRET1, NBNO, IAD
      CHARACTER*1  TYPM
      CHARACTER*8  K8B, KNBNO
      CHARACTER*16 TYPGRP, NOM
C
      CALL JEMARQ()
      IRET = 10
      TYPM = MESS(1:1)
      NOMOBJ = ' '
C
      IF ( TYPE(1:5) .EQ. 'NOEUD' ) THEN
         TYPGRP = '.GROUPENO       '
         NOM    = '.NOMNOE         '
      ELSEIF ( TYPE(1:6) .EQ. 'MAILLE' ) THEN
         TYPGRP = '.GROUPEMA       '
         NOM    = '.NOMMAI         '
      ELSE
         GOTO 9999
      ENDIF
C
      CALL JEEXIN(JEXNOM(NOMMA//TYPGRP,NOMGRP),IRET1)
      IF ( IRET1 .EQ. 0 ) THEN
         IF ( TYPM .EQ. ' ' ) GOTO 9999
         IF ( TYPE(1:5) .EQ. 'NOEUD' ) THEN
            CALL UTMESS(TYPM,'UTNONO','LE GROUP_NO '//NOMGRP//
     +                                ' N''EXISTE PAS.')
         ELSE
            CALL UTMESS(TYPM,'UTNONO','LE GROUP_MA '//NOMGRP//
     +                                ' N''EXISTE PAS.')
         ENDIF
         GOTO 9999
      ENDIF
C
      IRET = 0
      CALL JELIRA(JEXNOM(NOMMA//TYPGRP,NOMGRP),'LONMAX',NBNO,K8B)
      IF ( NBNO .NE. 1 ) THEN
         IRET = 1
         IF ( TYPM .EQ. 'F'  .OR.  TYPM .EQ. 'E' ) THEN
            CALL CODENT( NBNO, 'D', KNBNO )
            IF ( TYPE(1:5) .EQ. 'NOEUD' ) THEN
               CALL UTMESS(TYPM,'UTNONO','LE GROUP_NO '//NOMGRP//
     +                                  ' CONTIENT '//KNBNO//' NOEUDS')
            ELSE
               CALL UTMESS(TYPM,'UTNONO','LE GROUP_MA '//NOMGRP//
     +                                  ' CONTIENT '//KNBNO//' MAILLES')
            ENDIF
            GOTO 9999
         ENDIF
      ENDIF
C
      CALL JEVEUO(JEXNOM(NOMMA//TYPGRP,NOMGRP),'L',IAD)
      CALL JENUNO(JEXNUM(NOMMA//NOM,ZI(IAD)),NOMOBJ)
C
 9999 CONTINUE
      CALL JEDEMA()
      END
