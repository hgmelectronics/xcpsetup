import QtQuick 2.5

QtObject {
    readonly property string targetCmdId: "18FCD403"
    readonly property string targetResId: "18FCD4F9"
    readonly property int bps: 500000
    readonly property var parameterFilenameFilters: [
        qsTr("HGM parameter files (*.hgp)"),
        qsTr("All files (*)")
    ]
    readonly property var preferredPlotColors: [
        "#000000",
        "#e69f00",
        "#56b4e9",
        "#009e73",
        "#f0e442",
        "#0072b2",
        "#d55e00",
        "#cc79a7",
        "#80000000",
        "#80e69f00",
        "#8056b4e9",
        "#80009e73",
        "#80f0e442",
        "#800072b2",
        "#80d55e00",
        "#80cc79a7"
    ]

}
