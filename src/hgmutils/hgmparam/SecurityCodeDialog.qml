import QtQuick 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1

import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0
import com.hgmelectronics.utils 1.0

Dialog {
    id: codeDialog
    property Parameters parameters
    property ParamLayer paramLayer
    property bool ready: parameters.securityCodeEntry.param.valid
    property bool setupMode: parameters.securityCodeSetup.param.valid
    property bool enteringCode: false
    title: setupMode ? qsTr("Setup Security Code") : qsTr("Enter Security Code")

    standardButtons: StandardButton.Ok | StandardButton.Cancel

    TextField {
        id: codeEdit
        text: parameters.securityCodeEntry.param.stringVal
    }

    onAccepted: {
        parameters.securityCodeEntry.param.stringVal = codeEdit.text
        if(setupMode) {
            parameters.securityCodeSetup.param.floatVal = 1
            paramLayer.download([parameters.securityCodeSetup.param.key, parameters.securityCodeEntry.param.key])   // download(keylist) guarantees keys get written in the order specified
            close()
        }
        else {
            enteringCode = true
            paramLayer.download([parameters.securityCodeEntry.param.key])
        }

    }
    onRejected: {
        codeEdit.text = Qt.binding(function() { return parameters.securityCodeEntry.param.stringVal; } )
        close()
    }
    Connections {
        target: paramLayer
        onDownloadDone: {
            if(enteringCode && keys == [parameters.securityCodeEntry.param.key]) {
                if(result == OpResult.Success) {
                    paramLayer.upload([parameters.securityCodeSetup.param.key])
                }
                else {
                    entryFailedDialog.show(qsTr("Download failed, check connection to device"))
                    enteringCode = false
                }
            }
        }
        onUploadDone: {
            if(enteringCode) {
                if(result == OpResult.Success)
                    entryOkDialog.show(qsTr("Code accepted"))
                else if(result == OpResult.SlaveErrorAccessDenied)
                    entryFailedDialog.show(qsTr("Code not accepted, please try again"))
                else
                    entryFailedDialog.show(qsTr("Upload failed, check connection to device"))

                enteringCode = false
            }
        }
    }

    MessageDialog {
        id: entryOkDialog
        title: qsTr("Security Code OK")
        standardButtons: StandardButton.Ok

        function show(str) {
            text = str
        }
    }

    MessageDialog {
        id: entryFailedDialog
        title: qsTr("Security Code Failed")
        standardButtons: StandardButton.Ok

        function show(str) {
            text = str
        }
    }
}

