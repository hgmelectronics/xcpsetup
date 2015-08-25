TEMPLATE = subdirs

SUBDIRS += \
    ebussetuptools \
    ibemtool \
    multilist_demo

ibemtool.depends = ebussetuptools
multilist_demo.depends = ebussetuptools
