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
    Q_PROPERTY(XcpPtr base READ base CONSTANT)
    Q_PROPERTY(XcpPtr end READ end CONSTANT)
    Q_PROPERTY(quint32 size READ size CONSTANT)
    Q_PROPERTY(MemoryRangeType type READ type CONSTANT)
    Q_PROPERTY(quint8 addrGran READ addrGran CONSTANT)
    Q_PROPERTY(bool writable READ writable CONSTANT)
    Q_PROPERTY(bool valid READ valid NOTIFY validChanged)
    Q_PROPERTY(bool fullReload READ fullReload WRITE setFullReload NOTIFY fullReloadChanged)
    Q_PROPERTY(bool writeCacheDirty READ writeCacheDirty NOTIFY writeCacheDirtyChanged)
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
    MemoryRange(MemoryRangeType type, Xcp::XcpPtr base, quint32 size, bool writable, quint8 addrGran, MemoryRangeList *parent);

    XcpPtr base() const
    {
        return mBase;
    }

    bool writable() const
    {
        return mWritable;
    }

    bool valid() const
    {
        return mValid;
    }

    void setValid(bool newValid);

    bool fullReload() const
    {
        return mFullReload;
    }

    void setFullReload(bool newFullReload);

    quint32 size() const //!< size in bytes
    {
        return mSize;
    }

    quint8 addrGran() const
    {
        return mAddrGran;
    }

    MemoryRangeType type() const
    {
        return mType;
    }

    bool writeCacheDirty() const
    {
        return mWriteCacheDirty;
    }

    void setWriteCacheDirty(bool newWriteCacheDirty);

    XcpPtr end() const;

    virtual void resetCaches() = 0;

    virtual bool operator==(MemoryRange &other) = 0;
    inline bool operator!=(MemoryRange &other) { return !(*this == other); }


    static inline bool isValidType(int type) {
        return (type >= U8 && type < F64);
    }

signals:
    void validChanged();
    void fullReloadChanged();
    void writeCacheDirtyChanged();
    void uploadDone(SetupTools::OpResult result);
    void downloadDone(SetupTools::OpResult result);

public slots:
    void upload();
    virtual void download() = 0;
    void onConnectionChanged(bool ok);
    virtual void onUploadDone(SetupTools::OpResult result, Xcp::XcpPtr base, int len, std::vector<quint8> data = std::vector<quint8> ()) = 0;
    void onDownloadDone(SetupTools::OpResult result, Xcp::XcpPtr base, const std::vector<quint8> &data);

protected:
    Xcp::ConnectionFacade *connectionFacade() const;

    void convertToSlave(QVariant value, quint8 *buf);
    QVariant convertFromSlave(const quint8 *buf);

private:
    const Xcp::XcpPtr mBase;
    const quint32 mSize;
    const quint8 mAddrGran;
    const bool mWritable;
    const MemoryRangeType mType;

    bool mValid;
    bool mFullReload;
    bool mWriteCacheDirty;
};

quint32 memoryRangeTypeSize(MemoryRange::MemoryRangeType type);
QMetaType::Type memoryRangeTypeQtCode(MemoryRange::MemoryRangeType type);



}   // namespace Xcp
}   // namespace SetupTools

#endif // SETUPTOOLS_XCP_MEMORYRANGE_H

