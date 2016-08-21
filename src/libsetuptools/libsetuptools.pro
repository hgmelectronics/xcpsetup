#-------------------------------------------------
#
# Project created by QtCreator 2014-12-13T16:17:11
#
#-------------------------------------------------

QT       += network serialport quick qml charts

QT       -= gui

QMAKE_CXXFLAGS += -std=c++11 -ffunction-sections -fdata-sections -Wall -Wuninitialized

TARGET = setuptools
TEMPLATE = lib
CONFIG += staticlib

DEFINES += HG_VERSION=\\\"$$system(hg id -i)\\\"

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
    Slot.cpp \
    LinearSlot.cpp \
    Xcp_ParamRegistry.cpp \
    Xcp_ScalarParam.cpp \
    Xcp_Param.cpp \
    Xcp_ParamLayer.cpp \
    EncodingSlot.cpp \
    Xcp_ArrayMemoryRange.cpp \
    Xcp_ArrayParam.cpp \
    SlotArrayModel.cpp \
    TransposeProxyModel.cpp \
    TableMapperModel.cpp \
    ModelListProxy.cpp \
    JSONParamFile.cpp \
    Xcp_Interface_Can_Socket_Interface.cpp \
    ScaleOffsetProxyModel.cpp \
    SlotProxyModel.cpp \
    Xcp_VarArrayParam.cpp \
    Xcp_TestingSlave.cpp \
    RoleXYModelMapper.cpp \
    XYSeriesAutoAxis.cpp \
    CSVParamFile.cpp \
    ModelStringProxy.cpp \
    Xcp_Interface_Can_J2534_Interface.cpp \
    Xcp_Interface_Can_J2534_Library.cpp

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
    Slot.h \
    LinearSlot.h \
    Xcp_ParamRegistry.h \
    Xcp_ScalarParam.h \
    Xcp_Param.h \
    Xcp_ParamLayer.h \
    EncodingSlot.h \
    Xcp_ArrayMemoryRange.h \
    Xcp_ArrayParam.h \
    TransposeProxyModel.h \
    TableMapperModel.h \
    ModelListProxy.h \
    JSONParamFile.h \
    Xcp_Interface_Can_Socket_Interface.h \
    SlotArrayModel.h \
    ScaleOffsetProxyModel.h \
    SlotProxyModel.h \
    Xcp_VarArrayParam.h \
    Xcp_TestingSlave.h \
    RoleXYModelMapper.h \
    XYSeriesAutoAxis.h \
    CSVParamFile.h \
    ModelStringProxy.h \
    Xcp_Interface_Can_J2534_Interface.h \
    Xcp_Interface_Can_J2534_Library.h

unix:!android {
    target.path = /usr/lib
    INSTALLS += target
    DEFINES += SOCKETCAN
}

win32 {
    DEFINES += SPINWAIT
    DEFINES += J2534_INTFC
}

#CONFIG(debug) DEFINES += ELM327_DEBUG

DISTFILES += \
    datatablenotes.txt
