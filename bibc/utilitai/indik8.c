/* ------------------------------------------------------------------ */
/*           CONFIGURATION MANAGEMENT OF EDF VERSION                  */
/* MODIF INDIK8 UTILITAI  DATE 23/09/2002   AUTEUR MCOURTOI M.COURTOIS */
/* ================================================================== */
/* COPYRIGHT (C) 1991 - 2001  EDF R&D              WWW.CODE-ASTER.ORG */
/*                                                                    */
/* THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR      */
/* MODIFY IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS     */
/* PUBLISHED BY THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE */
/* LICENSE, OR (AT YOUR OPTION) ANY LATER VERSION.                    */
/* THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL,    */
/* BUT WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF     */
/* MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU   */
/* GENERAL PUBLIC LICENSE FOR MORE DETAILS.                           */
/*                                                                    */
/* YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE  */
/* ALONG WITH THIS PROGRAM; IF NOT, WRITE TO : EDF R&D CODE_ASTER,    */
/*    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.     */
/* ================================================================== */
/* ------------------------------------------------------------------ */
/* recherche de la  n-ieme apparition d un K*8 dans une liste de K*8    */
/* resultat = indice si present / 0 si absent                           */
#include <stdio.h>
#include <string.h>

#if defined HPUX
#define  indik8_ indik8
#endif
#if defined SOLARIS || HPUX || IRIX || P_LINUX || TRU64 || SOLARIS64 
long indik8_ ( char *lstmot , char *mot , long *n , long *nmot ,long llm , long lm)
#elif defined PPRO_NT
long __stdcall INDIK8 ( char *lstmot, unsigned long llm, char *mot, unsigned long lm, long *n,long *nmot)
#endif

{
	long i,j=0;
	char *p,m[8];
	
        if ( lm < 8 ) {
	    for (i=0; i<lm;i++) m[i] = mot[i];
	    for (i=lm;i<8 ;i++) m[i] = ' ';
	} else if ( lm == 8 ) {
	    for (i=0;i<8;i++)  m[i] = mot[i];
	} else {
	  return 0;
	}
	
	if ( *n == 1 ) {
	   for (i=0;i<*nmot;i++){
	      p = lstmot+8*i;
	      if (! strncmp(m,p,8)) return (i+1);
	   }
	} else {
	   for (i=0;i<*nmot;i++){
	      p = lstmot+8*i;
	      if (! strncmp(m,p,8)) 
	         if ( ++j == *n ) return (i+1);
	   }
	}
	
	return 0;
}
