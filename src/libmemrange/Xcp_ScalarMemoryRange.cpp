#include "Xcp_ScalarMemoryRange.h"

namespace SetupTools {
namespace Xcp {

ScalarMemoryRange::ScalarMemoryRange(MemoryRangeType type, Xcp::XcpPtr base, bool writable, MemoryRangeList *parent) :
    MemoryRange(base, memoryRangeTypeSize(type), writable, parent),
    mType(type),
    mValid(false),
    mValue(memoryRangeTypeQtCode(type))    // make a null QVariant of requested type
{}

bool ScalarMemoryRange::valid() const
{
    return mValid;
}

QVariant ScalarMemoryRange::value() const
{
    return mValue;
}

void ScalarMemoryRange::setValue(QVariant value)
{
    QVariant convertedValue = value;
    convertedValue.convert(mValue.type());

    // check for convertibility
    if(!convertedValue.isValid())
        return;
    if(convertedValue == mValue)
        return;

    if(mConnection->isOpen())
    {
        std::vector<quint8> buffer(mSize);
        convertToSlave(mType, getConnection(), convertedValue, buffer.data());
        getConnection()->download(mBase, buffer);
    }
    else
    {
        mValue = convertedValue;
        emit valueChanged();
    }
}

void ScalarMemoryRange::onUploadDone(Xcp::OpResult result, Xcp::XcpPtr base, int len, std::vector<quint8> data = std::vector<quint8> ())
{
    Q_UNUSED(base);
    Q_UNUSED(len);

    if(result == Xcp::OpResult::Success && data.size() >= mSize)
    {
        QVariant newValue = convertFromSlave(mType, getConnection(), data.data());
        if(newValue != mValue)
            emit valueChanged();
        setValid(true);
    }
    else
    {
        setValid(false);
    }
}

void ScalarMemoryRange::setValid(bool newValid)
{
    if(updateDelta<bool>(mValid, newValid))
        emit validChanged();
}

} // namespace Xcp
} // namespace SetupTools

