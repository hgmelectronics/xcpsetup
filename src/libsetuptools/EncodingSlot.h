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

class EncodingSlot : public Slot
{
    Q_OBJECT

    Q_PROPERTY(SetupTools::Slot *unencodedSlot READ unencodedSlot WRITE setUnencodedSlot NOTIFY unencodedSlotChanged)       //!< SLOT used when the value to be converted is not in the encoding model
    Q_PROPERTY(QVariant encodingList READ encodingList WRITE setEncodingList NOTIFY encodingListChanged)
    Q_PROPERTY(QStringList encodingStringList READ encodingStringList NOTIFY encodingListChanged)
    Q_PROPERTY(double oorFloat MEMBER oorFloat) //!< Engineering value returned when raw value is not convertible
    Q_PROPERTY(QString oorString MEMBER oorString) //!< Engineering value returned when raw value is not convertible
    Q_PROPERTY(QVariant oorRaw MEMBER oorRaw)   //!< Raw value returned when engineering value is not convertible
public:
    EncodingSlot(QObject *parent = nullptr);

    SetupTools::Slot *unencodedSlot();
    void setUnencodedSlot(Slot *);
    QVariant encodingList();
    void setEncodingList(QVariant);
    QStringList encodingStringList();

    Q_INVOKABLE virtual double toFloat(QVariant raw) const;
    Q_INVOKABLE virtual QString toString(QVariant raw) const;
    Q_INVOKABLE virtual QVariant toRaw(QVariant engr) const;
    Q_INVOKABLE virtual bool rawInRange(QVariant raw) const;
    Q_INVOKABLE virtual bool engrInRange(QVariant engr) const;
    Q_INVOKABLE int engrToEncodingIndex(QVariant engr) const;
    Q_INVOKABLE void append(double raw, QString engr);

    double oorFloat;
    QString oorString;
    QVariant oorRaw;
signals:
    void unencodedSlotChanged();
    void encodingListChanged();
public slots:
    void onUnencodedSlotUnitChanged();
private:
    Slot *mUnencodedSlot;
    QList<EncodingPair> mList;
    QMap<double, QString> mRawToEngr;
    QMap<QString, double> mEngrToRaw;
    QMap<QString, int> mEngrToIndex;
};

} // namespace SetupTools

#endif // SETUPTOOLS_ENCODINGSLOT_H
