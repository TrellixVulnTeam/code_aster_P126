      SUBROUTINE OP0169(IER)
      IMPLICIT REAL*8 (A-H,O-Z)
      INTEGER           IER
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 14/05/2002   AUTEUR DURAND C.DURAND 
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
C     OPERATEUR FONC_FLUI_STRU
C     CREATION D UNE FONCTION CONSTANTE (CONCEPT FONCTION) DONNANT
C     LA VALEUR DU COEFFICIENT DE MASSE AJOUTEE
C     ------------------------------------------------------------------
C OUT IER = 0 => TOUT S'EST BIEN PASSE
C     IER > 0 => NOMBRE D'ERREURS RENCONTREES
C     ------------------------------------------------------------------
C     OBJETS SIMPLES CREES:
C        NOMFON//'.PROL'
C        NOMFON//'.VALE
C     ------------------------------------------------------------------
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
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
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
C
      CHARACTER*8  TYPFON
      CHARACTER*16 CMD
      CHARACTER*19 NOMFON,TYPFLU
      CHARACTER*24 FSIC, FSVR, PROL, VALE
C     ------------------------------------------------------------------
      CALL JEMARQ()
C
      CALL GETRES(NOMFON,TYPFON,CMD)
      CALL GETVID(' ','TYPE_FLUI_STRU',0,1,1,TYPFLU,IBID)
C
C --- VERIFICATION A L EXECUTION
      FSIC = TYPFLU//'.FSIC'
      CALL JEVEUO(FSIC,'L',LFSIC)
      IF (ZI(LFSIC).NE.1) THEN
        CALL UTMESS('F',CMD,'L UTILISATION DE CETTE COMMANDE N EST '//
     &              'LEGITIME QUE SI LA CONFIGURATION ETUDIEE EST DU '//
     &              'TYPE "FAISCEAU_TRANS"')
      ENDIF
C
C --- CREATION ET REMPLISSAGE DE L'OBJET NOMFON.PROL
      PROL = NOMFON//'.PROL'
      CALL WKVECT(PROL,'G V K8',5,LPROL)
      ZK8(LPROL)   = 'CONSTANT'
      ZK8(LPROL+1) = 'LIN LIN '
      ZK8(LPROL+2) = 'ABSC    '
      ZK8(LPROL+3) = 'COEF_MAS'
      ZK8(LPROL+4) = 'CC      '
C
C --- CREATION ET REMPLISSAGE DE L'OBJET NOMFON.VALE
      FSVR = TYPFLU//'.FSVR'
      CALL JEVEUO(FSVR,'L',LFSVR)
C
      VALE = NOMFON//'.VALE'
      CALL WKVECT(VALE,'G V R',2,LVALE)
      ZR(LVALE)   = 1.0D0
      ZR(LVALE+1) = ZR(LFSVR)
C
      CALL JEDEMA()
      END
