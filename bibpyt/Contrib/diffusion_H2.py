# coding=utf-8
# --------------------------------------------------------------------
# Copyright (C) 1991 - 2019 - EDF R&D - www.code-aster.org
# This file is part of code_aster.
#
# code_aster is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# code_aster is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with code_aster.  If not, see <http://www.gnu.org/licenses/>.
# --------------------------------------------------------------------

import numpy as NP

from math import log
from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Commands import (AFFE_CHAR_THER, AFFE_MATERIAU, CALC_CHAMP, CALC_CHAM_ELEM, CREA_CHAMP, DEFI_MATERIAU, PROJ_CHAMP)
from code_aster.Commands.ExecuteCommand import UserMacro


def NT(epsp, Nl, Kt, a1, a2, a3):
    lnt = a1 + a2 * NP.exp(a3 * epsp)
    Nt = NP.exp(lnt * log(10.0))
    return Nt


def dNTdp(epsp, Nl, Kt, a1, a2, a3):
    Nt = NT(epsp, Nl, Kt, a1, a2, a3)
    dNtdp = Nt * a2 * a3 * NP.log(10.0) * NP.exp(a3 * epsp)
    return dNtdp


def THETA(Cl, epsp, Nl, Kt, a1, a2, a3):
    # Cl concentration totale ( dimensionnee)
    Nt = NT(epsp, Nl, Kt, a1, a2, a3)
    Ct = (Cl * Kt * Nt) / (Nl + Kt * Cl)
    theta = Ct / Nt
    return Ct, Nt, theta


def SOURCE(cl, epsp, depspdt, Ctot0, Nl, Kt, a1, a2, a3):
    #  expression directe
    Cl = cl * Ctot0
    Ct, Nt, theta = THETA(Cl, epsp, Nl, Kt, a1, a2, a3)
    dNtdp = dNTdp(epsp, Nl, Kt, a1, a2, a3)
    Source = -theta * dNtdp * depspdt
    Source = Source / Ctot0
    return Source


def DETOILE(cl, epsp, Ctot0, Nl, Kt, a1, a2, a3):
    cl = cl * Ctot0
    Ct, Nt, theta = THETA(cl, epsp, Nl, Kt, a1, a2, a3)
    return (cl + Ct * (1. - theta)) / cl


def FLUX(cl, GRSHx, GRSHy, DIME, GRSHz, Vh, R, T):
    Coef = Vh / R / T * cl
    Flux = GRSHx * Coef
    Fluy = GRSHy * Coef
    if DIME == 3:
        Fluz = GRSHz * Coef
        return Flux, Fluy, Fluz
    else:
        return Flux, Fluy


# "
# macro calculant a chaque pas de temps la concentration d'H2
# "

