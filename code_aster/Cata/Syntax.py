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

# TODO : - prendre en compte des conditions de blocs plus compliquées
#            (rajouter mCS = None quand on n'a pas de valeurs, ...)
#       - validators=NoRepeat
#       - prendre en compte les types Aster qui sont aujourd'hui tous des DataStructure
#       - Les fonctions definies dans la paire d'accolade NOOK sont à revoir

from code_aster.Cata.Rules import (
    AU_MOINS_UN, AtLeastOne,
    UN_PARMI, ExactlyOne,
    EXCLUS, AtMostOne,
    PRESENT_PRESENT, IfFirstAllPresent,
    PRESENT_ABSENT, OnlyFirstPresent,
    ENSEMBLE, AllTogether,
)
from code_aster.Cata import DataStructure as DS
DS_content = DS.__dict__.values()

import __builtin__


def _F(**args):
    return args

__builtin__._F = _F

# TODO: replace by the i18n function (see old accas.capy)
def _(args):
    return args

__builtin__._ = _


def _debug( *args ):
    """Debug print"""
    # return
    from pprint import pprint
    print "DEBUG:",
    pprint( args )

def checkMandatory(dictDefinition, dictSyntax):
    """Check that mandatory keywords are present in the given syntax"""
    for key, value in dictDefinition.iteritems():
        if isinstance(value, PartOfSyntax):
            if value.isMandatory() and not dictSyntax.has_key(key):
                _debug( "keyword =", value )
                _debug( "syntax =", dictSyntax )
                raise KeyError("Keyword {} is mandatory".format(key))

def buildConditionContext(dictDefinition, dictSyntax):
    """Build the context to evaluate bloc conditions.
    The values given by the user (dictSyntax) preempt on the definition ones"""
    ctxt = {}
    for key, value in dictDefinition.iteritems():
        if isinstance(value, SimpleKeyword):
            # use the default or None
            ctxt[key] = value.defaultValue()
    ctxt.update(dictSyntax)
    return ctxt


class PartOfSyntax(object):

    """
    Objet générique qui permet de décrire un bout de syntaxe
    """

    def __init__(self, curDict):
        """Initialization"""
        if type(curDict) != dict:
            raise TypeError("'dict' is expected")
        self.dictionary = curDict
        self.regles = curDict.get("regles")

    def __repr__(self):
        """Simple representation"""
        return "%s( %r )" % (self.__class__, self.dictionary)

    def checkSyntax(self, syntax):
        """Check the syntax"""
        raise NotImplementedError("must be defined in a subclass")

    def isMandatory(self):
        """Tell if this keyword is mandatory"""
        return self.dictionary.get("statut", "n") == "o"

    def getEntites(self):
        """Retourne les "entités" composant l'objet (SIMP, FACT, BLOC)
        """
        entites = self.dictionary.copy()
        for key, value in entites.items():
            if type(value) not in (SimpleKeyword, Bloc, FactorKeyword):
                del entites[key]
        return entites

    def inspectBlocs(self, dictSyntax):
        """
        Fonction membre inspectBlocs
        Parcourt les blocs présents et produit un dictionnaire avec les mot-clés
        à ajouter en fonction des conditions
        """
        ctxt = buildConditionContext(self.dictionary, dictSyntax)
        # XXX il y a sans doute un risque qu'on mette dans dictTmp des mots-clés
        #     qui sont à un niveau trop profond.
        dictTmp = {}
        # On évalue ensuite les conditions une après l'autre pour ajouter les
        # mot-clés
        for key, value in self.dictionary.iteritems():
            if isinstance(value, Bloc):
                dictTmp.update( value.inspectBlocs(dictSyntax) )

                findCondition = False
                currentCondition = value.getCondition()
                try:
                    findCondition = eval(currentCondition, ctxt)
                except:
                    pass
                if findCondition:
                    for key2, value2 in value.dictionary.iteritems():
                        if isinstance(value2, SimpleKeyword):
                            dictTmp[key2] = value2
        return dictTmp


