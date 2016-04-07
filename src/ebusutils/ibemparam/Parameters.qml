import QtQuick 2.5
import com.hgmelectronics.setuptools.xcp 1.0
import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.ui 1.0

QtObject {
    id: parameters
    property ParamRegistry registry;
    property ParamId paramId: ParamId {}
    property Slots slots: Slots {}

    property ScalarMetaParam boardId: ScalarMetaParam {
        param: registry.addScalarParam(MemoryRange.U8, paramId.boardId, true, true, slots.raw32)
        name: qsTr("Board ID")
    }

}
