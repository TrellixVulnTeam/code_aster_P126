      SUBROUTINE CFJEUN(NDIM,
     &                  JAPCOE,JAPCOF,JAPDDL,JAPJEU,JAPJFX,JAPJFY,
     &                  JAPMEM,JAPPAR,JAPPTR,JCOOR,JDDL,JNORMO,JNRINI,
     &                  JPDDL,JTANGO,
     &                  TYPALF,FROT3D,MOYEN,TANGDF,
     &                  MULNOR,CMULT,COORE,
     &                  POSNOE,POS,NUM,IESCL,NESMAX,REACTU)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 07/10/2004   AUTEUR MABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2004  EDF R&D                  WWW.CODE-ASTER.ORG
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
C TOLE CRP_21
C
      IMPLICIT     NONE
      INTEGER      NDIM
      INTEGER      JAPCOE
      INTEGER      JAPCOF
      INTEGER      JAPDDL
      INTEGER      JAPJEU
      INTEGER      JAPJFX
      INTEGER      JAPJFY
      INTEGER      JAPMEM
      INTEGER      JAPPAR
      INTEGER      JAPPTR
      INTEGER      JCOOR
      INTEGER      JDDL
      INTEGER      JNORMO
      INTEGER      JNRINI
      INTEGER      JPDDL
      INTEGER      JTANGO
      INTEGER      TYPALF
      INTEGER      FROT3D
      LOGICAL      MULNOR
      REAL*8       CMULT
      REAL*8       COORE(3)
      INTEGER      MOYEN
      INTEGER      TANGDF
      INTEGER      POS
      INTEGER      NUM
      INTEGER      IESCL
      INTEGER      NESMAX
      INTEGER      POSNOE
      INTEGER      REACTU
C
C ----------------------------------------------------------------------
C ROUTINE APPELEE PAR : RECHNO
C ----------------------------------------------------------------------
C
C SAUVEGARDE DANS RESOCO DES INFOS APRES CALCUL DU JEU
C POUR L'APPARIEMENT NODAL
C
C IN  NDIM   : DIMENSION DE L'ESPACE (2 OU 3)
C IN  JAPCOE : POINTEUR VERS RESOCO(1:14)//'.APCOEF'
C IN  JAPCOF : POINTEUR VERS RESOCO(1:14)//'.APCOFR'
C IN  JAPDDL : POINTEUR VERS RESOCO(1:14)//'.APDDL'
C IN  JAPJEU : POINTEUR VERS RESOCO(1:14)//'.APJEU'
C IN  JAPJFX : POINTEUR VERS RESOCO(1:14)//'.APJEFX'
C IN  JAPJFY : POINTEUR VERS RESOCO(1:14)//'.APJEFY'
C IN  JAPMEM : POINTEUR VERS RESOCO(1:14)//'.APMEMO'
C IN  JAPPAR : POINTEUR VERS RESOCO(1:14)//'.APPARI'
C IN  JAPPTR : POINTEUR VERS RESOCO(1:14)//'.APPOIN'
C IN  JCOOR  : POINTEUR VERS NEWGEO(1:19)//'.VALE'
C IN  JDDL   : POINTEUR VERS DEFICO(1:16)//'.DDLCO'
C IN  JNORMO : POINTEUR VERS RESOCO(1:14)//'.NORMCO'
C IN  JNRINI : POINTEUR VERS RESOCO(1:14)//'.NORINI'
C IN  JPDDL  : POINTEUR VERS DEFICO(1:16)//'.PDDLCO'
C IN  JTANGO : POINTEUR VERS RESOCO(1:14)//'.TANGCO'
C IN  TYPALF : TYPE ALGO UTILISE POUR LE FROTTEMENT
C   LES VALEURS SONT NEGATIVES SI AUCUNE LIAISON ACTIVE
C   0 PAS DE FROTTEMENT 
C   1 FROTTEMENT PENALISE
C   2 FROTTEMENT LAGRANGIEN
C   3 FROTTEMENT METHODE CONTINUE
C IN  FROT3D : VAUT 1 LORSQU'ON CONSIDERE LE FROTTEMENT EN 3D
C IN  MULNOR : LOGIQUE QUI VAUT 1 LORSQU'ON MULTIPLIE LES COEFFICIENTS
C              DE LA RELATION UNILATERALE PAR LES COMPOSANTES 
C              DES NORMALES
C IN  CMULT  : COEFFICIENT DE LA RELATION UNILATERALE (ISSU DU
C              MOT-CLE COEF_MULT_2 OU 1)
C IN  COORE  : COORDONNEES DU NOEUD ESCLAVE
C IN  MOYEN  : NORMALES D'APPARIEMENT
C               0 MAIT 
C               1 MAIT_ESCL 
C IN  TANGDF : INDICATEUR DE PRESENCE D'UN VECT_Y DEFINI PAR 
C              L'UTILISATEUR
C               0 PAS DE VECT_Y
C               1 UN VECT_Y EST DEFINI
C IN  POSNOE : POSITION DANS DEFICO(1:16)//'.CONTNO' DU NOEUD ESCLAVE
C IN  POS    : POSITION DE LA MAILLE MAITRE ASSOCIEE 
C IN  NUM    : NUMERO DE LA MAILLE MAITRE ASSOCIEE 
C IN  IESCL  : INDICE DU NOEUD ESCLAVE
C IN  NESMAX : NOMBRE MAX DE NOEUDS ESCLAVES
C IN  REACTU : INDICATEUR DE REACTUALISATION POUR TOUTE LA ZONE
C              DES NORMALES ET DU JEU
C
C -------------- DEBUT DECLARATIONS NORMALISEES JEVEUX -----------------
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
C ---------------- FIN DECLARATIONS NORMALISEES JEVEUX -----------------
C
      INTEGER      ZAPPAR
      PARAMETER    (ZAPPAR=3)
      INTEGER      ZAPMEM
      PARAMETER    (ZAPMEM=4)
      INTEGER      JDECAL,JDECDL,K
      INTEGER      NBDDLE,NBDDLM
      REAL*8       XNORM(3),XTANG(6),NORME
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C --- POSITION DE LA MAILLE MAITRE APPARIEE <POS>
      ZI(JAPPAR+ZAPPAR* (IESCL-1)+1)  = POSNOE
      ZI(JAPPAR+ZAPPAR* (IESCL-1)+2)  = -POS
      ZI(JAPPAR+ZAPPAR* (IESCL-1)+3)  = REACTU