class FactorKeyword(PartOfSyntax):

    """
    Objet mot-clé facteur equivalent de FACT dans les capy
    """

    def checkSyntax(self, tupleSyntax):
        """
        Fonction membre checkSyntax
        Vérifie :
            - qu'on a bien le bon nombre d'occurence du mot-clé
            - que les règles du catalogues sont bien vérifiées
            - que les mot-clés simples obligatoires sont bien présents
        Un parcourt des objets Bloc est réalisé pour ajouter au bon niveau les
        mot-clés à ajouter en fonction des conditions
        On verifie ensuite que l'utilisateur n'a pas oublié de mot-clé
        """
        if type(tupleSyntax) == dict:
            tupleSyntax = [tupleSyntax]
        elif type(tupleSyntax) in (list, tuple):
            pass
        else:
            raise TypeError("Type 'dict' or 'tuple' is expected")

        # Vérification du nombre de mots-clés facteurs
        if len(tupleSyntax) < self.dictionary.get('min', 0):
            raise ValueError("Too few factor keyword")
        if len(tupleSyntax) > self.dictionary.get('max', 1000000000):
            raise ValueError("Too much factor keyword")

        # Boucle sur toutes les occurences du mot-clé facteur
        for dictSyntax in tupleSyntax:
            # Vérification des règles de ce mot-clé
            if self.regles != None:
                for rule in self.regles:
                    rule.check(dictSyntax)

            # On vérifie que les mots-clés simples qui doivent être présents le
            # sont
            checkMandatory(self.dictionary, dictSyntax)
            # Pour les blocs aussi
            dictTmp = self.inspectBlocs(dictSyntax)
            checkMandatory(dictTmp, dictSyntax)

            # On boucle sur la syntax de l'utilisateur vérifier les mots-clés
            # simples
            for key, value in dictSyntax.iteritems():
                # print key, value
                if not self.dictionary.has_key(key) and not dictTmp.has_key(key):
                    raise KeyError("Keyword " + key + " unauthorized")
                else:
                    if self.dictionary.has_key(key):
                        kw = self.dictionary[key]
                        kw.checkSyntax(value)
                    if dictTmp.has_key(key):
                        kw = dictTmp[key]
                        kw.checkSyntax(value)


class SimpleKeyword(PartOfSyntax):

    """
    Objet mot-clé simple équivalent à SIMP dans les capy
    """

    def checkSyntax(self, skwValue):
        """
        Fonction membre checkSyntax
        Vérifie tout ce qu'il y a à vérifier pour un mot-clé simple :
            - le type,
            - le into,
            - val_min et val_max,
            - min et max
        """
        # Vérification du type
        currentType = self.dictionary["typ"]
        validType = None
        if currentType == 'TXM':
            validType = [str, unicode]
        elif currentType == 'I':
            validType = [int, ]
        elif currentType == 'R':
            validType = [float, int]
        elif currentType in DS_content:
            validType = [str, ]    # XXX str ???
        else:
            raise TypeError( "Unsupported type: {!r}".format(currentType) )

        # Vérification des valeurs max et min
        valMin = self.dictionary.get('val_min')
        valMax = self.dictionary.get('val_max')

        if type(skwValue) in (list, tuple):
            # Vérification du nombre de valeurs
            nbMin = self.dictionary.get('min')
            nbMax = self.dictionary.get('max')
            if nbMax == "**":
                nbMax = None
            if nbMax != None and len(skwValue) > nbMax:
                _debug( self )
                raise ValueError('At most {} values are expected'.format(nbMax))
            if nbMin != None and len(skwValue) < nbMin:
                raise ValueError('Bad number of values')
        else:
            skwValue = [skwValue]

        # Vérification du type et des bornes des valeurs
        for i in skwValue:
            # into
            if self.dictionary.has_key("into"):
                if i not in self.dictionary["into"]:
                    raise ValueError( "Value must be in {!r}".format(
                                      self.dictionary["into"]) )
            # type
            if type(i) not in validType \
               and not isinstance(i, DS.DataStructure) \
               and type(i) not in [DS.Mesh, DS.Model, DS.Material]:
                self._context(i)
                raise TypeError('Unexpected type ' + type(i))
            # val_min/val_max
            if valMax != None and i > valMax:
                raise ValueError('Value must be smaller than {}'.format(valMax))
            if valMin != None and i < valMin:
                raise ValueError('Value must be bigger than {}'.format(valMin))

    def _context(self, value):
        """Print contextual informations"""
        print "CONTEXT: value={!r}, type={}".format(value, type(value))
        print "CONTEXT: definition:", self

    def hasDefaultValue(self):
        undef = object()
        return self.dictionary.get("defaut", undef) is not undef

    def defaultValue(self):
        return self.dictionary.get("defaut")


