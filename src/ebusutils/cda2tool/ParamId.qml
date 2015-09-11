import QtQuick 2.5

QtObject {
    readonly property double cbtmCellVolt: 0x00031000*4
    readonly property double cbtmTabTemp: 0x00032000*4
    readonly property double cbtmDisch: 0x00033000*4
    readonly property double cbtmStatus: 0x00033100*4

    readonly property double ctcMaxSimulPickup: 0x00040000*4
    readonly property double ctcHasB: 0x00040010*4
    readonly property double ctcOn: 0x00041000*4
    readonly property double ctcOk: 0x00041010*4
    readonly property double ctcAClosed: 0x00041020*4
    readonly property double ctcBClosed: 0x00041030*4
}
