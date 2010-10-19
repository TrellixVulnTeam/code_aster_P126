      SUBROUTINE REACLM(NOMA  ,DEFICO,RESOCO,VALINC)
C      
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 19/10/2010   AUTEUR DESOZA T.DESOZA 
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
C RESPONSABLE ABBAS M.ABBAS
C
      IMPLICIT NONE
      CHARACTER*8  NOMA
      CHARACTER*24 DEFICO,RESOCO
      CHARACTER*19 VALINC(*)
C      
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODE CONTINUE - FROTTEMENT)
C
C REACTUALISATION DES SEUILS DE FROTTEMENT PAR LES MULTIPLICATEURS
C DE CONTACT
C      
C ----------------------------------------------------------------------
C
C 
C IN  NOMA   : NOM DU MAILLAGE
C IN  DEFICO : SD DE DEFINITION DU CONTACT
C IN  RESOCO : SD DE RESOLUTION DU CONTACT
C IN  VALINC : VARIABLE CHAPEAU POUR INCREMENTS VARIABLES
C
C -------------- DEBUT DECLARATIONS NORMALISEES JEVEUX -----------------
C
      INTEGER ZI
      COMMON /IVARJE/ ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C
C ---------------- FIN DECLARATIONS NORMALISEES JEVEUX -----------------
C
      INTEGER      MMINFI,CFMMVD,ZTABF
      INTEGER      IBID
      INTEGER      POSMAE,JDECME,NUMMAE
      INTEGER      IPTC
      INTEGER      IZONE,IMAE,IPTM,INOE
      INTEGER      NNE,NBMAE,NPTM
      INTEGER      CFDISI,NDIMG,NZOCO
      LOGICAL      MMINFL,LVERI
      REAL*8       LAMBDC,KSIPC1,KSIPC2
      REAL*8       MCON(9),FF(9)
      CHARACTER*8  ALIASE
      CHARACTER*19 CNSPLU,CNSLBD,DEPPLU
      CHARACTER*24 TABFIN
      INTEGER      JTABF
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- INITIALISATIONS
C      
      NDIMG  = CFDISI(DEFICO,'NDIM' )
      NZOCO  = CFDISI(DEFICO,'NZOCO')
C
C --- RECUPERATION DES QCQS DONNEES
C
      TABFIN = RESOCO(1:14)//'.TABFIN'
      CALL JEVEUO(TABFIN,'E',JTABF)
      ZTABF  = CFMMVD('ZTABF')
C
C --- DECOMPACTION DES VARIABLES CHAPEAUX
C        
      CALL NMCHEX(VALINC,'VALINC','DEPPLU',DEPPLU)     
C
C --- TRANSFORMATION DEPPLU EN CHAM_NO_S ET REDUCTION SUR LES LAGRANGES
C
      CNSPLU = '&&REACLM.CNSPLU'
      CALL CNOCNS(DEPPLU,'V',CNSPLU)
      CNSLBD = '&&REACLM.CNSLBD'
      CALL CNSRED(CNSPLU,0,IBID,1,'LAGS_C','V',CNSLBD)
C
C --- BOUCLE SUR LES ZONES
C
      IPTC   = 1
      DO 10 IZONE = 1,NZOCO
C
C --- OPTIONS SUR LA ZONE DE CONTACT
C  
        LVERI  = MMINFL(DEFICO,'VERIF' ,IZONE )
        NBMAE  = MMINFI(DEFICO,'NBMAE' ,IZONE )
        JDECME = MMINFI(DEFICO,'JDECME',IZONE )
C 
C ----- MODE VERIF: ON SAUTE LES POINTS
C  
        LVERI  = MMINFL(DEFICO,'VERIF' ,IZONE )
        IF (LVERI) THEN
          GOTO 25
        ENDIF
C
C ----- BOUCLE SUR LES MAILLES ESCLAVES
C      
        DO 20 IMAE = 1,NBMAE    
C
C ------- NUMERO ABSOLU DE LA MAILLE ESCLAVE
C
          POSMAE = JDECME + IMAE
          CALL CFNUMM(DEFICO,1     ,POSMAE,NUMMAE)    
C
C ------- INFOS SUR LA MAILLE
C
          CALL MMELTY(NOMA  ,NUMMAE,ALIASE,NNE   ,IBID  )        
C        
C ------- MULTIPLICATEURS DE CONTACT SUR LES NOEUDS ESCLAVES
C        
          CALL CALLAM(DEFICO,CNSLBD,POSMAE,MCON  )
C
C ------- NOMBRE DE POINTS SUR LA MAILLE ESCLAVE
C            
          CALL MMINFM(POSMAE,DEFICO,'NPTM',NPTM  )
C
C ------- BOUCLE SUR LES POINTS
C      
          DO 30 IPTM = 1,NPTM         
C
C --------- COORDONNEES ACTUALISEES DU POINT DE CONTACT 
C
            KSIPC1    = ZR(JTABF+ZTABF*(IPTC-1)+3 )
            KSIPC2    = ZR(JTABF+ZTABF*(IPTC-1)+4 )          
C          
C --------- MULTIPLICATEUR DE LAGRANGE DE CONTACT DU POINT
C     
            LAMBDC = 0.D0
            CALL MMNONF(NDIMG ,NNE   ,ALIASE,KSIPC1,KSIPC2,
     &                  FF    )

            DO 61 INOE = 1,NNE
              LAMBDC = FF(INOE)*MCON(INOE) + LAMBDC
   61       CONTINUE
C
C --------- SAUVEGARDE
C              
            ZR(JTABF+ZTABF*(IPTC-1)+16) = LAMBDC          
C
C --------- LIAISON DE CONTACT SUIVANTE
C
            IPTC   = IPTC + 1 
  30      CONTINUE
  20    CONTINUE
  25    CONTINUE
  10  CONTINUE
C 
      CALL DETRSD('CHAM_NO_S',CNSPLU)
      CALL DETRSD('CHAM_NO_S',CNSLBD)
      CALL JEDEMA()
      END
