#ifndef SETUPTOOLS_XCP_MEMORYRANGE_H
#define SETUPTOOLS_XCP_MEMORYRANGE_H

#include <QObject>
#include <QQmlListProperty>

#include "Xcp_ConnectionFacade.h"

namespace SetupTools
{
namespace Xcp
{

class MemoryRangeList;  // forward declare

class MemoryRange: public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool writable READ writable WRITE setWritable NOTIFY writableChanged)
    Q_ENUMS(MemoryRangeType)

public:
    enum MemoryRangeType
    {
        U8,
        S8,
        U16,
        S16,
        U32,
        S32,
        F32,
        U64,
        S64,
        F64
    };

    /**
     * @brief MemoryRange
     * @param type Qt metatype code
     * @param base Base address
     * @param writable
     * @param parent
     */
    MemoryRange(Xcp::XcpPtr base, quint32 size, bool writable, quint8 addrGran, MemoryRangeList *parent);

    bool writable() const;
    void setWritable(bool);

    XcpPtr base() const;
    XcpPtr end() const;

    quint32 size() const; //!< size in bytes

    virtual bool operator==(MemoryRange &other) = 0;
    inline bool operator!=(MemoryRange &other) { return !(*this == other); }

signals:
    void writableChanged();
public slots:
    void refresh();
    void onConnectionChanged(bool ok);
    virtual void onUploadDone(Xcp::OpResult result, Xcp::XcpPtr base, int len, std::vector<quint8> data = std::vector<quint8> ()) = 0;
    void onDownloadDone(Xcp::OpResult result, Xcp::XcpPtr base, const std::vector<quint8> &data);

protected:
    Xcp::ConnectionFacade *connectionFacade() const;
    const Xcp::XcpPtr mBase;
    const quint32 mSize;
    const quint8 mAddrGran;

    bool mWritable;
};

void convertToSlave(MemoryRange::MemoryRangeType type, Xcp::ConnectionFacade *conn, QVariant value, quint8 *buf);
QVariant convertFromSlave(MemoryRange::MemoryRangeType type, Xcp::ConnectionFacade *conn, const quint8 *buf);
quint32 memoryRangeTypeSize(MemoryRange::MemoryRangeType type);
QMetaType::Type memoryRangeTypeQtCode(MemoryRange::MemoryRangeType type);



}   // namespace Xcp
}   // namespace SetupTools

#endif // SETUPTOOLS_XCP_MEMORYRANGE_H
