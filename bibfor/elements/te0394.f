      SUBROUTINE TE0394(OPTION,NOMTE)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 10/11/1999   AUTEUR VABHHTS J.PELLET 
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

      CHARACTER*16 OPTION,NOMTE
C ......................................................................
C    - FONCTION REALISEE:  PASSAGE DES POINTS DE GAUSS AUX NOEUDS POUR
C                          LES CONTRAINTES ET LES VARIABLES INTERNES DE
C                          L'ELEMENT MEPODTGD

C    - ARGUMENTS:
C        DONNEES:      OPTION       -->  OPTION DE CALCUL
C                      NOMTE        -->  NOM DU TYPE ELEMENT
C ......................................................................


C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
      CHARACTER*32 JEXNUM,JEXNOM,JEXR8,JEXATR
      INTEGER ZI,JTAB(7)
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
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------

      IF (OPTION(1:14).EQ.'SIEF_ELNO_ELGA') THEN
        CALL JEVECH('PCONTRR','L',ISIGGA)
C PARAMETRES   EN SORTIE
        CALL JEVECH('PSIEFNOR','E',ISIGNO)

        DO 10 K = 1,6
          ZR(ISIGNO-1+K) = ZR(ISIGGA-1+K)
          ZR(ISIGNO-1+K+6) = ZR(ISIGGA-1+K)
   10   CONTINUE
      ELSE IF (OPTION(1:14).EQ.'VARI_ELNO_ELGA') THEN
        CALL JEVECH('PVARIGR','L',IVARGA)
        CALL JEVECH('PCOMPOR','L',ICOMPO)
        READ (ZK16(ICOMPO+1),'(I16)') NBVAR
        CALL TECACH(.TRUE.,.TRUE.,'PVARINR',7,JTAB)
        LGPG = MAX(JTAB(6),1)*JTAB(7)
C PARAMETRES   EN SORTIE
        CALL JEVECH('PVARINR','E',IVARNO)
        DO 20 K = 1,NBVAR
          ZR(IVARNO-1+K) = ZR(IVARGA-1+K)
          ZR(IVARNO-1+K+LGPG) = ZR(IVARGA-1+K)
   20   CONTINUE
      END IF

      END
