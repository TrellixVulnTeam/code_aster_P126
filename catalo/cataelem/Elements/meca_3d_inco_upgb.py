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

# person_in_charge: mickael.abbas at edf.fr


from cataelem.Tools.base_objects import LocatedComponents, ArrayOfComponents, SetOfNodes, ElrefeLoc
from cataelem.Tools.base_objects import Calcul, Element
import cataelem.Commons.physical_quantities as PHY
import cataelem.Commons.located_components as LC
import cataelem.Commons.parameters as SP
import cataelem.Commons.mesh_types as MT
from cataelem.Options.options import OP

#----------------
# Modes locaux :
#----------------


CCAMASS  = LocatedComponents(phys=PHY.CAMASS, type='ELEM',
    components=('C','ALPHA',))

DDL_MECA = LocatedComponents(phys=PHY.DEPL_R, type='ELNO', diff=True,
    components=(
    ('EN1',('DX','DY','DZ','PRES','GONF',)),
    ('EN2',('DX','DY','DZ','PRES',)),))


NDEPLAR  = LocatedComponents(phys=PHY.DEPL_R, type='ELNO',
    components=('DX','DY','DZ',))


EDEFOPC  = LocatedComponents(phys=PHY.EPSI_C, type='ELGA', location='RIGI',
    components=('EPXX','EPYY','EPZZ','EPXY','EPXZ',
          'EPYZ',))


EDEFONC  = LocatedComponents(phys=PHY.EPSI_C, type='ELNO',
    components=('EPXX','EPYY','EPZZ','EPXY','EPXZ',
          'EPYZ',))


CEPSINF  = LocatedComponents(phys=PHY.EPSI_F, type='ELEM',
    components=('EPXX','EPYY','EPZZ','EPXY','EPXZ',
          'EPYZ',))


EDEFOPG  = LocatedComponents(phys=PHY.EPSI_R, type='ELGA', location='RIGI',
    components=('EPXX','EPYY','EPZZ','EPXY','EPXZ',
          'EPYZ',))


EDEFONO  = LocatedComponents(phys=PHY.EPSI_R, type='ELNO',
    components=('EPXX','EPYY','EPZZ','EPXY','EPXZ',
          'EPYZ',))


CEPSINR  = LocatedComponents(phys=PHY.EPSI_R, type='ELEM',
    components=('EPXX','EPYY','EPZZ','EPXY','EPXZ',
          'EPYZ',))


EDFEQPG  = LocatedComponents(phys=PHY.EPSI_R, type='ELGA', location='RIGI',
    components=('INVA_2','PRIN_[3]','INVA_2SG','VECT_1_X','VECT_1_Y',
          'VECT_1_Z','VECT_2_X','VECT_2_Y','VECT_2_Z','VECT_3_X',
          'VECT_3_Y','VECT_3_Z',))


EERREUR  = LocatedComponents(phys=PHY.ERRE_R, type='ELEM',
    components=('ERREST','NUEST','SIGCAL','TERMRE','TERMR2',
          'TERMNO','TERMN2','TERMSA','TERMS2','TAILLE',))


EERRENO  = LocatedComponents(phys=PHY.ERRE_R, type='ELNO',
    components=('ERREST','NUEST','SIGCAL','TERMRE','TERMR2',
          'TERMNO','TERMN2','TERMSA','TERMS2','TAILLE',))


CFORCEF  = LocatedComponents(phys=PHY.FORC_F, type='ELEM',
    components=('FX','FY','FZ',))


NFORCER  = LocatedComponents(phys=PHY.FORC_R, type='ELNO',
    components=('FX','FY','FZ',))


EFORCER  = LocatedComponents(phys=PHY.FORC_R, type='ELGA', location='RIGI',
    components=('FX','FY','FZ',))


EKTHETA  = LocatedComponents(phys=PHY.G, type='ELEM',
    components=('GTHETA','FIC[3]','K[3]','BETA',))


NGEOMER  = LocatedComponents(phys=PHY.GEOM_R, type='ELNO',
    components=('X','Y','Z',))




EGGEOM_R = LocatedComponents(phys=PHY.GEOM_R, type='ELGA', location='RIGI',
    components=('X','Y','Z',))


EGGEOP_R = LocatedComponents(phys=PHY.GEOM_R, type='ELGA', location='RIGI',
    components=('X','Y','Z','W',))


CTEMPSR  = LocatedComponents(phys=PHY.INST_R, type='ELEM',
    components=('INST',))


