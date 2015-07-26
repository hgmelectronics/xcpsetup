#ifndef SETUPTOOLS_XCP_MEMORYRANGE_H
#define SETUPTOOLS_XCP_MEMORYRANGE_H

#include <QObject>

#include "Xcp_Connection.h"

namespace SetupTools
{
namespace Xcp
{

class MemoryRangeList;  // forward declare

class MemoryRange: public QObject
{
    Q_OBJECT

    Q_PROPERTY(QVariant value READ getValue WRITE setValue NOTIFY valueChanged)
    Q_PROPERTY(uint32_t addr READ addr)
    Q_PROPERTY(uint32_t addrExt READ addrExt)
    Q_PROPERTY(uint32_t size READ size)
    Q_PROPERTY(bool valid READ valid NOTIFY validChanged)
    Q_PROPERTY(bool writable READ writable NOTIFY writableChanged)

public:
    /**
     * @brief MemoryRange
     * @param type Qt metatype code
     * @param base Base address
     * @param count Number of members of type in this range - if > 1 results in a table
     * @param parent
     */
    MemoryRange(QMetaType::Type type, Xcp::XcpPtr base, quint32 count, bool writable, MemoryRangeList *parent);
    bool valid() const;
    bool writable() const;
    uint32_t address() const;
    uint32_t size() const;

    ValueType getValue() const;
    void setValue(ValueType value);

signals:
    void valueChanged();
    void validChanged();
    void writableChanged();

public slots:
    void refresh();
    void onOpenDone(Xcp::OpResult result);
    void onCloseDone(Xcp::OpResult result);
    void onUploadDone(Xcp::OpResult result, Xcp::XcpPtr base, int len, std::vector<quint8> data = std::vector<quint8> ());
    void onDownloadDone(Xcp::OpResult result, Xcp::XcpPtr base, const std::vector<quint8> &data);

private:
    Xcp::Connection* getConnection();

    Xcp::XcpPtr mBase;
    uint32_t mSize;
    bool mValid;    //!< discovered by trying to read in onOpenDone
    bool mWritable;

    QVariant mValue;
};

}   // namespace Xcp
}   // namespace SetupTools

#endif // SETUPTOOLS_XCP_MEMORYRANGE_H

