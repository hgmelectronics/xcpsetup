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
                        ScalarParamEdit {
                            metaParam: registry.dioBrdg1PhsAError
                        }
                        ScalarParamEdit {
                            metaParam: registry.dioBrdg1PhsBError
                        }
                        ScalarParamEdit {
                            metaParam: registry.dioBrdg1PhsCError
                        }
                        ScalarParamEdit {
                            metaParam: registry.dioBrdg2PhsAError
                        }
                        ScalarParamEdit {
                            metaParam: registry.dioBrdg2PhsBError
                        }
                        ScalarParamEdit {
                            metaParam: registry.dioBrdg2PhsCError
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamEdit {
                            metaParam: registry.dioBrdg1VoltError
                        }
                        ScalarParamEdit {
                            metaParam: registry.dioBrdg1TempError
                        }
                        ScalarParamEdit {
                            metaParam: registry.dioBrdg2Overtemp
                        }
                        ScalarParamEdit {
                            metaParam: registry.dioCtc1Aux
                        }
                        ScalarParamEdit {
                            metaParam: registry.dioCtc2Aux
                        }
                        ScalarParamEdit {
                            metaParam: registry.dioCtc3Aux
                        }
                        ScalarParamEdit {
                            metaParam: registry.dioSpareDi1
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamEdit {
                            metaParam: registry.dioCtc1Coil
                        }
                        ScalarParamEdit {
                            metaParam: registry.dioCtc2Coil
                        }
                        ScalarParamEdit {
                            metaParam: registry.dioCtc3Coil
                        }
                        ScalarParamEdit {
                            metaParam: registry.dioBrdg2FetEnable
                        }
                        ScalarParamEdit {
                            metaParam: registry.dioSpareDo1
                        }
                    }
                }
            }
        }

//        Tab {
//            title: "PWM"
//            active: true
//            AutoRefreshArea {
//                base: this
//                RowLayout {
//                    Layout.alignment: Qt.AlignLeft
//                    anchors.fill: parent
//                    anchors.margins: 10
//                    spacing: 10
//                    MultiroleTableParamEdit {
//                        Layout.margins: 10
//                        Layout.fillHeight: true
//                        Layout.fillWidth: true

