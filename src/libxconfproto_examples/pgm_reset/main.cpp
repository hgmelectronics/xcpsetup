#include <QCoreApplication>

#include "thingdoer.h"

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);

    ThingDoer doer;

    QTimer::singleShot(0, &doer, &ThingDoer::start);

    app.exec();
}
