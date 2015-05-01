# coding=utf-8

from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *

# ======================================================================
# COPYRIGHT (C) 1991 - 2013  EDF R&D                  WWW.CODE-ASTER.ORG
# THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
# IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
# THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
# (AT YOUR OPTION) ANY LATER VERSION.
#
# THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
# WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
# MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
# GENERAL PUBLIC LICENSE FOR MORE DETAILS.
#
# YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
# ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
#    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
# ======================================================================
# person_in_charge: jean-luc.flejou at edf.fr

#
# Définition d'une fonction pour affichage
#
#   AfficheMessage(texte)
#       affichage de texte
#
def AfficheMessage(MessageAffeCara):
    xx = max(map(len,MessageAffeCara.split('\n')))
    xx = max( (xx-16)/4,10)
    print "\n"*2,"! "*xx , "Affe_Cara_Elem","! "*xx
    print MessageAffeCara
    print "! "*(2*xx+8),"\n"*2


def ValeurCara(cara, Lcara, Lvale, valdefaut=None):
    if ( cara in Lcara ):
        return Lvale[Lcara.index(cara)]
    else:
        if valdefaut != None :
            return valdefaut
        else:
            raise AsException("Erreur construction de la commande")


def TransformeTuple(vale):
    if ( type(vale) is tuple ):
        return vale
    elif ( type(vale) is list ):
        return vale
    else:
        return tuple( (vale,) )


def IsDefinitionOK(cond, message , vmess=None):
    if ( not cond ):
        if ( vmess != None ):
            mess = str(message) % vmess
        else:
            mess = message
        print AfficheMessage( mess )
        raise AsException( mess )


