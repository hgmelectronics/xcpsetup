TEMPLATE = subdirs

SUBDIRS += \
    hgmflash \
    hgmparam

CONFIG(hgmparamonly) SUBDIRS = hgmparam
