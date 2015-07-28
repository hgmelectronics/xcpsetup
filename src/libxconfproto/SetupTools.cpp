#include <QQmlApplicationEngine>
#include <QtQml>
#include "SetupTools.h"
#include "ProgFile.h"
#include "Xcp_ProgramLayer.h"
#include "Xcp_Connection.h"
#include "Xcp_Interface_Registry.h"

namespace SetupTools
{

void LIBXCONFPROTOSHARED_EXPORT registerTypes()
{

    qmlRegisterType<SetupTools::Xcp::Interface::QmlRegistry>("com.setuptools.xcp", 1, 0, "InterfaceRegistry");
    qmlRegisterType<SetupTools::Xcp::Interface::Info>("com.setuptools.xcp", 1, 0, "InterfaceInfo");
    qmlRegisterType<SetupTools::Xcp::Connection>("com.setuptools.xcp", 1, 0, "ConnectionState");  // for State enum
    qmlRegisterType<SetupTools::ProgFile>("com.setuptools.xcp", 1, 0, "ProgFile");  // for Type enum
    qmlRegisterSingletonType<SetupTools::Xcp::OpResultWrapper>("com.setuptools.xcp", 1, 0, "OpResult", &SetupTools::Xcp::OpResultWrapper::create);
    qmlRegisterSingletonType<SetupTools::UrlUtil>("com.setuptools.xcp", 1, 0, "UrlUtil", &SetupTools::UrlUtil::create);

}

}
