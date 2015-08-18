#include <QFile>
#include <QTextStream>
#include <QtEndian>
#include <algorithm>
#include "ProgFile.h"

namespace SetupTools
{

ProgFile::ProgFile(QObject *parent) :
    QObject(parent),
    mType(Invalid),
    mValid(false)
{
    connect(&mProg, &FlashProg::changed, this, &ProgFile::onProgChanged);
}

QString ProgFile::name()
{
    return mName;
}

void ProgFile::setName(QString newName)
{
    mName = newName;
    if(mValid)
    {
        mValid = false;
        emit progChanged();
    }
}

ProgFile::Type ProgFile::type()
{
    return mType;
}

void ProgFile::setType(ProgFile::Type newType)
{
    mType = newType;
    if(mValid)
    {
        mValid = false;
        emit progChanged();
    }
}

bool ProgFile::valid()
{
    return mValid;
}

FlashProg *ProgFile::progPtr()
{
    return &mProg;
}

FlashProg &ProgFile::prog()
{
    return mProg;
}

const FlashProg &ProgFile::prog() const
{
    return mProg;
}

int ProgFile::size()
{
    return mProg.size();
}

uint ProgFile::base()
{
    return mProg.base();
}

ProgFile::Result ProgFile::read()
{
    for(auto blockPtr : mProg.blocks())
        delete blockPtr;
    mProg.blocks().clear();
    mValid = false;

    QFile file(mName);
    if(!file.open(QFile::ReadOnly))
        return Result::FileOpenFail;

    Result ret = Result::InvalidType;
    switch(mType)
    {
    case Srec:
        ret = readSrec(file);
        break;
    default:
        break;
    }
    emit progChanged();
    return ret;
}

void ProgFile::onProgChanged()
{
    emit progChanged();
}

namespace SrecDetail
{

struct Line
{
    quint32 base;
    std::vector<quint8> data;
};

enum class Result
{
    Ok = 0,
    NotApplicable,
    BadRecord
};

bool CompareLine(const Line &a, const Line &b)
{
    return a.base < b.base;
}

QList<FlashBlock *>::iterator FindAppendBlock(QList<FlashBlock *> &blocks, quint32 newBase)
{
    for(QList<FlashBlock *>::iterator blockIt = blocks.begin(); blockIt != blocks.end(); ++blockIt)
    {
        FlashBlock *block = *blockIt;
        if(block->base + block->data.size() == newBase)
            return blockIt;
    }
    return blocks.end();
}

std::pair<Result, Line> ConvertLine(const QString &text)
{
    Line ret;

    if(text.size() < 4
            || text[0] != QChar('S')
            || !text[1].isNumber()
            || text.size() % 2 != 0)
        return {Result::BadRecord, ret};

    QByteArray bytes = QByteArray::fromHex(QStringRef(&text, 2, text.size() - 2).toLatin1());
    if(bytes.size() != (text.size() - 2) / 2
            || bytes.size() != (bytes[0] + 1))
        return {Result::BadRecord, ret};

    {
        // Validate checksum
        quint8 accum = 0;
        for(int iByte = 0; iByte < bytes.size(); ++iByte)
            accum += bytes[iByte];
        if(accum != 0xFF)
            return {Result::BadRecord, ret};
    }

    const quint8 *dataBegin;
    const quint8 *dataEnd = reinterpret_cast<const uchar *>(bytes.data() + bytes.size() - 1);
    switch(text[1].toLatin1())
    {
    case '1':
        if(bytes.size() < 4)
            return {Result::BadRecord, ret};
        ret.base = qFromBigEndian<quint16>(reinterpret_cast<const uchar *>(bytes.data()) + 1);
        dataBegin = reinterpret_cast<const uchar *>(bytes.data() + 3);
        break;
    case '2':
        if(bytes.size() < 5)
            return {Result::BadRecord, ret};
        ret.base = qFromBigEndian<quint32>(reinterpret_cast<const uchar *>(bytes.data()) + 0) & 0x00FFFFFF;
        dataBegin = reinterpret_cast<const uchar *>(bytes.data() + 4);
        break;
    case '3':
        if(bytes.size() < 6)
            return {Result::BadRecord, ret};
        ret.base = qFromBigEndian<quint32>(reinterpret_cast<const uchar *>(bytes.data()) + 1);
        dataBegin = reinterpret_cast<const uchar *>(bytes.data() + 5);
        break;
    default:
        return {Result::NotApplicable, ret};
        break;
    }
    ret.data.resize(dataEnd - dataBegin);
    std::copy(dataBegin, dataEnd, ret.data.begin());

    return {Result::Ok, ret};
}

}   // namespace SrecDetail

ProgFile::Result ProgFile::readSrec(QFile &file)
{
    QTextStream stream(&file);
    std::vector<SrecDetail::Line> lines;
    while(1)
    {
        QString line = stream.readLine();
        if(line.isNull()) break;
        std::pair<SrecDetail::Result, SrecDetail::Line> conv = SrecDetail::ConvertLine(line);
        if(conv.first == SrecDetail::Result::Ok)
            lines.emplace_back(std::move(conv.second));
        else if(conv.first == SrecDetail::Result::BadRecord)
            return Result::CorruptedFile;
    }


    std::sort(lines.begin(), lines.end(), SrecDetail::CompareLine);

    quint32 remainingSize = 0;
    for(const SrecDetail::Line &line : lines)
        remainingSize += line.data.size();

    for(const SrecDetail::Line &line : lines)
    {
        QList<FlashBlock *>::iterator appendBlockIt = SrecDetail::FindAppendBlock(mProg.blocks(), line.base);
        FlashBlock *appendBlock;
        if(appendBlockIt != mProg.blocks().end())
            appendBlock = *appendBlockIt;
        else
        {
            // No block exists that we can tack this line onto
            if(mProg.blocks().size())
            {
                // First confirm we do not have overlapping blocks
                FlashBlock *lastBlock = mProg.blocks().back();
                quint32 lastBlockEnd = lastBlock->base + lastBlock->data.size();
                if(lastBlockEnd > line.base)
                    return Result::CorruptedFile;

                // Last block probably needs compacting
                lastBlock->data.shrink_to_fit();
            }

            // make a new block
            mProg.blocks().push_back(new FlashBlock(&mProg));
            appendBlock = mProg.blocks().back();
            appendBlock->base = line.base;
        }

        // Reserve best guess amount of memory needed (assumes rest of srecords are appendable to this block)
        appendBlock->data.reserve(appendBlock->data.size() + remainingSize);

        appendBlock->data.resize(appendBlock->data.size() + line.data.size());
        std::copy(line.data.begin(), line.data.end(), appendBlock->data.end() - line.data.size());

        remainingSize -= line.data.size();
    }
    mValid = true;
    return Result::Ok;
}

}   // namespace SetupTools
