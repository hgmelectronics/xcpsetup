import QtQuick 2.4
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2

Window {
    id: root

    property int faultCount
    property int warnCount
    property int infoCount

    title: qsTr("Log")

    width: 480
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
    }

    function warn(msg) {
        addMsg({type: messageType.warn, text: msg, time: new Date()})
    }

    function info(msg) {
        addMsg({type: messageType.info, text: msg, time: new Date()})
    }

    ColumnLayout {
        id: column
        anchors.fill: parent
        anchors.margins: 10
        spacing: 5

        TextArea {
            id: textArea

            readOnly: true
            wrapMode: TextEdit.NoWrap
            textFormat: TextEdit.RichText
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
                    redraw()
                }
            }
        }
    }

    function addMsg(msg) {
        messages.push(msg)
        drawMsg(msg, textArea.text)
    }

    function drawMsg(msg, buffer) {
        var timeText
        if(showTime.checked)
            timeText = Qt.formatTime(time, Qt.locale(Locale.name).timeFormat(Locale.ShortFormat)) + " " + msg.text
        else
            timeText = msg.text

        switch(msg.type) {
        case messageType.fault:
            buffer += "<b><font color=\"#FF0000\">" + timeText + "</font></b><br/>"
            break
        case messageType.warn:
            if(showWarn.checked)
                buffer += "<font color=\"#DD9900\">" + timeText + "</font><br/>"
            break
        case messageType.info:
            if(showInfo.checked)
                buffer += "<i><font color=\"#777777\">" + timeText + "</font></i><br/>"
            break
        }
    }

    function redraw() {
        var buffer = ""
        for(var i = 0, end = messages.length; i < end; ++i) {
            drawMsg(messages[i], buffer)
        }
        textArea.text = buffer
    }
}
