#ifndef XCP_EXCEPTION_H
#define XCP_EXCEPTION_H

#include <QException>
#include "libxconfproto_global.h"

namespace SetupTools
{
namespace Xcp
{

class LIBXCONFPROTOSHARED_EXPORT Exception : public QException {};

}
}

#endif // XCP_EXCEPTION_H
