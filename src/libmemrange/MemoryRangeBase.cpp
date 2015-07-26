#include "MemoryRangeBase.h"


namespace SetupTools
{


    MemoryRangeBase::setValid(bool valid)
    {
        if(valid!=mValid)
        {
            mValid = valid;
            emit validChanged();
        }
    }

    MemoryRangeBase::setWritable(bool writable)
    {
        if(writable!=mWritable)
        {
            mWritable = writable;
            emit writableChanged();
        }
    }


    MemoryRangeBase::MemoryRangeBase(uint32_t address, uint32_t size, bool writable,  MemoryRangeTable* parent):
        QObject(parent),
        mAddress(address),
        mSize(size),
        mWritable(writable),
        mConnection(parent.connection()),

    {
        connect(connection, &Connection::openDone, this, &MemoryRangeBase::onOpenDone);
        connect(connection, &Connection::closeDone, this, &MemoryRangeBase::onCloseDone);
        connect(connection, &Connection::uploadDone, this, &MemoryRangeBase::uploadDone);
        connect(connection, &Connection::downloadDone, this, &MemoryRangeBase::downloadDone);
    }


    void MemoryRangeBase::openDone(OpResult result)
    {

    }

    void MemoryRangeBase::closeDone(OpResult result)
    {

    }

}

