TEMPLATE = subdirs
SUBDIRS += ebusutils \
        hgmutils \
        libsetuptools \
        examples \
        test

libsetuptools.subdir = libsetuptools
examples.depends = libsetuptools
test.depends = libsetuptools
hgmutils.depends = libsetuptools
ebusutils.depends = libsetuptools
