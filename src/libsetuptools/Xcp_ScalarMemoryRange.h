#ifndef SETUPTOOLS_XCP_SCALARMEMORYRANGE_H
#define SETUPTOOLS_XCP_SCALARMEMORYRANGE_H

#include "Xcp_MemoryRange.h"
#include <boost/dynamic_bitset.hpp>

namespace SetupTools {
namespace Xcp {

class ScalarMemoryRange: public MemoryRange
{
    Q_OBJECT
    Q_PROPERTY(QVariant value READ value WRITE setValue NOTIFY valueChanged)

public:
    ScalarMemoryRange(MemoryRangeType type, Xcp::XcpPtr base, bool writable, quint8 addrGran, MemoryRangeList *parent);

    QVariant value() const;
    void setValue(QVariant value);

    virtual void resetCaches();

    virtual bool operator==(MemoryRange &other);

signals:
    void valueChanged();

public slots:
    virtual void download();
    void download(QVariant value);
    virtual void onUploadDone(SetupTools::Xcp::OpResult result, Xcp::XcpPtr base, int len, std::vector<quint8> data = std::vector<quint8> ());

private:
    QVariant::Type mVariantType;

    std::vector<quint8> mReadCache;
    boost::dynamic_bitset<> mReadCacheLoaded;

    QVariant mValue, mSlaveValue;
};

} // namespace Xcp
} // namespace SetupTools

#endif // SETUPTOOLS_XCP_SCALARMEMORYRANGE_H
