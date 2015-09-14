import QtQuick 2.5

QtObject {
    readonly property string targetCmdId: "18FCD403"
    readonly property string targetResId: "18FCD4F9"
    readonly property int bps: 500000
    readonly property var parameterFilenameFilters: [
        qsTr("HGM parameter files (*.hgp)"),
        qsTr("All files (*)")
    ]
}
