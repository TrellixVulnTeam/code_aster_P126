      SUBROUTINE VERITB ( NK1D, NDIM, ORIDEF )
C
      IMPLICIT     NONE
      INTEGER      NK1D, NDIM
      CHARACTER*8  ORIDEF
C ======================================================================
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF PREPOST  DATE 29/03/2002   AUTEUR CIBHHBC R.FERNANDES 
C ======================================================================
C COPYRIGHT (C) 1991 - 2002  EDF R&D                  WWW.CODE-ASTER.ORG
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
C                                                                       
C                                                                       
C ======================================================================
C ======================================================================
C --- BUT : VERIFICATION DE LA PRESENCE DES CHAMPS NECESSAIRES ---------
C ======================================================================
C IN  : NK1D   : NOMBRE D'OCCURENCE DE K1D -----------------------------
C --- : NDIM   : DIMENSION DE L'ESPACE ---------------------------------
C --- : ORIDEF : TYPE D'ORIENTATION DU DEFAUT --------------------------
C ======================================================================
      LOGICAL       EXIST, VERINR, TESTE
      INTEGER       I, IBID, NBVAL1, NBVAL2
      CHARACTER*8   MOTFAC, K8B,TABREV,TABMDB,TABTHR
      CHARACTER*19  TBINS1, TBINS2
C ======================================================================
      CALL JEMARQ()
C ======================================================================
C --- DEFINITION DES TABLES --------------------------------------------
C ======================================================================
      MOTFAC = 'K1D'
      TBINS1 = '&&VERITB.TBINS1'
      TBINS2 = '&&VERITB.TBINS2'
C ======================================================================
C --- CAS DE LA PREMIERE OCCURENCE DE K1D ------------------------------
C ======================================================================
      CALL GETVID ( MOTFAC , 'TABL_MECA_REV', 1,1,1, TABREV , IBID )
      CALL GETVID ( MOTFAC , 'TABL_MECA_MDB', 1,1,1, TABMDB , IBID )
      CALL GETVID ( MOTFAC , 'TABL_THER'    , 1,1,1, TABTHR , IBID )
C ======================================================================
C --- VERIFICATION DE LA PRESENCE DE LISTE D'INSTANT -------------------
C ======================================================================
      CALL TBEXIP ( TABREV, 'INST', EXIST, K8B )
      IF (.NOT.EXIST) THEN
         CALL UTMESS('F','VERITB','ABSENCE DU PARAMETRE INST POUR LA'//
     +               ' TABLE TABL_MECA_REV A L OCCURENCE 1')
      ENDIF
      CALL TBEXIP ( TABMDB, 'INST', EXIST, K8B )
      IF (.NOT.EXIST) THEN
         CALL UTMESS('F','VERITB','ABSENCE DU PARAMETRE INST POUR LA'//
     +               ' TABLE TABL_MECA_MDB A L OCCURENCE 1')
      ENDIF
      CALL TBEXIP ( TABTHR, 'INST', EXIST, K8B )
      IF (.NOT.EXIST) THEN
         CALL UTMESS('F','VERITB','ABSENCE DU PARAMETRE INST POUR LA'//
     +               ' TABLE TABL_THER A L OCCURENCE 1')
      ENDIF
C ======================================================================
C --- VERIFICATION DE LA COHERENCE DES LISTES D'INSTANT POUR -----------
C --- LES CHAMPS MECANIQUES --------------------------------------------
C ======================================================================
      CALL TBEXV1 ( TABREV, 'INST', TBINS1, 'V', NBVAL1, K8B )
      CALL TBEXV1 ( TABMDB, 'INST', TBINS2, 'V', NBVAL2, K8B )
      IF (NBVAL1.NE.NBVAL2) THEN
         CALL UTMESS('F','VERITB','LES TABLES TABL_MECA_REV ET'//
     +               ' TABL_MECA_MDB N ONT PAS LES MEMES DIMENSIONS')
      ENDIF
      TESTE = VERINR ( NBVAL1, TBINS1, TBINS2 )
      IF (TESTE) THEN
         CALL UTMESS('F','VERITB','LES TABLES N ONT PAS LES MEMES'//
     +               ' INSTANTS DE CALCULS')
      ENDIF
