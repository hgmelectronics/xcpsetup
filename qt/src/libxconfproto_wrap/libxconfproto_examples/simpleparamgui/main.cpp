#include <QtGui/QGuiApplication>
#include <QtQml>
#include <Xcp_Interface_Can_Elm327_Interface.h>
#include <Xcp_Connection.h>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    qmlRegisterSingletonType<SetupTools::Xcp::Interface::Can::Registry>("com.setuptools", 1, 0, "XcpCanInterfaceRegistry", SetupTools::Xcp::Interface::Can::registryProvider);
    qmlRegisterType<SetupTools::Xcp::Interface::Can::Info>("com.setuptools", 1, 0, "XcpCanInterfaceInfo");
    qmlRegisterInterface<SetupTools::Xcp::Interface::Can::Interface>("XcpCanInterface");
    qmlRegisterType<SetupTools::Xcp::Interface::Interface>("com.setuptools", 1, 0, "XcpInterface");
    //qmlRegisterType<QQmlListProperty<SetupTools::Xcp::Interface::Can::Info> >("com.setuptools", 1, 0, "XcpCanInterfaceInfoList");
    //qmlRegisterType<SetupTools::Xcp::Interface::Can::Elm327::Interface>("com.setuptools", 1, 0, "Elm327Interface");
    qmlRegisterType<SetupTools::Xcp::Connection>("com.setuptools", 1, 0, "XcpConnection");
    qmlRegisterType<SetupTools::Xcp::SimpleDataLayer>("com.setuptools", 1, 0, "XcpSimpleDataLayer");

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
