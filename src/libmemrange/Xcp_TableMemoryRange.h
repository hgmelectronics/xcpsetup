#ifndef SETUPTOOLS_XCP_TABULARMEMORYRANGE_H
#define SETUPTOOLS_XCP_TABULARMEMORYRANGE_H

#include "Xcp_MemoryRange.h"
#include <boost/dynamic_bitset.hpp>

namespace SetupTools {
namespace Xcp {

class TableMemoryRange: public MemoryRange
{
    Q_OBJECT

    Q_PROPERTY(XcpPtr base READ base)
    Q_PROPERTY(quint32 size READ size) //!< size in bytes
public:
    TableMemoryRange(MemoryRangeType type, quint32 dim, Xcp::XcpPtr base, bool writable, quint8 addrGran, MemoryRangeList *parent);

    int rowCount() const;
    QVariant operator[](quint32 index) const;
    const QList<QVariant> &data() const;
    bool setData(const QVariant &value, quint32 index);
    bool setDataRange(const QList<QVariant> &data, quint32 beginIndex = 0);  //!< write multiple entries at once to take advantage of block transfer

    virtual bool operator==(MemoryRange &other);
signals:
    void valueChanged();
public slots:
    virtual void download();
    void download(quint32 beginIndex, const QList<QVariant> &data);
    virtual void onUploadDone(Xcp::OpResult result, Xcp::XcpPtr base, int len, std::vector<quint8> data = std::vector<quint8> ());
private:
    QVariant partialUpload(quint32 offset, boost::iterator_range<quint8 *> data);

    const MemoryRangeType mType;
    const QVariant::Type mQtType;
    const quint32 mElemSize;
    const quint32 mDim;

    std::vector<quint8> mCache;
    boost::dynamic_bitset<> mCacheLoaded;

    QList<QVariant> mValue;
};

} // namespace Xcp
} // namespace SetupTools

#endif // SETUPTOOLS_XCP_TABULARMEMORYRANGE_H
