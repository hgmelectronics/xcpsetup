#ifndef XCP_EBUSEVENTLOGINTERFACE_H
#define XCP_EBUSEVENTLOGINTERFACE_H

#include <QObject>
#include <QAbstractListModel>
#include "Xcp_ParamLayer.h"
#include "ScalarParam.h"
#include "ArrayParam.h"
#include "LinearSlot.h"

namespace SetupTools {
namespace Xcp {

class EbusEventLogModel;

class EbusEventLogInterface : public QObject
{
    Q_OBJECT

    friend class EbusEventLogModel;

    struct Record
    {
        quint32 key;
        QVector<quint8> freeze;
    };

    Q_PROPERTY(ParamLayer * paramLayer MEMBER mParamLayer WRITE setParamLayer NOTIFY configParamChanged())
    Q_PROPERTY(QVariant beginSerialAddr MEMBER mBeginSerialAddr WRITE setBeginSerialAddr NOTIFY configParamChanged)
    Q_PROPERTY(QVariant endSerialAddr MEMBER mEndSerialAddr WRITE setEndSerialAddr NOTIFY configParamChanged)
    Q_PROPERTY(QVariant clearToSerialAddr MEMBER mClearToSerialAddr WRITE setClearToSerialAddr NOTIFY configParamChanged)
    Q_PROPERTY(QVariant viewSerialAddr MEMBER mViewSerialAddr WRITE setViewSerialAddr NOTIFY configParamChanged)
    Q_PROPERTY(QVariant viewKeyAddr MEMBER mViewKeyAddr WRITE setViewKeyAddr NOTIFY configParamChanged)
    Q_PROPERTY(QVariant viewFreezeSizeAddr MEMBER mViewFreezeSizeAddr WRITE setViewFreezeSizeAddr NOTIFY configParamChanged)
    Q_PROPERTY(QVariant viewFreezeAddr MEMBER mViewFreezeAddr WRITE setViewFreezeAddr NOTIFY configParamChanged)
    Q_PROPERTY(int viewFreezeMaxSize MEMBER mViewFreezeMaxSize WRITE setViewFreezeMaxSize NOTIFY configParamChanged)
    Q_PROPERTY(EbusEventLogModel * model READ model NOTIFY modelChanged)
    Q_PROPERTY(int minEventSerial READ minEventSerial NOTIFY boundsChanged)
    Q_PROPERTY(int maxEventSerial READ maxEventSerial NOTIFY boundsChanged)
    Q_PROPERTY(int count READ count NOTIFY boundsChanged)
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)  // TODO
public:
    explicit EbusEventLogInterface(QObject *parent = 0);

    EbusEventLogModel * model() const
    {
        return mModel;
    }
    int minEventSerial() const
    {
        return mBeginEventSerial;
    }
    int maxEventSerial() const
    {
        return mEndEventSerial - 1;
    }
    int count() const
    {
        return std::max(mEndEventSerial - mBeginEventSerial, 0);
    }
    bool busy()
    {
        return mBusy;
    }

    void setParamLayer(ParamLayer * value)
    {
        if(updateDelta<>(mParamLayer, value))
            changeConfigParam();
    }
    void setBeginSerialAddr(QVariant value)
    {
        if(updateDelta<>(mBeginSerialAddr, value))
            changeConfigParam();
    }
    void setEndSerialAddr(QVariant value)
    {
        if(updateDelta<>(mEndSerialAddr, value))
            changeConfigParam();
    }
    void setClearToSerialAddr(QVariant value)
    {
        if(updateDelta<>(mClearToSerialAddr, value))
            changeConfigParam();
    }
    void setViewSerialAddr(QVariant value)
    {
        if(updateDelta<>(mViewSerialAddr, value))
            changeConfigParam();
    }
    void setViewKeyAddr(QVariant value)
    {
        if(updateDelta<>(mViewKeyAddr, value))
            changeConfigParam();
    }
    void setViewFreezeSizeAddr(QVariant value)
    {
        if(updateDelta<>(mViewFreezeSizeAddr, value))
            changeConfigParam();
    }
    void setViewFreezeAddr(QVariant value)
    {
        if(updateDelta<>(mViewFreezeAddr, value))
            changeConfigParam();
    }
    void setViewFreezeMaxSize(int value)
    {
        if(updateDelta<>(mViewFreezeMaxSize, value))
            changeConfigParam();
    }

    Q_INVOKABLE void readEventBounds();
    Q_INVOKABLE void readBoundsAndEvents();
    Q_INVOKABLE void readAllEvents();
    Q_INVOKABLE void readEventRange(int beginSerial, int endSerial);
    Q_INVOKABLE void clearTo(int serial);

    QVariant mBeginSerialAddr;
    QVariant mEndSerialAddr;
    QVariant mClearToSerialAddr;
    QVariant mViewSerialAddr;
    QVariant mViewKeyAddr;
    QVariant mViewFreezeSizeAddr;
    QVariant mViewFreezeAddr;

    int mViewFreezeMaxSize;

    ParamLayer * mParamLayer;
signals:
    void modelChanged(quint32 beginChanged, quint32 endChanged);
    void boundsChanged();
    void configParamChanged();
    void busyChanged();
public slots:
    void onBoundsChanged();
    void onDownloadDone(SetupTools::OpResult result, QStringList keys);
    void onUploadDone(SetupTools::OpResult result, QStringList keys);
private:
    void configure();
    void setBusy(bool value)
    {
        if(updateDelta<>(mBusy, value))
            emit busyChanged();
    }
    void changeConfigParam()
    {
        Q_ASSERT(!mConfigured);
        emit configParamChanged();
        configure();
    }

    EbusEventLogModel * mModel;
    LinearSlot * mRawIntSlot;
    int mBeginEventSerial;
    int mEndEventSerial;
    int mNowReadingSerial;
    int mEndReadSerial;

    bool mConfigured;

    bool mBusy;
    bool mReadingEventsAfterBounds;

    ScalarParam * mBeginSerialParam;
    ScalarParam * mEndSerialParam;
    ScalarParam * mClearToSerialParam;
    ScalarParam * mViewSerialParam;
    ScalarParam * mViewKeyParam;
    ScalarParam * mViewFreezeSizeParam;
    ArrayParam * mViewFreezeParam;

    QMap<int, Record> mRecords;
};

class EbusEventLogModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_ENUMS(Roles)
public:
    enum Roles
    {
        Serial = Qt::UserRole,
        Key,
        Freeze
    };

    EbusEventLogModel(EbusEventLogInterface * parent);

    Q_INVOKABLE int count() const;
    virtual int rowCount(const QModelIndex & parent = QModelIndex()) const;
    virtual QVariant data(const QModelIndex & index, int role) const;
    virtual bool setData(const QModelIndex & index, const QVariant &value, int role);
    virtual Qt::ItemFlags flags(const QModelIndex & index) const;
    virtual QHash<int, QByteArray> roleNames() const;

    Q_INVOKABLE QVariant get(int index, QString roleName) const;
signals:
    void countChanged();
private slots:
    void onDataChanged(quint32 beginChanged, quint32 endChanged);
    void onBoundsChanged();
private:
    bool isValidIndex(const QModelIndex & index) const;

    EbusEventLogInterface * const mInterface;
    int mCount;
};

} // namespace Xcp
} // namespace SetupTools

#endif // XCP_EBUSEVENTLOGINTERFACE_H
