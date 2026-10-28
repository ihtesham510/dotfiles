import QtQuick
import qs
import qs.services

// Colored dot + network type, on the right of the notch.
Row {
    spacing: 6

    Item {
        width: 7
        height: label.implicitHeight
        anchors.verticalCenter: parent.verticalCenter

        Rectangle {
            width: 7
            height: 7
            radius: 3.5
            anchors.centerIn: parent
            color: Network.online ? Theme.success : Theme.danger
        }
    }

    Text {
        id: label
        color: Theme.subtle
        font.pixelSize: 12
        text: Network.label
    }
}
