#ifndef SETUPTOOLS_XCP_PARAM_H
#define SETUPTOOLS_XCP_PARAM_H

#include <QObject>
#include <Xcp_Exception.h>
#include <Xcp_MemoryRange.h>
#include <Slot.h>

namespace SetupTools {
namespace Xcp {

class Param : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool saveable MEMBER saveable)
    Q_PROPERTY(QString key MEMBER key)
    Q_PROPERTY(bool valid READ valid NOTIFY validChanged)
    Q_PROPERTY(bool writeCacheDirty READ writeCacheDirty NOTIFY writeCacheDirtyChanged)
    Q_PROPERTY(Slot* slot READ slot CONSTANT)

public:
    explicit Param(QObject *parent = nullptr);
    explicit Param(MemoryRange *baseRange, Slot* slot, QObject *parent = nullptr);

    bool valid() const;
    bool writeCacheDirty() const;
    Slot *slot() const;

    virtual QVariant getSerializableValue(bool *allInRange = nullptr, bool *anyInRange = nullptr) = 0;
    virtual bool setSerializableValue(const QVariant &val) = 0;
    virtual void resetCaches() = 0;  //!< Set all write cache dirty and clear all read cache

    bool saveable;
    QString key;

signals:
    void uploadDone(SetupTools::Xcp::OpResult result);
    void downloadDone(SetupTools::Xcp::OpResult result);
    void writeCacheDirtyChanged(QString key);
    void validChanged();

public slots:
    virtual void upload() = 0;
    virtual void download() = 0;

private:
    void onRangeValidChanged();
    void onRangeWriteCacheDirtyChanged();
    MemoryRange* const mBaseRange;
    Slot* const mSlot;
};

}   // namespace Xcp
} // namespace SetupTools

#endif // SETUPTOOLS_XCP_PARAM_H
