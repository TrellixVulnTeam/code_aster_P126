# coding=utf-8
# --------------------------------------------------------------------
# Copyright (C) 1991 - 2020 - EDF R&D - www.code-aster.org
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

# person_in_charge: francesco.bettonte at edf.fr

"""
This module defines the different types of calculations
"""

import os.path as osp
from functools import wraps

from libaster import ConvergenceError

from ...Cata.Syntax import _F
from ...Commands import (AFFE_CHAR_CINE, AFFE_CHAR_MECA, CALC_CHAMP,
                         CREA_CHAMP, CREA_RESU, DEFI_FONCTION, MODI_MAILLAGE,
                         POST_RELEVE_T, STAT_NON_LINE)
from ...Helpers.UniteAster import UniteAster
from ...Messages import MasquerAlarme, RetablirAlarme, UTMESS
from ...Utilities import ExecutionParameter
from .mac3coeur_coeur import CoeurFactory
from .thyc_result import lire_resu_thyc


def calc_mac3coeur_ops(self, **args):
    """Fonction d'appel de la macro CALC_MAC3COEUR"""

    MasquerAlarme('MECANONLINE5_57')
    MasquerAlarme('ELEMENTS3_59')

    analysis = Mac3CoeurCalcul.factory(self, args)
    result = analysis.run()

    RetablirAlarme('MECANONLINE5_57')
    RetablirAlarme('ELEMENTS3_59')

    return result

# decorator to cache values of properties
NULL = object()


def cached_property(method):
    """Decorator for the 'getter' method of a property
    It returns directly the value without calling the 'getter' method itself if
    it has already been computed (== not NULL).
    The value is cached in the attribute "_ + `method name`" of the instance.
    """
    @wraps(method)
    def wrapper(inst):
        """Real wrapper function"""
        attr = '_' + method.__name__
        cached = getattr(inst, attr)
        if cached is not NULL:
            return cached
        computed = method(inst)
        setattr(inst, attr, computed)
        return computed
    return wrapper


