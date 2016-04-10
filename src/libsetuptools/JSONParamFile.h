#ifndef SETUPTOOLS_PARAMFILE_H
#define SETUPTOOLS_PARAMFILE_H

#include <QObject>
#include <QFile>
#include <QMap>
#include <QVariant>

namespace SetupTools
{

class JSONParamFile : public QObject
{
    Q_OBJECT
    Q_ENUMS(Result)
    Q_PROPERTY(QString name MEMBER mName WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(bool exists MEMBER mExists NOTIFY existsChanged)
    Q_PROPERTY(QString parseError READ parseError NOTIFY resultChanged)
    Q_PROPERTY(int result READ result NOTIFY resultChanged)
    Q_PROPERTY(QString resultString READ resultString NOTIFY resultChanged)
public:
    enum Result
    {
        Ok,
        CorruptedFile,
        FileOpenFail,
        FileReadFail,
        FileWriteFail
    };

    JSONParamFile(QObject *parent = 0);
    void setName(QString newName);
    QString parseError() { return mLastParseError; }
    Result result() { return mLastResult; }
    QString resultString() { return mLastResultString; }

    Q_INVOKABLE static QString resultString(int result);
    Q_INVOKABLE QVariantMap read();
    Q_INVOKABLE void write(QVariantMap map);
public slots:
signals:
    void nameChanged();
    void existsChanged();
    void resultChanged();
    void opComplete();
private:
    QVariantMap readJson(QFile &file);
    void writeJson(QFile &file, QVariantMap map);
    void setExists(bool exists);
    void setResult(Result val);
    void setParseError(QString parseErrorString);

    QString mName;
    bool mExists;
    Result mLastResult;
    QString mLastParseError;
    QString mLastResultString;
};

}   // namespace SetupTools

#endif // SETUPTOOLS_PARAMFILE_H