C --- ZI(JAPMEM+ZAPMEM* (POSNOE-1)+2) ET ZI(JAPPAR+ZAPPAR* (IESCL-1)+2)
C --- ECRASES DNAS CFJEUM (CHMANO)
      ZI(JAPMEM+ZAPMEM* (POSNOE-1))   = 1
      ZI(JAPMEM+ZAPMEM* (POSNOE-1)+1) = POS
      ZI(JAPMEM+ZAPMEM* (POSNOE-1)+2) = 0
      ZI(JAPMEM+ZAPMEM* (POSNOE-1)+3) = 0
      IF (POS.NE.0) THEN 
        ZI(JAPMEM+ZAPMEM*(POS-1)) = 0
      ENDIF
C
      NBDDLE = ZI(JPDDL+POSNOE) - ZI(JPDDL+POSNOE-1)
      NBDDLM = ZI(JPDDL+POS) - ZI(JPDDL+POS-1)
C
      IF ((NBDDLE.GT.3) .OR. (NBDDLM.GT.3)) THEN
        CALL UTMESS('F','CFJEUN','ON NE PEUT PAS AVOIR PLUS'//
     &                  ' DE 3 DDLS IMPLIQUES DANS LA MEME RELATION'//
     &                  ' UNILATERALE')
      END IF

      ZI(JAPPAR+ZAPPAR* (IESCL-1)+3) = 0

      IF (MOYEN.EQ.0) THEN
C --- NORMALE = 'MAIT'
        XNORM(1) = ZR(JNRINI+3* (POSNOE-1)  )
        XNORM(2) = ZR(JNRINI+3* (POSNOE-1)+1)
        XNORM(3) = ZR(JNRINI+3* (POSNOE-1)+2)
      ELSE
