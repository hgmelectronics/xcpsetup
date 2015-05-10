#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <Cs2Tool.h>
#include <Xcp_Interface_Registry.h>
int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    QQmlApplicationEngine engine;

    qmlRegisterType<SetupTools::Xcp::Interface::QmlRegistry>("com.setuptools.xcp", 1, 0, "InterfaceRegistry");
    qmlRegisterType<SetupTools::Xcp::Interface::Info>("com.setuptools.xcp", 1, 0, "InterfaceInfo");
    qmlRegisterType<SetupTools::Xcp::Connection>("com.setuptools.xcp", 1, 0, "ConnectionState");  // for State enum
    qmlRegisterType<SetupTools::ProgFile>("com.setuptools.xcp", 1, 0, "ProgFile");  // for Type enum
    qmlRegisterSingletonType<SetupTools::Xcp::OpResultWrapper>("com.setuptools.xcp", 1, 0, "OpResult", &SetupTools::Xcp::OpResultWrapper::create);

    qmlRegisterType<SetupTools::Cs2Tool>("com.hgmelectronics.utils.cs2tool", 1, 0, "Cs2Tool");

    qmlRegisterSingletonType<SetupTools::UrlUtil>("com.setuptools.xcp", 1, 0, "UrlUtil", &SetupTools::UrlUtil::create);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
