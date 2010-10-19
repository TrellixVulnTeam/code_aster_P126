      SUBROUTINE LISCPY(LISCHA,LISCH2,BASE  )
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 19/10/2010   AUTEUR COURTOIS M.COURTOIS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2009  EDF R&D                  WWW.CODE-ASTER.ORG
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
C
      IMPLICIT NONE
      CHARACTER*19  LISCHA,LISCH2
      CHARACTER*1   BASE
C
C ----------------------------------------------------------------------
C
C ROUTINE UTILITAIRE (LISTE_CHARGES)
C
C COPIE DE LA SD LISTE_CHARGES
C
C ----------------------------------------------------------------------
C
C ON RECOPIE SANS PRENDRE LES ELEMENTS TARDIFS POUR ETRE COMPATIBLE
C AVEC CALC_ELEM/CALC_NO
C
C IN  LISCHA : NOM DE LA SD LISTE_CHARGES SOURCE
C IN  BASE   : BASE DE CREATION DE LA SD DESTINATION
C OUT LISCH2 : NOM DE LA SD LISTE_CHARGES DESTINATION
C
C -------------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ----------------
C
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
C
C -------------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ----------------
C
      CHARACTER*24 CHARGE,INFCHA,FOMULT
      INTEGER      JALICH,JINFCH,JALIFC
      INTEGER      NCHAR,ICH,ICH2,NCHAR2,IVAL,ITYP
      CHARACTER*8  NOMCHA,NOMFCT
C --- NOMBRE MAXIMUM DE TYPE_INFO
      INTEGER      NBINMX,NBINFO
      PARAMETER   (NBINMX=99) 
      CHARACTER*24 LISINF(NBINMX)           
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- ACCES SD
C
      CHARGE = LISCHA(1:19)//'.LCHA'
      INFCHA = LISCHA(1:19)//'.INFC'
      FOMULT = LISCHA(1:19)//'.FCHA'
C      
      CALL JEVEUO(CHARGE,'L',JALICH)
      CALL JEVEUO(INFCHA,'L',JINFCH)
      CALL JEVEUO(FOMULT,'L',JALIFC)
C      
      IF(ZI(JINFCH).EQ.0)THEN
          CALL LISCCR(LISCH2,1,BASE)
          CALL JEVEUO(LISCH2(1:19)//'.INFC','E',JINFCH)
          ZI(JINFCH) = 0
          GOTO 999
      ELSE
         CALL LISNCH(LISCHA,NCHAR )
         NCHAR2 = NCHAR
      ENDIF
      
      DO 24 ICH=1,NCHAR
        ITYP   = ZI(JINFCH+NCHAR+ICH) 
        IF (ITYP.EQ.10) THEN
          NCHAR2 = NCHAR2-1
        ENDIF
   24 CONTINUE
     
      CALL ASSERT(NCHAR2.GT.0)
      CALL ASSERT(NCHAR2.LE.NCHAR)
C
      CALL LISCCR(LISCH2,NCHAR2,BASE  )
C
      ICH2 = 1
      DO 25 ICH=1,NCHAR
        NOMCHA = ZK24(JALICH+ICH-1) (1:8)  
        ITYP   = ZI(JINFCH+NCHAR+ICH)   
        IF (ITYP.NE.10) THEN
          NBINFO = NBINMX
          CALL LISCLI(LISCHA,ICH   ,NOMCHA,NOMFCT,NBINFO,
     &                LISINF,IVAL  )
          CALL LISCAD(LISCH2,ICH2  ,NOMCHA,NOMFCT,NBINFO,
     &                LISINF,IVAL  )        

          ICH2 = ICH2 + 1
        ENDIF
   25 CONTINUE
C
      CALL ASSERT(NCHAR2.EQ.(ICH2-1))
C  
 999  CONTINUE
      CALL JEDEMA()
      END