class Mac3CoeurCalcul(object):

    """Base class of an analysis, intended to be inherited

    Its factory builds the proper object according to the passed keywords.
    Then, a calculation is just completed using::

        calc = Mac3CoeurCalcul.factory(...)
        calc.run()

    Inherited classes may have to adjust `_prepare_data()` and `_run()` methods.
    There are a lot of cached properties:
        - They should store only some data required by the calculation.
        - They are computed only at the first access (or after being deleted).
        - The cache mecanism allows to build Code_Aster objects or to run long
          operations only if necessary.
        - Prefer use standard properties for scalar values.
    """
    mcfact = None

    @staticmethod
    def factory(macro, args):
        """Factory that returns the calculation object"""
        class_ = None
        if 'DEFORMATION' in args and args['DEFORMATION']:
            class_ = Mac3CoeurDeformation
        if 'LAME' in args and args['LAME']:
            class_ = Mac3CoeurLame
        if 'ETAT_INITIAL' in args and args['ETAT_INITIAL']:
            class_ = Mac3CoeurEtatInitial
        if not class_:
            UTMESS('F', 'DVP_1')
        return class_(macro, args)

    def __init__(self, macro, args):
        """Initialization"""
        self.macro = macro
        self.keyw = args
        self.mcf = args[self.mcfact]
        # parameters
        self._niv_fluence = 0.
        self._subdivis = 1
        self._use_archimede = None
        self.char_init = None
        self.etat_init = None
        self._maintien_grille = None
        self._lame=False
        self.calc_res_def = False
        self.res_def = None
        self.res_def_keyw = None

        # cached properties
        self._init_properties()

    def _init_properties(self):
        """Initialize all the cached properties to NULL"""
        self._coeur = NULL
        self._mesh = NULL
        self._model = NULL
        self._geofib = NULL
        self._carael = NULL
        self._cham_mater_contact = NULL
        self._cham_mater_free = NULL
        self._times = NULL
        self._times_arch = NULL
        self._times_woSubd = NULL
        self._evol_temp = NULL
        self._evol_fluence = NULL
        self._rigid_load = NULL
        self._archimede_load = NULL
        self._gravity_load = NULL
        self._vessel_head_load = NULL
        self._vessel_dilatation_load = NULL
        self._thyc_load = NULL
        self._symetric_cond = NULL
        self._periodic_cond = NULL
        self._vessel_dilatation_load_full = NULL
        self._kinematic_cond = NULL
        self._char_ini_comp = NULL

    def _prepare_data(self,noresu):
        """Prepare the data for the calculation"""
        coeur = self.coeur
        coeur.recuperation_donnees_geom(self.mesh)
        # force the computation of the times to ensure it is done first
        # Note that times depends on niv_fluence and subdivis.
        self.times
        self.times_arch
        self.fluence_cycle = self.keyw.get('FLUENCE_CYCLE')
        self._type_deformation = self.keyw.get('TYPE_DEFORMATION')
        self._option_rigi_geom = 'DEFAUT'
        if 'RIGI_GEOM' in self._type_deformation:
            self._type_deformation = 'PETIT'
            self._option_rigi_geom = 'OUI'

    def _run(self):
        """Run the calculation itself"""
        raise NotImplementedError('must be defined in a subclass')

    def run(self,noresu=False):
        """Run all the calculation steps"""
        self._prepare_data(noresu)
        return self._run()

    @property
    def niv_fluence(self):
        """Return the fluence level"""
        return self._niv_fluence

    @niv_fluence.setter
    def niv_fluence(self, value):
        """Set the value of the fluence level"""
        self._niv_fluence = value

    @property
    def subdivis(self):
        """Return the factor of time splitting"""
        return self._subdivis

    @subdivis.setter
    def subdivis(self, value):
        """Set the value of the time splitting"""
        self._subdivis = value

    @property
    def use_archimede(self):
        """Tell if Archimede loadings are enabled or not ('OUI'/'NON')"""
        return self._use_archimede

    @use_archimede.setter
    def use_archimede(self, value):
        """Set the value of the time splitting"""
        self._use_archimede = value

    # cached properties
    @property
    @cached_property
    def coeur(self):
        """Return the `Coeur` object"""
        if self.keyw['TYPE_COEUR'][:5] == 'LIGNE' :
            return _build_coeur(self.keyw['TYPE_COEUR'], self.macro,
                            self.keyw['TABLE_N'],self.keyw['NB_ASSEMBLAGE'])
        else :
            return _build_coeur(self.keyw['TYPE_COEUR'], self.macro,
                            self.keyw['TABLE_N'])

    @coeur.setter
    def coeur(self, value):
        """Setter method that ensure that the attribute is NULL"""
        assert self._coeur is NULL, 'attribute must be set only once or resetted'
        self._coeur = value

    @coeur.deleter
    def coeur(self):
        """Reset the attribute"""
        self._coeur = NULL

    @property
    @cached_property
    def mesh(self):
        """Return the `maillage_sdaster` object"""
        return self.coeur.affectation_maillage(self.keyw.get('MAILLAGE_N'))

    @mesh.setter
    def mesh(self, value):
        """Setter method that ensure that the attribute is NULL"""
        assert self._mesh is NULL, 'attribute must be set only once or resetted'
        self._mesh = value

    @mesh.deleter
    def mesh(self):
        """Reset the attribute"""
        self._mesh = NULL

    @property
    @cached_property
    def model(self):
        """Return the `modele_sdaster` object"""
        return self.coeur.affectation_modele(self.mesh)

    @model.setter
    def model(self, value):
        """Setter method that ensure that the attribute is NULL"""
        assert self._model is NULL, 'attribute must be set only once or resetted'
        self._model = value

    @model.deleter
    def model(self):
        """Reset the attribute"""
        self._model = NULL

    @property
    @cached_property
    def geofib(self):
        """Return the `geom_fibre` object"""
        return self.coeur.definition_geom_fibre()

    @property
    @cached_property
    def carael(self):
        """Return the `cara_elem` object"""
        return self.coeur.definition_cara_coeur(self.model, self.geofib)

    @property
    @cached_property
    def times(self):
        """Return the list of the time steps"""
        return self.coeur.definition_time(self.niv_fluence, self.subdivis)

    @property
    @cached_property
    def times_arch(self):
        """Return the list of the archive time"""
        return self.coeur.definition_time_arch(self.niv_fluence, self.subdivis)

    @property
    @cached_property
    def times_woSubd(self):
        """Return the list of the time steps"""
        return self.coeur.definition_time(self.niv_fluence, self.subdivis,1)

    @property
    @cached_property
    def evol_temp(self):
        """Return the evolution of temperature"""
        return self.coeur.definition_champ_temperature(self.mesh)

    @property
    @cached_property
    def evol_fluence(self):
        """Return the evolution of the fluence fields"""
        if self.etat_init :
            assert (self.fluence_cycle == 0.)
        return self.coeur.definition_fluence(self.niv_fluence, self.mesh,self.fluence_cycle,self._lame)

    @property
    @cached_property
    def cham_mater_free(self):
        """Return the field of material (without contact)"""
        return self.coeur.definition_materiau(
            self.mesh, self.geofib, self.evol_fluence,
            self.evol_temp, CONTACT='NON')

    @property
    @cached_property
    def cham_mater_contact(self):
        """Return the field of material (with contact enabled)"""
        return self.coeur.definition_materiau(
            self.mesh, self.geofib, self.evol_fluence,
            self.evol_temp, CONTACT='OUI')

    def cham_mater_contact_progressif(self,ratio):
        """Return the field of material (with contact enabled)"""
        return self.coeur.definition_materiau(
            self.mesh, self.geofib, self.evol_fluence,
            self.evol_temp, CONTACT='OUI',RATIO=ratio)

    # loadings
    @property
    @cached_property
    def rigid_load(self):
        """Compute the rigid body loading"""
        coeur = self.coeur
        _excit_rigid = AFFE_CHAR_MECA(MODELE=self.model,
                                      LIAISON_SOLIDE=coeur.cl_rigidite_grille())
        return [_F(CHARGE=_excit_rigid), ]

    @property
    @cached_property
    def archimede_load(self):
        """Compute the Archimede loadings"""
        fmult_arch = self.coeur.definition_temp_archimede(self.use_archimede)
        load = [
            _F(CHARGE=self.coeur.definition_archimede_nodal(self.model),
               FONC_MULT=fmult_arch,),
            _F(CHARGE=self.coeur.definition_archimede_poutre(self.model),
               FONC_MULT=fmult_arch,), ]
        return load

    @property
    @cached_property
    def gravity_load(self):
        """Return the gravity loading"""
        return [_F(CHARGE=self.coeur.definition_pesanteur(self.model)), ]

    @property
    @cached_property
    def vessel_head_load(self):
        """Return the loadings due to the pression of
        the vessel head"""
        coeur = self.coeur
        dicv = self.mcf[0].cree_dict_valeurs(self.mcf[0].mc_liste)
        typ = dicv.get('TYPE_MAINTIEN') or 'DEPL_PSC'
        force = None
        compression_init = (self.fluence_cycle != 0)
        if typ == 'FORCE':
            force = self.mcf['FORCE_MAINTIEN']
        char = coeur.definition_maintien_type(self.model, typ, force,compression_init)
        return [_F(CHARGE=char), ]

    @property
    @cached_property
    def vessel_dilatation_load(self):
        """Return the loading due to the vessel dilatation"""
        char_dilat = self.coeur.dilatation_cuve(self.model, self.mesh,
                               (self.char_init is not None),self._maintien_grille)
        return [_F(CHARGE=char_dilat,), ]

    @property
    @cached_property
    def vessel_dilatation_load_full(self):
        """Return the loading due to the vessel dilatation"""
        char_dilat = self.coeur.dilatation_cuve(self.model, self.mesh)
        return [_F(CHARGE=char_dilat,), ]

    @property
    @cached_property
    def thyc_load(self):
        """Return the loading due to the fluid flow"""
        coeur = self.coeur
        thyc = read_thyc(coeur, self.model, self.mcf['UNITE_THYC'])

        coef_mult_thv = self.mcf['COEF_MULT_THV'] or 1.
        coef_mult_tht = self.mcf['COEF_MULT_THT'] or 1.
        
        fmult_ax = coeur.definition_temp_hydro_axiale(coef_mult_thv)
        fmult_tr = coeur.definition_effort_transverse(coef_mult_tht)
        
        load_ax = [
            _F(CHARGE=thyc.chax_nodal, FONC_MULT=fmult_ax,),
            _F(CHARGE=thyc.chax_poutre, FONC_MULT=fmult_ax,),
        ]
        load_tr = [
            _F(CHARGE=thyc.chtr_nodal, FONC_MULT=fmult_tr,),
            _F(CHARGE=thyc.chtr_poutre, FONC_MULT=fmult_tr,),
        ]
        self._thyc_ax=(thyc.chax_nodal,thyc.chax_poutre)
        self._thyc_tr=(thyc.chtr_nodal,thyc.chtr_poutre)
        return (load_ax,load_tr)

    @property
    @cached_property
    def kinematic_cond(self):
        """Define the kinematic conditions from displacement"""
        _excit = AFFE_CHAR_CINE(MODELE=self.model,
                                EVOL_IMPO=self.char_init,
                                NOM_CMP=('DY','DZ',),
                                )
        return [_F(CHARGE=_excit), ]

    @property
    @cached_property
    def symetric_cond(self):
        """Define the boundary conditions of symetry"""

        def block(grma=None, grno=None, ddl=None):
            """Block 'ddl' of 'grma/grno' to zero"""
            kddl = {}.fromkeys(ddl, 0.)
            kddl['GROUP_MA' if grma else 'GROUP_NO'] = grma or grno
            return kddl
        ddl_impo = [
            block(grma='CRAYON', ddl=['DRX']),
            block(grno='LISPG', ddl=['DRX', 'DRY', 'DRZ']),
            block(grma=('EBOSUP', 'EBOINF'), ddl=['DRX', 'DRY', 'DRZ']),
        ]
        _excit = AFFE_CHAR_MECA(MODELE=self.model,
                                DDL_IMPO=ddl_impo)
        return [_F(CHARGE=_excit), ]

    @property
    @cached_property
    def periodic_cond(self):
        """Define the boundary conditions of periodicity"""

        def equal(ddl, grno1, grno2):
            """Return keyword to set ddl(grno1) = ddl(grno2)"""
            return _F(GROUP_NO_1=grno1,
                      GROUP_NO_2=grno2,
                      DDL_1=ddl,
                      DDL_2=ddl,
                      COEF_MULT_1=1.,
                      COEF_MULT_2=-1.,
                      COEF_IMPO=0.)
        liaison_group = [equal('DY', 'PMNT_S', 'PEBO_S'),
                         equal('DZ', 'PMNT_S', 'PEBO_S'),
                         equal('DY', 'PSUP', 'PEBO_S'),
                         equal('DZ', 'PSUP', 'PEBO_S'),
                         equal('DY', 'PINF', 'FIX'),
                         equal('DZ', 'PINF', 'FIX'), ]
        _excit = AFFE_CHAR_MECA(MODELE=self.model,
                                LIAISON_GROUP=liaison_group)
        return [_F(CHARGE=_excit), ]

    @property
    @cached_property
    def char_ini_comp(self):
        comp = [_F(RELATION='MULTIFIBRE',
                   GROUP_MA=('CRAYON', 'T_GUIDE'),
                   PARM_THETA=0.5,
                   DEFORMATION = self._type_deformation,
                   RIGI_GEOM = self._option_rigi_geom, ),
                _F(RELATION='DIS_GRICRA',
                   GROUP_MA='ELA',),
                _F(RELATION='DIS_CHOC',
                   GROUP_MA=('RES_EXT','RES_CONT'),),
                _F(RELATION='ELAS',
                   GROUP_MA=('EBOINF', 'EBOSUP', 'RIG', 'DIL')),
                _F(RELATION='VMIS_ISOT_TRAC',
                   GROUP_MA='MAINTIEN',
                   DEFORMATION='PETIT'),]
        return comp


    def snl(self, **kwds):
        """Return the common keywords for STAT_NON_LINE
        All keywords can be overridden using `kwds`."""
        keywords = {
            'MODELE': self.model,
            'CARA_ELEM': self.carael,
            'CHAM_MATER': self.cham_mater_free,
            'COMPORTEMENT': (_F(RELATION='MULTIFIBRE',
                                GROUP_MA=('CRAYON', 'T_GUIDE'),
                                PARM_THETA=0.5,
                                DEFORMATION=self._type_deformation,
                                RIGI_GEOM = self._option_rigi_geom, ),
                             _F(RELATION='DIS_GRICRA',
                                GROUP_MA='ELA',),
                             _F(RELATION='DIS_CHOC',
                                GROUP_MA=('CREIC', 'RES_TOT')),
                             _F(RELATION='ELAS',
                                GROUP_MA=('CREI', 'EBOINF', 'EBOSUP', 'RIG', 'DIL')),
                             _F(RELATION='VMIS_ISOT_TRAC',
                                GROUP_MA='MAINTIEN',
                                DEFORMATION='PETIT'),),
            'SUIVI_DDL':_F(NOM_CHAM='DEPL',EVAL_CHAM='MAXI_ABS',GROUP_NO='CR_BAS',NOM_CMP=('DX',)),
            'NEWTON': _F(MATRICE='TANGENTE',
                         REAC_ITER=1,),
            'CONVERGENCE' : _F(ITER_GLOB_MAXI = 10,
                               RESI_GLOB_MAXI = 1.E-2,
                               RESI_GLOB_RELA = 1.E-6),
            'SOLVEUR': _F(METHODE='MUMPS',
                          PRETRAITEMENTS='AUTO'),
            'ARCHIVAGE': _F(LIST_INST=self.times_arch,
                            PRECISION=1.E-08),
            'AFFICHAGE': _F(INFO_RESIDU='OUI'),
            'INFO' : 1,
        }
        keywords.update(kwds)
        return keywords

    def snl_lame(self, **kwds):
        """Return the common keywords for STAT_NON_LINE
        All keywords can be overridden using `kwds`."""
        keywords = {
            'MODELE': self.model,
            'CARA_ELEM': self.carael,
            'CHAM_MATER': self.cham_mater_free,
            'COMPORTEMENT': (_F(RELATION='MULTIFIBRE',
                                GROUP_MA=('CRAYON', 'T_GUIDE'),
                                PARM_THETA=0.5,
                                DEFORMATION=self._type_deformation,
                                RIGI_GEOM = self._option_rigi_geom, ),
                             _F(RELATION='DIS_GRICRA',
                                GROUP_MA='ELA',),
                             _F(RELATION='DIS_CHOC',
                                GROUP_MA=('CREIC', 'RES_TOT')),
                             _F(RELATION='ELAS',
                                GROUP_MA=('CREI','EBOINF', 'EBOSUP', 'RIG', 'DIL')),
                             _F(RELATION='VMIS_ISOT_TRAC',
                                GROUP_MA='MAINTIEN',
                                DEFORMATION='PETIT'),),
            'SUIVI_DDL':_F(NOM_CHAM='DEPL',EVAL_CHAM='MAXI_ABS',GROUP_NO='CR_BAS',NOM_CMP=('DX',)),
            'NEWTON': _F(MATRICE='TANGENTE',
                         REAC_ITER=1,),
            'CONVERGENCE' : _F(ITER_GLOB_MAXI = 10,
                               RESI_GLOB_MAXI = 1.E-2,
                               RESI_GLOB_RELA = 1.E-6),
            'SOLVEUR': _F(METHODE='MUMPS',
                          PRETRAITEMENTS='AUTO'),
            'ARCHIVAGE': _F(INST=self.coeur.temps_simu['T1'],
                            PRECISION=1.E-08),
            'AFFICHAGE': _F(INFO_RESIDU='OUI'),
            'INFO' : 1,

        }
        keywords.update(kwds)
        return keywords

    def set_from_resu(self, what, resu):
        """Extract a parameter from a result"""
        assert what in ('mesh', 'model')
        if what == "mesh":
            return resu.getModel().getMesh()
        else:
            return resu.getModel()


