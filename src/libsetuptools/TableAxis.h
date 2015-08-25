#ifndef SETUPTOOLS_TABLEAXIS_H
#define SETUPTOOLS_TABLEAXIS_H

#include <QtCore>
#include <QHash>
#include <QByteArray>
#include <QObject>

namespace SetupTools {

class TableAxisRole {
    Q_GADGET

    Q_ENUMS(Roles)
public:
    typedef enum {
        XRole = Qt::UserRole,
        YRole,
        ValueRole
    } Roles;
};

class TableAxis : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(QString xUnit READ xUnit WRITE setXUnit NOTIFY xUnitChanged)
    Q_PROPERTY(QString yUnit READ yUnit WRITE setYUnit NOTIFY yUnitChanged)
public:
    explicit TableAxis(QObject *parent = nullptr);
    QString xUnit() const;
    QString yUnit() const;
    void setXUnit(QString);
    void setYUnit(QString);
signals:
    void xUnitChanged();
    void yUnitChanged();
protected:
    QString mXUnit, mYUnit;
};

} // namespace SetupTools

#endif // SETUPTOOLS_TABLEAXIS_H
