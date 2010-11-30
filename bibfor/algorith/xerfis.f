      SUBROUTINE XERFIS(NDIME,NINTER,NPTS,NPTM)
      IMPLICIT NONE 

      INTEGER    NDIME,NINTER,NPTS,NPTM

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 16/06/2010   AUTEUR CARON A.CARON 
C ======================================================================
C COPYRIGHT (C) 1991 - 2010  EDF R&D                  WWW.CODE-ASTER.ORG
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
C                 AFFICHER DES MESSAGES D'ERREUR LORSQUE LES
C                CONFIGURATIONS DE FISSURE SUR L'ELEMENT SONT :
C       (1) DOUTEUSES (AURAIT DU ETRE RETIRE)/ IMPROBABLES (FAUX)
C       (2) INTERDITES
C     ENTREE
C       NDIME   : DIMENSION DE L'ELEMENT FINI
C       NINTER  : NOMBRE DE POINTS D'INTERSECTION
C       NPTS    : NB DE POINTS INTERSEPTES EN UN DES 3 NOEUDS SOMMETS
C       NPTM    : NB DE POINT INTERSEPTES EN UN DES 3 NOEUDS MILIEUX
C......................................................................

      CALL JEMARQ()

C --- POUR LES TRIA6

      IF (NDIME.EQ.2) THEN
C
C PLUTOT QUE DE VERIFIER LES SEULES CONFIGURATIONS QUE L'ON RETIENT
C ON EXCLUT CELLES QUE L'ON NE VEUT PAS POUR AVOIR UNE MEILLEURE 
C VISIBILITE DES DIFFERENTES CONFIGURATIONS QUI SE PRESENTENT

C       NBRE DE POINT D'INTERSECTION INCORRECT (1) OU (2)
        IF (NINTER.LE.1) THEN
          CALL U2MESS('F','XFEM_64')

C       NBRE DE POINT D'INTERSECTION INCORRECT (1) OU (2)
        ELSEIF (NINTER.GT.3) THEN
          CALL U2MESS('F','XFEM_64')

C       NBRE PT INTER SOMMET > NBRE PT INTER TOTAL (1)
        ELSEIF (NPTS.GT.NINTER) THEN
          CALL U2MESS('F','XFEM_64')

C       LA FISSURE INTERCEPTE DEUX NOEUDS SOMMETS UNIQUEMENT (1) OU (2)
        ELSEIF (NINTER.EQ.2 .AND. NPTS.EQ.2) THEN
          CALL U2MESS('F','XFEM_64')

C       LA FISSURE INTERCEPTE LES 3 ARETES STRICTEMENT (2)
        ELSEIF (NINTER.EQ.3 .AND. NPTS.EQ.0) THEN
         CALL U2MESS('F','XFEM_64')

C       (2)
        ELSEIF (NINTER.EQ.3 .AND. NPTS.EQ.1 .AND. NPTM.NE.1) THEN
          CALL U2MESS('F','XFEM_64')

C       LA FISSURE JOUXTE UN BORD DE L'ELEMENT (1)
        ELSEIF (NINTER.EQ.3 .AND. NPTS.EQ.2 .AND. NPTM.EQ.1) THEN
          CALL U2MESS('F','XFEM_64')

C       (1) OU (2)
        ELSEIF (NINTER.EQ.3 .AND. NPTS.EQ.2 .AND. NPTM.NE.1) THEN
          CALL U2MESS('F','XFEM_64')

C       (1) OU (2)
        ELSEIF (NINTER.EQ.3 .AND. NPTS.EQ.3) THEN
          CALL U2MESS('F','XFEM_64')

        ENDIF

C --- POUR LES SEG3

      ELSEIF (NDIME.EQ.1) THEN

C       NBRE DE POINT D'INTERSECTION INCORRECT (1) OU (2)
        IF (NINTER.NE.1 .AND. NPTS.NE.0) THEN
          CALL U2MESS('F','XFEM_64')
        ENDIF

      ENDIF

      CALL JEDEMA()
      END