def char_grad_impo_ops(self, RESU_H2, TINIT, TFIN, RESUMECA, GRMAVOL, DIME, Ctot0, CHARGRD0, Vh, R, T, **args):
# macro pour calculer le chargement thermique specfique a la diffusion H2

    import numpy as NP
    import aster
    from code_aster.Cata.Syntax import _F
    INFO = args.get('INFO')

    # On importe les definitions des commandes a utiliser dans la macro
    CREA_CHAMP = self.get_cmd('CREA_CHAMP')
    AFFE_CHAR_THER = self.get_cmd('AFFE_CHAR_THER')
    CALC_CHAMP = self.get_cmd('CALC_CHAMP')
    CALC_CHAM_ELEM = self.get_cmd('CALC_CHAM_ELEM')

    dt = TFIN - TINIT

    # Recuperation du modele a partir du resultat
    moth = RESU_H2.getModel()

    # Recuperation du maillage a partir du resultat
    mesh = moth.getSupportMesh()

    # Recuperation du modele mecanique a partir du resultat
    mome = RESUMECA.getModel()

    # extraction du champ de cl instant -
    __C20 = CREA_CHAMP(OPERATION='EXTR', TYPE_CHAM='NOEU_TEMP_R',
                       RESULTAT=RESU_H2, NOM_CHAM='TEMP', INST=TINIT, INFO=INFO)

    # on suppose que les noeuds du maillage thermique et mecaniqeu sont les
    # memes (pour eviter un PROJ_CHAMP)
    lc_t0 = __C20.EXTR_COMP('TEMP', [], 1)
    c_t0 = lc_t0.valeurs
    node_th = lc_t0.noeud
    nbnode = len(node_th)

    # contruction du terme Grad SigmaH
    # trace de sigma aux noeuds
    __SIEQN2 = CALC_CHAMP(
        INST=TFIN, RESULTAT=RESUMECA, CRITERES='SIEQ_NOEU', INFO=INFO)
    __SIEQN = PROJ_CHAMP(
        METHODE='COLLOCATION',
                RESULTAT=__SIEQN2,
                MODELE_1=mome,
                MODELE_2=moth,
                NOM_CHAM='SIEQ_NOEU',
                TOUT_ORDRE='OUI')
    __SIEQ = CREA_CHAMP(OPERATION='EXTR', TYPE_CHAM='NOEU_SIEF_R',
                        RESULTAT=__SIEQN, NOM_CHAM='SIEQ_NOEU', INST=TFIN, INFO=INFO)

    # on renome la CMP pour pouvoir calculer le flux "thermique"
    __TRSIG = CREA_CHAMP(
        OPERATION='ASSE', TYPE_CHAM='NOEU_TEMP_R', MODELE=moth,
        ASSE=(_F(CHAM_GD=__SIEQ, GROUP_MA=GRMAVOL, NOM_CMP='TRSIG', NOM_CMP_RESU='TEMP', COEF_R=1. / 3.),), INFO=INFO)
    # calcul du gradient de Trace(Sigma)
    __MAT1 = DEFI_MATERIAU(THER=_F(LAMBDA=-1., RHO_CP=0.))
    __CMT1 = AFFE_MATERIAU(
        MAILLAGE=mesh, AFFE=_F(TOUT='OUI', MATER=__MAT1,),)
    __GRSH = CALC_CHAM_ELEM(
        MODELE=moth, CHAM_MATER=__CMT1, GROUP_MA=GRMAVOL, OPTION='FLUX_ELGA', TEMP=__TRSIG)

    gradsighe = __GRSH.EXTR_COMP('FLUX', [], 1)
    gradsighx = gradsighe.valeurs
    gradsighy = __GRSH.EXTR_COMP('FLUY', [], 0).valeurs
    if (DIME == 3):
        gradsighz = __GRSH.EXTR_COMP('FLUZ', [], 0).valeurs

    fx = NP.zeros(nbnode)
    fy = NP.zeros(nbnode)
    if (DIME == 3):
        fz = NP.zeros(nbnode)
    for ino, node in enumerate(node_th):
        cl = c_t0[ino]
        grsigx = gradsighx[ino]
        grsigy = gradsighy[ino]
        if (DIME == 3):
            grsigz = gradsighz[ino]
            fx[ino], fx[ino], fz[ino] = FLUX(
                cl, grsigx, grsigy, DIME, grsigz, Vh, R, T)
        else:
            grsigz = 0.
            fx[ino], fx[ino] = FLUX(cl, grsigx, grsigy, DIME, grsigz, Vh, R, T)

    # pour gagner du temps on evite la construction du mot-cle PRE_GRAD_TEMP
    nomvale = CHARGRD0.nom.ljust(8) + '.CHTH.GRAIN.VALE'
    nomlima = CHARGRD0.nom.ljust(8) + '.CHTH.GRAIN.LIMA'
    nomdesc = CHARGRD0.nom.ljust(8) + '.CHTH.GRAIN.DESC'
    tabvale = aster.getvectjev(nomvale)
    tabdesc = aster.getvectjev(nomdesc)
    dicolima = aster.getcolljev(nomlima)

    nbrvale = len(tabvale)
    champ = NP.zeros(nbrvale)
    bidon = NP.zeros(nbrvale)

    nommai = mesh.sdj.NOMMAI.get()
    connex = mesh.sdj.CONNEX.get()
    groupma = mesh.sdj.GROUPEMA.get()[GRMAVOL.ljust(24)]
    nbzone = tabdesc[1]
