#include <QtGui/QGuiApplication>
#include <QtQml>
#include <Xcp_Interface_Can_Elm327_Interface.h>
#include <Xcp_Connection.h>
#include <Xcp_ConnectionFacade.h>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    qmlRegisterType<SetupTools::Xcp::Interface::QmlRegistry>("com.setuptools.xcp", 1, 0, "InterfaceRegistry");
    qmlRegisterType<SetupTools::Xcp::Interface::Info>("com.setuptools.xcp", 1, 0, "InterfaceInfo");
    qmlRegisterType<SetupTools::Xcp::Connection>("com.setuptools.xcp", 1, 0, "ConnectionState");  // for State enum
    qmlRegisterSingletonType<SetupTools::Xcp::OpResultWrapper>("com.setuptools.xcp", 1, 0, "OpResult", &SetupTools::Xcp::OpResultWrapper::create);
    qmlRegisterType<SetupTools::Xcp::SimpleDataLayer>("com.setuptools.xcp", 1, 0, "SimpleDataLayer");

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
