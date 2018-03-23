## makefile for Anacondas

#########################################################
## variables

## site-specific
GROUP = staff
SUDO =
TOP = /users/shared

## versioning
AVER = 5.1.0
PVER = 3
EVER = 36

## install dir
ANACONDA = $(PWD)/anaconda-$(AVER)
ENVIRON = $(ANACONDA)/envs/py$(EVER)
PYTHON_EXE = $(ENVIRON)/bin/python$(PVER)
PIP_EXE = $(ENVIRON)/bin/pip

## assumes already downloaded
SCRIPT = $(HOME)/Downloads/Anaconda$(PVER)-$(AVER)-MacOSX-x86_64.sh

#MAKE = /usr/bin/make

#########################################################
## rules

%.plist: %.clist
	awk '{print $$1}' $< | sort -u > $@
%.clist:
	$(ANACONDA)/bin/conda list -n > $@

#########################################################
## targets, etc

.PHONY: 

## (3) wordembeddings
we word wordembed: wordembeddings
	cd $< ; \
	  $(SUDO) git pull ; \
	  $(SUDO) $(PYTHON_EXE) ./setup.py sdist
	  cd - ; \
	  $(SUDO) $(PIP_EXE) $</dist/wordembeddings-*.tar.gz
wordembeddings:
	$(SUDO) git clone https://github.com/NationalSecurityAgency/wordembeddings.git

## (2.2) extra packages in environment
## note that  "make extra EXTRALIST=packagename"  is the preferred way to add more
EXTRALIST = argparse
extra: 
	/usr/bin/env EVER=$(EVER) PVER=$(PVER) AVER=$(AVER) ./installer.bash $(EXTRALIST)

## (2) desired packages in each environment
LOADLIST = madscience.list
load: perms
	for package in `egrep -v "^#|^conda|^anaconda|^python" $(LOADLIST) | awk '{print $$1}'` ; \
	  do \
	    $(MAKE) extra EXTRALIST=$$package ; \
	  done

## (1) create environments
env envs: perms py36 py27
	$(SUDO) $(ANACONDA)/bin/conda info -e
py36: $(ANACONDA)/envs/py36
$(ANACONDA)/envs/py36:
	$(SUDO) $(ANACONDA)/bin/conda create -n py36 --clone root
	@ $(MAKE) load EVER=36 PVER=3 LOADLIST=madscience.list
#	@ $(MAKE) word EVER=36 PVER=3 
py35: $(ANACONDA)/envs/py35
$(ANACONDA)/envs/py35:
	$(SUDO) $(ANACONDA)/bin/conda create -n py35 -y python=3.5
	@ $(MAKE) load EVER=35 PVER=3 LOADLIST=root.plist
	@ $(MAKE) load EVER=35 PVER=3 LOADLIST=madscience.list
#	@ $(MAKE) word EVER=35 PVER=3 
py27: $(ANACONDA)/envs/py27
$(ANACONDA)/envs/py27:
	$(SUDO) $(ANACONDA)/bin/conda create -n py27 -y python=2.7
	@ $(MAKE) load EVER=27 PVER=2 LOADLIST=root.plist
	@ $(MAKE) load EVER=27 PVER=2 LOADLIST=madscience.list
	@ $(MAKE) word EVER=27 PVER=2 

## (0) initial install of Anaconda
init: $(ANACONDA)
$(ANACONDA): $(SCRIPT)
	$(SUDO) bash $(SCRIPT) -b -p $(ANACONDA)
#	$(SUDO) ln -s $(ANACONDA)/bin/pip $(ANACONDA)/bin/pip$(PVER)
	$(ANACONDA)/bin/conda list -n root > root.clist
	awk '{print tolower($$1)}' root.clist | sort -u > root.plist
	$(SUDO) chmod g+s $(ANACONDA)

##
perms:
	$(SUDO) chgrp -R $(GROUP) $(ANACONDA)
	$(SUDO) find $(ANACONDA) -type d -exec chmod ug+w {} \;
## package lists
lists list:
	$(ANACONDA)/bin/conda list -n root > root.clist
	$(ANACONDA)/bin/conda list -n py36 > py36.clist
	$(ANACONDA)/bin/conda list -n py35 > py35.clist
	$(ANACONDA)/bin/conda list -n py27 > py27.clist
	awk '{print tolower($$1)}' root.clist | sort -u > root.plist
	awk '{print tolower($$1)}' py36.clist | sort -u > py36.plist
	awk '{print tolower($$1)}' py35.clist | sort -u > py35.plist
	awk '{print tolower($$1)}' py27.clist | sort -u > py27.plist

##
clean:
	$(RM) *~ *.log *.plist *.clist
realclean: clean
	$(RM) -r $(ANACONDA)

