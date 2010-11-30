      SUBROUTINE CALIMC(CHARGZ)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 22/06/2010   AUTEUR DEVESA G.DEVESA 
C ======================================================================
C COPYRIGHT (C) 1991 - 2010  EDF R&D                  WWW.CODE-ASTER.ORG
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
      IMPLICIT REAL*8 (A-H,O-Z)

C       CALIMC -- TRAITEMENT DU MOT FACTEUR LIAISON_INTERF

C      TRAITEMENT DU MOT FACTEUR LIAISON_INTERF DE AFFE_CHAR_MECA
C      CE MOT FACTEUR PERMET DE DEFINIR UNE RELATION LINEAIRE ENTRE
C      LES DDLS PHYSIQUES DE L INTERFACE DYNAMIQUE D UN MACRO-ELEMENT
C      ET LES DDLS VIRTUELS DE L OBJET LINO

C -------------------------------------------------------
C  CHARGE        - IN    - K8   - : NOM DE LA SD CHARGE
C                - JXVAR -      -   LA  CHARGE EST ENRICHIE
C                                   DE LA RELATION LINEAIRE DECRITE
C                                   CI-DESSUS.
C -------------------------------------------------------

C.========================= DEBUT DES DECLARATIONS ====================
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ------
      CHARACTER*32 JEXNUM,JEXNOM,JEXR8,JEXATR
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
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ------

C -----  ARGUMENTS
      CHARACTER*(*) CHARGZ
C      CHARACTER*8 NOMA
C ------ VARIABLES LOCALES
      CHARACTER*1 K1BID
      COMPLEX*16 BETAC,CBID
      CHARACTER*2 TYPLAG
      CHARACTER*4 TYCH,TYPVAL,TYPCOE
      CHARACTER*8 K8BID,NOMCMP,NOMNOE,BETAF,NMCMP2,NMNOE2
      CHARACTER*6 TYPLIA
      CHARACTER*8 CHARGE,POSLAG,NOMGD
      CHARACTER*16 MOTFAC
      CHARACTER*19 LISREL
      CHARACTER*14 NUMDDL
      CHARACTER*8  K8B, BASEMO, MAILLA, LISCMP(6),
     &             MACREL, LINTF, NOMNOL, NOGDSI, MAYA
      CHARACTER*24 CHAMNO, NOMCHA, NUMEDD, NPRNO
      CHARACTER*3  TTRAN
C     ------------------------------------------------------------------
      DATA LISCMP   /'DX      ','DY      ','DZ      ',
     &               'DRX     ','DRY     ','DRZ     '/
C     ------------------------------------------------------------------

C.========================= DEBUT DU CODE EXECUTABLE ==================

      CALL JEMARQ()

      MOTFAC = 'LIAISON_INTERF'

      CALL GETFAC(MOTFAC,NLIAI)
      IF (NLIAI.EQ.0) GO TO 40

C --- INITIALISATIONS :
C     ---------------
      ZERO = 0.0D0
C --- BETA, BETAC ET BETAF SONT LES VALEURS DU SECOND MEMBRE DE LA
C --- RELATION LINEAIRE SUIVANT QUE C'EST UN REEL, UN COMPLEXE OU
C --- UNE FONCTION, DANS NOTRE CAS C'EST UN REEL

      BETA = ZERO
      BETAC = (0.0D0,0.0D0)
      BETAF = '&FOZERO'

      CHARGE = CHARGZ

C --- TYPE DES VALEURS AU SECOND MEMBRE DE LA RELATION

      TYPVAL = 'REEL'

C --- TYPE DES VALEURS DES COEFFICIENTS

      TYPCOE = 'REEL'

C --- NOM DE LA LISTE_RELA

      LISREL = '&CALIMC.RLLISTE'

C --- BOUCLE SUR LES OCCURENCES DU MOT-FACTEUR LIAISON_MACREL :
C     -------------------------------------------------------
      DO 30 IOCC = 1,NLIAI

C ---   ON REGARDE SI LES MULTIPLICATEURS DE LAGRANGE SONT A METTRE
C ---   APRES LES NOEUDS PHYSIQUES LIES PAR LA RELATION DANS LA MATRICE
C ---   ASSEMBLEE :
C ---   SI OUI TYPLAG = '22'
C ---   SI NON TYPLAG = '12'

