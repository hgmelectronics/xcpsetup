#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <Cda2Tool.h>
#include <SetupTools.h>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    QQmlApplicationEngine engine;

#ifdef STATICQT
    engine.setImportPathList({"qrc:/", "qrc:/QtQuick/Dialogs/"});
#endif

    SetupTools::registerTypes();

    qmlRegisterType<SetupTools::Cda2Tool>("com.ebus.utils.cda2tool", 1, 0, "Cda2Tool");


    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