C --- NORMALE = 'MAIT_ESCL'
        XNORM(1) = ( ZR(JNRINI+3* (POSNOE-1)  )  -
     &               ZR(JNRINI+3* (POS-1)  )) / 2
        XNORM(2) = ( ZR(JNRINI+3* (POSNOE-1)+1)  -
     &               ZR(JNRINI+3* (POS-1)+1)) / 2
        XNORM(3) = ( ZR(JNRINI+3* (POSNOE-1)+2)  -
     &               ZR(JNRINI+3* (POS-1)+2)) / 2
      END IF
      CALL NORMEV(XNORM,NORME)
      CALL CFTANG(NDIM,XNORM,XTANG,TANGDF)
      CALL R8COPY(3,XNORM,1,ZR(JNORMO+3* (IESCL-1)),1)
      CALL R8COPY(6,XTANG,1,ZR(JTANGO+6* (IESCL-1)),1)
      ZR(JAPJEU+IESCL-1) = (ZR(JCOOR+3* (NUM-1))-COORE(1))*
     &                     ZR(JNORMO+3* (IESCL-1)) +
     &                     (ZR(JCOOR+3* (NUM-1)+1)-COORE(2))*
     &                     ZR(JNORMO+3* (IESCL-1)+1) +
     &                     (ZR(JCOOR+3* (NUM-1)+2)-COORE(3))*
     &                     ZR(JNORMO+3* (IESCL-1)+2)
C --- SI FROTTEMENT 3D
      IF (FROT3D.EQ.1) THEN
         ZR(JAPJFX+IESCL-1) = 0
         ZR(JAPJFY+IESCL-1) = 0
      END IF

      JDECAL = ZI(JAPPTR+IESCL-1)
      JDECDL = ZI(JPDDL+POSNOE-1)

      DO 30 K = 1,NBDDLE
        ZR(JAPCOE+JDECAL+K-1) = 1.D0*CMULT
        IF (MULNOR) THEN
          ZR(JAPCOE+JDECAL+K-1) = ZR(JAPCOE+JDECAL+K-1)*
     &                            ZR(JNORMO+3*(IESCL-1)+K-1)
        END IF
C --- SI FROTTEMENT
        IF (TYPALF.NE.0) THEN
          ZR(JAPCOF+JDECAL+K-1)           = 1.D0*CMULT
          ZR(JAPCOF+JDECAL+30*NESMAX+K-1) = 1.D0*CMULT
          IF (MULNOR) THEN
            ZR(JAPCOF+JDECAL+K-1) = ZR(JAPCOF+JDECAL+K-1)*
     &                              ZR(JTANGO+6*(IESCL-1)+K-1)
            IF (FROT3D.EQ.1) THEN
              ZR(JAPCOF+JDECAL+30*NESMAX+K-1) = 
     &              ZR(JAPCOF+JDECAL+30*NESMAX+K-1)*
     &              ZR(JTANGO+6* (IESCL-1)+K+2)
            END IF
          END IF
        END IF
        ZI(JAPDDL+JDECAL+K-1) = ZI(JDDL+JDECDL+K-1)
   30 CONTINUE

      JDECAL = JDECAL + NBDDLE
      JDECDL = ZI(JPDDL+POS-1)
      DO 40 K = 1,NBDDLM
        ZR(JAPCOE+JDECAL+K-1) = -1.D0*CMULT
        IF (MULNOR) THEN
          ZR(JAPCOE+JDECAL+K-1) = ZR(JAPCOE+JDECAL+K-1)*
     &                            ZR(JNORMO+3* (IESCL-1)+K-1)
        END IF
C --- SI FROTTEMENT
        IF (TYPALF.NE.0) THEN
          ZR(JAPCOF+JDECAL+K-1)           = -1.D0*CMULT
          ZR(JAPCOF+JDECAL+30*NESMAX+K-1) = -1.D0*CMULT
          IF (MULNOR) THEN
            ZR(JAPCOF+JDECAL+K-1) = ZR(JAPCOF+JDECAL+K-1)*
     &                              ZR(JTANGO+6* (IESCL-1)+K-1)
            IF (FROT3D.EQ.1) THEN
              ZR(JAPCOF+JDECAL+30*NESMAX+K-1) = 
     &                ZR(JAPCOF+JDECAL+30*NESMAX+K-1)*
     &                ZR(JTANGO+6* (IESCL-1)+K+2)
            END IF
          END IF
        END IF
        ZI(JAPDDL+JDECAL+K-1) = ZI(JDDL+JDECDL+K-1)
   40 CONTINUE

      ZI(JAPPTR+IESCL) = ZI(JAPPTR+IESCL-1) + NBDDLE + NBDDLM

C ----------------------------------------------------------------------

      CALL JEDEMA()
      END
