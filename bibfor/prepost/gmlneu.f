      SUBROUTINE  GMLNEU(NBNODE)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF PREPOST  DATE 10/12/2001   AUTEUR VABHHTS J.PELLET 
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
C.======================================================================
      IMPLICIT REAL*8 (A-H,O-Z)
C
C      GMLNEU --   LECTURE DES NUMEROS DE NOEUDS ET DE LEURS
C                  COORDONNEES SUR LE FICHIER DE SORTIE DE GMSH
C
C   ARGUMENT        E/S  TYPE         ROLE
C    NBNODE         OUT   I         NOMBRE DE NOEUDS DU MAILLAGE
C
C.========================= DEBUT DES DECLARATIONS ====================
C -----  ARGUMENTS
           INTEGER  NBNODE
C -----  VARIABLES LOCALES
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
      CHARACTER*32 JEXNOM, JEXNUM
C
C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------
C.========================= DEBUT DU CODE EXECUTABLE ==================
      CALL JEMARQ()
C
C --- INITIALISATION :
C     --------------
      NBNODE   = 0
C
C --- RECUPERATION DES NUMEROS D'UNITE LOGIQUE :
C     ----------------------------------------
      IGMSH = IUNIFI('UNIVERSEL')
      IMES  = IUNIFI('MESSAGE')
C
C --- LECTURE DU NOMBRE DE NOEUDS :
C     ---------------------------
      READ(IGMSH,'(I10)') NBNODE
C
C --- CREATION DE VECTEURS DE TRAVAIL :
C     -------------------------------
      CALL JEDETR('&&PREGMS.INFO.NOEUDS')
      CALL JEDETR('&&PREGMS.COOR.NOEUDS')
C
      CALL WKVECT('&&PREGMS.INFO.NOEUDS','V V I',NBNODE,JINFO)
      CALL WKVECT('&&PREGMS.COOR.NOEUDS','V V R',3*NBNODE,JCOOR)
C
C --- LECTURE DES NUMEROS DE NOEUDS ET DE LEURS COORDONNEES :
C     -----------------------------------------------------
      DO 10 INODE = 1, NBNODE
C        READ(IGMSH,'(I10,3(E25.16))') NODE,X,Y,Z
        READ(IGMSH,*) NODE,X,Y,Z
C
        ZI(JINFO+INODE-1) = NODE
        ZR(JCOOR-1+3*(INODE-1)+1) = X
        ZR(JCOOR-1+3*(INODE-1)+2) = Y
        ZR(JCOOR-1+3*(INODE-1)+3) = Z
C
  10  CONTINUE
C
      WRITE(IMES,*) 'NOMBRE DE NOEUDS : ',NBNODE
C
      CALL JEDEMA()
C
C.============================ FIN DE LA ROUTINE ======================
      END
