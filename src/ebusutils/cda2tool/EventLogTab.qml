import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

RowLayout {
    id: root
    property ParamLayer paramLayer
    property Parameters parameters
    EbusEventLogInterface {
        id: logInterface
        paramLayer: root.paramLayer
        beginSerialAddr:    0x10000000
        endSerialAddr:      0x10000008
        clearToSerialAddr:  0x10000010
        viewSerialAddr:     0x10000018
        viewKeyAddr:        0x10000020
        viewFreezeSizeAddr: 0x10000038
        viewFreezeAddr:     0x10000040
        viewFreezeMaxSize:  64
    }

    Layout.alignment: Qt.AlignLeft
    anchors.fill: parent
    anchors.margins: 10
    spacing: 10
    ColumnLayout {
        Layout.alignment: Qt.AlignTop

        GroupBox {
            title: "Min Serial"
            TextField {
                text: logInterface.minEventSerial
            }
        }
        GroupBox {
            title: "Max Serial"
            TextField {
                text: logInterface.maxEventSerial
            }
        }
        GroupBox {
            title: "Clear To Serial"
            TextField {
                validator: IntValidator {}

                onAccepted: logInterface.clearTo(text)
            }
        }

        Button {
            action: readEvents
        }

        Button {
            action: exportEvents
        }
    }

    Action {
        id: readEvents
        text: qsTr("Read Events")
        enabled: paramLayer.idle && paramLayer.slaveConnected && !logInterface.busy
        onTriggered: {
            logInterface.readBoundsAndEvents()
        }
    }

    Action {
        id: exportEvents
        text: qsTr("Export Events")

        onTriggered: {
            exportedEventsWindow.redraw()
            exportedEventsWindow.show()
        }
    }

    function keyString(key) {
        if(typeof key !== "number")
            return ""
        switch(key) {
        case 0x90000:
            return "Fault Halt"
        case 0x90001:
            return "Exited Fault Halt"
        case 0x90002:
            return "Start Inhibited"
        case 0x90003:
            return "Ground Fault Detected"
        case 0x90004:
            return "Ground Fault Cleared"
        case 0xA0000:
            return "Bootup"
        case 0xA0001:
            return "Stack Overflow"
        default:
            return key.toString(16)
        }
    }

    function packStatusString(raw) {
        var str = ""
        if(raw & 0x00000001)
            str += ",OpenWire"
        if(raw & 0x00000002)
            str += ",Thermistor"
        if(raw & 0x00000004)
            str += ",Balance"
        if(raw & 0x00000008)
            str += ",Internal"
        if(raw & 0x00000010)
            str += ",PwrSupply"
        if(raw & 0x00000020)
            str += ",I2C"
        if(raw & 0x00000040)
            str += ",Overtemp"
        if(raw & 0x00000100)
            str += ",Comm"
        if(raw & 0x00000200)
            str += ",VoltLost"
        if(raw & 0x00000400)
            str += ",TempLost"
        if(raw & 0x00000800)
            str += ",AdjTempLost"
        if(raw & 0x00001000)
            str += ",GndFlt"
        if(raw & 0x00002000)
            str += ",LimpHome"
        if(raw & 0x00004000)
            str += ",CurrRegFlt"
        if(raw & 0x00008000)
            str += ",LowAuxV"
        if(raw & 0x00010000)
            str += ",CtcInop"
        if(raw & 0x00020000)
            str += ",TracPrechgFlt"
        if(raw & 0x00040000)
            str += ",AuxPrechgFlt"
        if(raw & 0x00080000)
            str += ",LowStringV"

        if(raw & 0x20000000)
            str += ",BattCtcClosed"
        if(raw & 0x10000000)
            str += ",PosTracCtcClosed"
        if(raw & 0x08000000)
            str += ",PosAuxCtcClosed"
        if(raw & 0x04000000)
            str += ",NegCtcClosed"
        if(raw & 0x02000000)
            str += ",HVPresent"
        if(raw & 0x01000000)
            str += ",ExtChgCtcClosed"

        if(str.length)
            return str.slice(1)
        else
            return ""
    }

    function decodeCbtmFaults(raw) {
        if(raw === 0)
            return ""

        var boardId = (raw & 0xFF000000) >> 24
        var boardStr = "ID=" + boardId.toFixed()
        var str = ""
        if(raw & 0x00000001)
            str += ",OpenWire"
        if(raw & 0x00000002)
            str += ",Thermistor"
        if(raw & 0x00000004)
            str += ",Balance"
        if(raw & 0x00000008)
            str += ",Internal"
        if(raw & 0x00000010)
            str += ",PwrSupply"
        if(raw & 0x00000020)
            str += ",I2C"
        if(raw & 0x00000040)
            str += ",Overtemp"
        if(raw & 0x00000100)
            str += ",Comm"
        if(raw & 0x00000200)
            str += ",MainFetShort"
        if(raw & 0x00000400)
            str += ",AuxFetShort"
        if(raw & 0x00000800)
            str += ",FetOpen"
        if(raw & 0x00001000)
            str += ",CellvSelftest"
        if(raw & 0x00002000)
            str += ",AuxSelftest"
        if(raw & 0x00004000)
            str += ",StatusSelftest"
        if(raw & 0x00008000)
            str += ",IntMux"
        if(raw & 0x00010000)
            str += ",CellVSum"
        if(raw & 0x00020000)
            str += ",Ref"
        if(raw & 0x40000000)
            str += ",NonQuiescent"
        return boardStr + str
    }

    function ctcCtrlString(code) {
        if(typeof code !== "number")
            return ""
        switch(code) {
        case 0:
            return "Standby"
        case 1:
            return "Ready"
        case 2:
            return "TracPrecharge"
        case 3:
            return "Run"
        case 4:
            return "StoppingRun"
        case 5:
            return "Charge"
        case 6:
            return "StoppingCharge"
        case 7:
            return "FaultHalt"
        default:
            return code.toString(16)
        }
    }

    function timestampFromView(view) {
        return (view.getUint32(0x00, 1) + view.getUint32(0x00, 1) << 32) / 1000000
    }

    function decodeFaultHaltFreezeFrame(view) {
        var timestamp = timestampFromView(view)
        var packStatus = packStatusString(view.getUint32(0x08, 1))
        var stringI = (view.getUint16(0x0C, 1) - 32000) * 0.05
        var stringV = (view.getUint16(0x0E, 1) - 32120) * 0.05
        var maxStringI = (view.getUint16(0x10, 1) - 32000) * 0.05
        var minStringI = (view.getUint16(0x12, 1) - 32000) * 0.05
        var maxCellV = view.getUint16(0x14, 1) * 0.0001
        var minCellV = view.getUint16(0x16, 1) * 0.0001
        var highVCellNum = view.getUint8(0x18)
        var lowVCellNum = view.getUint8(0x19)
        var maxTabTemp = view.getUint8(0x1A) - 40
        var minTabTemp = view.getUint8(0x1B) - 40
        var hotTabNum = view.getUint8(0x1C)
        var coldTabNum = view.getUint8(0x1D)
        var ctcCtrlState = ctcCtrlString(view.getUint8(0x1E))

        var boardFaults = [decodeCbtmFaults(view.getUint32(0x20, 1)),
                           decodeCbtmFaults(view.getUint32(0x24, 1))]

        var str = ""
        str += "TimeSinceBoot=" + timestamp.toFixed(3)
        str += " PackStatus=" + packStatus
        str += " StringI=" + stringI
        str += " StringV=" + stringV
        str += " MaxStringI=" + maxStringI
        str += " MinStringI=" + minStringI
        if(maxCellV >= minCellV) {
            str += " MaxCellV=" + maxCellV.toFixed(4) + "@" + highVCellNum
            str += " MinCellV=" + minCellV.toFixed(4) + "@" + lowVCellNum
        }
        else {
            str += " NoCellVData"
        }
        if(maxTabTemp >= minTabTemp) {
            str += " MaxTabTemp=" + maxTabTemp + "@" + hotTabNum
            str += " MinTabTemp=" + minTabTemp + "@" + coldTabNum
        }
        else {
            str += " NoTabTempData"
        }
        str += " CtcState=" + ctcCtrlState
        if(boardFaults[0].length)
            str += " CBTM" + boardFaults[0]
        if(boardFaults[1].length)
            str += " CBTM" + boardFaults[1]

        return str
    }

    function decodeOldGroundFaultFreezeFrame(view) {
        var timestamp = timestampFromView(view)
        var conductance = view.getUint16(0x08, 1) * 0.001
        var center = view.getUint16(0x0A, 1) / 40000

        var str = ""
        str += "TimeSinceBoot=" + timestamp.toFixed(3)
        str += " Conductance=" + conductance.toFixed(3) + "uS"
        str += " Center=" + center.toFixed(2) + "%"

        return str
    }

    function decodeGroundFaultFreezeFrame(view) {
        var timestamp = timestampFromView(view)
        var conductance = view.getUint32(0x08, 1) * 0.001
        var center = view.getUint32(0x0C, 1) / 400

        var str = ""
        str += "TimeSinceBoot=" + timestamp.toFixed(3)
        str += " Conductance=" + conductance.toFixed(3) + "uS"
        str += " Center=" + center.toFixed(2) + "%"

        return str
    }

    function sysFlagsString(raw) {
        var str = ""
        if(raw & 0x00000001)
            str += ",WatchdogReset"
        if(raw & 0x00000002)
            str += ",CycleTimeViolation"
        if(raw & 0x00000004)
            str += ",StackOverflow"
        if(raw & 0x00008000)
            str += ",CanaryPresent"
        return str.slice(1)
    }

    function resetFlagsString(raw) {
        var str = ""
        if(raw & 0x00000001)
            str += ",PinReset"
        if(raw & 0x00000002)
            str += ",PowerOnReset"
        if(raw & 0x00000004)
            str += ",SoftReset"
        if(raw & 0x00000008)
            str += ",IndepWatchdogReset"
        if(raw & 0x00000010)
            str += ",WindowWatchdogReset"
        if(raw & 0x00000020)
            str += ",LowPowerReset"
        if(raw & 0x00008000)
            str += ",CanaryPresent"
        return str.slice(1)
    }

    function decodeResetFreezeFrame(view) {
        var flags = resetFlagsString(view.getUint16(0x00, 1))
        var resetCount = view.getUint16(0x02, 1)

        var str = ""
        str += "Flags=" + flags
        str += " ResetCount=" + resetCount

        return str
    }

    function decodeStackOverflowFreezeFrame(view) {
        var timestamp = timestampFromView(view)
        var flags = sysFlagsString(view.getUint16(0x08, 1))
        var rtdbRows = view.getUint16(0x0A, 1)
        var heapAllocBytes = view.getUint32(0x0C, 1)
        var heapFreeBytes = view.getUint32(0x10, 1)
        var heapNFrees = view.getUint32(0x14, 1)

        var str = ""
        str += "TimeSinceBoot=" + timestamp.toFixed(3)
        str += " Flags=" + flags
        str += " RTDBRows=" + rtdbRows
        str += " AllocBytes=" + heapAllocBytes
        str += " FreeBytes=" + heapFreeBytes
        str += " NFrees=" + heapNFrees

        return str
    }

    function decodeFreezeFrame(arr) {
        if(!Array.isArray(arr)
                || arr.length < 1)
            return ""

        var i
        for(i = 0; i < arr.length; ++i) {
            if(typeof arr[i] !== "number") {
                console.log("Bad event log freeze frame format")
                console.log(arr)
                return ""
            }
        }

        var key = arr[0]
        var freeze = arr.slice(1)
        var freezeBuffer = new ArrayBuffer(freeze.length)
        var freezeUint8Array = new Uint8Array(freezeBuffer)
        freezeUint8Array.set(freeze)
        var freezeView = new DataView(freezeBuffer)

        if((key === 0x90000
                || key === 0x90001
                || key === 0x90002)
            && freeze.length === 0x28) {
            // fault halt freeze frame format
            return decodeFaultHaltFreezeFrame(freezeView)
        }
        else if((key === 0x90003
                 || key === 0x90004)
             && freeze.length === 0x0C) {
            // old ground fault freeze frame format
            return decodeOldGroundFaultFreezeFrame(freezeView)
        }
        else if((key === 0x90003
                 || key === 0x90004)
             && freeze.length === 0x10) {
            // new ground fault freeze frame format
            return decodeGroundFaultFreezeFrame(freezeView)
        }
        else if((key === 0xA0000)
             && freeze.length === 0x04) {
            // reset freeze frame format
            return decodeResetFreezeFrame(freezeView)

        }
        else if((key === 0xA0001)
             && freeze.length === 0x18) {
            // stack overflow freeze frame format
            return decodeStackOverflowFreezeFrame(freezeView)
        }
        else {
            // unknown, display as hex
            var str = ""
            i = 0
            while(1) {
                if(i >= freeze.length)
                    return str
                var valueStr = freeze[i].toString(16)
                if(valueStr.length < 2)
                    valueStr = "0" + valueStr
                str += valueStr
                ++i
                if(i < freeze.length)
                    str += " "
            }
        }
    }

    Window {
        id: exportedEventsWindow

        title: qsTr("Exported Events")

        width: 640
        height: 360

        TextArea {
            id: textArea

            text: ""

            readOnly: true
            wrapMode: TextEdit.NoWrap
            textFormat: TextEdit.AutoText
            anchors.fill: parent
        }

        function redraw() {
            var buffer = ""
            for(var i = 0, end = logInterface.model.count; i < end; ++i) {
                var serial = logInterface.model.get(i, "serial")
                var key = logInterface.model.get(i, "key")
                var freeze = logInterface.model.get(i, "freeze")
                if((typeof serial === "number") && (typeof key === "number") && Array.isArray(freeze))
                    buffer += serial.toFixed() + "\t" + keyString(key) + "\t" + decodeFreezeFrame(freeze) + "\n"
            }
            textArea.text = buffer
        }
    }

    Label {
        visible: false
        id: sysFontLabel
    }

    TableView {
        Layout.alignment: Qt.AlignTop
        Layout.fillHeight: true
        Layout.fillWidth: true
        id: table
        model: logInterface.model
        rowDelegate: Rectangle {
           height: 13*3+4
           SystemPalette {
              id: sysPalette
              colorGroup: SystemPalette.Active
           }
           color: {
              var baseColor = styleData.alternate ? sysPalette.alternateBase : sysPalette.base
              return styleData.selected ? sysPalette.highlight : baseColor
           }
        }
        TableViewColumn {
            id: serialColumn
            role: "serial"
            title: "Serial #"
            delegate: Text {
                Layout.fillHeight: true
                verticalAlignment: Text.AlignVCenter
                padding: 2
                font: sysFontLabel.font
                renderType: sysFontLabel.renderType
                color: styleData.selected ? "white" : styleData.textColor
                text: (typeof styleData.value === "number") ? styleData.value.toFixed() : ""
            }
        }
        TableViewColumn {
            id: keyColumn
            role: "key"
            title: "Code"
            width: 150
            delegate: Text {
                Layout.fillHeight: true
                verticalAlignment: Text.AlignVCenter
                padding: 2
                font: sysFontLabel.font
                renderType: sysFontLabel.renderType
                color: styleData.selected ? "white" : styleData.textColor
                text: keyString(styleData.value)
            }
        }
        TableViewColumn {
            role: "freeze"
            title: "Freeze Frame"
            width: table.viewport.width - serialColumn.width - keyColumn.width
            delegate: Text {
                Layout.fillHeight: true
                verticalAlignment: Text.AlignVCenter
                padding: 2
                font: sysFontLabel.font
                renderType: sysFontLabel.renderType
                color: styleData.selected ? "white" : styleData.textColor
                text: decodeFreezeFrame(styleData.value)
                wrapMode: Text.Wrap
            }
        }
    }
}