def affe_cara_elem_prod(self, **args):
    POUTRE = args.get('POUTRE')
    BARRE = args.get('BARRE')
    COQUE = args.get('COQUE')
    CABLE = args.get('CABLE')
    DISCRET = args.get('DISCRET')
    DISCRET_2D = args.get('DISCRET_2D')
    GRILLE = args.get('GRILLE')
    mess0 =tr("Concept : %(k1)s\nOccurence numéro %(i1)d de %(k2)s, les cardinaux de CARA et VALE sont différents.")
    # - - - - - - - - - - - - - - -
    if POUTRE != None:
        mess1 = tr("Concept : %(k1)s\nOccurence numéro %(i1)d de POUTRE, mauvaise définition de %(k2)s.")
        for ii in range(len(POUTRE)):
            mclf = POUTRE[ii]
            if (mclf['SECTION'] == 'CERCLE'):
                cara = TransformeTuple( mclf['CARA'] )
                vale = TransformeTuple( mclf['VALE'] )
                IsDefinitionOK( len(cara) == len(vale), mess0 , {'k1':self.sdnom,'i1':ii+1,'k2':'POUTRE'} )
                if (mclf['VARI_SECT']=='CONSTANT'):
                    rayon = ValeurCara('R',  cara, vale)
                    ep    = ValeurCara('EP', cara, vale, rayon)
                    IsDefinitionOK( rayon > 0.0, mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'R'} )
                    IsDefinitionOK( (0< ep <= rayon), mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'EP'} )
                elif (mclf['VARI_SECT']=='HOMOTHETIQUE'):
                    if ( mclf['GROUP_MA'] ):
                        r_debut  = ValeurCara('R_DEBUT',  cara, vale)
                        r_fin    = ValeurCara('R_FIN',    cara, vale)
                        ep_debut = ValeurCara('EP_DEBUT', cara, vale, r_debut)
                        ep_fin   = ValeurCara('EP_FIN',   cara, vale, r_fin)
                        IsDefinitionOK( r_debut > 0.0, mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'R_DEBUT'} )
                        IsDefinitionOK( r_fin   > 0.0, mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'R_FIN'} )
                    elif ( mclf['MAILLE'] ):
                        r_debut  = ValeurCara('R1',  cara, vale)
                        r_fin    = ValeurCara('R2',  cara, vale)
                        ep_debut = ValeurCara('EP1', cara, vale, r_debut)
                        ep_fin   = ValeurCara('EP2', cara, vale, r_fin)
                        IsDefinitionOK( r_debut > 0.0, mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'R1'} )
                        IsDefinitionOK( r_fin   > 0.0, mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'R2'} )
                    IsDefinitionOK( (0.0< ep_debut <= r_debut), mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'EP1'} )
                    IsDefinitionOK( (0.0< ep_fin   <= r_fin),   mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'EP2'} )
            elif (mclf['SECTION'] == 'RECTANGLE'):
                cara = TransformeTuple( mclf['CARA'] )
                vale = TransformeTuple( mclf['VALE'] )
                IsDefinitionOK( len(cara) == len(vale), mess0 , {'k1':self.sdnom,'i1':ii+1,'k2':'POUTRE'} )
                if (mclf['VARI_SECT']=='CONSTANT'):
                    if ( 'H' in cara ):
                        h  = ValeurCara('H',  cara, vale)
                        ep = ValeurCara('EP', cara, vale, h*0.5)
                        IsDefinitionOK( h > 0.0, mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'H'} )
                        IsDefinitionOK( (0.0< ep <= h*0.5), mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'EP'} )
                    else:
                        hy  = ValeurCara('HY',  cara, vale)
                        epy = ValeurCara('EPY', cara, vale, hy*0.5)
                        hz  = ValeurCara('HZ',  cara, vale)
                        epz = ValeurCara('EPZ', cara, vale, hz*0.5)
                        IsDefinitionOK( hy > 0.0, mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'HY'} )
                        IsDefinitionOK( hz > 0.0, mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'HZ'} )
                        IsDefinitionOK( (0< epy <= hy*0.5), mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'EPY'} )
                        IsDefinitionOK( (0< epz <= hz*0.5), mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'EPZ'} )
                elif (mclf['VARI_SECT']=='HOMOTHETIQUE'):
                    if ( 'H1' in cara ):
                        h1  = ValeurCara('H1',  cara, vale)
                        ep1 = ValeurCara('EP1', cara, vale, h1*0.5)
                        h2  = ValeurCara('H2',  cara, vale)
                        ep2 = ValeurCara('EP2', cara, vale, h2*0.5)
                        IsDefinitionOK( h1 > 0.0, mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'H1'} )
                        IsDefinitionOK( h2 > 0.0, mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'H2'} )
                        IsDefinitionOK( (0< ep1 <= h1*0.5), mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'EP1'} )
                        IsDefinitionOK( (0< ep2 <= h2*0.5), mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'EP2'} )
                    else:
                        hy1  = ValeurCara('HY1',  cara, vale)
                        epy1 = ValeurCara('EPY1', cara, vale, hy1*0.5)
                        hy2  = ValeurCara('HY2',  cara, vale)
                        epy2 = ValeurCara('EPY2', cara, vale, hy2*0.5)
                        hz1  = ValeurCara('HZ1',  cara, vale)
                        epz1 = ValeurCara('EPZ1', cara, vale, hz1*0.5)
                        hz2  = ValeurCara('HZ2',  cara, vale)
                        epz2 = ValeurCara('EPZ2', cara, vale, hz2*0.5)
                        IsDefinitionOK( hy1 > 0.0, mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'HY1'} )
                        IsDefinitionOK( hy2 > 0.0, mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'HY2'} )
                        IsDefinitionOK( hz1 > 0.0, mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'HZ1'} )
                        IsDefinitionOK( hz2 > 0.0, mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'HZ2'} )
                        IsDefinitionOK( (0< epy1 <= hy1*0.5), mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'EPY1'} )
                        IsDefinitionOK( (0< epy2 <= hy2*0.5), mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'EPY2'} )
                        IsDefinitionOK( (0< epz1 <= hz1*0.5), mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'EPZ1'} )
                        IsDefinitionOK( (0< epz2 <= hz2*0.5), mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'EPZ2'} )
                elif (mclf['VARI_SECT']=='AFFINE'):
                    hy   = ValeurCara('HY',   cara, vale)
                    hz1  = ValeurCara('HZ1',  cara, vale)
                    hz2  = ValeurCara('HZ2',  cara, vale)
                    epy  = ValeurCara('EPY',  cara, vale, hy*0.5)
                    epz1 = ValeurCara('EPZ1', cara, vale, hz1*0.5)
                    epz2 = ValeurCara('EPZ2', cara, vale, hz2*0.5)
                    IsDefinitionOK( hy  > 0.0, mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'HY'} )
                    IsDefinitionOK( hz1 > 0.0, mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'HZ1'} )
                    IsDefinitionOK( hz2 > 0.0, mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'HZ2'} )
                    IsDefinitionOK( (0< epy  <= hy *0.5), mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'EPY'} )
                    IsDefinitionOK( (0< epz1 <= hz1*0.5), mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'EPZ1'} )
                    IsDefinitionOK( (0< epz2 <= hz2*0.5), mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'EPZ2'} )
            elif (mclf['SECTION'] == 'GENERALE'):
                if (mclf['VARI_SECT']=='CONSTANT'):
                    tmp = mclf.cree_dict_toutes_valeurs()
                    if ( 'CARA' in tmp.keys() ):
                        cara = TransformeTuple( mclf['CARA'] )
                        vale = TransformeTuple( mclf['VALE'] )
                        IsDefinitionOK( len(cara) == len(vale), mess0 , {'k1':self.sdnom,'i1':ii+1,'k2':'POUTRE'} )
                        a  = ValeurCara('A' , cara, vale)
                        iy = ValeurCara('IY', cara, vale)
                        iz = ValeurCara('IZ', cara, vale)
                        jx = ValeurCara('JX', cara, vale)
                        IsDefinitionOK( a  > 0.0, mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'A'} )
                        IsDefinitionOK( iy > 0.0, mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'IY'} )
                        IsDefinitionOK( iz > 0.0, mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'IZ'} )
                        IsDefinitionOK( jx > 0.0, mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'JX'} )
                elif (mclf['VARI_SECT']=='HOMOTHETIQUE'):
                    cara = TransformeTuple( mclf['CARA'] )
                    vale = TransformeTuple( mclf['VALE'] )
                    IsDefinitionOK( len(cara) == len(vale), mess0 , {'k1':self.sdnom,'i1':ii+1,'k2':'POUTRE'} )
                    a1  = ValeurCara('A1' , cara, vale)
                    iy1 = ValeurCara('IY1', cara, vale)
                    iz1 = ValeurCara('IZ1', cara, vale)
                    jx1 = ValeurCara('JX1', cara, vale)
                    a2  = ValeurCara('A2' , cara, vale)
                    iy2 = ValeurCara('IY2', cara, vale)
                    iz2 = ValeurCara('IZ2', cara, vale)
                    jx2 = ValeurCara('JX2', cara, vale)
                    IsDefinitionOK( a1  > 0.0, mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'A1'} )
                    IsDefinitionOK( iy1 > 0.0, mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'IY1'} )
                    IsDefinitionOK( iz1 > 0.0, mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'IZ1'} )
                    IsDefinitionOK( jx1 > 0.0, mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'JX1'} )
                    IsDefinitionOK( a2  > 0.0, mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'A2'} )
                    IsDefinitionOK( iy2 > 0.0, mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'IY2'} )
                    IsDefinitionOK( iz2 > 0.0, mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'IZ2'} )
                    IsDefinitionOK( jx2 > 0.0, mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'JX2'} )
    # - - - - - - - - - - - - - - -
    if BARRE != None:
        mess1 = tr("Concept : %s\n" % self.sdnom + "Occurence numéro %d de BARRE, mauvaise définition de %s.")
        for ii in range(len(BARRE)):
            mclf = BARRE[ii]
            if (mclf['SECTION'] == 'CERCLE'):
                cara = TransformeTuple( mclf['CARA'] )
                vale = TransformeTuple( mclf['VALE'] )
                IsDefinitionOK( len(cara) == len(vale), mess0 , {'k1':self.sdnom,'i1':ii+1,'k2':'BARRE'} )
                rayon = ValeurCara('R',  cara, vale)
                ep    = ValeurCara('EP', cara, vale, rayon)
                IsDefinitionOK( rayon > 0.0, mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'R'} )
                IsDefinitionOK( (0.0 < ep <= rayon), mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'EP'} )
            elif (mclf['SECTION'] == 'RECTANGLE'):
                cara = TransformeTuple( mclf['CARA'] )
                vale = TransformeTuple( mclf['VALE'] )
                IsDefinitionOK( len(cara) == len(vale), mess0 , {'k1':self.sdnom,'i1':ii+1,'k2':'BARRE'} )
                if ( 'H' in cara ):
                    h  = ValeurCara('H',  cara, vale)
                    ep = ValeurCara('EP', cara, vale, h*0.5)
                    IsDefinitionOK( h > 0.0, mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'H'} )
                    IsDefinitionOK( (0< ep <= h*0.5), mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'EP'} )
                else:
                    hy  = ValeurCara('HY',  cara, vale)
                    epy = ValeurCara('EPY', cara, vale, hy*0.5)
                    hz  = ValeurCara('HZ',  cara, vale)
                    epz = ValeurCara('EPZ', cara, vale, hz*0.5)
                    IsDefinitionOK( hy > 0.0, mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'HY'} )
                    IsDefinitionOK( hz > 0.0, mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'HZ'} )
                    IsDefinitionOK( (0< epy <= hy*0.5), mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'EPY'} )
                    IsDefinitionOK( (0< epz <= hz*0.5), mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'EPZ'} )
            elif (mclf['SECTION'] == 'GENERALE'):
                tmp = mclf.cree_dict_toutes_valeurs()
                if ( 'CARA' in tmp.keys() ):
                    cara = TransformeTuple( mclf['CARA'] )
                    vale = TransformeTuple( mclf['VALE'] )
                    IsDefinitionOK( len(cara) == len(vale), mess0 , {'k1':self.sdnom,'i1':ii+1,'k2':'BARRE'} )
                    vale = ValeurCara('A' , cara, vale)
                    IsDefinitionOK( vale > 0.0, mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'A'} )
    # - - - - - - - - - - - - - - -
    if COQUE != None:
        mess1 = tr("Concept : %s\n" % self.sdnom + "Occurence numéro %d de COQUE, mauvaise définition de %s.")
        for ii in range(len(COQUE)):
            mclf = COQUE[ii]
            if ( 'EPAIS' in mclf ):
                vale =  mclf['EPAIS']
                IsDefinitionOK( vale > 0.0, mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'EPAIS'} )
            if ( 'A_CIS' in mclf ):
                vale =  mclf['A_CIS']
                IsDefinitionOK( vale > 0.0, mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'A_CIS'} )
            if ( 'COEF_RIGI_DRZ' in mclf ):
                vale =  mclf['COEF_RIGI_DRZ']
                IsDefinitionOK( vale > 0.0, mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'COEF_RIGI_DRZ'} )
            if ( 'COQUE_NCOU' in mclf ):
                vale =  mclf['COQUE_NCOU']
                IsDefinitionOK( vale > 0,   mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'COQUE_NCOU'} )
    # - - - - - - - - - - - - - - -
    if CABLE != None:
        mess1 = tr("Concept : %s\n" % self.sdnom + "Occurence numéro %d de CABLE, mauvaise définition de %s.")
        for ii in range(len(CABLE)):
            mclf = CABLE[ii]
            if ( 'SECTION' in mclf ):
                vale =  mclf['SECTION']
                IsDefinitionOK( vale>0.0, mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'SECTION'} )
    # - - - - - - - - - - - - - - -
    if DISCRET != None:
        pass
    # - - - - - - - - - - - - - - -
    if DISCRET_2D != None:
        pass
    # - - - - - - - - - - - - - - -
    if GRILLE != None:
        mess1 = tr("Concept : %s\n" % self.sdnom + "Occurence numéro %d de GRILLE, mauvaise définition de %s.")
        for ii in range(len(GRILLE)):
            mclf = GRILLE[ii]
            if ( 'SECTION' in mclf ):
                vale =  mclf['SECTION']
                IsDefinitionOK( vale>=0.0, mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'SECTION'} )
            if ( 'EXCENTREMENT' in mclf ):
                vale =  mclf['EXCENTREMENT']
                IsDefinitionOK( vale>=0.0, mess1 , {'k1':self.sdnom,'i1':ii+1,'k2':'EXCENTREMENT'} )
    #
    # Tout est ok
    return cara_elem



