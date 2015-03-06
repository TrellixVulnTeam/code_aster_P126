# coding: utf-8

# Copyright (C) 1991 - 2015  EDF R&D                www.code-aster.org
#
# This file is part of Code_Aster.
#
# Code_Aster is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# Code_Aster is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Code_Aster.  If not, see <http://www.gnu.org/licenses/>.

import sys
import re
import platform

import aster_pkginfo

from code_aster.Supervis.libBaseUtils import debug, to_cstr
from code_aster.Supervis.libBaseUtils cimport copyToFStr


class ExecutionParameter:

    """This class stores and provides the execution parameters.
    The execution parameters are read from the command line or using
    the method `set()`.
    """

    def __init__( self ):
        """Initialization of attributes"""
        self._args = {}
        self._args['suivi_batch'] = 0
        self._args['dbgjeveux'] = 0

        self._args['memory'] = 1000.
        self._args['maxbase'] = 1000.
        self._args['tpmax'] = 86400

        self._args['repdex'] = '.'
        self._computed()
        self._on_command_line()

    def _computed( self ):
        """Fill some "computed" values"""
        # hostname
        self._args['hostname'] = platform.node()
        # ex. i686/x86_64
        self._args['processor'] = platform.machine()
        # ex. Linux
        self._args['system'] = platform.system()
        # ex. 32bit/64bit
        self._args['architecture'] = platform.architecture()[0]
        # ex. 2.6.32...
        self._args['osrelease'] = platform.release()
        self._args['osname'] = ' '.join(platform.linux_distribution())
        version = aster_pkginfo.version_info.version
        self._args['versionSTA'] = None
        self._args['versLabel'] = None
        keys = ('parentid', 'branch', 'date',
                'from_branch', 'changes', 'uncommitted')
        self._args.update(zip(keys, aster_pkginfo.version_info[1:]))
        self._args['version'] = '.'.join(str(i) for i in version)
        self._args['versMAJ'] = version[0]
        self._args['versMIN'] = version[1]
        self._args['versSUB'] = version[2]
        self._args['exploit'] = aster_pkginfo.version_info.branch.startswith('v')
        self._args['versionD0'] = '%d.%02d.%02d' % version
        self._args['versLabel'] = aster_pkginfo.get_version_desc()

    def _on_command_line(self):
        """Initialize parameters that can be changed by the command line"""
        self._args['buildelem'] = 0
        self._args['autostart'] = 1

    def set( self, argName, argValue ):
        """Set the value of an execution parameter"""
        self._args[argName] = argValue

    def get( self, argName ):
        """Return the value of an execution parameter
        @param argName Argument de la ligne de commande demande
        @return Entier relu
        """
        return self._args.get( argName, None )

    def parse_args( self, argv=None ):
        """Parse the command line arguments to set the execution parameters"""
        from argparse import ArgumentParser
        # command arguments parser
        parser = ArgumentParser(description='execute a Code_Aster study',
                                prog="Code_Aster{called by Python}")
        parser.add_argument('--build-elem', dest='buildelem', action='store_true',
            default=False,
            help="enable specific starting mode to build the elements database")
        parser.add_argument('--start', dest='autostart',
            action='store_true', default=True,
            help="automatically start the memory manager")
        parser.add_argument('--no-start', dest='autostart',
            action='store_false',
            help="turn off the automatic start of the memory manager")

        args, ignored = parser.parse_known_args( argv or sys.argv )
        debug( "Ignored arguments:", ignored )
        # assign parameter values
        self.set( 'buildelem', int(args.buildelem) )
        self.set( 'autostart', int(args.autostart) )


# global instance
executionParameter = ExecutionParameter()

def setExecutionParameter( argName, argValue ):
    """Static function to set parameters from the user command file"""
    global executionParameter
    executionParameter.set( argName, argValue)

cdef public long getParameterLong( char* argName ):
    """Request the value of an execution parameter of type 'int'"""
    global executionParameter
    value = executionParameter.get( argName ) or 0
    debug( 'gtopti( {} ): {}'.format( argName, value ) )
    return value

cdef public double getParameterDouble( char* argName ):
    """Request the value of an execution parameter of type 'double'"""
    global executionParameter
    value = executionParameter.get( argName ) or 0.
    debug( 'gtoptr( {} ): {}'.format( argName, value ) )
    return value

cdef public void gtoptk_( char* argName, char* valk, long* iret,
                          unsigned int larg, unsigned int lvalk ):
    """Request the value of an execution parameter of type 'string'"""
    global executionParameter
    arg = to_cstr( argName, larg )
    value = executionParameter.get( arg )
    if value is None:
        iret[0] = 4
    else:
        copyToFStr( valk, value, lvalk )
        iret[0] = 0
    debug( 'gtoptk( {} ): {}, iret {}'.format( arg, value, iret[0] ) )