C ======================================================================
C --- DESTRUCTIONS DES VECTEURS INUTILES -------------------------------
C ======================================================================
      CALL JEDETR ( TBINS2 )
      CALL JEDETR ( TABREV )
      CALL JEDETR ( TABMDB )
      CALL JEDETR ( TABTHR )
C ======================================================================
C --- ITERATIONS SUR LES OCCURENCES DE K1D -----------------------------
C ======================================================================
      DO 10 I = 2, NK1D
C ======================================================================
C --- RECUPERATION DES TABLES ASSOCIEES A K1D POUR L'ITERATION COURANTE-
C ======================================================================
         CALL GETVID ( MOTFAC , 'TABL_MECA_REV', I,1,1, TABREV , IBID )
         CALL GETVID ( MOTFAC , 'TABL_MECA_MDB', I,1,1, TABMDB , IBID )
         CALL GETVID ( MOTFAC , 'TABL_THER'    , I,1,1, TABTHR , IBID )
C ======================================================================
C --- VERIFICATION DE LA PRESENCE DE LISTE D'INSTANT -------------------
C ======================================================================
         CALL TBEXIP ( TABREV, 'INST', EXIST, K8B )
         IF (.NOT.EXIST) THEN
            CALL UTMESS('F','VERITB','ABSENCE DU PARAMETRE INST POUR'//
     +                  ' LA TABLE TABL_MECA_REV')
         ENDIF
         CALL TBEXIP ( TABMDB, 'INST', EXIST, K8B )
         IF (.NOT.EXIST) THEN
            CALL UTMESS('F','VERITB','ABSENCE DU PARAMETRE INST POUR'//
     +                  ' LA TABLE TABL_MECA_MDB')
         ENDIF
         CALL TBEXIP ( TABTHR, 'INST', EXIST, K8B )
         IF (.NOT.EXIST) THEN
            CALL UTMESS('F','VERITB','ABSENCE DU PARAMETRE INST POUR'//
     +                  ' LA TABLE TABL_THER')
         ENDIF
C ======================================================================
C --- VERIFICATION DE LA COHERENCE DES LISTES D'INSTANT POUR -----------
C --- LES CHAMPS MECANIQUES --------------------------------------------
C ======================================================================
         CALL TBEXV1 ( TABREV, 'INST', TBINS2, 'V', NBVAL2, K8B )
         IF (NBVAL1.NE.NBVAL2) THEN
            CALL UTMESS('F','VERITB','LES TABLES N ONT PAS LES MEMES'//
     +                  ' DIMENSIONS')
         ENDIF
         TESTE = VERINR ( NBVAL1, TBINS1, TBINS2)
         IF (TESTE) THEN
            CALL UTMESS('F','VERITB','LES TABLES N ONT PAS LES MEMES'//
     +                  ' INSTANTS DE CALCULS')
         ENDIF
         CALL JEDETR ( TBINS2 )
         CALL TBEXV1 ( TABMDB, 'INST', TBINS2, 'V', NBVAL2, K8B )
         IF (NBVAL1.NE.NBVAL2) THEN
            CALL UTMESS('F','VERITB','LES TABLES N ONT PAS LES MEMES'//
     +                  ' DIMENSIONS')
         ENDIF
         TESTE = VERINR ( NBVAL1, TBINS1, TBINS2)
         IF (TESTE) THEN
            CALL UTMESS('F','VERITB','LES TABLES N ONT PAS LES MEMES'//
     +                  ' INSTANTS DE CALCULS')
         ENDIF
         CALL JEDETR ( TBINS2 )
         CALL JEDETR ( TABREV )
         CALL JEDETR ( TABMDB )
         CALL JEDETR ( TABTHR )
 10   CONTINUE      
      CALL JEDETR ( TBINS1 )
