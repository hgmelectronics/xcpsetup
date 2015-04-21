#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <IbemTool.h>
#include <Xcp_Interface_Registry.h>
#include <MultiselectList.h>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    QQmlApplicationEngine engine;

    qmlRegisterType<SetupTools::Xcp::Interface::QmlRegistry>("com.setuptools", 1, 0, "XcpInterfaceRegistry");
    qmlRegisterType<SetupTools::Xcp::Interface::Info>("com.setuptools", 1, 0, "XcpInterfaceInfo");
    qmlRegisterType<SetupTools::Xcp::Connection>("com.setuptools", 1, 0, "XcpConnectionState");  // for State enum
    qmlRegisterType<SetupTools::ProgFile>("com.setuptools", 1, 0, "ProgFile");  // for Type enum
    qmlRegisterType<SetupTools::Xcp::OpResultWrapper>("com.setuptools", 1, 0, "XcpOpResult");

    qmlRegisterType<SetupTools::IbemTool>("com.ebus.utils.ibemtool", 1, 0, "IbemTool");

    qmlRegisterType<MultiselectListWrapper>("com.ebus.ui.multiselectlist", 1, 0, "MultiselectListWrapper");
    qmlRegisterType<MultiselectListModel>("com.ebus.ui.multiselectlist", 1, 0, "MultiselectListModel");
    qmlRegisterType<MultiselectListController>("com.ebus.ui.multiselectlist", 1, 0, "MultiselectListController");
    qmlRegisterSingletonType<SetupTools::UrlUtil>("com.setuptools", 1, 0, "UrlUtil", &SetupTools::urlUtilProvider);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
