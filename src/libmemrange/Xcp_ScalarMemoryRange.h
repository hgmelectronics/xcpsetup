#ifndef SETUPTOOLS_XCP_SCALARMEMORYRANGE_H
#define SETUPTOOLS_XCP_SCALARMEMORYRANGE_H

#include "Xcp_MemoryRange.h"

namespace SetupTools {
namespace Xcp {

class ScalarMemoryRange: public MemoryRange
{
    Q_OBJECT

    Q_PROPERTY(XcpPtr base READ base)
    Q_PROPERTY(quint32 size READ size) //!< size in bytes
    Q_PROPERTY(bool valid READ valid NOTIFY validChanged)
    Q_PROPERTY(bool writable READ writable WRITE setWritable NOTIFY writableChanged)
    Q_PROPERTY(QVariant value READ value WRITE setValue NOTIFY valueChanged)

public:
    ScalarMemoryRange(MemoryRangeType type, Xcp::XcpPtr base, bool writable, MemoryRangeList *parent);

    bool valid() const;

    QVariant value() const;
    void setValue(QVariant value);

signals:
    void valueChanged();
    void validChanged();

public slots:
    virtual void onUploadDone(Xcp::OpResult result, Xcp::XcpPtr base, int len, std::vector<quint8> data = std::vector<quint8> ());

private:
    void setValid(bool newValid);

    MemoryRangeType mType;

    bool mValid;    //!< discovered by trying to read in onOpenDone

    QVariant mValue;
};

} // namespace Xcp
} // namespace SetupTools

#endif // SETUPTOOLS_XCP_SCALARMEMORYRANGE_H
