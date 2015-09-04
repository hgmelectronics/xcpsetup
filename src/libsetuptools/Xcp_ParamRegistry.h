#ifndef SETUPTOOLS_XCP_PARAMREGISTRY_H
#define SETUPTOOLS_XCP_PARAMREGISTRY_H

#include "Xcp_MemoryRangeTable.h"
#include "Slot.h"
#include "Xcp_Param.h"
#include "Xcp_ScalarParam.h"
#include "Xcp_ArrayParam.h"
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
    Q_PROPERTY(SetupTools::Xcp::ConnectionFacade *connectionFacade READ connectionFacade WRITE setConnectionFacade NOTIFY connectionChanged)
    Q_PROPERTY(bool connectionOk READ connectionOk NOTIFY connectionChanged)
    Q_PROPERTY(bool writeCacheDirty READ writeCacheDirty NOTIFY writeCacheDirtyChanged)
    Q_PROPERTY(QList<QString> paramKeys READ paramKeys NOTIFY paramsChanged)
    Q_PROPERTY(QList<QString> saveableParamKeys READ saveableParamKeys NOTIFY paramsChanged)
public:
    explicit ParamRegistry(QObject *parent = 0);
    explicit ParamRegistry(quint32 addrGran, QObject *parent = 0);

    quint32 addrGran() const;
    SetupTools::Xcp::ConnectionFacade *connectionFacade() const;
    void setConnectionFacade(SetupTools::Xcp::ConnectionFacade *);
    bool connectionOk() const;
    const MemoryRangeTable *table() const;
    const QList<QString> &paramKeys() const;
    const QList<QString> &saveableParamKeys() const;
    bool writeCacheDirty() const;

    SetupTools::Xcp::ScalarParam *addParam(int type, SetupTools::Xcp::XcpPtr base, bool writable, bool saveable, SetupTools::Slot* slot);
    SetupTools::Xcp::ScalarParam *addParam(int type, SetupTools::Xcp::XcpPtr base, bool writable, bool saveable, SetupTools::Slot* slot, QString key);
    SetupTools::Xcp::ArrayParam *addParam(int type, SetupTools::Xcp::XcpPtr base, int count, bool writable, bool saveable, SetupTools::Slot* slot);
    SetupTools::Xcp::ArrayParam *addParam(int type, SetupTools::Xcp::XcpPtr base, int count, bool writable, bool saveable, SetupTools::Slot* slot, QString key);

    Q_INVOKABLE SetupTools::Xcp::ScalarParam *addParam(int type, quint32 base, bool writable, bool saveable, SetupTools::Slot* slot);
    Q_INVOKABLE SetupTools::Xcp::ScalarParam *addParam(int type, quint32 base, bool writable, bool saveable, SetupTools::Slot* slot, QString key);
    Q_INVOKABLE SetupTools::Xcp::ArrayParam *addParam(int type, quint32 base, int count, bool writable, bool saveable, SetupTools::Slot* slot);
    Q_INVOKABLE SetupTools::Xcp::ArrayParam *addParam(int type, quint32 base, int count, bool writable, bool saveable, SetupTools::Slot* slot, QString key);
    Q_INVOKABLE SetupTools::Xcp::Param *getParam(QString key);
    Q_INVOKABLE void resetCaches();
signals:
    void connectionChanged();
    void paramsChanged();
    void writeCacheDirtyChanged();

private:
    void onTableConnectionChanged();
    void onParamWriteCacheDirtyChanged(QString key);
    void addParamKey(QString key);
    MemoryRangeTable *mTable;
    QMap<QString, Param *> mParams;
    QList<QString> mParamKeys;  // maintain our own list of keys because QMap<>::keys() just builds a new list every time
    QList<QString> mSaveableParamKeys;  // maintain our own list of keys because QMap<>::keys() just builds a new list every time
    QList<QString> mWriteCacheDirtyKeys;
};

} // namespace Xcp
} // namespace SetupTools

#endif // SETUPTOOLS_XCP_PARAMREGISTRY_H
