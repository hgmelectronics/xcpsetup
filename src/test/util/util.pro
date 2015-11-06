#-------------------------------------------------
#
# Project created by QtCreator 2015-08-03T08:12:00
#
#-------------------------------------------------

QT       += core testlib quick serialport

QT       -= gui

QMAKE_CXXFLAGS += -std=c++11 -Wall -Wuninitialized

TARGET = util
CONFIG   += console
CONFIG   -= app_bundle

TEMPLATE = app


SOURCES += main.cpp \
    test.cpp

win32:CONFIG(release, debug|release): {
    LIBS += -L$$OUT_PWD/../../libsetuptools/release/ -lsetuptools
    PRE_TARGETDEPS += $$OUT_PWD/../../libsetuptools/release/libsetuptools.a
}
else:win32:CONFIG(debug, debug|release): {
    LIBS += -L$$OUT_PWD/../../libsetuptools/debug/ -lsetuptools
    PRE_TARGETDEPS += $$OUT_PWD/../../libsetuptools/debug/libsetuptools.a
}
else:unix: {
    LIBS += -L$$OUT_PWD/../../libsetuptools/ -lsetuptools
    PRE_TARGETDEPS += $$OUT_PWD/../../libsetuptools/libsetuptools.a
}

INCLUDEPATH += $$PWD/../../libsetuptools
DEPENDPATH += $$PWD/../../libsetuptools

HEADERS += \
    test.h