AFFE_CARA_ELEM=MACRO(nom="AFFE_CARA_ELEM",
   sd_prod=affe_cara_elem_prod,
   op=OPS('Macro.affe_cara_elem_ops.affe_cara_elem_ops'),
   fr=tr("Affectation de caractéristiques à des éléments de structure"),
   reentrant='n',
   UIinfo ={"groupes":("Modélisation",)},
   regles = (AU_MOINS_UN('POUTRE','BARRE','COQUE','CABLE','DISCRET','DISCRET_2D','MASSIF',
                         'GRILLE','MEMBRANE','MULTIFIBRE','RIGI_PARASOL'),
             PRESENT_PRESENT('MULTIFIBRE','GEOM_FIBRE'),
             EXCLUS('DISCRET','DISCRET_2D'),),
   MODELE = SIMP(statut='o',typ=modele_sdaster ),
   INFO   = SIMP(statut='f',typ='I', defaut= 1 ,into=(1,2) ),
   VERIF  = SIMP(statut='f',typ='TXM',validators=NoRepeat(),max='**',into=("MAILLE","NOEUD") ),
#
# ==============================================================================
    POUTRE  = FACT(statut= 'f',max= '**',
        SECTION = SIMP(statut= 'o',typ= 'TXM' ,into= ("GENERALE","RECTANGLE","CERCLE") ),
        b_generale = BLOC(condition = " SECTION == 'GENERALE'",
            regles = (UN_PARMI('MAILLE','GROUP_MA'),),
            MAILLE    = SIMP(statut= 'f',typ= ma  ,validators= NoRepeat(),max= '**'),
            GROUP_MA  = SIMP(statut= 'f',typ= grma,validators= NoRepeat(),max= '**'),
            VARI_SECT = SIMP(statut= 'f',typ= 'TXM',into= ("CONSTANT","HOMOTHETIQUE"),defaut= "CONSTANT"),
            b_constant = BLOC(condition = "VARI_SECT == 'CONSTANT'",
                regles = (PRESENT_ABSENT('TABLE_CARA','CARA'),
                          PRESENT_PRESENT('TABLE_CARA','NOM_SEC'),
                          PRESENT_PRESENT('CARA','VALE'),),
                TABLE_CARA = SIMP(statut= 'f',typ=table_sdaster),
                NOM_SEC    = SIMP(statut= 'f',typ= 'TXM'),
                CARA       = SIMP(statut= 'f',typ= 'TXM',min= 4 ,max= 15,
                    fr= tr("A,IY,IZ,JX sont des paramètres obligatoires"),
                    validators= [NoRepeat(), Compulsory(['A','IY','IZ','JX'])],
                    into= ("A","IY","IZ","AY","AZ","EY","EZ","JX","RY","RZ","RT","JG","IYR2","IZR2","AI") ),
                VALE       = SIMP(statut= 'f',typ= 'R',min= 4 ,max= 15),
            ),
            b_homothetique = BLOC(condition = "VARI_SECT == 'HOMOTHETIQUE'",
                CARA = SIMP(statut= 'o',typ= 'TXM',min= 8 ,max= 30,
                    fr= tr("A1,A2,IY1,IY2,IZ1,IZ2,JX1,JX2 sont des paramètres obligatoires"),
                    validators= [NoRepeat(), Compulsory(['A1','A2','IY1','IY2','IZ1','IZ2','JX1','JX2'])],
                    into= ("A1","IY1","IZ1","AY1","AZ1","EY1","EZ1","JX1","RY1", "RZ1","RT1","JG1","IYR21","IZR21","AI1",
                           "A2","IY2","IZ2","AY2","AZ2","EY2","EZ2","JX2","RY2", "RZ2","RT2","JG2","IYR22","IZR22","AI2") ),
                VALE = SIMP(statut= 'o',typ= 'R',min= 8 ,max= 30),
            ),
        ),
        b_rectangle = BLOC(condition = "SECTION == 'RECTANGLE'",
            regles = (UN_PARMI('MAILLE','GROUP_MA'),),
            MAILLE    = SIMP(statut= 'f',typ= ma  ,validators= NoRepeat(),max= '**'),
            GROUP_MA  = SIMP(statut= 'f',typ= grma,validators= NoRepeat(),max= '**'),
            VARI_SECT = SIMP(statut= 'f',typ= 'TXM',into= ("CONSTANT","HOMOTHETIQUE","AFFINE"),defaut= "CONSTANT"),
            b_constant = BLOC(condition = "VARI_SECT == 'CONSTANT'",
                CARA  = SIMP(statut= 'o',typ= 'TXM',min= 1 ,max= 4,
                    validators = [NoRepeat(),
                                  OrVal( [AndVal( [Compulsory(['H']),Absent(['HY','HZ','EPY','EPZ'])] ),
                                          AndVal( [Compulsory(['HY','HZ']),Together(['EPY','EPZ']),Absent(['H','EP'])] )] )],
                    into= ("H","EP", "HY","HZ","EPY","EPZ"),),
                VALE  = SIMP(statut= 'o',typ= 'R',min= 1 ,max= 4),
            ),
            b_homothetique = BLOC(condition = "VARI_SECT == 'HOMOTHETIQUE'",
                CARA  = SIMP(statut= 'o',typ= 'TXM',min= 2 ,max= 8,
                    validators = [NoRepeat(),
                                  OrVal( [AndVal( [Compulsory(['H1','H2']),Together(['EP1','EP2']),
                                                   Absent(['HY1','HY2','HZ1','HZ2','EPY1','EPY2','EPZ1','EPZ2'])] ),
                                          AndVal( [Compulsory(['HY1','HY2','HZ1','HZ2']),Together(['EPY1','EPY2','EPZ1','EPZ2']),
                                                   Absent(['H1','H2','EP1','EP2'])] )] )],
                    into= ("H1","HZ1","HY1","EP1","EPY1","EPZ1",
                           "H2","HZ2","HY2","EP2","EPY2","EPZ2") ),
                VALE  = SIMP(statut= 'o',typ= 'R',min= 2 ,max= 8),
            ),
            b_affine = BLOC(condition = "VARI_SECT == 'AFFINE'",
                CARA = SIMP(statut= 'o',typ= 'TXM',min= 3 ,max= 6,
                    validators= [NoRepeat(), AndVal( [Compulsory(['HY','HZ1','HZ2']), Together(['EPY','EPZ1','EPZ2'])] )],
                    into= ("HY","EPY", "HZ1","EPZ1","HZ2","EPZ2") ),
                VALE = SIMP(statut= 'o',typ= 'R',min= 3 ,max= 6),
            ),
        ),
        b_cercle = BLOC(condition = " SECTION == 'CERCLE'",
            VARI_SECT = SIMP(statut= 'f',typ= 'TXM',into= ("CONSTANT","HOMOTHETIQUE"),defaut= "CONSTANT"),
            b_constant = BLOC(condition = "VARI_SECT == 'CONSTANT'",
                regles = (UN_PARMI('MAILLE','GROUP_MA'),),
                MAILLE   = SIMP(statut= 'f',typ= ma  ,validators= NoRepeat(),max= '**'),
                GROUP_MA = SIMP(statut= 'f',typ= grma,validators= NoRepeat(),max= '**'),
                CARA     = SIMP(statut= 'o',typ= 'TXM',min=1, max=2,
                    validators= [NoRepeat(), Compulsory('R')] ,
                    fr= tr("R est un paramètre obligatoire"),
                    into= ("R","EP") ),
                VALE     = SIMP(statut= 'o',typ= 'R',min=1, max=2,),
            ),
            b_homothetique = BLOC(condition = "VARI_SECT == 'HOMOTHETIQUE'",
                regles = (UN_PARMI('MAILLE','GROUP_MA'),),
                MAILLE   = SIMP(statut= 'f',typ= ma  ,validators= NoRepeat(),max= '**'),
                GROUP_MA = SIMP(statut= 'f',typ= grma,validators= NoRepeat(),max= '**'),
                b_maille = BLOC(condition = "MAILLE != None",
                    CARA = SIMP(statut= 'o',typ= 'TXM', min=2, max=4,
                        validators= [NoRepeat(), AndVal( [Compulsory(['R1','R2']), Together(['EP1','EP2'])] )],
                        fr= tr("R1, R2 sont des paramètres obligatoires"),
                        into= ("R1","R2","EP1","EP2") ),
                ),
                b_grma  = BLOC(condition = "GROUP_MA != None",
                    CARA = SIMP(statut= 'o',typ= 'TXM', min=2, max= 4,
                        validators= [NoRepeat(), AndVal( [Compulsory(['R_DEBUT','R_FIN']), Together(['EP_DEBUT','EP_FIN'])] )],
                        fr= tr("R_DEBUT, R_FIN sont des paramètres obligatoires"),
                        into= ("R_DEBUT","R_FIN","EP_DEBUT","EP_FIN") ),
                ),
                VALE = SIMP(statut= 'o',typ= 'R',min= 2 ,max= 4),
            ),
            MODI_METRIQUE = SIMP(statut= 'f',typ= 'TXM',defaut= "NON",into= ("OUI","NON") ),
            FCX           = SIMP(statut= 'f',typ= (fonction_sdaster,nappe_sdaster,formule) ),
            TUYAU_NSEC    = SIMP(statut= 'f',typ= 'I',val_max= 32,defaut= 16),
            TUYAU_NCOU    = SIMP(statut= 'f',typ= 'I',val_max= 10,defaut= 3),
        ),
    ),
#
# ==============================================================================
    BARRE = FACT(statut='f',max='**',
        regles = (UN_PARMI('MAILLE','GROUP_MA'),),
        MAILLE   = SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
        GROUP_MA = SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
        SECTION  = SIMP(statut='o',typ='TXM',into=("GENERALE","RECTANGLE","CERCLE") ),
        b_generale = BLOC(condition = "SECTION=='GENERALE'",
            regles = (PRESENT_ABSENT('TABLE_CARA','CARA'),
                      PRESENT_PRESENT('TABLE_CARA','NOM_SEC'),
                      PRESENT_PRESENT('CARA','VALE')),
            TABLE_CARA = SIMP(statut='f',typ=table_sdaster),
            NOM_SEC    = SIMP(statut='f',typ='TXM',validators=LongStr(1,24) ),
            CARA       = SIMP(statut='f',typ='TXM',into=("A",) ),
            VALE       = SIMP(statut='f',typ='R',min=1,max=1 ),
        ),
        b_rectangle = BLOC(condition = "SECTION=='RECTANGLE'",
            CARA = SIMP(statut='o',typ='TXM', min=1, max=4,
                validators = [NoRepeat(),
                              OrVal( [AndVal( [Compulsory(['H']),Absent(['HY','HZ','EPY','EPZ'])] ),
                                      AndVal( [Compulsory(['HY','HZ']),Together(['EPY','EPZ']),Absent(['H','EP'])] )] )],
                into=("H","EP","HZ","HY","EPY","EPZ"), ),
            VALE = SIMP(statut='o',typ='R',min=1,max=4 ), ),
        b_cercle = BLOC(condition = "SECTION=='CERCLE'",
            CARA = SIMP(statut='o',typ='TXM',validators=[NoRepeat(),Compulsory(['R'])],min=1,max=2,into=("R","EP") ),
            VALE = SIMP(statut='o',typ='R',min=1,max=2 ), ),
        FCX = SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule) ),
    ),