#   print "tabdesc",tabdesc
#   print "tablima",dicolima

    for izone in list(dicolima.keys()):

        # chaque maille du groupe est affectee
        for index, ima in enumerate(dicolima[izone]):
            if ima == 0:
                break
            if ima in groupma:
                # ATTENTION : dans Python, les tableaux commencent a 0
                # mais dans la connectivite, les noeuds commencent a 1!
                lnoeu = NP.array(connex[ima]) - 1
                nbno = len(lnoeu)

                # calcul de la moyenne par maille de fx
                lflux = fx[lnoeu]
                flux = NP.add.reduce(lflux)
                flux = flux / nbno

                lfluy = fy[lnoeu]
                fluy = NP.add.reduce(lfluy)
                fluy = fluy / nbno
                numa = index
#              print 'essai, numa, ima',numa, ima, groupma, lnoeu, nbno
                champ[9 * (numa - 1) + 1] = -flux
                champ[9 * (numa - 1) + 2] = -fluy

    aster.putvectjev(nomvale, nbrvale, tuple(
        range(1, nbrvale + 1)), tuple(champ), tuple(bidon), 1)


CHAR_GRAD_IMPO_cata = MACRO(
    nom="CHAR_GRAD_IMPO",
    op=char_grad_impo_ops,
    # sd_prod   = char_ther,
    docu="",
    reentrant='n',
    fr="calcul du chargement de gradient(trace(sigma)) pour la diffusion d'h2",

    RESU_H2=SIMP(statut='o', typ=evol_ther),
    TINIT=SIMP(statut='o', typ='R'),
    TFIN=SIMP(statut='o', typ='R'),
    Ctot0=SIMP(statut='o', typ='R'),
    DIME=SIMP(statut='o', typ='I'),
    RESUMECA=SIMP(
    statut='o', typ=resultat_sdaster, fr="Resultat de STAT_NON_LINE"),
    GRMAVOL=SIMP(
    statut='o', typ=grma, validators=NoRepeat(), max=1),
    INFO=SIMP(statut='f', typ='I', into=(1, 2)),
    CHARGRD0 =SIMP(statut='o', typ=char_ther),
    Vh =SIMP(statut='f', typ='R', defaut=2.e-6),
    R =SIMP(statut='f', typ='R', defaut=8.3144),
    T =SIMP(statut='f', typ='R', defaut=293.),
    )

CHAR_GRAD_IMPO = UserMacro("CHAR_GRAD_IMPO", CHAR_GRAD_IMPO_cata, char_grad_impo_ops)

#
# macro pour initialiser le chargement thermique de gradient specifique a la diffusion H2
#

def char_grad_ini_ops(self, RESU_H2, GRMAVOL, DIME, **args):

    import aster
    from code_aster.Cata.Syntax import _F

    grad = []
    # On boucle sur les mailles du groupe de mailles GRMAVOL

    # Recuperation du modele a partir du resultat
    moth = RESU_H2.getModel()

    # Recuperation du maillage a partir du resultat
    mesh = moth.getSupportMesh()

    nommai = mesh.sdj.NOMMAI.get()
    connex = mesh.sdj.CONNEX.get()
    groupma = mesh.sdj.GROUPEMA.get()[GRMAVOL.ljust(24)]

    for ima in groupma:
        # ATTENTION : dans Python, les tableaux commencent a 0
        # mais dans la connectivite, les noeuds commencent a 1!
        lnoeu = NP.array(connex[ima]) - 1
        nbno = len(lnoeu)
        # ajout dans le mot-cle facteur PRE_GRAD_TEMP
        nom_maille = nommai[ima - 1]
        mon_dico = {}
        mon_dico["MAILLE"] = nom_maille
        mon_dico["FLUX_X"] = 0.
        mon_dico["FLUX_Y"] = 0.
        if DIME == 3:
            mon_dico["FLUX_Z"] = 0.
        grad.append(mon_dico)

    chth = AFFE_CHAR_THER(MODELE=moth, INFO=args.get('INFO'),
                          PRE_GRAD_TEMP=grad,
                          )
    return chth


