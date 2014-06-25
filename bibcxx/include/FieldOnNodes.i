%module libAster
%{
#include "FieldOnNodes.hpp"
%}

template<class ValueType>
class FieldOnNodes
{
    public:
        FieldOnNodes(char* name);
        ~FieldOnNodes();
};

%template(FieldOnNodesDouble) FieldOnNodes<double>;

%extend FieldOnNodes<double>
{
    double __getitem__(int i) const
    {
        return (*self)->operator[](i);
    }
}
