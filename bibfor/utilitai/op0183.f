      SUBROUTINE OP0183 ( IERR )
      IMPLICIT   NONE
      INTEGER             IERR
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 05/10/2004   AUTEUR REZETTE C.REZETTE 
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
C   - FONCTION REALISEE:
C       APPEL D'UN EXECUTABLE EXTERNE : L'UTILISATEUR DOIT FOURNIR
C       LE NOM COMPLET DU SCRIPT DE LANCEMENT OU DE L'EXECUTABLE
C   - OUT :
C       IERR   : +1 SI ERREUR AVEC L'APPLICATION EXTERNE
C
C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------
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
C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------
C
      INTEGER NBPAR,K,KK,IERRC,NK1,JNOM,IFM,NIV
C DEB ------------------------------------------------------------------
      CALL JEMARQ()
      CALL INFMAJ()
      CALL INFNIV(IFM,NIV)
C
      CALL GETFAC('ARGUMENT',NBPAR)
      CALL WKVECT('&&OP0183_NOM','V V K80',NBPAR+1,JNOM)
C
      CALL GETVTX('        ','LOGICIEL' ,0,1,1,ZK80(JNOM),NK1)
C
      DO 100 K=1,NBPAR
        CALL GETVTX('ARGUMENT','NOM_PARA' ,K,1,1,ZK80(JNOM+K),NK1)
100   CONTINUE

C
      CALL APLEXT(NIV,NBPAR+1,ZK80(JNOM),IERRC)
C
      IF (IERRC .NE. 0) THEN
         CALL UTMESS('F','EXEC_LOGICIEL','CODE RETOUR NON NUL DETECTE')
      ENDIF
      CALL JEDEMA()
C
C FIN ------------------------------------------------------------------
      END
