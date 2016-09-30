TEMPLATE = subdirs

SUBDIRS += \
    cda2tool \
    ebussetuptools \
	ibemparam \
    ibemtool \
    multilist_demo \
	ytbtool

ibemtool.depends = ebussetuptools
multilist_demo.depends = ebussetuptools
