#ifndef SETUPTOOLS_SLOTARRAYMODEL_H
#define SETUPTOOLS_SLOTARRAYMODEL_H

#include <QObject>
#include <QAbstractListModel>
#include "Slot.h"

namespace SetupTools {

class SlotArrayModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(Slot *slot READ slot WRITE setSlot NOTIFY slotChanged)
    Q_PROPERTY(int count READ count WRITE setCount NOTIFY countChanged)
    Q_PROPERTY(int min READ min WRITE setMin NOTIFY minChanged)
    Q_PROPERTY(int stride READ stride WRITE setStride NOTIFY strideChanged)
    Q_PROPERTY(bool stringFormat READ stringFormat WRITE setStringFormat NOTIFY stringFormatChanged)
public:
    SlotArrayModel(QObject *parent = nullptr);
    SlotArrayModel(Slot *slot, int count, int min = 0, int stride = 1, bool stringFormat = true, QObject *parent = nullptr);

    // gets the value in enginering units
    Q_INVOKABLE QVariant get(int row) const;

    Slot *slot() const { return mSlot; }
    void setSlot(Slot *newSlot);

    int count() const { return mCount; }
    void setCount(int newCount);

    int min() const { return mMin; }
    void setMin(int newMin);

    int stride() const { return mStride; }
    void setStride(int newStride);

    bool stringFormat() const { return mStringFormat; }
    void setStringFormat(bool newStringFormat);

    virtual int rowCount(const QModelIndex & parent = QModelIndex()) const;
    virtual int columnCount(const QModelIndex &parent = QModelIndex()) const;
    virtual QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;

signals:
    void slotChanged();
    void countChanged();
    void minChanged();
    void strideChanged();
    void stringFormatChanged();

public slots:
    void onSlotValueParamChanged();

private:
    Slot *mSlot;
    int mCount;
    int mMin;
    int mStride;
    bool mStringFormat;
};

} // namespace SetupTools

#endif // SETUPTOOLS_SLOTARRAYMODEL_H
