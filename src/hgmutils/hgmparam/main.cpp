#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <SetupTools.h>
#include <QProcessEnvironment>

int main(int argc, char *argv[])
{
    qputenv("QMLSCENE_DEVICE", "softwarecontext");

    QApplication app(argc, argv);
    app.setOrganizationName("HGM Automotive Electronics");
    app.setOrganizationDomain("hgmelectronics.com");
    app.setApplicationName("CS2 Parameter Editor");

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
