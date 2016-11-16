#ifndef SETUPTOOLS_PARAM_H
#define SETUPTOOLS_PARAM_H

#include <QObject>
#include <QVector>
#include <QtEndian>
#include "Exception.h"
#include "Slot.h"
#include <boost/dynamic_bitset.hpp>
#include <boost/range/iterator_range.hpp>
#include "util.h"

namespace SetupTools {

class ParamRegistry;

class Param : public QObject
{
    Q_OBJECT

    Q_PROPERTY(SetupTools::ParamRegistry * registry READ registry WRITE setRegistry NOTIFY registryChanged)
    Q_PROPERTY(QVariant addr READ addr WRITE setAddr NOTIFY addrChanged)
    Q_PROPERTY(QString key READ key NOTIFY addrChanged)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(bool writable READ writable WRITE setWritable NOTIFY writableChanged)
    Q_PROPERTY(bool saveable READ saveable WRITE setSaveable NOTIFY saveableChanged)
    Q_PROPERTY(bool fullReload READ fullReload WRITE setFullReload NOTIFY fullReloadChanged)
    Q_PROPERTY(bool bigEndian READ bigEndian WRITE setBigEndian NOTIFY bigEndianChanged)
    Q_PROPERTY(int dataType READ dataType WRITE setDataType NOTIFY dataTypeChanged)
    Q_PROPERTY(SetupTools::Slot * slot READ slot WRITE setSlot NOTIFY slotChanged)

    Q_PROPERTY(bool valid READ valid WRITE setValid NOTIFY validChanged)
    Q_PROPERTY(bool writeCacheDirty READ writeCacheDirty WRITE setWriteCacheDirty NOTIFY writeCacheDirtyChanged)

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
        F64,
        INVALID
    };

    explicit Param(QObject * parent = 0);
    virtual ~Param() = default;

    ParamRegistry * registry()
    {
        return mRegistry;
    }
    void setRegistry(ParamRegistry * val);

    const QVariant & addr() const
    {
        return mAddr;
    }
    void setAddr(const QVariant & val);

    const QString key() const
    {
        return mKey;
    }

    const QString name() const
    {
        if(mName.isEmpty())
            return mAddr.toString();
        else
            return mName;
    }
    void setName(const QString & val)
    {
        if(updateDelta<>(mName, val))
            emit nameChanged();
    }

    bool writable() const
    {
        return mWritable;
    }
    void setWritable(bool val)
    {
        if(updateDelta<>(mWritable, val))
            emit writableChanged();
    }

    bool saveable() const
    {
        return mSaveable;
    }
    void setSaveable(bool val)
    {
        if(updateDelta<>(mSaveable, val))
            emit saveableChanged();
    }

    bool fullReload() const
    {
        return mFullReload;
    }
    void setFullReload(bool val)
    {
        if(updateDelta<>(mFullReload, val))
            emit fullReloadChanged();
    }

    bool bigEndian() const
    {
        return mBigEndian;
    }
    void setBigEndian(bool val)
    {
        if(updateDelta<>(mBigEndian, val))
            emit bigEndianChanged();
    }

    int dataType() const
    {
        return mDataType;
    }
    void setDataType(int val);
    quint32 dataTypeSize() const
    {
        return mDataTypeSize;
    }
    QMetaType::Type dataTypeCode() const
    {
        return mDataTypeCode;
    }

    Slot * slot()
    {
        return mSlot;
    }
    const Slot * slot() const
    {
        return mSlot;
    }
    void setSlot(Slot * val);

    bool valid() const
    {
        return mValid;
    }
    void setValid(bool valid);

    bool writeCacheDirty() const
    {
        return mWriteCacheDirty;
    }
    void setWriteCacheDirty(bool dirty);

    Q_INVOKABLE void resetCaches();  //!< Clear all slave data (making write cache dirty)

    virtual QVariant getSerializableValue(bool *allInRange = nullptr, bool *anyInRange = nullptr) = 0;
    virtual bool setSerializableValue(const QVariant &val) = 0;
    virtual QVariant getSerializableRawValue(bool *allInRange = nullptr, bool *anyInRange = nullptr) = 0;
    virtual bool setSerializableRawValue(const QVariant &val) = 0;

    boost::iterator_range<const quint8 *> bytes() const;
    QPair<quint32, quint32> changedBytes() const; // called by ParamRegistry to get range of data to download to slave
    quint32 loadedBytes() const
    {
        return mNumBytesLoaded;
    }
    void setBytes(boost::iterator_range<const quint8 *> data, quint32 offset, bool eraseExisting = false);  // used to make host-only changes
    void setSlaveBytes(boost::iterator_range<const quint8 *> data, quint32 offset);  // called by ParamRegistry when it dispatches uploaded data - also sets host bytes

    template <typename T>
    T fromSlaveEndian(const uchar *src) const
    {
        if(mBigEndian)
            return qFromBigEndian<T>(src);
        else
            return qFromLittleEndian<T>(src);
    }
    template <typename T>
    T fromSlaveEndian(const char *src) const
    {
        return fromSlaveEndian<T>(reinterpret_cast<const uchar *>(src));
    }
    template <typename T>
    T fromSlaveEndian(T src) const
    {
        if(mBigEndian)
            return qFromBigEndian<T>(src);
        else
            return qFromLittleEndian<T>(src);
    }
    template <typename T>
    void toSlaveEndian(T src, uchar *dest) const
    {
        if(mBigEndian)
            qToBigEndian(src, dest);
        else
            qToLittleEndian(src, dest);
    }
    template <typename T>
    void toSlaveEndian(T src, char *dest) const
    {
        toSlaveEndian<T>(src, reinterpret_cast<uchar *>(dest));
    }
    template <typename T>
    T toSlaveEndian(T src) const
    {
        if(mBigEndian)
            return qToBigEndian<T>(src);
        else
            return qToLittleEndian<T>(src);
    }

    bool convertToSlave(QVariant value, quint8 * buf) const;
    QVariant convertFromSlave(const quint8 * buf) const;

    virtual quint32 minSize() = 0;  // called to find out if enough data is present for param to be valid
    virtual quint32 maxSize() = 0;  // called to find out if enough data is present for param to be valid
    virtual quint32 size() = 0;     // actual size of the param

signals:
    void registryChanged();
    void addrChanged();
    void nameChanged();
    void writableChanged();
    void saveableChanged();
    void fullReloadChanged();
    void bigEndianChanged();
    void slotChanged();
    void dataTypeChanged();
    void validChanged(QString key);
    void rawValueChanged(QString key);
    void writeCacheDirtyChanged(QString key);
    void cachesReset();
    void uploadDone(SetupTools::OpResult result);
    void downloadDone(SetupTools::OpResult result);

public slots:
protected:
    virtual bool isCompleted();
    void registerIfCompleted();
private:
    virtual void updateEngrFromRaw(quint32 begin, quint32 end) = 0; // called when data in, or validity of, part of raw range has changed

    ParamRegistry * mRegistry;
    QVariant mAddr;
    QString mKey;
    QString mName;
    bool mWritable;
    bool mSaveable;
    bool mFullReload;
    bool mBigEndian;
    MemoryRangeType mDataType;
    quint32 mDataTypeSize;
    QMetaType::Type mDataTypeCode;
    Slot * mSlot;
    bool mCompleted;
    bool mValid;
    bool mWriteCacheDirty;
    QVector<quint8> mBytes, mSlaveBytes;
    boost::dynamic_bitset<> mBytesLoaded, mSlaveBytesLoaded;
    quint32 mNumBytesLoaded;
};

} // namespace SetupTools

#endif // SETUPTOOLS_PARAM_H
