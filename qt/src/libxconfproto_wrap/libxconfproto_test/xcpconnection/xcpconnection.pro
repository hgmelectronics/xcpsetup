#-------------------------------------------------
#
# Project created by QtCreator 2015-01-04T17:28:41
#
#-------------------------------------------------

QT       += core testlib

QT       -= gui

QMAKE_CXXFLAGS += -std=c++11

TARGET = elm327
CONFIG   += console
CONFIG   -= app_bundle

TEMPLATE = app


SOURCES += main.cpp \
    test.cpp \
    testingslave.cpp

win32:CONFIG(release, debug|release): LIBS += -L$$OUT_PWD/../../libxconfproto/release/ -llibxconfproto
else:win32:CONFIG(debug, debug|release): LIBS += -L$$OUT_PWD/../../libxconfproto/debug/ -llibxconfproto
else:unix: LIBS += -L$$OUT_PWD/../../libxconfproto/ -llibxconfproto

INCLUDEPATH += $$PWD/../../libxconfproto
DEPENDPATH += $$PWD/../../libxconfproto

HEADERS += \
    test.h \
    testingslave.h