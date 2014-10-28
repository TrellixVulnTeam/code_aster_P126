# coding: utf-8

"""
Configuration for ivanoe

. $HOME/dev/codeaster/devtools/etc/env_unstable.sh

waf configure --use-config=ivanoe --prefix=../install/std
waf install -p -j 8
"""

import os
ASTER_ROOT = os.environ['ASTER_ROOT']
YAMMROOT = ASTER_ROOT + '/yamm/V7_3_0_201402'

import intel

def configure(self):
    opts = self.options

    intel.configure(self)

    self.env.append_value('CFLAGS_ASTER_DEBUG', ['-D__DEBUG_ALL__'])
    self.env.append_value('FCFLAGS_ASTER_DEBUG', ['-D__DEBUG_ALL__'])
    self.env['ADDMEM'] = 280
    self.env.append_value('OPT_ENV', [
        '. ' + ASTER_ROOT + '/etc/codeaster/profile.sh',
        '. ' + ASTER_ROOT + '/etc/codeaster/profile_intel.sh',
        '. ' + ASTER_ROOT + '/etc/codeaster/profile_zmat.sh'])

    self.env.append_value('LIBPATH', [
        '/usr/lib/atlas-base/atlas',                # for NumPy, see issue18751
        YAMMROOT + '/prerequisites/Python_273/lib',
        YAMMROOT + '/prerequisites/Hdf5_1810/lib',
        YAMMROOT + '/tools/Medfichier_307/lib',
        YAMMROOT + '/prerequisites/Mumps_20141/lib',
        YAMMROOT + '/prerequisites/Mumps_20141/libseq',
        YAMMROOT + '/prerequisites/Metis_40/lib',
        YAMMROOT + '/prerequisites/Scotch_5111/lib'])

    self.env.append_value('INCLUDES', [
        YAMMROOT + '/prerequisites/Python_273/include/python2.7',
        YAMMROOT + '/prerequisites/Hdf5_1810/include',
        YAMMROOT + '/tools/Medfichier_307/include',
        YAMMROOT + '/prerequisites/Metis_40/Lib',
        YAMMROOT + '/prerequisites/Scotch_5111/include'])

    # to fail if not found
    opts.enable_hdf5 = True
    opts.enable_med = True
    opts.enable_metis = True
    opts.enable_mumps = True
    opts.enable_scotch = True

    opts.enable_petsc = False
    opts.enable_mfront = False
