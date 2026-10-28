import QtQuick
import qs
import qs.services

// Date line, only visible while the notch is expanded.
Text {
    id: root

    property bool expanded: false

    color: Theme.muted
    font.pixelSize: 13
    text: Qt.formatDateTime(Clock.date, "dddd, d MMMM")
    opacity: 0
    visible: opacity > 0

    onExpandedChanged: {
        if (expanded) {
            fadeOut.stop();
            fadeIn.restart();
        } else {
            fadeIn.stop();
            fadeOut.restart();
        }
    }

    Component.onCompleted: {
        // Don't replay the intro when the config reloads while expanded.
        if (expanded)
            opacity = 1;
    }

    // Wait for the notch to finish growing first, so the date is never
    // revealed while the bottom edge is still clipping it.
    SequentialAnimation {
        id: fadeIn

        PauseAnimation {
            duration: Math.max(0, Theme.expandDuration - 120)
        }
        NumberAnimation {
            target: root
            property: "opacity"
            to: 1
            duration: 120
            easing.type: Easing.OutCubic
        }
    }

    // Fade out quickly so the collapsing notch doesn't cut through the text.
    SequentialAnimation {
        id: fadeOut

        NumberAnimation {
            target: root
            property: "opacity"
            to: 0
            duration: 100
            easing.type: Easing.InCubic
        }
    }
}
