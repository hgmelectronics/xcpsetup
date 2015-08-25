#ifndef PROGFILE_H
#define PROGFILE_H

#include <QFile>
#include <QQmlEngine>
#include "FlashProg.h"

namespace SetupTools
{

class ProgFile : public QObject
{
    Q_OBJECT
public:
    ProgFile(QObject *parent = nullptr);

    static QObject *create(QQmlEngine *engine, QJSEngine *scriptEngine);

    Q_INVOKABLE static SetupTools::FlashProg *readSrec(QString path);
};

}   // namespace SetupTools

#endif // PROGFILE_H
