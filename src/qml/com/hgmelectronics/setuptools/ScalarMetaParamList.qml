import QtQuick 2.0

QtObject {
    id: root
    property list<ScalarMetaParam> params
    default property alias data: root.params
    property bool anyValid: {
        for(var i = 0; i < params.length; ++i) {
            if(params[i].param.valid)
                return true
        }
        return false
    }
}
