#-------------------------------------------------
#
# Project created by QtCreator 2015-01-01T10:50:43
#
#-------------------------------------------------

QT       += core testlib quick

QT       -= gui

QMAKE_CXXFLAGS += -std=c++11

TARGET = elm327
CONFIG   += console
CONFIG   -= app_bundle

TEMPLATE = app


SOURCES += main.cpp \
    test.cpp

win32:CONFIG(release, debug|release): LIBS += -L$$OUT_PWD/../../libxconfproto/release/ -lxconfproto
else:win32:CONFIG(debug, debug|release): LIBS += -L$$OUT_PWD/../../libxconfproto/debug/ -lxconfproto
else:unix: LIBS += -L$$OUT_PWD/../../libxconfproto/ -lxconfproto

INCLUDEPATH += $$PWD/../../libxconfproto
DEPENDPATH += $$PWD/../../libxconfproto

HEADERS += \
    test.h

win32:CONFIG(release, debug|release): LIBS += -L$$OUT_PWD/../../qextserialport/release/ -lQt5ExtSerialPort
else:win32:CONFIG(debug, debug|release): LIBS += -L$$OUT_PWD/../../qextserialport/debug/ -lQt5ExtSerialPort
else:unix: LIBS += -L$$OUT_PWD/../../qextserialport/ -lQt5ExtSerialPort

INCLUDEPATH += $$PWD/../../qextserialport
DEPENDPATH += $$PWD/../../qextserialport
