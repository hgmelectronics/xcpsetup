#ifndef CSVPARAMFILE_H
#define CSVPARAMFILE_H

#include <QObject>
#include <QFile>
#include <QMap>
#include <QVariant>

namespace SetupTools
{

class CSVParamFile : public QObject
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

    CSVParamFile(QObject *parent = 0);
    void setName(QString newName);
    QString parseError() { return mLastParseError; }
    Result result() { return mLastResult; }
    QString resultString() { return mLastResultString; }

    Q_INVOKABLE static QString resultString(int result);
    Q_INVOKABLE QVariantMap read();
    Q_INVOKABLE void write(QVariantMap valueMap, QVariantMap nameMap);
public slots:
signals:
    void nameChanged();
    void existsChanged();
    void resultChanged();
    void opComplete();
private:
    QVariantMap readCsv(QFile &file);
    void writeCsv(QFile &file, QVariantMap valueMap, QVariantMap nameMap);
    void setExists(bool exists);
    void setResult(Result val);
    void setParseError(QString parseErrorString);

    QString mName;
    bool mExists;
    Result mLastResult;
    QString mLastParseError;
    QString mLastResultString;
};

}

#endif // CSVPARAMFILE_H
