#ifndef XCP_INTERFACE_REGISTRY_H
#define XCP_INTERFACE_REGISTRY_H

#include <QObject>

namespace SetupTools
{
namespace Xcp
{
namespace Interface
{

class Registry : public QObject
{
    Q_OBJECT
public:
    explicit Registry(QObject *parent = 0);

signals:

public slots:

};

}
}
}

#endif // XCP_INTERFACE_REGISTRY_H
