import QtQuick 2.5
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

ParamRegistry {
    id: root

    property bool isDriverOnly: true

    property Slots slots: Slots {}

    property TableMetaParam aioAiCts: TableMetaParam {
        param: TableParam {
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
                slot: slots.volts
                name: qsTr("AI Voltage")
            }
        }
        isLiveData: true
    }

    property TableMetaParam aioAoCts: TableMetaParam {
        param: TableParam {
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
                slot: slots.volts
                name: qsTr("AO Voltage")
            }
        }
        isLiveData: true
    }

    property ScalarMetaParam aioCurrZeroCalibStart: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00011100
            writable: true
            saveable: false
            slot: slots.bool01
            name: qsTr("Zero Calib Start")
        }
        immediateWrite: true
    }

    property ScalarMetaParam aioCurrZeroCalibDone: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00011101
            writable: false
            saveable: false
            slot: slots.bool01
            name: qsTr("Zero Calib Done")
        }
        isLiveData: true
    }

    property ScalarMetaParam aioMagneticsTemp: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00012000
            writable: false
            saveable: false
            slot: slots.degC
            name: qsTr("Magnetics Temp")
        }
    }

    property ScalarMetaParam aioColdplateTemp: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00012001
            writable: false
            saveable: false
            slot: slots.degC
            name: qsTr("Coldplate Temp")
        }
    }

    property ScalarMetaParam aioIgbt1Temp: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00012002
            writable: false
            saveable: false
            slot: slots.degC
            name: qsTr("IGBT 1 Temp")
        }
    }

    property ScalarMetaParam aioIgbt2Temp: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00012003
            writable: false
            saveable: false
            slot: slots.degC
            name: qsTr("IGBT 2 Temp")
        }
    }

    property ScalarMetaParam aioVbatVolt: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00012004
            writable: false
            saveable: false
            slot: slots.volts
            name: qsTr("Vbat")
        }
    }

    property ScalarMetaParam aioVref2V5Volt: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00012005
            writable: false
            saveable: false
            slot: slots.volts
            name: qsTr("2.5Vref")
        }
    }

    property ScalarMetaParam aioBcAcVoltageAB: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00013000
            writable: false
            saveable: false
            slot: slots.volts
            name: qsTr("BC Line Voltage A-B")
        }
    }

    property ScalarMetaParam aioBcAcVoltageCB: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00013001
            writable: false
            saveable: false
            slot: slots.volts
            name: qsTr("BC Line Volt C-B")
        }
    }

    property TableMetaParam aioBcAcCurrent: TableMetaParam {
        param: TableParam {
            x: SlotArrayModel {
               slot: slots.phaseName
               count: 3
            }
            value: ArrayParam {
                registry: root
                bigEndian: true
                dataType: Param.F32
                addr: 4 * 0x00013002
                minCount: 3
                maxCount: 3
                writable: false
                saveable: false
                slot: slots.amps
                name: qsTr("BC Line Curr")
            }
        }
        isLiveData: true
    }

    property TableMetaParam aioBcInvAbsCurr: TableMetaParam {
        param: TableParam {
            x: SlotArrayModel {
               slot: slots.phaseName
               count: 3
            }
            value: ArrayParam {
                registry: root
                bigEndian: true
                dataType: Param.F32
                addr: 4 * 0x00013005
                minCount: 3
                maxCount: 3
                writable: false
                saveable: false
                slot: slots.amps
                name: qsTr("BC Inv Abs Curr")
            }
        }
        isLiveData: true
    }

    property TableMetaParam aioBcInvAvgCurr: TableMetaParam {
        param: TableParam {
            x: SlotArrayModel {
               slot: slots.phaseName
               count: 3
            }
            value: ArrayParam {
                registry: root
                bigEndian: true
                dataType: Param.F32
                addr: 4 * 0x00013008
                minCount: 3
                maxCount: 3
                writable: false
                saveable: false
                slot: slots.amps
                name: qsTr("BC Inv Avg Curr")
            }
        }
        isLiveData: true
    }

    property TableMetaParam aioBcTrapAbsCurr: TableMetaParam {
        param: TableParam {
            x: SlotArrayModel {
               slot: slots.phaseName
               count: 3
            }
            value: ArrayParam {
                registry: root
                bigEndian: true
                dataType: Param.F32
                addr: 4 * 0x0001300B
                minCount: 3
                maxCount: 3
                writable: false
                saveable: false
                slot: slots.amps
                name: qsTr("BC Trap Abs Curr")
            }
        }
        isLiveData: true
    }

    property ScalarMetaParam aioBcDcOutCurr: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x0001300E
            writable: false
            saveable: false
            slot: slots.amps
            name: qsTr("BC DC Out Curr")
        }
    }

    property ScalarMetaParam aioBcConnSizeMon: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x0001300F
            writable: false
            saveable: false
            slot: slots.volts
            name: qsTr("BC Conn Size Mon")
        }
    }

    property ScalarMetaParam aioBcRectVoltNeg: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00013010
            writable: false
            saveable: false
            slot: slots.volts
            name: qsTr("BC Rect Volt Neg")
        }
    }

    property ScalarMetaParam aioBcRectVoltPos: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00013011
            writable: false
            saveable: false
            slot: slots.volts
            name: qsTr("BC Rect Volt Pos")
        }
    }

    property ScalarMetaParam aioBcDcOutVolt: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00013012
            writable: false
            saveable: false
            slot: slots.volts
            name: qsTr("BC DC Out Volt")
        }
    }

    property TableMetaParam aioBcAcVoltageMid: TableMetaParam {
        param: TableParam {
            x: SlotArrayModel {
               slot: slots.phaseName
               count: 3
            }
            value: ArrayParam {
                registry: root
                bigEndian: true
                dataType: Param.F32
                addr: 4 * 0x00013013
                minCount: 3
                maxCount: 3
                writable: false
                saveable: false
                slot: slots.amps
                name: qsTr("BC AC Volt Phase-Mid")
            }
        }
        isLiveData: true
    }

    property TableMetaParam aioDcdcRegCurr: TableMetaParam {
        param: TableParam {
            x: SlotArrayModel {
               slot: slots.phaseName
               count: 3
            }
            value: ArrayParam {
                registry: root
                bigEndian: true
                dataType: Param.F32
                addr: 4 * 0x00014000
                minCount: 3
                maxCount: 3
                writable: false
                saveable: false
                slot: slots.amps
                name: qsTr("DC6 Reg Curr")
            }
        }
        isLiveData: true
    }

    property ScalarMetaParam aioDcdcRegInVolt: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00014003
            writable: false
            saveable: false
            slot: slots.volts
            name: qsTr("DC6 Reg In Volt")
        }
    }

    property ScalarMetaParam aioDcdcRegOutVolt: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00014004
            writable: false
            saveable: false
            slot: slots.volts
            name: qsTr("DC6 Reg Out Volt")
        }
    }

    property ScalarMetaParam aioDcdcLvCapCenterVolt: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00014005
            writable: false
            saveable: false
            slot: slots.volts
            name: qsTr("DC6 LV Cap Center Volt")
        }
    }

    property ScalarMetaParam aioDcdcRectOutVolt: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00014006
            writable: false
            saveable: false
            slot: slots.volts
            name: qsTr("DC6 Rect Out Volt")
        }
    }

    property ScalarMetaParam aioDcdcLvCtcOutVolt: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00014007
            writable: false
            saveable: false
            slot: slots.volts
            name: qsTr("DC6 LV Ctc Out Volt")
        }
    }

    property TableMetaParam aioDcdcXfmrAbsCurr: TableMetaParam {
        param: TableParam {
            x: SlotArrayModel {
               slot: slots.phaseName
               count: 3
            }
            value: ArrayParam {
                registry: root
                bigEndian: true
                dataType: Param.F32
                addr: 4 * 0x00014008
                minCount: 3
                maxCount: 3
                writable: false
                saveable: false
                slot: slots.amps
                name: qsTr("DC6 Xfmr Abs Curr")
            }
        }
        isLiveData: true
    }

    property TableMetaParam aioDcdcXfmrAvgCurr: TableMetaParam {
        param: TableParam {
            x: SlotArrayModel {
               slot: slots.phaseName
               count: 3
            }
            value: ArrayParam {
                registry: root
                bigEndian: true
                dataType: Param.F32
                addr: 4 * 0x0001400B
                minCount: 3
                maxCount: 3
                writable: false
                saveable: false
                slot: slots.amps
                name: qsTr("DC6 Xfmr Avg Curr")
            }
        }
        isLiveData: true
    }

    property ScalarMetaParam canDcdcOutVoltCmd: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00021000
            writable: true
            saveable: false
            slot: slots.volts
            name: qsTr("DCDC Out Volt Cmd")
        }
        isLiveData: true
        immediateWrite: true
    }

    property ScalarMetaParam canDcdcEnableCmd: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00021001
            writable: true
            saveable: false
            slot: slots.bool01
            name: qsTr("DCDC Enable Cmd")
        }
        isLiveData: true
        immediateWrite: true
    }

    property ScalarMetaParam canDcdcEnabled: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00021002
            writable: false
            saveable: false
            slot: slots.bool01
            name: qsTr("CAN DCDC Enabled")
        }
    }

    property ScalarMetaParam canDcdcOvertemp: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00021003
            writable: false
            saveable: false
            slot: slots.bool01
            name: qsTr("CAN DCDC Overtemp")
        }
    }

    property ScalarMetaParam canDcdcElecFlt: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00021004
            writable: false
            saveable: false
            slot: slots.bool01
            name: qsTr("CAN DCDC Electronic Fault")
        }
    }

    property ScalarMetaParam canDcdcOutVolt: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00021005
            writable: false
            saveable: false
            slot: slots.volts
            name: qsTr("CAN DCDC Out V")
        }
    }

    property ScalarMetaParam canDcdcOutCurr: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00021006
            writable: false
            saveable: false
            slot: slots.amps
            name: qsTr("CAN DCDC Out I")
        }
    }

    property ScalarMetaParam canDcdcOutPwr: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00021007
            writable: false
            saveable: false
            slot: slots.watts
            name: qsTr("CAN DCDC Out P")
        }
    }

    property ScalarMetaParam canDcdcInCurr: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00021008
            writable: false
            saveable: false
            slot: slots.amps
            name: qsTr("CAN DCDC In I")
        }
    }

    property ScalarMetaParam canDcdcHeatsinkTemp: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00021009
            writable: false
            saveable: false
            slot: slots.degC
            name: qsTr("CAN DCDC Heatsink Temp")
        }
    }

    property TableMetaParam dioBrdg1PhsError: TableMetaParam {
        param: TableParam {
            x: SlotArrayModel {
               slot: slots.phaseName
               count: 3
            }
            value: ArrayParam {
                registry: root
                bigEndian: true
                dataType: Param.F32
                addr: 4 * 0x00031000
                minCount: 3
                maxCount: 3
                writable: false
                saveable: false
                slot: slots.bool01
                name: qsTr("Bridge 1 Phase Error")
            }
        }
        isLiveData: true
    }

    property TableMetaParam dioBrdg2PhsError: TableMetaParam {
        param: TableParam {
            x: SlotArrayModel {
               slot: slots.phaseName
               count: 3
            }
            value: ArrayParam {
                registry: root
                bigEndian: true
                dataType: Param.F32
                addr: 4 * 0x00031003
                minCount: 3
                maxCount: 3
                writable: false
                saveable: false
                slot: slots.bool01
                name: qsTr("Bridge 2 Phase Error")
            }
        }
        isLiveData: true
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
        immediateWrite: true
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
        immediateWrite: true
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
        immediateWrite: true
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
        immediateWrite: true
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
        immediateWrite: true
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
        immediateWrite: true
    }

    property ScalarMetaParam pwmBridge1Deadband: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00040000
            writable: true
            saveable: true
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
        immediateWrite: true
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
        immediateWrite: true
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
        immediateWrite: true
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
        immediateWrite: true
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
        immediateWrite: true
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
        immediateWrite: true
    }
    property TableMetaParam pwmBridge1PhasePeak: TableMetaParam {
        param: TableParam {
            x: SlotArrayModel {
               slot: slots.phaseName
               count: 3
            }
            value: ArrayParam {
                registry: root
                bigEndian: true
                dataType: Param.F32
                addr: 4 * 0x00041006
                minCount: 3
                maxCount: 3
                writable: true
                saveable: false
                slot: slots.pwmPercentage
                name: qsTr("Bridge 1 Phase Peak")
            }
        }
        immediateWrite: true
        isLiveData: true
    }
    property TableMetaParam pwmBridge1PhaseZero: TableMetaParam {
        param: TableParam {
            x: SlotArrayModel {
               slot: slots.phaseName
               count: 3
            }
            value: ArrayParam {
                registry: root
                bigEndian: true
                dataType: Param.F32
                addr: 4 * 0x00041009
                minCount: 3
                maxCount: 3
                writable: true
                saveable: false
                slot: slots.percentage
                name: qsTr("Bridge 1 Phase Zero")
            }
        }
        immediateWrite: true
        isLiveData: true
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
        immediateWrite: true
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
        immediateWrite: true
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
        immediateWrite: true
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
        immediateWrite: true
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
        immediateWrite: true
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
        immediateWrite: true
    }
    property TableMetaParam pwmBridge2PhaseDutyA: TableMetaParam {
        param: TableParam {
            x: SlotArrayModel {
               slot: slots.phaseName
               count: 3
            }
            value: ArrayParam {
                registry: root
                bigEndian: true
                dataType: Param.F32
                addr: 4 * 0x00041012
                minCount: 3
                maxCount: 3
                writable: true
                saveable: false
                slot: slots.pwmPercentage
                name: qsTr("Bridge 2 Phase Duty A")
            }
        }
        immediateWrite: true
        isLiveData: true
    }
    property TableMetaParam pwmBridge2PhaseDutyB: TableMetaParam {
        param: TableParam {
            x: SlotArrayModel {
               slot: slots.phaseName
               count: 3
            }
            value: ArrayParam {
                registry: root
                bigEndian: true
                dataType: Param.F32
                addr: 4 * 0x00041015
                minCount: 3
                maxCount: 3
                writable: true
                saveable: false
                slot: slots.pwmPercentage
                name: qsTr("Bridge 2 Phase Duty B")
            }
        }
        immediateWrite: true
        isLiveData: true
    }
    property ScalarMetaParam pwmBridge1PhaseAngle: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00041018
            writable: false
            saveable: false
            slot: slots.freqHz
            name: qsTr("Bridge 1 Phase Angle")
        }
        isLiveData: true
    }
    property TableMetaParam pwmBridge1Sine: TableMetaParam {
        param: TableParam {
            x: SlotArrayModel {
               slot: slots.phaseName
               count: 3
            }
            value: ArrayParam {
                registry: root
                bigEndian: true
                dataType: Param.F32
                addr: 4 * 0x00041019
                minCount: 3
                maxCount: 3
                writable: false
                saveable: false
                slot: slots.pwmPercentage
                name: qsTr("Bridge 1 Sine")
            }
        }
        isLiveData: true
    }
    property ScalarMetaParam pwmBridge1JumpAngle: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x0004101C
            writable: true
            saveable: false
            slot: slots.radians
            name: qsTr("Bridge 1 Jump Angle")
        }
        immediateWrite: true
    }

    property ScalarMetaParam dcdcReducedCurrOutVolt: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00050000
            writable: true
            saveable: true
            slot: slots.volts
            name: qsTr("Reduced I Out V")
        }
    }

    property ScalarMetaParam dcdcFullCurrOutVolt: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00050001
            writable: true
            saveable: true
            slot: slots.volts
            name: qsTr("Full I Out V")
        }
    }

    property ScalarMetaParam dcdcReducedMaxOutCurr: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00050002
            writable: true
            saveable: true
            slot: slots.amps
            name: qsTr("Reduced Max Out I")
        }
    }

    property ScalarMetaParam dcdcFullMaxOutCurr: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00050003
            writable: true
            saveable: true
            slot: slots.amps
            name: qsTr("Full Max Out I")
        }
    }

    property ScalarMetaParam dcdcCurrLimIntCoeff: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00050004
            writable: true
            saveable: true
            slot: slots.coeffVoltsPerAmp
            name: qsTr("I Lim Int Coeff")
        }
    }

    property ScalarMetaParam dcdcOutVoltRegPropCoeff: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00050005
            writable: true
            saveable: true
            slot: slots.coeffVoltsPerVolt
            name: qsTr("Out V Reg Prop Coeff")
        }
    }

    property ScalarMetaParam dcdcOutVoltRegIntCoeff: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00050006
            writable: true
            saveable: true
            slot: slots.coeffVoltsPerVoltSec
            name: qsTr("Out V Reg Int Coeff")
        }
    }

    property ScalarMetaParam dcdcIgbtDrop: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00050007
            writable: true
            saveable: true
            slot: slots.volts
            name: qsTr("IGBT Drop")
        }
    }

    property ScalarMetaParam dcdcLinkVoltRegIntCoeff: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00050008
            writable: true
            saveable: true
            slot: slots.coeffVoltsPerVoltSec
            name: qsTr("Link V Reg Int Coeff")
        }
    }

    property ScalarMetaParam dcdcStage1CurrBalIntCoeff: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00050009
            writable: true
            saveable: true
            slot: slots.coeffVoltsPerAmpSec
            name: qsTr("Stage 1 Bal Int Coeff")
        }
    }

    property ScalarMetaParam dcdcStage1CurrBalMaxAdj: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x0005000A
            writable: true
            saveable: true
            slot: slots.percentage
            name: qsTr("Stage 1 Bal Max Adj")
        }
    }

    property ScalarMetaParam dcdcOutVoltCmd: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00051000
            writable: true
            saveable: false
            slot: slots.volts
            name: qsTr("Out V Cmd")
        }
        immediateWrite: true
        isLiveData: true
    }

    property ScalarMetaParam dcdcCurrLimIntegrator: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00051001
            writable: false
            saveable: false
            slot: slots.volts
            name: qsTr("I Lim Integrator")
        }
    }

    property ScalarMetaParam dcdcAdjOutVoltCmd: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00051002
            writable: false
            saveable: false
            slot: slots.volts
            name: qsTr("Adj Out V Cmd")
        }
    }

    property ScalarMetaParam dcdcOutVoltRegIntegrator: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00051003
            writable: false
            saveable: false
            slot: slots.volts
            name: qsTr("Out V Reg Integrator")
        }
    }

    property ScalarMetaParam dcdcLinkVoltCmd: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00051004
            writable: true
            saveable: false
            slot: slots.volts
            name: qsTr("Link V Cmd")
        }
        immediateWrite: true
        isLiveData: true
    }

    property ScalarMetaParam dcdcStage1AvgPhaseDuty: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00051005
            writable: true
            saveable: false
            slot: slots.signedPercentage
            name: qsTr("Stage 1 Avg Phase Duty")
        }
        immediateWrite: true
        isLiveData: true
    }

    property ScalarMetaParam dcdcLinkVoltRegIntegrator: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00051006
            writable: false
            saveable: false
            slot: slots.signedPercentage
            name: qsTr("Link V Reg Integrator")
        }
    }

    property ScalarMetaParam dcdcLinkPowerBasedOutputCurrent: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00051007
            writable: false
            saveable: false
            slot: slots.amps
            name: qsTr("Link Power Based Out I")
        }
    }

    property ScalarMetaParam dcdcXfmrPrimaryBasedOutputCurrent: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00051008
            writable: false
            saveable: false
            slot: slots.amps
            name: qsTr("Xfmr Primary Based Out I")
        }
    }

    property ScalarMetaParam dcdcLinkPowerBasedInputCurrent: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00051009
            writable: false
            saveable: false
            slot: slots.amps
            name: qsTr("Link Power Based In I")
        }
    }

    property ScalarMetaParam dcdcState: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x0005100A
            writable: false
            saveable: false
            slot: slots.dcdcState
            name: qsTr("DCDC State")
        }
    }

    property ScalarMetaParam bcMinLineLockFreq: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00060000
            writable: true
            saveable: true
            slot: slots.freqHz
            name: qsTr("BC Min Line Lock Freq")
        }
    }
    property ScalarMetaParam bcMaxLineLockFreq: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00060001
            writable: true
            saveable: true
            slot: slots.freqHz
            name: qsTr("BC Max Line Lock Freq")
        }
    }
    property ScalarMetaParam bcSinePllPropCoeff: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00060002
            writable: true
            saveable: true
            slot: slots.rawf32
            name: qsTr("BC Sine PLL P Coeff")
        }
        immediateWrite: true
    }
    property ScalarMetaParam bcSinePllIntCoeff: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00060003
            writable: true
            saveable: true
            slot: slots.rawf32
            name: qsTr("BC Sine PLL I Coeff")
        }
        immediateWrite: true
    }
    property ScalarMetaParam bcSinePllDerivCoeff: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00060004
            writable: true
            saveable: true
            slot: slots.rawf32
            name: qsTr("BC Sine PLL D Coeff")
        }
        immediateWrite: true
    }
    property ScalarMetaParam bcSinePllStartCmd: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00061000
            writable: true
            saveable: false
            slot: slots.bool01
            name: qsTr("BC Sine PLL Start Cmd")
        }
        immediateWrite: true
    }
    property ScalarMetaParam bcSinePllPhaseAdjCmd: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00061001
            writable: true
            saveable: false
            slot: slots.radians
            name: qsTr("BC Sine PLL Phase Adj")
        }
        immediateWrite: true
    }
    property ScalarMetaParam bcSinePllLocked: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00061002
            writable: false
            saveable: false
            slot: slots.bool01
            name: qsTr("BC Sine PLL Locked")
        }
    }
    property ScalarMetaParam bcSinePllRawPhaseError: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00061003
            writable: false
            saveable: false
            slot: slots.radians
            name: qsTr("BC Sine PLL Raw Phase Error")
        }
    }
    property ScalarMetaParam bcSinePllFiltPhaseError: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00061004
            writable: false
            saveable: false
            slot: slots.radians
            name: qsTr("BC Sine PLL Filt Phase Error")
        }
    }
    property ScalarMetaParam bcSinePllIntegrator: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00061005
            writable: false
            saveable: false
            slot: slots.freqRadSigned
            name: qsTr("BC Sine PLL Integrator")
        }
    }
    property ScalarMetaParam bcSinePllFreq: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00061006
            writable: false
            saveable: false
            slot: slots.freqHzSigned
            name: qsTr("BC Sine PLL Freq")
        }
    }
    property ScalarMetaParam bcLineRealPower: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00061100
            writable: false
            saveable: false
            slot: slots.watts
            name: qsTr("BC Line Real Power")
        }
    }
    property ScalarMetaParam bcLineReactivePower: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00061101
            writable: false
            saveable: false
            slot: slots.voltAmps
            name: qsTr("BC Line Reactive Power")
        }
    }
    property ScalarMetaParam bcLineApparentPower: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00061102
            writable: false
            saveable: false
            slot: slots.voltAmps
            name: qsTr("BC Line Apparent Power")
        }
    }
    property ScalarMetaParam bcLinePowerFactor: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00061103
            writable: false
            saveable: false
            slot: slots.rawf32
            name: qsTr("BC Line Power Factor")
        }
    }
    property ScalarMetaParam bcLineCurrentLag: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00061104
            writable: false
            saveable: false
            slot: slots.radians
            name: qsTr("BC Line Current Lag")
        }
    }
    property ScalarMetaParam bcLineRmsVolts: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00061105
            writable: false
            saveable: false
            slot: slots.volts
            name: qsTr("BC Line RMS Volts")
        }
    }
    property ScalarMetaParam bcLineRmsAmps: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00061106
            writable: false
            saveable: false
            slot: slots.amps
            name: qsTr("BC Line RMS Amps")
        }
    }
    property ScalarMetaParam bcLineRealAmps: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00061107
            writable: false
            saveable: false
            slot: slots.amps
            name: qsTr("BC Line Real Amps")
        }
    }
    property ScalarMetaParam bcLineReactiveAmps: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00061108
            writable: false
            saveable: false
            slot: slots.amps
            name: qsTr("BC Line Reactive Amps")
        }
    }
    property ScalarMetaParam bcFiltLineRealPower: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00061120
            writable: false
            saveable: false
            slot: slots.watts
            name: qsTr("BC Filt Line Real Power")
        }
    }
    property ScalarMetaParam bcFiltLineReactivePower: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00061121
            writable: false
            saveable: false
            slot: slots.voltAmps
            name: qsTr("BC Filt Line Reactive Power")
        }
    }
    property ScalarMetaParam bcFiltLineApparentPower: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00061122
            writable: false
            saveable: false
            slot: slots.voltAmps
            name: qsTr("BC Filt Line Apparent Power")
        }
    }
    property ScalarMetaParam bcFiltLinePowerFactor: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00061123
            writable: false
            saveable: false
            slot: slots.rawf32
            name: qsTr("BC Filt Line Power Factor")
        }
    }
    property ScalarMetaParam bcFiltLineCurrentLag: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00061124
            writable: false
            saveable: false
            slot: slots.radians
            name: qsTr("BC Filt Line Current Lag")
        }
    }
    property ScalarMetaParam bcFiltLineRmsVolts: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00061125
            writable: false
            saveable: false
            slot: slots.volts
            name: qsTr("BC Filt Line RMS Volts")
        }
    }
    property ScalarMetaParam bcFiltLineRmsAmps: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00061126
            writable: false
            saveable: false
            slot: slots.amps
            name: qsTr("BC Filt Line RMS Amps")
        }
    }
    property ScalarMetaParam bcLinkVoltCmd: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00061200
            writable: true
            saveable: false
            slot: slots.volts
            name: qsTr("BC Link Volt Cmd")
        }
        immediateWrite: true
    }
    property ScalarMetaParam bcLineRealPowerCmd: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00061201
            writable: true
            saveable: false
            slot: slots.watts
            name: qsTr("BC Line Real Power Cmd")
        }
        immediateWrite: true
    }
    property ScalarMetaParam bcLineReactivePowerCmd: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00061202
            writable: true
            saveable: false
            slot: slots.watts
            name: qsTr("BC Line Reactive Power Cmd")
        }
        immediateWrite: true
    }
    property ScalarMetaParam bcLineRealCurrentCmd: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00061203
            writable: true
            saveable: false
            slot: slots.amps
            name: qsTr("BC Line Real Curr Cmd")
        }
        immediateWrite: true
    }
    property ScalarMetaParam bcLineReactiveCurrentCmd: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00061204
            writable: true
            saveable: false
            slot: slots.amps
            name: qsTr("BC Line Reactive Curr Cmd")
        }
        immediateWrite: true
    }
    property ScalarMetaParam bcLineRealCurrentOpenLoopCmd: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00061205
            writable: false
            saveable: false
            slot: slots.amps
            name: qsTr("BC Line Real Curr OL Cmd")
        }
    }
    property ScalarMetaParam bcLineReactiveCurrentOpenLoopCmd: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00061206
            writable: false
            saveable: false
            slot: slots.amps
            name: qsTr("BC Line Reactive Curr OL Cmd")
        }
    }
    property ScalarMetaParam bcTestingErrorCode: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00061F00
            writable: false
            saveable: false
            slot: slots.rawf32
            name: qsTr("BC Testing Error Code")
        }
    }
    property ScalarMetaParam bcTestingEngage: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            bigEndian: true
            dataType: Param.F32
            addr: 4 * 0x00061F01
            writable: true
            saveable: false
            slot: slots.bool01
            name: qsTr("BC Testing Engage")
        }
        immediateWrite: true
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