class Mac3CoeurDeformation(Mac3CoeurCalcul):

    """Compute the strain of the assemblies"""
    mcfact = 'DEFORMATION'

    def __init__(self, macro, args, char_init=None):
        """Initialization"""
        super().__init__(macro, args)
        self.char_init = char_init

    def _prepare_data(self,noresu):
        """Prepare the data for the calculation"""
        self.niv_fluence = self.mcf['NIVE_FLUENCE']
        if self.keyw['TYPE_COEUR'][:4] == "MONO":
            self.subdivis = 5
        self.use_archimede = self.mcf['ARCHIMEDE']
        self._maintien_grille = (self.mcf['MAINTIEN_GRILLE'] == 'OUI')
        super()._prepare_data(noresu)
    
    @property
    @cached_property
    def mesh(self):
        """Return the `maillage_sdaster` object"""
        mesh = self.keyw.get('MAILLAGE_N')
        char_init = self.char_init
        if char_init :
            resu_init=None
        else :
            resu_init = self.mcf['RESU_INIT']
        if not (mesh or resu_init or char_init):
            UTMESS('F', 'COEUR0_7')
        elif resu_init:
            if mesh:
                UTMESS('A', 'COEUR0_1')
            self.etat_init = _F(EVOL_NOLI=resu_init)
            mesh = self.set_from_resu('mesh', resu_init)
        elif char_init :
            if mesh :
                UTMESS('A', 'COEUR0_1')
            mesh = self.set_from_resu('mesh', char_init)
        else:
            mesh = super().mesh
        return mesh

    @property
    @cached_property
    def model(self):
        """Return the `modele_sdaster` object"""
        char_init = self.char_init
        if char_init :
            resu_init=None
        else :
            resu_init = self.mcf['RESU_INIT']
        if resu_init:
            model = self.set_from_resu('model', resu_init)
        elif char_init :
            model = self.set_from_resu('model', char_init)
        else:
            model = super().model
        return model

    def dechargePSC(self,RESU) :
        coeur = self.coeur
        
        CALC_CHAMP(reuse =RESU,
                   RESULTAT=RESU,
                   PRECISION=1.E-08,
                   CRITERE='RELATIF',
                   INST=coeur.temps_simu['T8'],
                   FORCE=('FORC_NODA',),)

        __SPRING=POST_RELEVE_T(ACTION=_F(INTITULE='FORCES',
                                         GROUP_NO=('PMNT_S'),
                                         RESULTAT=RESU,
                                         NOM_CHAM='FORC_NODA',
                                         NOM_CMP=('DX',),
                                         REPERE='GLOBAL',
                                         PRECISION=1.E-08,
                                         INST=coeur.temps_simu['T8'],
                                         CRITERE='RELATIF',
                                         OPERATION='EXTRACTION',),)

        tab2=__SPRING.EXTR_TABLE()
        valeurs=tab2.values()

        inst=valeurs['INST'][-1]
        fx=valeurs['DX']
        noeuds=valeurs['NOEUD']
        listarg = []
        for el in zip(fx,noeuds) :
          listarg.append(_F(NOEUD=el[1],FX=el[0]))

        assert(inst==coeur.temps_simu['T8'])

        _LI2=DEFI_FONCTION(NOM_PARA='INST',PROL_DROITE='CONSTANT',VALE=(coeur.temps_simu['T8'],1.,coeur.temps_simu['T8b'],0.),)

        _F_EMB2=AFFE_CHAR_MECA(MODELE=self.model,
                                FORCE_NODALE=listarg,)

        return (_LI2,_F_EMB2)

    def _run(self):
        """Run the main part of the calculation"""
        coeur = self.coeur
        if self.keyw['TYPE_COEUR'][:4] == "MONO":
            chmat_contact = self.cham_mater_free
        else:
            chmat_contact = self.cham_mater_contact
        constant_load = self.archimede_load + \
            self.gravity_load + self.vessel_dilatation_load + \
            self.symetric_cond
        nbRatio = 9
        # T0 - T8
        if (self.char_init) :
            __RESULT = STAT_NON_LINE(**self.snl(
                               CHAM_MATER=self.cham_mater_free,
                               INCREMENT=_F(LIST_INST=self.times,
                                            INST_INIT=0.,
                                            PRECISION=1.E-08,
                                            INST_FIN=coeur.temps_simu['T5']),
                               COMPORTEMENT=self.char_ini_comp,
                               EXCIT=constant_load + self.vessel_head_load + \
                                      self.thyc_load[0]+self.kinematic_cond,
                               ))
            constant_load = self.archimede_load + \
                self.gravity_load + self.vessel_dilatation_load_full + \
                self.symetric_cond + self.periodic_cond + self.rigid_load
            __RESULT = STAT_NON_LINE(**self.snl(
                               reuse=__RESULT,
                               RESULTAT=__RESULT,
                               CHAM_MATER=self.cham_mater_free,
                               INCREMENT=_F(LIST_INST=self.times,
                                            PRECISION=1.E-08,
                                            INST_FIN=coeur.temps_simu['T8']),
                               COMPORTEMENT=self.char_ini_comp,
                               EXCIT=constant_load + self.vessel_head_load +
                                      self.thyc_load[0],
                               ETAT_INIT=_F(EVOL_NOLI=__RESULT,
                                            PRECISION=1.E-08,
                                            CRITERE='RELATIF',),
                               ))

            (LI2,F_EMB2)=self.dechargePSC(__RESULT)

            # T8 - Tf
            __RESULT = STAT_NON_LINE(**self.snl(
                                  reuse=__RESULT,
                                  RESULTAT=__RESULT,
                                  CHAM_MATER=self.cham_mater_free,
                                  ETAT_INIT=_F(EVOL_NOLI=__RESULT,
                                               PRECISION=1.E-08,
                                               CRITERE='RELATIF',),
                                  EXCIT=constant_load+[_F(CHARGE=F_EMB2,FONC_MULT=LI2),],
                                  INCREMENT=_F(LIST_INST=self.times,
                                               PRECISION=1.E-08),
                                  COMPORTEMENT=self.char_ini_comp,
                                  ))

        else :

            constant_load += self.periodic_cond + self.rigid_load
            loads = constant_load \
                    + self.vessel_head_load \
                    + self.thyc_load[0] + self.thyc_load[1]
            keywords=[]
            mater=[]
            ratio = 1.
            mater.append(self.cham_mater_contact_progressif(ratio))

            __RESULT = None
            if (not self.etat_init) :
                __RESULT = STAT_NON_LINE(**self.snl(CHAM_MATER=self.cham_mater_free,
                                INCREMENT=_F(LIST_INST=self.times,
                                             PRECISION=1.E-08,
                                             INST_FIN=0.),
                                EXCIT=loads,
                ))
                self.etat_init = _F(EVOL_NOLI=__RESULT,
                                    PRECISION=1.E-08,
                                    CRITERE='RELATIF')

            keywords.append(self.snl(CHAM_MATER=mater[-1],
                                INCREMENT=_F(LIST_INST=self.times_woSubd,
                                             PRECISION=1.E-08,
                                             INST_FIN=coeur.temps_simu['T0b']),
                                EXCIT=loads,
                                ETAT_INIT=self.etat_init
            ))
            
            nb_test = 0
            while nb_test < nbRatio :
                try :
                    nb = len(keywords)
                    __res_int = [None]*nb
                    for i in range(nb) :
                        k = keywords[::-1][i]
                        if i>0 :
                            kwds = {
                                'NEWTON': _F(MATRICE='TANGENTE',
                                 PREDICTION='DEPL_CALCULE',
                                 EVOL_NOLI = __res_int[i-1],
                                 REAC_ITER=1,),
                                }
                            k.update(kwds)
                        __res_int[i]=STAT_NON_LINE(**k)
                    break
                except ConvergenceError:
                    ratio = ratio/10.
                    mater.append(self.cham_mater_contact_progressif(ratio))
                    keywords.append(self.snl(CHAM_MATER=mater[-1],
                                    INCREMENT=_F(LIST_INST=self.times_woSubd,
                                                 PRECISION=1.E-08,
                                                 INST_FIN=coeur.temps_simu['T0b']),
                                    EXCIT=loads,
                                    ETAT_INIT=self.etat_init
                    ))
                nb_test+=1
            else :
                raise ConvergenceError('no convergence')
            keywords = self.snl(
                                reuse=__RESULT,
                                RESULTAT=__RESULT,
                                NEWTON= _F(MATRICE='TANGENTE',
                                    PREDICTION='DEPL_CALCULE',
                                    EVOL_NOLI = __res_int[-1],
                                    REAC_ITER=1,),
                                CHAM_MATER=self.cham_mater_contact,
                                INCREMENT=_F(LIST_INST=self.times_woSubd,
                                             PRECISION=1.E-08,
                                             INST_FIN=coeur.temps_simu['T0b']),
                                EXCIT=loads,
                                ETAT_INIT=self.etat_init
                                )
            
            __RESULT = STAT_NON_LINE(**keywords)

            __RESULT = STAT_NON_LINE(**self.snl(
                                  reuse=__RESULT,
                                  RESULTAT=__RESULT,
                                  CHAM_MATER=chmat_contact,
                                  INCREMENT=_F(LIST_INST=self.times,
                                               PRECISION=1.E-08,
                                               INST_FIN=coeur.temps_simu['T8']),
                                  EXCIT=loads,
                                  ETAT_INIT=_F(EVOL_NOLI=__RESULT,
                                               PRECISION=1.E-08,
                                               CRITERE='RELATIF'),
                                  ))

            (LI2,F_EMB2)=self.dechargePSC(__RESULT)
            # T8 - Tf
            __RESULT = STAT_NON_LINE(**self.snl(
                                  reuse=__RESULT,
                                  RESULTAT=__RESULT,
                                  CHAM_MATER=chmat_contact,
                                  ETAT_INIT=_F(EVOL_NOLI=__RESULT,
                                               PRECISION=1.E-08,
                                               CRITERE='RELATIF'),
                                  EXCIT=constant_load+[_F(CHARGE=F_EMB2,FONC_MULT=LI2),],
                                  INCREMENT=_F(LIST_INST=self.times,
                                               PRECISION=1.E-08,
                                               INST_FIN=coeur.temps_simu['T8b']),
                                  ))

            keywords=[]
            mater=[]
            ratio = 1.e-8
            mater.append(self.cham_mater_contact_progressif(ratio))
            keywords.append(self.snl(CHAM_MATER=mater[-1],
                                INCREMENT=_F(LIST_INST=self.times_woSubd,
                                             PRECISION=1.E-08),
                                EXCIT=constant_load,
                                ETAT_INIT=_F(EVOL_NOLI=__RESULT,
                                             PRECISION=1.E-08,
                                             CRITERE='RELATIF'),
                               ))
            nb_test = 0
            while nb_test < nbRatio :
                try :
                    nb = len(keywords)
                    __res_int = [None]*nb
                    for i in range(nb) :
                        k = keywords[::-1][i]
                        if i>0 :
                            kwds = {
                                'NEWTON': _F(MATRICE='TANGENTE',
                                 PREDICTION='DEPL_CALCULE',
                                 EVOL_NOLI = __res_int[i-1],
                                 REAC_ITER=1,),
                                }
                            k.update(kwds)
                        __res_int[i]=STAT_NON_LINE(**k)
                    break
                except ConvergenceError:
                    ratio = ratio*10.
                    mater.append(self.cham_mater_contact_progressif(ratio))
                    keywords.append(self.snl(CHAM_MATER=mater[-1],
                                    INCREMENT=_F(LIST_INST=self.times_woSubd,
                                                 PRECISION=1.E-08,),
                                    EXCIT=constant_load,
                                    ETAT_INIT=_F(EVOL_NOLI=__RESULT,
                                                 PRECISION=1.E-08,
                                                 CRITERE='RELATIF'),
                                   ))
                nb_test+=1
            else :
                raise ConvergenceError('no convergence')
            keywords = self.snl(reuse = __RESULT,
                                RESULTAT=__RESULT,
                                NEWTON= _F(MATRICE='TANGENTE',
                                    PREDICTION='DEPL_CALCULE',
                                    EVOL_NOLI = __res_int[-1],
                                    REAC_ITER=1,),
                                CHAM_MATER=self.cham_mater_free,
                                INCREMENT=_F(LIST_INST=self.times_woSubd,
                                             PRECISION=1.E-08,),
                                EXCIT=constant_load,
                                ETAT_INIT=_F(EVOL_NOLI=__RESULT,
                                             PRECISION=1.E-08,
                                             CRITERE='RELATIF'),
                                )
            __RESULT = STAT_NON_LINE(**keywords)
        return __RESULT

