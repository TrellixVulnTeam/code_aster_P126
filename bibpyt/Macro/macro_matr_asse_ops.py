#@ MODIF macro_matr_asse_ops Macro  DATE 15/10/2002   AUTEUR DURAND C.DURAND 
#            CONFIGURATION MANAGEMENT OF EDF VERSION
# ======================================================================
# COPYRIGHT (C) 1991 - 2002  EDF R&D                  WWW.CODE-ASTER.ORG
# THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY  
# IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY  
# THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR     
# (AT YOUR OPTION) ANY LATER VERSION.                                                  
#                                                                       
# THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT   
# WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF            
# MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU      
# GENERAL PUBLIC LICENSE FOR MORE DETAILS.                              
#                                                                       
# YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE     
# ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,         
#    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.        
# ======================================================================

def macro_matr_asse_ops(self,MODELE,CHAM_MATER,CARA_ELEM,MATR_ASSE,
                        SOLVEUR,NUME_DDL,CHARGE,INST,**args):
  """
     Ecriture de la macro MACRO_MATR_ASSE
  """
  ier=0

  # On met le mot cle NUME_DDL dans une variable locale pour le proteger
  numeddl=NUME_DDL
  # On importe les definitions des commandes a utiliser dans la macro
  # Le nom de la variable doit etre obligatoirement le nom de la commande
  CALC_MATR_ELEM=self.get_cmd('CALC_MATR_ELEM')
  NUME_DDL      =self.get_cmd('NUME_DDL')
  ASSE_MATRICE  =self.get_cmd('ASSE_MATRICE')
  # La macro compte pour 1 dans la numerotation des commandes
  self.icmd=1

  if SOLVEUR:
    methode=SOLVEUR['METHODE']
    if methode=='LDLT':
      if SOLVEUR['RENUM']:
         renum=SOLVEUR['RENUM']
      else:
         renum='RCMK'
      if renum not in ('SANS','RCMK'):
        ier=ier+1
        self.cr.fatal("Avec methode LDLT, RENUM doit etre SANS ou RCMK.")
        return ier
    elif methode=='MULT_FRONT':
      if SOLVEUR['RENUM']:
         renum=SOLVEUR['RENUM']
      else:
         renum='MDA'
      if renum not in ('MDA','MD','METIS'):
        ier=ier+1
        self.cr.fatal("Avec methode MULT_FRONT, RENUM doit etre MDA, MD ou RCMK.")
        return ier
    elif methode=='GCPC':
      if SOLVEUR['RENUM']:
         renum=SOLVEUR['RENUM']
      else:
         renum='SANS'
      if renum not in ('SANS','RCMK'):
        ier=ier+1
        self.cr.fatal("Avec methode GCPC, RENUM doit etre SANS ou RCMK.")
        return ier
  else:
    methode='MULT_FRONT'
    renum  ='MDA'

  if numeddl in self.sdprods:
    # Si le concept numeddl est dans self.sdprods
    # il doit etre  produit par la macro
    # il faudra donc appeler la commande NUME_DDL
    lnume = 1
  else:
    lnume = 0
  lrigel = 0
  lmasel = 0

