import QtQuick
import qs

// Everything the notch shows while idle: workspaces, clock, network, date.
Item {
    id: root

    property bool expanded: false
    property bool hoverd: false

    Item {
        id: topRow
        width: parent.width
        height: Theme.collapsedHeight

        Workspaces {
            anchors.left: parent.left
            anchors.leftMargin: Theme.margin
            anchors.verticalCenter: parent.verticalCenter
            expanded: root.expanded
        }

        ClockDisplay {
            anchors.centerIn: parent
            expanded: root.expanded
            hoverd_expand: root.hoverd
        }

        NetworkIndicator {
            anchors.right: parent.right
            anchors.rightMargin: Theme.margin
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    DateDisplay {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: topRow.bottom
        expanded: root.expanded
    }
}