class Mac3CoeurLame(Mac3CoeurCalcul):

    """Compute the thinkness of water from deformed assemblies"""
    mcfact = 'LAME'

    def _init_properties(self):
        """Initialize all the cached properties to NULL"""
        super()._init_properties()
        self._layer_load = NULL
        self._lame = True

    @property
    @cached_property
    def layer_load(self):
        """Return the loading due to the displacements of the water layer"""
        return [_F(CHARGE=self.coeur.affe_char_lame(self.model)), ]

    def update_coeur(self, resu, table):
        """Update the `Coeur` object from the given `Table` and result"""
        self._init_properties()
        self.mesh = self.set_from_resu('mesh', resu)
        self.model = self.set_from_resu('model', resu)
        if self.keyw['TYPE_COEUR'][:5] == 'LIGNE' :
            self.coeur = _build_coeur(self.keyw['TYPE_COEUR'], self.macro, table,self.keyw['NB_ASSEMBLAGE'])
        else :
            self.coeur = _build_coeur(self.keyw['TYPE_COEUR'], self.macro, table)
        # initializations
        self.coeur.recuperation_donnees_geom(self.mesh)
        self.times

    def deform_mesh_inverse(self, depl):
        """Use the displacement of the result to deform the mesh"""
        _depl_inv = CREA_CHAMP(OPERATION='COMB',
                          TYPE_CHAM='NOEU_DEPL_R',
                          COMB=_F(CHAM_GD=depl,COEF_R=-1.))

        _mesh = MODI_MAILLAGE(reuse=self.mesh,
                              MAILLAGE=self.mesh,
                              DEFORME=_F(OPTION='TRAN',
                                         DEPL=_depl_inv))
        del self.mesh
        self.mesh = _mesh

    def deform_mesh(self, resu):
        """Use the displacement of the result to deform the mesh"""
        _depl = CREA_CHAMP(OPERATION='EXTR',
                           INST = self.coeur.temps_simu['T1'],
                           PRECISION=1.E-08,
                           TYPE_CHAM='NOEU_DEPL_R',
                           NOM_CHAM='DEPL',
                           RESULTAT=resu)
        _mesh = MODI_MAILLAGE(reuse=self.mesh,
                              MAILLAGE=self.mesh,
                              DEFORME=_F(OPTION='TRAN',
                                         DEPL=_depl))
        del self.mesh
        self.mesh = _mesh
        return _depl

    def extrChamp(self,resu,inst) :

        _depl = CREA_CHAMP(OPERATION='EXTR',
                           TYPE_CHAM='NOEU_DEPL_R',
                           NOM_CHAM='DEPL',
                           INST=inst,
                           PRECISION=1.E-08,
                           RESULTAT=resu)
        return _depl

    def asseChamp(self,depl1,depl2) :

        _depl = CREA_CHAMP(TYPE_CHAM = 'NOEU_DEPL_R',
                   OPERATION = 'ASSE',
                   MODELE    = self.model,
                   ASSE = (_F(TOUT='OUI',CHAM_GD = depl1,NOM_CMP=('DY','DZ'),CUMUL = 'NON',),
                           _F(TOUT='OUI',CHAM_GD = depl2,NOM_CMP=('DY','DZ'),CUMUL = 'OUI',),
                           _F(TOUT='OUI',CHAM_GD = depl2,NOM_CMP=('DX',),CUMUL = 'NON',COEF_R=0.0),
                           ),)

        return _depl

    def cr(self,inst,cham_gd,reuse=None) :
        """Return the common keywords for CREA_RESU """
        keywords = {
            'OPERATION' : 'AFFE',
            'TYPE_RESU' : 'EVOL_NOLI',
            'NOM_CHAM'  : 'DEPL',
            'AFFE': (_F(CHAM_GD = cham_gd,
                        INST    = inst,
                        PRECISION=1.E-08,
                        MODELE  = self.model))
                   }
        if reuse :
            keywords['reuse'] = reuse
            keywords['RESULTAT'] = reuse
        return keywords


    def output_resdef(self,resu,depl_deformed,tinit,tfin) :
        """save the result to be used by a next calculation"""
        _pdt_ini = self.coeur.temps_simu['T1']
        _pdt_fin = self.coeur.temps_simu['T4']

        if ((not tinit) and (not tfin)) :
            _pdt_ini_out = _pdt_ini
            _pdt_fin_out = _pdt_fin
        else :
            _pdt_ini_out = tinit
            _pdt_fin_out = tfin


        depl_ini = self.extrChamp(resu,_pdt_ini)
        depl_fin = self.extrChamp(resu,_pdt_fin)

        depl_tot_ini = self.asseChamp(depl_deformed,depl_ini)
        depl_tot_fin = self.asseChamp(depl_deformed,depl_fin)

        self.deform_mesh_inverse(depl_deformed)

        self.res_def = CREA_RESU(**self.cr(_pdt_ini_out,depl_tot_ini))
        self.res_def = CREA_RESU(reuse=self.res_def,
                                 **self.cr(_pdt_fin_out,depl_tot_fin))
        if self.res_def_keyw:
            self.macro.register_result(self.res_def, self.res_def_keyw)

    def _prepare_data(self, noresu=None):
        """Prepare the data for the calculation"""
        self.use_archimede = 'OUI'
        self._maintien_grille = False
        if not noresu:
            self.res_def_keyw = self.keyw.get('RESU_DEF')
            if self.res_def_keyw:
                self.calc_res_def = True
        super()._prepare_data(noresu)

    def _run(self,tinit=None,tfin=None):
        """Run the main part of the calculation"""
        coeur = self.coeur
        # calcul de deformation d'apres DAMAC / T0 - T1
        _snl_lame = STAT_NON_LINE(**self.snl_lame(
                                  INCREMENT=_F(LIST_INST=self.times,
                                               INST_INIT=0.,
                                               PRECISION=1.E-08,
                                               INST_FIN=coeur.temps_simu['T1']),
                                  EXCIT=self.archimede_load + self.vessel_head_load +
                                  self.vessel_dilatation_load + self.gravity_load +
                                  self.layer_load + self.periodic_cond,
                                  ))
        self.update_coeur(_snl_lame, self.keyw['TABLE_N'])
        # WARNING: element characteristics and the most of the loadings must be
        # computed on the initial (not deformed) meshhg st
        # please keep the call to deform_mesh after the computation of keywords
        keywords=[]
        keywords.append(self.snl_lame(CHAM_MATER=self.cham_mater_free,
                            INCREMENT=_F(LIST_INST=self.times,
                                         PRECISION=1.E-08,
                                         INST_FIN=0.),
                            EXCIT=self.rigid_load + self.archimede_load +
                            self.vessel_head_load +
                            self.vessel_dilatation_load +
                            self.gravity_load +
                            self.symetric_cond + self.periodic_cond +
                            self.thyc_load[0] + self.thyc_load[1],
                           ))
        #on fait l'irradiation historique sur assemblages droits
        __RESULT = STAT_NON_LINE(**keywords[-1])
        #on deforme le maillage
        depl_deformed = self.deform_mesh(_snl_lame)
        mater=[]
        ratio = 1.
        mater.append(self.cham_mater_contact_progressif(ratio))
        kwds = {    'CHAM_MATER' : mater[-1],
                    'ETAT_INIT' : _F(EVOL_NOLI=__RESULT,
                                     PRECISION=1.E-08,
                                     CRITERE='RELATIF'),
                    'INCREMENT' : _F(LIST_INST=self.times_woSubd,
                                     PRECISION=1.E-08,
                                     INST_FIN=coeur.temps_simu['T0b']),

            }
        keywords[-1].update(kwds)
        nb_test = 0
        while nb_test < 5 :
            try :
                nb = len(keywords)
                __res_int = [None]*nb
                for i in range(nb) :
                    k = keywords[::-1][i]
                    if i>0 :
                        kwds = {
                            'NEWTON': _F(MATRICE='TANGENTE',
                             PREDICTION='DEPL_CALCULE',
                             EVOL_NOLI = __res_int[i-1],
                             REAC_ITER=1,),
                            }
                        k.update(kwds)
                    # if i == nb-1 :
                    #     __RESULT = STAT_NON_LINE(**k)
                    # else :
                    __res_int[i]=STAT_NON_LINE(**k)
                break
            except ConvergenceError:
                ratio = ratio/10.
                mater.append(self.cham_mater_contact_progressif(ratio))
                keywords.append(self.snl_lame(CHAM_MATER=mater[-1],
                                INCREMENT=_F(LIST_INST=self.times_woSubd,
                                             PRECISION=1.E-08,
                                             INST_FIN=coeur.temps_simu['T0b']),
                                ETAT_INIT=_F(EVOL_NOLI=__RESULT,
                                             PRECISION=1.E-08,
                                             CRITERE='RELATIF'),
                                EXCIT=self.rigid_load + self.archimede_load +
                                self.vessel_head_load +
                                self.vessel_dilatation_load +
                                self.gravity_load +
                                self.symetric_cond + self.periodic_cond +
                                self.thyc_load[0] + self.thyc_load[1],
                               ))
            nb_test+=1
        else :
            raise  ConvergenceError('no convergence')


        keywords = self.snl_lame(
                            reuse = __RESULT,
                            RESULTAT=__RESULT,
                            ETAT_INIT=_F(EVOL_NOLI=__RESULT,
                                         PRECISION=1.E-08,
                                         CRITERE='RELATIF'),
                            NEWTON= _F(MATRICE='TANGENTE',
                                PREDICTION='DEPL_CALCULE',
                                EVOL_NOLI = __res_int[-1],
                                REAC_ITER=1,),
                            CHAM_MATER=self.cham_mater_contact,
                            INCREMENT=_F(LIST_INST=self.times_woSubd,
                                         PRECISION=1.E-08,
                                         INST_FIN=coeur.temps_simu['T0b']),
                            EXCIT=self.rigid_load + self.archimede_load +
                            self.vessel_head_load +
                            self.vessel_dilatation_load +
                            self.gravity_load +
                            self.symetric_cond + self.periodic_cond +
                            self.thyc_load[0] + self.thyc_load[1],
                            )
        __RESULT = STAT_NON_LINE(**keywords)
        keywords = self.snl_lame(
                            reuse = __RESULT,
                            RESULTAT=__RESULT,
                            ETAT_INIT=_F(EVOL_NOLI=__RESULT,
                                         PRECISION=1.E-08,
                                         CRITERE='RELATIF'),
                            CHAM_MATER=self.cham_mater_contact,
                            INCREMENT=_F(LIST_INST=self.times,
                                         PRECISION=1.E-08,
                                         INST_FIN=coeur.temps_simu['T4']),
                            EXCIT=self.rigid_load + self.archimede_load +
                            self.vessel_head_load +
                            self.vessel_dilatation_load +
                            self.gravity_load +
                            self.symetric_cond + self.periodic_cond +
                            self.thyc_load[0] + self.thyc_load[1],
                            )
        __RESULT = STAT_NON_LINE(**keywords)

        if self.calc_res_def:
            self.output_resdef(__RESULT,depl_deformed,tinit,tfin)
        return __RESULT

