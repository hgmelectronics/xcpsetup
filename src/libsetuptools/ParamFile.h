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
    Q_PROPERTY(QString name MEMBER mName WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(Type type MEMBER mType WRITE setType NOTIFY typeChanged)
    Q_PROPERTY(bool exists MEMBER mExists NOTIFY nameChanged)
    Q_PROPERTY(QString parseError READ parseError NOTIFY resultChanged)
    Q_PROPERTY(int result READ result NOTIFY resultChanged)
    Q_PROPERTY(QString resultString READ resultString NOTIFY resultChanged)
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
    void setName(QString newName);
    void setType(Type newType);
    QString parseError() { return mLastParseError; }
    Result result() { return mLastResult; }
    QString resultString() { return mLastResultString; }

    Q_INVOKABLE static QString resultString(int result);
    Q_INVOKABLE QVariantMap read();
    Q_INVOKABLE void write(QVariantMap map);
public slots:
signals:
    void nameChanged();
    void typeChanged();
    void resultChanged();
    void opComplete();
private:
    QVariantMap readJson(QFile &file);
    void writeJson(QFile &file, QVariantMap map);
    bool isTypeOk() const;
    void setResult(Result val);
    void setParseError(QString parseErrorString);

    QString mName;
    Type mType;
    bool mExists;
    Result mLastResult;
    QString mLastParseError;
    QString mLastResultString;
};

}   // namespace SetupTools

#endif // SETUPTOOLS_PARAMFILE_H

