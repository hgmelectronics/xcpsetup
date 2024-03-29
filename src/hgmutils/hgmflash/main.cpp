#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <Cs2Tool.h>
#include <SetupTools.h>
#include <QPixmap>
#include <QSplashScreen>

int main(int argc, char *argv[])
{
    SetupTools::setupEnvironment();

    QApplication app(argc, argv);
    app.setOrganizationName("HGM Automotive Electronics");
    app.setOrganizationDomain("hgmelectronics.com");
    app.setApplicationName("HGM Flash Tool");

    QPixmap logo(":/com/hgmelectronics/utils/COMPUSHIFT logo.png");
    QSplashScreen splash(logo);
    splash.show();
    QGuiApplication::setOverrideCursor(QCursor(Qt::WaitCursor));

    QQmlApplicationEngine engine;

#ifdef STATICQT
    engine.setImportPathList({"qrc:/", "qrc:/QtQuick/Dialogs/"});
#else
    engine.addImportPath("qrc:/");
#endif

    SetupTools::registerTypes();

    qmlRegisterType<SetupTools::Cs2Tool>("com.hgmelectronics.utils.cs2tool", 1, 0, "Cs2Tool");

    engine.load(QUrl(QStringLiteral("qrc:/hgmflash.qml")));

    QGuiApplication::restoreOverrideCursor();
    splash.close();

    return app.exec();
}
