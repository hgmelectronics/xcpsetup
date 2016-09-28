#ifndef SETUPTOOLS_XCP_PARAMREGISTRY_H
#define SETUPTOOLS_XCP_PARAMREGISTRY_H
/*
#include "ParamRegistry.h"
#include "Xcp_ConnectionFacade.h"

#include <QObject>
#include <QString>
#include <unordered_map>
#include <boost/range/iterator_range.hpp>

namespace SetupTools {
namespace Xcp {

class ParamAddrRangeMap
{
public:
    ParamAddrRangeMap() = default;
    void insert(XcpPtr base, quint32 size, Param * param);
    QPair<Param *, int> find(XcpPtr base);  // assumes ranges do not overlap
private:
    struct ArrayAddrEntry
    {
        XcpPtr base;
        quint32 size;
        Param * param;
        operator XcpPtr() {
            return base;
        }
    };

    QVector<ArrayAddrEntry>::iterator lowerBound(XcpPtr base);
    QVector<ArrayAddrEntry>::iterator upperBound(XcpPtr base);

    QVector<ArrayAddrEntry> mVector;
};

class ParamRegistry : public SetupTools::ParamRegistry
{
    Q_OBJECT

    Q_PROPERTY(quint32 addrGran READ addrGran WRITE setAddrGran NOTIFY addrGranChanged)
    Q_PROPERTY(SetupTools::Xcp::ConnectionFacade *connectionFacade READ connectionFacade WRITE setConnectionFacade NOTIFY connectionChanged)
    Q_PROPERTY(bool connectionOk READ connectionOk NOTIFY connectionChanged)
    Q_PROPERTY(bool writeCacheDirty READ writeCacheDirty NOTIFY writeCacheDirtyChanged)
    Q_PROPERTY(QList<QString> paramKeys READ paramKeys NOTIFY paramsChanged)
    Q_PROPERTY(QList<QString> saveableParamKeys READ saveableParamKeys NOTIFY paramsChanged)
    Q_PROPERTY(int minRevNum READ minRevNum NOTIFY minRevNumChanged)
    Q_PROPERTY(int maxRevNum READ maxRevNum NOTIFY maxRevNumChanged)
    Q_PROPERTY(int currentRevNum READ currentRevNum WRITE setCurrentRevNum NOTIFY currentRevNumChanged)
    Q_PROPERTY(int revHistoryLength MEMBER mRevHistoryLength)
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
    QPair<Param *, int> findParamByAddr(XcpPtr base);
    int minRevNum();
    int maxRevNum();
    int currentRevNum();
    void setCurrentRevNum(int revNum);

    SetupTools::Xcp::ScalarParam *addScalarParam(int type, SetupTools::Xcp::XcpPtr base, bool writable, bool saveable, SetupTools::Slot* slot, QString key = QString(), QString name = QString());
    SetupTools::Xcp::ArrayParam *addArrayParam(int type, SetupTools::Xcp::XcpPtr base, int count, bool writable, bool saveable, SetupTools::Slot* slot, QString key = QString(), QString name = QString());
    SetupTools::Xcp::VarArrayParam *addVarArrayParam(int type, SetupTools::Xcp::XcpPtr base, int minCount, int maxCount, bool writable, bool saveable, SetupTools::Slot* slot, QString key = QString(), QString name = QString());

    Q_INVOKABLE SetupTools::Xcp::ScalarParam *addScalarParam(int type, double base, bool writable, bool saveable, SetupTools::Slot* slot, QString key = QString(), QString name = QString());
    Q_INVOKABLE SetupTools::Xcp::ArrayParam *addArrayParam(int type, double base, int count, bool writable, bool saveable, SetupTools::Slot* slot, QString key = QString(), QString name = QString());
    Q_INVOKABLE SetupTools::Xcp::VarArrayParam *addVarArrayParam(int type, double base, int minCount, int maxCount, bool writable, bool saveable, SetupTools::Slot* slot, QString key = QString(), QString name = QString());
    Q_INVOKABLE SetupTools::Xcp::Param *getParam(QString key);
    Q_INVOKABLE void resetCaches();
    Q_INVOKABLE void setValidAll(bool valid);
    Q_INVOKABLE void setWriteCacheDirtyAll(bool dirty);

    ParamRegistryHistoryElide historyElide();

    Q_INVOKABLE void beginHistoryElide();   // for use from QML, where object lifetime can be a little murky
    Q_INVOKABLE void endHistoryElide();

signals:
    void connectionChanged();
    void paramsChanged();
    void writeCacheDirtyChanged();
    void minRevNumChanged();
    void maxRevNumChanged();
    void currentRevNumChanged();

private slots:
    void onParamRawValueChanged(QString key);
    void onTableConnectionChanged();
    void onParamWriteCacheDirtyChanged(QString key);

private:
    struct Revision
    {
        static bool compareNumAndParam(const Revision & lhs, const Revision & rhs);

        int revNum;
        Param * param;
        QVariant oldValue, newValue;
    };

    friend bool operator <(const Revision & lhs, int rhs);
    friend bool operator <(int lhs, const Revision & rhs);

    void insertParam(Param * param, bool saveable); // inserts into mParams, mParamKeys, mSaveableParamKeys, and connects writeCacheDirtyChanged and rawValueChanged.

    MemoryRangeTable * mTable;
    QMap<QString, Param *> mParams;
    QMap<XcpPtr, Param *> mScalarAddrMap;
    QMap<QString, QVariant> mParamValues;
    ParamAddrRangeMap mArrayAddrMap;
    QList<QString> mParamKeys;  // maintain our own list of keys because QMap<>::keys() just builds a new list every time
    QList<QString> mSaveableParamKeys;  // maintain our own list of keys because QMap<>::keys() just builds a new list every time
    QList<QString> mWriteCacheDirtyKeys;

    int mHistoryElideCount;
    bool mHistoryIgnore;
    int mRevNum;
    int mRevHistoryLength;
    QVector<Revision> mRevHistory;
};

} // namespace Xcp
} // namespace SetupTools
*/
#endif // SETUPTOOLS_XCP_PARAMREGISTRY_H
