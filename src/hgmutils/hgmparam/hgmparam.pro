TEMPLATE = app

QT += qml quick widgets serialport charts

SOURCES += main.cpp

RESOURCES += qml.qrc \
    $$PWD/../qml/com/hgmelectronics/utils/hgmutils.qrc \
    $$PWD/../../qml/com/hgmelectronics/setuptools/setuptools.qrc

QMAKE_CXXFLAGS += -std=c++14 -Wno-unused-local-typedefs -ffunction-sections -fdata-sections

static {
    QMAKE_CXXFLAGS +=  -ffunction-sections -fdata-sections
    QMAKE_LFLAGS += -static-libstdc++ -static-libgcc -Wl,--gc-sections
    win32: QMAKE_LFLAGS += -static -lwinpthread
    DEFINES += STATICQT
    RESOURCES += $$PWD/../../qml/qmldirs/qmldirs.qrc
}

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH += \
    $$PWD/../../qml \
    $$PWD/../qml

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

HEADERS +=


win32:RC_ICONS += ../qml/com/hgmelectronics/utils/hgmparam-icon.ico

DEPLOY_DIRS = $$OUT_PWD/../../deploy $${OUT_PWD}/../deploy
include($$PWD/../../winmacdeploy.pri)
