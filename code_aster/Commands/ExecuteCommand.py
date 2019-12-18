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

"""
This module defines the objects on which the user's Commands are based.

All Commands executors are subclasses of :class:`.ExecuteCommand`.
Commands are factories (:meth:`ExecuteCommand.run` *classmethod*) that
create an executor that is called to create a result object.

When a new command is added there are different levels of complexity:

- Commands that are automatically added just using their catalog.
  Only the commands that return no result can work with this method.
  Other commands will raise a *NotImplementedError* exception at runtime.
  Macro-commands do not need a specific executor. Their catalog and ``ops()``
  function is sufficient.

  .. note:: All Commands that are not explicitly imported by
    :mod:`code_aster.Commands.__init__` are automatically created using this
    method.

- Commands where the Fortran operator is directly called. Usually it is just
  necessary to define the type of result object.
  Example: :mod:`~code_aster.Commands.defi_compor`.

- Commands where keywords are used to create the output result.
  Example: :mod:`~code_aster.Commands.defi_group`.

- Commands where several steps must be adapted. Usually, the operator directly
  calls C++ Objects to do the job.


For all features that are not yet supported, please use utilities from
the :mod:`code_aster.Utilities` functions (example:
:func:`~code_aster.Utilities.compatibility.unsupported` or
:func:`~code_aster.Utilities.compatibility.required`) to identify them.


Base classes
============
"""

import inspect
import linecache
import re
from collections import namedtuple

import aster
import libaster

from ..Cata import Commands
from ..Cata.Language.SyntaxObjects import _F
from ..Cata.SyntaxChecker import CheckerError, checkCommandSyntax
from ..Cata.SyntaxUtils import mixedcopy, remove_none, search_for
from ..Objects import DataStructure
from ..Supervis import CommandSyntax, ExecutionParameter, Options, logger
from ..Utilities import deprecated, import_object, no_new_attributes
from ..Utilities.outputs import (command_header, command_result,
                                 command_separator, command_text, command_time,
                                 decorate_name)


