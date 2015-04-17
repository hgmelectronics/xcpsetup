#ifndef THINGDOER_H
#define THINGDOER_H

#include <QObject>
#include <Xcp_Interface_Can_Elm327_Interface.h>
#include <Xcp_ConnectionFacade.h>
#include <QtSerialPort/QtSerialPort>

class ThingDoer : public QObject
{
    Q_OBJECT
public:
    ThingDoer();
public slots:
    void start();
    void onGetAvailSlavesStrDone(SetupTools::Xcp::OpResult result, QString bcastId, QString filter, QList<QString> slaveIds);
    void onSetStateDone(SetupTools::Xcp::OpResult result);
    void onResetDone(SetupTools::Xcp::OpResult result);
private:
    constexpr static const int N_GET_AVAIL_ITER = 20;
    SetupTools::Xcp::ConnectionFacade *mConn;
    QTextStream mQin, mQout;
    int mGetAvailIter;
};

#endif // THINGDOER_H
