TEMPLATE = app

QT += qml quick widgets serialport charts bluetooth

INCLUDEPATH += $$PWD/../../../../cots/boost_1_60_0

SOURCES += main.cpp

RESOURCES += qml.qrc \
    $$PWD/../../qml/com/hgmelectronics/setuptools/setuptools.qrc

QMAKE_CXXFLAGS += -std=c++14 -Wno-unused-local-typedefs -ffunction-sections -fdata-sections

static {
    QMAKE_CXXFLAGS +=  -ffunction-sections -fdata-sections
    QMAKE_LFLAGS += -static-libstdc++ -static-libgcc -Wl,--gc-sections
    win32: QMAKE_LFLAGS += -static -lwinpthread
    RESOURCES += $$PWD/../../qml/qmldirs/qmldirs.qrc
    DEFINES += STATICQT
}

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

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

win32:CONFIG(release, debug|release): {
    LIBS += -L$$OUT_PWD/../ebussetuptools/release/ -lebussetuptools
    PRE_TARGETDEPS += $$OUT_PWD/../ebussetuptools/release/libebussetuptools.a
}
else:win32:CONFIG(debug, debug|release): {
    LIBS += -L$$OUT_PWD/../ebussetuptools/debug/ -lebussetuptools
    PRE_TARGETDEPS += $$OUT_PWD/../ebussetuptools/debug/libebussetuptools.a
}
else:unix: {
    LIBS += -L$$OUT_PWD/../ebussetuptools/ -lebussetuptools
    PRE_TARGETDEPS += $$OUT_PWD/../ebussetuptools/libebussetuptools.a
}

INCLUDEPATH += $$PWD/../ebussetuptools
DEPENDPATH += $$PWD/../ebussetuptools

HEADERS +=

DEPLOY_DIRS = $$OUT_PWD/../../deploy
include($$PWD/../../winmacdeploy.pri)
