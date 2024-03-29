#include <QApplication>
#include <QQmlApplicationEngine>
#include "SetupTools.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

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
