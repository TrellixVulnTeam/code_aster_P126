      SUBROUTINE MEAMGY(MODELE,MATE,CARA,MATEL)
      IMPLICIT NONE
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 23/10/2007   AUTEUR BOYERE E.BOYERE 
C ======================================================================
C COPYRIGHT (C) 1991 - 2007  EDF R&D                  WWW.CODE-ASTER.ORG
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
C     ARGUMENTS:
C     ----------
      CHARACTER*8 MODELE, MATEL, CARA
      CHARACTER*24 MATE
C ----------------------------------------------------------------------
C     CALCUL DES MATRICES ELEMENTAIRES D'AMORTISSEMENT GYROSCOPIQUE
C     LES NOMS QUI SUIVENT SONT LES PREFIXES UTILISATEUR K8:
C     ENTREES:
C        MODELE : NOM DU MODELE
C        MATE   : CHAMP DE MATERIAUX
C        CARA   : CARACTERISTIQUES ELEMENTAIRES
C     SORTIES:
C        MATEL  : NOM DU MATEL (MATRICE ELEMENTAIRE) PRODUIT

C ----------------------------------------------------------------------
C---------------- COMMUNS NORMALISES  JEVEUX  --------------------------
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
C----------------------------------------------------------------------
C     VARIABLES LOCALES:
C     ------------------
      LOGICAL EXIGEO,EXICAR
      CHARACTER*8 LPAIN(10),LPAOUT(1),TEMPE,REPK
      CHARACTER*16 OPTION
      CHARACTER*24 CHGEOM,CHCARA(15),LCHIN(10),LCHOUT(10)
      CHARACTER*24 LIGRMO
      INTEGER JLIRES, ILIRES, IRET


      CALL JEMARQ()

      CALL ASSERT(MODELE.NE.' ')
      CALL ASSERT(MATE.NE.' ')
      CALL ASSERT(CARA.NE.' ')

      CALL JEDETR(MATEL//'.REFE_RESU')
      CALL JEDETR(MATEL//'.LISTE_RESU')

      CALL MEMARE('G',MATEL,MODELE,MATE,' ','MECA_GYRO')

C     CREATION DE LA MATRICE ELEMENTAIRE DE SORTIE
      CALL JECREO(MATEL//'.LISTE_RESU','G V K24')
      CALL JEECRA(MATEL//'.LISTE_RESU','LONMAX',1,' ')
      CALL JEVEUO(MATEL//'.LISTE_RESU','E',JLIRES)

      CALL MEGEOM(MODELE,' ',EXIGEO,CHGEOM)
      IF (.NOT.EXIGEO) CALL U2MESS('F','CALCULEL2_81')
      CALL ASSERT(CHGEOM.NE.' ')


C    CHAMP DE CARACTERISTIQUES ELEMENTAIRES
      CALL MECARA(CARA,EXICAR,CHCARA)
      IF (.NOT.EXICAR) CALL U2MESS('F','CALCULEL2_94')


      LPAOUT(1) = 'PMATUNS'
      LCHOUT(1) = MATEL//'.ME001'
      ILIRES = 0

      LPAIN(1) = 'PGEOMER'
      LCHIN(1) = CHGEOM
      LPAIN(2) = 'PMATERC'
      LCHIN(2) = MATE
      LPAIN(3) = 'PCAORIE'
      LCHIN(3) = CHCARA(1)
      LPAIN(4) = 'PCAGNPO'
      LCHIN(4) = CHCARA(6)
      LPAIN(5) = 'PCADISM'
      LCHIN(5) = CHCARA(3)
      LIGRMO = MODELE//'.MODELE'
      OPTION = 'MECA_GYRO'

      CALL JXVERI(' ',' ')

      CALL CALCUL('S',OPTION,LIGRMO,5,LCHIN,LPAIN,1,LCHOUT,LPAOUT,'G')

      CALL EXISD('CHAMP_GD',LCHOUT(1) (1:19),IRET)
      CALL ASSERT(IRET.GT.0)
      ILIRES = ILIRES + 1
      ZK24(JLIRES-1+ILIRES) = LCHOUT(1)
      CALL JEECRA(MATEL//'.LISTE_RESU','LONUTI',ILIRES,' ')


      CALL JEDEMA()

      END
