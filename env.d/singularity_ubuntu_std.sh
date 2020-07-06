# This file set the environment for code_aster.
# Configuration for Ubuntu 18 STD
export WAFBUILD_ENV=$(readlink -n -f ${BASH_SOURCE})

# DEVTOOLS_COMPUTER_ID avoids waf to re-source the environment
export DEVTOOLS_COMPUTER_ID=ubuntu18

# custom configuration
export CONFIG_PARAMETERS_addmem=800

export LIBPATH_HDF5="/opt/hdf5/lib"
export INCLUDES_HDF5="/opt/hdf5/include"

export LIBPATH_MED="/opt/med/lib"
export INCLUDES_MED="/opt/med/include"

export LIBPATH_METIS="/opt/metis/lib"
export INCLUDES_METIS="/opt/metis/include"

export LIBPATH_SCOTCH="/opt/scotch-seq/lib"
export INCLUDES_SCOTCH="/opt/scotch-seq/include"

export LIBPATH_MUMPS="/opt/mumps-seq/lib"
export INCLUDES_MUMPS="/opt/mumps-seq/include /opt/mumps-seq/include_seq"

export TFELHOME="/opt/tfel"
export LIBPATH_MFRONT="${TFELHOME}/lib"
export INCLUDES_MFRONT="${TFELHOME}/include"
export PYPATH_MFRONT="${TFELHOME}/lib/python3.6/site-packages"

export INCLUDES_BOOST="/usr/include"
export LIBPATH_BOOST="/usr/lib/x86_64-linux-gnu/"
export LIB_BOOST="boost_python3"


export LD_LIBRARY_PATH=${LIBPATH_HDF5}:${LIBPATH_MED}:${LIBPATH_METIS}:${LIBPATH_SCOTCH}:${LIBPATH_MUMPS}:${LIBPATH_MFRONT}:${LD_LIBRARY_PATH}

export PYTHONPATH=${PYPATH_MFRONT}:${PYTHONPATH}

export PATH=\
/opt/med/bin:\
/opt/homard/bin:\
${TFELHOME}/bin:\
/opt/miss3d/bin:\
/opt/ecrevisse/bin:\
${PATH}
