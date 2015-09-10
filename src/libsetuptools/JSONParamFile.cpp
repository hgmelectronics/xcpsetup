#include <QFile>
#include <QTextStream>
#include <QtEndian>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonValue>
#include <QJsonArray>
#include <algorithm>
#include "JSONParamFile.h"
#include <QDebug>

namespace SetupTools
{

JSONParamFile::JSONParamFile(QObject *parent) :
    QObject(parent),
    mExists(false)
{}

void JSONParamFile::setName(QString newName)
{
    mName = newName;
    emit nameChanged();
    setExists(QFile::exists(mName));
}

void JSONParamFile::setExists(bool exists)
{
    if(exists!=mExists)
    {
        mExists = exists;
        emit existsChanged();

    }
}

QVariantMap JSONParamFile::read()
{
    QFile file(mName);
    if(!file.open(QFile::ReadOnly))
    {
        setResult(Result::FileOpenFail);
        return QVariantMap();
    }

    return readJson(file);
}

void JSONParamFile::write(QVariantMap map)
{
    QFile file(mName);
    if(!file.open(QFile::WriteOnly | QFile::Truncate))
    {
        setResult(Result::FileOpenFail);
        return;
    }

    writeJson(file, map);
}

QVariantMap JSONParamFile::readJson(QFile &file)
{
    QJsonParseError parseErr;
    QByteArray bytes = file.readAll();
    QJsonDocument doc = QJsonDocument::fromJson(bytes, &parseErr);
    if(parseErr.error != QJsonParseError::NoError)
    {
        int lineNum = bytes.left(parseErr.offset).count('\n') + 1;
        int colNum = parseErr.offset - bytes.lastIndexOf('\n', parseErr.offset);
        setParseError(parseErr.errorString() + QString(" at line %1 col %2").arg(lineNum).arg(colNum));
        return QVariantMap();
    }
    if(!doc.isObject())
    {
        setParseError("document root is not an object");
        return QVariantMap();
    }
    QJsonObject object = doc.object();

    for(auto it = object.begin(), end = object.end(); it != end; ++it)
    {
        if(it.value().isArray())
        {
            for(auto elem : it.value().toArray())
            {
                if(!elem.isString())
                {
                    setResult(Result::CorruptedFile);
                    return QVariantMap();
                }
            }
        }
        else if(!it.value().isString())
        {
            setResult(Result::CorruptedFile);
            return QVariantMap();
        }
    }

    QVariantMap map;

    for(auto it = object.begin(), end = object.end(); it != end; ++it)
    {
        if(it.value().isArray())
        {
            QJsonArray array(it.value().toArray());
            QStringList stringList;
            stringList.reserve(array.size());
            for(QJsonValueRef elem : array)
                stringList.push_back(elem.toString());
            map.insert(it.key(), stringList);
        }
        else
        {
            Q_ASSERT(it.value().isString());
            map.insert(it.key(), it.value().toString());
        }
    }
    setResult(Result::Ok);
    return map;
}

void JSONParamFile::writeJson(QFile &file, QVariantMap map)
{
    QJsonObject root;
    for(QMap<QString, QVariant>::const_iterator it = map.begin(), end = map.end(); it != end; ++it)
    {
        if(it.value().type() == QVariant::List || it.value().type() == QVariant::StringList)
        {
            QStringList list = it.value().toStringList();
            if(list.size() > 0)
                root.insert(it.key(), QJsonArray::fromStringList(list));
        }
        else if(it.value().canConvert(QVariant::String))
        {
            QString str = it.value().toString();
            if(str.size() > 0)
                root.insert(it.key(), QJsonValue(str));
        }
    }
    QJsonDocument doc;
    doc.setObject(root);

    QByteArray text = doc.toJson();

    bool success =  (file.write(text) == text.size());
    setResult(success ? Result::Ok : Result::FileWriteFail);
    setExists(success);
}

void JSONParamFile::setResult(Result val)
{
    mLastResult = val;
    mLastParseError = "";
    mLastResultString = resultString(val);
    emit resultChanged();
    emit opComplete();
}

void JSONParamFile::setParseError(QString parseErrorString)
{
    mLastResult = Result::CorruptedFile;
    mLastParseError = parseErrorString;
    mLastResultString = "Parse error: " + parseErrorString;
    emit resultChanged();
    emit opComplete();
}

QString JSONParamFile::resultString(int result){
    switch(result) {
    case Ok:                        return "OK";
    case CorruptedFile:             return "File corrupted";
    case FileOpenFail:              return "Unable to open file";
    case FileWriteFail:             return "Unable to write file";
    default:                        return "Undefined error";
    }
}

}   // namespace SetupTools
