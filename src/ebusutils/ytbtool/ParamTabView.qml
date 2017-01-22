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
            title: "AIO/DIO/RTD"
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
                            metaParam: registry.aioTracMotorMaxRpm
                        }
                        ScalarParamEdit {
                            metaParam: registry.aioHallSensorCurrPerVolt
                        }
                        ScalarParamEdit {
                            metaParam: registry.aioTracMotorTherm1Curve
                        }
                        ScalarParamEdit {
                            metaParam: registry.aioTracMotorTherm2Curve
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        TableParamEdit {
                            xLabel: "#"
                            valueLabel: "V"
                            tableParam: registry.aioAiCts
                        }
                        TableParamEdit {
                            xLabel: "#"
                            valueLabel: "V"
                            tableParam: registry.aioAoCts
                        }
                        ScalarParamEdit {
                            metaParam: registry.rtdTemp0
                        }
                        ScalarParamEdit {
                            metaParam: registry.rtdTemp1
                        }
                        ScalarParamEdit {
                            metaParam: registry.rtdTemp2
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamEdit {
                            metaParam: registry.aioTracMotorSpeed
                        }
                        ScalarParamEdit {
                            metaParam: registry.aioTracMotorTorque
                        }
                        ScalarParamEdit {
                            metaParam: registry.aioTracMotorDcCurr
                        }
                        ScalarParamEdit {
                            metaParam: registry.aioTracMotorTherm1Temp
                        }
                        ScalarParamEdit {
                            metaParam: registry.aioTracMotorTherm2Temp
                        }
                        ScalarParamEdit {
                            metaParam: registry.aioTracMotorSpeedCmd
                        }
                        ScalarParamEdit {
                            metaParam: registry.aioTracMotorTorqueCmd
                        }
                        ScalarParamEdit {
                            metaParam: registry.dioForwardRun
                        }
                        ScalarParamEdit {
                            metaParam: registry.dioReverseRun
                        }
                        ScalarParamEdit {
                            metaParam: registry.dioTorqueMode
                        }
                        ScalarParamEdit {
                            metaParam: registry.dioFaultReset
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamEdit {
                            metaParam: registry.aioBus5VMillivolts
                        }
                        ScalarParamEdit {
                            metaParam: registry.aioBus3V3Millivolts
                        }
                        ScalarParamEdit {
                            metaParam: registry.aioBusPos15VMillivolts
                        }
                        ScalarParamEdit {
                            metaParam: registry.aioBusNeg15VMillivolts
                        }
                    }
                }
            }
        }

        Tab {
            title: "Aux Inverters"
            active: true
            AutoRefreshArea {
                base: this
                RowLayout {
                    Layout.alignment: Qt.AlignLeft
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10
                    MultiroleTableParamEdit {
                        Layout.margins: 10
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        tableMetaParam: registry.auxInv
                        roleNames: ["x", "cmdMode", "cmdSpeed", "cmdUpdated", "state", "speed", "faultCode", "alarmCode", "statusUpdated", "writeCmd", "readStatus", "readFault"]
                    }
                }
            }
        }

        Tab {
            title: "CAN"
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
                            metaParam: registry.canTracMaxMotoringCurr
                        }
                        ScalarParamEdit {
                            metaParam: registry.canTracMaxBrakingCurr
                        }
                        ScalarParamEdit {
                            metaParam: registry.canTracCmdSpeed
                        }
                        ScalarParamEdit {
                            metaParam: registry.canTracCmdTorque
                        }
                        ScalarParamEdit {
                            metaParam: registry.canTracCmdMode
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamEdit {
                            metaParam: registry.canTracSpeed
                        }
                        ScalarParamEdit {
                            metaParam: registry.canTracTorque
                        }
                        ScalarParamEdit {
                            metaParam: registry.canTracDcCurr
                        }
                        ScalarParamEdit {
                            metaParam: registry.canTracState
                        }
                        ScalarParamEdit {
                            metaParam: registry.canTracFaultCode
                        }
                        ScalarParamEdit {
                            metaParam: registry.canTracAlarmCode
                        }
                        TableParamEdit {
                            xLabel: "#"
                            valueLabel: "degC"
                            tableParam: registry.canTracMotorTemp
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamEdit {
                            name: "XcpProgramRequested"
                            metaParam: registry.canXcpProgramRequested
                        }
                        ScalarParamEdit {
                            name: "Can1RxErrCount"
                            metaParam: registry.canCan1RxErrCount
                        }
                        ScalarParamEdit {
                            name: "Can1TxErrCount"
                            metaParam: registry.canCan1TxErrCount
                        }
                        ScalarParamEdit {
                            name: "Can2RxErrCount"
                            metaParam: registry.canCan2RxErrCount
                        }
                        ScalarParamEdit {
                            name: "Can2TxErrCount"
                            metaParam: registry.canCan2TxErrCount
                        }
                    }
                }
            }
        }

        Tab {
            title: "Trac Inverter"
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
                            metaParam: registry.tracInvFwdMotoringTorqueLimit
                        }
                        ScalarParamEdit {
                            metaParam: registry.tracInvRevMotoringTorqueLimit
                        }
                        ScalarParamEdit {
                            metaParam: registry.tracInvFwdBrakingTorqueLimit
                        }
                        ScalarParamEdit {
                            metaParam: registry.tracInvRevBrakingTorqueLimit
                        }
                        EncodingParamEdit {
                            metaParam: registry.tracInvCmdMode
                        }
                        ScalarParamEdit {
                            metaParam: registry.tracInvReverseDir
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamEdit {
                            metaParam: registry.tracInvFreqRef
                        }
                        ScalarParamEdit {
                            metaParam: registry.tracInvMotorSpeed
                        }
                        ScalarParamEdit {
                            metaParam: registry.tracInvDcBusVolt
                        }
                        ScalarParamEdit {
                            metaParam: registry.tracInvTorqueRef
                        }
                        ScalarParamEdit {
                            metaParam: registry.tracInvAlarmCode
                        }
                        ScalarParamEdit {
                            metaParam: registry.tracInvFaultCode
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamEdit {
                            metaParam: registry.tracInvInputS1
                        }
                        ScalarParamEdit {
                            metaParam: registry.tracInvInputS2
                        }
                        ScalarParamEdit {
                            metaParam: registry.tracInvInputS3
                        }
                        ScalarParamEdit {
                            metaParam: registry.tracInvInputS4
                        }
                        ScalarParamEdit {
                            metaParam: registry.tracInvInputA1
                        }
                        ScalarParamEdit {
                            metaParam: registry.tracInvInputA2
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamEdit {
                            metaParam: registry.tracInvDuringRun
                        }
                        ScalarParamEdit {
                            metaParam: registry.tracInvDuringReverse
                        }
                        ScalarParamEdit {
                            metaParam: registry.tracInvDuringFaultReset
                        }
                        ScalarParamEdit {
                            metaParam: registry.tracInvDriveReady
                        }
                        ScalarParamEdit {
                            metaParam: registry.tracInvDuringAlarm
                        }
                        ScalarParamEdit {
                            metaParam: registry.tracInvDuringFault
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamEdit {
                            metaParam: registry.tracInvStatusUpdateStarted
                        }
                        ScalarParamEdit {
                            metaParam: registry.tracInvStatusUpdated
                        }
                        ScalarParamEdit {
                            metaParam: registry.tracInvWriteTorqueLimitsResult
                        }
                        ScalarParamEdit {
                            metaParam: registry.tracInvWriteAcceptResult
                        }
                        ScalarParamEdit {
                            metaParam: registry.tracInvReadStatusResult
                        }
                        ScalarParamEdit {
                            metaParam: registry.tracInvReadFaultResult
                        }
                        ScalarParamEdit {
                            metaParam: registry.tracInvTorqueLimitsSet
                        }
                    }
                }
            }
        }

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
                        ScalarParamEdit {
                            metaParam: registry.sysCycleDrvAuxInvOut
                        }
                        ScalarParamEdit {
                            metaParam: registry.sysCycleDrvCanIn
                        }
                        ScalarParamEdit {
                            metaParam: registry.sysCycleDrvCanOut
                        }
                        ScalarParamEdit {
                            metaParam: registry.sysCycleDrvRtdIn
                        }
                        ScalarParamEdit {
                            metaParam: registry.sysCycleDrvTracInvIn
                        }
                        ScalarParamEdit {
                            metaParam: registry.sysCycleDrvTracInvOut
                        }
                        ScalarParamEdit {
                            metaParam: registry.sysCycleCtlTrac
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

        Tab {
            title: "Trac"
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
                        EncodingParamEdit {
                            metaParam: registry.tracTempSensorType
                        }
                        ScalarParamEdit {
                            metaParam: registry.tracCurrentRegUpRelax
                        }
                        ScalarParamEdit {
                            metaParam: registry.tracCurrentRegDownRelax
                        }
                        ScalarParamEdit {
                            metaParam: registry.tracCurrentRegRatedTorque
                        }
                        ScalarParamEdit {
                            metaParam: registry.tracAccelDampingFilterLength
                        }
                        ScalarParamEdit {
                            metaParam: registry.tracAccelDampingCoeff
                        }
                        ScalarParamEdit {
                            metaParam: registry.tracAccelDampingMaxIncrease
                        }
                        ScalarParamEdit {
                            metaParam: registry.tracAccelDampingMaxDecrease
                        }
                    }
                    ColumnLayout {
                        Layout.alignment: Qt.AlignTop
                        ScalarParamEdit {
                            metaParam: registry.tracAnalogSpeedOffset
                        }
                        ScalarParamEdit {
                            metaParam: registry.tracAnalogTorqueOffset
                        }
                        ScalarParamEdit {
                            metaParam: registry.tracAnalogSpeedCmdOffset
                        }
                        ScalarParamEdit {
                            metaParam: registry.tracAnalogTorqueCmdOffset
                        }
                        ScalarParamEdit {
                            metaParam: registry.tracPositiveTorqueLimit
                        }
                        ScalarParamEdit {
                            metaParam: registry.tracNegativeTorqueLimit
                        }
                        ScalarParamEdit {
                            metaParam: registry.tracMotorSpeed
                        }
                        ScalarParamEdit {
                            metaParam: registry.tracMotorAccel
                        }
                        ScalarParamEdit {
                            metaParam: registry.tracMotorTorque
                        }
                        ScalarParamEdit {
                            metaParam: registry.tracMotorDcCurr
                        }
                        ScalarParamEdit {
                            metaParam: registry.tracState
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
