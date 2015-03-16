#ifndef SETUPTOOLS_XCP_INTERFACE_REGISTRY_H
#define SETUPTOOLS_XCP_INTERFACE_REGISTRY_H

#include <QObject>
#include <Xcp_Interface_Interface.h>

namespace SetupTools {
namespace Xcp {
namespace Interface {

class LIBXCONFPROTOSHARED_EXPORT Registry : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QList<QString> avail READ avail CONSTANT)
public:
    explicit Registry(QObject *parent = 0);
    virtual ~Registry();
    const QList<QString> &avail();
    virtual Interface *make(QString uri) = 0;
protected:
    QList<QString> mAvailUri;
};

class LIBXCONFPROTOSHARED_EXPORT CompositeRegistry : public Registry
{
    Q_OBJECT
public:
    explicit CompositeRegistry(QObject *parent = 0);
    virtual ~CompositeRegistry();
    void add(Registry *reg);
    virtual Interface *make(QString uri);
protected:
    QList<Registry *> mChildren;
};

class LIBXCONFPROTOSHARED_EXPORT MasterRegistry : public CompositeRegistry
{
    Q_OBJECT
public:
    explicit MasterRegistry(QObject *parent = 0);
    virtual ~MasterRegistry();
};

} // namespace Interface
} // namespace Xcp
} // namespace SetupTools

#endif // SETUPTOOLS_XCP_INTERFACE_REGISTRY_H
