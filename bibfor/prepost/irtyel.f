      SUBROUTINE IRTYEL(NOMO,NBMAI)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF PREPOST  DATE 21/02/96   AUTEUR VABHHTS J.PELLET 
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
C BUT: CREER L'OBJET JEVEUX '&&IRTYEL.TYPELEM'
      IMPLICIT REAL*8 (A-H,O-Z)
C      CET OBJET EST DIMENSIONNE AU NOMBRE DE MAILLES DU MAILLAGE
C      SI UNE MAILLE N'EST AFFECTEE PAR AUCUN ELEMENT FINI, TYPEL=0
C
C CONTENANT LE TYPE_ELEMENT ASSOCIE A CHAQUE MAILLE
C     ENTREE:
C        NOMO : NOM UTILISATEUR DU MODELE
C        NBMAI: NOMBRE DE MAILLES
C---------------- COMMUNS NORMALISES  JEVEUX  --------------------------
      COMMON/IVARJE/ZI(1)
      COMMON/RVARJE/ZR(1)
      COMMON/CVARJE/ZC(1)
      COMMON/LVARJE/ZL(1)
      COMMON/KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      COMMON/NOMAJE/PGC
      CHARACTER*6  PGC
      INTEGER ZI
      REAL*8 ZR
      COMPLEX*16 ZC
      LOGICAL ZL
      CHARACTER*8  ZK8,NOMO
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24,LIEL
      CHARACTER*32 ZK32,JEXNUM,JEXNOM,JEXR8,JEXATR
      CHARACTER*80 ZK80
      CHARACTER*1 K1BID
C
      CALL JEMARQ()
      CALL JEEXIN('&&IRTYEL.TYPELEM',IRET)
      IF (IRET.NE.0) CALL JEDETR('&&IRTYEL.TYPELEM')
      CALL WKVECT('&&IRTYEL.TYPELEM','V V I',NBMAI,JTYEL)
      LIEL=NOMO//'.MODELE    .LIEL'
      CALL JELIRA(LIEL,'NUTIOC',NBGREL,K1BID)
      DO 1 IMA=1,NBMAI
         DO 2 IGREL=1,NBGREL
            CALL JEVEUO(JEXNUM(LIEL,IGREL),'L',JLIGR)
            CALL JELIRA(JEXNUM(LIEL,IGREL),'LONMAX',LGR,K1BID)
            DO 3 IEL=1,LGR-1
               IF (IMA.EQ.ZI(JLIGR-1+IEL)) THEN
                  ZI(JTYEL-1+IMA)=ZI(JLIGR-1+LGR)
                  GO TO 1
               END IF
    3       CONTINUE
    2    CONTINUE
    1 CONTINUE
      CALL JEDEMA()
      END
