#ifndef SETUPTOOLS_PARAMREGISTRY_H
#define SETUPTOOLS_PARAMREGISTRY_H

#include <QObject>
#include "Param.h"

namespace SetupTools {

class ParamHistoryElide
{
    friend class ParamRegistry;
    ParamHistoryElide(ParamRegistry & registry);
public:
    ParamHistoryElide(const ParamHistoryElide & other);
    ParamHistoryElide & operator =(const ParamHistoryElide &);
    ~ParamHistoryElide();

    ParamHistoryElide() = delete;
private:
    ParamRegistry * mRegistry;
};

class ParamRegistry : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool writeCacheDirty READ writeCacheDirty NOTIFY writeCacheDirtyChanged)
    Q_PROPERTY(QList<QString> paramKeys READ paramKeys NOTIFY paramsChanged)
    Q_PROPERTY(QList<QString> saveableParamKeys READ saveableParamKeys NOTIFY paramsChanged)
    Q_PROPERTY(int minRevNum READ minRevNum NOTIFY minRevNumChanged)
    Q_PROPERTY(int maxRevNum READ maxRevNum NOTIFY maxRevNumChanged)
    Q_PROPERTY(int currentRevNum READ currentRevNum WRITE setCurrentRevNum NOTIFY currentRevNumChanged)
    Q_PROPERTY(int revHistoryLength MEMBER mRevHistoryLength)

    struct Revision
    {
        static bool compareNumAndParam(const Revision & lhs, const Revision & rhs);

        int revNum;
        Param * param;
        QVariant oldValue, newValue;
    };

    friend bool operator <(const Revision & lhs, int rhs);
    friend bool operator <(int lhs, const Revision & rhs);

public:
    explicit ParamRegistry(QObject *parent = 0);
    virtual ~ParamRegistry() = default;

    const QList<QString> &paramKeys() const
    {
        return mParamKeys;
    }
    const QList<QString> &saveableParamKeys() const
    {
        return mSaveableParamKeys;
    }
    bool writeCacheDirty() const
    {
        return !mWriteCacheDirtyKeys.empty();
    }

    int minRevNum();
    int maxRevNum();
    int currentRevNum();
    void setCurrentRevNum(int revNum);

    void registerParam(Param * param);

    Q_INVOKABLE SetupTools::Param * getParam(const QString & key);
    Q_INVOKABLE void resetCaches();
    Q_INVOKABLE void setValidAll(bool valid);
    Q_INVOKABLE void setWriteCacheDirtyAll(bool dirty);

    ParamHistoryElide historyElide();

    Q_INVOKABLE void beginHistoryElide();   // for use from QML, where object lifetime can be a little murky
    Q_INVOKABLE void endHistoryElide();

signals:
    void paramsChanged();
    void writeCacheDirtyChanged();
    void minRevNumChanged();
    void maxRevNumChanged();
    void currentRevNumChanged();

private slots:
    void onParamRawValueChanged(QString key);
    void onParamSaveableChanged();
    void onParamDirtyValidChanged(QString key);

private:
    QMap<QString, Param *> mParams;
    QMap<QString, QVariant> mParamValues;
    QList<QString> mParamKeys;  // maintain our own list of keys because QMap<>::keys() just builds a new list every time
    QList<QString> mSaveableParamKeys;  // maintain our own list of keys because QMap<>::keys() just builds a new list every time
    QList<QString> mWriteCacheDirtyKeys;

    int mHistoryElideCount;
    bool mHistoryIgnore;
    int mRevNum;
    int mRevHistoryLength;
    QVector<Revision> mRevHistory;
};

} // namespace SetupTools

#endif // SETUPTOOLS_PARAMREGISTRY_H
