#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <Cs2Tool.h>
#include <SetupTools.h>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    QQmlApplicationEngine engine;

#ifdef STATICQT
    engine.setImportPathList({"qrc:/", "qrc:/QtQuick/Dialogs/"});
#endif

    SetupTools::registerTypes();

    qmlRegisterType<SetupTools::Cs2Tool>("com.hgmelectronics.utils.cs2tool", 1, 0, "Cs2Tool");

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
