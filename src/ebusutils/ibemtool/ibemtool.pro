TEMPLATE = app

QT += qml quick widgets serialport

SOURCES += main.cpp \
    IbemTool.cpp

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


win32:CONFIG(release, debug|release): LIBS += -L$$OUT_PWD/../../libxconfproto/release/ -lxconfproto
else:win32:CONFIG(debug, debug|release): LIBS += -L$$OUT_PWD/../../libxconfproto/debug/ -lxconfproto
else:unix: LIBS += -L$$OUT_PWD/../../libxconfproto/ -lxconfproto

INCLUDEPATH += $$PWD/../../libxconfproto
DEPENDPATH += $$PWD/../../libxconfproto

win32:CONFIG(release, debug|release): LIBS += -L$$OUT_PWD/../ebussetuptools/release/ -lebussetuptools
else:win32:CONFIG(debug, debug|release): LIBS += -L$$OUT_PWD/../ebussetuptools/debug/ -lebussetuptools
else:unix: LIBS += -L$$OUT_PWD/../ebussetuptools/ -lebussetuptools

INCLUDEPATH += $$PWD/../ebussetuptools
DEPENDPATH += $$PWD/../ebussetuptools

HEADERS += \
    IbemTool.h
