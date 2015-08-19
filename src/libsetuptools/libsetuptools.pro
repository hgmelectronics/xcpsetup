#-------------------------------------------------
#
# Project created by QtCreator 2014-12-13T16:17:11
#
#-------------------------------------------------

QT       += network serialport quick qml

QT       -= gui

QMAKE_CXXFLAGS += -std=c++11 -ffunction-sections -fdata-sections

TARGET = setuptools
TEMPLATE = lib
CONFIG += staticlib

SOURCES += \
    util.cpp \
    Xcp_Connection.cpp \
    Xcp_Interface_Interface.cpp \
    Xcp_Interface_Can_Interface.cpp \
    Xcp_Interface_Can_Elm327_Interface.cpp \
    Xcp_Interface_Loopback_Interface.cpp \
    Xcp_Interface_Can_Registry.cpp \
    Xcp_ConnectionFacade.cpp \
    Xcp_Interface_Registry.cpp \
    FlashProg.cpp \
    ProgFile.cpp \
    Xcp_ProgramLayer.cpp \
    Xcp_Exception.cpp \
    SetupTools.cpp \
    Xcp_MemoryRangeTable.cpp \
    Xcp_MemoryRangeList.cpp \
    Xcp_MemoryRange.cpp \
    Xcp_ScalarMemoryRange.cpp \
    Xcp_TableMemoryRange.cpp \
    LinearTableAxis.cpp \
    Slot.cpp \
    LinearSlot.cpp \
    Xcp_ParamRegistry.cpp \
    Xcp_ScalarParam.cpp \
    Xcp_Param.cpp \
    Xcp_TableParam.cpp \
    TableAxis.cpp \
    ParamFile.cpp \
    Xcp_ParamLayer.cpp

HEADERS += \
    util.h \
    Xcp_Connection.h \
    Xcp_Interface_Interface.h \
    Xcp_Interface_Can_Interface.h \
    Xcp_Interface_Can_Elm327_Interface.h \
    Xcp_Exception.h \
    Xcp_Interface_Loopback_Interface.h \
    Xcp_Interface_Can_Registry.h \
    Xcp_ConnectionFacade.h \
    Xcp_Interface_Registry.h \
    FlashProg.h \
    ProgFile.h \
    Xcp_ProgramLayer.h \
    SetupTools.h \
    Xcp_MemoryRangeTable.h \
    Xcp_MemoryRange.h \
    Xcp_MemoryRangeList.h \
    Xcp_ScalarMemoryRange.h \
    Xcp_TableMemoryRange.h \
    LinearTableAxis.h \
    Slot.h \
    LinearSlot.h \
    Xcp_ParamRegistry.h \
    Xcp_ScalarParam.h \
    Xcp_Param.h \
    Xcp_TableParam.h \
    TableAxis.h \
    ParamFile.h \
    Xcp_ParamLayer.h

unix {
    target.path = /usr/lib
    INSTALLS += target
}

win32 {
    DEFINES += SPINWAIT
}

CONFIG(debug) DEFINES += ELM327_DEBUG

DISTFILES += \
    datatablenotes.txt