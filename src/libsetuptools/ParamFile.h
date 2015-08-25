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
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(Type type READ type WRITE setType NOTIFY typeChanged)
    Q_PROPERTY(bool exists READ exists NOTIFY nameChanged)
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
        FileReadFail,
        InvalidType,
        FileWriteFail
    };

    ParamFile(QObject *parent = 0);
    QString name();
    void setName(QString newName);
    Type type();
    void setType(Type newType);
    bool exists();

    Q_INVOKABLE static QString resultString(int result);
public slots:
    Result read(QMap<QString, QVariant> &mapOut);
    Result write(const QMap<QString, QVariant> &map);
signals:
    void nameChanged();
    void typeChanged();
    void parseError(QString info);
private:
    Result readJson(QFile &file, QMap<QString, QVariant> &mapOut);
    Result writeJson(QFile &file, const QMap<QString, QVariant> &map);
    bool isTypeOk() const;

    QString mName;
    Type mType;
    bool mExists;
};

}   // namespace SetupTools

#endif // SETUPTOOLS_PARAMFILE_H

