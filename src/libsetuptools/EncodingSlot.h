#ifndef SETUPTOOLS_ENCODINGSLOT_H
#define SETUPTOOLS_ENCODINGSLOT_H

#include <QObject>
#include <QAbstractListModel>
#include <Slot.h>
#include <boost/optional.hpp>

namespace SetupTools {

class EncodingSlot;

class EncodingValidator : public QValidator
{
    Q_OBJECT
public:
    EncodingValidator(EncodingSlot *parent = nullptr);
public slots:
    void slotChanged();

    virtual QValidator::State validate(QString &input, int &pos) const;
};

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
    friend class EncodingValidator;

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

    Q_INVOKABLE virtual double asFloat(QVariant raw) const;
    Q_INVOKABLE virtual QString asString(QVariant raw) const;
    Q_INVOKABLE virtual QVariant asRaw(QVariant engr) const;
    Q_INVOKABLE virtual bool rawInRange(QVariant raw) const;
    Q_INVOKABLE virtual bool engrInRange(QVariant engr) const;
    Q_INVOKABLE int engrToEncodingIndex(QVariant engr) const;
    Q_INVOKABLE void append(double raw, QString engr);
    virtual QValidator *validator();

    virtual QVariant rawMin() const;
    virtual QVariant rawMax() const;
    virtual QVariant engrMin() const;
    virtual QVariant engrMax() const;

    double oorFloat;
    QString oorString;
    QVariant oorRaw;
signals:
    void unencodedSlotChanged();
    void encodingListChanged();

private:
    void onUnencodedSlotUnitChanged();
    void onUnencodedSlotValueParamChanged();

    Slot *mUnencodedSlot;
    QList<EncodingPair> mList;
    QMap<double, QString> mRawToEngr;
    QMap<QString, double> mEngrToRaw;
    QMap<QString, int> mEngrToIndex;
    double mRawMin;
    double mRawMax;

    EncodingValidator *mValidator;
};

} // namespace SetupTools

#endif // SETUPTOOLS_ENCODINGSLOT_H
