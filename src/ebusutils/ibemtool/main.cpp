#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <IbemTool.h>
#include <SetupTools.h>
#include <MultiselectList.h>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    app.setOrganizationName("Ebus Inc");
    app.setOrganizationDomain("ebus.com");
    app.setApplicationName("BMS Flash Tool");

    QQmlApplicationEngine engine;

#ifdef STATICQT
    engine.setImportPathList({"qrc:/", "qrc:/QtQuick/Dialogs/"});
#else
    engine.addImportPath("qrc:/");
#endif

    SetupTools::registerTypes();

    qmlRegisterType<SetupTools::IbemTool>("com.ebus.utils.ibemtool", 1, 0, "IbemTool");
    qmlRegisterType<MultiselectListWrapper>("com.ebus.ui.multiselectlist", 1, 0, "MultiselectListWrapper");
    qmlRegisterType<MultiselectListModel>("com.ebus.ui.multiselectlist", 1, 0, "MultiselectListModel");
    qmlRegisterType<MultiselectListController>("com.ebus.ui.multiselectlist", 1, 0, "MultiselectListController");

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
