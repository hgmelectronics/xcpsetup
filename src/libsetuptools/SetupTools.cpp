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
#include "Xcp_TableParam.h"
#include "Xcp_TableMemoryRange.h"
#include "LinearSlot.h"
#include "LinearTableAxis.h"
#include "EncodingSlot.h"
#include "ParamFile.h"

namespace SetupTools
{


void registerTypes()
{
    static const int major = 1;
    static const int minor = 0;

    qmlRegisterType<SetupTools::Xcp::Interface::QmlRegistry>("com.setuptools.xcp", major, minor, "InterfaceRegistry");
    qmlRegisterType<SetupTools::Xcp::Interface::Info>("com.setuptools.xcp", major, minor, "InterfaceInfo");
    qmlRegisterType<SetupTools::Xcp::Connection>("com.setuptools.xcp", major, minor, "ConnectionState");  // for State enum
    qmlRegisterSingletonType<SetupTools::ProgFile>("com.setuptools.xcp", major, minor, "ProgFile", &SetupTools::ProgFile::create);  // for its static functions
    qmlRegisterType<SetupTools::FlashProg>("com.setuptools", major, minor, "FlashProg");
    qmlRegisterSingletonType<SetupTools::Xcp::OpResultWrapper>("com.setuptools.xcp", major, minor, "OpResult", &SetupTools::Xcp::OpResultWrapper::create);
    qmlRegisterSingletonType<SetupTools::UrlUtil>("com.setuptools.xcp", major, minor, "UrlUtil", &SetupTools::UrlUtil::create);
    qmlRegisterUncreatableType<SetupTools::Xcp::ParamLayer>("com.setuptools.xcp", major, minor, "ParamLayer", "SetupTools::Xcp::ParamLayer is uncreatable from within QML");

    qmlRegisterType<SetupTools::Xcp::ParamRegistry>("com.setuptools.xcp", major, minor, "ParamRegistry");
    qmlRegisterType<SetupTools::ParamFile>("com.setuptools", major, minor, "ParamFile");

    qmlRegisterUncreatableType<SetupTools::Xcp::Param>("com.setuptools.xcp", major, minor, "Param", "SetupTools::Xcp::Param is uncreatable from within QML");
    qmlRegisterUncreatableType<SetupTools::Xcp::MemoryRange>("com.setuptools.xcp", major, minor, "MemoryRange", "SetupTools::Xcp::MemoryRange is uncreatable from within QML");

    qmlRegisterType<SetupTools::Xcp::ScalarParam>("com.setuptools.xcp", major, minor, "ScalarParam");
    qmlRegisterUncreatableType<SetupTools::Xcp::ScalarMemoryRange>("com.setuptools.xcp", major, minor, "ScalarMemoryRange", "SetupTools::Xcp::ScalarMemoryRange is uncreatable from within QML");

    qmlRegisterType<SetupTools::Xcp::TableParam>("com.setuptools.xcp", major, minor, "TableParam");
    qmlRegisterUncreatableType<SetupTools::Xcp::TableMemoryRange>("com.setuptools.xcp", major, minor, "TableMemoryRange", "SetupTools::Xcp::TableMemoryRange is uncreatable from within QML");
    qmlRegisterUncreatableType<SetupTools::Xcp::TableParamListModel>("com.setuptools.xcp", major, minor, "TableParamListModel", "SetupTools::Xcp::TableParamListModel is uncreatable from within QML");


    qmlRegisterUncreatableType<SetupTools::Slot>("com.setuptools", major, minor, "Slot", "SetupTools::Slot is uncreatable from within QML");
    qmlRegisterType<SetupTools::LinearSlot>("com.setuptools", major, minor, "LinearSlot");
    qmlRegisterType<SetupTools::EncodingSlot>("com.setuptools", major, minor, "EncodingSlot");

    qmlRegisterUncreatableType<SetupTools::TableAxis>("com.setuptools", major, minor, "TableAxis", "SetupTools::TableAxis is uncreatable from within QML");
    qmlRegisterType<SetupTools::LinearTableAxis>("com.setuptools", major, minor, "LinearTableAxis");
}

}
