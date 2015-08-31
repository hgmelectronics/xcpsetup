TEMPLATE = subdirs
SUBDIRS += \
libsetuptools \
hgmutils \
examples \
test

libsetuptools.subdir = libsetuptools
hgmutils.depends = libsetuptools
