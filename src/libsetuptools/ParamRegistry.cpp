#include "ParamRegistry.h"
#include "util.h"

namespace SetupTools {

bool operator <(const ParamRegistry::Revision & lhs, int rhs)
{
    return lhs.revNum < rhs;
}

bool operator <(int lhs, const ParamRegistry::Revision & rhs)
{
    return lhs < rhs.revNum;
}

ParamHistoryElide::ParamHistoryElide(ParamRegistry & registry) :
    mRegistry(&registry)
{
    mRegistry->beginHistoryElide();
}

ParamHistoryElide::ParamHistoryElide(const ParamHistoryElide & other) :
    mRegistry(other.mRegistry)
{
    mRegistry->beginHistoryElide(); // increment because other is about to be destroyed, at which time it will decrement
}

ParamHistoryElide & ParamHistoryElide::operator =(const ParamHistoryElide & rhs)
{
    rhs.mRegistry->beginHistoryElide();
    mRegistry->endHistoryElide();
    mRegistry = rhs.mRegistry;

    return *this;
}

ParamHistoryElide::~ParamHistoryElide()
{
    mRegistry->endHistoryElide();
}

bool ParamRegistry::Revision::compareNumAndParam(const Revision & lhs, const Revision & rhs)
{
    if(lhs.revNum < rhs.revNum)
        return true;
    if(lhs.revNum > rhs.revNum)
        return false;
    return (lhs.param < rhs.param);
}

ParamRegistry::ParamRegistry(QObject *parent) :
    QObject(parent),
    mHistoryElideCount(),
    mHistoryIgnore(),
    mRevNum(),
    mRevHistoryLength(5000)
{
}

int ParamRegistry::minRevNum()
{
    if(mRevHistory.empty())
        return mRevNum;

    return mRevHistory.front().revNum - 1;  // we can reconstruct the revision before the first one stored, since we store old and new values
}

int ParamRegistry::maxRevNum()
{
    if(mRevHistory.empty())
        return mRevNum;

    return mRevHistory.back().revNum;
}

int ParamRegistry::currentRevNum()
{
    return mRevNum;
}

void ParamRegistry::setCurrentRevNum(int revNum)
{
    Q_ASSERT(mHistoryElideCount == 0);

    if(mRevHistory.empty()
            || revNum < (mRevHistory.first().revNum - 1)
            || revNum > mRevHistory.last().revNum
            || mHistoryElideCount)
        return;

    QMap<QString, QVariant> newParamValues;

    auto curRevNumEnd = std::upper_bound(mRevHistory.begin(), mRevHistory.end(), mRevNum);

    // Collect all param changes
    if(revNum < mRevNum)
    {
        // play backwards (undo)
        auto newRevNumBegin = std::upper_bound(mRevHistory.begin(), mRevHistory.end(), revNum);
        for(auto it = curRevNumEnd - 1; it >= newRevNumBegin; --it)
            newParamValues[it->param->key()] = it->oldValue;
    }
    else if(revNum > mRevNum)
    {
        // play forwards (redo)
        auto newRevNumEnd = std::upper_bound(mRevHistory.begin(), mRevHistory.end(), revNum);
        for(auto it = curRevNumEnd; it < newRevNumEnd; ++it)
            newParamValues[it->param->key()] = it->newValue;
    }

    mHistoryIgnore = true;  // do not record history while writing values to params
    for(auto key : newParamValues.keys())
    {
        mParams[key]->setSerializableRawValue(newParamValues[key]);
        mParamValues[key] = newParamValues[key];
    }
    mHistoryIgnore = false;

    mRevNum = revNum;
    emit currentRevNumChanged();
}

void ParamRegistry::registerParam(Param * param)
{
    QString key = param->key();
    if(mParams.count(key))
    {
        qDebug() << key << "already exists in registry";
        Q_ASSERT(!mParams.count(key));
    }
    Q_ASSERT(param->minSize() > 0);
    Q_ASSERT(param->maxSize() >= param->minSize());

    mParams[key] = param;
    mParamKeys.insert(std::lower_bound(mParamKeys.begin(), mParamKeys.end(), key), key);

    if(param->saveable())
        mSaveableParamKeys.insert(std::lower_bound(mSaveableParamKeys.begin(), mSaveableParamKeys.end(), key), key);
    mParamValues[key] = QVariant();

    connect(param, &Param::validChanged, this, &ParamRegistry::onParamDirtyValidChanged);
    connect(param, &Param::writeCacheDirtyChanged, this, &ParamRegistry::onParamDirtyValidChanged);
    connect(param, &Param::rawValueChanged, this, &ParamRegistry::onParamRawValueChanged);
    connect(param, &Param::saveableChanged, this, &ParamRegistry::onParamSaveableChanged);
}

Param * ParamRegistry::getParam(const QString & key)
{
    auto it = mParams.find(key);
    if(it != mParams.end())
        return *it;
    else
        return nullptr;
}

void ParamRegistry::resetCaches()
{
    for(Param * param : mParams)
        param->resetCaches();
}

void ParamRegistry::setValidAll(bool valid)
{
    ParamHistoryElide elide = historyElide();
    for(Param *param : mParams)
        param->setValid(valid);
}

void ParamRegistry::setWriteCacheDirtyAll(bool dirty)
{
    for(Param *param : mParams)
        param->setWriteCacheDirty(dirty);
}

ParamHistoryElide ParamRegistry::historyElide()
{
    return ParamHistoryElide(*this);
}

void ParamRegistry::beginHistoryElide()
{
    if(mHistoryElideCount == 0)
    {
        ++mRevNum;
        emit currentRevNumChanged();
    }
    ++mHistoryElideCount;
}

void ParamRegistry::endHistoryElide()
{
    --mHistoryElideCount;

    if(mHistoryElideCount == 0)
    {
        if(updateDelta<>(mRevNum, std::min(mRevNum, maxRevNum())))  // nothing happened during the history elide
            emit currentRevNumChanged();
    }

    Q_ASSERT(mHistoryElideCount >= 0);
}

void ParamRegistry::onParamRawValueChanged(QString key)
{
    Q_ASSERT(mParams.count(key));
    Q_ASSERT(mParamValues.count(key));

    if(mHistoryIgnore)
        return;

    Param * param = mParams[key];

    int oldMinRevNum = minRevNum();
    int oldMaxRevNum = maxRevNum();
    int oldRevNum = mRevNum;

    auto curRevNumRange = std::equal_range(mRevHistory.begin(), mRevHistory.end(), mRevNum);

    // Delete any revisions past the current one
    mRevHistory.erase(curRevNumRange.second, mRevHistory.end());

    if(!mHistoryElideCount)
        ++mRevNum;

    Revision rev { mRevNum, param, mParamValues[key], param->getSerializableRawValue() };
    mParamValues[key] = rev.newValue;

    auto insertIt = std::lower_bound(curRevNumRange.first, curRevNumRange.second, rev, &Revision::compareNumAndParam);

    // If eliding multiple changes into one revision number, see if there is already a change for this key
    if(mHistoryElideCount
            && insertIt != mRevHistory.end()
            && insertIt->revNum == rev.revNum
            && insertIt->param == rev.param)
        insertIt->newValue = rev.newValue;
    else
        mRevHistory.insert(insertIt, rev);

    int numToDelete = std::max(mRevHistory.size() - mRevHistoryLength, 0);
    auto itToDelete = mRevHistory.begin() + numToDelete;
    auto clampedItToDelete = std::min(itToDelete, std::lower_bound(mRevHistory.begin(), mRevHistory.end(), mRevNum));   // Don't delete part of the currently accumulated revision
    mRevHistory.erase(mRevHistory.begin(), clampedItToDelete);

    if(oldMinRevNum != minRevNum())
        emit minRevNumChanged();
    if(oldMaxRevNum != maxRevNum())
        emit maxRevNumChanged();
    if(oldRevNum != mRevNum)
        emit currentRevNumChanged();
}

void ParamRegistry::onParamDirtyValidChanged(QString key)
{
    Q_ASSERT(mParams.count(key));

    bool regPrevDirty = !mWriteCacheDirtyKeys.empty();
    bool dirty = mParams[key]->writeCacheDirty() && mParams[key]->valid();
    auto keyIt = std::lower_bound(mWriteCacheDirtyKeys.begin(), mWriteCacheDirtyKeys.end(), key);
    if(dirty)
    {
        if(keyIt == mWriteCacheDirtyKeys.end() || *keyIt != key)
            mWriteCacheDirtyKeys.insert(keyIt, key);
    }
    else
    {
        if(keyIt != mWriteCacheDirtyKeys.end() && *keyIt == key)
            mWriteCacheDirtyKeys.erase(keyIt);
    }
    bool regDirty = !mWriteCacheDirtyKeys.empty();
    if(regPrevDirty != regDirty)
        emit writeCacheDirtyChanged();
}

void ParamRegistry::onParamSaveableChanged()
{
    Param * param = qobject_cast<Param *>(QObject::sender());
    QString key = param->key();

    if(param->saveable())
    {
        if(!mSaveableParamKeys.contains(key))
            mSaveableParamKeys.insert(std::lower_bound(mSaveableParamKeys.begin(), mSaveableParamKeys.end(), key), key);
    }
    else
    {
        auto it = std::find(mSaveableParamKeys.begin(), mSaveableParamKeys.end(), key);
        if(it != mSaveableParamKeys.end())
            mSaveableParamKeys.erase(it);
    }
}

} // namespace SetupTools
