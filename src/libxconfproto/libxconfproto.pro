#-------------------------------------------------
#
# Project created by QtCreator 2014-12-13T16:17:11
#
#-------------------------------------------------

QT       += network serialport quick

QT       -= gui

QMAKE_CXXFLAGS += -std=c++11

TARGET = xconfproto
TEMPLATE = lib

DEFINES += LIBXCONFPROTO_LIBRARY

SOURCES += \
    util.cpp \
    Xcp_Connection.cpp \
    Xcp_Interface_Interface.cpp \
    Xcp_Interface_Can_Interface.cpp \
    Xcp_Interface_Can_Elm327_Interface.cpp \
    Xcp_Interface_Loopback_Interface.cpp \
    Xcp_Interface_Can_Registry.cpp \
    Xcp_ConnectionFacade.cpp \
    Xcp_Interface_Registry.cpp \
    FlashProg.cpp \
    ProgFile.cpp \
    Xcp_ProgramLayer.cpp \
    Xcp_Exception.cpp
    SetupTools.cpp

HEADERS += \
    libxconfproto_global.h \
    util.h \
    Xcp_Connection.h \
    Xcp_Interface_Interface.h \
    Xcp_Interface_Can_Interface.h \
    Xcp_Interface_Can_Elm327_Interface.h \
    Xcp_Exception.h \
    Xcp_Interface_Loopback_Interface.h \
    Xcp_Interface_Can_Registry.h \
    Xcp_ConnectionFacade.h \
    Xcp_Interface_Registry.h \
    FlashProg.h \
    ProgFile.h \
    Xcp_ProgramLayer.h \
    SetupTools.h

unix {
    target.path = /usr/lib
    INSTALLS += target
}

win32 {
    DEFINES += SPINWAIT
}

CONFIG(debug) DEFINES += ELM327_DEBUG

DISTFILES += \
    datatablenotes.txt
