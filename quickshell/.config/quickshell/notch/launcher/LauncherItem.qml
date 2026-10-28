import QtQuick
import Quickshell
import Quickshell.Widgets
import qs

// One row in the launcher result list.
Rectangle {
    id: root

    required property var modelData
    required property int index
    property var view: null

    signal activated

    readonly property bool selected: view !== null && view.currentIndex === index

    implicitHeight: 44
    radius: 10
    color: selected ? Theme.surfaceHover : (pointer.containsMouse ? Theme.surface : "transparent")

    Row {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 12
        spacing: 12

        IconImage {
            id: icon
            anchors.verticalCenter: parent.verticalCenter
            implicitSize: 38
            asynchronous: true
            source: {
                const path = Quickshell.iconPath(root.modelData.icon || "", true);
                return path !== "" ? path : Quickshell.iconPath("application-x-executable", true);
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - icon.width - 12

            Text {
                width: parent.width
                text: root.modelData.name
                color: Theme.foreground
                font.pixelSize: 16
                elide: Text.ElideRight
            }
        }
    }

    MouseArea {
        id: pointer
        anchors.fill: parent
        hoverEnabled: true

        onClicked: root.activated()
        onContainsMouseChanged: {
            if (containsMouse && root.view !== null)
                root.view.currentIndex = root.index;
        }
    }
}
