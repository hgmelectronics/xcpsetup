#ifndef SETUPTOOLS_XCP_SCALARMEMORYRANGE_H
#define SETUPTOOLS_XCP_SCALARMEMORYRANGE_H

#include "Xcp_MemoryRange.h"
#include <boost/dynamic_bitset.hpp>

namespace SetupTools {
namespace Xcp {

class ScalarMemoryRange: public MemoryRange
{
    Q_OBJECT

    Q_PROPERTY(XcpPtr base READ base)
    Q_PROPERTY(quint32 size READ size) //!< size in bytes
    Q_PROPERTY(QVariant value READ value WRITE setValue NOTIFY valueChanged)

public:
    ScalarMemoryRange(MemoryRangeType type, Xcp::XcpPtr base, bool writable, quint8 addrGran, MemoryRangeList *parent);

    QVariant value() const;
    void setValue(QVariant value);

    virtual bool operator==(MemoryRange &other);

signals:
    void valueChanged();

public slots:
    virtual void download();
    void download(QVariant value);
    virtual void onUploadDone(Xcp::OpResult result, Xcp::XcpPtr base, int len, std::vector<quint8> data = std::vector<quint8> ());

private:
    MemoryRangeType mType;

    bool mValid;    //!< discovered by trying to read in onOpenDone

    std::vector<quint8> mCache;
    boost::dynamic_bitset<> mCacheLoaded;

    QVariant mValue;
};

} // namespace Xcp
} // namespace SetupTools

#endif // SETUPTOOLS_XCP_SCALARMEMORYRANGE_H
