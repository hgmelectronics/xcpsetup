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
#include "Xcp_TableParam.h"
#include "LinearSlot.h"
#include "LinearTableAxis.h"
#include "ParamFile.h"

namespace SetupTools
{

void registerTypes()
{
    qmlRegisterType<SetupTools::Xcp::Interface::QmlRegistry>("com.setuptools.xcp", 1, 0, "InterfaceRegistry");
    qmlRegisterType<SetupTools::Xcp::Interface::Info>("com.setuptools.xcp", 1, 0, "InterfaceInfo");
    qmlRegisterType<SetupTools::Xcp::Connection>("com.setuptools.xcp", 1, 0, "ConnectionState");  // for State enum
    qmlRegisterType<SetupTools::ProgFile>("com.setuptools.xcp", 1, 0, "ProgFile");  // for Type enum
    qmlRegisterSingletonType<SetupTools::Xcp::OpResultWrapper>("com.setuptools.xcp", 1, 0, "OpResult", &SetupTools::Xcp::OpResultWrapper::create);
    qmlRegisterSingletonType<SetupTools::UrlUtil>("com.setuptools.xcp", 1, 0, "UrlUtil", &SetupTools::UrlUtil::create);
    qmlRegisterUncreatableType<SetupTools::Xcp::ParamLayer>("com.setuptools.xcp", 1, 0, "ParamLayer", "SetupTools::Xcp::ParamLayer is uncreatable from within QML");
    qmlRegisterType<SetupTools::Xcp::ParamRegistry>("com.setuptools.xcp", 1, 0, "ParamRegistry");
    qmlRegisterUncreatableType<SetupTools::Xcp::Param>("com.setuptools.xcp", 1, 0, "Param", "SetupTools::Xcp::Param is uncreatable from within QML");
    qmlRegisterType<SetupTools::Xcp::ScalarParam>("com.setuptools.xcp", 1, 0, "ScalarParam");
    qmlRegisterType<SetupTools::Xcp::TableParam>("com.setuptools.xcp", 1, 0, "TableParam");
    qmlRegisterUncreatableType<SetupTools::Xcp::TableParamListModel>("com.setuptools.xcp", 1, 0, "TableParamListModel", "SetupTools::Xcp::TableParamListModel is uncreatable from within QML");
    qmlRegisterUncreatableType<SetupTools::Xcp::MemoryRange>("com.setuptools.xcp", 1, 0, "MemoryRange", "SetupTools::Xcp::MemoryRange is uncreatable from within QML");
    qmlRegisterUncreatableType<SetupTools::Slot>("com.setuptools", 1, 0, "Slot", "SetupTools::Slot is uncreatable from within QML");
    qmlRegisterType<SetupTools::LinearSlot>("com.setuptools", 1, 0, "LinearSlot");
    qmlRegisterUncreatableType<SetupTools::TableAxis>("com.setuptools", 1, 0, "TableAxis", "SetupTools::TableAxis is uncreatable from within QML");
    qmlRegisterType<SetupTools::LinearTableAxis>("com.setuptools", 1, 0, "LinearTableAxis");
    qmlRegisterType<SetupTools::ParamFile>("com.setuptools", 1, 0, "ParamFile");
}

}