C        CALL GETVTX(MOTFAC,'NUME_LAGR',IOCC,1,1,POSLAG,IBID)
C        IF (POSLAG.EQ.'APRES') THEN
C          TYPLAG = '22'
C        ELSE
C          TYPLAG = '12'
C        END IF
        TYPLAG = '12'
        CALL GETVID(MOTFAC,'MACR_ELEM_DYNA',IOCC,1,1,MACREL,NMC)  
        CALL JEVEUO(MACREL//'.MAEL_REFE','L',IADREF)
        BASEMO = ZK24(IADREF)
        CALL RSORAC(BASEMO,'LONUTI',IBID,RBID,K8B,CBID,RBID,
     &               K8B,NBMODE,1,IBID)
        CALL JEVEUO(BASEMO//'           .REFD','L',IADRIF)
        NUMEDD = ZK24(IADRIF+3)
        CALL DISMOI('F','NOM_MAILLA',NUMEDD(1:14),'NUME_DDL',IBID,
     &                  MAILLA,IRET)
        LINTF = ZK24(IADRIF+4)
C On recupere le nbre de noeuds presents dans interf_dyna
        CALL JELIRA(JEXNUM(LINTF//'.IDC_LINO',1),'LONMAX',NBNOE,K8B)
C On recupere la liste des noeuds presents dans interf_dyna
        CALL JEVEUO(LINTF//'.IDC_DEFO','L',LLDEF)
C On recupere le nbre de modes statiques dans la base
        CALL DISMOI('F','NB_MODES_STA',BASEMO,'RESULTAT',
     &                      NBMDEF,K8B,IERD)
        CALL JELIRA(MACREL//'.LINO','LONMAX',NBNTOT,K8B)
        NBMDYN = NBMODE-NBMDEF
        NEC = NBMODE/NBNTOT
        NBNDYN = NBMDYN/NEC
        NBNDEF = NBNTOT-NBNDYN
        NBNDE2 = NBMDEF/NEC
        CALL ASSERT(NBNDEF.EQ.NBNDE2)
C       CREATION DU TABLEAU NOEUD-COMPOSANTE ASSOCIES AUX MODES
        CALL WKVECT('&&CALIMC.NCMPSD','V V K8',2*NBMDEF,JNCMPD)
        CALL JEVEUO(MACREL//'.LINO','L',IACONX)
        DO 21 I=1,NBNDEF
          I2 = I+NBNDYN
          CALL JENUNO(JEXNUM(MAILLA//'.NOMNOE',ZI(IACONX+I2-1)),NOMNOL)
          DO 22 J=1,NEC
            ZK8(JNCMPD+2*NEC*(I-1)+2*J-2) = NOMNOL
            ZK8(JNCMPD+2*NEC*(I-1)+2*J-1) = LISCMP(J)
  22      CONTINUE
  21    CONTINUE
        CALL WKVECT('&&CALIMC.NCMPIN','V V K8',2*NBNOE*NEC,JNCMPI)
        DO 23 I=1,NBNOE
          CALL JENUNO(JEXNUM(MAILLA//'.NOMNOE',ZI(LLDEF+I-1)),NOMNOL)
          DO 24 J=1,NEC
            ZK8(JNCMPI+2*NEC*(I-1)+2*J-2) = NOMNOL
            ZK8(JNCMPI+2*NEC*(I-1)+2*J-1) = LISCMP(J)
  24      CONTINUE
  23    CONTINUE
        NUMDDL = NUMEDD(1:14)
        CALL DISMOI('F','NB_EQUA',NUMDDL,'NUME_DDL',NEQ,K8B,IRET)
        CALL WKVECT('&&CALIMC.BASE','V V R',NBMODE*NEQ,IDBASE)
        CALL COPMO2(BASEMO,NEQ,NUMDDL,NBMODE,ZR(IDBASE))
        CALL DISMOI('F','NOM_GD',NUMDDL,'NUME_DDL',IBID,NOGDSI,IERD)
C        NOGDSI = 'DEPL_R'  
        CALL DISMOI('F','NB_EC',NOGDSI,'GRANDEUR',NBEC,K8B,IERD)
        NPRNO = NUMDDL//'.NUME.PRNO'
        CALL JEVEUO(JEXNUM(NPRNO,1),'L',IAPRNO)
        
        CALL GETVTX(MOTFAC, 'TYPE_LIAISON', IOCC,1,1, TYPLIA, N2 )
        
        IF (TYPLIA.EQ.'RIGIDE') THEN
          NBTERM = NBMDEF+1
        ELSE
          NBTERM = NBMDEF+NEC*NBNOE
        ENDIF

C ---   CREATION DES TABLEAUX DE TRAVAIL NECESSAIRES A L'AFFECTATION
C ---   DE LA LISTE_RELA
C       ----------------
C ---     VECTEUR DU NOM DES NOEUDS
        CALL WKVECT('&&CALIMC.LISNO','V V K8',NBTERM,IDNOEU)
C ---     VECTEUR DU NOM DES DDLS
        CALL WKVECT('&&CALIMC.LISDDL','V V K8',NBTERM,IDDDL)
C ---      VECTEUR DES COEFFICIENTS REELS
        CALL WKVECT('&&CALIMC.COER','V V R',NBTERM,IDCOER)
C ---     VECTEUR DES COEFFICIENTS COMPLEXES
        CALL WKVECT('&&CALIMC.COEC','V V C',NBTERM,IDCOEC)
C ---     VECTEUR DES DIRECTIONS DES DDLS A CONTRAINDRE
        CALL WKVECT('&&CALIMC.DIRECT','V V R',3*NBTERM,IDIREC)
C ---     VECTEUR DES DIMENSIONS DE CES DIRECTIONS
        CALL WKVECT('&&CALIMC.DIME','V V I',NBTERM,IDIMEN)


C ---   AFFECTATION DES TABLEAUX DE TRAVAIL :
C       -----------------------------------

C ---   BOUCLE SUR LES DDL D'INTERFACE DU MACRO-ELEMENT
C        CALL GETVTX(MOTFAC, 'SANS_ROTA' , IOCC,1,1, TTRAN, N2 )
        TTRAN = 'NON'
        IF (TTRAN.EQ.'OUI') THEN
          NEC2 = 3
        ELSE
          NEC2 = NEC
        ENDIF
        IF (TYPLIA.NE.'RIGIDE') GOTO 101
C
C       CAS RIGIDE
C
        DO 25 I=1,NBNOE
          DO 26 J=1,NEC2
            K = 0
            NOMNOE = ZK8(JNCMPI+2*NEC*(I-1)+2*J-2)
            NOMCMP = ZK8(JNCMPI+2*NEC*(I-1)+2*J-1)
            CALL JENONU(JEXNOM(MAILLA//'.NOMNOE',NOMNOE),INOE)
            IF (NOMCMP.EQ.'DX') ICMP = 1
            IF (NOMCMP.EQ.'DY') ICMP = 2
            IF (NOMCMP.EQ.'DZ') ICMP = 3
            IF (NOMCMP.EQ.'DRX') ICMP = 4
            IF (NOMCMP.EQ.'DRY') ICMP = 5
            IF (NOMCMP.EQ.'DRZ') ICMP = 6
            IDDL = ZI(IAPRNO-1+(NBEC+2)*(INOE-1)+1)
            DO 27 II=1,NBNDEF
              DO 28 JJ=1,NEC
                K = K + 1
                NOMNOE = ZK8(JNCMPD+2*NEC*(II-1)+2*JJ-2)
                NOMCMP = ZK8(JNCMPD+2*NEC*(II-1)+2*JJ-1)
                IMOD = NBMDYN+(II-1)*NEC+JJ
                VALE = ZR(IDBASE+(IMOD-1)*NEQ+IDDL-1+ICMP-1)
                ZK8(IDNOEU+K-1) = NOMNOE
                ZK8(IDDDL+K-1) = NOMCMP
                ZR(IDCOER+K-1) = VALE
  28          CONTINUE
  27        CONTINUE
            K = NBTERM
            NOMNOE = ZK8(JNCMPI+2*NEC*(I-1)+2*J-2)
            NOMCMP = ZK8(JNCMPI+2*NEC*(I-1)+2*J-1)
            ZK8(IDNOEU+K-1) = NOMNOE
            ZK8(IDDDL+K-1) = NOMCMP
            ZR(IDCOER+K-1) = -1.0D0

C ---   AFFECTATION DE LA RELATION A LA LISTE_RELA  :
C       ------------------------------------------
            CALL AFRELA(ZR(IDCOER),ZC(IDCOEC),ZK8(IDDDL),ZK8(IDNOEU),
     &                  ZI(IDIMEN),ZR(IDIREC),NBTERM,BETA,BETAC,BETAF,
     &                  TYPCOE,TYPVAL,TYPLAG,0.D0,LISREL)
     
  26      CONTINUE
  25    CONTINUE
        GOTO 102
 101    CONTINUE 
C 
C       CAS SOUPLE
C
        DO 31 I=1,NBNDEF
          DO 32 J=1,NEC
          K = 0
          IMOD = NBMDYN+(I-1)*NEC+J
          DO 35 I2=1,NBNOE
            NOMNOE = ZK8(JNCMPI+2*NEC*(I2-1))
            CALL JENONU(JEXNOM(MAILLA//'.NOMNOE',NOMNOE),INOE)
            IDDL = ZI(IAPRNO-1+(NBEC+2)*(INOE-1)+1)
            DO 36 J2=1,NEC
              K = K + 1
              NOMCMP = ZK8(JNCMPI+2*NEC*(I2-1)+2*J2-1)
              IF (NOMCMP.EQ.'DX') ICMP = 1
              IF (NOMCMP.EQ.'DY') ICMP = 2
              IF (NOMCMP.EQ.'DZ') ICMP = 3
              IF (NOMCMP.EQ.'DRX') ICMP = 4
              IF (NOMCMP.EQ.'DRY') ICMP = 5
              IF (NOMCMP.EQ.'DRZ') ICMP = 6
              ZK8(IDNOEU+K-1) = NOMNOE
              ZK8(IDDDL+K-1) = NOMCMP
              ZR(IDCOER+K-1) = -ZR(IDBASE+(IMOD-1)*NEQ+IDDL-1+ICMP-1)
  36        CONTINUE
  35      CONTINUE
          DO 37 II=1,NBNDEF
            NOMNOE = ZK8(JNCMPD+2*NEC*(II-1))
            DO 38 JJ=1,NEC
              K = K + 1
              NOMCMP = ZK8(JNCMPD+2*NEC*(II-1)+2*JJ-1)
              IMOD2 = NBMDYN+(II-1)*NEC+JJ
              VALE = ZERO
              DO 33 I3=1,NBNOE
                NMNOE2 = ZK8(JNCMPI+2*NEC*(I3-1))
                CALL JENONU(JEXNOM(MAILLA//'.NOMNOE',NMNOE2),INOE)
                IDDL2 = ZI(IAPRNO-1+(NBEC+2)*(INOE-1)+1)
                DO 34 J3=1,NEC
                  NMCMP2 = ZK8(JNCMPI+2*NEC*(I3-1)+2*J3-1)
                  IF (NMCMP2.EQ.'DX') ICMP2 = 1
                  IF (NMCMP2.EQ.'DY') ICMP2 = 2
                  IF (NMCMP2.EQ.'DZ') ICMP2 = 3
                  IF (NMCMP2.EQ.'DRX') ICMP2 = 4
                  IF (NMCMP2.EQ.'DRY') ICMP2 = 5
                  IF (NMCMP2.EQ.'DRZ') ICMP2 = 6
                  VALE = VALE + 
     &             ZR(IDBASE+(IMOD-1)*NEQ+IDDL2-1+ICMP2-1)*
     &             ZR(IDBASE+(IMOD2-1)*NEQ+IDDL2-1+ICMP2-1)
  34            CONTINUE
  33          CONTINUE
              ZK8(IDNOEU+K-1) = NOMNOE
              ZK8(IDDDL+K-1) = NOMCMP
              ZR(IDCOER+K-1) = VALE
  38        CONTINUE
  37      CONTINUE
C ---   AFFECTATION DE LA RELATION A LA LISTE_RELA  :
C       ------------------------------------------
          CALL AFRELA(ZR(IDCOER),ZC(IDCOEC),ZK8(IDDDL),ZK8(IDNOEU),
     &                ZI(IDIMEN),ZR(IDIREC),NBTERM,BETA,BETAC,BETAF,
     &                TYPCOE,TYPVAL,TYPLAG,0.D0,LISREL)
     

  32      CONTINUE
  31    CONTINUE
C
 102    CONTINUE   
C ---   MENAGE :
C       ------
        CALL JEDETR('&&CALIMC.LISNO')
        CALL JEDETR('&&CALIMC.LISDDL')
        CALL JEDETR('&&CALIMC.COER')
        CALL JEDETR('&&CALIMC.COEC')
        CALL JEDETR('&&CALIMC.DIRECT')
        CALL JEDETR('&&CALIMC.DIME')
        CALL JEDETR('&&CALIMC.NCMPSD')
        CALL JEDETR('&&CALIMC.NCMPIN')
        CALL JEDETR('&&CALIMC.BASE')

   30 CONTINUE

C --- AFFECTATION DE LA LISTE_RELA A LA CHARGE :
C     ----------------------------------------
      CALL AFLRCH(LISREL,CHARGE)

C --- MENAGE :
C     ------
      CALL JEDETR(LISREL)

   40 CONTINUE

      CALL JEDEMA()
C.============================ FIN DE LA ROUTINE ======================
      END