#
# ==============================================================================
    COQUE= FACT(statut='f',max='**',
        regles = (UN_PARMI('MAILLE','GROUP_MA' ),
                  EXCLUS('ANGL_REP','VECTEUR'),
                  PRESENT_PRESENT( 'EXCENTREMENT',   'INER_ROTA' ),
                  PRESENT_PRESENT( 'EXCENTREMENT_FO','INER_ROTA' ),
                  UN_PARMI('EPAIS','EPAIS_FO' ),
                  EXCLUS('EXCENTREMENT','EXCENTREMENT_FO'),),
        MAILLE          = SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
        GROUP_MA        = SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
        EPAIS           = SIMP(statut='f',typ='R' ),
        EPAIS_FO        = SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule) ),
        ANGL_REP        = SIMP(statut='f',typ='R',min=2,max=2),
        VECTEUR         = SIMP(statut='f',typ='R',min=3,max=3),
        A_CIS           = SIMP(statut='f',typ='R',defaut= 0.8333333E0),
        COEF_RIGI_DRZ   = SIMP(statut='f',typ='R',defaut= 1.0E-5 ),
        COQUE_NCOU      = SIMP(statut='f',typ='I',defaut= 1 ),
        EXCENTREMENT    = SIMP(statut='f',typ='R' ),
        EXCENTREMENT_FO = SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule) ),
        INER_ROTA       = SIMP(statut='f',typ='TXM',into=("OUI",) ),
        MODI_METRIQUE   = SIMP(statut='f',typ='TXM',defaut="NON",into=("OUI","NON") ),
    ),
#
# ==============================================================================
    CABLE = FACT(statut='f',max='**',
        regles = (UN_PARMI('MAILLE','GROUP_MA'),),
        MAILLE   = SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
        GROUP_MA = SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
        N_INIT   = SIMP(statut='f',typ='R',defaut= 5000. ),
        SECTION  = SIMP(statut='f',typ='R' ),
        FCX      = SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule) ),
    ),
