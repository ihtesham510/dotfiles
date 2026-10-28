import QtQuick
import qs
import qs.services

// The time in the middle of the notch.
Text {
    id: root

    property bool expanded: false
    property bool hoverd_expand: false

    color: Theme.foreground
    font.bold: true
    font.pixelSize: 15
    text: Qt.formatDateTime(Clock.date, "hh:mm AP")
    scale: {
        switch (true) {
        case root.expanded:
            return 1.35;
        case root.hoverd_expand:
            return 1.3;
        default:
            return 1;
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: Theme.expandDuration
            easing.type: Easing.OutCubic
        }
    }
}