CHAR_GRAD_INI_cata = MACRO(
    nom="CHAR_GRAD_INI",
    op=char_grad_ini_ops,
    sd_prod=char_ther,
    docu="",
    reentrant='n',
    fr="calcul du chargement de gradient(trace(sigma)) initial pour la diffusion d'h2",

    RESU_H2=SIMP(statut='o', typ=evol_ther),
    DIME=SIMP(statut='o', typ='I'),
    GRMAVOL=SIMP(
    statut='o', typ=grma, validators=NoRepeat(), max=1),
    INFO=SIMP(statut='f', typ='I', into=(1, 2)),
    )

CHAR_GRAD_INI = UserMacro("CHAR_GRAD_INI", CHAR_GRAD_INI_cata, char_grad_ini_ops)

# "
# macro calculant a chaque pas de temps la source volumique
# "

def char_source_ops(self, RESU_H2, TINIT, TFIN, RESUMECA, GRMAVOL, DIME, Ctot0, Nl, Kt, a1, a2, a3, **args):
# macro pour calculer le chargement thermique specfique a la diffusion H2

    import numpy as NP
    import aster
    from code_aster.Cata.Syntax import _F
    INFO = args.get('INFO')

   # On importe les definitions des commandes a utiliser dans la macro
    DETRUIRE = self.get_cmd('DETRUIRE')
    CREA_CHAMP = self.get_cmd('CREA_CHAMP')
    AFFE_CHAR_THER = self.get_cmd('AFFE_CHAR_THER')
    AFFE_CHAR_CINE = self.get_cmd('AFFE_CHAR_CINE')
    CALC_CHAMP = self.get_cmd('CALC_CHAMP')

    dt = TFIN - TINIT

    # Recuperation du modele thermique a partir du resultat
    moth = RESU_H2.getModel()

    # Recuperation du maillage a partir du resultat
    mesh = moth.getSupportMesh()

    # Recuperation du modele mecanique a partir du resultat
    mome = RESUMECA.getModel()

    # extraction du champ de Cl instant -
    __C20 = CREA_CHAMP(OPERATION='EXTR', TYPE_CHAM='NOEU_TEMP_R',
                       RESULTAT=RESU_H2, NOM_CHAM='TEMP', INST=TINIT, INFO=INFO)
    __EPEQN2 = CALC_CHAMP(
        INST=(TINIT, TFIN), RESULTAT=RESUMECA, VARI_INTERNE='VARI_NOEU', INFO=INFO)
    __EPEQN = PROJ_CHAMP(
        METHODE='COLLOCATION',
                RESULTAT=__EPEQN2,
                MODELE_1=mome,
                MODELE_2=moth,
                NOM_CHAM='VARI_NOEU',
                TOUT_ORDRE='OUI')
    __VINT0 = CREA_CHAMP(OPERATION='EXTR', TYPE_CHAM='NOEU_VAR2_R',
                         RESULTAT=__EPEQN, NOM_CHAM='VARI_NOEU', INST=TINIT, INFO=INFO)
    __VINT1 = CREA_CHAMP(OPERATION='EXTR', TYPE_CHAM='NOEU_VAR2_R',
                         RESULTAT=__EPEQN, NOM_CHAM='VARI_NOEU', INST=TFIN, INFO=INFO)

    # recopie du champ C20 pour initialiser le futur champ source
    __chtmp = CREA_CHAMP(
        OPERATION='AFFE', TYPE_CHAM='NOEU_NEUT_R', MAILLAGE=mesh,
        AFFE=(_F(VALE=0., GROUP_MA=GRMAVOL, NOM_CMP='X1',),))
    nomcham = __chtmp.sdj.nomj()

    # on suppose que les noeuds du maillage thermique et mecaniqeu sont les
    # memes (pour eviter un PROJ_CHAMP)
    lc_t0 = __C20.EXTR_COMP('TEMP', [], 1)
    c_t0 = lc_t0.valeurs
    node_th = lc_t0.noeud
    # print 'node_th=',node_th
    lp_t0 = __VINT0.EXTR_COMP('V1', [], 1)
    p_t0 = lp_t0.valeurs
    node_me = lp_t0.noeud
    p_t1 = __VINT1.EXTR_COMP('V1', [], 0).valeurs
    nbnode = len(node_th)
    assert(nbnode == len(node_me))
    source = NP.zeros(nbnode)
    bidon = NP.zeros(nbnode)
    for ino, node in enumerate(node_th):
        Cl = c_t0[ino]
        p0 = p_t0[ino]
        p1 = p_t1[ino]
        dpdt = (p1 - p0) / dt
        # avec INCLUDE   : ne trouve pas SOURCE, mais en important la macro,
        # cela marche
        source[ino] = SOURCE(Cl, p1, dpdt, Ctot0, Nl, Kt, a1, a2, a3)

    nomvect = '%-19s.VALE' % __chtmp.nom
    aster.putvectjev(nomvect, nbnode, tuple(
        range(1, nbnode + 1)), tuple(source), tuple(bidon), 1)
    __NEUTG = CREA_CHAMP(OPERATION='DISC', TYPE_CHAM='ELGA_NEUT_R',
                         MODELE=moth, PROL_ZERO='OUI', CHAM_GD=__chtmp, INFO=INFO)
    __CHSOUR = CREA_CHAMP(
        OPERATION='ASSE', TYPE_CHAM='ELGA_SOUR_R', MODELE=moth, INFO=INFO, PROL_ZERO='OUI',
        ASSE=(_F(CHAM_GD=__NEUTG, GROUP_MA=GRMAVOL, NOM_CMP='X1', NOM_CMP_RESU='SOUR',),))

    chth = AFFE_CHAR_THER(MODELE=moth, INFO=INFO,
                          SOURCE=_F(SOUR_CALCULEE=__CHSOUR,),
                          )
    return chth


