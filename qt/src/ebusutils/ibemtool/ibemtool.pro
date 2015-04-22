TEMPLATE = app

QT += qml quick widgets

SOURCES += main.cpp \
    IbemTool.cpp

RESOURCES += qml.qrc

QMAKE_CXXFLAGS += -std=c++11

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

win32:CONFIG(release, debug|release): LIBS += -L$$OUT_PWD/../../../libxconfproto_wrap/Desktop-Release/libxconfproto/release/ -lxconfproto
else:win32:CONFIG(debug, debug|release): LIBS += -L$$OUT_PWD/../../../libxconfproto_wrap/Desktop-Debug/libxconfproto/debug/ -lxconfproto
else:unix:CONFIG(release, debug|release): LIBS += -L$$OUT_PWD/../../../libxconfproto_wrap/Desktop-Release/libxconfproto/ -lxconfproto
else:unix:CONFIG(debug, debug|release): LIBS += -L$$OUT_PWD/../../../libxconfproto_wrap/Desktop-Debug/libxconfproto/ -lxconfproto

INCLUDEPATH += $$PWD/../../libxconfproto_wrap/libxconfproto
DEPENDPATH += $$PWD/../../libxconfproto_wrap/libxconfproto

win32:CONFIG(release, debug|release): LIBS += -L$$OUT_PWD/../ebussetuptools/release/ -lebussetuptools
else:win32:CONFIG(debug, debug|release): LIBS += -L$$OUT_PWD/../ebussetuptools/debug/ -lebussetuptools
else:unix: LIBS += -L$$OUT_PWD/../ebussetuptools/ -lebussetuptools

INCLUDEPATH += $$PWD/../ebussetuptools
DEPENDPATH += $$PWD/../ebussetuptools

HEADERS += \
    IbemTool.h
