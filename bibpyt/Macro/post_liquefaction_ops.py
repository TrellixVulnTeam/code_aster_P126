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

#-------------------------------------------------------
# CRITERE DE LIQUEFACTION : [SIP(t)-SIP(t0)]/SIV(t0)
#-------------------------------------------------------

def post_liquefaction_ops(self,AXE,RESU_REF,RESULTAT,INST_REF,**args):

  import aster
  import os,string,types
  from code_aster.Cata.Syntax import _F

  # La macro compte pour 1 dans la numerotation des commandes
  self.set_icmd(1)

  ### On importe les definitions des commandes a utiliser dans la macro
  CREA_CHAMP     = self.get_cmd('CREA_CHAMP')
  CREA_RESU      = self.get_cmd('CREA_RESU')
  FORMULE        = self.get_cmd('FORMULE')
  DETRUIRE       = self.get_cmd('DETRUIRE')

 ### RECUPERATION DU MODELE A PARTIR DU RESULTAT

#  modele
  __model = RESU_REF.getModel()


  ### Extraction du champ SIEF_ELGA a la fin de l'etat reference INST_REF
  __sigini = CREA_CHAMP (OPERATION = 'EXTR',
                 TYPE_CHAM = 'ELGA_SIEF_R',
                         RESULTAT  = RESU_REF,
                 NOM_CHAM  = 'SIEF_ELGA',
                 INST      = INST_REF,)

  ### Transformation des champs SIP(tref) et SIYY(tref) en champs de type NEUT
  if AXE == 'X':
    __sig1 = CREA_CHAMP(OPERATION = 'ASSE',
                TYPE_CHAM = 'ELGA_NEUT_R',
                PROL_ZERO = 'OUI',
                MODELE    = __model,
                       ASSE      = _F(TOUT         = 'OUI',
                         CHAM_GD      = __sigini,
                              NOM_CMP      = ('SIPXX','SIXX'),
                       NOM_CMP_RESU = ('X1','X2'),),)
  elif AXE == 'Y':
    __sig1 = CREA_CHAMP(OPERATION = 'ASSE',
                TYPE_CHAM = 'ELGA_NEUT_R',
                PROL_ZERO = 'OUI',
                MODELE    = __model,
                       ASSE      = _F(TOUT         = 'OUI',
                         CHAM_GD      = __sigini,
                              NOM_CMP      = ('SIPYY','SIYY'),
                       NOM_CMP_RESU = ('X1','X2'),),)
  elif AXE == 'Z':
    __sig1 = CREA_CHAMP(OPERATION = 'ASSE',
                TYPE_CHAM = 'ELGA_NEUT_R',
                PROL_ZERO = 'OUI',
                MODELE    = __model,
                       ASSE      = _F(TOUT         = 'OUI',
                         CHAM_GD      = __sigini,
                              NOM_CMP      = ('SIPZZ','SIZZ'),
                       NOM_CMP_RESU = ('X1','X2'),),)

  ### Formule pour evaluer le critere de liquefaction (qui vaut 0 si jamais SIYY(tref) vaut 0)
  __fmul = FORMULE(NOM_PARA = ('X1','X2','X3'), 
               VALE     = '0.0 if abs(X2)<=1e-12 else (X3-X1)/X2')

  __chfmu = CREA_CHAMP(OPERATION = 'AFFE',
               TYPE_CHAM = 'ELGA_NEUT_F',
               MODELE    = __model,
                    PROL_ZERO = 'OUI',
                       AFFE      = _F(TOUT    = 'OUI',
                      NOM_CMP = 'X4',
                      VALE_F  = __fmul),)

  ###-------------
  ### DEBUT BOUCLE
  ###-------------

  ### Acces aux numeros d'ordre de RESULTAT pour l'indicage de la boucle
  __dico = aster.GetResu(RESULTAT.get_name(), "VARI_ACCES")
  __numo = __dico['NUME_ORDRE']
  __n    = __numo[-1]

  ### Initialisation des variables de la boucle
  __liqq  = [None]*(__n+1)
  __sigf = [None]*(__n+1)
  __siff = [None]*(__n+1)

  for i in range(0,__n+1):

     ### Extraction du champ SIEF_ELGA
    __sigt = CREA_CHAMP (OPERATION  = 'EXTR',
                    TYPE_CHAM  = 'ELGA_SIEF_R',
                            RESULTAT   = RESULTAT,
                    NOM_CHAM   = 'SIEF_ELGA',
                    NUME_ORDRE = i,)

     ### Transformation du champ SIP(t) en champ de type NEUT
    if AXE == 'X':
      __sig2 = CREA_CHAMP(OPERATION = 'ASSE',
               TYPE_CHAM = 'ELGA_NEUT_R',
               MODELE    = __model,
               PROL_ZERO = 'OUI',
                      ASSE      = _F(TOUT         = 'OUI',
                      CHAM_GD      = __sigt,
                            NOM_CMP      = ('SIPXX',),
                     NOM_CMP_RESU = ('X3',),),)
    elif AXE == 'Y':
      __sig2 = CREA_CHAMP(OPERATION = 'ASSE',
               TYPE_CHAM = 'ELGA_NEUT_R',
               MODELE    = __model,
               PROL_ZERO = 'OUI',
                      ASSE      = _F(TOUT         = 'OUI',
                      CHAM_GD      = __sigt,
                            NOM_CMP      = ('SIPYY',),
                     NOM_CMP_RESU = ('X3',),),)
    elif AXE == 'Z':
      __sig2 = CREA_CHAMP(OPERATION = 'ASSE',
               TYPE_CHAM = 'ELGA_NEUT_R',
               MODELE    = __model,
               PROL_ZERO = 'OUI',
                      ASSE      = _F(TOUT         = 'OUI',
                      CHAM_GD      = __sigt,
                            NOM_CMP      = ('SIPZZ',),
                     NOM_CMP_RESU = ('X3',),),)

     ### Assemblage de SIP(t0),SIYY(t0) et SIP(t) dans le meme champ SIG
    __sig = CREA_CHAMP(OPERATION = 'ASSE',
                    MODELE    = __model,
               TYPE_CHAM ='ELGA_NEUT_R',
                    ASSE      = (_F(CHAM_GD = __sig1 ,
                       TOUT ='OUI',
                                     CUMUL='OUI',
                       COEF_R = 1.),
                             _F(CHAM_GD = __sig2 ,
                       TOUT ='OUI',
                         CUMUL='OUI',
                       COEF_R = 1.),),)

     ### Calcul du critere de liquefaction
    __liqq[i] = CREA_CHAMP(OPERATION = 'EVAL',
                     TYPE_CHAM = 'ELGA_NEUT_R',
                             CHAM_F    = __chfmu,
                     CHAM_PARA = (__sig,),)

     ### Creation d'un champ contenant le resultat du calcul
    __sigf[i] = CREA_CHAMP(OPERATION = 'ASSE',
                TYPE_CHAM = 'ELGA_NEUT_R',
                MODELE    = __model,
                PROL_ZERO = 'OUI',
                       ASSE      = _F(TOUT         = 'OUI',
                      CHAM_GD      = __liqq[i],
                             NOM_CMP      = ('X4',),
                      NOM_CMP_RESU = ('X4',),),)

     ### Transformer le champ SIGF de type NEUT en champ de type SIEF_ELGA (sous la variable SIP)
    if AXE == 'X':
      __siff[i] = CREA_CHAMP(OPERATION = 'ASSE',
                  TYPE_CHAM = 'ELGA_SIEF_R',
                  PROL_ZERO = 'OUI',
                  MODELE    = __model,
                         ASSE      = _F(TOUT         = 'OUI',
                        CHAM_GD      = __sigf[i],
                               NOM_CMP      = ('X4',),
                        NOM_CMP_RESU = ('SIPXX',),),)
    if AXE == 'Y':
      __siff[i] = CREA_CHAMP(OPERATION = 'ASSE',
                  TYPE_CHAM = 'ELGA_SIEF_R',
                  PROL_ZERO = 'OUI',
                  MODELE    = __model,
                         ASSE      = _F(TOUT         = 'OUI',
                        CHAM_GD      = __sigf[i],
                               NOM_CMP      = ('X4',),
                        NOM_CMP_RESU = ('SIPYY',),),)
    if AXE == 'Z':
      __siff[i] = CREA_CHAMP(OPERATION = 'ASSE',
                  TYPE_CHAM = 'ELGA_SIEF_R',
                  PROL_ZERO = 'OUI',
                  MODELE    = __model,
                         ASSE      = _F(TOUT         = 'OUI',
                        CHAM_GD      = __sigf[i],
                               NOM_CMP      = ('X4',),
                        NOM_CMP_RESU = ('SIPZZ',),),)

  ###-------------
  ### FIN BOUCLE
  ###-------------

  # Acces aux instants de RESULTAT pour creer la nouvelle SD resultat LIQ
  __numo2 = __dico['INST']

  __liste=[]
  for k in range(0,__n+1):
     __liste.append( _F(CHAM_GD= __siff[k],MODELE=__model,INST = __numo2[k],),)

  LIQ = CREA_RESU(OPERATION = 'AFFE',
          TYPE_RESU = 'EVOL_NOLI',
          NOM_CHAM  = 'SIEF_ELGA',
                  AFFE      = (__liste),)

  return LIQ
