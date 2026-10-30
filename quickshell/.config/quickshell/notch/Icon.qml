import QtQuick
import Qt5Compat.GraphicalEffects

Item {
    id: root
    property url source
    property color color: "white"
    property int size: 24

    implicitWidth: size
    implicitHeight: size

    Image {
        id: img
        anchors.fill: parent
        source: root.source
        sourceSize: Qt.size(root.size * 2, root.size * 2)

        layer.enabled: true
        layer.effect: ColorOverlay {
            color: root.color
        }
    }
}
