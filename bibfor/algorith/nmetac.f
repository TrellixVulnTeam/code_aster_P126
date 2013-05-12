      SUBROUTINE NMETAC(FONACT,SDDYNA,DEFICO,NBMAX ,CHAACT)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 29/04/2013   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2013  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE ABBAS M.ABBAS
C
      IMPLICIT     NONE
      INCLUDE 'jeveux.h'
      INTEGER      NBMAX
      LOGICAL      CHAACT(NBMAX)
      INTEGER      FONACT(*)
      CHARACTER*19 SDDYNA
      CHARACTER*24 DEFICO
C
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (GESTION IN ET OUT)
C
C ACTIVATION DES CHAMPS A TRAITER SUIVANT FONCTIONNALITES ACTIVEES
C
C ----------------------------------------------------------------------
C
C IN  SDDYNA : SD DYNAMIQUE
C IN  FONACT : FONCTIONNALITES ACTIVEES (VOIR NMFONC)
C IN  DEFICO : SD POUR LA DEFINITION DU CONTACT
C IN  NBMAX  : NOMBRE DE CHAMPS A CONSIDERER
C OUT CHAACT : CHAMPS A ACTIVER/DESACTIVER
C
C ----------------------------------------------------------------------
C
      LOGICAL      NDYNLO,ISFONC,CFDISL
      LOGICAL      LXFCM,LDYNA,LXFFM,LXCZM,LCONT,LNOEU,LMUAP,LSTRX
      LOGICAL      LVIBR,LFLAM,LSTAB,LENER
      CHARACTER*24 TRAV
      INTEGER      JTRAV
      INTEGER      ICHAM,ISTOP
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- FONCTIONNALITES ACTIVEES
C
      LDYNA  = NDYNLO(SDDYNA,'DYNAMIQUE'  )
      LXFCM  = ISFONC(FONACT,'CONT_XFEM'  )
      LCONT  = ISFONC(FONACT,'CONTACT'    )
      LMUAP  = NDYNLO(SDDYNA,'MULTI_APPUI')
      LFLAM  = ISFONC(FONACT,'CRIT_STAB'  )
      LSTAB  = ISFONC(FONACT,'DDL_STAB'   )
      LVIBR  = ISFONC(FONACT,'MODE_VIBR'  )
      LENER  = ISFONC(FONACT,'ENERGIE'    )
      IF (LXFCM) THEN
        LXFFM  = ISFONC(FONACT,'FROT_XFEM')
        LXCZM  = CFDISL(DEFICO,'EXIS_XFEM_CZM')
      ENDIF
      LSTRX  = ISFONC(FONACT,'EXI_STRX')
C
C --- VECTEUR ACTIVATION
C
      TRAV   = '&&NMETAC.TRAV'
      CALL WKVECT(TRAV  ,'V V I',NBMAX ,JTRAV)
C
C --- CHAMPS STANDARDS: DEPL/SIEF_ELGA/VARI_ELGA/FORC_NODA
C
      CHAACT(1)  = .TRUE.
      CHAACT(2)  = .TRUE.
      CHAACT(3)  = .TRUE.
      CHAACT(16) = .TRUE.
      ZI(JTRAV-1+1)  = 1
      ZI(JTRAV-1+2)  = 1
      ZI(JTRAV-1+3)  = 1
      ZI(JTRAV-1+16) = 1
C
C --- CARTE COMPORTEMENT
C
      CHAACT(4) = .TRUE.
      ZI(JTRAV-1+4)  = 1
C
C --- CHAMPS DYNAMIQUE: VITE/ACCE
C
      IF (LDYNA) THEN
        CHAACT(5) = .TRUE.
        CHAACT(6) = .TRUE. 
      ENDIF
      ZI(JTRAV-1+5)  = 1
      ZI(JTRAV-1+6)  = 1
C
C --- CHAMPS XFEM
C
      IF (LXFCM) THEN
        CHAACT(7) = .TRUE.
        IF (LXFFM) THEN
          CHAACT(8) = .TRUE.
        ENDIF
        IF (LXCZM) THEN
          CHAACT(9) = .TRUE.
        ENDIF
      ENDIF
      ZI(JTRAV-1+7)  = 1
      ZI(JTRAV-1+8)  = 1
      ZI(JTRAV-1+9)  = 1
C
C --- CONTACT
C
      IF (LCONT) THEN
        LNOEU = CFDISL(DEFICO,'ALL_INTEG_NOEUD')
        IF (LNOEU) THEN
          CHAACT(10) = .TRUE.    
        ENDIF
      ENDIF
      ZI(JTRAV-1+10)  = 1
C
C --- FLAMBEMENT
C
      IF (LFLAM) THEN
        CHAACT(11) = .TRUE.
      ENDIF
      ZI(JTRAV-1+11)  = 1
C
C --- STABILITE
C
      IF (LSTAB) THEN
        CHAACT(18) = .TRUE.
      ENDIF
      ZI(JTRAV-1+18)  = 1
C
C --- MODES VIBRATOIRES
C
      IF (LVIBR) THEN
        CHAACT(12) = .TRUE.
      ENDIF
      ZI(JTRAV-1+12)  = 1
C
C --- DEPL/VITE/ACCE D'ENTRAINEMENT EN MULTI-APPUIS
C
      IF (LMUAP) THEN
        CHAACT(13) = .TRUE.
        CHAACT(14) = .TRUE.
        CHAACT(15) = .TRUE.
      ENDIF
      ZI(JTRAV-1+13)  = 1
      ZI(JTRAV-1+14)  = 1
      ZI(JTRAV-1+15)  = 1
C
C --- POUTRE MULTI_FIBRE
C
      IF (LSTRX) THEN
        CHAACT(17) = .TRUE.
      ENDIF
      ZI(JTRAV-1+17)  = 1
C
C --- FORCES POUR CALCUL DES ENERGIES
C
      IF (LENER) THEN
        CHAACT(19) = .TRUE.
        CHAACT(20) = .TRUE.
      ENDIF
      ZI(JTRAV-1+19)  = 1
      ZI(JTRAV-1+20)  = 1
C
C --- VERIFICATION
C --- SI LE ASSERT SE DECLENCHE, C'EST QUE VOUS AVEZ OUBLIE DE DIRE
C --- DANS QUEL CAS ON DOIT S'OCCUPER DU CHAMP
C
      DO 10 ICHAM = 1,NBMAX
        ISTOP = ZI(JTRAV-1+ICHAM)
        CALL ASSERT(ISTOP.EQ.1)
  10  CONTINUE
C
      CALL JEDETR(TRAV)
      CALL JEDEMA()
      END