class ExecuteCommand(object):

    """This class implements an executor of commands.

    Commands executors are defined by subclassing this class and overloading
    some of the methods. A user's Command is a factory of these classes.

    The :meth:`run` factory creates an instance of one of these classes and
    executes successively these steps:

        - :meth:`.adapt_syntax` to eventually change the user's keywords to
          adapt the syntax from an older version. Does nothing by default.

        - :meth:`.check_syntax` to check the user's keywords conformance to
          to catalog definition.

        - :meth:`.create_result` to create the *DataStructure* object.
          The default implementation only works if the operator creates no
          object.

        - :meth:`.exec_` that is the main function of the Command.
          The default implementation calls the *legacy* Fortran operator.

        - :meth:`.post_exec` that allows to execute additional code after
          the main function. Does nothing by default.
    """
    # class attributes
    command_name = command_op = command_cata = None
    level = 0

    _cata = _op = _result = _result_name = _counter = _caller = None

    __setattr__ = no_new_attributes(object.__setattr__)

    def __init__(self):
        """Initialization"""
        assert self.command_name, "'command_name' attribute is not defined!"
        self._cata = self.command_cata or getattr(Commands, self.command_name)
        self._op = self.command_op or self._cata.definition['op']
        self._result = None
        self._result_name = ""
        self._counter = 0

    @classmethod
    def run(cls, **kwargs):
        """Run the command.

        Arguments:
            keywords (dict): User keywords
        """
        cmd = cls()
        keywords = mixedcopy(kwargs)
        cmd.keep_caller_infos(keywords)
        timer = ExecutionParameter().timer
        if cmd.command_name not in ("DEBUT", "POURSUITE", "FIN"):
            check_jeveux()
        if cmd._op is None:
            logger.debug("ignore command {0}".format(cmd.name))
            return

        ExecuteCommand.level += 1
        cmd._counter = ExecutionParameter().incr_command_counter()
        timer.Start(str(cmd._counter), name=cmd.command_name,
                    hide=not cmd.show_syntax())
        timer.Start(" . check syntax", num=1.1e6)
        cmd.adapt_syntax(keywords)
        cmd._cata.addDefaultKeywords(keywords)
        remove_none(keywords)
        try:
            cmd.check_syntax(keywords)
        except CheckerError as exc:
            # in case of syntax error, show the syntax and raise the exception
            cmd.print_syntax(keywords)
            ExecuteCommand.level -= 1
            if ExecutionParameter().option & Options.Debug:
                logger.error(exc.msg)
                raise
            raise exc.original(exc.msg)
        finally:
            timer.Stop(" . check syntax")
        cmd.create_result(keywords)
        if hasattr(cmd._result, "userName"):
            cmd._result.userName = cmd.result_name

        cmd.print_syntax(keywords)
        try:
            cmd.exec_(keywords)
            cmd.add_references(keywords)
            cmd.post_exec(keywords)
        finally:
            cmd.print_result()
        ExecuteCommand.level -= 1
        return cmd._result

    @classmethod
    def show_syntax(cls):
        """Tell if the current command syntax should be printed.

        Returns:
            bool: *True* if the syntax should be printed.
        """
        return (cls.level <= 1 or
                ExecutionParameter().option & Options.ShowChildCmd)

    def _call_oper(self, syntax):
        """Call fortran operator.

        Arguments:
            syntax (*CommandSyntax*): Syntax description with user keywords.
        """
        return libaster.call_oper(syntax, 0)

    @property
    def name(self):
        """Returns the command name."""
        return self._cata.name

    def _visitSyntax(self, toVisit):
        name = self._result.getName()
        if type(toVisit) in (list, tuple):
            for value in toVisit:
                if isinstance(value, DataStructure):
                    if name != value.getName():
                        self._result.addReference(value)
                else:
                    self._visitSyntax(value)
        elif type(toVisit) in (dict, _F):
            for value in toVisit.values():
                self._visitSyntax(value)
        elif isinstance(toVisit, DataStructure):
            if name != toVisit.getName():
                self._result.addReference(toVisit)

    def add_references(self, keywords):
        """Add reference to DataStructure in self._result

        Arguments:
            keywords (dict): Keywords arguments of user's keywords, changed
                in place.
        """
        if isinstance(self._result, DataStructure):
            self._visitSyntax(keywords)

    def adapt_syntax(self, keywords):
        """Hook to adapt syntax from a old version or for compatibility reasons.

        Arguments:
            keywords (dict): Keywords arguments of user's keywords, changed
                in place.
        """

    def print_syntax(self, keywords):
        """Print an echo of the Command.

        Arguments:
            keywords (dict): Keywords arguments of user's keywords.
        """
        if not self.show_syntax():
            return
        printed_args = mixedcopy(keywords)
        remove_none(printed_args)
        filename = self._caller["filename"]
        lineno = self._caller["lineno"]

        logger.info("\n.. _stg{0}_{1}".format(
            ExecutionParameter().get_option("stage_number"),
            self._caller["identifier"]))
        logger.info(command_separator())
        logger.info(command_header(self._counter, filename, lineno))
        max_print = ExecutionParameter().get_option("max_print")
        logger.info(command_text(self.name, printed_args, self.result_name,
                                 limit=max_print))

    def print_result(self):
        """Print an echo of the result of the command."""
        if not self.show_syntax():
            return
        if self._result and type(self._result) is not int:
            logger.info(command_result(self._counter, self.name,
                                       self._result))
        self._print_timer()

    def _print_timer(self):
        """Print the timer informations."""
        timer = ExecutionParameter().timer
        logger.info(command_time(*timer.StopAndGet(str(self._counter))))
        logger.info(command_separator())

    def check_syntax(self, keywords):
        """Check the syntax passed to the command. *keywords* will contain
        default keywords after executing this method.

        Arguments:
            keywords (dict): Keywords arguments of user's keywords, changed
                in place.
        """
        logger.debug("checking syntax of {0}...".format(self.name))
        max_check = ExecutionParameter().get_option("max_check")
        checkCommandSyntax(self._cata, keywords, add_default=False,
                           max_check=max_check)

    def create_result(self, keywords):
        """Create the result before calling the *exec* command function
        if needed.
        The result is stored in an internal attribute and will be built by
        *exec_*.

        Arguments:
            keywords (dict): Keywords arguments of user's keywords.
        """
        sd_type = self._cata.get_type_sd_prod(**keywords)
        if sd_type is None:
            self._result = None
        else:
            raise NotImplementedError("Method 'create_result' must be "
                                      "overridden for {0!r}.".format(self.name))

    def exec_(self, keywords):
        """Execute the command.

        Arguments:
            keywords (dict): User's keywords.
        """
        syntax = CommandSyntax(self.name, self._cata)
        syntax.define(keywords, add_default=False)
        # set result and type names
        if self._result is None or type(self._result) is int:
            type_name = ""
            result_name = ""
        else:
            type_name = self._result.getType()
            result_name = self._result.getName()
        syntax.setResult(result_name, type_name)

        timer = ExecutionParameter().timer
        try:
            timer.Start(" . fortran", num=1.2e6)
            self._call_oper(syntax)
        finally:
            timer.Stop(" . fortran")
            syntax.free()

    def post_exec(self, keywords):
        """Hook that allows to add post-treatments after the *exec* function.

        .. note:: If the Command executes the *op* fortran subroutine and if
            the result DataStructure references input in a Jeveux object,
            pointers on these inputs must be explicitly references into
            the result.

        Arguments:
            keywords (dict): Keywords arguments of user's keywords.
        """

    @property
    def result_name(self):
        """Return the name of the result of the Command.

        Returns:
            str: Name of the result returned by the Command.
        """
        return self._result_name

    def keep_caller_infos(self, keywords, level=2):
        """Register the caller frame infos.

        Arguments:
            keywords (dict): Dict of keywords.
            level (Optional[int]): Number of frames to rewind to find the
                caller.
        """
        self._caller = {"filename": "unknown", "lineno": 0, "context": {},
                        "identifier": ""}
        caller = inspect.currentframe()
        try:
            for _ in range(level):
                caller = caller.f_back
            self._caller["filename"] = caller.f_code.co_filename
            self._caller["lineno"] = caller.f_lineno
            self._caller["context"] = caller.f_globals
            self._result_name = get_user_name(self.command_name,
                                              self._caller["filename"],
                                              self._caller["lineno"])
        finally:
            del caller

        try:
            identifier = "cmd{0}".format(keywords.pop('identifier'))
        except KeyError:
            identifier = "txt{0}".format(self._caller["lineno"])
        self._caller["identifier"] = identifier


