#include "Xcp_EbusEventLogInterface.h"
#include "LinearSlot.h"
#include <boost/algorithm/clamp.hpp>

namespace SetupTools {
namespace Xcp {

void EbusEventLogInterface::readEventBounds()
{
    Q_ASSERT(mConfigured);
    setBusy(true);
    mReadingEventsAfterBounds = false;
    mParamLayer->upload({mBeginSerialParam->key(), mEndSerialParam->key()});
}

void EbusEventLogInterface::readBoundsAndEvents()
{
    Q_ASSERT(mConfigured);
    setBusy(true);
    mReadingEventsAfterBounds = true;
    mParamLayer->upload({mBeginSerialParam->key(), mEndSerialParam->key()});
}

void EbusEventLogInterface::readAllEvents()
{
    readEventRange(mBeginEventSerial, mEndEventSerial);
}

void EbusEventLogInterface::readEventRange(int beginSerial, int endSerial)
{
    Q_ASSERT(mConfigured);
    mNowReadingSerial = std::max(mBeginEventSerial, beginSerial);
    mEndReadSerial = std::min(mEndEventSerial, endSerial);

    if(mEndReadSerial > mNowReadingSerial)
    {
        setBusy(true);
        mViewSerialParam->setFloatVal(mNowReadingSerial);   // start the first one
        mParamLayer->download({mViewSerialParam->key()});
    }
    else
    {
        setBusy(false);
    }
}

void EbusEventLogInterface::clearTo(int serial)
{
    Q_ASSERT(mConfigured);
    setBusy(true);
    mClearToSerialParam->setFloatVal(serial);
    mParamLayer->download({mClearToSerialParam->key()});

    // on download done signal, reread bounds
}

void EbusEventLogInterface::onBoundsChanged()
{
    if(!mConfigured)
        return;

    double beginSerialFloat = mBeginSerialParam->valid() ? mBeginSerialParam->floatVal() : NAN;
    double endSerialFloat = mEndSerialParam->valid() ? mEndSerialParam->floatVal() : NAN;
    int beginSerial = beginSerialFloat;
    int endSerial = endSerialFloat;

    if(std::isnan(beginSerialFloat)
            || std::isnan(endSerialFloat)
            || beginSerial != beginSerialFloat
            || endSerial != endSerialFloat
            || beginSerial > endSerial)
    {
        mBeginEventSerial = 0;
        mEndEventSerial = 0;
    }
    else
    {
        mBeginEventSerial = beginSerial;
        mEndEventSerial = endSerial;
    }

    // purge records that were cleared on the device
    for(int key : mRecords.keys())
    {
        if(key < mBeginEventSerial || key >= mEndEventSerial)
            mRecords.remove(key);
    }

    Q_ASSERT(mEndEventSerial >= mBeginEventSerial);
    emit boundsChanged();
    emit modelChanged(0, mEndEventSerial - mBeginEventSerial);
}

void EbusEventLogInterface::onUploadDone(OpResult result, QStringList keys)
{
    Q_ASSERT(mConfigured);

//    qDebug() << int(result) << keys;

    if(keys == QStringList({mViewKeyParam->key(), mViewFreezeSizeParam->key(), mViewFreezeParam->key()}))
    {
        if(result == OpResult::Success)
        {
            Record & record = mRecords[mNowReadingSerial];
            record.key = quint32(mViewKeyParam->floatVal());

            Q_ASSERT(mViewFreezeMaxSize > 0);
            quint32 size = boost::algorithm::clamp(quint32(mViewFreezeSizeParam->floatVal()), 0, mViewFreezeMaxSize);
            record.freeze.resize(size);
            for(quint32 i = 0; i < size; ++i)
                record.freeze[i] = quint8(mViewFreezeParam->get(i).toUInt());

//            qDebug() << "Got record" << mNowReadingSerial << record.key << record.freeze;

            ++mNowReadingSerial;

            if(mNowReadingSerial < mEndReadSerial)
            {
                mViewSerialParam->setFloatVal(mNowReadingSerial);   // start the next one
                mParamLayer->download({mViewSerialParam->key()});
            }
            else
            {
                emit modelChanged(0, mEndReadSerial - mBeginEventSerial);  // FIXME can improve performance by saving the beginning of the read range
                setBusy(false);
            }
        }
        else
        {
            qDebug() << "Upload of event record failed, code" << int(result);
            emit modelChanged(0, mNowReadingSerial - mBeginEventSerial);  // FIXME can improve performance by saving the beginning of the read range
            setBusy(false);
        }
    }
    else if(keys == QStringList({mBeginSerialParam->key(), mEndSerialParam->key()}))
    {
        if(mReadingEventsAfterBounds)
            readAllEvents();
        else
            setBusy(false);
    }
}

void EbusEventLogInterface::onDownloadDone(OpResult result, QStringList keys)
{
    Q_ASSERT(mConfigured);

    if(keys == QStringList(mClearToSerialParam->key()))     // initiated by clearTo()
    {
        readEventBounds();  // even if operation appeared to fail, see what the target's state is
    }
    else if(keys == QStringList(mViewSerialParam->key()))   // initiated by readEventRange()
    {
        if(result != OpResult::Success)
        {
            qDebug() << "Setting event view serial to" << mNowReadingSerial << "failed with code" << int(result);
            setBusy(false);
        }
        else if(fabs(mViewSerialParam->floatVal() - mNowReadingSerial) > std::numeric_limits<float>::epsilon() * 10)
        {
            qDebug() << "Setting event view serial to" << mNowReadingSerial << "failed, value is" << mViewSerialParam->floatVal() << "with difference" << fabs(mViewSerialParam->floatVal() - mNowReadingSerial);
            setBusy(false);
        }
        else
        {
            mParamLayer->upload({mViewKeyParam->key(), mViewFreezeSizeParam->key(), mViewFreezeParam->key()});
        }
    }
}

EbusEventLogInterface::EbusEventLogInterface(QObject *parent) :
    QObject(parent),
    mBeginSerialAddr(),
    mEndSerialAddr(),
    mClearToSerialAddr(),
    mViewSerialAddr(),
    mViewKeyAddr(),
    mViewFreezeSizeAddr(),
    mViewFreezeAddr(),
    mViewFreezeMaxSize(-1),
    mParamLayer(nullptr),