EGNEUT_F = LocatedComponents(phys=PHY.NEUT_F, type='ELGA', location='RIGI',
    components=('X[30]',))


EMNEUT_R = LocatedComponents(phys=PHY.NEUT_R, type='ELEM',
    components=('X[30]',))


EGNEUT_R = LocatedComponents(phys=PHY.NEUT_R, type='ELGA', location='RIGI',
    components=('X[30]',))


EREFCO   = LocatedComponents(phys=PHY.PREC, type='ELEM',
    components=('SIGM','EPSI',))


ECONTPC  = LocatedComponents(phys=PHY.SIEF_C, type='ELGA', location='RIGI',
    components=('SIXX','SIYY','SIZZ','SIXY','SIXZ',
          'SIYZ',))


ECONTNC  = LocatedComponents(phys=PHY.SIEF_C, type='ELNO',
    components=('SIXX','SIYY','SIZZ','SIXY','SIXZ',
          'SIYZ',))


ECONTPG  = LocatedComponents(phys=PHY.SIEF_R, type='ELGA', location='RIGI',
    components=('SIXX','SIYY','SIZZ','SIXY','SIXZ',
          'SIYZ',))


ECONTNO  = LocatedComponents(phys=PHY.SIEF_R, type='ELNO',
    components=('SIXX','SIYY','SIZZ','SIXY','SIXZ',
          'SIYZ',))


ECOEQPG  = LocatedComponents(phys=PHY.SIEF_R, type='ELGA', location='RIGI',
    components=('VMIS','TRESCA','PRIN_[3]','VMIS_SG','VECT_1_X',
          'VECT_1_Y','VECT_1_Z','VECT_2_X','VECT_2_Y','VECT_2_Z',
          'VECT_3_X','VECT_3_Y','VECT_3_Z','TRSIG','TRIAX',))


ESOURCR  = LocatedComponents(phys=PHY.SOUR_R, type='ELGA', location='RIGI',
    components=('SOUR',))


ZVARIPG  = LocatedComponents(phys=PHY.VARI_R, type='ELGA', location='RIGI',
    components=('VARI',))


MVECTUR  = ArrayOfComponents(phys=PHY.VDEP_R, locatedComponents=DDL_MECA)

VVECTUR  = ArrayOfComponents(phys=PHY.VDEP_R, locatedComponents=NDEPLAR)

MMATUUR  = ArrayOfComponents(phys=PHY.MDEP_R, locatedComponents=DDL_MECA)

VMATUUR  = ArrayOfComponents(phys=PHY.MDEP_R, locatedComponents=NDEPLAR)

MMATUNS  = ArrayOfComponents(phys=PHY.MDNS_R, locatedComponents=DDL_MECA)