class Bloc(PartOfSyntax):

    """
    Objet Bloc équivalent à BLOC dans les capy
    """

    def getCondition(self):
        """
        Récupération de la condition d'apparition d'un bloc
        """
        cond = self.dictionary.get('condition')
        assert cond is not None, "A bloc must have a condition!"
        return cond


class Command(PartOfSyntax):

    """
    Object Command qui représente toute la syntaxe d'une commande
    """

    def checkSyntax(self, dictSyntax):
        """
        Fonction membre permettant de verifier la syntaxe d'une commande
        """
        if type(dictSyntax) != dict:
            raise TypeError("'dict' is expected")

        # Vérification des règles
        if self.regles != None:
            for rule in self.regles:
                rule.check(dictSyntax)

        # On boucle sur tout le catalogue et on vérifie que pour tous les bouts de syntaxe
        # les mot-clés obligatoires sont bien présents

        # On commence par rechercher les blocs à ajouter
        # Construction des conditions
        ctxt = buildConditionContext(self.dictionary, dictSyntax)

        dictTmp = {}
        # Evaluation des conditions et ajout des mot-clés nécessaires
        for key, value in self.dictionary.iteritems():
            if isinstance(value, Bloc):
                findCondition = False
                currentCondition = value.getCondition()
                try:
                    findCondition = eval(currentCondition, ctxt)
                except:
                    pass
                if findCondition:
                    for key2, value2 in value.dictionary.iteritems():
                        if isinstance(value2, SimpleKeyword):
                            dictTmp[key2] = value2

        # Vérification que tous les mots-clés obligatoires sont présents
        # à la fois dans les blocs
        checkMandatory(dictTmp, dictSyntax)

        # Mais aussi dans le dictionnaire standard
        checkMandatory(self.dictionary, dictSyntax)

        # On vérifie ensuite que les mots-clés donnés par l'utilisateur
        # sont autorisés et ont la bonne syntaxe
        for key, value in dictSyntax.iteritems():
            if not self.dictionary.has_key(key):
                raise KeyError("Keyword " + key + " unauthorized")
            else:
                if self.dictionary.has_key(key):
                    kw = self.dictionary[key]
                    kw.checkSyntax(value)


class Operator(Command):

    pass


class Macro(Command):

    pass


class Procedure(Command):

    pass


class Formule(Command):

    pass

# Les fonctions definies dans la paire d'accolade Ok ont été correctement traitées
# Les fonctions definies dans la paire d'accolade NOOK sont à revoir
# Ok {


def OPER(**kwargs):
    return Operator(kwargs)


def SIMP(**kwargs):
    return SimpleKeyword(kwargs)


def FACT(**kwargs):
    return FactorKeyword(kwargs)


def BLOC(**kwargs):
    return Bloc(kwargs)


def MACRO(**kwargs):
    return Macro(kwargs)


def PROC(**kwargs):
    return Procedure(kwargs)


def FORM(**kwargs):
    return Formule(kwargs)


def tr(kwargs):
    return kwargs


def OPS(kwargs):
    return kwargs


class EMPTY_OPS(object):
    pass


class Ops(object):

    def __init__(self):
        self.DEBUT = None
        self.build_detruire = None
        self.build_formule = None
        self.build_gene_vari_alea = None
        self.INCLUDE = None
        self.INCLUDE_context = None
        self.POURSUITE = None
        self.POURSUITE_context = None

ops = Ops()


class C_MFRONT_OFFICIAL(object):

    def keys(self):
        return {}


class PROC_ETAPE(Procedure):
    pass
# } Ok

# NOOK {


def CO():
    pass


class assd(object):
    pass


def NoRepeat():
    return


def LongStr(a, b):
    pass


def AndVal(*args):
    pass


def OrdList(args):
    pass
# } NOOK
