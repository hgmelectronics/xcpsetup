#ifndef SETUPTOOLS_XCP_PARAM_H
#define SETUPTOOLS_XCP_PARAM_H

#include <QObject>
#include <Xcp_Exception.h>
#include <Xcp_MemoryRange.h>
#include <Slot.h>
#include <boost/dynamic_bitset.hpp>

namespace SetupTools {
namespace Xcp {

class Param : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool saveable MEMBER saveable WRITE setSaveable NOTIFY saveableChanged)
    Q_PROPERTY(QString key MEMBER key WRITE setKey NOTIFY keyChanged)
    Q_PROPERTY(bool valid READ valid WRITE setValid NOTIFY validChanged)
    Q_PROPERTY(bool writeCacheDirty READ writeCacheDirty WRITE setWriteCacheDirty NOTIFY writeCacheDirtyChanged)
    Q_PROPERTY(Slot* slot READ slot CONSTANT)

public:
    explicit Param(QObject *parent = nullptr);
    explicit Param(MemoryRange *baseRange, Slot* slot, QObject *parent = nullptr);
    explicit Param(MemoryRange *baseRange, QList<MemoryRange *> extRanges, bool requireExtRangesValid, Slot* slot, QObject *parent = nullptr);

    void setSaveable(bool newSaveable);
    void setKey(QString newKey);

    bool valid() const;
    void setValid(bool valid);

    bool writeCacheDirty() const;
    void setWriteCacheDirty(bool dirty);

    Slot *slot() const;

    Q_INVOKABLE void resetCaches();  //!< Set all write cache dirty and clear all read cache

    virtual QVariant getSerializableValue(bool *allInRange = nullptr, bool *anyInRange = nullptr) = 0;
    virtual bool setSerializableValue(const QVariant &val) = 0;
    virtual QVariant getSerializableRawValue(bool *allInRange = nullptr, bool *anyInRange = nullptr) = 0;
    virtual bool setSerializableRawValue(const QVariant &val) = 0;

    bool saveable;
    QString key;

signals:
    void saveableChanged();
    void keyChanged();
    void uploadDone(SetupTools::Xcp::OpResult result);
    void downloadDone(SetupTools::Xcp::OpResult result);
    void writeCacheDirtyChanged(QString key);
    void validChanged();
    void cachesReset();

public slots:
    virtual void upload() = 0;
    virtual void download() = 0;

private:
    void onRangeValidChanged();
    void onRangeWriteCacheDirtyChanged();
    void onExtRangeValidChanged(int index);
    void onExtRangeWriteCacheDirtyChanged(int index);

    MemoryRange * const mBaseRange;
    QList<MemoryRange *> const mExtRanges;

    QSignalMapper *mExtRangeValidChangedMapper;
    QSignalMapper *mExtRangeWriteCacheDirtyChangedMapper;
    boost::dynamic_bitset<> mExtRangeValid;
    boost::dynamic_bitset<> mExtRangeWriteCacheDirty;

    const bool mRequireExtRangesValid;
    Slot * const mSlot;
};

}   // namespace Xcp
} // namespace SetupTools

#endif // SETUPTOOLS_XCP_PARAM_H
