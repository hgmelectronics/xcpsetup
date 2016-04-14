#include <QFile>
#include <QTextStream>
#include <QtEndian>
#include <algorithm>
#include "CSVParamFile.h"
#include <QDebug>

namespace SetupTools
{

CSVParamFile::CSVParamFile(QObject *parent) :
    QObject(parent),
    mExists(false)
{}

void CSVParamFile::setName(QString newName)
{
    mName = newName;
    emit nameChanged();
    setExists(QFile::exists(mName));
}

void CSVParamFile::setExists(bool exists)
{
    if(exists != mExists)
    {
        mExists = exists;
        emit existsChanged();

    }
}

QVariantMap CSVParamFile::read()
{
    QFile file(mName);
    if(!file.open(QFile::ReadOnly))
    {
        setResult(Result::FileOpenFail);
        return QVariantMap();
    }

    return readCsv(file);
}

void CSVParamFile::write(QVariantMap valueMap, QVariantMap nameMap)
{
    QFile file(mName);
    if(!file.open(QFile::WriteOnly | QFile::Truncate))
    {
        setResult(Result::FileOpenFail);
        return;
    }

    writeCsv(file, valueMap, nameMap);
}

QString convertToCsvSafe(const QString & input)
{
    QString str = input;
    str.replace(QChar('\\'), "\\\\");   // first escape backslashes
    str.replace(QChar(','), "\\,");     // then escape commas
    return str;
}

QString convertFromCsvSafe(const QString & input)
{
    QString str = input;
    str.replace(QString("\\,"), QString(","));
    str.replace(QString("\\\\"), QString("\\"));
    return str;
}

QVariantMap CSVParamFile::readCsv(QFile &file)
{
    QString text = QString::fromUtf8(file.readAll());
    QStringList lines = text.split(QChar('\n'));

    QVariantMap map;

    for(int iLine = 0, nLines = lines.size(); iLine < nLines; ++iLine)
    {
        if(lines[iLine].isEmpty())
            continue;

        QStringList fields = lines[iLine].split(QChar(','));
        if(fields.size() < 3)
        {
            setParseError(QString("line %1 has less than 3 fields").arg(iLine + 1));
            setResult(Result::CorruptedFile);
            return QVariantMap();
        }
        QString id = fields[0];
        if(id.size() == 0)
        {
            setParseError(QString("line %1 has empty ID field").arg(iLine + 1));
            setResult(Result::CorruptedFile);
            return QVariantMap();
        }
        QStringList valueFields = fields.mid(2);
        for(int iField = 0, nFields = valueFields.size(); iField < nFields; ++iField)
        {
            if(valueFields[iField].size() == 0)
            {
                setParseError(QString("line %1 has empty value field %2").arg(iLine + 1).arg(iField + 1));
                setResult(Result::CorruptedFile);
                return QVariantMap();
            }
        }
        if(valueFields.size() > 1)
            map.insert(id, valueFields);
        else
            map.insert(id, valueFields[0]);
    }

    setResult(Result::Ok);
    return map;
}

void CSVParamFile::writeCsv(QFile &file, QVariantMap valueMap, QVariantMap nameMap)
{
    QByteArray text;

    for(QVariantMap::const_iterator it = valueMap.begin(), end = valueMap.end(); it != end; ++it)
    {
        QString valueString;
        if(it.value().type() == QVariant::List || it.value().type() == QVariant::StringList)
        {
            QStringList list = it.value().toStringList();

            if(list.size() > 0)
            {
                for(QString & item : list)
                    item = convertToCsvSafe(item);

                valueString = list.join(QChar(','));
            }
        }
        else if(it.value().canConvert(QVariant::String))
        {
            QString str = convertToCsvSafe(it.value().toString());
            valueString = str;
        }

        if(valueString.size() > 0)
        {
            QString name;
            auto nameIt = nameMap.find(it.key());
            if(nameIt != nameMap.end())
                name = convertToCsvSafe(nameIt.value().toString());

            QStringList lineList;
            lineList.append(it.key());
            lineList.append(name);
            lineList.append(valueString);

            QString line = lineList.join(QChar(',')) + QString("\n");

            text.append(line.toUtf8());
        }
    }

    bool success =  (file.write(text) == text.size());
    setResult(success ? Result::Ok : Result::FileWriteFail);
    setExists(success);
}

void CSVParamFile::setResult(Result val)
{
    mLastResult = val;
    mLastParseError = "";
    mLastResultString = resultString(val);
    emit resultChanged();
    emit opComplete();
}

void CSVParamFile::setParseError(QString parseErrorString)
{
    mLastResult = Result::CorruptedFile;
    mLastParseError = parseErrorString;
    mLastResultString = "Parse error: " + parseErrorString;
    emit resultChanged();
    emit opComplete();
}

QString CSVParamFile::resultString(int result){
    switch(result) {
    case Ok:                        return "OK";
    case CorruptedFile:             return "File corrupted";
    case FileOpenFail:              return "Unable to open file";
    case FileWriteFail:             return "Unable to write file";
    default:                        return "Undefined error";
    }
}

}   // namespace SetupTools
