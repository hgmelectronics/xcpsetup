#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <Cs2Tool.h>
#include <Xcp_Interface_Registry.h>
int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    QQmlApplicationEngine engine;

    qmlRegisterType<SetupTools::Xcp::Interface::QmlRegistry>("com.setuptools", 1, 0, "XcpInterfaceRegistry");
    qmlRegisterType<SetupTools::Xcp::Interface::Info>("com.setuptools", 1, 0, "XcpInterfaceInfo");
    qmlRegisterType<SetupTools::Xcp::Connection>("com.setuptools", 1, 0, "XcpConnectionState");  // for State enum
    qmlRegisterType<SetupTools::ProgFile>("com.setuptools", 1, 0, "ProgFile");  // for Type enum
    qmlRegisterType<SetupTools::Xcp::OpResultWrapper>("com.setuptools", 1, 0, "XcpOpResult");

    qmlRegisterType<SetupTools::Cs2Tool>("com.hgmelectronics.utils.cs2tool", 1, 0, "Cs2Tool");

    qmlRegisterSingletonType<SetupTools::UrlUtil>("com.setuptools", 1, 0, "UrlUtil", &SetupTools::urlUtilProvider);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
