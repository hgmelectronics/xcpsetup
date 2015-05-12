#-------------------------------------------------
#
# Project created by QtCreator 2015-04-16T18:12:06
#
#-------------------------------------------------

QT       -= gui
QT       += quick

QMAKE_CXXFLAGS += -std=c++11

TARGET = ebussetuptools
TEMPLATE = lib

DEFINES += EBUSSETUPTOOLS_LIBRARY

SOURCES += MultiselectList.cpp

HEADERS += MultiselectList.h\
        ebussetuptools_global.h

unix {
    target.path = /usr/lib
    INSTALLS += target
}
