# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH =

TEMPLATE = app

# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += main.cpp

QT += qml quick widgets serialport

RESOURCES += qml.qrc

QMAKE_CXXFLAGS += -std=c++11 -Wno-unused-local-typedefs

static {
    QMAKE_CXXFLAGS +=  -ffunction-sections -fdata-sections
    QMAKE_LFLAGS += -static-libstdc++ -static-libgcc -Wl,--gc-sections
    win32: QMAKE_LFLAGS += -static -lwinpthread
}

# Installation path
# target.path =

# Please do not modify the following two lines. Required for deployment.
include(deployment.pri)

win32:CONFIG(release, debug|release): LIBS += -L$$OUT_PWD/../../libsetuptools/release/ -lsetuptools
else:win32:CONFIG(debug, debug|release): LIBS += -L$$OUT_PWD/../../libsetuptools/debug/ -lsetuptools
else:unix: LIBS += -L$$OUT_PWD/../../libsetuptools/ -lsetuptools

INCLUDEPATH += $$PWD/../../libsetuptools
DEPENDPATH += $$PWD/../../libsetuptools

OTHER_FILES += \
    main.qml \
    MainForm.qml
