# coding=utf-8
# --------------------------------------------------------------------
# Copyright (C) 1991 - 2017 - EDF R&D - www.code-aster.org
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

# person_in_charge: mathieu.courtois@edf.fr
"""
:py:class:`DEBUT` --- Initialization of code_aster
**************************************************

The :py:class:`Starter` starts the execution by initializing the code_aster
memory manager (*Jeveux*). For this task, it parses the arguments through the
:py:class:`~code_aster.Supervis.ExecutionParameter.ExecutionParameter` object.
By default, arguments are read from the command line. Otherwise, the arguments
can be passed to :py:func:`.init`.

Some Python objects that have to be available from :py:mod:`libaster` are
passed during the initialization to the
:py:class:`~code_aster.Supervis.ExecutionParameter.ExecutionParameter`.
"""

import aster
import aster_core
from Comportement import catalc

from ..RunManager import LogicalUnitFile, Serializer, loadObjects
from ..Supervis import CommandSyntax, ExecutionParameter, logger
from ..Supervis.logger import setlevel

from .ExecuteCommand import ExecuteCommand


class ExecutionStarter(object):
    """Initialize the
    :class:`~code_aster.Supervis.ExecutionParameter.ExecutionParameter` object
    for requests from the both sides Python/Fortran."""
    params = _is_initialized = None

    @classmethod
    def init(cls, argv):
        """Initialization of class attributes.

        Attributes:
            argv (list[str]): List of command line arguments.

        Returns:
            bool: *True* if the initialization has been done, *False* if the
            execution was already initialized.
        """
        if cls._is_initialized:
            return False
        cls.params = ExecutionParameter()
        cls.params.parse_args(argv)
        cls.params.catalc = catalc
        cls.params.logical_unit = LogicalUnitFile
        cls.params.syntax = CommandSyntax
        aster_core.register(cls.params)
        aster.init(0)
        if cls.params.get_option('abort'):
            aster.onFatalError('ABORT')
        cls._is_initialized = True
        return True


class Starter(ExecuteCommand):
    """Define the command DEBUT."""
    command_name = "DEBUT"
    restart = False

    @classmethod
    def run(cls, **keywords):
        """Run the Command.

        Arguments:
            keywords (dict): User keywords
        """
        if not ExecutionStarter.init(None):
            return

        super(Starter, cls).run(**keywords)

    @classmethod
    def run_with_argv(cls, **keywords):
        """Run the macro-command with the arguments from the command line.

        Arguments:
            keywords (dict): User keywords
        """
        cmd = cls()
        cmd._result = None
        cmd.exec_(keywords)

    def _call_oper(self, syntax):
        """Call fortran operator.

        Arguments:
            syntax (*CommandSyntax*): Syntax description with user keywords.
        """
        logger.info("starting the execution...")
        aster.debut(syntax)


class Restarter(Starter):
    """Define the command POURSUITE."""
    command_name = "POURSUITE"
    restart = True

    def _call_oper(self, syntax):
        """Call fortran operator.

        Arguments:
            syntax (*CommandSyntax*): Syntax description with user keywords.
        """
        if not Serializer.canRestart():
            ExecutionStarter.params.set_option("continue", 0)
            super(Restarter, self)._call_oper(syntax)
        else:
            logger.info("restarting from a previous execution...")
            aster.poursu(syntax)
            # 1:_call_oper, 2:exec_, 3:Restarter.run, 4:ExecuteCmd.run, 5:user
            # 1:_call_oper, 2:exec_, 3:run_with_argv, 4:init, 5:user
            loadObjects(level=5)


DEBUT = Starter.run
POURSUITE = Restarter.run


def init(*argv, **kwargs):
    """Initialize code_aster as `DEBUT`/`POURSUITE` command does + command
    line options.

    Arguments:
        argv (list): List of command line arguments.
    """
    if not ExecutionStarter.init(argv):
        return

    if 'debug' in kwargs:
        if kwargs['debug']:
            setlevel()
        del kwargs['debug']

    if ExecutionStarter.params.get_option("continue"):
        Restarter.run_with_argv(**kwargs)
    else:
        Starter.run_with_argv(**kwargs)