CHAR_SOURCE_cata = MACRO(
    nom="CHAR_SOURCE",
    op=char_source_ops,
    sd_prod=char_ther,
    docu="",
    reentrant='n',
    fr="calcul du chargement pour la diffusion d'h2",

    RESU_H2=SIMP(statut='o', typ=evol_ther),
    TINIT=SIMP(statut='o', typ='R'),
    TFIN=SIMP(statut='o', typ='R'),
    Ctot0=SIMP(statut='o', typ='R'),
    DIME=SIMP(statut='o', typ='I'),
    RESUMECA=SIMP(
    statut='o', typ=resultat_sdaster, fr="Resultat de STAT_NON_LINE"),
    GRMAVOL=SIMP(
    statut='o', typ=grma, validators=NoRepeat(), max=1),
    Nl=SIMP(statut='f', typ='R', defaut=5.1e29),
    Kt=SIMP(
    statut='f', typ='R', defaut=49703276456.589699),
    a1=SIMP(statut='f', typ='R', defaut=23.26),
    a2=SIMP(statut='f', typ='R', defaut=-2.33),
    a3=SIMP(statut='f', typ='R', defaut=-5.5),
    INFO=SIMP(statut='f', typ='I', into=(1, 2)),
    )

CHAR_SOURCE = UserMacro("CHAR_SOURCE", CHAR_SOURCE_cata, char_source_ops)

