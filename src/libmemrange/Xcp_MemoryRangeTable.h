#ifndef SETUPTOOLS_XCP_MEMORYRANGETABLE_H
#define SETUPTOOLS_XCP_MEMORYRANGETABLE_H

#include <QObject>
#include <QList>

#include "Xcp_Connection.h"
#include "Xcp_MemoryRangeList.h"

namespace SetupTools
{
namespace Xcp
{

class MemoryRangeTable: public QObject
{
    Q_OBJECT
    Q_ENUMS(MemoryRangeType)

    Q_PROPERTY(quint32 addrGran READ addrGran)
    Q_PROPERTY(Xcp::Connection *connection READ connection WRITE setConnection NOTIFY connectionChanged)
    Q_PROPERTY(bool connectionOk READ connectionOk NOTIFY connectionChanged)
public:
    MemoryRangeTable(quint32 addrGran, QObject *parent = nullptr);
    quint32 addrGran() const;
    Xcp::Connection *connection() const;
    void setConnection(Xcp::Connection *);
    bool connectionOk() const;

    /**
     * @brief adds a memrange to table, either in new list or overlapping list, or returns an identical one if existing
     */
    Q_INVOKABLE MemoryRange *addRange(MemoryRange::MemoryRangeType type, XcpPtr base, quint32 count, bool writable);

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
    void connectionChanged();

public slots:
    void onOpenDone(Xcp::OpResult result);
    void onCloseDone(Xcp::OpResult result);
    void onUploadDone(Xcp::OpResult result, Xcp::XcpPtr base, int len, std::vector<quint8> data = std::vector<quint8> ());
    void onDownloadDone(Xcp::OpResult result, Xcp::XcpPtr base, std::vector<quint8> data);

private:
    typedef QList<MemoryRangeList *>::iterator ListIterator;
    typedef boost::iterator_range<ListIterator> ListRange;
    static bool listBeginLessThan(const MemoryRangeList *list, const XcpPtr &addr);
    static bool listEndLessThan(const MemoryRangeList *list, const XcpPtr &addr);
    ListIterator findOverlapBegin(XcpPtr addr);
    ListIterator findOverlapEnd(XcpPtr addr);
    ListRange findOverlap(XcpPtr base, int len);

    const quint32 mAddrGran;
    Xcp::Connection *mConnection;
    QList<MemoryRangeList *> mEntries;
};

}   // namespace Xcp
}   // namespace SetupTools

#endif // SETUPTOOLS_XCP_MEMORYRANGETABLE_H
