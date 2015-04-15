#ifndef PROGFILE_H
#define PROGFILE_H

#include <QFile>
#include "FlashProg.h"

namespace SetupTools
{

class ProgFile : public QObject
{
    Q_OBJECT
    Q_ENUMS(Type)
    Q_ENUMS(Result)
    Q_PROPERTY(QString name READ name WRITE setName)
    Q_PROPERTY(Type type READ type WRITE setType)
    Q_PROPERTY(bool valid READ valid NOTIFY validChanged)
    Q_PROPERTY(FlashProg *prog READ progPtr)
public:
    enum Type
    {
        Invalid = 0,
        Srec
    };

    enum Result
    {
        Ok,
        CorruptedFile,
        FileOpenFail,
        InvalidType
    };

    ProgFile(QObject *parent = 0);
    QString name();
    void setName(QString newName);
    Type type();
    void setType(Type newType);
    bool valid();
    FlashProg *progPtr();
    FlashProg &prog();
    const FlashProg &prog() const;
public slots:
    Result read();
signals:
    void validChanged();
private:
    Result readSrec(QFile &file);

    QString mName;
    Type mType;
    bool mValid;
    FlashProg mProg;
};

}   // namespace SetupTools

#endif // PROGFILE_H