#------------------------------------------------------------
class MBNC_HEXA20(Element):
    """Mechanics - 3D - Incompressible - UPGB model - HEXA20"""
    meshType = MT.HEXA20
    nodes = (
            SetOfNodes('EN1', (1,2,3,4,5,6,7,8,)),
            SetOfNodes('EN2', (9,10,11,12,13,14,15,16,17,18,19,20,)),
        )
    elrefe =(
            ElrefeLoc(MT.H20, gauss = ('RIGI=FPG8','MASS=FPG27','NOEU=NOEU','FPG1=FPG1',), mater=('RIGI','MASS','NOEU','FPG1',),),
            ElrefeLoc(MT.HE8, gauss = ('RIGI=FPG8',),),
            ElrefeLoc(MT.H20, gauss = ('RIGI=FPG8',),),
            ElrefeLoc(MT.QU8, gauss = ('RIGI=FPG9','MASS=FPG9','NOEU=NOEU',),),
        )
    calculs = (

        OP.CALC_G(te=27,
            para_in=((SP.PACCELE, NDEPLAR), (OP.CALC_G.PCOMPOR, LC.CCOMPOR),
                     (SP.PCONTGR, ECONTPG), (OP.CALC_G.PCONTRR, ECONTPG),
                     (SP.PDEFOPL, EDEFONO), (SP.PDEPINR, NDEPLAR),
                     (SP.PDEPLAR, NDEPLAR), (SP.PEPSINR, CEPSINR),
                     (SP.PFRVOLU, NFORCER), (SP.PGEOMER, NGEOMER),
                     (SP.PMATERC, LC.CMATERC), (SP.PPESANR, LC.CPESANR),
                     (SP.PROTATR, LC.CROTATR), (SP.PSIGINR, ECONTNO),
                     (SP.PTHETAR, NDEPLAR), (OP.CALC_G.PVARCPR, LC.ZVARCPG),
                     (SP.PVARCRR, LC.ZVARCPG), (OP.CALC_G.PVARIPR, LC.ZVARINO),
                     (SP.PVITESS, NDEPLAR), ),
            para_out=((SP.PGTHETA, LC.EGTHETA), ),
        ),

        OP.CALC_G_F(te=27,
            para_in=((SP.PACCELE, NDEPLAR), (OP.CALC_G_F.PCOMPOR, LC.CCOMPOR),
                     (SP.PCONTGR, ECONTPG), (OP.CALC_G_F.PCONTRR, ECONTPG),
                     (SP.PDEFOPL, EDEFONO), (SP.PDEPINR, NDEPLAR),
                     (SP.PDEPLAR, NDEPLAR), (SP.PEPSINF, CEPSINF),
                     (SP.PFFVOLU, CFORCEF), (SP.PGEOMER, NGEOMER),
                     (SP.PMATERC, LC.CMATERC), (SP.PPESANR, LC.CPESANR),
                     (SP.PROTATR, LC.CROTATR), (SP.PSIGINR, ECONTNO),
                     (SP.PTEMPSR, CTEMPSR), (SP.PTHETAR, NDEPLAR),
                     (OP.CALC_G_F.PVARCPR, LC.ZVARCPG), (SP.PVARCRR, LC.ZVARCPG),
                     (OP.CALC_G_F.PVARIPR, LC.ZVARINO), (SP.PVITESS, NDEPLAR),
                     ),
            para_out=((SP.PGTHETA, LC.EGTHETA), ),
        ),

        OP.CALC_K_G(te=295,
            para_in=((OP.CALC_K_G.PBASLOR, LC.N9NEUT_R), (OP.CALC_K_G.PCOMPOR, LC.CCOMPOR),
                     (SP.PCOURB, LC.G27NEUTR), (SP.PDEPINR, NDEPLAR),
                     (SP.PDEPLAR, NDEPLAR), (SP.PEPSINR, CEPSINR),
                     (SP.PFRVOLU, NFORCER), (SP.PGEOMER, NGEOMER),
                     (OP.CALC_K_G.PLSN, LC.N1NEUT_R), (OP.CALC_K_G.PLST, LC.N1NEUT_R),
                     (SP.PMATERC, LC.CMATERC), (SP.PPESANR, LC.CPESANR),
                     (SP.PPULPRO, LC.CFREQR), (SP.PROTATR, LC.CROTATR),
                     (SP.PSIGINR, ECONTNO), (SP.PTHETAR, NDEPLAR),
                     (OP.CALC_K_G.PVARCPR, LC.ZVARCPG), (SP.PVARCRR, LC.ZVARCPG),
                     ),
            para_out=((SP.PGTHETA, EKTHETA), ),
        ),

        OP.CALC_K_G_F(te=295,
            para_in=((OP.CALC_K_G_F.PBASLOR, LC.N9NEUT_R), (OP.CALC_K_G_F.PCOMPOR, LC.CCOMPOR),
                     (SP.PCOURB, LC.G27NEUTR), (SP.PDEPINR, NDEPLAR),
                     (SP.PDEPLAR, NDEPLAR), (SP.PEPSINF, CEPSINF),
                     (SP.PFFVOLU, CFORCEF), (SP.PGEOMER, NGEOMER),
                     (OP.CALC_K_G_F.PLSN, LC.N1NEUT_R), (OP.CALC_K_G_F.PLST, LC.N1NEUT_R),
                     (SP.PMATERC, LC.CMATERC), (SP.PPESANR, LC.CPESANR),
                     (SP.PPULPRO, LC.CFREQR), (SP.PROTATR, LC.CROTATR),
                     (SP.PSIGINR, ECONTNO), (SP.PTEMPSR, CTEMPSR),
                     (SP.PTHETAR, NDEPLAR), (OP.CALC_K_G_F.PVARCPR, LC.ZVARCPG),
                     (SP.PVARCRR, LC.ZVARCPG), ),
            para_out=((SP.PGTHETA, EKTHETA), ),
        ),

        OP.CHAR_LIMITE(te=483,
            para_in=((SP.PDEPLAR, NDEPLAR), (SP.PGEOMER, NGEOMER),
                     (SP.PMATERC, LC.CMATERC), (SP.PTEMPSR, CTEMPSR),
                     (OP.CHAR_LIMITE.PVARCPR, LC.ZVARCPG), ),
            para_out=((SP.PECHLI, LC.ECHALIM), ),
        ),

        OP.CHAR_MECA_FF3D3D(te=17,
            para_in=((SP.PFF3D3D, CFORCEF), (SP.PGEOMER, NGEOMER),
                     (SP.PTEMPSR, CTEMPSR), ),
            para_out=((SP.PVECTUR, VVECTUR), ),
        ),

        OP.CHAR_MECA_FR3D3D(te=16,
            para_in=((SP.PFR3D3D, NFORCER), (SP.PGEOMER, NGEOMER),
                     ),
            para_out=((SP.PVECTUR, VVECTUR), ),
        ),

        OP.CHAR_MECA_PESA_R(te=15,
            para_in=((SP.PGEOMER, NGEOMER), (SP.PMATERC, LC.CMATERC),
                     (SP.PPESANR, LC.CPESANR), (OP.CHAR_MECA_PESA_R.PVARCPR, LC.ZVARCPG),
                     ),
            para_out=((SP.PVECTUR, VVECTUR), ),
        ),

        OP.CHAR_MECA_TEMP_R(te=13,
            para_in=((SP.PCAMASS, CCAMASS), (OP.CHAR_MECA_TEMP_R.PCOMPOR, LC.CCOMPOR),
                     (SP.PGEOMER, NGEOMER), (SP.PMATERC, LC.CMATERC),
                     (SP.PTEMPSR, CTEMPSR), (OP.CHAR_MECA_TEMP_R.PVARCPR, LC.ZVARCPG),
                     (SP.PVARCRR, LC.ZVARCPG), ),
            para_out=((SP.PVECTUR, VVECTUR), ),
        ),

        OP.COOR_ELGA(te=488,
            para_in=((SP.PGEOMER, NGEOMER), ),
            para_out=((OP.COOR_ELGA.PCOORPG, EGGEOP_R), ),
        ),

        OP.EPEQ_ELGA(te=335,
            para_in=((OP.EPEQ_ELGA.PDEFORR, EDEFOPG), ),
            para_out=((OP.EPEQ_ELGA.PDEFOEQ, EDFEQPG), ),
        ),

        OP.EPEQ_ELNO(te=335,
            para_in=((OP.EPEQ_ELNO.PDEFORR, EDEFONO), ),
            para_out=((OP.EPEQ_ELNO.PDEFOEQ, LC.EDFEQNO), ),
        ),
        
        OP.EPGQ_ELGA(te=335,
            para_in=((OP.EPGQ_ELGA.PDEFORR, EDEFOPG), ),
            para_out=((OP.EPGQ_ELGA.PDEFOEQ, EDFEQPG), ),
        ),

        OP.EPGQ_ELNO(te=335,
            para_in=((OP.EPGQ_ELNO.PDEFORR, EDEFONO), ),
            para_out=((OP.EPGQ_ELNO.PDEFOEQ, LC.EDFEQNO), ),
        ),

        OP.EPSI_ELGA(te=453,
            para_in=((SP.PDEPLAR, NDEPLAR), (SP.PGEOMER, NGEOMER),
                     (OP.EPSI_ELGA.PVARCPR, LC.ZVARCPG), ),
            para_out=((SP.PDEFOPC, EDEFOPC), (OP.EPSI_ELGA.PDEFOPG, EDEFOPG),
                     ),
        ),

        OP.EPSI_ELNO(te=4,
            para_in=((OP.EPSI_ELNO.PDEFOPG, EDEFOPG), ),
            para_out=((SP.PDEFONC, EDEFONC), (SP.PDEFONO, EDEFONO),
                     ),
        ),

        OP.EPSG_ELGA(te=25,
            para_in=((SP.PDEPLAR, NDEPLAR), (SP.PGEOMER, NGEOMER),
                     (SP.PMATERC, LC.CMATERC), (OP.EPSG_ELGA.PVARCPR, LC.ZVARCPG),
                     (SP.PVARCRR, LC.ZVARCPG), ),
            para_out=((OP.EPSG_ELGA.PDEFOPG, EDEFOPG), ),
        ),

        OP.EPSG_ELNO(te=4,
            para_in=((OP.EPSG_ELNO.PDEFOPG, EDEFOPG), ),
            para_out=((SP.PDEFONO, EDEFONO), ),
        ),

        OP.EPSL_ELGA(te=25,
            para_in=((SP.PDEPLAR, NDEPLAR), (SP.PGEOMER, NGEOMER),
                     (SP.PMATERC, LC.CMATERC), (OP.EPSL_ELGA.PVARCPR, LC.ZVARCPG),
                     (SP.PVARCRR, LC.ZVARCPG), ),
            para_out=((OP.EPSL_ELGA.PDEFOPG, EDEFOPG), ),
        ),

        OP.EPSL_ELNO(te=4,
            para_in=((OP.EPSL_ELNO.PDEFOPG, EDEFOPG), ),
            para_out=((SP.PDEFONO, EDEFONO), ),
        ),

        OP.ERME_ELEM(te=375,
            para_in=((SP.PCONTNO, ECONTNO), (SP.PFFVOLU, CFORCEF),
                     (SP.PFORCE, LC.CREFERI), (SP.PFRVOLU, EFORCER),
                     (SP.PGEOMER, NGEOMER), (SP.PMATERC, LC.CMATERC),
                     (SP.PPESANR, LC.CPESANR), (SP.PPRESS, LC.CREFERI),
                     (SP.PROTATR, LC.CROTATR), (SP.PTEMPSR, CTEMPSR),
                     (OP.ERME_ELEM.PVOISIN, LC.EVOISIN), ),
            para_out=((OP.ERME_ELEM.PERREUR, EERREUR), ),
        ),

        OP.ERME_ELNO(te=379,
            para_in=((OP.ERME_ELNO.PERREUR, EERREUR), ),
            para_out=((SP.PERRENO, EERRENO), ),
        ),

        OP.FORC_NODA(te=591,
            para_in=((OP.FORC_NODA.PCOMPOR, LC.CCOMPOR), (OP.FORC_NODA.PCONTMR, ECONTPG),
                     (SP.PDEPLMR, DDL_MECA), (SP.PDEPLPR, DDL_MECA),
                     (SP.PGEOMER, NGEOMER), (SP.PMATERC, LC.CMATERC),
                     (OP.FORC_NODA.PVARCPR, LC.ZVARCPG), (SP.PVARCRR, LC.ZVARCPG),
                     ),
            para_out=((SP.PVECTUR, MVECTUR), ),
        ),

        OP.FULL_MECA(te=590,
            para_in=((SP.PCARCRI, LC.CCARCRI), (OP.FULL_MECA.PCOMPOR, LC.CCOMPOR),
                     (OP.FULL_MECA.PCONTMR, ECONTPG), (SP.PDEPLMR, DDL_MECA),
                     (SP.PDEPLPR, DDL_MECA), (SP.PGEOMER, NGEOMER),
                     (SP.PINSTMR, CTEMPSR), (SP.PINSTPR, CTEMPSR),(SP.PITERAT, LC.CITERAT),
                     (SP.PMATERC, LC.CMATERC), (SP.PVARCMR, LC.ZVARCPG),
                     (OP.FULL_MECA.PVARCPR, LC.ZVARCPG), (SP.PVARCRR, LC.ZVARCPG),
                     (SP.PVARIMP, ZVARIPG), (OP.FULL_MECA.PVARIMR, ZVARIPG),
                     ),
            para_out=((SP.PCODRET, LC.ECODRET), (OP.FULL_MECA.PCONTPR, ECONTPG),
                     (SP.PMATUNS, MMATUNS), (SP.PMATUUR, MMATUUR),
                     (OP.FULL_MECA.PVARIPR, ZVARIPG), (SP.PVECTUR, MVECTUR),
                     ),
        ),

        OP.FULL_MECA_ELAS(te=590,
            para_in=((SP.PCARCRI, LC.CCARCRI), (OP.FULL_MECA_ELAS.PCOMPOR, LC.CCOMPOR),
                     (OP.FULL_MECA_ELAS.PCONTMR, ECONTPG), (SP.PDEPLMR, DDL_MECA),
                     (SP.PDEPLPR, DDL_MECA), (SP.PGEOMER, NGEOMER),
                     (SP.PINSTMR, CTEMPSR), (SP.PINSTPR, CTEMPSR),
                     (SP.PMATERC, LC.CMATERC), (SP.PVARCMR, LC.ZVARCPG),
                     (OP.FULL_MECA_ELAS.PVARCPR, LC.ZVARCPG), (SP.PVARCRR, LC.ZVARCPG),
                     (SP.PVARIMP, ZVARIPG), (OP.FULL_MECA_ELAS.PVARIMR, ZVARIPG),
                     ),
            para_out=((SP.PCODRET, LC.ECODRET), (OP.FULL_MECA_ELAS.PCONTPR, ECONTPG),
                     (SP.PMATUNS, MMATUNS), (SP.PMATUUR, MMATUUR),
                     (OP.FULL_MECA_ELAS.PVARIPR, ZVARIPG), (SP.PVECTUR, MVECTUR),
                     ),
        ),

        OP.GRAD_NEUT9_R(te=398,
            para_in=((SP.PGEOMER, NGEOMER), (SP.PNEUTER, LC.N9NEUT_R),
                     ),
            para_out=((OP.GRAD_NEUT9_R.PGNEUTR, LC.G27NEUTR), ),
        ),

        OP.INIT_MAIL_VOIS(te=99,
            para_out=((OP.INIT_MAIL_VOIS.PVOISIN, LC.EVOISIN), ),
        ),

        OP.INIT_VARC(te=99,
            para_out=((OP.INIT_VARC.PVARCPR, LC.ZVARCPG), ),
        ),

        OP.MASS_MECA(te=12,
            para_in=((SP.PGEOMER, NGEOMER), (SP.PMATERC, LC.CMATERC),
                     (OP.MASS_MECA.PVARCPR, LC.ZVARCPG), ),
            para_out=((SP.PMATUUR, VMATUUR), ),
        ),

        OP.NORME_L2(te=563,
            para_in=((SP.PCALCI, LC.EMNEUT_I), (SP.PCHAMPG, EGNEUT_R),
                     (SP.PCOEFR, EMNEUT_R), (OP.NORME_L2.PCOORPG, EGGEOP_R),
                     ),
            para_out=((SP.PNORME, LC.ENORME), ),
        ),

        OP.NSPG_NBVA(te=496,
            para_in=((OP.NSPG_NBVA.PCOMPOR, LC.CCOMPO2), ),
            para_out=((SP.PDCEL_I, LC.EDCEL_I), ),
        ),

        OP.PAS_COURANT(te=404,
            para_in=((SP.PGEOMER, NGEOMER), (SP.PMATERC, LC.CMATERC),
                     (OP.PAS_COURANT.PVARCPR, LC.ZVARCPG),),
            para_out=((SP.PCOURAN, LC.ECOURAN), ),
        ),

        OP.QIRE_ELEM(te=368,
            para_in=((SP.PCONSTR, LC.CCONSTR), (SP.PCONTNOD, ECONTNO),
                     (SP.PCONTNOP, ECONTNO), (SP.PFFVOLUD, CFORCEF),
                     (SP.PFFVOLUP, CFORCEF), (SP.PFORCED, LC.CREFERI),
                     (SP.PFORCEP, LC.CREFERI), (SP.PFRVOLUD, EFORCER),
                     (SP.PFRVOLUP, EFORCER), (SP.PGEOMER, NGEOMER),
                     (SP.PPESANRD, LC.CPESANR), (SP.PPESANRP, LC.CPESANR),
                     (SP.PPRESSD, LC.CREFERI), (SP.PPRESSP, LC.CREFERI),
                     (SP.PROTATRD, LC.CROTATR), (SP.PROTATRP, LC.CROTATR),
                     (SP.PTEMPSR, CTEMPSR), (OP.QIRE_ELEM.PVOISIN, LC.EVOISIN),
                     ),
            para_out=((OP.QIRE_ELEM.PERREUR, EERREUR), ),
        ),

        OP.QIRE_ELNO(te=379,
            para_in=((OP.QIRE_ELNO.PERREUR, EERREUR), ),
            para_out=((SP.PERRENO, EERRENO), ),
        ),

        OP.RAPH_MECA(te=590,
            para_in=((SP.PCARCRI, LC.CCARCRI), (OP.RAPH_MECA.PCOMPOR, LC.CCOMPOR),
                     (OP.RAPH_MECA.PCONTMR, ECONTPG), (SP.PDEPLMR, DDL_MECA),
                     (SP.PDEPLPR, DDL_MECA), (SP.PGEOMER, NGEOMER),
                     (SP.PINSTMR, CTEMPSR), (SP.PINSTPR, CTEMPSR),(SP.PITERAT, LC.CITERAT),
                     (SP.PMATERC, LC.CMATERC), (SP.PVARCMR, LC.ZVARCPG),
                     (OP.RAPH_MECA.PVARCPR, LC.ZVARCPG), (SP.PVARCRR, LC.ZVARCPG),
                     (SP.PVARIMP, ZVARIPG), (OP.RAPH_MECA.PVARIMR, ZVARIPG),
                     ),
            para_out=((SP.PCODRET, LC.ECODRET), (OP.RAPH_MECA.PCONTPR, ECONTPG),
                     (OP.RAPH_MECA.PVARIPR, ZVARIPG), (SP.PVECTUR, MVECTUR),
                     ),
        ),

        OP.REFE_FORC_NODA(te=593,
            para_in=((OP.REFE_FORC_NODA.PCOMPOR, LC.CCOMPOR), (SP.PGEOMER, NGEOMER),
                     (SP.PREFCO, EREFCO), ),
            para_out=((SP.PVECTUR, MVECTUR), ),
        ),

        OP.REPERE_LOCAL(te=133,
            para_in=((SP.PCAMASS, CCAMASS), (SP.PGEOMER, NGEOMER),
                     ),
            para_out=((SP.PREPLO1, LC.CGEOM3D), (SP.PREPLO2, LC.CGEOM3D),
                     (SP.PREPLO3, LC.CGEOM3D), ),
        ),

        OP.RIGI_MECA(te=592,
            para_in=((SP.PCAMASS, CCAMASS), (SP.PGEOMER, NGEOMER),
                     (SP.PMATERC, LC.CMATERC), (OP.RIGI_MECA.PVARCPR, LC.ZVARCPG),
                     ),
            para_out=((SP.PMATUUR, MMATUUR), ),
        ),

        OP.RIGI_MECA_ELAS(te=590,
            para_in=((SP.PCARCRI, LC.CCARCRI), (OP.RIGI_MECA_ELAS.PCOMPOR, LC.CCOMPOR),
                     (OP.RIGI_MECA_ELAS.PCONTMR, ECONTPG), (SP.PDEPLMR, DDL_MECA),
                     (SP.PDEPLPR, DDL_MECA), (SP.PGEOMER, NGEOMER),
                     (SP.PINSTMR, CTEMPSR), (SP.PINSTPR, CTEMPSR),
                     (SP.PMATERC, LC.CMATERC), (SP.PVARCMR, LC.ZVARCPG),
                     (OP.RIGI_MECA_ELAS.PVARCPR, LC.ZVARCPG), (SP.PVARCRR, LC.ZVARCPG),
                     (OP.RIGI_MECA_ELAS.PVARIMR, ZVARIPG), ),
            para_out=((SP.PMATUNS, MMATUNS), (SP.PMATUUR, MMATUUR),
                     ),
        ),

        OP.RIGI_MECA_TANG(te=590,
            para_in=((SP.PCARCRI, LC.CCARCRI), (OP.RIGI_MECA_TANG.PCOMPOR, LC.CCOMPOR),
                     (OP.RIGI_MECA_TANG.PCONTMR, ECONTPG), (SP.PDEPLMR, DDL_MECA),
                     (SP.PDEPLPR, DDL_MECA), (SP.PGEOMER, NGEOMER),
                     (SP.PINSTMR, CTEMPSR), (SP.PINSTPR, CTEMPSR),(SP.PITERAT, LC.CITERAT),
                     (SP.PMATERC, LC.CMATERC), (SP.PVARCMR, LC.ZVARCPG),
                     (OP.RIGI_MECA_TANG.PVARCPR, LC.ZVARCPG), (SP.PVARCRR, LC.ZVARCPG),
                     (OP.RIGI_MECA_TANG.PVARIMR, ZVARIPG), ),
            para_out=((SP.PMATUNS, MMATUNS), (SP.PMATUUR, MMATUUR),
                     ),
        ),

        OP.SIEF_ELGA(te=97,
            para_in=((SP.PCAMASS, CCAMASS), (SP.PDEPLAR, NDEPLAR),
                     (SP.PGEOMER, NGEOMER), (SP.PMATERC, LC.CMATERC),
                     (OP.SIEF_ELGA.PVARCPR, LC.ZVARCPG), (SP.PVARCRR, LC.ZVARCPG),
                     ),
            para_out=((SP.PCONTRC, ECONTPC), (OP.SIEF_ELGA.PCONTRR, ECONTPG),
                     ),
        ),

        OP.SIEF_ELNO(te=4,
            para_in=((OP.SIEF_ELNO.PCONTRR, ECONTPG), (OP.SIEF_ELNO.PVARCPR, LC.ZVARCPG),
                     ),
            para_out=((SP.PSIEFNOC, ECONTNC), (OP.SIEF_ELNO.PSIEFNOR, ECONTNO),
                     ),
        ),

        OP.SIEQ_ELGA(te=335,
            para_in=((OP.SIEQ_ELGA.PCONTRR, ECONTPG), ),
            para_out=((OP.SIEQ_ELGA.PCONTEQ, ECOEQPG), ),
        ),

        OP.SIEQ_ELNO(te=335,
            para_in=((OP.SIEQ_ELNO.PCONTRR, ECONTNO), ),
            para_out=((OP.SIEQ_ELNO.PCONTEQ, LC.ECOEQNO), ),
        ),

        OP.SIGM_ELGA(te=546,
            para_in=((SP.PSIEFR, ECONTPG), ),
            para_out=((SP.PSIGMC, ECONTPC), (SP.PSIGMR, ECONTPG),
                     ),
        ),

        OP.SIGM_ELNO(te=4,
            para_in=((OP.SIGM_ELNO.PCONTRR, ECONTPG), ),
            para_out=((SP.PSIEFNOC, ECONTNC), (OP.SIGM_ELNO.PSIEFNOR, ECONTNO),
                     ),
        ),

        OP.TOU_INI_ELEM(te=99,
            para_out=((OP.TOU_INI_ELEM.PGEOM_R, LC.CGEOM3D), ),
        ),

        OP.TOU_INI_ELGA(te=99,
            para_out=((OP.TOU_INI_ELGA.PGEOM_R, EGGEOM_R), (OP.TOU_INI_ELGA.PNEUT_F, EGNEUT_F),
                     (OP.TOU_INI_ELGA.PNEUT_R, EGNEUT_R), (OP.TOU_INI_ELGA.PSIEF_R, ECONTPG),
                     (OP.TOU_INI_ELGA.PSOUR_R, ESOURCR), (OP.TOU_INI_ELGA.PVARI_R, ZVARIPG),
                     ),
        ),

        OP.TOU_INI_ELNO(te=99,
            para_out=((OP.TOU_INI_ELNO.PGEOM_R, NGEOMER), (OP.TOU_INI_ELNO.PNEUT_F, LC.ENNEUT_F),
                     (OP.TOU_INI_ELNO.PNEUT_R, LC.ENNEUT_R), (OP.TOU_INI_ELNO.PSIEF_R, ECONTNO),
                     (OP.TOU_INI_ELNO.PVARI_R, LC.ZVARINO), ),
        ),

        OP.VARI_ELNO(te=4,
            para_in=((SP.PVARIGR, ZVARIPG), ),
            para_out=((OP.VARI_ELNO.PVARINR, LC.ZVARINO), ),
        ),

        OP.VERI_JACOBIEN(te=328,
            para_in=((SP.PGEOMER, NGEOMER), ),
            para_out=((SP.PCODRET, LC.ECODRET), ),
        ),

    )


