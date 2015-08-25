#-------------------------------------------------
#
# Project created by QtCreator 2015-04-16T18:12:06
#
#-------------------------------------------------

QT       -= gui
QT       += quick

QMAKE_CXXFLAGS += -std=c++11 -ffunction-sections -fdata-sections

TARGET = ebussetuptools
TEMPLATE = lib
CONFIG += staticlib

SOURCES += MultiselectList.cpp

HEADERS += MultiselectList.h

unix {
    target.path = /usr/lib
    INSTALLS += target
}
