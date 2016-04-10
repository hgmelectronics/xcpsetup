#ifndef SETUPTOOLS_XCP_MEMORYRANGETABLE_H
#define SETUPTOOLS_XCP_MEMORYRANGETABLE_H

#include <QObject>
#include <QList>

#include "Xcp_ConnectionFacade.h"
#include "Xcp_MemoryRangeList.h"

namespace SetupTools
{
namespace Xcp
{

class ScalarMemoryRange;
class ArrayMemoryRange;

class MemoryRangeTable: public QObject
{
    Q_OBJECT
    Q_ENUMS(MemoryRangeType)

    Q_PROPERTY(quint32 addrGran READ addrGran)
    Q_PROPERTY(Xcp::ConnectionFacade *connectionFacade READ connectionFacade WRITE setConnectionFacade NOTIFY connectionChanged)
    Q_PROPERTY(bool connectionOk READ connectionOk NOTIFY connectionChanged)
public:
    MemoryRangeTable(quint32 addrGran, QObject *parent = nullptr);
    quint32 addrGran() const;
    Xcp::ConnectionFacade *connectionFacade() const;
    void setConnectionFacade(Xcp::ConnectionFacade *);
    bool connectionOk() const;

    /**
     * @brief adds a memrange to table, either in new list or overlapping list, or returns an identical one if existing
     */
    Q_INVOKABLE ScalarMemoryRange *addScalarRange(MemoryRange::MemoryRangeType type, XcpPtr base, bool writable);
    Q_INVOKABLE ArrayMemoryRange *addTableRange(MemoryRange::MemoryRangeType type, XcpPtr base, quint32 count, bool writable);

    /**
     * @brief Clear all ranges from table - mostly useful for testing
     */
    Q_INVOKABLE void clear();

    /**
     * @brief getLists
     * @return Const reference to the internal list of memory range lists, useful for testing
     */
    QList<MemoryRangeList *> const &getLists() const;

signals:
    void connectionChanged(bool ok);

private:
    void onConnStateChanged();
    void onUploadDone(SetupTools::Xcp::OpResult result, Xcp::XcpPtr base, int len, std::vector<quint8> data = std::vector<quint8> ());
    void onDownloadDone(SetupTools::Xcp::OpResult result, Xcp::XcpPtr base, std::vector<quint8> data);
    typedef QList<MemoryRangeList *>::iterator ListIterator;
    typedef boost::iterator_range<ListIterator> ListRange;

    static bool listBeginLessThan(const MemoryRangeList *list, const XcpPtr &addr);
    static bool listEndLessThan(const MemoryRangeList *list, const XcpPtr &addr);
    ListIterator findOverlapBegin(XcpPtr addr);
    ListIterator findOverlapEnd(XcpPtr addr);
    ListRange findOverlap(XcpPtr base, int len);
    void insertRange(MemoryRange *newRange);

    const quint32 mAddrGran;
    Xcp::ConnectionFacade *mConnectionFacade;
    bool mConnectionOk;
    QList<MemoryRangeList *> mEntries;
};

}   // namespace Xcp
}   // namespace SetupTools

#endif // SETUPTOOLS_XCP_MEMORYRANGETABLE_H
