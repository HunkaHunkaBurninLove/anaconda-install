#!/bin/bash

############################################
## variables

## site-specific
SUDO=
#SUDO=sudo

## version defaults
## environment
if [ -z ${EVER} ]; then
    EVER=36
fi
## python
if [ -z ${PVER} ]; then
    PVER=3
fi
## anaconda
if [ -z ${AVER} ]; then
    AVER=5.0.0
fi

## installdir
ANACONDA=${PWD}/anaconda-${AVER}
ENVIRON=${ANACONDA}/envs/py${EVER}
#PYTHON_EXE=${ENVIRON}/bin/python${PVER}

############################################
## do it

for package in ${*} ; do 
  echo 
  #echo "================================================" 
  echo "CONDA ${package}"
  
  ret=`${SUDO} ${ANACONDA}/bin/conda install -y -q -n py${EVER} ${package}`
  echo "ret= ${ret}" 
  success=`echo ${ret} | egrep -i installed\|downgraded | wc -l` 
  echo 
  echo "  conda_success= ${success}"
  
  if [ ${success} == 0 ] ; then 
      echo 
      echo "PIP ${package}"
      echo
      ${SUDO} /usr/bin/env LC_ALL=C ${ENVIRON}/bin/pip install \
	      --prefix ${ENVIRON} ${package}
  fi
  
  echo 
  echo "================================================"
  echo
done