#------------------------------------------------------------
class MBNC_TETRA10(MBNC_HEXA20):
    """Mechanics - 3D - Incompressible - UPGB model - TETRA10"""
    meshType = MT.TETRA10
    nodes = (
            SetOfNodes('EN1', (1,2,3,4,)),
            SetOfNodes('EN2', (5,6,7,8,9,10,)),
        )
    elrefe =(
            ElrefeLoc(MT.T10, gauss = ('RIGI=FPG4','MASS=FPG15','NOEU=NOEU','FPG1=FPG1',), mater=('RIGI','MASS','NOEU','FPG1',),),
            ElrefeLoc(MT.TE4, gauss = ('RIGI=FPG4',),),
            ElrefeLoc(MT.T10, gauss = ('RIGI=FPG4',),),
            ElrefeLoc(MT.TR6, gauss = ('RIGI=FPG6','MASS=FPG6','NOEU=NOEU',),),
        )


#------------------------------------------------------------
class MBNC_PENTA15(MBNC_HEXA20):
    """Mechanics - 3D - Incompressible - UPGB model - PENTA15"""
    meshType = MT.PENTA15
    nodes = (
            SetOfNodes('EN1', (1,2,3,4,5,6,)),
            SetOfNodes('EN2', (7,8,9,10,11,12,13,14,15,)),
        )
    elrefe =(
            ElrefeLoc(MT.P15, gauss = ('RIGI=FPG21','MASS=FPG21','NOEU=NOEU','FPG1=FPG1',), mater=('RIGI','MASS','NOEU','FPG1',),),
            ElrefeLoc(MT.PE6, gauss = ('RIGI=FPG21',),),
            ElrefeLoc(MT.P15, gauss = ('RIGI=FPG21',),),
            ElrefeLoc(MT.QU8, gauss = ('RIGI=FPG9','MASS=FPG9','NOEU=NOEU',),),
            ElrefeLoc(MT.TR6, gauss = ('RIGI=FPG6','MASS=FPG6','NOEU=NOEU',),),
        )
