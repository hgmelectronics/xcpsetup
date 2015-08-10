#-------------------------------------------------
#
# Project created by QtCreator 2015-05-13T17:31:39
#
#-------------------------------------------------

QT       += qml

QT       -= gui

TARGET = memrange
TEMPLATE = lib
CONFIG += staticlib
QMAKE_CXXFLAGS += -std=c++11

SOURCES +=  \
    Xcp_MemoryRangeTable.cpp \
    Xcp_MemoryRangeList.cpp \
    Xcp_MemoryRange.cpp \
    Xcp_ScalarMemoryRange.cpp \
    Xcp_TableMemoryRange.cpp \
    LinearTableAxis.cpp


HEADERS += \
    Xcp_MemoryRangeTable.h \
    Xcp_MemoryRange.h \
    Xcp_MemoryRangeList.h \
    Xcp_ScalarMemoryRange.h \
    Xcp_TableMemoryRange.h \
    LinearTableAxis.h

INCLUDEPATH += $$PWD/../libxconfproto

DEPENDPATH += $$PWD/../libxconfproto

# Default rules for deployment.
#include(deployment.pri)

