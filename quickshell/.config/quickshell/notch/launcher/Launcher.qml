import QtQuick
import Quickshell
import Quickshell.Widgets
import qs
import qs.services

// The launcher body. Fills the notch and is shown only in Launcher mode.
Item {
    id: root

    signal closeRequested

    function focusInput(): void {
        search.forceActiveFocus();
    }

    function reset(): void {
        search.text = "";
        results.currentIndex = results.count > 0 ? 0 : -1;
    }

    function moveSelection(delta: int): void {
        if (results.count === 0)
            return;

        let base = results.currentIndex;
        if (base < 0)
            base = delta > 0 ? -1 : 0;

        results.currentIndex = (base + delta + results.count) % results.count;
    }

    function activate(index: int): void {
        const list = results.model;
        if (!list || index < 0 || index >= list.length)
            return;

        list[index].execute();
        root.closeRequested();
    }

    function handleEscape(event): void {
        if (search.text.length > 0) {
            search.text = "";
        } else {
            root.closeRequested();
        }
        event.accepted = true;
    }

    onVisibleChanged: {
        if (visible) {
            reset();
            // Immediate attempt plus a deferred retry: the Hyprland focus grab
            // may not have handed the keyboard to this window yet.
            focusInput();
            Qt.callLater(focusInput);
        }
    }

    // Fallback for when focus moves away from the search field.
    Keys.onEscapePressed: event => root.handleEscape(event)

    Keys.onUpPressed: event => {
        root.moveSelection(-1);
        event.accepted = true;
    }

    Keys.onDownPressed: event => {
        root.moveSelection(1);
        event.accepted = true;
    }

    // --- Search field -----------------------------------------------------

    Rectangle {
        id: searchBox
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 14
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        height: 44
        radius: 12
        border.width: 1
        color: "transparent"

        Behavior on border.color {
            ColorAnimation {
                duration: 140
            }
        }

        IconImage {
            id: searchIcon
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            implicitSize: 16
            source: Quickshell.iconPath("system-search", true)
        }

        Text {
            anchors.left: search.left
            anchors.verticalCenter: search.verticalCenter
            visible: search.text.length === 0
            text: "Search applications…"
            color: Theme.muted
            font.pixelSize: 15
        }

        TextInput {
            id: search
            anchors.left: searchIcon.right
            anchors.leftMargin: 10
            anchors.right: hint.left
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter

            color: Theme.foreground
            font.pixelSize: 15
            selectionColor: Theme.success
            selectedTextColor: Theme.background
            selectByMouse: true
            clip: true
            focus: true

            onAccepted: root.activate(results.currentIndex)

            // Arrow keys are handled here before the TextInput consumes them.
            Keys.onEscapePressed: event => root.handleEscape(event)
            Keys.onUpPressed: event => {
                root.moveSelection(-1);
                event.accepted = true;
            }
            Keys.onDownPressed: event => {
                root.moveSelection(1);
                event.accepted = true;
            }
        }

        Text {
            id: hint
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            text: "esc"
            color: Theme.muted
            font.pixelSize: 10
        }
    }

    Rectangle {
        id: divider
        anchors.top: searchBox.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        height: 1
        color: "transparent"
    }

    // --- Results ----------------------------------------------------------

    ListView {
        id: results
        anchors.top: divider.bottom
        anchors.topMargin: 8
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: footer.top
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        anchors.bottomMargin: 6

        clip: true
        spacing: 2
        cacheBuffer: 0
        keyNavigationWraps: true
        boundsBehavior: Flickable.StopAtBounds
        model: Applications.search(search.text)
        currentIndex: -1

        delegate: LauncherItem {
            width: results.width
            view: results
            onActivated: root.activate(index)
        }

        onModelChanged: currentIndex = count > 0 ? 0 : -1
        onCountChanged: currentIndex = count > 0 ? 0 : -1
        onCurrentIndexChanged: {
            if (currentIndex >= 0)
                positionViewAtIndex(currentIndex, ListView.Contain);
        }
    }

    Text {
        anchors.top: divider.bottom
        anchors.bottom: footer.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 20
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        visible: results.count === 0
        text: search.text.length === 0 ? "No applications found" : "No matches for \"" + search.text + "\""
        color: Theme.muted
        font.pixelSize: 12
        wrapMode: Text.Wrap
    }

    Item {
        id: footer
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        height: 13
    }
}
