# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH =

TEMPLATE = app

# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += main.cpp

QT += qml quick widgets

RESOURCES += qml.qrc

QMAKE_CXXFLAGS += -std=c++11

# Installation path
# target.path =

# Please do not modify the following two lines. Required for deployment.
include(deployment.pri)

win32:CONFIG(release, debug|release): LIBS += -L$$OUT_PWD/../../libxconfproto/release/ -lxconfproto
else:win32:CONFIG(debug, debug|release): LIBS += -L$$OUT_PWD/../../libxconfproto/debug/ -lxconfproto
else:unix: LIBS += -L$$OUT_PWD/../../libxconfproto/ -lxconfproto

INCLUDEPATH += $$PWD/../../libxconfproto
DEPENDPATH += $$PWD/../../libxconfproto

OTHER_FILES += \
    main.qml \
    MainForm.qml

win32:CONFIG(release, debug|release): LIBS += -L$$OUT_PWD/../../qextserialport/release/ -lQt5ExtSerialPort
else:win32:CONFIG(debug, debug|release): LIBS += -L$$OUT_PWD/../../qextserialport/debug/ -lQt5ExtSerialPort
else:unix: LIBS += -L$$OUT_PWD/../../qextserialport/ -lQt5ExtSerialPort

INCLUDEPATH += $$PWD/../../qextserialport
DEPENDPATH += $$PWD/../../qextserialport