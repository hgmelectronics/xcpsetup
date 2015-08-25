TEMPLATE = subdirs
SUBDIRS += hgmutils \
        libsetuptools

libsetuptools.subdir = libsetuptools
hgmutils.depends = libsetuptools
