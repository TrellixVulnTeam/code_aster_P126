      SUBROUTINE MECHTI (NOMA,TIME,CHTIME)
      IMPLICIT REAL*8 (A-H,O-Z)
      REAL*8                  TIME
      CHARACTER*(*)      NOMA
      CHARACTER*24                 CHTIME
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 14/05/98   AUTEUR VABHHTS J.PELLET 
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
C     CREE UNE CARTE D'INSTANT
C     ------------------------------------------------------------------
C IN  : NOMA   : NOM DU MAILLAGE
C IN  : TIME   : INSTANT DE CALCUL
C OUT : CHTIME : NOM DE LA CARTE CREEE
C     ------------------------------------------------------------------
      REAL*8       TPS(6),RUNDF
      CHARACTER*8  K8B, NOMCMP(6)
      COMPLEX*16   C16B
      DATA         NOMCMP/'INST    ','DELTAT  ','THETA   ',
     &                    'KHI     ','R       ','RHO     '/
C DEB-------------------------------------------------------------------
C
      CHTIME = '&&MECHTI.CH_INST_R'
      TPS(1) = TIME

      RUNDF=R8NNEM()
      TPS(2) = RUNDF
      TPS(3) = RUNDF
      TPS(4) = RUNDF
      TPS(5) = RUNDF
      TPS(6) = RUNDF

      CALL MECACT('V',CHTIME,'MAILLA',NOMA,'INST_R',6,NOMCMP,
     +            IBID,TPS,C16B,K8B)
C
      END
