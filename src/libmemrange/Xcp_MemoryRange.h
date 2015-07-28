#ifndef SETUPTOOLS_XCP_MEMORYRANGE_H
#define SETUPTOOLS_XCP_MEMORYRANGE_H

#include <QObject>
#include <QQmlListProperty>

#include "Xcp_Connection.h"

namespace SetupTools
{
namespace Xcp
{

class MemoryRangeList;  // forward declare

class MemoryRange: public QObject
{
    Q_OBJECT
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
    MemoryRange(Xcp::XcpPtr base, quint32 size, bool writable, MemoryRangeList *parent);

    bool writable() const;
    void setWritable(bool);

    XcpPtr base() const;

    quint32 size() const; //!< size in bytes

public slots:
    void refresh();
    void onOpenDone(Xcp::OpResult result);
    void onCloseDone(Xcp::OpResult result);
    virtual void onUploadDone(Xcp::OpResult result, Xcp::XcpPtr base, int len, std::vector<quint8> data = std::vector<quint8> ()) = 0;
    void onDownloadDone(Xcp::OpResult result, Xcp::XcpPtr base, const std::vector<quint8> &data);

protected:
    Xcp::Connection *getConnection() const;

private:
    const Xcp::XcpPtr mBase;
    const quint32 mSize;

    bool mWritable;
};

void convertToSlave(MemoryRange::MemoryRangeType type, Xcp::Connection *conn, QVariant value, quint8 *buf);
QVariant convertFromSlave(MemoryRange::MemoryRangeType type, Xcp::Connection *conn, const quint8 *buf);
quint32 memoryRangeTypeSize(MemoryRange::MemoryRangeType type);
QMetaType::Type memoryRangeTypeQtCode(MemoryRange::MemoryRangeType type);



}   // namespace Xcp
}   // namespace SetupTools

#endif // SETUPTOOLS_XCP_MEMORYRANGE_H

