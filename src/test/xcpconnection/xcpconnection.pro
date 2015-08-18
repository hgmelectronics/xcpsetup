#-------------------------------------------------
#
# Project created by QtCreator 2015-01-04T17:28:41
#
#-------------------------------------------------

QT       += core testlib quick

QT       -= gui

QMAKE_CXXFLAGS += -std=c++11 -Wno-unused-local-typedefs

static {
    QMAKE_CXXFLAGS +=  -ffunction-sections -fdata-sections
    QMAKE_LFLAGS += -static-libstdc++ -static-libgcc -Wl,--gc-sections
    win32: QMAKE_LFLAGS += -static -lwinpthread
}

TARGET = xcpconnection
CONFIG   += console
CONFIG   -= app_bundle

TEMPLATE = app


SOURCES += main.cpp \
    test.cpp \
    testingslave.cpp

win32:CONFIG(release, debug|release): LIBS += -L$$OUT_PWD/../../libsetuptools/release/ -lsetuptools
else:win32:CONFIG(debug, debug|release): LIBS += -L$$OUT_PWD/../../libsetuptools/debug/ -lsetuptools
else:unix: LIBS += -L$$OUT_PWD/../../libsetuptools/ -lsetuptools

INCLUDEPATH += $$PWD/../../libsetuptools
DEPENDPATH += $$PWD/../../libsetuptools

HEADERS += \
    test.h \
    testingslave.h
