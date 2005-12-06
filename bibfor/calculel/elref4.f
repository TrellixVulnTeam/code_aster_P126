      SUBROUTINE ELREF4(ELRZ,FAMIL,NDIM,NNO,NNOS,NPG,IPOIDS,IVF,IDFDE,
     &                  JGANO)
      IMPLICIT NONE
      CHARACTER*(*) ELRZ,FAMIL
      INTEGER NDIM,NNO,NNOS,NPG,IPOIDS,IVF,IDFDE,JGANO
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 26/01/2004   AUTEUR VABHHTS J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2003  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
C (AT YOUR OPTION) ANY LATER VERSION.

C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.

C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C RESPONSABLE VABHHTS J.PELLET

C ----------------------------------------------------------------------
C BUT: RECUPERER DANS UNE ROUTINE TE00IJ LES ADRESSES DANS ZR
C      - DES POIDS DES POINTS DE GAUSS  : IPOIDS
C      - DES VALEURS DES FONCTIONS DE FORME : IVF
C      - DES VALEURS DES DERIVEES 1ERES DES FONCTIONS DE FORME : IDFDE
C      - DE LA MATRICE DE PASSAGE GAUSS -> NOEUDS : JGANO
C ----------------------------------------------------------------------
C   IN   ELRZ : NOM DE L'ELREFA (K8) OU ' '
C                 SI ELRZ=' ' : ON PREND L'ELREFA "PRINCIPAL"
C        FAMIL  : NOM (LOCAL) DE LA FAMILLE DE POINTS DE GAUSS :
C                 'STD','RICH',...
C   OUT  NDIM   : DIMENSION DE L'ESPACE (=NB COORDONNEES)
C        NNO    : NOMBRE DE NOEUDS DU TYPE_MAILLE
C        NNOS   : NOMBRE DE NOEUDS SOMMETS DU TYPE_MAILLE
C        NPG    : NOMBRE DE POINTS DE GAUSS
C        IPOIDS : ADRESSE DANS ZR DU TABLEAU POIDS(IPG)
C        IVF    : ADRESSE DANS ZR DU TABLEAU FF(INO,IPG)
C        IDFDE  : ADRESSE DANS ZR DU TABLEAU DFF(IDIM,INO,IPG)
C        JGANO  : ADRESSE DANS ZR DE LA MATRICE DE PASSAGE
C                      GAUSS -> NOEUDS (DIM= 2+NNO*NPG)
C                 ATTENTION : LES 2 1ERS TERMES SONT LES
C                             DIMMENSIONS DE LA MATRICE: NNO ET NPG
C   -------------------------------------------------------------------
      INTEGER JCOOPG,JDFD2


      CALL ELREF5(ELRZ,FAMIL,NDIM,NNO,NNOS,NPG,IPOIDS,JCOOPG,IVF,IDFDE,
     &            JDFD2,JGANO)


      END