    mModel(new EbusEventLogModel(this)),
    mRawIntSlot(new LinearSlot(this)),
    mBeginEventSerial(0),
    mEndEventSerial(0),
    mNowReadingSerial(std::numeric_limits<int>::min()),
    mEndReadSerial(std::numeric_limits<int>::min()),
    mConfigured(false),
    mBusy(false),
    mReadingEventsAfterBounds(false),
    mBeginSerialParam(nullptr),
    mEndSerialParam(nullptr),
    mClearToSerialParam(nullptr),
    mViewSerialParam(nullptr),
    mViewKeyParam(nullptr),
    mViewFreezeSizeParam(nullptr),
    mViewFreezeParam(nullptr)
{
    mRawIntSlot->setEngrA(std::numeric_limits<int>::min());     // cover both int and uint range
    mRawIntSlot->setEngrB(std::numeric_limits<quint32>::max());
    mRawIntSlot->setRawA(std::numeric_limits<int>::min());
    mRawIntSlot->setRawB(std::numeric_limits<quint32>::max());
}

static void setupParam(Param * param, ParamRegistry * registry, QVariant addr, QString name, bool writable, int dataType, Slot * slot)
{
    param->setRegistry(registry);
    param->setAddr(addr);
    param->setName(name);
    param->setWritable(writable);
    param->setDataType(dataType);
    param->setSlot(slot);
}

void EbusEventLogInterface::configure()
{
    if(mConfigured)
        return;

    if(!mBeginSerialAddr.isValid()
            || !mEndSerialAddr.isValid()
            || !mClearToSerialAddr.isValid()
            || !mViewSerialAddr.isValid()
            || !mViewKeyAddr.isValid()
            || !mViewFreezeSizeAddr.isValid()
            || !mViewFreezeAddr.isValid()
            || mViewFreezeMaxSize <= 0
            || !mParamLayer)
        return;

    auto reg = mParamLayer->registry();

    mBeginSerialParam = new ScalarParam(this);
    setupParam(mBeginSerialParam,       reg,    mBeginSerialAddr,       "Log Begin Serial",     false,  Param::MemoryRangeType::S32,    mRawIntSlot);

    mEndSerialParam = new ScalarParam(this);
    setupParam(mEndSerialParam,         reg,    mEndSerialAddr,         "Log End Serial",       false,  Param::MemoryRangeType::S32,    mRawIntSlot);

    mClearToSerialParam = new ScalarParam(this);
    setupParam(mClearToSerialParam,     reg,    mClearToSerialAddr,     "Log Clear-To Serial",  true,   Param::MemoryRangeType::S32,    mRawIntSlot);

    mViewSerialParam = new ScalarParam(this);
    setupParam(mViewSerialParam,        reg,    mViewSerialAddr,        "Log View Serial",      true,   Param::MemoryRangeType::S32,    mRawIntSlot);

    mViewKeyParam = new ScalarParam(this);
    setupParam(mViewKeyParam,           reg,    mViewKeyAddr,           "Log View Key",         false,  Param::MemoryRangeType::U32,    mRawIntSlot);

    mViewFreezeSizeParam = new ScalarParam(this);
    setupParam(mViewFreezeSizeParam,    reg,    mViewFreezeSizeAddr,    "Log View Freeze Size", false,  Param::MemoryRangeType::U32,    mRawIntSlot);

    mViewFreezeParam = new ArrayParam(this);
    mViewFreezeParam->setMinCount(mViewFreezeMaxSize);
    mViewFreezeParam->setMaxCount(mViewFreezeMaxSize);
    setupParam(mViewFreezeParam,        reg,    mViewFreezeAddr,        "Log View Freeze",      false,  Param::MemoryRangeType::U8,     mRawIntSlot);

    connect(mBeginSerialParam, &ScalarParam::valChanged,   this, &EbusEventLogInterface::onBoundsChanged);
    connect(mBeginSerialParam, &ScalarParam::validChanged, this, &EbusEventLogInterface::onBoundsChanged);
    connect(mEndSerialParam,   &ScalarParam::valChanged,   this, &EbusEventLogInterface::onBoundsChanged);
    connect(mEndSerialParam,   &ScalarParam::validChanged, this, &EbusEventLogInterface::onBoundsChanged);

    connect(mParamLayer, &ParamLayer::downloadDone, this, &EbusEventLogInterface::onDownloadDone);
    connect(mParamLayer, &ParamLayer::uploadDone, this, &EbusEventLogInterface::onUploadDone);

    mConfigured = true;
}

EbusEventLogModel::EbusEventLogModel(EbusEventLogInterface * parent) :
    QAbstractListModel(parent),
    mInterface(parent),
    mCount(parent->count())
{
    connect(mInterface, &EbusEventLogInterface::modelChanged, this, &EbusEventLogModel::onDataChanged);
    connect(mInterface, &EbusEventLogInterface::boundsChanged, this, &EbusEventLogModel::onBoundsChanged);
}

int EbusEventLogModel::count() const
{
    return rowCount();
}

int EbusEventLogModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : mCount;
}

QVariant EbusEventLogModel::data(const QModelIndex &index, int role) const
{
    QVariant out;
    int serial = index.row() + mInterface->mBeginEventSerial;

    if(isValidIndex(index))
    {
        switch(role)
        {
        case Roles::Serial:
            out = serial;
            break;
        case Roles::Key:
            out = double(mInterface->mRecords[serial].key);   // cast to double so keys >= 0x80000000 don't get borked in QML
            break;
        case Roles::Freeze:
        {
            QList<QVariant> freezeVar;
            freezeVar.append(mInterface->mRecords[serial].key);
            for(quint8 byte : mInterface->mRecords[serial].freeze)
                freezeVar.append(byte);
            out = freezeVar;
            break;
        }
        default:
            break;
        }
    }

//    qDebug() << "row" << index.row() << "serial" << serial << "role" << role << "fetched" << out;
    return out;
}

bool EbusEventLogModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    Q_UNUSED(index);
    Q_UNUSED(value);
    Q_UNUSED(role);
    return false;
}

