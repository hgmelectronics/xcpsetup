import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtCharts 2.0
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

Item {
    id: root
    property Parameters registry
    property ParamLayer paramLayer
    anchors.left: parent.left
    anchors.right: parent.right

    TabView {
        id: tabView
        anchors.fill: parent

        Tab {
            title: "AIO/DIO"
            active: true
            AutoRefreshArea {
                base: this
                RowLayout {
                    Layout.alignment: Qt.AlignLeft
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10
                    TableParamEdit {
                        Layout.fillHeight: true
                        xLabel: "AI #"
                        tableParam: registry.aioAiCts
                    }
//                    TableParamEdit {
//                        Layout.fillHeight: true
//                        xLabel: "AO #"
//                        tableParam: registry.aioAoCts
//                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamSpinBox {
                            metaParam: registry.dioBrdg1PhsAError
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.dioBrdg1PhsBError
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.dioBrdg1PhsCError
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.dioBrdg2PhsAError
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.dioBrdg2PhsBError
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.dioBrdg2PhsCError
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamSpinBox {
                            metaParam: registry.dioBrdg1VoltError
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.dioBrdg1TempError
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.dioBrdg2Overtemp
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.dioCtc1Aux
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.dioCtc2Aux
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.dioCtc3Aux
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.dioSpareDi1
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamSpinBox {
                            metaParam: registry.dioCtc1Coil
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.dioCtc2Coil
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.dioCtc3Coil
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.dioBrdg2FetEnable
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.dioSpareDo1
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.dioSoftBaseblock
                        }
                    }
                }
            }
        }

        Tab {
            title: "PWM"
            active: true
            AutoRefreshArea {
                base: this
                RowLayout {
                    Layout.alignment: Qt.AlignLeft
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamSpinBox {
                            metaParam: registry.pwmBridge1Deadband
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamSpinBox {
                            metaParam: registry.pwmBridge1Freq
                        }
                        EncodingParamEdit {
                            metaParam: registry.pwmBridge1RotationCba
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.pwmBridge1Peak
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.pwmBridge1Zero
                        }
                        EncodingParamEdit {
                            metaParam: registry.pwmBridge1TopForce
                        }
                        EncodingParamEdit {
                            metaParam: registry.pwmBridge1BottomForce
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        EncodingParamEdit {
                            metaParam: registry.pwmBridge1PhaseAPeak
                        }
                        EncodingParamEdit {
                            metaParam: registry.pwmBridge1PhaseAZero
                        }
                        EncodingParamEdit {
                            metaParam: registry.pwmBridge1PhaseBPeak
                        }
                        EncodingParamEdit {
                            metaParam: registry.pwmBridge1PhaseBZero
                        }
                        EncodingParamEdit {
                            metaParam: registry.pwmBridge1PhaseCPeak
                        }
                        EncodingParamEdit {
                            metaParam: registry.pwmBridge1PhaseCZero
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamSpinBox {
                            metaParam: registry.pwmBridge2Freq
                        }
                        ScalarParamSpinBox {
                            metaParam: registry.pwmBridge2Duty
                        }
                        EncodingParamEdit {
                            metaParam: registry.pwmBridge2DutyA
                        }
                        EncodingParamEdit {
                            metaParam: registry.pwmBridge2DutyB
                        }
                        EncodingParamEdit {
                            metaParam: registry.pwmBridge2TopForce
                        }
                        EncodingParamEdit {
                            metaParam: registry.pwmBridge2BottomForce
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        EncodingParamEdit {
                            metaParam: registry.pwmBridge2PhaseADutyA
                        }
                        EncodingParamEdit {
                            metaParam: registry.pwmBridge2PhaseADutyB
                        }
                        EncodingParamEdit {
                            metaParam: registry.pwmBridge2PhaseBDutyA
                        }
                        EncodingParamEdit {
                            metaParam: registry.pwmBridge2PhaseBDutyB
                        }
                        EncodingParamEdit {
                            metaParam: registry.pwmBridge2PhaseCDutyA
                        }
                        EncodingParamEdit {
                            metaParam: registry.pwmBridge2PhaseCDutyB
                        }
                    }
                }
            }
        }

//        Tab {
//            title: "CAN"
//            active: true
//            AutoRefreshArea {
//                base: this
//                RowLayout {
//                    Layout.alignment: Qt.AlignLeft
//                    anchors.fill: parent
//                    anchors.margins: 10
//                    spacing: 10
//                    ColumnLayout {
//                        Layout.alignment: Qt.AlignTop
//                        ScalarParamSpinBox {
//                            metaParam: registry.canTracMaxMotoringCurr
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.canTracMaxBrakingCurr
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.canTracCmdSpeed
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.canTracCmdTorque
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.canTracCmdMode
//                        }
//                    }
//                    ColumnLayout {
//                        Layout.alignment: Qt.AlignTop
//                        ScalarParamSpinBox {
//                            metaParam: registry.canTracSpeed
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.canTracTorque
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.canTracDcCurr
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.canTracState
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.canTracFaultCode
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.canTracAlarmCode
//                        }
//                        TableParamEdit {
//                            xLabel: "#"
//                            valueLabel: "degC"
//                            tableParam: registry.canTracMotorTemp
//                        }
//                    }
//                    ColumnLayout {
//                        Layout.alignment: Qt.AlignTop
//                        ScalarParamSpinBox {
//                            name: "XcpProgramRequested"
//                            metaParam: registry.canXcpProgramRequested
//                        }
//                        ScalarParamSpinBox {
//                            name: "Can1RxErrCount"
//                            metaParam: registry.canCan1RxErrCount
//                        }
//                        ScalarParamSpinBox {
//                            name: "Can1TxErrCount"
//                            metaParam: registry.canCan1TxErrCount
//                        }
//                        ScalarParamSpinBox {
//                            name: "Can2RxErrCount"
//                            metaParam: registry.canCan2RxErrCount
//                        }
//                        ScalarParamSpinBox {
//                            name: "Can2TxErrCount"
//                            metaParam: registry.canCan2TxErrCount
//                        }
//                    }
//                }
//            }
//        }

//        Tab {
//            title: "Trac Inverter"
//            active: true
//            AutoRefreshArea {
//                base: this
//                RowLayout {
//                    Layout.alignment: Qt.AlignLeft
//                    anchors.fill: parent
//                    anchors.margins: 10
//                    spacing: 10
//                    ColumnLayout {
//                        Layout.alignment: Qt.AlignTop
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvFwdMotoringTorqueLimit
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvRevMotoringTorqueLimit
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvFwdBrakingTorqueLimit
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvRevBrakingTorqueLimit
//                        }
//                        EncodingParamEdit {
//                            metaParam: registry.tracInvCmdMode
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvReverseDir
//                        }
//                    }
//                    ColumnLayout {
//                        Layout.alignment: Qt.AlignTop
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvFreqRef
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvMotorSpeed
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvDcBusVolt
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvTorqueRef
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvAlarmCode
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvFaultCode
//                        }
//                    }
//                    ColumnLayout {
//                        Layout.alignment: Qt.AlignTop
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvInputS1
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvInputS2
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvInputS3
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvInputS4
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvInputA1
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvInputA2
//                        }
//                    }
//                    ColumnLayout {
//                        Layout.alignment: Qt.AlignTop
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvDuringRun
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvDuringReverse
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvDuringFaultReset
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvDriveReady
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvDuringAlarm
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvDuringFault
//                        }
//                    }
//                    ColumnLayout {
//                        Layout.alignment: Qt.AlignTop
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvStatusUpdateStarted
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvStatusUpdated
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvWriteTorqueLimitsResult
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvWriteAcceptResult
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvReadStatusResult
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvReadFaultResult
//                        }
//                        ScalarParamSpinBox {
//                            metaParam: registry.tracInvTorqueLimitsSet
//                        }
//                    }
//                }
//            }
//        }

        Tab {
            title: "System"
            active: true
            AutoRefreshArea {
                base: this
                RowLayout {
                    Layout.alignment: Qt.AlignLeft
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamSpinBox {
                            metaParam: registry.sysCycleIdle
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamIndicator {
                            name: "Watchdog Reset"
                            metaParam: registry.sysFlags
                            bitMask: 0x00000001
                        }
                        ScalarParamIndicator {
                            name: "Stack Overflow"
                            metaParam: registry.sysFlags
                            bitMask: 0x00000004
                        }
                        ScalarParamIndicator {
                            name: "Cycle Time Violation"
                            metaParam: registry.sysFlags
                            bitMask: 0x00000002
                        }
                        ScalarParamSpinBox {
                            name: "Heap Alloc Bytes"
                            metaParam: registry.sysHeapAllocBytes
                        }
                        ScalarParamSpinBox {
                            name: "Heap Avail Bytes"
                            metaParam: registry.sysHeapFreeBytes
                        }
                        ScalarParamSpinBox {
                            name: "Heap Free Count"
                            metaParam: registry.sysHeapNFrees
                        }
                        ScalarParamSpinBox {
                            name: "RTDB rows"
                            metaParam: registry.sysRtDbRows
                        }
                    }
                }
            }
        }

//        Tab {
//            title: "Event Log"
//            active: true

//            EventLogTab {
//                paramLayer: root.paramLayer
//                parameters: root.registry
//            }
//        }
    }
}