class Mac3CoeurEtatInitial(Mac3CoeurLame):

    """Compute Initial State"""
    mcfact = 'LAME'

    def __init__(self,macro,args) :
        """Initialization"""
        self.args_lame={}
        self.args_defo={}
        for el in args :
            if el == 'ETAT_INITIAL' :
                self.args_lame['LAME']=args[el]
                self.args_defo['DEFORMATION']=args[el]
            else :
                if (el not in ['LAME','DEFORMATION']) :
                    self.args_lame[el] = args[el]
                    self.args_defo[el] = args[el]
        super().__init__(macro, self.args_lame)
        self.calc_res_def = True

    def _prepare_data(self,noresu):
        """Prepare the data for the calculation"""
        self.niv_fluence = self.mcf['NIVE_FLUENCE']
        assert self.keyw['TYPE_COEUR'][:4] != "MONO"
        super()._prepare_data(noresu)

    def _run(self,tinit=None,tfin=None):
        tinit = self.coeur.temps_simu['T0']
        tfin  = self.coeur.temps_simu['T5']
        print('T0 = %f , T5 = %f'%(tinit,tfin))
        return super()._run(tinit,tfin)


    def run(self):
        super().run(noresu=True)
        self.defo = Mac3CoeurDeformation(self.macro, self.args_defo, self.res_def)
        return self.defo.run()


# helper functions
def _build_coeur(typ_coeur, macro, sdtab,longueur=None):
    """Return a `Coeur` object of the given type"""
    rcdir = ExecutionParameter().get_option("rcdir")
    datg = osp.join(rcdir, "datg")
    factory = CoeurFactory(datg)
    # prepare the Table object
    tab = sdtab.EXTR_TABLE()
    name = tab.para[0]
    tab.Renomme(name, 'idAC')
    coeur = factory.get(typ_coeur)(name, typ_coeur, macro, datg, longueur)
    coeur.init_from_table(tab)
    return coeur


def read_thyc(coeur, model, unit):
    """Read a file containing THYC results"""
    res = None
    try:
        UL = UniteAster()
        fname = UL.Nom(unit)
        res = lire_resu_thyc(coeur, model, fname)
    finally:
        pass
    return res
