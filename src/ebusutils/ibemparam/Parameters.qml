import QtQuick 2.5
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

ParamRegistry {
    id: root

//    readonly property double boardId:                           0x0000
//    readonly property double afeCalibZero:                      0x0004
//    readonly property double afeCalibScale:                     0x0014
//    readonly property double vocModelSoc:                       0x0034
//    readonly property double vocModelVoc:                       0x0060
//    readonly property double riModelSocBreakpt:                 0x008C
//    readonly property double riModelRAtZeroSoc:                 0x0090

    property Slots slots: Slots {}

    property ScalarMetaParam boardId: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            addr: '0000'
            writable: true
            saveable: true
            dataType: Param.U8
            slot: slots.raw32
        }
        name: qsTr("Board ID")
    }

}
