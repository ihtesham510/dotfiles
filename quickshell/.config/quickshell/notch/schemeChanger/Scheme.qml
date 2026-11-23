import QtQuick
import qs
import qs.notch
import qs.services

Item {
    id: root

    required property var modelData
    required property int index
    property ListView view

    signal activated

    property string iconFont: "Material Symbols Rounded"

    readonly property bool selected: view && view.currentIndex === index
    readonly property bool active: modelData.value === Schemes.scheme

    implicitHeight: 44
    height: implicitHeight

    Rectangle {
        anchors.fill: parent
        radius: 10
        color: root.selected ? Qt.alpha(Theme.foreground, 0.10) : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: 100
            }
        }
    }

    Icon {
        id: icon
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        source: Icons.url(root.modelData.icon)
        size: 20
        color: root.active ? Theme.success : Theme.foreground
    }

    Text {
        anchors.left: icon.right
        anchors.leftMargin: 12
        anchors.right: check.left
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        text: root.modelData.name
        elide: Text.ElideRight
        font.pixelSize: 14
        font.bold: root.active
        color: root.active ? Theme.success : Theme.foreground
    }

    Text {
        id: check
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        visible: root.active
        text: "check"
        font.family: root.iconFont
        font.pixelSize: 18
        color: Theme.success
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: if (root.view)
            root.view.currentIndex = root.index
        onClicked: root.activated()
    }
}
