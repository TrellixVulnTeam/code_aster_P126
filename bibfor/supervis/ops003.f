      SUBROUTINE OPS003( ICMD , ICOND, IER )
      IMPLICIT REAL*8 (A-H,O-Z)
      INTEGER            ICMD , ICOND, IER
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF SUPERVIS  DATE 16/06/2000   AUTEUR D6BHHJP J.P.LEFEBVRE 
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
C     PROCEDURE "PROCEDURE" PERMET DE REDEFINIR DES CHOSES
C     ------------------------------------------------------------------
      CHARACTER*16     CBID, NOMCMD
      CHARACTER*32     NAME
      CHARACTER*8      UNITE,NOMSYM
      PARAMETER             (MXFILE=30)
      COMMON  /SUCC00/ UNITE(MXFILE), NAME(MXFILE)
      COMMON  /SUCN00/ IPASS,IFILE,JCMD
C     ------------------------------------------------------------------
      IF (ICOND .NE. -1) THEN
        CALL UTMESS('E','SUPERVISEUR','ERREUR FATALE  **** '//
     +                                'APPEL A COMMANDE "SUPERVISEUR".')
        IER = 1
        GOTO 9999
      ENDIF
      CALL GETRES(CBID,CBID,NOMCMD)
      IF ( IPASS.NE.80191 .OR. (IPASS.EQ.80191 .AND. IFILE.EQ.0) ) THEN
         CALL UTMESS('E','ANALYSE SEMANTIQUE (ERREUR XX)',
     +              'LA PROCEDURE "PROCEDURE" NE PEUT ETRE UTILISER '//
     +              'DANS LE FICHIER DE COMMANDES PRINCIPAL.')
         IER = 1
         GOTO 9999
      ENDIF
C
      IF ( ICMD .NE. JCMD ) THEN
         CALL UTMESS('E','ANALYSE SEMANTIQUE (ERREUR XX)',
     +               'LA PROCEDURE "PROCEDURE" DOIT ETRE UTILISER '//
     +               'EN TETE D''UN SOUS-FICHIER.')
         IER = 1
         GOTO 9999
      ENDIF
C
C     --- NOM DE L'INCLUDE ---
      CALL GETVTX(' ','NOM',1,1,1,NAME(IFILE),L)
C
C     --- IMPRESSION DU NOM DE L'INCLUDE SI ON EST EN MUET ---
      CALL LXINFU(IREAD,LREC,IWRITE,CBID )
      IF ( IWRITE .EQ. 0 ) THEN
         IWR = IUNIFI('MESSAGE')
         IF ( IWR .GT. 0 ) THEN
            WRITE(IWR,*) ' --- INCLUDE: "',NAME(IFILE),
     +                                    '"  SUR UNITE:',IREAD
         ENDIF
      ENDIF
C
C     --- ANNULATION DE LA PROCEDURE ---
      CALL SMCDEL(ICMD,0,IER)
      ICMD = ICMD - 1
 9999 CONTINUE
      END
