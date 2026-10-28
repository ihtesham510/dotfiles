import QtQuick
import qs

// Everything the notch shows while idle: workspaces, clock, network, date.
Item {
    id: root

    property bool expanded: false
    property bool hoverd: false

    readonly property int dateGap: 2

    // The clock shifts up by half of the date's height, so time + date are
    // centred as one block instead of the time alone. Animated so the block
    // doesn't jump when the notch opens.
    property real blockShift: root.expanded ? -(date.implicitHeight + root.dateGap) / 2 : 0

    Behavior on blockShift {
        NumberAnimation {
            duration: Theme.expandDuration
            easing.type: Easing.OutCubic
        }
    }

    ClockDisplay {
        id: clock
        anchors.horizontalCenter: parent.horizontalCenter
        y: (parent.height - height) / 2 + root.blockShift
        expanded: root.expanded
        hoverd_expand: root.hoverd
    }

    DateDisplay {
        id: date
        anchors.horizontalCenter: parent.horizontalCenter
        y: clock.y + clock.height + root.dateGap
        expanded: root.expanded
    }

    // These stay on the notch's vertical centre, aligned with the clock/date
    // block. The space below them is where the media player will go.
    Workspaces {
        anchors.left: parent.left
        anchors.leftMargin: Theme.margin
        anchors.verticalCenter: parent.verticalCenter
        expanded: root.expanded
    }

    NetworkIndicator {
        anchors.right: parent.right
        anchors.rightMargin: Theme.margin
        anchors.verticalCenter: parent.verticalCenter
    }
}
