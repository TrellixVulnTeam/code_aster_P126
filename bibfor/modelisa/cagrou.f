      SUBROUTINE CAGROU(FONREZ, CHARGZ)
      IMPLICIT REAL*8 (A-H,O-Z)
      CHARACTER*(*)     FONREZ, CHARGZ
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 11/09/2000   AUTEUR DURAND C.DURAND 
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
C     TRAITER LE MOT CLE LIAISON_UNIF DE AFFE_CHAR_XXX
C     ET ENRICHIR LA CHARGE (CHARGE) AVEC LES RELATIONS LINEAIRES
C
C IN       : FONREZ : 'REEL' OU 'FONC' OU 'COMP'
C IN/JXVAR : CHARGZ : NOM D'UNE SD CHARGE
C ----------------------------------------------------------------------
C     ----------- COMMUNS NORMALISES  JEVEUX  --------------------------
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
      CHARACTER*32      JEXNOM, JEXNUM
C---------------- FIN COMMUNS NORMALISES  JEVEUX  ----------------------
C
      COMPLEX*16    BETAC, COEMUC(2)
      CHARACTER*2   TYPLAG
      CHARACTER*4   FONREE
      CHARACTER*4   TYPCOE
      CHARACTER*8   BETAF, DDL(2), NONO(2), CHARGE
      CHARACTER*8   K8BID
      CHARACTER*16  MOTFAC
      CHARACTER*19  LISREL
      CHARACTER*24  LISNOE
      REAL*8        COEMUR(2), DIRECT(6)
      INTEGER       IDIM(2)
      DATA  DIRECT /0.0D0, 0.0D0, 0.0D0, 0.0D0, 0.0D0, 0.0D0/
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      FONREE = FONREZ
      CHARGE = CHARGZ
C
      MOTFAC = 'LIAISON_UNIF'
      TYPLAG = '12'
C
      TYPCOE = 'REEL'
      IF (FONREE.EQ.'COMP') THEN
        TYPCOE = 'COMP'
      ENDIF
C
      LISREL = '&&CAGROU.RLLISTE'
      LISNOE = '&&CAGROU.NOEUD'
      CALL GETFAC(MOTFAC,NLIAI)
      IF (NLIAI.EQ.0) GOTO 9999
C
      CALL FOZERO('&FOZERO')
      BETAF =  '&FOZERO'
      BETAC  = (0.0D0,0.0D0)
      BETA   =  0.0D0
      COEMUC(1) =  (1.0D0,0.0D0)
      COEMUC(2) = (-1.0D0,0.0D0)
      COEMUR(1) =  1.0D0
      COEMUR(2) = -1.0D0
      IDIM(1)   =  0
      IDIM(2)   =  0
      LONLIM    =  0
C
      DO 10 IOCC = 1, NLIAI
C
C     -- ACUISITION DE LA LISTE DES NOEUDS A LIER :
C        (CETTE LISTE EST NON REDONDANTE)
C     ---------------------------------------------
         CALL MALINO(MOTFAC, CHARGE, IOCC, LISNOE, LONLIS)
         LONLIM = MAX(LONLIM,LONLIS)
         IF (LONLIS.LE.1) THEN
           CALL UTMESS('F','CAGROU',
     +     'POUR LIAISON_UNIF ENTRER PLUS DE UN NOEUD')
         ENDIF
C
         CALL JEVEUO(LISNOE, 'L', JLIST)
C
         CALL GETVTX (MOTFAC,'DDL',IOCC,1,0,K8BID,N1)
         IF ( N1.NE.0) THEN
              N1 = -N1
         ENDIF
C
        CALL WKVECT ('&&CAGROU.DDL','V V K8',N1,JDDL)
C
        CALL GETVTX (MOTFAC,'DDL',IOCC,1,N1,ZK8(JDDL),N2)
C
         NONO(1) = ZK8(JLIST)
C
         DO 20 IDDL =1, N1
            DDL(1) = ZK8(JDDL+IDDL-1)
            DDL(2) = ZK8(JDDL+IDDL-1)
            DO 30 INO = 2, LONLIS
               NONO(2) = ZK8(JLIST+INO-1)
               CALL AFRELA(COEMUR, COEMUC, DDL ,NONO,
     +                     IDIM,DIRECT,2,BETA,BETAC,BETAF,
     +                     TYPCOE,FONREE,TYPLAG,LISREL)
 30       CONTINUE
 20     CONTINUE
         CALL JEDETR (LISNOE)
         CALL JEDETR ('&&CAGROU.DDL')
 10   CONTINUE
C
C     -- AFFECTATION DE LA LISTE_RELA A LA CHARGE :
C     ---------------------------------------------
      IF (LONLIM.GT.1) THEN
        CALL AFLRCH(LISREL,CHARGE)
      ENDIF
C
 9999 CONTINUE
      CALL JEDEMA()
      END
