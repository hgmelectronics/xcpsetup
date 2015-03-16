#include "Xcp_Interface_Registry.h"
#include "Xcp_Interface_Can_Registry.h"

namespace SetupTools {
namespace Xcp {
namespace Interface {

Registry::Registry(QObject *parent) : QObject(parent) {}

Registry::~Registry() {}

const QList<QString> &Registry::avail()
{
    return mAvailUri;
}


CompositeRegistry::CompositeRegistry(QObject *parent) : Registry(parent) {}

CompositeRegistry::~CompositeRegistry() {}

void CompositeRegistry::add(Registry *reg)
{
    mChildren.append(reg);
    reg->setParent(this);
    mAvailUri.append(reg->avail());
}

Interface *CompositeRegistry::make(QString uri)
{
    for(Registry *child : mChildren)
    {
        Interface *intfc = child->make(uri);
        if(intfc != NULL)
            return intfc;
    }
    return NULL;
}


MasterRegistry::MasterRegistry(QObject *parent) : CompositeRegistry(parent) {
    mChildren.append(new Can::MasterRegistry(this));
}

MasterRegistry::~MasterRegistry() {}

} // namespace Interface
} // namespace Xcp
} // namespace SetupTools

