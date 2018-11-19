from code_aster.Commands import FORMULE

def Solu_Manu() :

        try:
          # Import du module de calcul symbolique Sympy
          import sympy
          sympy_available = True
          # cet import inutile est du au plantage sur la machine clpaster (fiche 17434)
          import numpy
        except ImportError:
          sympy_available = False


        if sympy_available:

          X,Y = sympy.symbols('X Y');

        # Definition de la solution manufacturee
          T=100*(X**6+Y**6);


        # Deduction de la fonction source de chaleur, ie: S=-laplacien(F(X,Y))
          S=-Lambda*(sympy.diff(sympy.diff(T,X),X)+sympy.diff(sympy.diff(T,Y),Y));


        # Deduction des conditions de Neumann
          N=Lambda*sympy.diff(T,X);


        # Transformation des formules Sympy en formules Aster
          TT=FORMULE(NOM_PARA=('X','Y'),VALE=str(T));
          SS=FORMULE(NOM_PARA=('X','Y'),VALE=str(S));
          NN=FORMULE(NOM_PARA=('X','Y'),VALE=str(N));

        # Si importation de sympy impossible
        else:

        #================================================================================================
        # Definition des formules Aster
        #================================================================================================

          TT=FORMULE(NOM_PARA=('X','Y'),VALE='100*X**6 + 100*Y**6');
          SS=FORMULE(NOM_PARA=('X','Y'),VALE='-45000*X**4 - 45000*Y**4');
          NN=FORMULE(NOM_PARA=('X','Y'),VALE='9000*X**5');
      
        return TT, SS, NN
