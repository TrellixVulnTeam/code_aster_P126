#ifndef LINEARSOLVER_H_
#define LINEARSOLVER_H_

#include <boost/shared_ptr.hpp>
#include <list>
#include <set>
#include <string>

#include "LinearAlgebra/AllowedLinearSolver.h"

using namespace std;

/* person_in_charge: nicolas.sellenet at edf.fr */

// Ces wrappers sont la pour autoriser que les set soitent const
// Sinon, on aurait pas pu passer directement des const set<> en parametre template
struct WrapMultFront
{
    static const set< Renumbering > setOfAllowedRenumbering;
};

struct WrapLdlt
{
    static const set< Renumbering > setOfAllowedRenumbering;
};

struct WrapMumps
{
    static const set< Renumbering > setOfAllowedRenumbering;
};

struct WrapPetsc
{
    static const set< Renumbering > setOfAllowedRenumbering;
};

struct WrapGcpc
{
    static const set< Renumbering > setOfAllowedRenumbering;
};

/**
* class PhysicalQuantity
* @author Nicolas Sellenet
*/
template< class Wrapping >
class RenumberingChecker
{
    public:
        static bool isAllowedRenumbering( Renumbering test )
        {
            if ( Wrapping::setOfAllowedRenumbering.find( test ) == Wrapping::setOfAllowedRenumbering.end() )
                return false;
            return true;
        }
};

typedef RenumberingChecker< WrapMultFront > MultFrontRenumberingChecker;
typedef RenumberingChecker< WrapLdlt > LdltRenumberingChecker;
typedef RenumberingChecker< WrapMumps > MumpsRenumberingChecker;
typedef RenumberingChecker< WrapPetsc > PetscRenumberingChecker;
typedef RenumberingChecker< WrapGcpc > GcpcRenumberingChecker;

class SolverChecker
{
    public:
        static bool isAllowedRenumberingForSolver( LinearSolverEnum solver, Renumbering renumber )
        {
            switch ( solver )
            {
                case MultFront:
                    return MultFrontRenumberingChecker::isAllowedRenumbering( renumber );
                case Ldlt:
                    return LdltRenumberingChecker::isAllowedRenumbering( renumber );
                case Mumps:
                    return MumpsRenumberingChecker::isAllowedRenumbering( renumber );
                case Petsc:
                    return PetscRenumberingChecker::isAllowedRenumbering( renumber );
                case Gcpc:
                    return GcpcRenumberingChecker::isAllowedRenumbering( renumber );
                default:
                    throw "Not a valid linear solver";
            }
        };
};

class LinearSolverInstance
{
    private:
        LinearSolverEnum _linearSolver;
        Renumbering      _renumber;

    public:
        LinearSolverInstance(const LinearSolverEnum currentLinearSolver, const Renumbering currentRenumber):
                    _linearSolver( currentLinearSolver ),
                    _renumber( currentRenumber )
        {
            SolverChecker::isAllowedRenumberingForSolver( currentLinearSolver, currentRenumber );
        };

        string getSolverName()
        {
            return LinearSolverNames[ (int)_linearSolver ];
        };

        string getRenumburingName()
        {
            return RenumberingNames[ (int)_renumber ];
        };
};

/**
* class LinearSolver
*   Enveloppe d'un pointeur intelligent vers un LinearSolverInstance
* @author Nicolas Sellenet
*/
class LinearSolver
{
    public:
        typedef boost::shared_ptr< LinearSolverInstance > LinearSolverPtr;

    private:
        LinearSolverPtr _linearSolverPtr;

    public:
        LinearSolver( const LinearSolverEnum currentLinearSolver,
                      const Renumbering currentRenumber ): _linearSolverPtr()
        {
            _linearSolverPtr = LinearSolverPtr( new LinearSolverInstance( currentLinearSolver,
                                                                          currentRenumber ) );
        };

        ~LinearSolver()
        {};

        LinearSolver& operator=(const LinearSolver& tmp)
        {
            _linearSolverPtr = tmp._linearSolverPtr;
            return *this;
        };

        const LinearSolverPtr& operator->() const
        {
            return _linearSolverPtr;
        };

        LinearSolverInstance& operator*(void) const
        {
            return *_linearSolverPtr;
        };

        bool isEmpty() const
        {
            if ( _linearSolverPtr.use_count() == 0 ) return true;
            return false;
        };
};

#endif /* LINEARSOLVER_H_ */
