#-------------------------------------------------
#
# Project created by QtCreator 2015-04-12T13:55:33
#
#-------------------------------------------------

QT       += core serialport quick

QT       -= gui

TARGET = pgm_reset
CONFIG   += console
CONFIG   -= app_bundle

TEMPLATE = app

QMAKE_CXXFLAGS += -std=c++11


SOURCES += main.cpp \
    thingdoer.cpp

win32:CONFIG(release, debug|release): LIBS += -L$$OUT_PWD/../../libxconfproto/release/ -lxconfproto
else:win32:CONFIG(debug, debug|release): LIBS += -L$$OUT_PWD/../../libxconfproto/debug/ -lxconfproto
else:unix: LIBS += -L$$OUT_PWD/../../libxconfproto/ -lxconfproto

INCLUDEPATH += $$PWD/../../libxconfproto
DEPENDPATH += $$PWD/../../libxconfproto

HEADERS += \
    thingdoer.h
