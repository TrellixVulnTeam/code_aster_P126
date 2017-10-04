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

"""
:py:mod:`strfunc` --- String manipulations utilities
****************************************************

This module defines utilities functions for strings manipulation.
"""

import locale

_encoding = None


def get_encoding():
    """Return local encoding
    """
    global _encoding
    if _encoding is None:
        try:
            _encoding = locale.getpreferredencoding() or 'ascii'
        except locale.Error:
            _encoding = 'ascii'
    return _encoding


def to_unicode(string):
    """Try to convert string into a unicode string.

    Arguments:
        string (str): String to convert to unicode.

    Returns:
        str: Unicode string.
    """
    if type(string) is unicode:
        return string
    elif type(string) is dict:
        new = {}
        for k, v in string.items():
            new[k] = to_unicode(v)
        return new
    elif type(string) is list:
        return [to_unicode(elt) for elt in string]
    elif type(string) is tuple:
        return tuple(to_unicode(list(string)))
    elif type(string) is not str:
        return string
    assert type(string) is str, u"unsupported object: %s" % string
    for encoding in ('utf-8', 'iso-8859-15', 'cp1252'):
        try:
            s = unicode(string, encoding)
            return s
        except UnicodeDecodeError:
            pass
    return unicode(string, 'utf-8', 'replace')


def from_unicode(ustring, encoding, errors='replace'):
    """Try to encode a unicode string using encoding.

    Arguments:
        ustring (str): Unicode string to encode.
        encoding (str): Encoding name.
        errors (str): Behavior in case of encoding error
            (see :py:func:`string.encode`).

    Returns:
        str: Encoded string.
    """
    try:
        return ustring.encode(encoding)
    except UnicodeError:
        pass
    return ustring.encode(encoding, errors)


def convert(content, encoding=None, errors='replace'):
    """Convert content using encoding or default encoding if *None*.

    Arguments:
        content (str/unicode): Text to convert.
        encoding (str): Encoding name.
        errors (str): Behavior in case of encoding error
            (see :meth:`string.encode`).

    Returns:
        str: Encoded string.
    """
    if type(content) not in (str, unicode):
        content = unicode(content)
    if type(content) == str:
        content = to_unicode(content)
    return from_unicode(content, encoding or get_encoding(), errors)
