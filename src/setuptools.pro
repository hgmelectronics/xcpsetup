TEMPLATE = subdirs
SUBDIRS += ebusutils \
        hgmutils \
        libxconfproto \
        libxconfproto_examples \
        libxconfproto_test \
    libmemrange

libxconfproto.subdir = libxconfproto
libxconfproto_examples.depends = libxconfproto
libxconfproto_test.depends = libxconfproto
hgmutils.depends = libxconfproto
ebusutils.depends = libxconfproto
libmemrange.depends = libxconfproto
