# coding: utf-8

"""
Configuration for aster5

. $HOME/dev/codeaster/devtools/etc/env_unstable.sh

waf configure --use-config=aster5 --prefix=../install/std
waf install -p
"""

import os
ASTER_ROOT = os.environ['ASTER_ROOT']
YAMMROOT = ASTER_ROOT + '/public/default'

import intel

def configure(self):
    opts = self.options

    intel.configure(self)

    # enable TEST_STRICT on the reference server
    self.env.append_value('DEFINES', ['TEST_STRICT'])

    self.env['ADDMEM'] = 600
    self.env.append_value('OPT_ENV', [
        '. /etc/profile.d/lmod.sh',
        'module loadifort/2016.0.047 icc/2016.0.047 mkl/2016.0.047'])

    TFELHOME = YAMMROOT + '/prerequisites/Mfront-TFEL300'
    self.env.TFELHOME = TFELHOME

    self.env.append_value('LIBPATH', [
        YAMMROOT + '/prerequisites/Hdf5-1814/lib',
        YAMMROOT + '/tools/Medfichier-321/lib',
        YAMMROOT + '/prerequisites/Metis_aster-510_aster1/lib',
        YAMMROOT + '/prerequisites/Scotch_aster-604_aster6/SEQ/lib',
        YAMMROOT + '/prerequisites/Mumps-511_consortium_aster/SEQ/lib',
        TFELHOME + '/lib',
    ])

    self.env.append_value('INCLUDES', [
        YAMMROOT + '/prerequisites/Hdf5-1814/include',
        YAMMROOT + '/tools/Medfichier-321/include',
        YAMMROOT + '/prerequisites/Metis_aster-510_aster1/include',
        YAMMROOT + '/prerequisites/Scotch_aster-604_aster6/SEQ/include',
        YAMMROOT + '/prerequisites/Mumps-511_consortium_aster/SEQ/include',
        YAMMROOT + '/prerequisites/Mumps-511_consortium_aster/SEQ/include_seq',
        TFELHOME + '/include',
    ])

    self.env.append_value('LIB', ('pthread', 'util'))
    self.env.append_value('LIB_SCOTCH', ('scotcherrexit'))
    # to fail if not found
    opts.enable_hdf5 = True
    opts.enable_med = True
    opts.enable_metis = True
    opts.enable_mumps = True
    opts.enable_scotch = True
    opts.enable_mfront = True

    opts.enable_petsc = False
