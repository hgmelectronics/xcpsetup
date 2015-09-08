#include <QFile>
#include <QTextStream>
#include <QtEndian>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonValue>
#include <QJsonArray>
#include <algorithm>
#include "ParamFile.h"
#include <QDebug>

namespace SetupTools
{

ParamFile::ParamFile(QObject *parent) :
    QObject(parent),
    mType(Invalid),
    mExists(false)
{}

void ParamFile::setName(QString newName)
{
    mName = newName;
    mExists = QFile::exists(newName);
    emit nameChanged();
}

void ParamFile::setType(ParamFile::Type newType)
{
    mType = newType;
    emit typeChanged();
}

QVariantMap ParamFile::read()
{
    if(!isTypeOk())
    {
        setResult(Result::InvalidType);
        return QVariantMap();
    }

    QFile file(mName);
    if(!file.open(QFile::ReadOnly))
    {
        setResult(Result::FileOpenFail);
        return QVariantMap();
    }

    switch(mType)
    {
    case Json:
        return readJson(file);
        break;
    default:
        setResult(Result::InvalidType);
        return QVariantMap();
        break;
    }
}

void ParamFile::write(QVariantMap map)
{
    if(!isTypeOk())
    {
        setResult(Result::InvalidType);
        return;
    }

    QFile file(mName);
    if(!file.open(QFile::WriteOnly | QFile::Truncate))
    {
        setResult(Result::FileOpenFail);
        return;
    }

    switch(mType)
    {
    case Json:
        writeJson(file, map);
        break;
    default:
        setResult(Result::InvalidType);
        break;
    }
}

QVariantMap ParamFile::readJson(QFile &file)
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

void ParamFile::writeJson(QFile &file, QVariantMap map)
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

    if(file.write(text) == text.size())
        setResult(Result::Ok);
    else
        setResult(Result::FileWriteFail);
}

bool ParamFile::isTypeOk() const
{
    switch(mType)
    {
    case Json:
        return true;
        break;
    default:
        return false;
        break;
    }
}

void ParamFile::setResult(Result val)
{
    mLastResult = val;
    mLastParseError = "";
    mLastResultString = resultString(val);
    emit resultChanged();
    emit opComplete();
}

void ParamFile::setParseError(QString parseErrorString)
{
    mLastResult = Result::CorruptedFile;
    mLastParseError = parseErrorString;
    mLastResultString = "Parse error: " + parseErrorString;
    emit resultChanged();
    emit opComplete();
}

QString ParamFile::resultString(int result){
    switch(result) {
    case Ok:                        return "OK";
    case CorruptedFile:             return "File corrupted";
    case FileOpenFail:              return "Unable to open file";
    case InvalidType:               return "Invalid file type set";
    case FileWriteFail:             return "Unable to write file";
    default:                        return "Undefined error";
    }
}

}   // namespace SetupTools
