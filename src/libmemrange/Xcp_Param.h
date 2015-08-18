#ifndef SETUPTOOLS_XCP_PARAM_H
#define SETUPTOOLS_XCP_PARAM_H

#include <QObject>
#include <Xcp_Exception.h>
#include <Xcp_MemoryRange.h>

namespace SetupTools {
namespace Xcp {

class Param : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool saveable MEMBER saveable)
    Q_PROPERTY(QString key MEMBER key)
    Q_PROPERTY(bool writeCacheDirty READ writeCacheDirty NOTIFY writeCacheDirtyChanged)
public:
    explicit Param(MemoryRange *baseRange, QObject *parent = 0);

    bool writeCacheDirty() const;
    virtual QVariant getSerializableValue() = 0;
    virtual bool setSerializableValue(const QVariant &val) = 0;

    bool saveable;
    QString key;
signals:
    void uploadDone(SetupTools::Xcp::OpResult result);
    void downloadDone(SetupTools::Xcp::OpResult result);
    void writeCacheDirtyChanged(QString key);
public slots:
    virtual void upload() = 0;
    virtual void download() = 0;
    void onRangeWriteCacheDirtyChanged();
private:
    MemoryRange *mBaseRange;
};

}   // namespace Xcp
} // namespace SetupTools

#endif // SETUPTOOLS_XCP_PARAM_H