#
# ==============================================================================
    DISCRET = FACT(statut='f',max='**',
        REPERE    = SIMP(statut='f',typ='TXM',into=("LOCAL","GLOBAL") ),
        AMOR_HYST = SIMP(statut='f',typ='R' ),
        SYME      = SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON"),),
        b_SYME_OUI = BLOC(condition="SYME=='OUI'",
            fr=tr("SYMETRIQUE: Affectation de matrices de rigidité, de masse ou d'amortissement à des mailles ou noeuds"),
            CARA = SIMP(statut='o',typ='TXM',validators=NoRepeat(),max=1,defaut="None",
            into = ("K_T_D_N", "K_T_D_L", "K_TR_D_N", "K_TR_D_L", "K_T_N", "K_T_L", "K_TR_N", "K_TR_L",
                    "M_T_D_N", "M_T_D_L", "M_TR_D_N", "M_TR_D_L", "M_T_N", "M_T_L", "M_TR_N", "M_TR_L",
                    "A_T_D_N", "A_T_D_L", "A_TR_D_N", "A_TR_D_L", "A_T_N", "A_T_L", "A_TR_N", "A_TR_L",),),
            #  Affection des caractéristiques de RIGIDITE/AMORTISSEMENT/MASSE
            b_AK_T_D_N = BLOC(condition = "((CARA=='K_T_D_N')or(CARA=='A_T_D_N'))",
                fr       = tr("NOEUD: 3 valeurs (triangulaire supérieure par colonne)"),
                regles   = (UN_PARMI('MAILLE','GROUP_MA','NOEUD','GROUP_NO'),),
                NOEUD    = SIMP(statut='f',typ=no  ,validators=NoRepeat(),max='**'),
                GROUP_NO = SIMP(statut='f',typ=grno,validators=NoRepeat(),max='**'),
                MAILLE   = SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
                GROUP_MA = SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
                VALE     = SIMP(statut='o',typ='R',min=3 ,max=3 ),),
            b_AK_T_D_L = BLOC(condition = "((CARA=='K_T_D_L')or(CARA=='A_T_D_L'))",
                fr       = tr("SEGMENT: 3 valeurs (triangulaire supérieure par colonne)"),
                regles   = (UN_PARMI('MAILLE','GROUP_MA'),),
                MAILLE   = SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
                GROUP_MA = SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
                VALE     = SIMP(statut='o',typ='R',min=3 ,max=3 ),),
            b_AK_TR_D_N  = BLOC(condition = "((CARA=='K_TR_D_N')or(CARA=='A_TR_D_N'))",
                fr       = tr("NOEUD: 6 valeurs (triangulaire supérieure par colonne)"),
                regles   = (UN_PARMI('MAILLE','GROUP_MA','NOEUD','GROUP_NO'),),
                NOEUD    = SIMP(statut='f',typ=no  ,validators=NoRepeat(),max='**'),
                GROUP_NO = SIMP(statut='f',typ=grno,validators=NoRepeat(),max='**'),
                MAILLE   = SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
                GROUP_MA = SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
                VALE     = SIMP(statut='o',typ='R',min=6 ,max=6 ),),
            b_AK_TR_D_L = BLOC(condition = "((CARA=='K_TR_D_L')or(CARA=='A_TR_D_L'))",
                fr       = tr("SEGMENT: 6 valeurs (triangulaire supérieure par colonne)"),
                regles   = (UN_PARMI('MAILLE','GROUP_MA'),),
                MAILLE   = SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
                GROUP_MA = SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
                VALE     = SIMP(statut='o',typ='R',min=6 ,max=6 ),),
            b_MAK_T_N = BLOC(condition = "((CARA=='K_T_N')or(CARA=='A_T_N')or(CARA=='M_T_N'))",
                fr       = tr("NOEUD: 6 valeurs (triangulaire supérieure par colonne)"),
                regles   = (UN_PARMI('MAILLE','GROUP_MA','NOEUD','GROUP_NO'),),
                NOEUD    = SIMP(statut='f',typ=no  ,validators=NoRepeat(),max='**'),
                GROUP_NO = SIMP(statut='f',typ=grno,validators=NoRepeat(),max='**'),
                MAILLE   = SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
                GROUP_MA = SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
                VALE     = SIMP(statut='o',typ='R',min=6 ,max=6 ),),
            b_MAK_T_L = BLOC(condition = "((CARA=='K_T_L')or(CARA=='A_T_L')or(CARA=='M_T_L'))",
                fr       = tr("SEGMENT: 21 valeurs (triangulaire supérieure par colonne)"),
                regles   = (UN_PARMI('MAILLE','GROUP_MA'),),
                MAILLE   = SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
                GROUP_MA = SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
                VALE     = SIMP(statut='o',typ='R',min=21,max=21),),
            b_MAK_TR_N = BLOC(condition = "((CARA=='K_TR_N')or(CARA=='A_TR_N')or(CARA=='M_TR_N'))",
                fr       = tr("NOEUD: 21 valeurs (triangulaire supérieure par colonne)"),
                regles   = (UN_PARMI('MAILLE','GROUP_MA','NOEUD','GROUP_NO'),),
                NOEUD    = SIMP(statut='f',typ=no  ,validators=NoRepeat(),max='**'),
                GROUP_NO = SIMP(statut='f',typ=grno,validators=NoRepeat(),max='**'),
                MAILLE   = SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
                GROUP_MA = SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
                VALE     = SIMP(statut='o',typ='R',min=21,max=21),),
            b_MAK_TR_L = BLOC(condition = "((CARA=='K_TR_L')or(CARA=='A_TR_L')or(CARA=='M_TR_L'))",
                fr       = tr("SEGMENT: 78 valeurs (triangulaire supérieure par colonne)"),
                regles   = (UN_PARMI('MAILLE','GROUP_MA'),),
                MAILLE   = SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
                GROUP_MA = SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
                VALE     = SIMP(statut='o',typ='R',min=78,max=78),),
            #  Affection des caractéristiques de MASSE
            b_M_T_D_N = BLOC(condition = "(CARA=='M_T_D_N')",
                fr       = tr("NOEUD: 1 valeur de masse"),
                regles   = (UN_PARMI('MAILLE','GROUP_MA','NOEUD','GROUP_NO'),),
                NOEUD    = SIMP(statut='f',typ=no  ,validators=NoRepeat(),max='**'),
                GROUP_NO = SIMP(statut='f',typ=grno,validators=NoRepeat(),max='**'),
                MAILLE   = SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
                GROUP_MA = SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
                VALE     = SIMP(statut='o',typ='R',min=1 ,max=1 ),),
            b_M_T_D_L = BLOC(condition = "(CARA=='M_T_D_L')",
                fr       = tr("SEGMENT: 1 valeur de masse"),
                regles   = (UN_PARMI('MAILLE','GROUP_MA',),),
                MAILLE   = SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
                GROUP_MA = SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
                VALE     = SIMP(statut='o',typ='R',min=1 ,max=1 ),),
            b_M_TR_D_N = BLOC(condition = "(CARA=='M_TR_D_N')",
                fr       = tr("NOEUD: 1 valeur de masse, 6 valeurs du tenseur d'inertie, 3 composantes du vecteur d'excentrement"),
                regles   = (UN_PARMI('MAILLE','GROUP_MA','NOEUD','GROUP_NO'),),
                NOEUD    = SIMP(statut='f',typ=no  ,validators=NoRepeat(),max='**'),
                GROUP_NO = SIMP(statut='f',typ=grno,validators=NoRepeat(),max='**'),
                MAILLE   = SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
                GROUP_MA = SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
                VALE     = SIMP(statut='o',typ='R',min=10,max=10),),
            b_M_TR_D_L = BLOC(condition = "(CARA=='M_TR_D_L')",
                fr       = tr("SEGMENT: 1 valeur de masse, 3 valeurs du tenseur d'inertie"),
                regles   = (UN_PARMI('MAILLE','GROUP_MA',),),
                MAILLE   = SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
                GROUP_MA = SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
                VALE     = SIMP(statut='o',typ='R',min=4,max=4),),
        ),
        #     éléments à matrice non-symétrique
        #        b_MAK_T_N_NS       'K_T_N'     'A_T_N'    'M_T_N'
        #        b_MAK_T_L_NS       'K_T_L'     'A_T_L'    'M_T_L'
        #        b_MAK_TR_N_NS      'K_TR_N'    'A_TR_N'   'M_TR_N'
        #        b_MAK_TR_L_NS      'K_TR_L'    'A_TR_L'   'M_TR_L'
        b_SYME_NON = BLOC(condition="SYME=='NON'",
            fr   = tr("NON-SYMETRIQUE: Affectation de matrices de rigidité, de masse ou d'amortissement à des mailles ou noeuds"),
            CARA = SIMP(statut='o',typ='TXM',validators=NoRepeat(),max=1,defaut="None",
            into = ("K_T_N", "K_T_L", "K_TR_N", "K_TR_L",
                    "M_T_N", "M_T_L", "M_TR_N", "M_TR_L",
                    "A_T_N", "A_T_L", "A_TR_N", "A_TR_L",),),
            #  Affection des caractéristiques de RIGIDITE/AMORTISSEMENT/MASSE : NON-SYMETRIQUE
            b_MAK_T_N_NS = BLOC(condition = "((CARA=='K_T_N')or(CARA=='A_T_N')or(CARA=='M_T_N'))",
                fr       = tr("NOEUD: 9 valeurs (matrice pleine par colonne)"),
                regles   = (UN_PARMI('MAILLE','GROUP_MA','NOEUD','GROUP_NO'),),
                NOEUD    = SIMP(statut='f',typ=no  ,validators=NoRepeat(),max='**'),
                GROUP_NO = SIMP(statut='f',typ=grno,validators=NoRepeat(),max='**'),
                MAILLE   = SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
                GROUP_MA = SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
                VALE     = SIMP(statut='o',typ='R',min=9 ,max=9 ),),
            b_MAK_T_L_NS = BLOC(condition = "((CARA=='K_T_L')or(CARA=='A_T_L')or(CARA=='M_T_L'))",
                fr       = tr("SEGMENT: 36 valeurs (matrice pleine par colonne)"),
                regles   = (UN_PARMI('MAILLE','GROUP_MA'),),
                MAILLE   = SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
                GROUP_MA = SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
                VALE     = SIMP(statut='o',typ='R',min=36,max=36),),
            b_MAK_TR_N_NS = BLOC(condition = "((CARA=='K_TR_N')or(CARA=='A_TR_N')or(CARA=='M_TR_N'))",
                fr       =tr("NOEUD: 36 valeurs (matrice pleine par colonne)"),
                regles   = (UN_PARMI('MAILLE','GROUP_MA','NOEUD','GROUP_NO'),),
                NOEUD    = SIMP(statut='f',typ=no  ,validators=NoRepeat(),max='**'),
                GROUP_NO = SIMP(statut='f',typ=grno,validators=NoRepeat(),max='**'),
                MAILLE   = SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
                GROUP_MA = SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
                VALE     = SIMP(statut='o',typ='R',min=36,max=36),),
            b_MAK_TR_L_NS = BLOC(condition = "((CARA=='K_TR_L')or(CARA=='A_TR_L')or(CARA=='M_TR_L'))",
                fr       = tr("SEGMENT: 144 valeurs (matrice pleine par colonne)"),
                regles   = (UN_PARMI('MAILLE','GROUP_MA'),),
                MAILLE   = SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
                GROUP_MA = SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
                VALE     = SIMP(statut='o',typ='R',min=144,max=144),),
        ),
    ),
