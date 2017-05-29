#include <QQmlApplicationEngine>
#include <QtQml>
#include <QQuickWindow>
#include "SetupTools.h"
#include "ParamRegistry.h"
#include "ProgFile.h"
#include "Xcp_ProgramLayer.h"
#include "Xcp_Connection.h"
#include "Xcp_Interface_Registry.h"
#include "Xcp_ParamLayer.h"
#include "ScalarParam.h"
#include "ArrayParam.h"
#include "LinearSlot.h"
#include "EncodingSlot.h"
#include "JSONParamFile.h"
#include "CSVParamFile.h"
#include "TransposeProxyModel.h"
#include "TableMapperModel.h"
#include "SlotArrayModel.h"
#include "ScaleOffsetProxyModel.h"
#include "SlotProxyModel.h"
#include "ModelListProxy.h"
#include "ModelStringProxy.h"
#include "RoleXYModelMapper.h"
#include "XYSeriesAutoAxis.h"
namespace SetupTools
{


void registerTypes()
{
    static constexpr int major = 1;
    static constexpr int minor = 0;

    qmlRegisterType<SetupTools::Xcp::Interface::QmlRegistry>("com.hgmelectronics.setuptools.xcp", major, minor, "InterfaceRegistry");
    qmlRegisterType<SetupTools::Xcp::Connection>("com.hgmelectronics.setuptools.xcp", major, minor, "ConnectionState");  // for State enum
    qmlRegisterSingletonType<SetupTools::ProgFile>("com.hgmelectronics.setuptools.xcp", major, minor, "ProgFile", &SetupTools::ProgFile::create);  // for its static functions
    qmlRegisterType<SetupTools::FlashProg>("com.hgmelectronics.setuptools", major, minor, "FlashProg");
    qmlRegisterSingletonType<SetupTools::OpResultWrapper>("com.hgmelectronics.setuptools.xcp", major, minor, "OpResult", &SetupTools::OpResultWrapper::create);
    qmlRegisterSingletonType<SetupTools::UrlUtil>("com.hgmelectronics.setuptools.xcp", major, minor, "UrlUtil", &SetupTools::UrlUtil::create);
    qmlRegisterSingletonType<SetupTools::Clipboard>("com.hgmelectronics.setuptools", major, minor, "Clipboard", &SetupTools::Clipboard::create);
    qmlRegisterSingletonType<SetupTools::AppVersion>("com.hgmelectronics.setuptools", major, minor, "AppVersion", &SetupTools::AppVersion::create);
    qmlRegisterType<SetupTools::Xcp::ParamLayer>("com.hgmelectronics.setuptools.xcp", major, minor, "ParamLayer");
    qmlRegisterType<SetupTools::TabSeparated>("com.hgmelectronics.setuptools", major, minor, "TabSeparated");

    qmlRegisterType<SetupTools::ParamRegistry>("com.hgmelectronics.setuptools", major, minor, "ParamRegistry");
    qmlRegisterType<SetupTools::JSONParamFile>("com.hgmelectronics.setuptools", major, minor, "JSONParamFile");
    qmlRegisterType<SetupTools::CSVParamFile>("com.hgmelectronics.setuptools", major, minor, "CSVParamFile");

    qmlRegisterUncreatableType<SetupTools::Param>("com.hgmelectronics.setuptools.xcp", major, minor, "Param", "SetupTools::Param is uncreatable from within QML");
    qmlRegisterType<SetupTools::ScalarParam>("com.hgmelectronics.setuptools", major, minor, "ScalarParam");
    qmlRegisterType<SetupTools::ArrayParam>("com.hgmelectronics.setuptools", major, minor, "ArrayParam");

    qmlRegisterUncreatableType<SetupTools::Slot>("com.hgmelectronics.setuptools", major, minor, "Slot", "SetupTools::Slot is uncreatable from within QML");
    qmlRegisterType<SetupTools::LinearSlot>("com.hgmelectronics.setuptools", major, minor, "LinearSlot");
    qmlRegisterType<SetupTools::EncodingSlot>("com.hgmelectronics.setuptools", major, minor, "EncodingSlot");

    qmlRegisterType<SetupTools::SlotArrayModel>("com.hgmelectronics.setuptools", major, minor, "SlotArrayModel");
    qmlRegisterType<SetupTools::TransposeProxyModel>("com.hgmelectronics.setuptools", major, minor, "TransposeProxyModel");
    qmlRegisterType<SetupTools::ScaleOffsetProxyModel>("com.hgmelectronics.setuptools", major, minor, "ScaleOffsetProxyModel");
    qmlRegisterType<SetupTools::SlotProxyModel>("com.hgmelectronics.setuptools", major, minor, "SlotProxyModel");
    qmlRegisterType<SetupTools::TableMapperModel>("com.hgmelectronics.setuptools", major, minor, "TableMapperModel");
    qmlRegisterType<SetupTools::ModelListProxy>("com.hgmelectronics.setuptools", major, minor, "ModelListProxy");
    qmlRegisterType<SetupTools::ModelStringProxy>("com.hgmelectronics.setuptools", major, minor, "ModelStringProxy");
    qmlRegisterType<SetupTools::RoleXYModelMapper>("com.hgmelectronics.setuptools.ui", major, minor, "RoleXYModelMapper");
    qmlRegisterType<SetupTools::XYSeriesAutoAxis>("com.hgmelectronics.setuptools.ui", major, minor, "XYSeriesAutoAxis");
}

void setupEnvironment()
{
    QQuickWindow::setSceneGraphBackend(QSGRendererInterface::Software);
}

}
