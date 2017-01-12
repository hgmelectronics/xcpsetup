import QtQuick 2.5
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

ParamRegistry {
    id: root

    property bool isDriverOnly: true

    property Slots slots: Slots {}

    property TableParam aioAiCts: TableParam {
        x: SlotArrayModel {
           slot: slots.count
           count: 24
       }
        value: ArrayParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00011000
            minCount: 24
            maxCount: 24
            writable: false
            saveable: false
            slot: slots.aiVolts
            name: qsTr("AI Voltage")
        }
    }

    property TableParam aioAoCts: TableParam {
        x: SlotArrayModel {
           slot: slots.count
           count: 8
       }
        value: ArrayParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00011020
            minCount: 8
            maxCount: 8
            writable: true
            saveable: false
            slot: slots.aoVolts
            name: qsTr("AO Voltage")
        }
    }

    property ScalarMetaParam dioBrdg1PhsAError: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00031000
            writable: false
            saveable: false
            slot: slots.bool01
            name: qsTr("Bridge 1 Phase A Error")
        }
    }
    property ScalarMetaParam dioBrdg1PhsBError: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00031001
            writable: false
            saveable: false
            slot: slots.bool01
            name: qsTr("Bridge 1 Phase B Error")
        }
    }
    property ScalarMetaParam dioBrdg1PhsCError: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00031002
            writable: false
            saveable: false
            slot: slots.bool01
            name: qsTr("Bridge 1 Phase C Error")
        }
    }
    property ScalarMetaParam dioBrdg2PhsAError: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00031003
            writable: false
            saveable: false
            slot: slots.bool01
            name: qsTr("Bridge 2 Phase A Error")
        }
    }
    property ScalarMetaParam dioBrdg2PhsBError: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00031004
            writable: false
            saveable: false
            slot: slots.bool01
            name: qsTr("Bridge 2 Phase B Error")
        }
    }
    property ScalarMetaParam dioBrdg2PhsCError: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00031005
            writable: false
            saveable: false
            slot: slots.bool01
            name: qsTr("Bridge 2 Phase C Error")
        }
    }
    property ScalarMetaParam dioBrdg1VoltError: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00031006
            writable: false
            saveable: false
            slot: slots.bool01
            name: qsTr("Bridge 1 Volt Error")
        }
    }
    property ScalarMetaParam dioBrdg1TempError: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00031007
            writable: false
            saveable: false
            slot: slots.bool01
            name: qsTr("Bridge 1 Temp Error")
        }
    }
    property ScalarMetaParam dioBrdg2Overtemp: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00031008
            writable: false
            saveable: false
            slot: slots.bool01
            name: qsTr("Bridge 2 Overtemp")
        }
    }
    property ScalarMetaParam dioCtc1Aux: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00031009
            writable: false
            saveable: false
            slot: slots.bool01
            name: qsTr("Ctc 1 Aux Contact")
        }
    }
    property ScalarMetaParam dioCtc2Aux: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x0003100A
            writable: false
            saveable: false
            slot: slots.bool01
            name: qsTr("Ctc 2 Aux Contact")
        }
    }
    property ScalarMetaParam dioCtc3Aux: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x0003100B
            writable: false
            saveable: false
            slot: slots.bool01
            name: qsTr("Ctc 3 Aux Contact")
        }
    }
    property ScalarMetaParam dioSpareDi1: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x0003100C
            writable: false
            saveable: false
            slot: slots.bool01
            name: qsTr("Spare DI 1")
        }
    }

    property ScalarMetaParam dioCtc1Coil: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00031100
            writable: true
            saveable: false
            slot: slots.bool01
            name: qsTr("Ctc 1 Coil")
        }
    }
    property ScalarMetaParam dioCtc2Coil: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00031101
            writable: true
            saveable: false
            slot: slots.bool01
            name: qsTr("Ctc 2 Coil")
        }
    }
    property ScalarMetaParam dioCtc3Coil: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00031102
            writable: true
            saveable: false
            slot: slots.bool01
            name: qsTr("Ctc 3 Coil")
        }
    }
    property ScalarMetaParam dioBrdg2FetEnable: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00031103
            writable: true
            saveable: false
            slot: slots.bool01
            name: qsTr("Bridge 2 FET Enable")
        }
    }
    property ScalarMetaParam dioSpareDo1: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00031104
            writable: true
            saveable: false
            slot: slots.bool01
            name: qsTr("Spare DO 1")
        }
    }
    property ScalarMetaParam dioSoftBaseblock: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00031105
            writable: true
            saveable: false
            slot: slots.bool01
            name: qsTr("Soft Baseblock")
        }
    }

    property ScalarMetaParam pwmBridge1Deadband: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00040000
            writable: true
            saveable: false
            slot: slots.timeSecAsUsec
            name: qsTr("Bridge 1 Deadband")
        }
    }
    property ScalarMetaParam pwmBridge1Freq: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00041000
            writable: true
            saveable: false
            slot: slots.freqHz
            name: qsTr("Bridge 1 Freq")
        }
    }
    property ScalarMetaParam pwmBridge1RotationCba: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00041001
            writable: true
            saveable: false
            slot: slots.phaseOrder
            name: qsTr("Bridge 1 Phase Order")
        }
    }
    property ScalarMetaParam pwmBridge1Peak: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00041002
            writable: true
            saveable: false
            slot: slots.percentage
            name: qsTr("Bridge 1 Peak")
        }
        immediateWrite: false
    }
    property ScalarMetaParam pwmBridge1Zero: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00041003
            writable: true
            saveable: false
            slot: slots.percentage
            name: qsTr("Bridge 1 Zero")
        }
        immediateWrite: false
    }
    property ScalarMetaParam pwmBridge1TopForce: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00041004
            writable: true
            saveable: false
            slot: slots.bridgeForce
            name: qsTr("Bridge 1 Top Force")
        }
        immediateWrite: false
    }
    property ScalarMetaParam pwmBridge1BottomForce: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00041005
            writable: true
            saveable: false
            slot: slots.bridgeForce
            name: qsTr("Bridge 1 Bottom Force")
        }
        immediateWrite: false
    }
    property ScalarMetaParam pwmBridge1PhaseAPeak: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00041006
            writable: true
            saveable: false
            slot: slots.pwmPercentage
            name: qsTr("Bridge 1 Phase A Peak")
        }
        immediateWrite: false
    }
    property ScalarMetaParam pwmBridge1PhaseBPeak: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00041007
            writable: true
            saveable: false
            slot: slots.pwmPercentage
            name: qsTr("Bridge 1 Phase B Peak")
        }
        immediateWrite: false
    }
    property ScalarMetaParam pwmBridge1PhaseCPeak: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00041008
            writable: true
            saveable: false
            slot: slots.pwmPercentage
            name: qsTr("Bridge 1 Phase C Peak")
        }
        immediateWrite: false
    }
    property ScalarMetaParam pwmBridge1PhaseAZero: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00041009
            writable: true
            saveable: false
            slot: slots.pwmPercentage
            name: qsTr("Bridge 1 Phase A Zero")
        }
        immediateWrite: false
    }
    property ScalarMetaParam pwmBridge1PhaseBZero: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x0004100A
            writable: true
            saveable: false
            slot: slots.pwmPercentage
            name: qsTr("Bridge 1 Phase B Zero")
        }
        immediateWrite: false
    }
    property ScalarMetaParam pwmBridge1PhaseCZero: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x0004100B
            writable: true
            saveable: false
            slot: slots.pwmPercentage
            name: qsTr("Bridge 1 Phase C Zero")
        }
        immediateWrite: false
    }
    property ScalarMetaParam pwmBridge2Freq: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x0004100C
            writable: true
            saveable: false
            slot: slots.freqHz
            name: qsTr("Bridge 2 Freq")
        }
    }
    property ScalarMetaParam pwmBridge2Duty: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x0004100D
            writable: true
            saveable: false
            slot: slots.percentage
            name: qsTr("Bridge 2 Duty")
        }
        immediateWrite: false
    }
    property ScalarMetaParam pwmBridge2DutyA: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x0004100E
            writable: true
            saveable: false
            slot: slots.pwmPercentage
            name: qsTr("Bridge 2 DutyA")
        }
        immediateWrite: false
    }
    property ScalarMetaParam pwmBridge2DutyB: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x0004100F
            writable: true
            saveable: false
            slot: slots.pwmPercentage
            name: qsTr("Bridge 2 DutyB")
        }
        immediateWrite: false
    }
    property ScalarMetaParam pwmBridge2TopForce: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00041010
            writable: true
            saveable: false
            slot: slots.bridgeForce
            name: qsTr("Bridge 2 Top Force")
        }
        immediateWrite: false
    }
    property ScalarMetaParam pwmBridge2BottomForce: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00041011
            writable: true
            saveable: false
            slot: slots.bridgeForce
            name: qsTr("Bridge 2 Bottom Force")
        }
        immediateWrite: false
    }
    property ScalarMetaParam pwmBridge2PhaseADutyA: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00041012
            writable: true
            saveable: false
            slot: slots.pwmPercentage
            name: qsTr("Bridge 2 Phase A DutyA")
        }
        immediateWrite: false
    }
    property ScalarMetaParam pwmBridge2PhaseBDutyA: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00041013
            writable: true
            saveable: false
            slot: slots.pwmPercentage
            name: qsTr("Bridge 2 Phase B DutyA")
        }
        immediateWrite: false
    }
    property ScalarMetaParam pwmBridge2PhaseCDutyA: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00041014
            writable: true
            saveable: false
            slot: slots.pwmPercentage
            name: qsTr("Bridge 2 Phase C DutyA")
        }
        immediateWrite: false
    }
    property ScalarMetaParam pwmBridge2PhaseADutyB: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00041015
            writable: true
            saveable: false
            slot: slots.pwmPercentage
            name: qsTr("Bridge 2 Phase A DutyB")
        }
        immediateWrite: false
    }
    property ScalarMetaParam pwmBridge2PhaseBDutyB: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00041016
            writable: true
            saveable: false
            slot: slots.pwmPercentage
            name: qsTr("Bridge 2 Phase B DutyB")
        }
        immediateWrite: false
    }
    property ScalarMetaParam pwmBridge2PhaseCDutyB: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00041017
            writable: true
            saveable: false
            slot: slots.pwmPercentage
            name: qsTr("Bridge 2 Phase C DutyB")
        }
        immediateWrite: false
    }




    property ScalarMetaParam sysCycleIdle: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00071000
            writable: false
            saveable: false
            slot: slots.timeUsec
            name: qsTr("Sys Cycle Idle")
        }
    }
    property ScalarMetaParam sysCycleDrvAioIn: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00071001
            writable: false
            saveable: false
            slot: slots.timeUsec
            name: qsTr("Sys Cycle AIO Input")
        }
    }
    property ScalarMetaParam sysCycleDrvAioOut: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00071002
            writable: false
            saveable: false
            slot: slots.timeUsec
            name: qsTr("Sys Cycle AIO Output")
        }
    }
    property ScalarMetaParam sysCycleDrvCanIn: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00071003
            writable: false
            saveable: false
            slot: slots.timeUsec
            name: qsTr("Sys Cycle CAN Input")
        }
    }
    property ScalarMetaParam sysCycleDrvCanOut: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00071004
            writable: false
            saveable: false
            slot: slots.timeUsec
            name: qsTr("Sys Cycle CAN Output")
        }
    }
    property ScalarMetaParam sysCycleDrvDioIn: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00071005
            writable: false
            saveable: false
            slot: slots.timeUsec
            name: qsTr("Sys Cycle DIO Input")
        }
    }
    property ScalarMetaParam sysCycleDrvDioOut: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00071006
            writable: false
            saveable: false
            slot: slots.timeUsec
            name: qsTr("Sys Cycle DIO Output")
        }
    }
    property ScalarMetaParam sysCycleDrvPwmIn: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00071007
            writable: false
            saveable: false
            slot: slots.timeUsec
            name: qsTr("Sys Cycle PWM Input")
        }
    }
    property ScalarMetaParam sysCycleDrvPwmOut: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00071008
            writable: false
            saveable: false
            slot: slots.timeUsec
            name: qsTr("Sys Cycle PWM Output")
        }
    }

    property ScalarMetaParam sysFlags: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00072000
            writable: false
            saveable: false
            slot: slots.count
            name: qsTr("Sys Flags")
        }
    }
    property ScalarMetaParam sysHeapAllocBytes: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00072001
            writable: false
            saveable: false
            slot: slots.count
            name: qsTr("Heap Alloc Bytes")
        }
    }
    property ScalarMetaParam sysHeapFreeBytes: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00072002
            writable: false
            saveable: false
            slot: slots.count
            name: qsTr("Heap Free Bytes")
        }
    }
    property ScalarMetaParam sysHeapNFrees: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00072003
            writable: false
            saveable: false
            slot: slots.count
            name: qsTr("Heap Free Count")
        }
    }
    property ScalarMetaParam sysRtDbRows: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00072004
            writable: false
            saveable: false
            slot: slots.count
            name: qsTr("RTDB Rows")
        }
    }

    property ScalarMetaParam eventBeginSerial: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.S32
            addr: 0x10000000
            writable: false
            saveable: false
            slot: slots.raw32
            name: qsTr("Event Log Begin Serial")
        }
    }

    property ScalarMetaParam eventEndSerial: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.S32
            addr: 0x10000008
            writable: false
            saveable: false
            slot: slots.raw32
            name: qsTr("Event Log End Serial")
        }
    }
    property ScalarMetaParam eventClearToSerial: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.S32
            addr: 0x10000010
            writable: true
            saveable: false
            slot: slots.raw32
            name: qsTr("Event Log Clear-To Serial")
        }
        immediateWrite: false
    }
    property ScalarMetaParam eventViewSerial: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.S32
            addr: 0x10000018
            writable: true
            saveable: false
            slot: slots.raw32
            name: qsTr("Event Log View Serial")
        }
        immediateWrite: false
    }
    property ScalarMetaParam eventViewKey: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.U32
            addr: 0x10000020
            writable: false
            saveable: false
            slot: slots.rawu32hex
            name: qsTr("Viewed Event Key")
        }
    }
    property ScalarMetaParam eventViewFreezeSize: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.U32
            addr: 0x10000038
            writable: false
            saveable: false
            slot: slots.raw32
            name: qsTr("Viewed Event Freeze Size")
        }
    }
    property TableParam eventViewFreeze: TableParam {
        x: SlotArrayModel {
            slot: slots.raw32
            count: 16
        }
        value: ArrayParam {
            registry: root
            bigEndian: true
            dataType: Param.U32
            addr: 0x10000040
            minCount: 16
            writable: false
            saveable: false
            slot: slots.rawu32hex
            name: qsTr("Viewed Event Freeze")
        }
    }
}
