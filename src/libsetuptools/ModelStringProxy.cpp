#include "ModelStringProxy.h"
#include "util.h"

namespace SetupTools {

ModelStringProxy::ModelStringProxy(QObject *parent) :
    QObject(parent),
    mSource(nullptr),
    mRole(Qt::DisplayRole),
    mPacking(Packing::Char)
{}

QString ModelStringProxy::string() const
{
    return mString;
}

void ModelStringProxy::setSource(QAbstractItemModel *source)
{
    disconnect(mDataChangedConnection);
    disconnect(mRowsInsertedConnection);
    disconnect(mRowsRemovedConnection);
    disconnect(mColsInsertedConnection);
    disconnect(mColsRemovedConnection);

    mSource = source;

    if(mSource)
    {
        mDataChangedConnection = connect(mSource, &QAbstractItemModel::dataChanged, this, &ModelStringProxy::onSourceDataChanged);
        mRowsInsertedConnection = connect(mSource, &QAbstractItemModel::rowsInserted, this, &ModelStringProxy::onSourceRowsColsAddedRemoved);
        mRowsRemovedConnection = connect(mSource, &QAbstractItemModel::rowsRemoved, this, &ModelStringProxy::onSourceRowsColsAddedRemoved);
        mColsInsertedConnection = connect(mSource, &QAbstractItemModel::columnsInserted, this, &ModelStringProxy::onSourceRowsColsAddedRemoved);
        mColsRemovedConnection = connect(mSource, &QAbstractItemModel::columnsRemoved, this, &ModelStringProxy::onSourceRowsColsAddedRemoved);

        updateRole();

        createStringData();
    }
}

void ModelStringProxy::setRoleName(QString roleName)
{
    if(updateDelta<>(mRoleName, roleName))
    {
        updateRole();

        if(mSource)
            createStringData();
    }
}

void ModelStringProxy::setPacking(int packing)
{
    if(packing < 0 || packing >= Packing::COUNT)
        return;

    if(updateDelta<>(mPacking, packing))
    {
        if(mSource)
            createStringData();
    }
}

void ModelStringProxy::onSourceDataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight, const QVector<int> &roles)
{
    Q_UNUSED(topLeft);
    Q_UNUSED(bottomRight);

    Q_ASSERT(mSource);

    if(roles.count(mRole))
        createStringData();
}

void ModelStringProxy::onSourceRowsColsAddedRemoved(const QModelIndex &parent, int first, int last)
{
    Q_UNUSED(parent);
    Q_UNUSED(first);
    Q_UNUSED(last);

    Q_ASSERT(mSource);

    createStringData();
}

static constexpr int PACKING_BYTES[] { 1, 2, 2, 4, 4 };
static constexpr bool PACKING_REVERSE[] { false, false, true, false, true };

void ModelStringProxy::createStringData()
{
    QByteArray bytes;
    int rows = mSource->rowCount();
    int cols = mSource->columnCount();
    int bytesPerElem = PACKING_BYTES[mPacking];
    bool reverse = PACKING_REVERSE[mPacking];

    bytes.reserve(rows * cols * bytesPerElem);
    for(int i = 0, end = rows * cols; i < end; ++i)
    {
        QVariant data = mSource->data(mSource->index(i / cols, i % cols), mRole);
        uint word = QVariantToUIntOr(data, 0);
        QByteArray chars;
        chars.reserve(bytesPerElem);
        bool terminated = false;
        for(int iByte = 0; iByte < bytesPerElem; ++iByte)
        {
            char c = char(word >> (iByte * 8));

            if(c == 0)
            {
                terminated = true;
                break;
            }
            else
            {
                if(reverse)
                    chars.append(c);
                else
                    chars.prepend(c);
            }
        }
        bytes.append(chars);
        if(terminated)
            break;
    }

    QString string = QString::fromUtf8(bytes);

    if(updateDelta<>(mString, string))
        emit stringChanged();

    emit stringChanged();
}

void ModelStringProxy::updateRole()
{
    mRole = Qt::DisplayRole;

    if(mSource)
    {
        for(int role : mSource->roleNames().keys())
        {
            if(mSource->roleNames()[role] == mRoleName)
            {
                mRole = role;
                break;
            }
        }
    }
}

} // namespace SetupTools

