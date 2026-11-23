import QtQuick
import qs
import qs.services

Item {
    id: root

    signal closeRequested

    property bool closeOnApply: true

    property string iconFont: "Material Symbols Rounded"

    function focusInput(): void {
        search.forceActiveFocus();
    }

    function filtered(query: string): var {
        const q = query.trim().toLowerCase();
        if (q.length === 0)
            return Schemes.schemes;
        return Schemes.schemes.filter(s => s.name.toLowerCase().indexOf(q) !== -1);
    }

    function reset(): void {
        search.text = "";
        Qt.callLater(function () {
            const i = results.model.findIndex(s => s.value === Schemes.scheme);
            results.currentIndex = i >= 0 ? i : (results.count > 0 ? 0 : -1);
        });
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

        Schemes.setScheme(list[index].value);
        if (root.closeOnApply)
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
            focusInput();
            Qt.callLater(focusInput);
        }
    }

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
        color: "transparent"

        Text {
            id: searchIcon
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            text: "palette"
            font.family: root.iconFont
            font.pixelSize: 18
            color: Theme.muted
        }

        Text {
            anchors.left: search.left
            anchors.verticalCenter: search.verticalCenter
            visible: search.text.length === 0
            text: "Search schemes…"
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
        model: root.filtered(search.text)
        currentIndex: -1

        delegate: Scheme {
            width: results.width
            view: results
            onActivated: root.activate(index)
        }

        // Typing changes the model: jump to the first match.
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
        text: "No matches for \"" + search.text + "\""
        color: Theme.muted
        font.pixelSize: 12
        wrapMode: Text.Wrap
    }

    // --- Footer: dark / light toggle --------------------------------------

    Item {
        id: footer
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        anchors.bottomMargin: 8
        height: 32

        Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: "Mode"
            color: Theme.muted
            font.pixelSize: 12
        }

        Rectangle {
            id: modeButton
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: modeRow.implicitWidth + 20
            height: 28
            radius: 14
            color: modeArea.containsMouse ? Qt.alpha(Theme.foreground, 0.10) : "transparent"

            Row {
                id: modeRow
                anchors.centerIn: parent
                spacing: 6

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Schemes.mode === "dark" ? "dark_mode" : "light_mode"
                    font.family: root.iconFont
                    font.pixelSize: 16
                    color: Theme.foreground
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Schemes.mode === "dark" ? "Dark" : "Light"
                    font.pixelSize: 12
                    color: Theme.foreground
                }
            }

            MouseArea {
                id: modeArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Schemes.toggleMode()
            }
        }
    }
}