# decalage eventuel en premiere position dans la liste de l occurence de MATR_ASSE contenant 
# l option de rigidite
  try :
    for m in MATR_ASSE:
      option=m['OPTION']
      if option in ('RIGI_MECA','RIGI_MECA_LAGR','RIGI_THER','RIGI_ACOU') :
         decal=m
         MATR_ASSE.remove(decal)
         MATR_ASSE.insert(0,decal)
         break
  except: pass

  iocc=0
  for m in MATR_ASSE:
    iocc=iocc+1
    option=m['OPTION']
    if iocc == 1 and lnume == 1 and option not in ('RIGI_MECA','RIGI_MECA_LAGR',
                                                   'RIGI_THER','RIGI_ACOU')      :
      ier=ier+1
      self.cr.fatal("UNE DES OPTIONS DOIT ETRE RIGI_MECA OU RIGI_THER OU RIGI_ACOU OU RIGI_MECA_LAGR")
      return ier

    if m['SIEF_ELGA']!=None and option!='RIGI_GEOM':
      ier=ier+1
      self.cr.fatal("SIEF_ELGA N EST ADMIS QU AVEC L OPTION RIGI_GEOM")
      return ier

    if m['MODE_FOURIER']!=None and option not in ('RIGI_MECA','RIGI_FLUI_STRU','RIGI_THER'):
      ier=ier+1
      self.cr.fatal("MODE_FOURIER N EST ADMIS QU AVEC UNE DES OPTIONS RIGI_MECA RIGI_FLUI_STRU RIGI_THER")
      return ier

    if (m['THETA']!=None or m['PROPAGATION']!=None) and option!='RIGI_MECA_LAGR':
      ier=ier+1
      self.cr.fatal("PROPAGATION ET,OU THETA NE SONT ADMIS QU AVEC L OPTION RIGI_MECA_LAGR")
      return ier

    motscles={'OPTION':option}
    if option == 'AMOR_MECA':
       if (not lrigel or not lmasel):
          ier=ier+1
          self.cr.fatal("""POUR CALCULER AMOR_MECA, IL FAUT AVOIR CALCULE
                           RIGI_MECA ET MASS_MECA AUPARAVANT (DANS LE MEME APPEL)""")
          return ier
       if CHAM_MATER != None:
          motscles['RIGI_MECA']   =rigel
          motscles['MASS_MECA']   =masel
    if CHARGE     != None:
       if option[0:9] not in ('MASS_THER','RIGI_GEOM','MASS_ID_M'):
                           motscles['CHARGE']      =CHARGE
    if CHAM_MATER != None: motscles['CHAM_MATER']  =CHAM_MATER
    if CARA_ELEM  != None: motscles['CARA_ELEM']   =CARA_ELEM
    if INST       != None: motscles['INST']        =INST
    if m['SIEF_ELGA']   :  motscles['SIEF_ELGA']   =m['SIEF_ELGA']
    if m['MODE_FOURIER']:  motscles['MODE_FOURIER']=m['MODE_FOURIER']
    if m['THETA']       :  motscles['THETA']       =m['THETA']
    if m['PROPAGATION'] :  motscles['PROPAGATION'] =m['PROPAGATION']

    __a=CALC_MATR_ELEM(MODELE=MODELE,**motscles)

    if option == 'RIGI_MECA':
      rigel  = __a
      lrigel = 1
    if option == 'MASS_MECA':
      masel  = __a
      lmasel = 1

    if lnume and option in ('RIGI_MECA','RIGI_THER','RIGI_ACOU','RIGI_MECA_LAGR'):
      self.DeclareOut('num',numeddl)
      # On peut passer des mots cles egaux a None. Ils sont ignores
      num=NUME_DDL(MATR_RIGI=__a,METHODE=methode,RENUM=renum)
    else:
      num=numeddl

    self.DeclareOut('mm',m['MATRICE'])
    mm=ASSE_MATRICE(MATR_ELEM=__a,NUME_DDL=num)
  return ier


def macro_matr_asse_prod(self,NUME_DDL,MATR_ASSE,**args):
  if not MATR_ASSE:  raise AsException("Impossible de typer les concepts resultats")
  if not NUME_DDL:  raise AsException("Impossible de typer les concepts resultats")
  self.type_sdprod(NUME_DDL,nume_ddl)
  for m in MATR_ASSE:
    opti=m['OPTION']

    if opti in ( "RIGI_MECA","RIGI_FLUI_STRU","RIGI_MECA_LAGR" ,
       "MASS_MECA" , "MASS_FLUI_STRU" ,"RIGI_GEOM" ,"RIGI_ROTA",
       "AMOR_MECA","IMPE_MECA","MASS_ID_MDEP_R","MASS_ID_MDNS_R",
       "ONDE_FLUI","MASS_MECA_DIAG" ) : t=matr_asse_depl_r

    if opti in ( "RIGI_ACOU","MASS_ACOU","AMOR_ACOU",) : t=matr_asse_pres_c

    if opti in ( "RIGI_THER","MASS_THER","RIGI_THER_CONV" ,
       "RIGI_THER_CONV_D","MASS_ID_MTEM_R","MASS_ID_MTNS_R",) : t=matr_asse_temp_r

    if opti == "RIGI_MECA_HYST"   : t= matr_asse_depl_c

    self.type_sdprod(m['MATRICE'],t)
  return None

