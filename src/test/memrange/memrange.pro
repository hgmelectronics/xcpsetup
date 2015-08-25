#-------------------------------------------------
#
# Project created by QtCreator 2015-08-03T08:12:00
#
#-------------------------------------------------

QT       += core testlib quick serialport

QT       -= gui

QMAKE_CXXFLAGS += -std=c++11

TARGET = memrange
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

win32:CONFIG(release, debug|release): LIBS += -L$$OUT_PWD/../../libsetuptools/release/ -lsetuptools
else:win32:CONFIG(debug, debug|release): LIBS += -L$$OUT_PWD/../../libsetuptools/debug/ -lsetuptools
else:unix: LIBS += -L$$OUT_PWD/../../libsetuptools/ -lsetuptools

INCLUDEPATH += $$PWD/../../libsetuptools
DEPENDPATH += $$PWD/../../libsetuptools

HEADERS += \
    test.h \
    testingslave.h
