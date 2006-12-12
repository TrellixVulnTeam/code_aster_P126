      SUBROUTINE OP0108 ( IER )
      IMPLICIT NONE
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 12/12/2006   AUTEUR VIVAN L.VIVAN 
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
C      OPERATEUR :     AFFE_CHAR_CINE_F
C
C      MOTS-CLES ACTUELLEMENT TRAITES:  MECA_IMPO
C                                       THER_IMPO
C
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
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
      CHARACTER*32 JEXNUM,JEXNOM,JEXR8,JEXATR
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------
      INTEGER       IER, IOCMI, IOCTI, N1, ITYPE, INOMO
      CHARACTER*8   CHCINE, MO, K8B
      CHARACTER*16  TYPE, OPER
      CHARACTER*24  CNOMO, CTYPE
C
      DATA CTYPE/'        .TYPE           '/
      DATA CNOMO/'        .CI  .MODEL.NOMO'/
C ======================================================================
C --- DEBUT
C
      CALL JEMARQ()
C
      CALL INFMAJ
C
C --- RECUPERATION DU RESULTAT
C
      CALL GETRES ( CHCINE, TYPE, OPER )
C
C --- RECUPERATION DU MODELE ET DU MAILLAGE ASSOCIE
C
      CALL GETVID ( ' ', 'MODELE', 1,1,1, MO, N1 )
C
C --- CREATION DU .TYPE ET DU .MODEL.NOMO
C
      CTYPE(1:8) = CHCINE
      CALL WKVECT(CTYPE,' G V K8',1,ITYPE)
      CNOMO(1:8)   = CHCINE
      CNOMO(12:13) = TYPE(11:12)
      CALL WKVECT(CNOMO,' G V K8',1,INOMO)
      ZK8(INOMO) = MO
C
C --- LECTURE DES OCCURENCES DES MOTCLES FACTEURS
C
      CALL GETFAC ( 'MECA_IMPO', IOCMI )
      IF ( IOCMI .NE. 0 ) THEN
         ZK8(ITYPE) = 'CIME_FO'
         CALL CHARCI ( CHCINE, 'MECA_IMPO', IOCMI, MO, 'F' )
      ENDIF
C
      CALL GETFAC ( 'THER_IMPO', IOCTI )
      IF ( IOCTI .NE. 0 ) THEN
         ZK8(ITYPE) = 'CITH_FO'
         CALL CHARCI ( CHCINE, 'THER_IMPO', IOCTI, MO, 'F' )
      ENDIF
C
      CALL JEDEMA()
      END