#
# ==============================================================================
    DISCRET_2D = FACT(statut='f',max='**',
        REPERE    = SIMP(statut='f',typ='TXM',into=("LOCAL","GLOBAL") ),
        AMOR_HYST = SIMP(statut='f',typ='R' ),
        SYME      = SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON"),),
        b_SYME_OUI = BLOC(condition="SYME=='OUI'",
            fr   = tr("SYMETRIQUE: Affectation de matrices de rigidité, de masse ou d'amortissement à des mailles ou noeuds"),
            CARA = SIMP(statut='o',typ='TXM',validators=NoRepeat(),max=1,defaut="None",
            into = ("K_T_D_N", "K_T_D_L", "K_TR_D_N", "K_TR_D_L", "K_T_N", "K_T_L", "K_TR_N", "K_TR_L",
                    "M_T_D_N", "M_T_D_L", "M_TR_D_N", "M_TR_D_L", "M_T_N", "M_T_L", "M_TR_N", "M_TR_L",
                    "A_T_D_N", "A_T_D_L", "A_TR_D_N", "A_TR_D_L", "A_T_N", "A_T_L", "A_TR_N", "A_TR_L",),),
            #  Affection des caractéristiques de RIGIDITE/AMORTISSEMENT/MASSE
            b_AK_T_D_N = BLOC(condition = "((CARA=='K_T_D_N')or(CARA=='A_T_D_N'))",
                fr       = tr("NOEUD: 2 valeurs (triangulaire supérieure par colonne)"),
                regles   = (UN_PARMI('MAILLE','GROUP_MA','NOEUD','GROUP_NO'),),
                NOEUD    = SIMP(statut='f',typ=no  ,validators=NoRepeat(),max='**'),
                GROUP_NO = SIMP(statut='f',typ=grno,validators=NoRepeat(),max='**'),
                MAILLE   = SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
                GROUP_MA = SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
                VALE     = SIMP(statut='o',typ='R',min=2 ,max=2 ),),
            b_AK_T_D_L = BLOC(condition = "((CARA=='K_T_D_L')or(CARA=='A_T_D_L'))",
                fr       = tr("SEGMENT: 2 valeurs (triangulaire supérieure par colonne)"),
                regles   = (UN_PARMI('MAILLE','GROUP_MA'),),
                MAILLE   = SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
                GROUP_MA = SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
                VALE     = SIMP(statut='o',typ='R',min=2 ,max=2 ),),
            b_AK_TR_D_N  = BLOC(condition = "((CARA=='K_TR_D_N')or(CARA=='A_TR_D_N'))",
                fr       = tr("NOEUD: 3 valeurs (triangulaire supérieure par colonne)"),
                regles   = (UN_PARMI('MAILLE','GROUP_MA','NOEUD','GROUP_NO'),),
                NOEUD    = SIMP(statut='f',typ=no  ,validators=NoRepeat(),max='**'),
                GROUP_NO = SIMP(statut='f',typ=grno,validators=NoRepeat(),max='**'),
                MAILLE   = SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
                GROUP_MA = SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
                VALE     = SIMP(statut='o',typ='R',min=3 ,max=3 ),),
            b_AK_TR_D_L = BLOC(condition = "((CARA=='K_TR_D_L')or(CARA=='A_TR_D_L'))",
                fr       = tr("SEGMENT: 3 valeurs (triangulaire supérieure par colonne)"),
                regles   = (UN_PARMI('MAILLE','GROUP_MA'),),
                MAILLE   = SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
                GROUP_MA = SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
                VALE     = SIMP(statut='o',typ='R',min=3 ,max=3 ),),
            b_MAK_T_N = BLOC(condition = "((CARA=='K_T_N')or(CARA=='A_T_N')or(CARA=='M_T_N'))",
                fr       = tr("NOEUD: 3 valeurs (triangulaire supérieure par colonne)"),
                regles   = (UN_PARMI('MAILLE','GROUP_MA','NOEUD','GROUP_NO'),),
                NOEUD    = SIMP(statut='f',typ=no  ,validators=NoRepeat(),max='**'),
                GROUP_NO = SIMP(statut='f',typ=grno,validators=NoRepeat(),max='**'),
                MAILLE   = SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
                GROUP_MA = SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
                VALE     = SIMP(statut='o',typ='R',min=3 ,max=3 ),),
            b_MAK_T_L = BLOC(condition = "((CARA=='K_T_L')or(CARA=='A_T_L')or(CARA=='M_T_L'))",
                fr       = tr("SEGMENT: 10 valeurs (triangulaire supérieure par colonne)"),
                regles   = (UN_PARMI('MAILLE','GROUP_MA'),),
                MAILLE   = SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
                GROUP_MA = SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
                VALE     = SIMP(statut='o',typ='R',min=10,max=10),),
            b_MAK_TR_N = BLOC(condition = "((CARA=='K_TR_N')or(CARA=='A_TR_N')or(CARA=='M_TR_N'))",
                fr       = tr("NOEUD: 6 valeurs (triangulaire supérieure par colonne)"),
                regles   = (UN_PARMI('MAILLE','GROUP_MA','NOEUD','GROUP_NO'),),
                NOEUD    = SIMP(statut='f',typ=no  ,validators=NoRepeat(),max='**'),
                GROUP_NO = SIMP(statut='f',typ=grno,validators=NoRepeat(),max='**'),
                MAILLE   = SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
                GROUP_MA = SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
                VALE     = SIMP(statut='o',typ='R',min=6 ,max=6),),
            b_MAK_TR_L = BLOC(condition = "((CARA=='K_TR_L')or(CARA=='A_TR_L')or(CARA=='M_TR_L'))",
                fr       = tr("SEGMENT: 21 valeurs (triangulaire supérieure par colonne)"),
                regles   = (UN_PARMI('MAILLE','GROUP_MA'),),
                MAILLE   = SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
                GROUP_MA = SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
                VALE     = SIMP(statut='o',typ='R',min=21,max=21),),
            #  Affection des caractéristiques de MASSE
            b_M_T_D_N = BLOC(condition = "(CARA=='M_T_D_N')",
                fr       = tr("NOEUD: 1 valeur de masse"),
                regles   = (UN_PARMI('MAILLE','GROUP_MA','NOEUD','GROUP_NO'),),
                NOEUD    = SIMP(statut='f',typ=no  ,validators=NoRepeat(),max='**'),
                GROUP_NO = SIMP(statut='f',typ=grno,validators=NoRepeat(),max='**'),
                MAILLE   = SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
                GROUP_MA = SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
                VALE     = SIMP(statut='o',typ='R',min=1 ,max=1 ),),
            b_M_T_D_L = BLOC(condition = "(CARA=='M_T_D_L')",
                fr       = tr("SEGMENT: 1 valeur de masse"),
                regles   = (UN_PARMI('MAILLE','GROUP_MA',),),
                MAILLE   = SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
                GROUP_MA = SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
                VALE     = SIMP(statut='o',typ='R',min=1 ,max=1 ),),
            b_M_TR_D_N = BLOC(condition = "(CARA=='M_TR_D_N')",
                fr       = tr("NOEUD: 1 valeur de masse, 1 valeur d'inertie, 2 composantes du vecteur d'excentrement"),
                regles   = (UN_PARMI('MAILLE','GROUP_MA','NOEUD','GROUP_NO'),),
                NOEUD    = SIMP(statut='f',typ=no  ,validators=NoRepeat(),max='**'),
                GROUP_NO = SIMP(statut='f',typ=grno,validators=NoRepeat(),max='**'),
                MAILLE   = SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
                GROUP_MA = SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
                VALE     = SIMP(statut='o',typ='R',min=4 ,max=4 ),),
            b_M_TR_D_L = BLOC(condition = "(CARA=='M_TR_D_L')",
                fr       = tr("SEGMENT: 1 valeur de masse, 1 valeur d'inertie"),
                regles   = (UN_PARMI('MAILLE','GROUP_MA',),),
                MAILLE   = SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
                GROUP_MA = SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
                VALE     = SIMP(statut='o',typ='R',min=2 ,max=2 ),),
        ),
        #     éléments à matrice non-symétrique
        #        b_MAK_T_N_NS       'K_T_N'     'A_T_N'    'M_T_N'
        #        b_MAK_T_L_NS       'K_T_L'     'A_T_L'    'M_T_L'
        #        b_MAK_TR_N_NS      'K_TR_N'    'A_TR_N'   'M_TR_N'
        #        b_MAK_TR_L_NS      'K_TR_L'    'A_TR_L'   'M_TR_L'
        b_SYME_NON = BLOC(condition="SYME=='NON'",
            fr   = tr("NON-SYMETRIQUE: Affectation de matrices de rigidité, de masse ou d'amortissement à des mailles ou noeuds"),
            CARA = SIMP(statut='o',typ='TXM',validators=NoRepeat(),max=1,defaut="None",
            into = ("K_T_N", "K_T_L", "K_TR_N", "K_TR_L",
                    "M_T_N", "M_T_L", "M_TR_N", "M_TR_L",
                    "A_T_N", "A_T_L", "A_TR_N", "A_TR_L",),),
            #  Affection des caractéristiques de RIGIDITE/AMORTISSEMENT/MASSE : NON-SYMETRIQUE
            b_MAK_T_N_NS = BLOC(condition = "((CARA=='K_T_N')or(CARA=='A_T_N')or(CARA=='M_T_N'))",
                fr       = tr("NOEUD: 4 valeurs (matrice pleine par colonne)"),
                regles   = (UN_PARMI('MAILLE','GROUP_MA','NOEUD','GROUP_NO'),),
                NOEUD    = SIMP(statut='f',typ=no  ,validators=NoRepeat(),max='**'),
                GROUP_NO = SIMP(statut='f',typ=grno,validators=NoRepeat(),max='**'),
                MAILLE   = SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
                GROUP_MA = SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
                VALE     = SIMP(statut='o',typ='R',min=4 ,max=4 ),),
            b_MAK_T_L_NS = BLOC(condition = "((CARA=='K_T_L')or(CARA=='A_T_L')or(CARA=='M_T_L'))",
                fr       = tr("SEGMENT: 16 valeurs (matrice pleine par colonne)"),
                regles   = (UN_PARMI('MAILLE','GROUP_MA'),),
                MAILLE   = SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
                GROUP_MA = SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
                VALE     = SIMP(statut='o',typ='R',min=16,max=16),),
            b_MAK_TR_N_NS = BLOC(condition = "((CARA=='K_TR_N')or(CARA=='A_TR_N')or(CARA=='M_TR_N'))",
                fr       = tr("NOEUD: 9 valeurs (matrice pleine par colonne)"),
                regles   = (UN_PARMI('MAILLE','GROUP_MA','NOEUD','GROUP_NO'),),
                NOEUD    = SIMP(statut='f',typ=no  ,validators=NoRepeat(),max='**'),
                GROUP_NO = SIMP(statut='f',typ=grno,validators=NoRepeat(),max='**'),
                MAILLE   = SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
                GROUP_MA = SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
                VALE     = SIMP(statut='o',typ='R',min=9 ,max=9),),
            b_MAK_TR_L_NS = BLOC(condition = "((CARA=='K_TR_L')or(CARA=='A_TR_L')or(CARA=='M_TR_L'))",
                fr       = tr("SEGMENT: 36 valeurs (matrice pleine par colonne)"),
                regles   = (UN_PARMI('MAILLE','GROUP_MA'),),
                MAILLE   = SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
                GROUP_MA = SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
                VALE     = SIMP(statut='o',typ='R',min=36,max=36),),
        ),
    ),
