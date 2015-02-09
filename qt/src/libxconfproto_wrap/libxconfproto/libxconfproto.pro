#-------------------------------------------------
#
# Project created by QtCreator 2014-12-13T16:17:11
#
#-------------------------------------------------

QT       += quick

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
    Xcp_Interface_Can_Registry.cpp

HEADERS += \
    libxconfproto_global.h \
    util.h \
    Xcp_Connection.h \
    Xcp_Interface_Interface.h \
    Xcp_Interface_Can_Interface.h \
    Xcp_Interface_Can_Elm327_Interface.h \
    Xcp_Exception.h \
    Xcp_Interface_Loopback_Interface.h \
    Xcp_Interface_Can_Registry.h

unix {
    target.path = /usr/lib
    INSTALLS += target
}

win32:CONFIG(release, debug|release): LIBS += -L$$OUT_PWD/../qextserialport/release/ -lQt5ExtSerialPort
else:win32:CONFIG(debug, debug|release): LIBS += -L$$OUT_PWD/../qextserialport/debug/ -lQt5ExtSerialPort
else:unix: LIBS += -L$$OUT_PWD/../qextserialport/ -lQt5ExtSerialPort

INCLUDEPATH += $$PWD/../qextserialport
DEPENDPATH += $$PWD/../qextserialport