# "
# macro calculant a chaque pas de temps la source volumique
# "
def champ_detoile_ops(self, RESU_H2, TINIT, TFIN, RESUMECA, GRMAVOL, DIME, Ctot0, Nl, Kt, a1, a2, a3, **args):
# macro pour calculer le chargement thermique specfique a la diffusion H2

    import numpy as NP
    import aster
    from code_aster.Cata.Syntax import _F
    INFO = args.get('INFO')

   # On importe les definitions des commandes a utiliser dans la macro
    DETRUIRE = self.get_cmd('DETRUIRE')
    CREA_CHAMP = self.get_cmd('CREA_CHAMP')
    CALC_CHAMP = self.get_cmd('CALC_CHAMP')

   # Recuperation du modele a partir du resultat
    moth = RESU_H2.getModel()

   # Recuperation du maillage a partir du resultat
    mesh = moth.getSupportMesh()

   # Recuperation du modele mecanique a partir du resultat
    mome = RESUMECA.getModel()

    # extraction du champ de Cl instant -
    __C20 = CREA_CHAMP(OPERATION='EXTR', TYPE_CHAM='NOEU_TEMP_R',
                       RESULTAT=RESU_H2, NOM_CHAM='TEMP', INST=TINIT, INFO=INFO)
    __EPEQN2 = CALC_CHAMP(
        INST=(TINIT, TFIN), RESULTAT=RESUMECA, VARI_INTERNE='VARI_NOEU')
    __EPEQN = PROJ_CHAMP(
        METHODE='COLLOCATION',
                RESULTAT=__EPEQN2,
                MODELE_1=mome,
                MODELE_2=moth,
                NOM_CHAM='VARI_NOEU',
                TOUT_ORDRE='OUI')
    __VINT1 = CREA_CHAMP(OPERATION='EXTR', TYPE_CHAM='NOEU_VAR2_R',
                         RESULTAT=__EPEQN, NOM_CHAM='VARI_NOEU', INST=TFIN, INFO=INFO)

    # recopie du champ C20 pour initialiser le futur champ source
    __chtmp = CREA_CHAMP(
        OPERATION='AFFE', TYPE_CHAM='NOEU_NEUT_R', MAILLAGE=mesh,
        AFFE=(_F(VALE=0., GROUP_MA=GRMAVOL, NOM_CMP='X1',),))
    nomcham = __chtmp.sdj.nomj()

    # on suppose que les noeuds du maillage thermique et mecaniqeu sont les
    # memes (pour eviter un PROJ_CHAMP)
    lc_t0 = __C20.EXTR_COMP('TEMP', [], 1)
    c_t0 = lc_t0.valeurs
    node_th = lc_t0.noeud
    lp_t1 = __VINT1.EXTR_COMP('V1', [], 1)
    p_t1 = lp_t1.valeurs
    node_me = lp_t1.noeud
    nbnode = len(node_th)
    assert(nbnode == len(node_me))
    detoile = NP.zeros(nbnode)
    bidon = NP.zeros(nbnode)
    for ino, node in enumerate(node_th):
        Cl = c_t0[ino]
        p1 = p_t1[ino]
        detoile[ino] = DETOILE(Cl, p1, Ctot0, Nl, Kt, a1, a2, a3)

    nomvect = '%-19s.VALE' % __chtmp.nom
    aster.putvectjev(nomvect, nbnode, tuple(
        range(1, nbnode + 1)), tuple(detoile), tuple(bidon), 1)
    NEUTG = CREA_CHAMP(OPERATION='DISC', TYPE_CHAM='ELNO_NEUT_R',
                       MODELE=moth, PROL_ZERO='OUI', CHAM_GD=__chtmp, INFO=INFO)

    return NEUTG


CHAMP_DETOILE_cata = MACRO(
    nom="CHAMP_DETOILE",
    op=champ_detoile_ops,
    sd_prod=cham_elem,
    docu="",
    reentrant='n',
    fr="calcul du cham de Detoile",

    RESU_H2=SIMP(statut='o', typ=evol_ther),
    TINIT=SIMP(statut='o', typ='R'),
    TFIN=SIMP(statut='o', typ='R'),
    Ctot0=SIMP(statut='o', typ='R'),
    DIME=SIMP(statut='o', typ='I'),
    RESUMECA=SIMP(
    statut='o', typ=resultat_sdaster, fr="Resultat de STAT_NON_LINE"),
    GRMAVOL=SIMP(
    statut='o', typ=grma, validators=NoRepeat(), max=1),
    Nl=SIMP(statut='f', typ='R', defaut=5.1e29),
    Kt=SIMP(
    statut='f', typ='R', defaut=49703276456.589699),
    a1=SIMP(statut='f', typ='R', defaut=23.26),
    a2=SIMP(statut='f', typ='R', defaut=-2.33),
    a3=SIMP(statut='f', typ='R', defaut=-5.5),
    INFO=SIMP(statut='f', typ='I', into=(1, 2)),
    )

CHAMP_DETOILE = UserMacro("CHAMP_DETOILE", CHAMP_DETOILE_cata, champ_detoile_ops)
