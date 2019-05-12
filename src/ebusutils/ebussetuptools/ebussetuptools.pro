#-------------------------------------------------
#
# Project created by QtCreator 2015-04-16T18:12:06
#
#-------------------------------------------------

QT       -= gui
QT       += quick

QMAKE_CXXFLAGS += -std=c++14 -ffunction-sections -fdata-sections

TARGET = ebussetuptools
TEMPLATE = lib
CONFIG += staticlib

INCLUDEPATH += $$PWD/../../libsetuptools
DEPENDPATH += $$PWD/../../libsetuptools

SOURCES += MultiselectList.cpp \
    Xcp_EbusEventLogInterface.cpp

HEADERS += MultiselectList.h \
    Xcp_EbusEventLogInterface.h

unix {
    target.path = /usr/lib
    INSTALLS += target
}
