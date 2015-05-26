TEMPLATE = app

QT += qml quick widgets

SOURCES += main.cpp

RESOURCES += qml.qrc

QMAKE_CXXFLAGS += -std=c++11 -Wno-unused-local-typedefs

static {
    QMAKE_CXXFLAGS +=  -ffunction-sections -fdata-sections
    QMAKE_LFLAGS += -static-libstdc++ -static-libgcc -Wl,--gc-sections
    win32: QMAKE_LFLAGS += -static -lwinpthread
}

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

HEADERS +=

win32:CONFIG(release, debug|release): LIBS += -L$$OUT_PWD/../ebussetuptools/release/ -lebussetuptools
else:win32:CONFIG(debug, debug|release): LIBS += -L$$OUT_PWD/../ebussetuptools/debug/ -lebussetuptools
else:unix: LIBS += -L$$OUT_PWD/../ebussetuptools/ -lebussetuptools

INCLUDEPATH += $$PWD/../ebussetuptools
DEPENDPATH += $$PWD/../ebussetuptools