#
# ==============================================================================
    ORIENTATION = FACT(statut='f',max='**',
        regles = (UN_PARMI('MAILLE','GROUP_MA','NOEUD','GROUP_NO' ),),
        NOEUD    = SIMP(statut='f',typ=no  ,validators=NoRepeat(),max='**'),
        GROUP_NO = SIMP(statut='f',typ=grno,validators=NoRepeat(),max='**'),
        MAILLE   = SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
        GROUP_MA = SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
        CARA     = SIMP(statut='o',typ='TXM', into=("VECT_Y","ANGL_VRIL","VECT_X_Y","ANGL_NAUT","GENE_TUYAU"),),
        b_cara_vect_y = BLOC(condition = "(CARA=='VECT_Y')", fr=tr("Maille de longueur non nulle."),
            VALE      = SIMP(statut='o',typ='R',max=3,min=3, fr=tr("Vecteur dont la projection sur le plan normal à l'axe X local donne Y local."),),
            PRECISION = SIMP(statut='f',typ='R', fr=tr("valeur en-dessous de laquelle la maille est considérée comme de longueur nulle"),),
        ),
        b_cara_angl_vril = BLOC(condition = "(CARA=='ANGL_VRIL')", fr=tr("Maille de longueur non nulle."),
            VALE      = SIMP(statut='o',typ='R', fr=tr("Angle de rotation du repère autour de l'axe X local."),),
            PRECISION = SIMP(statut='f',typ='R', fr=tr("valeur en-dessous de laquelle la maille est considérée comme de longueur nulle")),
        ),
        b_cara_vect_x_y = BLOC(condition = "(CARA=='VECT_X_Y')", fr=tr("Noeud ou Maille de longueur nulle."),
            VALE      = SIMP(statut='o',typ='R',max=6,min=6, fr=tr("Les 2 vecteurs formant les axes X et Y locaux."),),
            PRECISION = SIMP(statut='f',typ='R', fr=tr("valeur en-dessous de laquelle la maille est considérée comme de longueur nulle")),
        ),
        b_cara_angl_naut = BLOC(condition = "(CARA=='ANGL_NAUT')", fr=tr("Noeud ou Maille de longueur nulle."),
            VALE      = SIMP(statut='o',typ='R',max=3,min=3, fr=tr("Les 3 angles nautiques alpha, beta, gamma.")),
            PRECISION = SIMP(statut='f',typ='R', fr=tr("valeur en-dessous de laquelle la maille est considérée comme de longueur nulle")),
        ),
        b_cara_gene_tuyau = BLOC(condition = "(CARA=='GENE_TUYAU')", fr=tr("Tuyau."),
            VALE      = SIMP(statut='o',typ='R', max=3,min=3, fr=tr("Vecteur donnant la position de la génératrice.")),
            PRECISION = SIMP(statut='f',typ='R', defaut= 1.0E-4 ),
            CRITERE   = SIMP(statut='f',typ='TXM',defaut="RELATIF",into=("RELATIF","ABSOLU") ),
        ),
    ),
#
# ==============================================================================
    DEFI_ARC = FACT(statut='f',max='**',
        regles = (UN_PARMI('MAILLE','GROUP_MA'),
                  UN_PARMI('ORIE_ARC','CENTRE','NOEUD_CENTRE','GROUP_NO_CENTRE', 'POIN_TANG','NOEUD_POIN_TANG','GROUP_NO_POIN_TG'),
                  PRESENT_PRESENT('ORIE_ARC','RAYON'),
                  EXCLUS('COEF_FLEX','COEF_FLEX_XY'),
                  EXCLUS('COEF_FLEX','COEF_FLEX_XZ'),
                  EXCLUS('INDI_SIGM','INDI_SIGM_XY'),
                  EXCLUS('INDI_SIGM','INDI_SIGM_XZ'),
                  PRESENT_PRESENT('COEF_FLEX_XY','COEF_FLEX_XZ'),
                  PRESENT_PRESENT('INDI_SIGM_XY','INDI_SIGM_XZ'),),
        MAILLE           = SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
        GROUP_MA         = SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
        ORIE_ARC         = SIMP(statut='f',typ='R'),
        CENTRE           = SIMP(statut='f',typ='R',max='**'),
        NOEUD_CENTRE     = SIMP(statut='f',typ=no),
        GROUP_NO_CENTRE  = SIMP(statut='f',typ=grno),
        POIN_TANG        = SIMP(statut='f',typ='R',max='**'),
        NOEUD_POIN_TANG  = SIMP(statut='f',typ=no),
        GROUP_NO_POIN_TG = SIMP(statut='f',typ=grno),
        RAYON            = SIMP(statut='f',typ='R'),
        COEF_FLEX        = SIMP(statut='f',typ='R'),
        INDI_SIGM        = SIMP(statut='f',typ='R'),
        COEF_FLEX_XY     = SIMP(statut='f',typ='R'),
        INDI_SIGM_XY     = SIMP(statut='f',typ='R'),
        COEF_FLEX_XZ     = SIMP(statut='f',typ='R'),
        INDI_SIGM_XZ     = SIMP(statut='f',typ='R'),
        PRECISION        = SIMP(statut='f',typ='R',defaut= 1.0E-3),
        CRITERE          = SIMP(statut='f',typ='TXM',defaut="RELATIF",into=("RELATIF","ABSOLU") ),
    ),
