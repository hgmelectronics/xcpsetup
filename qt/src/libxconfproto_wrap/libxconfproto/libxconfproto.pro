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

SOURCES += \
    util.cpp \
    Xcp_Connection.cpp \
    Xcp_Interface_Interface.cpp \
    Xcp_Interface_Can_Interface.cpp \
    Xcp_Interface_Can_Elm327_Interface.cpp \
    Xcp_Interface_Loopback_Interface.cpp

HEADERS += \
    libxconfproto_global.h \
    util.h \
    Xcp_Connection.h \
    Xcp_Interface_Interface.h \
    Xcp_Interface_Can_Interface.h \
    Xcp_Interface_Can_Elm327_Interface.h \
    Xcp_Exception.h \
    Xcp_Interface_Loopback_Interface.h

unix {
    target.path = /usr/lib
    INSTALLS += target
}