C ======================================================================
C --- VERIFICATION DE LA PRESENCE DES BONNES COMPOSANTES POUR LE -------
C --- CALCUL DES FACTEURS D'INTENSITE DE CONTRAINTE --------------------
C ======================================================================
      DO 20 I = 1, NK1D
C ======================================================================
C --- RECUPERATION DES TABLES ASSOCIEES A K1D POUR L'ITERATION COURANTE-
C ======================================================================
         CALL GETVID ( MOTFAC , 'TABL_MECA_REV', I,1,1, TABREV , IBID )
         CALL GETVID ( MOTFAC , 'TABL_MECA_MDB', I,1,1, TABMDB , IBID )
         CALL GETVID ( MOTFAC , 'TABL_THER'    , I,1,1, TABTHR , IBID )
         IF (NDIM.EQ.2) THEN
C ======================================================================
C --- CAS D'UNE DIMENSION D'ORDRE 2 ------------------------------------
C ======================================================================
            IF (ORIDEF.EQ.'CIRC') THEN
C ======================================================================
C --- CAS D'UN DEFAUT CIRCONFERENTIEL ----------------------------------
C ======================================================================
               CALL TBEXIP ( TABREV, 'SIYY', EXIST, K8B )
               IF (.NOT.EXIST) THEN
                  CALL UTMESS('F','VERITB','ABSENCE DU PARAMETRE SIYY'//
     +             ' POUR LA TABLE TABL_MECA_REV '//
     +             ' POUR UN DEFAUT CIRCONFERENTIEL EN DIMENSION 2' )
               ENDIF
               CALL TBEXIP ( TABMDB, 'SIYY', EXIST, K8B )
               IF (.NOT.EXIST) THEN
                  CALL UTMESS('F','VERITB','ABSENCE DU PARAMETRE SIYY'//
     +             ' POUR LA TABLE TABL_MECA_MDB '//
     +             ' POUR UN DEFAUT CIRCONFERENTIEL EN DIMENSION 2' )
               ENDIF
            ELSE
C ======================================================================
C --- CAS D'UN DEFAUT LONGITUDINAL -------------------------------------
C ======================================================================
               CALL TBEXIP ( TABREV, 'SIZZ', EXIST, K8B )
               IF (.NOT.EXIST) THEN
                  CALL UTMESS('F','VERITB','ABSENCE DU PARAMETRE SIZZ'//
     +             ' POUR LA TABLE TABL_MECA_REV '//
     +             ' POUR UN DEFAUT LONGITUDINAL EN DIMENSION 2' )
               ENDIF
               CALL TBEXIP ( TABMDB, 'SIZZ', EXIST, K8B )
               IF (.NOT.EXIST) THEN
                  CALL UTMESS('F','VERITB','ABSENCE DU PARAMETRE SIZZ'//
     +             ' POUR LA TABLE TABL_MECA_MDB '//
     +             ' POUR UN DEFAUT LONGITUDINAL EN DIMENSION 2' )
               ENDIF
            ENDIF
         ELSE
C ======================================================================
C --- CAS D'UNE DIMENSION D'ORDRE 3 ------------------------------------
C ======================================================================
            IF (ORIDEF.EQ.'CIRC') THEN