def check_jeveux():
    """Check that the memory manager (Jeveux) is up."""
    if not libaster.jeveux_status():
        raise RuntimeError("code_aster memory manager is not started. "
                           "No command can be executed.")


class ExecuteCommandOps(ExecuteCommand):

    """This implements an executor of commands that use an
     `opsXXX` subroutine."""

    def _call_oper(self, syntax):
        """Call fortran operator.

        Arguments:
            syntax (*CommandSyntax*): Syntax description with user keywords.
        """
        return libaster.call_ops(syntax, self._op)


class ExecuteMacro(ExecuteCommand):

    """This implements an executor of *legacy* macro-commands.

    The OPS function of *legacy* macro-commands returns a return code and
    declared results through ``self.DeclareOut(...)``.

    Now the results must be directly returned by the OPS function.

    Long term: ``result = MACRO_COMMAND(**keywords)`` where ``result`` is
    a *DataStructure* object (for one result) or a *namedtuple* (for several
    results). ``result`` is created by the *ops* function.

    For compatibility: :meth:`.create_result` builds the type of the
    *namedtuple*. The *ops* function returns the "main" result and registers
    others with :meth:`register_result`.
    :meth:`exec_` adds it at first position of the *namedtuple* under the
    name "main".

    Attributes:
        _sdprods (list[CO]): List of CO objects.
        _result_type (type): *namedtuple* type.
        _result_names (list[str]): List of expected results names.
        _add_results (dict): Dict of additional results.
    """

    _sdprods = _result_type = _result_names = _add_results = None

    def __init__(self):
        """Initialization"""
        super(ExecuteMacro, self).__init__()
        self._op = self.command_op or import_object(self._op)

    def create_result(self, keywords):
        """Macro-commands create their results in the *exec_* method.

        Arguments:
            keywords (dict): Keywords arguments of user's keywords.
        """
        def _predicate(value):
            if(type(value) in (list, tuple)):
                return all(isinstance(val, CO) for val in value)
            return isinstance(value, CO)

        self._sdprods = search_for(keywords, _predicate)
        if self._sdprods:
            names_i = ((ii.getName() for ii in i) if(type(i) in (list, tuple))
                       else [i.getName()]
                       for i in self._sdprods)
            names = [ii for i in names_i for ii in i]
            self._result_type = namedtuple("Result", ["main"] + names)
            self._result_names = names
            self._add_results = {}

    def print_result(self):
        """Print an echo of the result of the command."""
        if not self._sdprods and self._result:
            logger.info(command_result(self._counter, self.name,
                                       self._result))
        if self._result_names:
            for name in self._result_names:
                logger.info(command_result(self._counter, self.name,
                                           self._add_results.get(name)))
        self._print_timer()

    def exec_(self, keywords):
        """Execute the command and fill the *_result* attribute.

        Arguments:
            keywords (dict): User's keywords.
        """
        output = self._op(self, **keywords)
        assert not isinstance(output, int), \
            "OPS must now return results, not 'int'."
        if ExecutionParameter().option & Options.UseLegacyMode:
            self._result = output
            # re-assign the user variable name
            if hasattr(self._result, "userName"):
                self._result.userName = self.result_name
            if self._add_results:
                publish_in(self._caller["context"], self._add_results)
            return

        if not self._sdprods:
            self._result = output
        else:
            dres = dict(main=output)
            dres.update(self._add_results)
            missing = set(self._result_names).difference(list(dres.keys()))
            if missing:
                raise ValueError("Missing results: {0}".format(tuple(missing)))
            self._result = self._result_type(**dres)

    def register_result(self, result, target):
        """Register an additional result.

        Similar to the old *DeclareOut* method but it must called **after** that
        the result has been created.

        Arguments:
            result (*DataStructure*): Result object to register.
            target (:class:`CO`): CO object.
        """
        name = target.getName()
        orig = result.userName
        result.userName = name
        self._add_results[name] = result
        if ExecutionParameter().option & Options.ShowChildCmd:
            logger.info("Intermediate result '{0}' will be available as '{1}'."
                        .format(orig, name))

    @property
    def sdprods(self):
        """Attribute that holds the auxiliary results."""
        return self._sdprods or []

    # create a sub-object?
    def get_cmd(self, name):
        """Return a command."""
        from .. import Commands
        return getattr(Commands, name, None)

    @deprecated(False)
    def set_icmd(self, _):
        """Does nothing, kept for compatibility."""
        return

    @deprecated(help="Results have to be register using 'register_result'.")
    def DeclareOut(self, result, target):
        """Register a result of the macro-command."""
        pass

    @property
    @deprecated(True, help="Not yet implemented.")
    def reuse(self):
        return

    @property
    @deprecated(True, help="Not yet implemented.")
    def sd(self):
        return

    @property
    @deprecated(True, help="Use the 'logger' object instead.")
    def cr(self):
        return logger

    def get_concept(self, name):
        raise NotImplementedError("'get_concept()' does not exist anymore...")


