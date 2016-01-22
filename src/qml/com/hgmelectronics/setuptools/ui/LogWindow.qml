import QtQuick 2.4
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2

Window {
    id: root

    property int faultCount
    property int warnCount
    property int infoCount
    property bool visibleFault: faultCount > 0
    property bool visibleWarn: (warnCount > 0) && showWarn.checked
    property bool visibleInfo: (infoCount > 0) && showInfo.checked

    title: qsTr("Log")

    width: 640
    height: 360

    property var messages: []

    property var messageType: ({
        fault: 0,
        warn: 1,
        info: 2
    })

    function show() {
        visible = true
    }

    function fault(msg) {
        addMsg({type: messageType.fault, text: msg, time: new Date()})
        faultCount = faultCount + 1
    }

    function warn(msg) {
        addMsg({type: messageType.warn, text: msg, time: new Date()})
        warnCount = warnCount + 1
    }

    function info(msg) {
        addMsg({type: messageType.info, text: msg, time: new Date()})
        infoCount = infoCount + 1
    }

    ColumnLayout {
        id: column
        anchors.fill: parent
        anchors.margins: 10
        spacing: 5

        TextArea {
            id: textArea

            text: ""

            readOnly: true
            wrapMode: TextEdit.NoWrap
            textFormat: TextEdit.AutoText
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        RowLayout {
            spacing: 5
            Layout.alignment: Qt.AlignRight
            CheckBox {
                id: showWarn
                checked: true
                text: qsTr("Show warnings")
                onCheckedChanged: redraw()
            }
            CheckBox {
                id: showInfo
                checked: false
                text: qsTr("Show infos")
                onCheckedChanged: redraw()
            }
            CheckBox {
                id: showTime
                checked: false
                text: qsTr("Show times")
                onCheckedChanged: redraw()
            }
            Button {
                text: qsTr("Clear")
                onClicked: {
                    messages = []
                    faultCount = 0
                    warnCount = 0
                    infoCount = 0
                    redraw()
                }
            }
        }
    }

    function addMsg(msg) {
        messages.push(msg)
        textArea.text += renderMsg(msg)
    }

    function renderMsg(msg) {
        var timeText
        if(showTime.checked)
            timeText = Qt.formatTime(msg.time, Qt.locale().timeFormat(Locale.LongFormat)) + " " + msg.text
        else
            timeText = msg.text

        var formatted = ""
        switch(msg.type) {
        case messageType.fault:
            formatted = "<b><font color=\"#FF0000\">" + timeText + "</font></b><br/>"
            break
        case messageType.warn:
            if(showWarn.checked)
                formatted = "<font color=\"#DD9900\">" + timeText + "</font><br/>"
            break
        case messageType.info:
            if(showInfo.checked)
                formatted = "<i><font color=\"#777777\">" + timeText + "</font></i><br/>"
            break
        }
        return formatted
    }

    function redraw() {
        var buffer = ""
        for(var i = 0, end = messages.length; i < end; ++i) {
            buffer += renderMsg(messages[i])
        }
        textArea.text = buffer
    }
}
