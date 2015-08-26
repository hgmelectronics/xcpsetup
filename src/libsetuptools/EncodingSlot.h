#ifndef SETUPTOOLS_ENCODINGSLOT_H
#define SETUPTOOLS_ENCODINGSLOT_H

#include <QObject>
#include <QAbstractListModel>
#include <Slot.h>
#include <boost/optional.hpp>

namespace SetupTools {

struct EncodingPair
{
    double raw;
    QString text;

    inline bool operator==(EncodingPair &other)
    {
        return (raw == other.raw) && (text == other.text);
    }
};

class EncodingListModel : public QAbstractListModel
{
    Q_OBJECT
public:
    EncodingListModel(QObject *parent = nullptr);

    virtual int rowCount(const QModelIndex & parent = QModelIndex()) const;
    virtual QVariant data(const QModelIndex &index, int role) const;
    virtual bool setData(const QModelIndex &index, const QVariant &value, int role);
    virtual Qt::ItemFlags flags(const QModelIndex &index) const;
    virtual QHash<int, QByteArray> roleNames() const;
    virtual bool insertRows(int row, int count, const QModelIndex &parent = QModelIndex());
    virtual bool removeRows(int row, int count, const QModelIndex &parent = QModelIndex());

    Q_INVOKABLE void append(double raw, QString engr);

    boost::optional<QString> rawToEngr(double raw) const;
    boost::optional<double> engrToRaw(QString engr) const;
signals:
    void changed();
private:
    constexpr static int TEXT_ROLE = Qt::DisplayRole;
    constexpr static int RAW_ROLE = Qt::UserRole;

    void removeRowFromMaps(const EncodingPair &row);

    QList<EncodingPair> mList;
    QMap<double, QString> mRawToEngr;
    QMap<QString, double> mEngrToRaw;
};

class EncodingSlot : public Slot
{
    Q_OBJECT

    Q_PROPERTY(SetupTools::Slot *unencodedSlot READ unencodedSlot WRITE setUnencodedSlot NOTIFY unencodedSlotChanged)       //!< SLOT used when the value to be converted is not in the encoding model
    Q_PROPERTY(SetupTools::EncodingListModel *model READ model NOTIFY modelChanged)
    Q_PROPERTY(double oorFloat MEMBER oorFloat) //!< Engineering value returned when raw value is not convertible
    Q_PROPERTY(QString oorString MEMBER oorString) //!< Engineering value returned when raw value is not convertible
    Q_PROPERTY(QVariant oorRaw MEMBER oorRaw)   //!< Raw value returned when engineering value is not convertible
public:
    EncodingSlot(QObject *parent = nullptr);

    SetupTools::Slot *unencodedSlot();
    void setUnencodedSlot(Slot *);
    SetupTools::EncodingListModel *model();

    Q_INVOKABLE virtual double toFloat(QVariant raw) const;
    Q_INVOKABLE virtual QString toString(QVariant raw) const;
    Q_INVOKABLE virtual QVariant toRaw(QVariant engr) const;
    Q_INVOKABLE virtual bool rawInRange(QVariant raw) const;
    Q_INVOKABLE virtual bool engrInRange(QVariant engr) const;

    double oorFloat;
    QString oorString;
    QVariant oorRaw;
signals:
    void unencodedSlotChanged();
    void modelChanged();
public slots:
    void onModelChanged();
private:
    Slot *mUnencodedSlot;
    EncodingListModel *mModel;
};

} // namespace SetupTools

#endif // SETUPTOOLS_ENCODINGSLOT_H
