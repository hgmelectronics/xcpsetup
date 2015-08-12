#ifndef SETUPTOOLS_PARAMFILE_H
#define SETUPTOOLS_PARAMFILE_H

#include <QObject>
#include <QFile>
#include <QMap>
#include <QVariant>

namespace SetupTools
{

class ParamFile : public QObject
{
    Q_OBJECT
    Q_ENUMS(Type)
    Q_ENUMS(Result)
    Q_PROPERTY(QString name READ name WRITE setName)
    Q_PROPERTY(Type type READ type WRITE setType)
    Q_PROPERTY(bool valid READ valid NOTIFY mapChanged)
public:
    enum Type
    {
        Invalid = 0,
        Json
    };

    enum Result
    {
        Ok,
        CorruptedFile,
        FileOpenFail,
        InvalidType,
        FileWriteFail
    };

    ParamFile(QObject *parent = 0);
    QString name();
    void setName(QString newName);
    Type type();
    void setType(Type newType);
    bool valid();
    QMap<QString, QVariant> &map();
public slots:
    Result read();
    Result write();
signals:
    void mapChanged();
    void jsonParseError(QString info);
private:
    Result readJson(QFile &file);
    Result writeJson(QFile &file);
    bool isTypeOk() const;

    QString mName;
    Type mType;
    bool mValid;
    QMap<QString, QVariant> mMap;
};

}   // namespace SetupTools

#endif // SETUPTOOLS_PARAMFILE_H

