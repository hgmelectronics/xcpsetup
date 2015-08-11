#ifndef SETUPTOOLS_XCP_PARAM_H
#define SETUPTOOLS_XCP_PARAM_H

#include <QObject>

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
public slots:
};

}   // namespace Xcp
} // namespace SetupTools

#endif // SETUPTOOLS_XCP_PARAM_H
