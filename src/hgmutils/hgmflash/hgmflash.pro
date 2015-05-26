TEMPLATE = app

QT += qml quick widgets serialport

SOURCES += main.cpp \
    Cs2Tool.cpp

RESOURCES += qml.qrc

QMAKE_CXXFLAGS += -std=c++11 -Wno-unused-local-typedefs
QMAKE_LFLAGS += -static-libstdc++ -static-libgcc -static -lwinpthread
QMAKE_CXXFLAGS += -ffunction-sections -fdata-sections
QMAKE_LFLAGS += -Wl,--gc-sections

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

win32:CONFIG(release, debug|release): LIBS += -L$$OUT_PWD/../../libxconfproto/release/ -lxconfproto
else:win32:CONFIG(debug, debug|release): LIBS += -L$$OUT_PWD/../../libxconfproto/debug/ -lxconfproto
else:unix: LIBS += -L$$OUT_PWD/../../libxconfproto/ -lxconfproto

INCLUDEPATH += $$PWD/../../libxconfproto
DEPENDPATH += $$PWD/../../libxconfproto

HEADERS += \
    Cs2Tool.h

win32:RC_ICONS += hgmflash.ico
