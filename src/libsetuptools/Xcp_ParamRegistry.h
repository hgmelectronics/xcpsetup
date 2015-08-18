#ifndef SETUPTOOLS_XCP_PARAMREGISTRY_H
#define SETUPTOOLS_XCP_PARAMREGISTRY_H

#include "Xcp_MemoryRangeTable.h"
#include "Slot.h"
#include "TableAxis.h"
#include "Xcp_Param.h"
#include "Xcp_ConnectionFacade.h"

#include <QObject>
#include <QString>
#include <unordered_map>

namespace SetupTools {
namespace Xcp {

class ParamRegistry : public QObject
{
    Q_OBJECT

    Q_PROPERTY(quint32 addrGran READ addrGran)
    Q_PROPERTY(Xcp::ConnectionFacade *connectionFacade READ connectionFacade WRITE setConnectionFacade NOTIFY connectionChanged)
    Q_PROPERTY(bool connectionOk READ connectionOk NOTIFY connectionChanged)
    Q_PROPERTY(bool writeCacheDirty READ writeCacheDirty NOTIFY writeCacheDirtyChanged)
    Q_PROPERTY(QList<QString> paramKeys READ paramKeys NOTIFY paramsChanged)
public:
    explicit ParamRegistry(quint32 addrGran, QObject *parent = 0);

    quint32 addrGran() const;
    Xcp::ConnectionFacade *connectionFacade() const;
    void setConnectionFacade(Xcp::ConnectionFacade *);
    bool connectionOk() const;
    const MemoryRangeTable *table() const;
    const QList<QString> &paramKeys() const;
    bool writeCacheDirty() const;

    Q_INVOKABLE Param *addScalarParam(MemoryRange::MemoryRangeType type, XcpPtr base, bool writable, bool saveable, const Slot *slot, QString key);
    Q_INVOKABLE Param *addTableParam(MemoryRange::MemoryRangeType type, XcpPtr base, int count, bool writable, bool saveable, const Slot *slot, const TableAxis *axis, QString key);
    Q_INVOKABLE Param *addScalarParam(MemoryRange::MemoryRangeType type, XcpPtr base, bool writable, bool saveable, const Slot *slot);
    Q_INVOKABLE Param *addTableParam(MemoryRange::MemoryRangeType type, XcpPtr base, int count, bool writable, bool saveable, const Slot *slot, const TableAxis *axis);
    Q_INVOKABLE Param *getParam(QString key);
    Q_INVOKABLE void resetCaches();
signals:
    void connectionChanged();
    void paramsChanged();
    void writeCacheDirtyChanged();
public slots:
    void onTableConnectionChanged();
    void onParamWriteCacheDirtyChanged(QString key);
private:
    void addParamKey(QString key);
    MemoryRangeTable mTable;
    QMap<QString, Param *> mParams;
    QList<QString> mParamKeys;  // maintain our own list of keys because QMap<>::keys() just builds a new list every time
    QList<QString> mWriteCacheDirtyKeys;
};

} // namespace Xcp
} // namespace SetupTools

#endif // SETUPTOOLS_XCP_PARAMREGISTRY_H
