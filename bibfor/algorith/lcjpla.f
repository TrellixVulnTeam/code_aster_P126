        SUBROUTINE LCJPLA (FAMI,KPG,KSP,LOI,MOD,NR,IMAT,NMAT,MATER,NVI,
     1                     DEPS,SIGF,VIN,DSDE,SIGD,VIND,VP,VECP,
     2                     THETA, DT, DEVG, DEVGII)
        IMPLICIT   NONE
C       ================================================================
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 28/03/2007   AUTEUR PELLET J.PELLET 
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
C       ----------------------------------------------------------------
C       MATRICE SYMETRIQUE DE COMPORTEMENT TANGENT ELASTO-PLASTIQUE
C       VISCO-PLASTIQUE EN VITESSE A T+DT OU T
C       IN  FAMI   :  FAMILLE DE POINT DE GAUSS (RIGI,MASS,...)
C           KPG,KSP:  NUMERO DU (SOUS)POINT DE GAUSS
C           LOI    :  MODELE DE COMPORTEMENT
C           MOD    :  TYPE DE MODELISATION
C           IMAT   :  ADRESSE DU MATERIAU CODE
C           NMAT   :  DIMENSION MATER
C           MATER  :  COEFFICIENTS MATERIAU
C           NVI    :  NB VARIABLES INTERNES
C           DEPS   :  INCREMENT DE DEFORMATION
C           SIGF    :  CONTRAINTE A L INSTANT +
C           VIN    :  VARIABLES INTERNES
C           SIGD    :  CONTRAINTE A L INSTANT -
C       OUT DSDE   :  MATRICE DE COMPORTEMENT TANGENT = DSIG/DEPS
C           VP     : VALEURS PROPRES DU DEVIATEUR ELASTIQUE (HOEK-BROWN)
C           VECP   : VECTEURS PROPRES DU DEVIATEUR ELASTIQUE(HOEK-BROWN)
C       ----------------------------------------------------------------
C TOLE CRP_21
        INTEGER         IMAT, NMAT , NVI, NR,KPG,KSP
        REAL*8          DSDE(6,6),DEVG(*),DEVGII,SIGF(6),DEPS(6),DG
        REAL*8          VIN(*), VIND(*),THETA,DT,MATER(NMAT,2)
        REAL*8          VP(3),VECP(3,3),SIGD(6)
        CHARACTER*8     MOD
        CHARACTER*16    LOI
        CHARACTER*(*)   FAMI
C       ----------------------------------------------------------------
        IF     ( LOI(1:8) .EQ. 'ROUSS_PR' .OR.
     1           LOI(1:10) .EQ. 'ROUSS_VISC' ) THEN
          CALL  RSLJPL(FAMI,KPG,KSP,LOI,IMAT,NMAT,MATER,
     &                 SIGF,VIN,VIND,DEPS,THETA,DT,DSDE)
C
        ELSEIF ( LOI(1:7)  .EQ. 'NADAI_B'    ) THEN
          CALL  INSJPL(MOD,NMAT,MATER,SIGF,VIN,DSDE)
C
        ELSEIF ( LOI(1:6) .EQ. 'LAIGLE'   ) THEN
          CALL  LGLJPL(MOD,NMAT,MATER,SIGF,DEVG,DEVGII,VIN,DSDE)
C
        ELSEIF (( LOI(1:10) .EQ. 'HOEK_BROWN'   ).OR.
     1          ( LOI(1:14) .EQ. 'HOEK_BROWN_EFF'   ))THEN
          CALL  HBRJPL(MOD,NMAT,MATER,SIGF,VIN,VIND,VP,VECP,DSDE)
        ELSEIF ( LOI(1:7) .EQ. 'IRRAD3M'   ) THEN
          CALL  IRRJPL(FAMI,KPG,KSP,MOD,NMAT,MATER,NR,NVI,SIGF,VIND,
     &                 VIN,SIGD,DSDE)
        ENDIF
C
        END
