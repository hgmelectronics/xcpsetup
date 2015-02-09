#-------------------------------------------------
#
# Project created by QtCreator 2015-01-25T11:00:38
#
#-------------------------------------------------

QT       += core quick

QT       -= gui

TARGET = cs2readwrite
CONFIG   += console
CONFIG   -= app_bundle

TEMPLATE = app

QMAKE_CXXFLAGS += -std=c++11


SOURCES += main.cpp

win32:CONFIG(release, debug|release): LIBS += -L$$OUT_PWD/../../libxconfproto/release/ -lxconfproto
else:win32:CONFIG(debug, debug|release): LIBS += -L$$OUT_PWD/../../libxconfproto/debug/ -lxconfproto
else:unix: LIBS += -L$$OUT_PWD/../../libxconfproto/ -lxconfproto

INCLUDEPATH += $$PWD/../../libxconfproto
DEPENDPATH += $$PWD/../../libxconfproto

win32:CONFIG(release, debug|release): LIBS += -L$$OUT_PWD/../../qextserialport/release/ -lQt5ExtSerialPort
else:win32:CONFIG(debug, debug|release): LIBS += -L$$OUT_PWD/../../qextserialport/debug/ -lQt5ExtSerialPort
else:unix: LIBS += -L$$OUT_PWD/../../qextserialport/ -lQt5ExtSerialPort

INCLUDEPATH += $$PWD/../../qextserialport
DEPENDPATH += $$PWD/../../qextserialport
