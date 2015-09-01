#include <QQmlApplicationEngine>
#include <QtQml>
#include "SetupTools.h"
#include "ProgFile.h"
#include "Xcp_ProgramLayer.h"
#include "Xcp_Connection.h"
#include "Xcp_Interface_Registry.h"
#include "Xcp_ParamLayer.h"
#include "Xcp_ParamRegistry.h"
#include "Xcp_ScalarParam.h"
#include "Xcp_ScalarMemoryRange.h"
#include "Xcp_ArrayParam.h"
#include "Xcp_ArrayMemoryRange.h"
#include "LinearSlot.h"
#include "EncodingSlot.h"
#include "ParamFile.h"
#include "TransposeProxyModel.h"
#include "TableMapperModel.h"
#include "SlotArrayModel.h"

namespace SetupTools
{


void registerTypes()
{
    static constexpr int major = 1;
    static constexpr int minor = 0;

    qmlRegisterType<SetupTools::Xcp::Interface::QmlRegistry>("com.hgmelectronics.setuptools.xcp", major, minor, "InterfaceRegistry");
    qmlRegisterType<SetupTools::Xcp::Interface::Info>("com.hgmelectronics.setuptools.xcp", major, minor, "InterfaceInfo");
    qmlRegisterType<SetupTools::Xcp::Connection>("com.hgmelectronics.setuptools.xcp", major, minor, "ConnectionState");  // for State enum
    qmlRegisterSingletonType<SetupTools::ProgFile>("com.hgmelectronics.setuptools.xcp", major, minor, "ProgFile", &SetupTools::ProgFile::create);  // for its static functions
    qmlRegisterType<SetupTools::FlashProg>("com.hgmelectronics.setuptools", major, minor, "FlashProg");
    qmlRegisterSingletonType<SetupTools::Xcp::OpResultWrapper>("com.hgmelectronics.setuptools.xcp", major, minor, "OpResult", &SetupTools::Xcp::OpResultWrapper::create);
    qmlRegisterSingletonType<SetupTools::UrlUtil>("com.hgmelectronics.setuptools.xcp", major, minor, "UrlUtil", &SetupTools::UrlUtil::create);
    qmlRegisterUncreatableType<SetupTools::Xcp::ParamLayer>("com.hgmelectronics.setuptools.xcp", major, minor, "ParamLayer", "SetupTools::Xcp::ParamLayer is uncreatable from within QML");

    qmlRegisterType<SetupTools::Xcp::ParamRegistry>("com.hgmelectronics.setuptools.xcp", major, minor, "ParamRegistry");
    qmlRegisterType<SetupTools::ParamFile>("com.hgmelectronics.setuptools", major, minor, "ParamFile");

    qmlRegisterUncreatableType<SetupTools::Xcp::Param>("com.hgmelectronics.setuptools.xcp", major, minor, "Param", "SetupTools::Xcp::Param is uncreatable from within QML");
    qmlRegisterUncreatableType<SetupTools::Xcp::MemoryRange>("com.hgmelectronics.setuptools.xcp", major, minor, "MemoryRange", "SetupTools::Xcp::MemoryRange is uncreatable from within QML");

    qmlRegisterType<SetupTools::Xcp::ScalarParam>("com.hgmelectronics.setuptools.xcp", major, minor, "ScalarParam");
    qmlRegisterUncreatableType<SetupTools::Xcp::ScalarMemoryRange>("com.hgmelectronics.setuptools.xcp", major, minor, "ScalarMemoryRange", "SetupTools::Xcp::ScalarMemoryRange is uncreatable from within QML");

    qmlRegisterType<SetupTools::Xcp::ArrayParam>("com.hgmelectronics.setuptools.xcp", major, minor, "ArrayParam");
    qmlRegisterUncreatableType<SetupTools::Xcp::ArrayMemoryRange>("com.hgmelectronics.setuptools.xcp", major, minor, "ArrayMemoryRange", "SetupTools::Xcp::ArrayMemoryRange is uncreatable from within QML");
    qmlRegisterUncreatableType<SetupTools::Xcp::ArrayParamModel>("com.hgmelectronics.setuptools.xcp", major, minor, "ArrayParamModel", "SetupTools::Xcp::ArrayParamModel is uncreatable from within QML");

    qmlRegisterUncreatableType<SetupTools::Slot>("com.hgmelectronics.setuptools", major, minor, "Slot", "SetupTools::Slot is uncreatable from within QML");
    qmlRegisterType<SetupTools::LinearSlot>("com.hgmelectronics.setuptools", major, minor, "LinearSlot");
    qmlRegisterType<SetupTools::EncodingSlot>("com.hgmelectronics.setuptools", major, minor, "EncodingSlot");

    qmlRegisterType<SetupTools::SlotArrayModel>("com.hgmelectronics.setuptools", major, minor, "SlotArrayModel");
    qmlRegisterType<SetupTools::TransposeProxyModel>("com.hgmelectronics.setuptools", major, minor, "TransposeProxyModel");
    qmlRegisterType<SetupTools::TableMapperModel>("com.hgmelectronics.setuptools", major, minor, "TableMapperModel");
}

}
