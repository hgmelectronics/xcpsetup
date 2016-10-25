#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <SetupTools.h>
#include "Xcp_EbusEventLogInterface.h"

int main(int argc, char *argv[])
{
//    qputenv("QMLSCENE_DEVICE", "softwarecontext");

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
    qmlRegisterType<SetupTools::Xcp::EbusEventLogInterface>("com.hgmelectronics.setuptools.xcp", 1, 0, "EbusEventLogInterface");

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
