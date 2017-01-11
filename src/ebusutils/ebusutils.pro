TEMPLATE = subdirs

SUBDIRS += \
    cda2tool \
    ebussetuptools \
	ibemparam \
    ibemtool \
	ipcparam \
    multilist_demo \
	ytbtool

cda2tool.depends = ebussetuptools
ibemtool.depends = ebussetuptools
multilist_demo.depends = ebussetuptools
