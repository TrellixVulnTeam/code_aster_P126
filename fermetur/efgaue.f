      SUBROUTINE EFGAUE( FID, TYPGEO, REFCOO, MODE_COO, NGAUSS,
     1                  GSCOO, WG, LOCNAME,CRET)
      IMPLICIT NONE
      INTEGER FID,TYPGEO,MODE_COO,NGAUSS,CRET
      REAL*8 REFCOO(*),GSCOO(*),WG(*)
      CHARACTER *(*) LOCNAME
      CALL UTMESS('F','EFGAUE','LA BIBLIOTHEQUE "MED" EST INDISPONIBLE'
     &            //' SUR CETTE MACHINE.')
      END
   
