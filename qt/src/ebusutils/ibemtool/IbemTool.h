#ifndef IBEMTOOL_H
#define IBEMTOOL_H

#include <QObject>
#include <MultiselectList.h>
#include <ProgFile.h>
#include <Xcp_ProgramLayer.h>

namespace SetupTools
{

/*
 * Program flow:
 *
 *  User selects program file (button Open Program)
 *  User selects interface (drop-down)
 *  User clicks Open Interface (or maybe it happens on selecting interface)
 *  We poll for IBEMs, stuff slave selection menu
 *  User picks boards to load
 *  User clicks Go
 *  On each board's completion, we uncheck it from the selection menu
 *  On completion of all boards or failure, throw up a dialog
 */

class IbemTool : public QObject
{
    Q_OBJECT
    Q_PROPERTY(MultiselectListModel slaveListModel READ slaveListModel NOTIFY slaveListModelChanged)
    Q_PROPERTY(QString programFilePath READ programFilePath WRITE setProgramFilePath NOTIFY programChanged)
    Q_PROPERTY(int programSize READ programSize NOTIFY programChanged)
    Q_PROPERTY(uint programBase READ programBase NOTIFY programChanged)
    Q_PROPERTY(bool programOk READ programOk NOTIFY programChanged)
    Q_PROPERTY(int progress READ progress NOTIFY progressChanged)
    Q_PROPERTY(QString intfcUri READ intfcUri WRITE setIntfcUri NOTIFY intfcUriChanged)
public:
    explicit IbemTool(QObject *parent = 0);
    ~IbemTool();

    MultiselectListModel *slaveListModel();
    QString programFilePath();
    void setProgramFilePath(QString path);
    int programSize();
    uint programBase();
    bool programOk();
    int progress();
    QString intfcUri();
    void setIntfcUri(QString uri);
signals:
    void slaveListModelChanged();
    void programChanged();
    void progressChanged();
    void intfcUriChanged();

    void programmingDone(bool ok);
public slots:
    void startProgramming();
    void onSetSlaveIdDone(Xcp::OpResult result);
    void onProgramDone(Xcp::OpResult result);
    void onProgramVerifyDone(Xcp::OpResult result);
    void onProgramResetDone(Xcp::OpResult result);
private:
    Xcp::ProgramLayer *mProgLayer;
    ProgFile *mProgFile;
    MultiselectListModel *mSlaveListModel;
};

} // namespace SetupTools

#endif // IBEMTOOL_H
