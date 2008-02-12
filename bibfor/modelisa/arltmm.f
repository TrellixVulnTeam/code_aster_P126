      SUBROUTINE ARLTMM(JTYEL  ,NUMORI,ITYEL2)
C     
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 12/02/2008   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2008  EDF R&D                  WWW.CODE-ASTER.ORG
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
      IMPLICIT NONE
      INTEGER      NUMORI
      INTEGER      JTYEL,ITYEL2
C      
C ----------------------------------------------------------------------
C
C ROUTINE ARLEQUIN
C
C RETOURNE LE BON TYPE D'ELEMENT POUR LE PSEUDO MODELE A PARTIR
C DU MODELE INITIAL 
C
C ATTENTION : CAS SOUS-MAILS - 2D :
C    LE DECOUPAGE EN TRIA6 NE MARCHE PAS POUR L'INSTANT
C    CAR ON NE CREE QUE LES TRIA3 LORD DE LA FABRICATION DES SOUS-MAILS
C    IL FAUT REVOIR D'AUTRES FICHIERS
C
C ----------------------------------------------------------------------
C
C
C IN  JTYEL  : POINTEUR SUR MODELE(1:8)//'.MAILLE'
C IN  NUMORI : NUMERO ABSOLU DE LA MAILLE DANS LE MODELE INITIAL
C OUT ITYEL2 : NUMERO DU TE DANS '&CATA.TE.NOMTE'
C
C
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
C
      CHARACTER*32       JEXNUM,JEXNOM
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
      INTEGER      ITYEL
      CHARACTER*16 NOMTE,NOMTE2
      LOGICAL      LSTOP,LDECOU
C      
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- INITIALISATIONS
C
      LSTOP  = .FALSE.
      NOMTE2 = ' '
      
      IF (NUMORI.LT.0) THEN
        LDECOU = .TRUE.
        NUMORI = ABS(NUMORI)
      ELSE
        LDECOU = .FALSE. 
      ENDIF
C
C --- NOM DU TE
C      
      ITYEL  = ZI(JTYEL-1+NUMORI)
      CALL JENUNO(JEXNUM('&CATA.TE.NOMTE',ITYEL),NOMTE)   
C            
      IF (NOMTE(1:4).EQ.'MEDP'.OR.NOMTE(1:4).EQ.'MECP') THEN
        IF (LDECOU) THEN
          NOMTE2(1:4) = NOMTE(1:4)
          IF (NOMTE(5:7).EQ.'TR3'.OR.NOMTE(5:7).EQ.'QU4') THEN
            NOMTE2(5:7) = 'TR3'
          ELSEIF (NOMTE(5:7).EQ.'TR6'.OR.NOMTE(5:7).EQ.'QU8') 
     &      THEN
            NOMTE2(5:7) = 'TR3' 
          ELSE
            LSTOP = .TRUE.
          ENDIF 
        ELSE
          NOMTE2 = NOMTE
        ENDIF  

      ELSEIF (NOMTE(1:4).EQ.'MIPL') THEN
        IF (LDECOU) THEN
          NOMTE2(1:4) = NOMTE(1:4)
          IF (NOMTE(5:7).EQ.'TR6'.OR.NOMTE(5:7).EQ.'QU8') THEN
            NOMTE2(5:7) = 'TR6'
            WRITE(6,*) '<ARLTMM> SOUS-MAILS - 2D : 
     &           DECOUPAGE EN TRIA6 NE MARCHE PAS ENCORE'
            CALL ASSERT(.FALSE.) 
          ELSE
            LSTOP = .TRUE.
          ENDIF 
        ELSE
          NOMTE2 = NOMTE
        ENDIF  
      ELSEIF (NOMTE(1:4).EQ.'MEAX') THEN
        IF (LDECOU) THEN
          IF (NOMTE.EQ.'MEAXQU4') THEN
            NOMTE2 = 'MEAXTR3'
          ELSEIF (NOMTE.EQ.'MEAXTR3') THEN
            NOMTE2 = 'MEAXTR3' 
          ELSE
            LSTOP = .TRUE.
          ENDIF 
        ELSE
          NOMTE2 = NOMTE
        ENDIF   
      ELSEIF (NOMTE(1:5).EQ.'MECA_') THEN
        LSTOP = .TRUE.    
      ELSEIF (NOMTE(1:4).EQ.'METD') THEN
        LSTOP = .TRUE.   
      ELSEIF (NOMTE(1:4).EQ.'METC') THEN
        LSTOP = .TRUE. 
      ELSEIF (NOMTE(1:4).EQ.'MECX') THEN
        LSTOP = .TRUE. 
      ELSEIF (NOMTE(1:4).EQ.'MEDK') THEN
        LSTOP = .TRUE. 
      ELSEIF (NOMTE(1:4).EQ.'MEDS') THEN
        LSTOP = .TRUE. 
      ELSEIF (NOMTE(1:4).EQ.'MEQ4') THEN
        LSTOP = .TRUE.               
      ELSEIF (NOMTE(1:4).EQ.'MEC3') THEN
        LSTOP = .TRUE. 
      ELSE
        LSTOP = .TRUE.
      ENDIF  
C
      IF (LSTOP) THEN
        WRITE(6,*) 'ELEMENT DE TYPE <',NOMTE,'> INTERDIT'
        CALL ASSERT(.FALSE.) 
      ELSE
        CALL JENONU(JEXNOM('&CATA.TE.NOMTE',NOMTE2),ITYEL2)        
      ENDIF
C
      CALL JEDEMA()

      END
