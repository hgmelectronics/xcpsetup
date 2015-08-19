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

QString ParamFile::name()
{
    return mName;
}

void ParamFile::setName(QString newName)
{
    mName = newName;
    mExists = QFile::exists(newName);
    emit nameChanged();
}

ParamFile::Type ParamFile::type()
{
    return mType;
}

void ParamFile::setType(ParamFile::Type newType)
{
    mType = newType;
    emit typeChanged();
}

bool ParamFile::exists()
{
    return mExists;
}

ParamFile::Result ParamFile::read(QMap<QString, QVariant> &mapOut)
{
    if(!isTypeOk())
        return Result::InvalidType;

    mapOut.clear();

    QFile file(mName);
    if(!file.open(QFile::ReadOnly))
        return Result::FileOpenFail;

    switch(mType)
    {
    case Json:
        return readJson(file, mapOut);
        break;
    default:
        return Result::InvalidType;
        break;
    }
}

ParamFile::Result ParamFile::write(const QMap<QString, QVariant> &map)
{
    if(!isTypeOk())
        return Result::InvalidType;

    QFile file(mName);
    if(!file.open(QFile::WriteOnly | QFile::Truncate))
        return Result::FileOpenFail;

    switch(mType)
    {
    case Json:
        return writeJson(file, map);
        break;
    default:
        return Result::InvalidType;
        break;
    }
}

ParamFile::Result ParamFile::readJson(QFile &file, QMap<QString, QVariant> &mapOut)
{
    QJsonParseError parseErr;
    QByteArray bytes = file.readAll();
    QJsonDocument doc = QJsonDocument::fromJson(bytes, &parseErr);
    if(parseErr.error != QJsonParseError::NoError)
    {
        int lineNum = bytes.left(parseErr.offset).count('\n') + 1;
        int colNum = parseErr.offset - bytes.lastIndexOf('\n', parseErr.offset);
        emit parseError(parseErr.errorString() + QString(" at line %1 col %2").arg(lineNum).arg(colNum));
        return Result::CorruptedFile;
    }
    if(!doc.isObject())
    {
        emit parseError("document root is not an object");
        return Result::CorruptedFile;
    }
    QJsonObject object = doc.object();

    for(auto it = object.begin(), end = object.end(); it != end; ++it)
    {
        if(it.value().isArray())
        {
            for(auto elem : it.value().toArray())
            {
                if(!elem.isString())
                    return Result::CorruptedFile;
            }
        }
        else if(!it.value().isString())
        {
            return Result::CorruptedFile;
        }
    }

    mapOut.clear();

    for(auto it = object.begin(), end = object.end(); it != end; ++it)
    {
        if(it.value().isArray())
        {
            QJsonArray array(it.value().toArray());
            QStringList stringList;
            stringList.reserve(array.size());
            for(QJsonValueRef elem : array)
                stringList.push_back(elem.toString());
            mapOut.insert(it.key(), stringList);
        }
        else
        {
            Q_ASSERT(it.value().isString());
            mapOut.insert(it.key(), it.value().toString());
        }
    }
    return Result::Ok;
}

ParamFile::Result ParamFile::writeJson(QFile &file, const QMap<QString, QVariant> &map)
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
        else if(it.value().type() == QVariant::String)
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
        return Result::Ok;
    else
        return Result::FileWriteFail;
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
