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

    qmlRegisterType<SetupTools::Xcp::Interface::QmlRegistry>("com.setuptools.xcp", 1, 0, "InterfaceRegistry");
    qmlRegisterType<SetupTools::Xcp::Interface::Info>("com.setuptools.xcp", 1, 0, "InterfaceInfo");
    qmlRegisterType<SetupTools::Xcp::Connection>("com.setuptools.xcp", 1, 0, "ConnectionState");  // for State enum
    qmlRegisterType<SetupTools::ProgFile>("com.setuptools.xcp", 1, 0, "ProgFile");  // for Type enum
    qmlRegisterSingletonType<SetupTools::Xcp::OpResultWrapper>("com.setuptools.xcp", 1, 0, "OpResult", &SetupTools::Xcp::OpResultWrapper::create);

    qmlRegisterType<SetupTools::IbemTool>("com.ebus.utils.ibemtool", 1, 0, "IbemTool");

    qmlRegisterType<MultiselectListWrapper>("com.ebus.ui.multiselectlist", 1, 0, "MultiselectListWrapper");
    qmlRegisterType<MultiselectListModel>("com.ebus.ui.multiselectlist", 1, 0, "MultiselectListModel");
    qmlRegisterType<MultiselectListController>("com.ebus.ui.multiselectlist", 1, 0, "MultiselectListController");
    qmlRegisterSingletonType<SetupTools::UrlUtil>("com.setuptools", 1, 0, "UrlUtil", &SetupTools::UrlUtil::create);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
