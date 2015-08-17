#ifndef SETUPTOOLS_XCP_PARAM_H
#define SETUPTOOLS_XCP_PARAM_H

#include <QObject>
#include <Xcp_Exception.h>

namespace SetupTools {
namespace Xcp {

class Param : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool saveable MEMBER saveable)
public:
    explicit Param(QObject *parent = 0);

    bool saveable;
signals:
    void uploadDone(SetupTools::Xcp::OpResult result);
    void downloadDone(SetupTools::Xcp::OpResult result);
public slots:
    virtual void upload() = 0;
    virtual void download() = 0;
};

}   // namespace Xcp
} // namespace SetupTools

#endif // SETUPTOOLS_XCP_PARAM_H