//                        tableMetaParam: registry.auxInv
//                        roleNames: ["x", "cmdMode", "cmdSpeed", "cmdUpdated", "state", "speed", "faultCode", "alarmCode", "statusUpdated", "writeCmd", "readStatus", "readFault"]
//                    }
//                }
//            }
//        }

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
//                        ScalarParamEdit {
//                            metaParam: registry.canTracMaxMotoringCurr
//                        }
//                        ScalarParamEdit {
//                            metaParam: registry.canTracMaxBrakingCurr
//                        }
//                        ScalarParamEdit {
//                            metaParam: registry.canTracCmdSpeed
//                        }
//                        ScalarParamEdit {
//                            metaParam: registry.canTracCmdTorque
//                        }
//                        ScalarParamEdit {
//                            metaParam: registry.canTracCmdMode
//                        }
//                    }
//                    ColumnLayout {
//                        Layout.alignment: Qt.AlignTop
//                        ScalarParamEdit {
//                            metaParam: registry.canTracSpeed
//                        }
//                        ScalarParamEdit {
//                            metaParam: registry.canTracTorque
//                        }
//                        ScalarParamEdit {
//                            metaParam: registry.canTracDcCurr
//                        }
//                        ScalarParamEdit {
//                            metaParam: registry.canTracState
//                        }
//                        ScalarParamEdit {
//                            metaParam: registry.canTracFaultCode
//                        }
//                        ScalarParamEdit {
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
//                        ScalarParamEdit {
//                            name: "XcpProgramRequested"
//                            metaParam: registry.canXcpProgramRequested
//                        }
//                        ScalarParamEdit {
//                            name: "Can1RxErrCount"
//                            metaParam: registry.canCan1RxErrCount
//                        }
//                        ScalarParamEdit {
//                            name: "Can1TxErrCount"
//                            metaParam: registry.canCan1TxErrCount
//                        }
//                        ScalarParamEdit {
//                            name: "Can2RxErrCount"
//                            metaParam: registry.canCan2RxErrCount
//                        }
//                        ScalarParamEdit {
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
//                        ScalarParamEdit {
//                            metaParam: registry.tracInvFwdMotoringTorqueLimit
//                        }
//                        ScalarParamEdit {
//                            metaParam: registry.tracInvRevMotoringTorqueLimit
//                        }
//                        ScalarParamEdit {
//                            metaParam: registry.tracInvFwdBrakingTorqueLimit
//                        }
//                        ScalarParamEdit {
//                            metaParam: registry.tracInvRevBrakingTorqueLimit
//                        }
//                        EncodingParamEdit {
//                            metaParam: registry.tracInvCmdMode
//                        }
//                        ScalarParamEdit {
//                            metaParam: registry.tracInvReverseDir
//                        }
//                    }
//                    ColumnLayout {
//                        Layout.alignment: Qt.AlignTop
//                        ScalarParamEdit {
//                            metaParam: registry.tracInvFreqRef
//                        }
//                        ScalarParamEdit {
//                            metaParam: registry.tracInvMotorSpeed
//                        }
//                        ScalarParamEdit {
//                            metaParam: registry.tracInvDcBusVolt
//                        }
//                        ScalarParamEdit {
//                            metaParam: registry.tracInvTorqueRef
//                        }
//                        ScalarParamEdit {
//                            metaParam: registry.tracInvAlarmCode
//                        }
//                        ScalarParamEdit {
//                            metaParam: registry.tracInvFaultCode
//                        }
//                    }
//                    ColumnLayout {
//                        Layout.alignment: Qt.AlignTop
//                        ScalarParamEdit {
//                            metaParam: registry.tracInvInputS1
//                        }
//                        ScalarParamEdit {
//                            metaParam: registry.tracInvInputS2
//                        }
//                        ScalarParamEdit {
//                            metaParam: registry.tracInvInputS3
//                        }
//                        ScalarParamEdit {
//                            metaParam: registry.tracInvInputS4
//                        }
//                        ScalarParamEdit {
//                            metaParam: registry.tracInvInputA1
//                        }
//                        ScalarParamEdit {
//                            metaParam: registry.tracInvInputA2
//                        }
//                    }
//                    ColumnLayout {
//                        Layout.alignment: Qt.AlignTop
//                        ScalarParamEdit {
//                            metaParam: registry.tracInvDuringRun
//                        }
//                        ScalarParamEdit {
//                            metaParam: registry.tracInvDuringReverse
//                        }
//                        ScalarParamEdit {
//                            metaParam: registry.tracInvDuringFaultReset
//                        }
//                        ScalarParamEdit {
//                            metaParam: registry.tracInvDriveReady
//                        }
//                        ScalarParamEdit {
//                            metaParam: registry.tracInvDuringAlarm
//                        }
//                        ScalarParamEdit {
//                            metaParam: registry.tracInvDuringFault
//                        }
//                    }
//                    ColumnLayout {
//                        Layout.alignment: Qt.AlignTop
//                        ScalarParamEdit {
//                            metaParam: registry.tracInvStatusUpdateStarted
//                        }
//                        ScalarParamEdit {
//                            metaParam: registry.tracInvStatusUpdated
//                        }
//                        ScalarParamEdit {
//                            metaParam: registry.tracInvWriteTorqueLimitsResult
//                        }
//                        ScalarParamEdit {
//                            metaParam: registry.tracInvWriteAcceptResult
//                        }
//                        ScalarParamEdit {
//                            metaParam: registry.tracInvReadStatusResult
//                        }
//                        ScalarParamEdit {
//                            metaParam: registry.tracInvReadFaultResult
//                        }
//                        ScalarParamEdit {
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
                        ScalarParamEdit {
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
                        ScalarParamEdit {
                            name: "Heap Alloc Bytes"
                            metaParam: registry.sysHeapAllocBytes
                        }
                        ScalarParamEdit {
                            name: "Heap Avail Bytes"
                            metaParam: registry.sysHeapFreeBytes
                        }
                        ScalarParamEdit {
                            name: "Heap Free Count"
                            metaParam: registry.sysHeapNFrees
                        }
                        ScalarParamEdit {
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
