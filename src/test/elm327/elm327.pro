#-------------------------------------------------
#
# Project created by QtCreator 2015-01-01T10:50:43
#
#-------------------------------------------------

QT       += core serialport testlib quick bluetooth

QT       -= gui

INCLUDEPATH += $$PWD/../../../../cots/boost_1_60_0

QMAKE_CXXFLAGS += -std=c++14 -Wno-unused-local-typedefs -Wall -Wuninitialized

static {
    QMAKE_CXXFLAGS +=  -ffunction-sections -fdata-sections
    QMAKE_LFLAGS += -static-libstdc++ -static-libgcc -Wl,--gc-sections
    win32: QMAKE_LFLAGS += -static -lwinpthread
}

TARGET = elm327
CONFIG   += console
CONFIG   -= app_bundle

TEMPLATE = app


SOURCES += main.cpp \
    test.cpp

win32:CONFIG(release, debug|release): LIBS += -L$$OUT_PWD/../../libsetuptools/release/ -lsetuptools
else:win32:CONFIG(debug, debug|release): LIBS += -L$$OUT_PWD/../../libsetuptools/debug/ -lsetuptools
else:unix: LIBS += -L$$OUT_PWD/../../libsetuptools/ -lsetuptools

INCLUDEPATH += $$PWD/../../libsetuptools
DEPENDPATH += $$PWD/../../libsetuptools

HEADERS += \
    test.h
