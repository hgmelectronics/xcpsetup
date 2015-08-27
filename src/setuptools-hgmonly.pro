TEMPLATE = subdirs
SUBDIRS += \
libsetuptools \
hgmutils


libsetuptools.subdir = libsetuptools
hgmutils.depends = libsetuptools
