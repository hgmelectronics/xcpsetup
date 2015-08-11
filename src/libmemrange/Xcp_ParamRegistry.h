#ifndef SETUPTOOLS_XCP_PARAMREGISTRY_H
#define SETUPTOOLS_XCP_PARAMREGISTRY_H

#include "Xcp_MemoryRangeTable.h"
#include "Slot.h"
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
public:
    explicit ParamRegistry(quint32 addrGran, QObject *parent = 0);

    quint32 addrGran() const;
    Xcp::ConnectionFacade *connectionFacade() const;
    void setConnectionFacade(Xcp::ConnectionFacade *);
    bool connectionOk() const;
    const MemoryRangeTable *table() const;

    Q_INVOKABLE Param *addParam(MemoryRange::MemoryRangeType type, XcpPtr base, quint32 count, bool writable, bool saveable, const Slot *slot, QString key);
    Q_INVOKABLE Param *getParam(QString key);
signals:
    void connectionChanged();
public slots:
    void onTableConnectionChanged();
private:
    MemoryRangeTable mTable;
    std::unordered_map<std::string, Param *> mParams;
};

} // namespace Xcp
} // namespace SetupTools

#endif // SETUPTOOLS_XCP_PARAMREGISTRY_H
