pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

// The default sink plus every volume action the shell can take.
//
// `volumeUpdated` is emitted for *actions*, not only for property changes.
// Pipewire reports nothing when the user presses "volume up" at 100% or mutes
// an already muted sink, so the on-screen meter would never appear for those.
Singleton {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var audio: root.sink?.audio ?? null

    // ── Displayed level ─────────────────────────────────────────────
    // Pipewire echoes a write back through the node *and* the device route it
    // goes through. The two echoes can arrive out of order and still carry the
    // previous level, which made the OSD flash the old percentage before the
    // new one. Commands therefore update `displayed` immediately, and echoes of
    // our own write are ignored until Pipewire confirms the value we asked for.
    property real displayed: 0.0
    property real commanded: 0.0
    property bool settling: false

    readonly property real volume: root.displayed
    readonly property int volumePercent: Math.round(root.volume * 100)
    readonly property bool isMuted: root.audio?.muted ?? false
    readonly property bool atMax: root.volume >= 0.999
    readonly property bool atMin: root.volume <= 0.001

    // Keyboard shortcut step, matches `volumeStep` in the hyprland config.
    readonly property real step: 0.10
    // Finer step for the mouse wheel / trackpad.
    readonly property real wheelStep: 0.05

    signal volumeUpdated

    // ── Startup guard ───────────────────────────────────────────────
    // Pipewire publishes the default sink a moment after login. Binding it
    // looks exactly like a volume change, which used to pop the OSD up on its
    // own at boot. Changes are ignored until the sink has been up for a moment;
    // explicit actions still always show the OSD.
    property bool ready: false

    Timer {
        id: readyTimer
        interval: 1200
        onTriggered: root.ready = true
    }

    onAudioChanged: {
        root.ready = false;
        if (root.audio) {
            root.displayed = root.audio.volume;
            readyTimer.restart();
        }
    }

    Component.onCompleted: {
        if (root.audio)
            readyTimer.start();
    }

    // Gives up waiting for a confirmation that never arrives (for example a
    // write that was a no-op because the value was already at its limit). The
    // displayed value is deliberately left alone here: syncing it back to
    // Pipewire is what made the OSD flash the previous level.
    Timer {
        id: settleTimer
        interval: 500
        onTriggered: root.settling = false
    }

    PwObjectTracker {
        objects: [root.sink]
    }

    Connections {
        target: root.audio

        // External changes (wpctl, other apps, a headset's buttons) and the
        // confirmation of our own writes.
        function onVolumeChanged() {
            const value = root.audio.volume;

            if (root.settling) {
                // Ignore a stale echo, adopt the value we asked for as soon as
                // Pipewire confirms it.
                if (Math.abs(value - root.commanded) > 0.005)
                    return;
                root.settling = false;
                settleTimer.stop();
                root.displayed = value;
                return;
            }

            root.displayed = value;
            if (root.ready)
                root.volumeUpdated();
        }

        function onMutedChanged() {
            if (root.ready)
                root.volumeUpdated();
        }
    }

    function setVolume(value: real): void {
        const next = Math.max(0.0, Math.min(1.0, value));
        root.displayed = next;
        root.commanded = next;
        root.settling = true;
        settleTimer.restart();
        if (root.audio && Math.abs(root.audio.volume - next) > 0.0001)
            root.audio.volume = next;
        // Always notify, even when clamped: the user did press the key.
        root.volumeUpdated();
    }

    function changeVolume(delta: real): void {
        root.setVolume(root.volume + delta);
    }

    function volumeUp(): void {
        root.setVolume(root.volume + root.step);
    }

    function volumeDown(): void {
        root.setVolume(root.volume - root.step);
    }

    function toggleMute(): void {
        if (root.audio)
            root.audio.muted = !root.audio.muted;
        root.volumeUpdated();
    }

    function setMuted(muted: bool): void {
        if (root.audio)
            root.audio.muted = muted;
        root.volumeUpdated();
    }

    // qs ipc call volume up
    // qs ipc call volume down
    // qs ipc call volume mute
    // qs ipc call volume set 40
    // qs ipc call volume get
    IpcHandler {
        target: "volume"

        function up(): void {
            root.volumeUp();
        }

        function down(): void {
            root.volumeDown();
        }

        function mute(): void {
            root.toggleMute();
        }

        function set(percent: int): void {
            root.setVolume(percent / 100);
        }

        function get(): int {
            return root.volumePercent;
        }
    }
}
