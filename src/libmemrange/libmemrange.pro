#-------------------------------------------------
#
# Project created by QtCreator 2015-05-13T17:31:39
#
#-------------------------------------------------

QT       += qml

QT       -= gui

TARGET = libmemrange
TEMPLATE = lib
CONFIG += staticlib
QMAKE_CXXFLAGS += -std=c++11

SOURCES +=  \
    MemoryRange.cpp \
    MemoryRangeBase.cpp \
    MemoryRangeTable.cpp


HEADERS += \
    MemoryRange.h \
    MemoryRangeBase.h \
    MemoryRangeTable.h

INCLUDEPATH += $$PWD/../libxconfproto

DEPENDPATH += $$PWD/../libxconfproto

# Default rules for deployment.
#include(deployment.pri)


win32:CONFIG(release, debug|release): LIBS += -L$$OUT_PWD/../libxconfproto/release/ -lxconfproto
else:win32:CONFIG(debug, debug|release): LIBS += -L$$OUT_PWD/../libxconfproto/debug/ -lxconfproto
else:unix: LIBS += -L$$OUT_PWD/../libxconfproto/ -lxconfproto
