#include <QtGui/QGuiApplication>
#include <QtQml>
#include <Xcp_Interface_Can_Elm327_Interface.h>
#include <Xcp_Connection.h>
#include "qtquick2applicationviewer.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    //qmlRegisterType<SetupTools::Xcp::Interface::Can::Elm327::Interface>("com.setuptools", 1, 0, "Elm327Interface");
    qmlRegisterType<SetupTools::Xcp::Connection>("com.setuptools", 1, 0, "XcpConnection");

    QtQuick2ApplicationViewer viewer;
    viewer.setMainQmlFile(QStringLiteral("qml/simpleparamgui/main.qml"));
    viewer.showExpanded();

    return app.exec();
}