Qt::ItemFlags EbusEventLogModel::flags(const QModelIndex &index) const
{
    if(!isValidIndex(index))
        return 0;
    else
        return Qt::ItemIsEnabled | Qt::ItemIsSelectable;
}

QHash<int, QByteArray> EbusEventLogModel::roleNames() const
{
    static const QHash<int, QByteArray> NAMES({
                                                  {Roles::Serial, "serial"},
                                                  {Roles::Key, "key"},
                                                  {Roles::Freeze, "freeze"}
                                              });
    return NAMES;
}

QVariant EbusEventLogModel::get(int index, QString roleName) const
{
    static const QMap<QString, int> ROLES({
                                                  {"serial", Roles::Serial},
                                                  {"key", Roles::Key},
                                                  {"freeze", Roles::Freeze}
                                              });
    if(!ROLES.contains(roleName))
        return QVariant();
    else
        return data(createIndex(index, 0), ROLES[roleName]);
}

void EbusEventLogModel::onDataChanged(quint32 beginChanged, quint32 endChanged)
{
    int clampedBegin = std::max(int(beginChanged), 0);
    int clampedEnd = std::min(int(endChanged), mCount);
    if(clampedEnd > clampedBegin && clampedBegin >= 0)
    emit dataChanged(createIndex(clampedBegin, 0), createIndex(clampedEnd - 1, 0));   // convert from STL style (end = past-the-end) to Qt model style (end = last one)
}

