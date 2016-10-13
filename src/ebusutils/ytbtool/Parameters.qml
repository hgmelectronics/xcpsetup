import QtQuick 2.5
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

ParamRegistry {
    id: root

    property bool isDriverOnly: true

    property Slots slots: Slots {}
    property SlotArrayModel auxInvAxisModel: SlotArrayModel {
        slot: slots.raw32
        min: 1
        count: 31
    }

    property ScalarMetaParam aioTracMotorMaxRpm: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00010000
            writable: true
            saveable: true
            slot: slots.rpm1
            name: qsTr("Trac Inverter Max Freq")
        }
    }
    property ScalarMetaParam aioHallSensorCurrPerVolt: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00010001
            writable: true
            saveable: true
            slot: slots.hallScale
            name: qsTr("Hall Sensor Scale")
        }
    }
    property ScalarMetaParam aioTracMotorTherm1Curve: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00010002
            writable: true
            saveable: true
            slot: slots.thermistorCurve
            name: qsTr("Trac Motor Thermistor 1 Curve")
        }
    }
    property ScalarMetaParam aioTracMotorTherm2Curve: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00010003
            writable: true
            saveable: true
            slot: slots.thermistorCurve
            name: qsTr("Trac Motor Thermistor 2 Curve")
        }
    }

    property TableParam aioAiCts: TableParam {
        x: SlotArrayModel {
            slot: slots.raw32
            count: 16
        }
        value: ArrayParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00011000
            minCount: 16
            writable: false
            saveable: false
            slot: slots.ytbAiVolts
            name: qsTr("AI Voltage")
        }
    }
    property TableParam aioAoCts: TableParam {
        x: SlotArrayModel {
           slot: slots.raw32
           count: 2
       }
        value: ArrayParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00011010
            minCount: 2
            writable: false
            saveable: false
            slot: slots.ytbAoVolts
            name: qsTr("AO Voltage")
        }
    }
    property ScalarMetaParam aioTracMotorSpeed: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00011020
            writable: false
            saveable: false
            slot: slots.rpm1Signed
            name: qsTr("AI Trac Motor Speed")
        }
    }
    property ScalarMetaParam aioTracMotorTorque: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00011021
            writable: false
            saveable: false
            slot: slots.signedDeciPercent
            name: qsTr("AI Trac Motor Torque")
        }
    }
    property ScalarMetaParam aioTracMotorDcCurr: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00011022
            writable: false
            saveable: false
            slot: slots.saeEc05Signed
            name: qsTr("AI Trac DC Current")
        }
    }
    property ScalarMetaParam aioTracMotorTherm1Temp: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00011023
            writable: false
            saveable: false
            slot: slots.saeTp02
            name: qsTr("AI Trac Motor Therm 1")
        }
    }
    property ScalarMetaParam aioTracMotorTherm2Temp: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00011024
            writable: false
            saveable: false
            slot: slots.saeTp02
            name: qsTr("AI Trac Motor Therm 2")
        }
    }
    property ScalarMetaParam aioBus5VMillivolts: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00011025
            writable: false
            saveable: false
            slot: slots.millivolts
            name: qsTr("5V Bus")
        }
    }
    property ScalarMetaParam aioBus3V3Millivolts: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00011026
            writable: false
            saveable: false
            slot: slots.millivolts
            name: qsTr("3.3V Bus")
        }
    }
    property ScalarMetaParam aioBusPos15VMillivolts: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00011027
            writable: false
            saveable: false
            slot: slots.millivolts
            name: qsTr("15V Bus")
        }
    }
    property ScalarMetaParam aioBusNeg15VMillivolts: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00011028
            writable: false
            saveable: false
            slot: slots.millivolts
            name: qsTr("-15V Bus")
        }
    }
    property ScalarMetaParam aioTracMotorSpeedCmd: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00011029
            writable: isDriverOnly
            saveable: false
            slot: slots.rpm1Signed
            name: qsTr("AO Trac Motor Speed Cmd")
        }
        immediateWrite: param.writable
    }
    property ScalarMetaParam aioTracMotorTorqueCmd: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x0001102A
            writable: isDriverOnly
            saveable: false
            slot: slots.signedDeciPercent
            name: qsTr("AO Trac Motor Torque Cmd")
        }
        immediateWrite: param.writable
    }



    property TableParam auxInvCmdMode: TableParam {
        x: auxInvAxisModel
        value: ArrayParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00021000
            maxCount: auxInvAxisModel.count
            writable: isDriverOnly
            saveable: false
            slot: slots.invMode
            name: qsTr("Aux Inv Cmd Mode")
        }
    }
    property TableParam auxInvCmdSpeed: TableParam {
        x: auxInvAxisModel
        value: ArrayParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00021100
            maxCount: auxInvAxisModel.count
            writable: isDriverOnly
            saveable: false
            slot: slots.rpm1
            name: qsTr("Aux Inv Cmd Speed")
        }
    }
    property TableParam auxInvCmdUpdated: TableParam {
        x: auxInvAxisModel
        value: ArrayParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00021200
            maxCount: auxInvAxisModel.count
            writable: isDriverOnly
            saveable: false
            slot: slots.bool01
            name: qsTr("Aux Inv Cmd Update Flag")
        }
    }
    property TableParam auxInvState: TableParam {
        x: auxInvAxisModel
        value: ArrayParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00021300
            maxCount: auxInvAxisModel.count
            writable: false
            saveable: false
            slot: slots.invState
            name: qsTr("Aux Inv State")
        }
    }
    property TableParam auxInvSpeed: TableParam {
        x: auxInvAxisModel
        value: ArrayParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00021400
            maxCount: auxInvAxisModel.count
            writable: false
            saveable: false
            slot: slots.rpm1
            name: qsTr("Aux Inv Speed")
        }
    }
    property TableParam auxInvFaultCode: TableParam {
        x: auxInvAxisModel
        value: ArrayParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00021500
            maxCount: auxInvAxisModel.count
            writable: false
            saveable: false
            slot: slots.raw32hex
            name: qsTr("Aux Inv Fault Code")
        }
    }
    property TableParam auxInvAlarmCode: TableParam {
        x: auxInvAxisModel
        value: ArrayParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00021600
            maxCount: auxInvAxisModel.count
            writable: false
            saveable: false
            slot: slots.raw32hex
            name: qsTr("Aux Inv Alarm Code")
        }
    }
    property TableParam auxInvStatusUpdated: TableParam {
        x: auxInvAxisModel
        value: ArrayParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00021700
            maxCount: auxInvAxisModel.count
            writable: isDriverOnly
            saveable: false
            slot: slots.bool01
            name: qsTr("Aux Inv Status Update Flag")
        }
    }
    property TableParam auxInvWriteCmdResult: TableParam {
        x: auxInvAxisModel
        value: ArrayParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00021800
            maxCount: auxInvAxisModel.count
            writable: false
            saveable: false
            slot: slots.modbusPduResult
            name: qsTr("Aux Inv Write Cmd Result")
        }
    }
    property TableParam auxInvReadStatusResult: TableParam {
        x: auxInvAxisModel
        value: ArrayParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00021900
            maxCount: auxInvAxisModel.count
            writable: false
            saveable: false
            slot: slots.modbusPduResult
            name: qsTr("Aux Inv Read Status Result")
        }
    }
    property TableParam auxInvReadFaultResult: TableParam {
        x: auxInvAxisModel
        value: ArrayParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00021A00
            maxCount: auxInvAxisModel.count
            writable: false
            saveable: false
            slot: slots.modbusPduResult
            name: qsTr("Aux Inv Read Fault Result")
        }
    }
    property MultiroleTableMetaParam auxInvCmd: MultiroleTableMetaParam {
        param: MultiroleTableParam {
            roleMapping: {
                "x": auxInvAxisModel,
                "mode": auxInvCmdMode.value,
                "speed": auxInvCmdSpeed.value,
                "updated": auxInvCmdUpdated.value
            }
        }
        isLiveData: true
    }
    property MultiroleTableMetaParam auxInvStatus: MultiroleTableMetaParam {
        param: MultiroleTableParam {
            roleMapping: {
                "x": auxInvAxisModel,
                "state": auxInvState.value,
                "speed": auxInvSpeed.value,
                "faultCode": auxInvFaultCode.value,
                "alarmCode": auxInvAlarmCode.value,
                "statusUpdated": auxInvStatusUpdated.value
            }
        }
        isLiveData: true
    }
    property MultiroleTableMetaParam auxInvModbusStatus: MultiroleTableMetaParam {
        param: MultiroleTableParam {
            roleMapping: {
                "x": auxInvAxisModel,
                "writeCmd": auxInvWriteCmdResult.value,
                "readStatus": auxInvReadStatusResult.value,
                "readFault": auxInvReadFaultResult.value
            }
        }
        isLiveData: true
    }
    property MultiroleTableMetaParam auxInv: MultiroleTableMetaParam {
        param: MultiroleTableParam {
            roleMapping: {
                "x": auxInvAxisModel,
                "cmdMode": auxInvCmdMode.value,
                "cmdSpeed": auxInvCmdSpeed.value,
                "cmdUpdated": auxInvCmdUpdated.value,
                "state": auxInvState.value,
                "speed": auxInvSpeed.value,
                "faultCode": auxInvFaultCode.value,
                "alarmCode": auxInvAlarmCode.value,
                "statusUpdated": auxInvStatusUpdated.value,
                "writeCmd": auxInvWriteCmdResult.value,
                "readStatus": auxInvReadStatusResult.value,
                "readFault": auxInvReadFaultResult.value
            }
        }
        isLiveData: true
    }



    property ScalarMetaParam canTracMaxMotoringCurr: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00031000
            writable: false
            saveable: false
            slot: slots.saeEc05
            name: qsTr("CAN Max Motoring Current")
        }
    }
    property ScalarMetaParam canTracMaxBrakingCurr: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00031001
            writable: false
            saveable: false
            slot: slots.saeEc05
            name: qsTr("CAN Max Braking Current")
        }
    }
    property ScalarMetaParam canTracCmdSpeed: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00031002
            writable: false
            saveable: false
            slot: slots.rpm1Signed
            name: qsTr("CAN Trac Cmd Speed")
        }
    }
    property ScalarMetaParam canTracCmdTorque: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00031003
            writable: false
            saveable: false
            slot: slots.signedDeciPercent
            name: qsTr("CAN Trac Cmd Torque")
        }
    }
    property ScalarMetaParam canTracCmdMode: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00031004
            writable: false
            saveable: false
            slot: slots.invMode
            name: qsTr("CAN Trac Cmd Mode")
        }
    }
    property ScalarMetaParam canTracSpeed: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00031005
            writable: isDriverOnly
            saveable: false
            slot: slots.rpm1Signed
            name: qsTr("CAN Trac Speed")
        }
    }
    property ScalarMetaParam canTracTorque: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00031006
            writable: isDriverOnly
            saveable: false
            slot: slots.signedDeciPercent
            name: qsTr("CAN Trac Torque")
        }
    }
    property ScalarMetaParam canTracDcCurr: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00031007
            writable: isDriverOnly
            saveable: false
            slot: slots.saeEc05Signed
            name: qsTr("CAN Trac DC Curr")
        }
    }
    property ScalarMetaParam canTracState: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00031008
            writable: isDriverOnly
            saveable: false
            slot: slots.invState
            name: qsTr("CAN Trac State")
        }
    }
    property ScalarMetaParam canTracFaultCode: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00031009
            writable: isDriverOnly
            saveable: false
            slot: slots.raw32hex
            name: qsTr("CAN Trac Fault Code")
        }
    }
    property ScalarMetaParam canTracAlarmCode: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x0003100A
            writable: isDriverOnly
            saveable: false
            slot: slots.raw32hex
            name: qsTr("CAN Trac Alarm Code")
        }
    }
    property TableParam canTracMotorTemp: TableParam {
        x: SlotArrayModel {
            slot: slots.raw32
            count: 3
        }
        value: ArrayParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x0003100B
            minCount: 3
            writable: isDriverOnly
            saveable: false
            slot: slots.saeTp02
            name: qsTr("CAN Trac Motor Temp")
        }
    }

    property ScalarMetaParam canXcpProgramRequested: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x0003F000
            writable: false
            saveable: false
            slot: slots.bool01
            name: qsTr("XCP Program Requested")
        }
    }
    property ScalarMetaParam canCan1RxErrCount: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x0003F001
            writable: false
            saveable: false
            slot: slots.raw32
            name: qsTr("CAN1 RX Err Count")
        }
    }
    property ScalarMetaParam canCan1TxErrCount: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x0003F002
            writable: false
            saveable: false
            slot: slots.raw32
            name: qsTr("CAN1 TX Err Count")
        }
    }
    property ScalarMetaParam canCan2RxErrCount: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x0003F003
            writable: false
            saveable: false
            slot: slots.raw32
            name: qsTr("CAN2 RX Err Count")
        }
    }
    property ScalarMetaParam canCan2TxErrCount: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x0003F004
            writable: false
            saveable: false
            slot: slots.raw32
            name: qsTr("CAN2 TX Err Count")
        }
    }



    property ScalarMetaParam dioForwardRun: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00041100
            writable: isDriverOnly
            saveable: false
            slot: slots.raw32
            name: qsTr("DO Forward Run")
        }
        immediateWrite: param.writable
    }
    property ScalarMetaParam dioReverseRun: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00041101
            writable: isDriverOnly
            saveable: false
            slot: slots.raw32
            name: qsTr("DO Reverse Run")
        }
        immediateWrite: param.writable
    }
    property ScalarMetaParam dioTorqueMode: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00041102
            writable: isDriverOnly
            saveable: false
            slot: slots.raw32
            name: qsTr("DO Torque Mode")
        }
        immediateWrite: param.writable
    }
    property ScalarMetaParam dioFaultReset: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00041103
            writable: isDriverOnly
            saveable: false
            slot: slots.raw32
            name: qsTr("DO Fault Reset")
        }
        immediateWrite: param.writable
    }


    property ScalarMetaParam rtdTemp0: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00051000
            writable: false
            saveable: false
            slot: slots.saeTp02
            name: qsTr("RTD Temp 0")
        }
    }
    property ScalarMetaParam rtdTemp1: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00051001
            writable: false
            saveable: false
            slot: slots.saeTp02
            name: qsTr("RTD Temp 1")
        }
    }
    property ScalarMetaParam rtdTemp2: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00051002
            writable: false
            saveable: false
            slot: slots.saeTp02
            name: qsTr("RTD Temp 2")
        }
    }



    property ScalarMetaParam tracInvFwdMotoringTorqueLimit: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00061000
            writable: isDriverOnly
            saveable: false
            slot: slots.signedDeciPercent
            name: qsTr("MODBUS Fwd Motoring Torque Limit")
        }
    }
    property ScalarMetaParam tracInvRevMotoringTorqueLimit: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00061001
            writable: isDriverOnly
            saveable: false
            slot: slots.signedDeciPercent
            name: qsTr("MODBUS Rev Motoring Torque Limit")
        }
    }
    property ScalarMetaParam tracInvFwdBrakingTorqueLimit: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00061002
            writable: isDriverOnly
            saveable: false
            slot: slots.signedDeciPercent
            name: qsTr("MODBUS Fwd Braking Torque Limit")
        }
    }
    property ScalarMetaParam tracInvRevBrakingTorqueLimit: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00061003
            writable: isDriverOnly
            saveable: false
            slot: slots.signedDeciPercent
            name: qsTr("MODBUS Rev Braking Torque Limit")
        }
    }
    property ScalarMetaParam tracInvCmdMode: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00061004
            writable: isDriverOnly
            saveable: false
            slot: slots.invMode
            name: qsTr("MODBUS Trac Cmd Mode")
        }
    }
    property ScalarMetaParam tracInvReverseDir: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00061005
            writable: isDriverOnly
            saveable: false
            slot: slots.bool01
            name: qsTr("MODBUS Trac Reverse")
        }
    }
    property ScalarMetaParam tracInvFreqRef: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00061100
            writable: false
            saveable: false
            slot: slots.rpm1
            name: qsTr("MODBUS Trac Freq Ref")
        }
    }
    property ScalarMetaParam tracInvMotorSpeed: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00061101
            writable: false
            saveable: false
            slot: slots.rpm1
            name: qsTr("MODBUS Trac Motor Speed")
        }
    }
    property ScalarMetaParam tracInvDcBusVolt: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00061102
            writable: false
            saveable: false
            slot: slots.saeEv01
            name: qsTr("MODBUS Trac DC V")
        }
    }
    property ScalarMetaParam tracInvTorqueRef: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00061103
            writable: false
            saveable: false
            slot: slots.signedDeciPercent
            name: qsTr("MODBUS Trac Torque Ref")
        }
    }
    property ScalarMetaParam tracInvInputS1: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00061104
            writable: false
            saveable: false
            slot: slots.bool01
            name: qsTr("MODBUS Trac Input S1")
        }
    }
    property ScalarMetaParam tracInvInputS2: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00061105
            writable: false
            saveable: false
            slot: slots.bool01
            name: qsTr("MODBUS Trac Input S2")
        }
    }
    property ScalarMetaParam tracInvInputS3: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00061106
            writable: false
            saveable: false
            slot: slots.bool01
            name: qsTr("MODBUS Trac Input S3")
        }
    }
    property ScalarMetaParam tracInvInputS4: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00061107
            writable: false
            saveable: false
            slot: slots.bool01
            name: qsTr("MODBUS Trac Input S4")
        }
    }
    property ScalarMetaParam tracInvDuringRun: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00061108
            writable: false
            saveable: false
            slot: slots.bool01
            name: qsTr("MODBUS Trac During Run")
        }
    }
    property ScalarMetaParam tracInvDuringReverse: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00061109
            writable: false
            saveable: false
            slot: slots.bool01
            name: qsTr("MODBUS Trac During Reverse")
        }
    }
    property ScalarMetaParam tracInvDuringFaultReset: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x0006110A
            writable: false
            saveable: false
            slot: slots.bool01
            name: qsTr("MODBUS Trac During Fault Reset")
        }
    }
    property ScalarMetaParam tracInvDriveReady: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x0006110B
            writable: false
            saveable: false
            slot: slots.bool01
            name: qsTr("MODBUS Trac Drive Ready")
        }
    }
    property ScalarMetaParam tracInvDuringAlarm: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x0006110C
            writable: false
            saveable: false
            slot: slots.bool01
            name: qsTr("MODBUS Trac During Alarm")
        }
    }
    property ScalarMetaParam tracInvDuringFault: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x0006110D
            writable: false
            saveable: false
            slot: slots.bool01
            name: qsTr("MODBUS Trac During Fault")
        }
    }
    property ScalarMetaParam tracInvInputA1: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x0006110E
            writable: false
            saveable: false
            slot: slots.yaskawaAnalogVolts
            name: qsTr("MODBUS Trac Input A1")
        }
    }
    property ScalarMetaParam tracInvInputA2: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x0006110F
            writable: false
            saveable: false
            slot: slots.yaskawaAnalogVolts
            name: qsTr("MODBUS Trac Input A2")
        }
    }
    property ScalarMetaParam tracInvAlarmCode: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00061110
            writable: false
            saveable: false
            slot: slots.raw32hex
            name: qsTr("MODBUS Trac Alarm Code")
        }
    }
    property ScalarMetaParam tracInvFaultCode: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00061111
            writable: false
            saveable: false
            slot: slots.raw32hex
            name: qsTr("MODBUS Trac Fault Code")
        }
    }
    property ScalarMetaParam tracInvStatusUpdateStarted: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00061200
            writable: isDriverOnly
            saveable: false
            slot: slots.bool01
            name: qsTr("Trac Status Update Started")
        }
    }
    property ScalarMetaParam tracInvStatusUpdated: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00061201
            writable: isDriverOnly
            saveable: false
            slot: slots.bool01
            name: qsTr("Trac Status Updated")
        }
    }
    property ScalarMetaParam tracInvWriteCmdResult: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00061202
            writable: false
            saveable: false
            slot: slots.modbusPduResult
            name: qsTr("Trac Write Cmd Result")
        }
    }
    property ScalarMetaParam tracInvWriteTorqueLimitsResult: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00061203
            writable: false
            saveable: false
            slot: slots.modbusPduResult
            name: qsTr("Trac Write Torque Limits Result")
        }
    }
    property ScalarMetaParam tracInvWriteAcceptResult: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00061204
            writable: false
            saveable: false
            slot: slots.modbusPduResult
            name: qsTr("Trac Write ACCEPT Result")
        }
    }
    property ScalarMetaParam tracInvReadStatusResult: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00061205
            writable: false
            saveable: false
            slot: slots.modbusPduResult
            name: qsTr("Trac Read Status Result")
        }
    }
    property ScalarMetaParam tracInvReadFaultResult: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00061206
            writable: false
            saveable: false
            slot: slots.modbusPduResult
            name: qsTr("Trac Read Fault Result")
        }
    }
    property ScalarMetaParam tracInvTorqueLimitsSet: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00061207
            writable: false
            saveable: false
            slot: slots.bool01
            name: qsTr("Trac Torque Limits Set")
        }
    }


    property ScalarMetaParam sysCycleIdle: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
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
            dataType: Param.S32
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
            dataType: Param.S32
            addr: 4 * 0x00071002
            writable: false
            saveable: false
            slot: slots.timeUsec
            name: qsTr("Sys Cycle AIO Output")
        }
    }
    property ScalarMetaParam sysCycleDrvAuxInvIn: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00071003
            writable: false
            saveable: false
            slot: slots.timeUsec
            name: qsTr("Sys Cycle Aux Inv Input")
        }
    }
    property ScalarMetaParam sysCycleDrvAuxInvOut: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00071004
            writable: false
            saveable: false
            slot: slots.timeUsec
            name: qsTr("Sys Cycle Aux Inv Output")
        }
    }
    property ScalarMetaParam sysCycleDrvCanIn: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00071005
            writable: false
            saveable: false
            slot: slots.timeUsec
            name: qsTr("Sys Cycle CAN Input")
        }
    }
    property ScalarMetaParam sysCycleDrvCanOut: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00071006
            writable: false
            saveable: false
            slot: slots.timeUsec
            name: qsTr("Sys Cycle CAN Output")
        }
    }
    property ScalarMetaParam sysCycleDrvDioIn: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00071007
            writable: false
            saveable: false
            slot: slots.timeUsec
            name: qsTr("Sys Cycle DIO Input")
        }
    }
    property ScalarMetaParam sysCycleDrvDioOut: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00071008
            writable: false
            saveable: false
            slot: slots.timeUsec
            name: qsTr("Sys Cycle DIO Output")
        }
    }
    property ScalarMetaParam sysCycleDrvRtdIn: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00071009
            writable: false
            saveable: false
            slot: slots.timeUsec
            name: qsTr("Sys Cycle RTD Input")
        }
    }
    property ScalarMetaParam sysCycleDrvRtdOut: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x0007100A
            writable: false
            saveable: false
            slot: slots.timeUsec
            name: qsTr("Sys Cycle RTD Output")
        }
    }
    property ScalarMetaParam sysCycleDrvTracInvIn: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x0007100B
            writable: false
            saveable: false
            slot: slots.timeUsec
            name: qsTr("Sys Cycle Trac Inv Input")
        }
    }
    property ScalarMetaParam sysCycleDrvTracInvOut: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x0007100C
            writable: false
            saveable: false
            slot: slots.timeUsec
            name: qsTr("Sys Cycle Trac Inv Output")
        }
    }
    property ScalarMetaParam sysCycleCtlTrac: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x0007100D
            writable: false
            saveable: false
            slot: slots.timeUsec
            name: qsTr("Sys Cycle Trac Ctl")
        }
    }

    property ScalarMetaParam sysFlags: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00072000
            writable: false
            saveable: false
            slot: slots.raw32
            name: qsTr("Sys Flags")
        }
    }
    property ScalarMetaParam sysHeapAllocBytes: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00072001
            writable: false
            saveable: false
            slot: slots.raw32
            name: qsTr("Heap Alloc Bytes")
        }
    }
    property ScalarMetaParam sysHeapFreeBytes: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00072002
            writable: false
            saveable: false
            slot: slots.raw32
            name: qsTr("Heap Free Bytes")
        }
    }
    property ScalarMetaParam sysHeapNFrees: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00072003
            writable: false
            saveable: false
            slot: slots.raw32
            name: qsTr("Heap Free Count")
        }
    }
    property ScalarMetaParam sysRtDbRows: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00072004
            writable: false
            saveable: false
            slot: slots.raw32
            name: qsTr("RTDB Rows")
        }
    }

    property ScalarMetaParam tracTempSensorType: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00080000
            writable: true
            saveable: true
            slot: slots.tempSensorType
            name: qsTr("Trac Motor Temp Sensor Type")
        }
    }

    property ScalarMetaParam tracCurrentRegUpRelax: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00080001
            writable: true
            saveable: true
            slot: slots.percent
            name: qsTr("Trac Curr Up Relax")
        }
    }

    property ScalarMetaParam tracCurrentRegDownRelax: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00080002
            writable: true
            saveable: true
            slot: slots.percent
            name: qsTr("Trac Curr Down Relax")
        }
    }

    property ScalarMetaParam tracCurrentRegRatedTorque: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00080003
            writable: true
            saveable: true
            slot: slots.torquePositive
            name: qsTr("Trac Rated Torque")
        }
    }

    property ScalarMetaParam tracAnalogSpeedOffset: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00081000
            writable: false
            saveable: false
            slot: slots.rpm1Signed
            name: qsTr("Analog Speed Offset")
        }
    }

    property ScalarMetaParam tracAnalogTorqueOffset: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00081001
            writable: false
            saveable: false
            slot: slots.signedDeciPercent
            name: qsTr("Analog Torque Offset")
        }
    }

    property ScalarMetaParam tracAnalogSpeedCmdOffset: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00081002
            writable: false
            saveable: false
            slot: slots.rpm1Signed
            name: qsTr("Analog Speed Cmd Offset")
        }
    }

    property ScalarMetaParam tracAnalogTorqueCmdOffset: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00081003
            writable: false
            saveable: false
            slot: slots.signedDeciPercent
            name: qsTr("Analog Torque Cmd Offset")
        }
    }

    property ScalarMetaParam tracMotoringCurrentIntegrator: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00081004
            writable: false
            saveable: false
            slot: slots.saeEc05Signed
            name: qsTr("Motoring Current Integrator")
        }
    }

    property ScalarMetaParam tracBrakingCurrentIntegrator: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00081005
            writable: false
            saveable: false
            slot: slots.saeEc05Signed
            name: qsTr("Braking Current Integrator")
        }
    }

    property ScalarMetaParam tracPositiveTorqueLimit: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00081006
            writable: false
            saveable: false
            slot: slots.signedDeciPercent
            name: qsTr("Positive Torque Limit")
        }
    }

    property ScalarMetaParam tracNegativeTorqueLimit: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00081007
            writable: false
            saveable: false
            slot: slots.signedDeciPercent
            name: qsTr("Negative Torque Limit")
        }
    }

    property ScalarMetaParam tracMotorSpeed: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00081008
            writable: false
            saveable: false
            slot: slots.rpm1Signed
            name: qsTr("Trac Motor Speed")
        }
    }

    property ScalarMetaParam tracMotorTorque: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x00081009
            writable: false
            saveable: false
            slot: slots.signedDeciPercent
            name: qsTr("Trac Motor Torque")
        }
    }

    property ScalarMetaParam tracMotorDcCurr: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x0008100A
            writable: false
            saveable: false
            slot: slots.saeEc05Signed
            name: qsTr("Trac Motor DC Curr")
        }
    }

    property ScalarMetaParam tracState: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 4 * 0x0008100B
            writable: false
            saveable: false
            slot: slots.tracState
            name: qsTr("Trac State")
        }
    }

    property ScalarMetaParam eventBeginSerial: ScalarMetaParam {
        param: ScalarParam {
            registry: root
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
            dataType: Param.S32
            addr: 0x10000010
            writable: true
            saveable: false
            slot: slots.raw32
            name: qsTr("Event Log Clear-To Serial")
        }
        immediateWrite: true
    }
    property ScalarMetaParam eventViewSerial: ScalarMetaParam {
        param: ScalarParam {
            registry: root
            dataType: Param.S32
            addr: 0x10000018
            writable: true
            saveable: false
            slot: slots.raw32
            name: qsTr("Event Log View Serial")
        }
        immediateWrite: true
    }
    property ScalarMetaParam eventViewKey: ScalarMetaParam {
        param: ScalarParam {
            registry: root
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
