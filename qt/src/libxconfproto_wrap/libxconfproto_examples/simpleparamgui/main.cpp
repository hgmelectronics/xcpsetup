#include <QtGui/QGuiApplication>
#include <QtQml>
#include <Xcp_Interface_Can_Elm327_Interface.h>
#include <Xcp_Connection.h>
#include <Xcp_ConnectionFacade.h>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    qmlRegisterType<SetupTools::Xcp::Interface::QmlRegistry>("com.setuptools", 1, 0, "XcpInterfaceRegistry");
    qmlRegisterType<SetupTools::Xcp::Interface::Info>("com.setuptools", 1, 0, "XcpInterfaceInfo");
    qmlRegisterType<SetupTools::Xcp::Connection>("com.setuptools", 1, 0, "XcpConnection");  // for State enum
    qmlRegisterType<SetupTools::Xcp::OpResultWrapper>("com.setuptools", 1, 0, "XcpOpResult");
    qmlRegisterType<SetupTools::Xcp::SimpleDataLayer>("com.setuptools", 1, 0, "XcpSimpleDataLayer");

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
