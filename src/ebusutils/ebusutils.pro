TEMPLATE = subdirs

SUBDIRS += \
    cda2tool \
    ebussetuptools \
    ibemtool \
    multilist_demo

ibemtool.depends = ebussetuptools
multilist_demo.depends = ebussetuptools
