#ifndef TESTINGSLAVE_H
#define TESTINGSLAVE_H

#include <QObject>

class TestingSlave : public QObject
{
    Q_OBJECT
public:
    enum class MemType {
        Calib,
        Prog
    };
    enum class OpType {
        Connect,
        Disconnect,
        GetStatus,
        Synch,
        GetCommModeInfo,
        SetRequest,
        SetMta,
        Upload,
        ShortUpload,
        TransportLayerCmd,
        Download,
        DownloadNext,
        SetCalPage,
        GetCalPage,
        ProgramStart,
        ProgramClear,
        Program,
        ProgramReset,
        ProgramVerify,
        ProgramNext,
        NvWrite
    };
    explicit TestingSlave(QObject *parent = 0); // starts thread
    void SetAG(int ag);
    void SetMasterBlockSupport(bool enable);
    int AddMemRange(MemType, size_t base, size_t len);
    int AddMemRange(MemType, size_t base, std::vector<quint8> data);
    std::vector<quint8> GetMemRange(int idx);
    void RemoveMemRange(int idx);
    void SetResponseDelay(OpType op, int delayMsec, int lifetimeIter);	// delayMsec < 0 means never respond, lifetimeIter < 0 means lasts forever

signals:

public slots:

};

#endif // TESTINGSLAVE_H