#
# ==============================================================================
    MASSIF = FACT(statut='f',max='**',
        regles = (UN_PARMI('MAILLE','GROUP_MA'),
                  UN_PARMI('ANGL_REP','ANGL_AXE','ANGL_EULER'),
                  EXCLUS('ANGL_REP','ANGL_EULER'),
                  EXCLUS('ANGL_REP','ANGL_AXE'),
                  EXCLUS('ANGL_REP','ORIG_AXE'),
                  PRESENT_PRESENT('ANGL_AXE','ORIG_AXE'), ),
        MAILLE     = SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
        GROUP_MA   = SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
        ANGL_REP   = SIMP(statut='f',typ='R',max=3),
        ANGL_EULER = SIMP(statut='f',typ='R',min=3,max=3),
        ANGL_AXE   = SIMP(statut='f',typ='R',max=2),
        ORIG_AXE   = SIMP(statut='f',typ='R',max=3),
    ),
#
# ==============================================================================
    POUTRE_FLUI = FACT(statut='f',max='**',
        regles   = (UN_PARMI('MAILLE','GROUP_MA'),),
        MAILLE       = SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
        GROUP_MA     = SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
        B_T          = SIMP(statut='o',typ='R'),
        B_N          = SIMP(statut='o',typ='R'),
        B_TN         = SIMP(statut='o',typ='R',defaut= 0.E+0 ),
        A_FLUI       = SIMP(statut='o',typ='R'),
        A_CELL       = SIMP(statut='o',typ='R'),
        COEF_ECHELLE = SIMP(statut='o',typ='R'),
    ),
#
# ==============================================================================
    GRILLE = FACT(statut='f',max='**',
        regles        = (UN_PARMI('MAILLE','GROUP_MA'),
                         EXCLUS('ANGL_REP','AXE'),
                         UN_PARMI('SECTION','SECTION_FO' ),
                         EXCLUS('EXCENTREMENT','EXCENTREMENT_FO'), ),
        MAILLE          = SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
        GROUP_MA        = SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
        SECTION         = SIMP(statut='f',typ='R'),
        SECTION_FO      = SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule) ),
        ANGL_REP        = SIMP(statut='f',typ='R',max=2),
        EXCENTREMENT    = SIMP(statut='f',typ='R'),
        EXCENTREMENT_FO = SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule) ),
        AXE             = SIMP(statut='f',typ='R',max='**'),
        COEF_RIGI_DRZ   = SIMP(statut='f',typ='R',defaut= 1.0E-10 ),
    ),
#
# ==============================================================================
   MEMBRANE = FACT(statut='f',max='**',
      regles  = (UN_PARMI('MAILLE','GROUP_MA'),
                 EXCLUS('ANGL_REP','AXE'), ),
      MAILLE   = SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
      GROUP_MA = SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
      ANGL_REP = SIMP(statut='f',typ='R',max=2),
      AXE      = SIMP(statut='f',typ='R',max='**'),
   ),
#
# ==============================================================================
    RIGI_PARASOL = FACT(statut='f',max='**',
        regles  = (UN_PARMI('COEF_GROUP','FONC_GROUP'),
                   UN_PARMI('COOR_CENTRE','NOEUD_CENTRE','GROUP_NO_CENTRE'),
                   EXCLUS('GROUP_MA_POI1','GROUP_MA_SEG2'),),
        GROUP_MA      = SIMP(statut='o',typ=grma,validators=NoRepeat(),max='**',
                             fr=tr("Surface servant à répartir les caractéristiques des discrets")),
        GROUP_MA_POI1 = SIMP(statut='f',typ=grma,validators=NoRepeat(),max=1,
                             fr=tr("Mailles de type point correspondant aux discrets")),
        GROUP_MA_SEG2 = SIMP(statut='f',typ=grma,validators=NoRepeat(),max=1,
                             fr=tr("Mailles de type seg2 correspondant aux discrets")),
        FONC_GROUP    = SIMP(statut='f',typ=(fonction_sdaster,nappe_sdaster,formule) ),
        COEF_GROUP    = SIMP(statut='f',typ='R',max='**'),
        REPERE        = SIMP(statut='f',typ='TXM',into=("LOCAL","GLOBAL") ),
        CARA          = SIMP(statut='o',typ='TXM',validators=NoRepeat(),max=2,
            into = ("K_TR_D_N","K_T_D_N","K_TR_D_L","K_T_D_L",
                    "A_TR_D_N","A_T_D_N","A_TR_D_L","A_T_D_L"),
            fr = tr("Choix des types de discrets du tapis de ressorts.") ),
        b_cara = BLOC(condition ="""CARA and (au_moins_un(CARA, ["K_TR_D_N","K_T_D_N","K_TR_D_L","K_T_D_L",
                                   "A_TR_D_N","A_T_D_N","A_TR_D_L","A_T_D_L"]) or \
                                    len(CARA) == 2 and CARA[0][2:] == CARA[1][2:])""",
            fr   = tr("Valeurs pour les discrets du tapis de ressorts."),
            VALE = SIMP(statut='o',typ='R',max='**', fr=tr("Valeurs pour les discrets du tapis de ressorts."),),
        ),
        GROUP_NO_CENTRE = SIMP(statut='f',typ=grno),
        NOEUD_CENTRE    = SIMP(statut='f',typ=no),
        COOR_CENTRE     = SIMP(statut='f',typ='R',min=2,max=3),
        EUROPLEXUS      = SIMP(statut='f',typ='TXM',into=("OUI","NON"),defaut="NON"),
        UNITE           = SIMP(statut='f',typ='I',val_min=1),
    ),
#
# ==============================================================================
    RIGI_MISS_3D = FACT(statut='f',max='**',
        GROUP_MA_POI1   = SIMP(statut='o',typ=grma,max=1),
        GROUP_MA_SEG2   = SIMP(statut='f',typ=grma,max=1),
        FREQ_EXTR       = SIMP(statut='o',typ='R',max=1),
        UNITE_RESU_IMPE = SIMP(statut='f',typ='I',defaut=30),
    ),
#
# ==============================================================================
    MASS_AJOU = FACT(statut='f',max='**',
        GROUP_MA      = SIMP(statut='o',typ=grma,validators=NoRepeat(),max='**',
                             fr = tr("Surface servant à répartir les caractéristiques des discrets")),
        GROUP_MA_POI1 = SIMP(statut='o',typ=grma,validators=NoRepeat(),max=1,
                             fr = tr("Mailles de type point correspondant aux discrets")),
        FONC_GROUP    = SIMP(statut='o',typ=(fonction_sdaster,nappe_sdaster,formule) ),
    ),
#
# ==============================================================================
    GEOM_FIBRE = SIMP(statut='f',max=1,typ=gfibre_sdaster,
        fr = tr("Donner le nom de la SD regroupant tous les groupes de fibres (issue de DEFI_GEOM_FIBRE)")),
#
# ==============================================================================
    MULTIFIBRE = FACT(statut='f',max='**',
        regles       = (AU_MOINS_UN('GROUP_MA','MAILLE'),),
        GROUP_MA     = SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
        MAILLE       = SIMP(statut='f',typ=ma  ,validators=NoRepeat(),max='**'),
        GROUP_FIBRE  = SIMP(statut='o',typ='TXM',max='**'),
        PREC_AIRE    = SIMP(statut='f',typ= 'R',defaut= 0.01),
        PREC_INERTIE = SIMP(statut='f',typ= 'R',defaut= 0.1),
    ),
)
