#ifndef SETUPTOOLS_XCP_ARRAYMEMORYRANGE_H
#define SETUPTOOLS_XCP_ARRAYMEMORYRANGE_H

#include "Xcp_MemoryRange.h"
#include <boost/dynamic_bitset.hpp>

namespace SetupTools {
namespace Xcp {

class ArrayMemoryRange: public MemoryRange
{
    Q_OBJECT
    Q_PROPERTY(int count READ count CONSTANT)

public:
    ArrayMemoryRange(MemoryRangeType type, quint32 dim, Xcp::XcpPtr base, bool writable, quint8 addrGran, MemoryRangeList *parent);

    Q_INVOKABLE QVariant get(int index) const
    {
        return mData.value(index);
    }

    Q_INVOKABLE bool set(int index, const QVariant &value);

    const QList<QVariant>& data() const
    {
        return mData;
    }

    bool setDataRange(const QList<QVariant> &data, quint32 beginIndex = 0);  //!< write multiple entries at once to take advantage of block transfer

    int count() const
    {
        return int(mDim);
    }

    quint32 elemSize() const
    {
        return mElemSize;
    }

    quint32 dim() const
    {
        return mDim;
    }

    virtual void resetCaches();

    virtual bool operator==(MemoryRange &other);

signals:
    void valueChanged();
    void dataUploaded(quint32 beginIndex, quint32 endIndex);
    void dataChanged(quint32 beginIndex, quint32 endIndex);

public slots:
    virtual void download();
    void download(quint32 beginIndex, const QList<QVariant> &data);
    virtual void onUploadDone(SetupTools::OpResult result, Xcp::XcpPtr base, int len, std::vector<quint8> data = std::vector<quint8> ());

private:
    bool inRange(int index) const;
    QVariant partialUpload(quint32 offset, boost::iterator_range<quint8 *> data);

    const QVariant::Type mQtType;
    const quint32 mElemSize;
    const quint32 mDim;
    std::vector<quint8> mReadCache;
    boost::dynamic_bitset<> mReadCacheLoaded;

    QList<QVariant> mData, mSlaveData;
};

} // namespace Xcp
} // namespace SetupTools

#endif // SETUPTOOLS_XCP_ARRAYMEMORYRANGE_H
