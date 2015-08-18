#include <QFile>
#include <QTextStream>
#include <QtEndian>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonValue>
#include <QJsonArray>
#include <algorithm>
#include "ParamFile.h"

namespace SetupTools
{

ParamFile::ParamFile(QObject *parent) :
    QObject(parent),
    mType(Invalid),
    mValid(false)
{}

QString ParamFile::name()
{
    return mName;
}

void ParamFile::setName(QString newName)
{
    mName = newName;
    if(mValid)
    {
        mValid = false;
        emit mapChanged();
    }
}

ParamFile::Type ParamFile::type()
{
    return mType;
}

void ParamFile::setType(ParamFile::Type newType)
{
    mType = newType;
    if(mValid)
    {
        mValid = false;
        emit mapChanged();
    }
}

bool ParamFile::valid()
{
    return mValid;
}

ParamFile::Result ParamFile::read()
{
    if(!isTypeOk())
        return Result::InvalidType;

    mMap.clear();
    mValid = false;

    QFile file(mName);
    if(!file.open(QFile::ReadOnly))
        return Result::FileOpenFail;

    Result ret = Result::InvalidType;
    switch(mType)
    {
    case Json:
        ret = readJson(file);
        break;
    default:
        break;
    }
    emit mapChanged();
    return ret;
}

ParamFile::Result ParamFile::write()
{
    if(!isTypeOk())
        return Result::InvalidType;

    QFile file(mName);
    if(!file.open(QFile::WriteOnly | QFile::Truncate))
        return Result::FileOpenFail;

    switch(mType)
    {
    case Json:
        return writeJson(file);
        break;
    default:
        return Result::InvalidType;
        break;
    }
}

ParamFile::Result ParamFile::readJson(QFile &file)
{
    QJsonParseError parseErr;
    QByteArray bytes = file.readAll();
    QJsonDocument doc = QJsonDocument::fromJson(bytes, &parseErr);
    if(parseErr.error != QJsonParseError::NoError)
    {
        int lineNum = bytes.left(parseErr.offset).count('\n') + 1;
        int colNum = parseErr.offset - bytes.lastIndexOf('\n', parseErr.offset);
        emit jsonParseError(parseErr.errorString() + QString(" at line %1 col %2").arg(lineNum).arg(colNum));
        return Result::CorruptedFile;
    }
    if(!doc.isObject())
    {
        emit jsonParseError("document root is not an object");
        return Result::CorruptedFile;
    }

    for(QJsonObject::iterator it = doc.object().begin(), end = doc.object().end(); it != end; ++it)
    {
        if(it.value().isArray())
        {
            for(QJsonValueRef elem : it.value().toArray())
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

    mMap.clear();

    for(QJsonObject::iterator it = doc.object().begin(), end = doc.object().end(); it != end; ++it)
    {
        if(it.value().isArray())
        {
            QJsonArray array(it.value().toArray());
            QStringList stringList;
            stringList.reserve(array.size());
            for(QJsonValueRef elem : array)
                stringList.push_back(elem.toString());
            mMap.insert(it.key(), stringList);
        }
        else
        {
            Q_ASSERT(it.value().isString());
            mMap.insert(it.key(), it.value().toString());
        }
    }
    return Result::Ok;
}

ParamFile::Result ParamFile::writeJson(QFile &file)
{
    QJsonObject root;
    for(QMap<QString, QVariant>::iterator it = mMap.begin(), end = mMap.end(); it != end; ++it)
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

}   // namespace SetupTools
