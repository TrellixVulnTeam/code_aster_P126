# coding=utf-8
# --------------------------------------------------------------------
# Copyright (C) 1991 - 2018 - EDF R&D - www.code-aster.org
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

# person_in_charge: mathieu.courtois at edf.fr

"""
:py:mod:`ExecutionParameter` --- Management of the execution parameters
***********************************************************************

A singleton object :py:class:`.ExecutionParameter` is created during the
initialization. Its main feature is to parse and store the arguments read from
the command line or passed to the :py:func:`~code_aster.Commands.debut.init`
function.
It also stores Python objects that have to be available from :py:mod:`libaster`.
They will be available though properties of the :py:class:`.ExecutionParameter`
object.

"""

import json
import logging
import os
import os.path as osp
import platform
import re
import sys
import warnings

import aster_pkginfo
from Utilitai.as_timer import ASTER_TIMER

from ..Utilities import Singleton, convert
from .logger import logger, setlevel
from .options import Options


class ExecutionParameter(object):
    """This class stores and provides the execution parameters.

    The execution parameters are defined by reading the command line or using
    the method `set_option()`.

    Attributes:
        _args (dict): Command line arguments and execution parameters.
        _bool (int): Bitwise combination of boolean parameters.
        _catalc (*CataLoiComportement*): Object that gives access to the
            catalog of behaviors.
        _unit (*LogicalUnitFile*): Class that manages the logical units.
        _syntax (*CommandSyntax*): Class that passes user keywords up to
            Fortran operator.
    """
    __metaclass__ = Singleton
    _singleton_id = 'Supervis.ExecutionParameter'
    _args = _bool = None
    _timer = _command_counter = None
    _catalc = _unit = _syntax = None

    def __init__(self):
        """Initialization of attributes"""
        self._args = {}
        # options also used in F90
        self._args['dbgjeveux'] = 0
        self._args['jxveri'] = 0
        self._args['sdveri'] = 0
        self._args['impr_macro'] = 0
        self._args['icode'] = 0
        self._args['jeveux_sysaddr'] = 0

        self._args['memory'] = 0.
        self._args['tpmax'] = 0.
        self._args['maxbase'] = 0.
        self._args['numthreads'] = 0

        self._args['stage_number'] = 0

        # boolean (on/off) options
        self._bool = Options.Null

        # TODO probably to be removed?
        self._args['repmat'] = '.'
        self._args['repdex'] = '.'

        self._computed()

    def _computed(self):
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

        self._timer = ASTER_TIMER(format="aster")
        self._command_counter = 0

    def set_option(self, option, value):
        """Set the value of an execution parameter.

        Arguments:
            option (str): Name of the parameter.
            value (misc): Parameter value.
        """
        # Options must at least be declared by __init__
        if option in self._args:
            self._args[option] = value
        else:
            if value:
                self.enable(Options.by_name(option))
            else:
                self.disable(Options.by_name(option))

    def get_option(self, option):
        """Return the value of an execution parameter. If the *option* is
        unknown, it returns *None*.

        Arguments:
            option (str): Name of the parameter.

        Returns:
            misc: Parameter value.
        """
        logger.debug("get_option {0!r}".format(option))
        if option.startswith("prog:"):
            value = get_program_path(re.sub('^prog:', '', option))
        elif option in self._args:
            value = self._args[option]
        else:
            try:
                value = self.option & Options.by_name(option)
            except AttributeError:
                value = None
        if isinstance(value, (str, unicode)):
            value = convert(value)
        logger.debug("return for {0!r}: {1} {2}"
                     .format(option, value, type(value)))
        return value

    def enable(self, option):
        """Enable a boolean option.

        Arguments:
            option (int): An 'Options' value.
        """
        self._bool |= option

        # for options that required an action
        if option == Options.Debug:
            setlevel()
        elif option == Options.ShowDeprecated:
            # disabled by default in python2.7
            warnings.simplefilter('default')

    def disable(self, option):
        """Disable a boolean option.

        Arguments:
            option (int): An 'Options' value.
        """
        self._bool = (self._bool | option) ^ option

        # for options that required an action
        if option == Options.Debug:
            setlevel(level=logging.INFO)
        elif option == Options.ShowDeprecated:
            warnings.resetwarnings()

    @property
    def option(self):
        """Attribute that holds the boolean options.

        Returns:
            int: Bitwise combination of boolean execution parameters.
        """
        return self._bool

    @property
    def timer(self):
        """Attribute that holds the timer object.

        Returns:
            ASTER_TIMER: Timer object.
        """
        return self._timer

    def parse_args(self, argv=None):
        """Parse the command line arguments to set the execution parameters"""
        from argparse import ArgumentParser
        # command arguments parser
        parser = ArgumentParser(description='execute a Code_Aster study',
                                prog="Code_Aster{called by Python}")
        parser.add_argument('-g', '--debug', dest='Debug',
            action='store_const', const=1, default=0,
            help="add debug informations")

        parser.add_argument('--abort', dest='Abort',
            action='store_const', const=1, default=0,
            help="abort execution in case of error (testcase mode, by default "
                 "raise an exception)")

        parser.add_argument('--dbgjeveux',
            action='store_const', const=1, default=0,
            help="turn on some additional checkings in the memory management")

        parser.add_argument('--jxveri',
            action='store_const', const=1, default=0,
            help="")
        parser.add_argument('--sdveri',
            action='store_const', const=1, default=0,
            help="")
        parser.add_argument('--impr_macro',
            action='store_const', const=1, default=0,
            help="")
        parser.add_argument('--icode',
            action='store_const', const=1, default=0,
            help="turn on running mode for testcase")

        parser.add_argument('--memory',
            action='store', type=float, default=2047,
            help="memory limit in MB used for code_aster objects "
                 "(default: 2047 MB)")
        parser.add_argument('--tpmax',
            action='store', type=float, default=86400,
            help="time limit of the execution in seconds (default: 1 day)")
        parser.add_argument('--maxbase',
            action='store', type=float, default=48000,
            help="size limit in MB for code_aster out-of-core files (glob.*, "
              "default: 48 GB)")
        parser.add_argument('--numthreads',
            action='store', type=int, default=1,
            help="maximum number of threads")

        parser.add_argument('--rep_mat', dest='repmat',
            action='store', metavar='DIR', default='.',
            help="directory of materials properties")
        parser.add_argument('--rep_dex', dest='repdex',
            action='store', metavar='DIR', default='.',
            help="directory of external datas (geometrical datas or properties...)")

        parser.add_argument('--stage_number',
            action='store', type=int, default=1, metavar='NUM',
            help="Stage number in the Study")
        parser.add_argument('--continue', dest='Continue',
            action='store_const', const=1, default=0,
            help="turn on to continue a previous execution")
        parser.add_argument('--use_legacy_mode', dest='UseLegacyMode',
            action='store', default=1,
            help="use (=1) or not (=0) the legacy mode for macro-commands "
                 "results. (default: 1)")
        parser.add_argument('--deprecated', dest='ShowDeprecated',
            action='store_const', const=1, default=0,
            help="turn on deprecation warnings")

        args, ignored = parser.parse_known_args(argv or sys.argv)

        logger.debug("Ignored arguments: %r", ignored)
        logger.debug("Read options: %r", vars(args))

        # assign parameter values
        for opt, value in vars(args).items():
            self.set_option(opt, value)

    def sub_tpmax(self, tsub):
        """Reduce the cpu time limit of `tsub`."""
        self.set_option('tpmax', self.get_option('tpmax') - tsub)

    def incr_command_counter(self):
        """Increment the counter of Commands.

        Returns:
            int: Current value of the counter.
        """
        self._command_counter += 1
        return self._command_counter

    # register objects callable from libaster
    @property
    def catalc(self):
        """Attribute that holds the catalog of behavior."""
        return self._catalc

    @catalc.setter
    def catalc(self, catalc):
        """Setter of `_catalc`."""
        self._catalc = catalc

    @property
    def logical_unit(self):
        """Attribute that holds the logical units manager."""
        return self._unit

    @logical_unit.setter
    def logical_unit(self, klass):
        """Setter of `_unit`."""
        self._unit = klass

    @property
    def syntax(self):
        """Attribute that holds the command syntax class."""
        return self._syntax

    @syntax.setter
    def syntax(self, klass):
        """Setter of `_syntax`."""
        self._syntax = klass


def get_program_path(program):
    """Return the path to *program* as stored by 'waf configure'.

    Returns:
        str: Path stored during configuration or *program* itself otherwise.
    """
    if getattr(get_program_path, "_cache", None) is None:
        prog_cfg = {}
        fname = osp.join(os.environ["ASTER_DATADIR"], "external_programs.js")
        if osp.isfile(fname):
            prog_cfg = json.load(open(fname, "rb"))
        get_program_path._cache = prog_cfg

    programs = get_program_path._cache
    return programs.get(program, program)
