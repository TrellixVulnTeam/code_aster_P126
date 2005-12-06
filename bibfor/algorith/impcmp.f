      SUBROUTINE IMPCMP(ICMP,NUMEDD,CHAINE)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 24/08/2005   AUTEUR MABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2005  EDF R&D                  WWW.CODE-ASTER.ORG
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
      IMPLICIT NONE
      INTEGER      ICMP
      CHARACTER*24 NUMEDD
      CHARACTER*16 CHAINE
C
C ----------------------------------------------------------------------
C ROUTINE APPELEE PAR : NMCONV
C ----------------------------------------------------------------------
C
C RETOURNE UNE CHAINE FORMATEE K16 POUR LES INFOS SUR UNE COMPOSANTE
C
C IN  ICMP   : NUMERO DE L'EQUATION
C IN  NUMEDD : NUMEROTATION NUME_DDL
C OUT CHAINE : CHAINE DU NOM DU NOEUD OU 'LIAISON_DDL'
C              CHAINE DU NOM DE LA CMP OU NOM DU LIGREL DE CHARGE
C
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
C
C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------
C
      CHARACTER*8   NOMNO,NOMCMP,TARDIF
      CHARACTER*16  INFOBL
      CHARACTER*24  LIGREL
C
C ----------------------------------------------------------------------
C
      CHAINE = '                '

      IF (ICMP.EQ.0) THEN
        GOTO 999
      ENDIF

      CALL RGNDAS('NUME_DDL',NUMEDD,ICMP,
     &             NOMNO,NOMCMP,TARDIF,LIGREL,INFOBL)
       
      IF ( TARDIF .NE. '  ' ) THEN
         IF (INFOBL(6:6).EQ.':') THEN
           CHAINE(1:16) = INFOBL(8:15)//LIGREL(1:8)
         ELSE
           CHAINE(1:16) = 'LIAISON'//LIGREL(1:8)
         ENDIF
      ELSE
         CHAINE(1:8)  = NOMNO
         CHAINE(9:16) = NOMCMP
      ENDIF

 999  CONTINUE

      END
