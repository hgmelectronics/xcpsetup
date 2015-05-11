import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1
import QtQuick.Window 2.0

Window {
    id: helpDialog
    title: "HGMFlash help"
    width: helpForm.implicitWidth + 20
    height: helpForm.implicitHeight + 20

    function show() {
        visible = true
    }

    Column {
        signal closeClicked()

        id: helpForm
        anchors.fill: parent
        anchors.margins: 10
        spacing: 5

        Label {
            width: 500
            wrapMode: Text.WordWrap
            text:   "<h2>Program</h2>
    <p>Use the Open command in the File menu to select an S-record program file to load on the target controller. Once it is successfully loaded, the fields in the Program area will show information about the file.</p>
    <h2>Interface</h2>
    <p>Select an interface from the drop-down menu. If you have built-in serial ports on your system, you will see an entry for each one, even though only one corresponds to the ELM327 compatible interface. You can try each port in turn, or look at your system's Device Manager or equivalent to find which port to use. If you do not see the port you are looking for, try closing and reopening the program.</p>
    <p>Note: the FTDI USB to serial adapter chips in many ELM327 compatible interfaces have a timing delay that can greatly slow programming on Windows machines. There is a setting that can be changed to fix this problem; this only has to be done once for each unique ELM327 adapter you use with your computer. To do so, follow these steps:</p>
    <ol><li>Open <i>Device Manager</i> from the Control Panel.</li>
    <li>Click on the <i>Ports (COM and LPT)</i> section label to expand it.</li>
    <li>Locate the entry for the USB serial port corresponding to your ELM327 adapter.</li>
    <li>Double-click on the entry to open the <i>Properties</i> dialog.</li>
    <li>Select the <i>Port Settings</i> tab.</li>
    <li>Click on the <i>Advanced...</i> button.</li>
    <li>Find the section labeled <i>Latency Timer (msec)</i>, and click on the drop-down menu.</li>
    <li>Change the value from 16 (the default) to 1.</li>
    <li>Click OK to save the change.</li>
    <li>Close the <i>Properties</i> window and the <i>Device Manager</i> window.</li>
    </ol>
    <p>Once you have selected an interface, click the Open button. You only need to use the Close button if you wish to switch to another interface; it is safe to simply quit the program when you are done.</p>
    <p>To begin programming, click the Start button. A dialog box will appear when the process is done. If you see an error message, please contact HGM for further instructions.</p>
    "
        }
        Button {
            anchors.right: parent.right
            text: "Close"
            isDefault: true
            onClicked: helpDialog.visible = false
        }
    }
}
