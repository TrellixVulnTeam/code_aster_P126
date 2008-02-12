      SUBROUTINE CORDD2(JPRN1,JPRN2,ILI,ECODL,NEC,NCMP,N,NDDLOC,POS)
      IMPLICIT NONE
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 11/02/2008   AUTEUR PELLET J.PELLET 
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
C TOLE CRP_6
C ----------------------------------------------------------------------
C     BUT:
C     ----
C     ROUTINE PARALLELE A CORDDL POUR LES SOUS-STRUCTURES.
C
C     IN
C     --
C     JPRN1,JPRN2 : ADRESSES DE PRNO ( OBJET ET POINTEUR DE LONGUEUR)
C     NEC  : NBEC(GD) (SUPPOSE = 1!)
C     ILI  : NUMERO DU LIGREL (ICI TOUJOURS 1).
C     N    : NUMERO GLOBAL DU NOEUD
C     ECODL(*) : ENTIER CODE DU NUMERO LOCAL DU NOEUD
C
C     OUT
C     ---
C     NDDLOC : NBRE DE DDL SUPPORTES PAR CE NOEUD SUR L ELEMENT
C     POS    : TABLEAU DE CORRESPONDANCE AVEC LES DDL SUR LE NOEUD
C              EN TANT QUE NOEUD GLOBAL
C ----------------------------------------------------------------------
      INTEGER NBECMX,NCMP
      PARAMETER (NBECMX = 10)
      INTEGER IFIN(NBECMX)
      INTEGER PRNO
      INTEGER POS(1)
      INTEGER ECODG,ECODL(*)
C ----------------------------------------------------------------------
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C ----------------------------------------------------------------------
      INTEGER  ILI,NUNOEL,L,JPRN1,JPRN2,NEC,IEC,IN
      INTEGER NDDLOC,N,I,IECDG,IECDL
C
C     FONCTION D ACCES A PRNO
      PRNO(ILI,NUNOEL,L) = ZI(JPRN1-1+ZI(JPRN2+ILI-1)+
     +                     (NUNOEL-1)* (NEC+2)+L-1)
C
C - DEB ----------------------------------------------------------------
C
C --- IFIN DONNE POUR CHAQUE ENTIER CODE LE NOMBRE MAX DE DDLS
C --- QUE L'ON PEUT TROUVER SUR CET ENTIER :
C     ------------------------------------
      CALL ASSERT(NEC.GT.0.AND.NEC.LE.NBECMX)
      CALL ASSERT(NCMP.GT.0.AND.NCMP.LE.30*NBECMX)
      DO 10 IEC = 1, NEC-1
          IFIN(IEC) = 30
 10   CONTINUE
      IFIN(NEC) = NCMP - 30*(NEC-1)
C
      IN = 0
      NDDLOC = 0
C
C --- AJOUT DE LA BOUCLE 20 SUR LE NOMBRE D'ENTIERS CODES
C --- PAR RAPPORT A LA VERSION NORMALE DE CORDD2 , LES INSTRUCTIONS
C --- NE CHANGENT PAS, EXCEPTEE LA DEFINITION DE ECODL ET ECODG
C --- OU INTERVIENT L'INDICE D'ENTIER CODE :
C     ------------------------------------
      DO 20 IEC = 1, NEC
C
C      ECODG = PRNO(ILI,N,3)
        ECODG = PRNO(ILI,N,2+IEC)

        DO 30 I = 1,IFIN(IEC)
          ECODG = ECODG/2
          ECODL(IEC) = ECODL(IEC)/2
          IECDG = IAND(1,ECODG)
          IF (IECDG.GT.0) THEN
            IN = IN + 1
            IECDL = IAND(1,ECODL(IEC))
            IF (IECDL.GT.0) THEN
               NDDLOC = NDDLOC + 1
               POS(NDDLOC) = IN
            END IF
          END IF
  30    CONTINUE
C
  20  CONTINUE
C
      END