C ======================================================================
C --- CAS D'UN DEFAUT CIRCONFERENTIEL ----------------------------------
C ======================================================================
               CALL TBEXIP ( TABREV, 'SIZZ', EXIST, K8B )
               IF (.NOT.EXIST) THEN
                  CALL UTMESS('F','VERITB','ABSENCE DU PARAMETRE SIZZ'//
     +             ' POUR LA TABLE TABL_MECA_REV '//
     +             ' POUR UN DEFAUT CIRCONFERENTIEL EN DIMENSION 3' )
               ENDIF
               CALL TBEXIP ( TABMDB, 'SIZZ', EXIST, K8B )
               IF (.NOT.EXIST) THEN
                  CALL UTMESS('F','VERITB','ABSENCE DU PARAMETRE SIZZ'//
     +             ' POUR LA TABLE TABL_MECA_MDB '//
     +             ' POUR UN DEFAUT CIRCONFERENTIEL EN DIMENSION 3')
               ENDIF
            ELSE
C ======================================================================
C --- CAS D'UN DEFAUT LONGITUDINAL -------------------------------------
C ======================================================================
               CALL TBEXIP ( TABREV, 'SIXX', EXIST, K8B )
               IF (.NOT.EXIST) THEN
                  CALL UTMESS('F','VERITB','ABSENCE DU PARAMETRE SIXX'//
     +             ' POUR LA TABLE TABL_MECA_REV '//
     +             ' POUR UN DEFAUT LONGITUDINAL EN DIMENSION 3' )
               ENDIF
               CALL TBEXIP ( TABMDB, 'SIXX', EXIST, K8B )
               IF (.NOT.EXIST) THEN
                  CALL UTMESS('F','VERITB','ABSENCE DU PARAMETRE SIXX'//
     +             ' POUR LA TABLE TABL_MECA_MDB '//
     +             ' POUR UN DEFAUT LONGITUDINAL EN DIMENSION 3' )
               ENDIF
               CALL TBEXIP ( TABREV, 'SIYY', EXIST, K8B )
               IF (.NOT.EXIST) THEN
                  CALL UTMESS('F','VERITB','ABSENCE DU PARAMETRE SIYY'//
     +             ' POUR LA TABLE TABL_MECA_REV '//
     +             ' POUR UN DEFAUT LONGITUDINAL EN DIMENSION 3' )
               ENDIF
               CALL TBEXIP ( TABMDB, 'SIYY', EXIST, K8B )
               IF (.NOT.EXIST) THEN
                  CALL UTMESS('F','VERITB','ABSENCE DU PARAMETRE SIYY'//
     +             ' POUR LA TABLE TABL_MECA_MDB '//
     +             ' POUR UN DEFAUT LONGITUDINAL EN DIMENSION 3' )
               ENDIF
               CALL TBEXIP ( TABREV, 'SIZZ', EXIST, K8B )
               IF (.NOT.EXIST) THEN
                  CALL UTMESS('F','VERITB','ABSENCE DU PARAMETRE SIZZ'//
     +             ' POUR LA TABLE TABL_MECA_REV '//
     +             ' POUR UN DEFAUT LONGITUDINAL EN DIMENSION 3' )
               ENDIF
               CALL TBEXIP ( TABMDB, 'SIZZ', EXIST, K8B )
               IF (.NOT.EXIST) THEN
                  CALL UTMESS('F','VERITB','ABSENCE DU PARAMETRE SIZZ'//
     +             ' POUR LA TABLE TABL_MECA_MDB '//
     +             ' POUR UN DEFAUT LONGITUDINAL EN DIMENSION 3' )
               ENDIF
            ENDIF
         ENDIF
C ======================================================================
C --- VERIFICATION DU PARAMETRE TEMP POUR LA TABLE DONNEE THERMIQUE ----
C ======================================================================
         CALL TBEXIP ( TABTHR, 'TEMP', EXIST, K8B )
         IF (.NOT.EXIST) THEN
            CALL UTMESS('F','VERITB','ABSENCE DU PARAMETRE TEMP POUR'//
     +                  ' LA TABLE TABL_THER')
         ENDIF
         CALL JEDETR ( TABREV )
         CALL JEDETR ( TABMDB )
         CALL JEDETR ( TABTHR )
 20   CONTINUE
C ======================================================================
      CALL JEDEMA()
C ======================================================================
      END