void EbusEventLogModel::onBoundsChanged()
{
    int newCount = mInterface->count();
//    qDebug() << "boundsChanged" << mCount << newCount;

    if(newCount > mCount)
    {
        beginInsertRows(QModelIndex(), mCount, newCount - 1);
        mCount = newCount;
        endInsertRows();
    }
    else if(newCount < mCount)
    {
        beginRemoveRows(QModelIndex(), newCount, mCount - 1);
        mCount = newCount;
        endRemoveRows();
    }
    emit countChanged();
    emit dataChanged(createIndex(0, 0), createIndex(newCount - 1, 0));
}

bool EbusEventLogModel::isValidIndex(const QModelIndex & index) const
{
    if(!index.isValid())
    {
//        qDebug() << "EbusEventLogModel::isValidIndex: Index not valid";
        return false;
    }
    if(index.column() != 0)
    {
//        qDebug() << "EbusEventLogModel::isValidIndex: column" << index.column() << "!= 0";
        return false;
    }
    if(index.row() < 0)
    {
//        qDebug() << "EbusEventLogModel::isValidIndex: row" << index.row() << "< 0";
        return false;
    }
    if(index.row() >= mInterface->count())
    {
//        qDebug() << "EbusEventLogModel::isValidIndex: row" << index.row() << ">=" << mInterface->count();
        return false;
    }
    if(!mInterface->mRecords.contains(index.row() + mInterface->mBeginEventSerial))
    {
//        qDebug() << "EbusEventLogModel::isValidIndex: record for serial" << index.row() + mInterface->mBeginEventSerial << "not found";
        return false;
    }
    return true;
}

} // namespace Xcp
} // namespace SetupTools
