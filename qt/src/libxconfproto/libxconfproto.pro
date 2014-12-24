#-------------------------------------------------
#
# Project created by QtCreator 2014-12-13T16:17:11
#
#-------------------------------------------------

QT       += network serialport

QT       -= gui

QMAKE_CXXFLAGS += -std=c++11

TARGET = libxconfproto
TEMPLATE = lib

DEFINES += LIBXCONFPROTO_LIBRARY

SOURCES += xcpconnection.cpp \
    caninterface.cpp \
    interface.cpp \
    elm327caninterface.cpp \
    util.cpp

HEADERS += xcpconnection.h\
        libxconfproto_global.h \
    caninterface.h \
    interface.h \
    elm327caninterface.h \
    util.h

unix {
    target.path = /usr/lib
    INSTALLS += target
}
