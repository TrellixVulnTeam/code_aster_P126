      SUBROUTINE IMPRSD(TYPESD,NOMSD,IFIC,TITRE)
      IMPLICIT   NONE
      CHARACTER*(*) TYPESD,NOMSD,TITRE
      INTEGER IFIC
C ----------------------------------------------------------------------
C MODIF UTILITAI  DATE 11/03/2002   AUTEUR CIBHHLV L.VIVAN 
C ======================================================================
C            CONFIGURATION MANAGEMENT OF EDF VERSION
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
C RESPONSABLE                            VABHHTS J.PELLET
C ----------------------------------------------------------------------
C  BUT : IMPRIMER UNE STRUCTURE DE DONNEE DONT ON CONNAIT LE TYPE


C TYPESD  IN K*   : TYPE DE LA STRUCTURE DE DONNEE A IMPRIMER
C                      'CHAMP' :   /CHAM_NO/CHAM_ELEM/RESUELEM/CARTE
C                                  /CHAM_NO_S/CHAM_ELEM_S
C NOMSD   IN K*  : NOM DE LA STRUCTURE DE DONNEES A IMPRIMER
C IFIC    IN I   : NUMERO LOGIQUE DU FICHIER ASCII POUR L'IMPRESSION
C TITRE   IN K*  : CHAINE DE CARACTERES IMPRIMEE EN TETE

C ----------------------------------------------------------------------
C     ----- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
      INTEGER ZI
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
C     ----- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------

      INTEGER      IBID,IFR,I1,I2,I3,I4,I5,I6,IB
      CHARACTER*16 TYP2SD
      CHARACTER*19 CH,CHS

C -DEB------------------------------------------------------------------

      CALL JEMARQ()
      TYP2SD = TYPESD

      IFR = IFIC
      IF ((IFR.EQ.0) .OR. (IFR.GT.100)) CALL UTMESS('F','IMPRSD',
     &    'STOP1')
      IBID = 0

C     1. ECRITURE DU TITRE :
C     ----------------------
      WRITE (IFR,*) ' '
      WRITE (IFR,*) '-----------------------------------------------'
      WRITE (IFR,*) TITRE


C     2. APPEL A LA BONNE ROUTINE :
C     ------------------------------

      IF ((TYP2SD.EQ.'CHAMP') .OR. (TYP2SD.EQ.'CHAMP_GD') .OR.
     &    (TYP2SD.EQ.'CHAMP_S')) THEN
C     ------------------------------------
        CH = NOMSD
        CHS = '&&IMPRSD.CHS'

        CALL EXISD('CHAM_NO_S',CH,I1)
        CALL EXISD('CHAM_ELEM_S',CH,I2)
        CALL EXISD('CHAM_NO',CH,I3)
        CALL EXISD('CHAM_ELEM',CH,I4)
        CALL EXISD('CARTE',CH,I5)
        CALL EXISD('RESUELEM',CH,I6)


        IF (I1.GT.0) CALL CNSIMP(CH,IFR)
        IF (I2.GT.0) CALL CESIMP(CH,IFR,IBID,IBID)

        IF (I3.GT.0) THEN
          CALL CNOCNS(CH,'V',CHS)
          CALL CNSIMP(CHS,IFR)
          CALL DETRSD('CHAM_NO_S',CHS)
        END IF

        IF (I4.GT.0) THEN
          CALL CELCES(CH,'V',CHS)
          CALL CESIMP(CHS,IFR,IBID,IBID)
          CALL DETRSD('CHAM_ELEM_S',CHS)
        END IF

        IF (I5.GT.0) THEN
          CALL CARCES(CH,'ELEM',' ','V',CHS,IB)
          CALL CESIMP(CHS,IFR,IBID,IBID)
          CALL DETRSD('CHAM_ELEM_S',CHS)
        END IF

        IF (I6.GT.0) WRITE (IFR,*) 'TYPE : RESUELEM NON TRAITE.'

      ELSE IF (TYP2SD.EQ.'TABLE') THEN
C     --------------------------------------


      ELSE
C     --------------------------------------
        CALL UTMESS('F','IMPRSD',' LE MOT CLE :'//TYP2SD//
     &              'N''EST PAS AUTORISE.')
      END IF

   10 CONTINUE
      CALL JEDEMA()
      END