def UserMacro(name, cata, ops):
    """Helper function that defines a user macro-command from its catalog
    description and its operator.

    Arguments:
        name (str): Name of the macro-command.
        cata (*PartOfSyntax*): Catalog description of the macro-command.
        ops (str): OPS function of the macro-command.

    Returns:
        *ExecuteCommand.run*: Executor function.
    """
    class Macro(ExecuteMacro):
        """Execute legacy operator."""
        command_name = name
        command_cata = cata

        @staticmethod
        def command_op(self, **kwargs):
            return ops(self, **kwargs)

    return Macro.run


class CO(object):

    """Object that identify an auxiliary result of a Macro-Command."""
    _name = None

    def __init__(self, name):
        """Initialization"""
        self._name = name

    def getName(self):
        """Return the CO name."""
        return self._name

    @property
    def userName(self):
        """Same as 'getName' for a CO."""
        return self.getName()

    @property
    def value_repr(self):
        """Returns the representation as a keyword value."""
        return "CO('{0}')".format(self.userName)

    def is_typco(self):
        """Tell if it is an auxiliary result."""
        return True

    def getType(self):
        """Return a type for syntax checking."""
        return "CO"

    def setType(self, typ):
        """Declare the future type."""
        pass

    # used in AsterStudy as settype
    settype = setType


def publish_in(context, dict_objects):
    """Publish some objects in a context.

    It supports list of results as declared in code_aster legacy:
    If an object is name ``xxx_n`` and that ``xxx`` exists and is a list in
    *context* and ``xxx[n]`` exists this item of the list is replaced by the
    new value.

    Arguments:
        context (dict): Destination context, changed in place.
        dict_objects (dict): Objects to be added into the context.
    """
    re_id = re.compile("^(.*)_([0-9]+)$")
    for name, value in list(dict_objects.items()):
        indexed = re_id.search(name)
        if indexed:
            bas, idx = indexed.groups()
            idx = int(idx)
            seq = context.get(bas)
            if seq and isinstance(seq, list) and len(seq) > idx:
                seq[idx] = value
                continue

        context[name] = value


def get_user_name(command, filename, lineno):
    """Parse the caller syntax to extract the name used by the user.

    Arguments:
        command (str): Command name.
        filename (str): Filename of the caller
        lineno (int): Line number in the file.

    Returns:
        str: Variable name used by the user, empty if not found.
    """
    re_comment = re.compile(r"^\s*#.*")
    re_oper = re.compile(r"\b{0}\s*\(".format(command))
    re_name = re.compile(r"^\s*(?P<name>\w+)\s*"
                         r"=\s*{0}\s*\(".format(command))

    while lineno > 0:
        line = linecache.getline(filename, lineno)
        lineno = lineno - 1
        if re_comment.match(line):
            continue
        if re_oper.search(line):
            mat = re_name.search(line)
            if mat:
                # str() because of linecache in ipython, remove it in py3
                return str(mat.group("name"))
            break

    return ""
