#-------------------------------------------------
#
# Project created by QtCreator 2015-08-03T08:12:00
#
#-------------------------------------------------

QT       += core testlib quick serialport

QT       -= gui

QMAKE_CXXFLAGS += -std=c++11

TARGET = libmemrange_test
CONFIG   += console
CONFIG   -= app_bundle

TEMPLATE = app


SOURCES += main.cpp \
    testingslave.cpp \
    test_base.cpp \
    test_scalar_range.cpp \
    test_table_range.cpp \
    test_slot.cpp \
    test_scalar_param.cpp \
    test_table_param.cpp

win32:CONFIG(release, debug|release): LIBS += -L$$OUT_PWD/../libxconfproto/release/ -lxconfproto
else:win32:CONFIG(debug, debug|release): LIBS += -L$$OUT_PWD/../libxconfproto/debug/ -lxconfproto
else:unix: LIBS += -L$$OUT_PWD/../libxconfproto/ -lxconfproto

win32:CONFIG(release, debug|release): LIBS += -L$$OUT_PWD/../libmemrange/release/ -lmemrange
else:win32:CONFIG(debug, debug|release): LIBS += -L$$OUT_PWD/../libmemrange/debug/ -lmemrange
else:unix: LIBS += -L$$OUT_PWD/../libmemrange/ -lmemrange

win32:CONFIG(release, debug|release): LIBS += -L$$OUT_PWD/../libxconfproto/release/ -lxconfproto
else:win32:CONFIG(debug, debug|release): LIBS += -L$$OUT_PWD/../libxconfproto/debug/ -lxconfproto
else:unix: LIBS += -L$$OUT_PWD/../libxconfproto/ -lxconfproto

INCLUDEPATH += $$PWD/../libxconfproto
DEPENDPATH += $$PWD/../libxconfproto
INCLUDEPATH += $$PWD/../libmemrange
DEPENDPATH += $$PWD/../libmemrange

HEADERS += \
    test.h \
    testingslave.h
