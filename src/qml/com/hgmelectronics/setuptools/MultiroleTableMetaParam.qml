import QtQuick 2.0

import com.hgmelectronics.setuptools 1.0
import com.hgmelectronics.setuptools.xcp 1.0

MetaParam {
    property MultiroleTableParam param
    property Connections connections: Connections {
        target: param
        onDownloadDone: {
            if(resetNeeded && result === OpResult.Success)
                ParamResetNeeded.set = true
        }
    }
    name: ("value" in param.roleMapping) ? param.roleMapping["value"].name : ""
}
