#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <SetupTools.h>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    app.setOrganizationName("Ebus");
    app.setOrganizationDomain("ebus.com");
    app.setApplicationName("CDA2 Parameter Editor");

    QQmlApplicationEngine engine;

#ifdef STATICQT
    engine.setImportPathList({"qrc:/", "qrc:/QtQuick/Dialogs/"});
#else
    engine.addImportPath("qrc:/");
#endif

    SetupTools::registerTypes();

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
