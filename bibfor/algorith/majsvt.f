      SUBROUTINE MAJSVT (SIGMOI,SIGPLU,VARMOI,VARPLU,COMMOI,COMPLU)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 31/08/1999   AUTEUR VABHHTS J.PELLET 
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
      IMPLICIT REAL*8 (A-H,O-Z)
      CHARACTER*24   SIGMOI,SIGPLU,VARMOI,VARPLU,COMMOI,COMPLU
C ----------------------------------------------------------------------
C     D Y N A M I Q U E  N O N  L I N E A I R E
C
C   MISE A JOUR DES CONTRAINTES VARIABLES INTERNES ET
C   VARIABLES DE COMMANDE EN DEBUT DE PAS
C
C OUT
C OUT
C OUT
C
      CHARACTER*8    K8BID,TYPE
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
      CHARACTER*32       JEXNUM , JEXNOM , JEXR8 , JEXATR
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
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------
C
C*** CONTRAINTES
      CALL JEMARQ()
      CALL DISMOI('F','TYPE_CHAMP',SIGMOI,'CHAMP',IBID,TYPE,IER)
      IF ( TYPE .EQ . 'CART') THEN
         CALL DETRSD ('CHAMP_GD',SIGMOI(1:19))
         CALL COPISD('CHAMP_GD','V',SIGPLU(1:19),SIGMOI(1:19))
      ELSE
         CALL JEVEUO (SIGMOI(1:19)//'.CELV','E',JSIGM)
         CALL JEVEUO (SIGPLU(1:19)//'.CELV','L',JSIGP)
         CALL JELIRA (SIGPLU(1:19)//'.CELV','LONMAX',LONSIG,K8BID)
         DO 20 I=1,LONSIG
            ZR(JSIGM+I-1) = ZR(JSIGP+I-1)
20       CONTINUE
      ENDIF
C
C*** VARIABLES
      CALL DISMOI('F','TYPE_CHAMP',VARMOI,'CHAMP',IBID,TYPE,IER)
      IF ( TYPE .EQ . 'CART') THEN
         CALL DETRSD ('CHAMP_GD',VARMOI(1:19))
         CALL COPISD('CHAMP_GD','V',VARPLU(1:19),VARMOI(1:19))
      ELSE
         CALL JEVEUO (VARMOI(1:19)//'.CELV','E',JVARM)
         CALL JEVEUO (VARPLU(1:19)//'.CELV','L',JVARP)
         CALL JELIRA (VARPLU(1:19)//'.CELV','LONMAX',LONVAR,K8BID)
         DO 21 I=1,LONVAR
            ZR(JVARM+I-1) = ZR(JVARP+I-1)
21       CONTINUE
      ENDIF
C
C*** VARIABLES DE COMMANDE
      CALL COPISD('VARI_COM','V',COMPLU(1:14), COMMOI(1:14))
C FIN ------------------------------------------------------------------
      CALL JEDEMA()
      END
